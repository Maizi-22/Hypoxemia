SET SEARCH_PATH TO mimiciii;
DROP MATERIALIZED VIEW IF EXISTS hypoxemia_var CASCADE;
CREATE MATERIALIZED VIEW hypoxemia_var AS WITH hypoxemia_chart AS (
SELECT chartevents.subject_id,
    chartevents.hadm_id,
    chartevents.icustay_id,
    chartevents.charttime,
    /*max(
        CASE
            WHEN (chartevents.itemid = ANY (ARRAY[3785, 3837, 490, 779])) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS pao2, */
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
            WHEN (chartevents.itemid IN (1096, 505, 506, 60, 437, 220339, 224700, 686)) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS peep,
    max(
        CASE
            WHEN (chartevents.itemid IN (1250, 118, 1103, 113, 220074)) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS cvp,
    max(
        CASE
            WHEN (chartevents.itemid IN (8368, 8440, 8441, 8555, 220180, 220051, 118)) THEN chartevents.valuenum
            ELSE NULL::double precision
        END) AS dbp
   FROM mimiciii.chartevents
  WHERE ((chartevents.itemid IN (3785, 3837, 490, 779, 223835, 3420, 3422, 190, 1096, 505, 506, 60, 437, 220339, 224700, 686, 1250, 118, 1103, 113, 220074, 8368, 8440, 8441, 8555, 220180, 220051, 118)) AND (chartevents.value IS NOT NULL))
  GROUP BY chartevents.subject_id, chartevents.hadm_id, chartevents.icustay_id, chartevents.charttime
  ORDER BY chartevents.subject_id, chartevents.hadm_id, chartevents.icustay_id, chartevents.charttime
)
, pvt AS (
         SELECT ie.subject_id,
            ie.hadm_id,
            ie.icustay_id,
                CASE
                    WHEN (le.itemid = 50816) THEN 'FIO2'::text
                    WHEN (le.itemid = 50819) THEN 'PEEP'::text
                    WHEN (le.itemid = 50821) THEN 'PO2'::text

                    ELSE NULL::text
                END AS label,
            le.charttime,
            le.value,
                CASE
                    WHEN (le.valuenum <= (0)::double precision) THEN NULL::double precision
                    WHEN ((le.itemid = 50816) AND (le.valuenum < (20)::double precision)) THEN NULL::double precision
                    WHEN ((le.itemid = 50816) AND (le.valuenum > (100)::double precision)) THEN NULL::double precision
                    WHEN ((le.itemid = 50821) AND (le.valuenum > (800)::double precision)) THEN NULL::double precision
                    ELSE le.valuenum
                END AS valuenum
           FROM (mimiciii.icustays ie
             LEFT JOIN mimiciii.labevents le ON (((le.subject_id = ie.subject_id) AND (le.hadm_id = ie.hadm_id) AND (le.charttime >= (ie.intime - '06:00:00'::interval hour)) AND (le.itemid = ANY (ARRAY[50816, 50819, 50821])))))
        )
, hypoxemia_lab AS (
      SELECT
        pvt.subject_id,
        pvt.hadm_id,
        pvt.icustay_id,
        pvt.charttime,
        max(
            CASE
            WHEN (pvt.label = 'FIO2' :: TEXT)
              THEN pvt.valuenum
            ELSE NULL :: DOUBLE PRECISION
            END) AS fio2,
        max(
            CASE
            WHEN (pvt.label = 'PEEP' :: TEXT)
              THEN pvt.valuenum
            ELSE NULL :: DOUBLE PRECISION
            END) AS peep,
        max(
            CASE
            WHEN (pvt.label = 'PO2' :: TEXT)
              THEN pvt.valuenum
            ELSE NULL :: DOUBLE PRECISION
            END) AS po2

      FROM pvt
      GROUP BY pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.charttime
      ORDER BY pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.charttime
)
SELECT hypoxemia_chart.subject_id,
            hypoxemia_chart.hadm_id,
            hypoxemia_chart.icustay_id,
            hypoxemia_chart.charttime,
            NULL AS pao2,
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
            hypoxemia_lab.po2 AS pao2,
            hypoxemia_lab.fio2,
            hypoxemia_lab.peep,
            NULL AS cvp,
            NULL AS dbp
           FROM hypoxemia_lab
  ORDER BY 1, 2, 3, 4
