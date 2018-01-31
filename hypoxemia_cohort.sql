CREATE MATERIALIZED VIEW hypoxemia_cohort AS
-- Find hypoxemia onset time
WITH pvt AS (
SELECT subject_id, hadm_id, icustay_id, charttime, pao2, fio2, peep, pao2fio2ratio, charttime AS onsettime,
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



