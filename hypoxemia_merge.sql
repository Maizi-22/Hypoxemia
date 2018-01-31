CREATE MATERIALIZED VIEW hypoxemia_merge AS WITH mergedata AS (
         SELECT hypoxemia_charts.subject_id,
            hypoxemia_charts.hadm_id,
            hypoxemia_charts.icustay_id,
            hypoxemia_charts.charttime,
            hypoxemia_charts.pao2,
            hypoxemia_charts.fio2,
            hypoxemia_charts.peep
           FROM mimiciii.hypoxemia_charts
        UNION
         SELECT hypoxemia_labs.subject_id,
            hypoxemia_labs.hadm_id,
            hypoxemia_labs.icustay_id,
            hypoxemia_labs.charttime,
            hypoxemia_labs.pao2,
            hypoxemia_labs.fio2,
            hypoxemia_labs.peep
           FROM mimiciii.hypoxemia_labs
  ORDER BY 1, 2, 3, 4
        ), tmp AS (
         SELECT mergedata.subject_id,
            mergedata.hadm_id,
            mergedata.icustay_id,
            mergedata.charttime,
            round((max(mergedata.pao2))::numeric, 2) AS pao2,
            max(mergedata.fio2) AS fio2,
            max(mergedata.peep) AS peep
           FROM mergedata
          WHERE ((mergedata.pao2 IS NOT NULL) AND (mergedata.fio2 IS NOT NULL))
          GROUP BY mergedata.subject_id, mergedata.hadm_id, mergedata.icustay_id, mergedata.charttime
          ORDER BY mergedata.subject_id, mergedata.hadm_id, mergedata.icustay_id, mergedata.charttime
        )
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
        END AS onsite,
    tmp.peep
   FROM tmp
  WHERE (tmp.fio2 <> (0)::double precision);

