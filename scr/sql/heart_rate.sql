SET SEARCH_PATH TO mimiciii;

SELECT subject_id, hadm_id, icustay_id, heartrate
  FROM ( SELECT hc.subject_id
       , hc.hadm_id
       , hc.icustay_id
       , onsettime
       , ceh.value AS heartrate
       , ceh.charttime
       , row_number() over(PARTITION BY ceh.icustay_id ORDER BY ceh.icustay_id, ceh.charttime) AS heartrate_num
  FROM hypoxemia_cohort hc
       LEFT JOIN (SELECT *
                    FROM chartevents ce
                   WHERE ce.itemid = ANY (ARRAY[211, 220045])
                     AND (ce.valuenum > (0)::double precision)
                    AND (ce.valuenum < (300)::double precision)) ceh
       ON ceh.icustay_id = hc.icustay_id
 WHERE ceh.charttime >= hc.onsettime
  ORDER BY hc.subject_id, hc.hadm_id
       , hc.icustay_id
  ) heartrate
WHERE heartrate_num = 1


