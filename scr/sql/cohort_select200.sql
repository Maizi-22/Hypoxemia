CREATE MATERIALIZED VIEW hypoxemia_cohort200 AS WITH tmp AS (
         SELECT hv.subject_id,
            hv.hadm_id,
            hv.icustay_id,
            hv.charttime,
            round((max(hv.pao2))::numeric, 2) AS pao2,
            max(hv.fio2) AS fio2
           FROM mimiciii.hypoxemia_var hv
          WHERE ((hv.pao2 IS NOT NULL) AND (hv.fio2 IS NOT NULL))
          GROUP BY hv.subject_id, hv.hadm_id, hv.icustay_id, hv.charttime
          ORDER BY hv.subject_id, hv.hadm_id, hv.icustay_id, hv.charttime
        ), hypoxemia_merge AS (
         SELECT tmp.subject_id,
            tmp.hadm_id,
            tmp.icustay_id,
            tmp.charttime,
            tmp.pao2,
            tmp.fio2,
            round((((tmp.pao2)::double precision / tmp.fio2))::numeric, 2) AS pao2fio2ratio,
                CASE
                    WHEN (((tmp.pao2)::double precision / tmp.fio2) <= (2)::double precision) THEN 1
                    ELSE 0
                END AS onsite
           FROM tmp
          WHERE (tmp.fio2 <> (0)::double precision)
        ), pvt AS (
         SELECT hypoxemia_merge.subject_id,
            hypoxemia_merge.hadm_id,
            hypoxemia_merge.icustay_id,
            hypoxemia_merge.charttime,
            hypoxemia_merge.pao2,
            hypoxemia_merge.fio2,
            hypoxemia_merge.pao2fio2ratio,
            hypoxemia_merge.charttime AS onsettime,
            row_number() OVER (PARTITION BY hypoxemia_merge.subject_id, hypoxemia_merge.icustay_id ORDER BY hypoxemia_merge.charttime) AS onset_index
           FROM hypoxemia_merge
          WHERE (hypoxemia_merge.onsite = 1)
        ), oi_mv AS (
         SELECT DISTINCT pvt.subject_id,
            pvt.hadm_id,
            pvt.icustay_id,
            pvt.charttime,
            pvt.pao2,
            pvt.fio2,
            pvt.pao2fio2ratio,
            pvt.onsettime,
            pvt.onset_index
           FROM (pvt
             JOIN mimiciii.ventdurations vent ON ((vent.icustay_id = pvt.icustay_id)))
          WHERE (pvt.onset_index = 1)
        )
 SELECT DISTINCT oim.subject_id,
    oim.hadm_id,
    oim.icustay_id,
    oim.charttime,
    oim.pao2,
    oim.fio2,
    oim.pao2fio2ratio,
    oim.onsettime,
    oim.onset_index
   FROM (oi_mv oim
     JOIN mimiciii.vasopressordurations vas ON ((oim.icustay_id = vas.icustay_id)))
  WHERE ((oim.onsettime >= (vas.starttime - '06:00:00'::interval hour)) AND (oim.onsettime <= (vas.endtime + '06:00:00'::interval hour)))
  ORDER BY oim.subject_id;

