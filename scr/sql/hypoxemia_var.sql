SET SEARCH_PATH TO mimiciii;
CREATE MATERIALIZED VIEW hypoxemia_var AS WITH hypoxemia_chart AS (
SELECT chartevents.subject_id,
    chartevents.hadm_id,
    chartevents.icustay_id,
    chartevents.charttime,
    max(
        CASE
            WHEN (chartevents.itemid = ANY (ARRAY[3785, 3837, 490, 779])) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS pao2,
    round((max(
        CASE
            WHEN (chartevents.itemid = 223835) THEN
            CASE
                WHEN ((chartevents.valuenum > (0)::double precision) AND (chartevents.valuenum <= (1)::double precision)) THEN (chartevents.valuenum * (100)::double precision)
                WHEN ((chartevents.valuenum > (1)::double precision) AND (chartevents.valuenum < (21)::double precision)) THEN NULL::double precision
                WHEN ((chartevents.valuenum >= (21)::double precision) AND (chartevents.valuenum <= (100)::double precision)) THEN chartevents.valuenum
                ELSE NULL::double precision
            END
            WHEN (chartevents.itemid = ANY (ARRAY[3420, 3422])) THEN chartevents.valuenum
            WHEN ((chartevents.itemid = 190) AND (chartevents.valuenum > (0.20)::double precision) AND (chartevents.valuenum < (1)::double precision)) THEN (chartevents.valuenum * (100)::double precision)
            ELSE NULL::double precision
        END))::numeric, 2) AS fio2,
    max(
        CASE
            WHEN (chartevents.itemid = ANY (ARRAY[60, 437, 505, 506, 686, 3555, 220339, 224700])) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS peep,
    max(
        CASE
            WHEN (chartevents.itemid = ANY (ARRAY[1103, 113, 220074])) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS cvp,
    max(
        CASE
            WHEN (chartevents.itemid = ANY (ARRAY[8364, 8368, 8440, 8441, 8555, 220180, 220051])) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS dbp
   FROM mimiciii.chartevents
  WHERE ((chartevents.itemid = ANY (ARRAY[3785, 3837, 490, 779, 3420, 190, 223835, 3422, 60, 437, 505, 506, 686, 3555, 220339, 224700, 8364, 8368, 8440, 8441, 8555, 220180, 220051, 1103, 113, 220074])) AND (chartevents.value IS NOT NULL))
  GROUP BY chartevents.subject_id, chartevents.hadm_id, chartevents.icustay_id, chartevents.charttime
  ORDER BY chartevents.subject_id, chartevents.hadm_id, chartevents.icustay_id, chartevents.charttime
)
, hypoxemia_lab AS (
SELECT idet.subject_id,
    idet.hadm_id,
    idet.icustay_id,
    le.charttime,
    max(
        CASE
            WHEN (le.itemid = 50816) THEN le.valuenum
            ELSE NULL::double precision
        END) AS fio2,
    max(
        CASE
            WHEN (le.itemid = 50821) THEN le.valuenum
            ELSE NULL::double precision
        END) AS pao2,
    max(
        CASE
            WHEN (le.itemid = 50819) THEN le.valuenum
            ELSE NULL::double precision
        END) AS peep
   FROM (mimiciii.labevents le
     LEFT JOIN mimiciii.icustay_detail idet ON (((idet.subject_id = le.subject_id) AND (idet.hadm_id = le.hadm_id))))
  WHERE ((le.itemid = ANY (ARRAY[50821, 50816, 50819])) AND ((le.charttime >= idet.intime) AND (le.charttime <= idet.outtime)))
  GROUP BY idet.subject_id, idet.hadm_id, idet.icustay_id, le.charttime
  ORDER BY idet.subject_id, idet.hadm_id, idet.icustay_id, le.charttime
)
SELECT hypoxemia_chart.subject_id,
            hypoxemia_chart.hadm_id,
            hypoxemia_chart.icustay_id,
            hypoxemia_chart.charttime,
            hypoxemia_chart.pao2,
            hypoxemia_chart.fio2,
            hypoxemia_chart.peep,
            hypoxemia_chart.cvp,
            hypoxemia_chart.dbp
           FROM hypoxemia_chart
        UNION
         SELECT hypoxemia_lab.subject_id,
            hypoxemia_lab.hadm_id,
            hypoxemia_lab.icustay_id,
            hypoxemia_lab.charttime,
            hypoxemia_lab.pao2,
            hypoxemia_lab.fio2,
            hypoxemia_lab.peep,
            NULL AS cvp,
            NULL AS dbp
           FROM hypoxemia_lab
  ORDER BY 1, 2, 3, 4
