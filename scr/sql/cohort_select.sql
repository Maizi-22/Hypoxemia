SET SEARCH_PATH TO mimiciii;
-- This query extract hypoxemia patients’ CVP and DBP value in 6 hour before and after OI onset
-- If patient have multiple record in one hour, will calculate average of this hour

DROP MATERIALIZED VIEW IF EXISTS hypoxemia_cohort CASCADE;
CREATE MATERIALIZED VIEW hypoxemia_cohort AS WITH  tmp AS (
         SELECT hv.subject_id,
            hv.hadm_id,
            hv.icustay_id,
            hv.charttime,
            round((max(hv.pao2))::numeric, 2) AS pao2,
            max(hv.fio2) AS fio2
           FROM hypoxemia_var hv
          WHERE ((hv.pao2 IS NOT NULL) AND (hv.fio2 IS NOT NULL))
          GROUP BY hv.subject_id, hv.hadm_id, hv.icustay_id, hv.charttime
          ORDER BY hv.subject_id, hv.hadm_id, hv.icustay_id, hv.charttime
        )
  , hypoxemia_merge AS(
     SELECT tmp.subject_id,
    tmp.hadm_id,
    tmp.icustay_id,
    tmp.charttime,
    tmp.pao2,
    tmp.fio2,
    round((((tmp.pao2)::double precision / tmp.fio2))::numeric, 2) AS pao2fio2ratio,
        CASE
            WHEN (((tmp.pao2)::double precision / tmp.fio2) <= (1)::double precision) THEN 1
            ELSE 0
        END AS onsite
   FROM tmp
  WHERE (tmp.fio2 <> (0)::double precision)
  )
, pvt AS (
SELECT subject_id, hadm_id, icustay_id, charttime, pao2, fio2, pao2fio2ratio, charttime AS onsettime,
ROW_NUMBER() OVER(
	PARTITION BY subject_id, icustay_id
	ORDER BY charttime
) AS onset_index
FROM hypoxemia_merge WHERE onsite = 1
  -- 4040 patients
)
-- select MV patients
, oi_mv AS(
SELECT DISTINCT pvt.*
  FROM pvt
       INNER JOIN ventdurations vent
	     ON vent.icustay_id = pvt.icustay_id
 WHERE onset_index = 1
  -- 3637 patients
)

SELECT DISTINCT oim.*
  --distinct oim.*, vas.starttime AS vas_starttime, vas.endtime vas_endtime
  FROM oi_mv oim
		   -- exclude vasopressor use in 6 hours
	     INNER JOIN mimiciii.vasopressordurations vas
	     ON oim.icustay_id = vas.icustay_id
	     WHERE oim.onsettime BETWEEN vas.starttime - '6 hour'::INTERVAL HOUR AND vas.endtime + '6 hour'::INTERVAL HOUR
 ORDER BY oim.subject_id
--1593 subject when window size 6hr



