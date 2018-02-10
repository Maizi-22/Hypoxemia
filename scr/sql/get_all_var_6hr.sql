SET SEARCH_PATH TO mimiciii;

WITH tmp AS (
    SELECT DISTINCT
      hc.subject_id,
      hc.hadm_id,
      hc.onsettime,
      hc.pao2fio2ratio
      -- cvp
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '06:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_pre1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '05:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_pre2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '04:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_pre3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '03:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_pre4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '02:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '01:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_pre5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '01:00:00' :: INTERVAL HOUR AND hc.onsettime
        THEN hv.cvp END  AS cvp_pre6
      -- dbp
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '06:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_pre1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '05:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_pre2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '04:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_pre3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '03:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_pre4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '02:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '01:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_pre5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '01:00:00' :: INTERVAL HOUR AND hc.onsettime
        THEN hv.dbp END  AS dbp_pre6
      -- peep
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '06:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_pre1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '05:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_pre2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '04:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_pre3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '03:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_pre4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '02:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '01:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_pre5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '01:00:00' :: INTERVAL HOUR AND hc.onsettime
        THEN hv.peep END AS peep_pre6
      -- heartrate
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '06:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_pre1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '05:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_pre2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '04:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_pre3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '03:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_pre4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '02:00:00' :: INTERVAL HOUR AND hc.onsettime -
                                                                                    '01:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_pre5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime - '01:00:00' :: INTERVAL HOUR AND hc.onsettime
        THEN hv.heartrate END AS heartrate_pre6
      -- cvp post
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime AND hc.onsettime + '01:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '01:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '02:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '03:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '04:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '05:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '06:00:00' :: INTERVAL HOUR
        THEN hv.cvp END  AS cvp_post6
      -- dbp post
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime AND hc.onsettime + '01:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '01:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '02:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '03:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '04:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '05:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '06:00:00' :: INTERVAL HOUR
        THEN hv.dbp END  AS dbp_post6
      -- peep post
      ,
      CASE WHEN hv.charttime BETWEEN hc.onsettime AND hc.onsettime + '01:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '01:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '02:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '03:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '04:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '05:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '06:00:00' :: INTERVAL HOUR
        THEN hv.peep END AS peep_post6,
      -- heartrate post
      CASE WHEN hv.charttime BETWEEN hc.onsettime AND hc.onsettime + '01:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post1,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '01:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '02:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post2,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '02:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '03:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post3,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '03:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '04:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post4,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '04:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '05:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post5,
      CASE WHEN hv.charttime BETWEEN hc.onsettime + '05:00:00' :: INTERVAL HOUR AND hc.onsettime +
                                                                                    '06:00:00' :: INTERVAL HOUR
        THEN hv.heartrate END AS heartrate_post6
    FROM hypoxemia_cohort100_limited hc
      LEFT JOIN hypoxemia_var hv
        ON hv.hadm_id = hc.hadm_id
)
SELECT subject_id, hadm_id, onsettime, pao2fio2ratio
       , avg(tmp.cvp_pre1) AS cvp_pre1
       , avg(tmp.cvp_pre2) AS cvp_pre2
       , avg(tmp.cvp_pre3) AS cvp_pre3
       , avg(tmp.cvp_pre4) AS cvp_pre4
       , avg(tmp.cvp_pre5) AS cvp_pre5
       , avg(tmp.cvp_pre6) AS cvp_pre6
       , avg(tmp.dbp_pre1) AS dbp_pre1
       , avg(tmp.dbp_pre2) AS dbp_pre2
       , avg(tmp.dbp_pre3) AS dbp_pre3
       , avg(tmp.dbp_pre4) AS dbp_pre4
       , avg(tmp.dbp_pre5) AS dbp_pre5
       , avg(tmp.dbp_pre6) AS dbp_pre6
       , avg(tmp.peep_pre1) AS peep_pre1
       , avg(tmp.peep_pre2) AS peep_pre2
       , avg(tmp.peep_pre3) AS peep_pre3
       , avg(tmp.peep_pre4) AS peep_pre4
       , avg(tmp.peep_pre5) AS peep_pre5
       , avg(tmp.peep_pre6) AS peep_pre6
       , avg(tmp.heartrate_pre1) AS heartrate_pre1
       , avg(tmp.heartrate_pre2) AS heartrate_pre2
       , avg(tmp.heartrate_pre3) AS heartrate_pre3
       , avg(tmp.heartrate_pre4) AS heartrate_pre4
       , avg(tmp.heartrate_pre5) AS heartrate_pre5
       , avg(tmp.heartrate_pre6) AS heartrate_pre6
       , avg(tmp.cvp_post1) AS cvp_post1
       , avg(tmp.cvp_post2) AS cvp_post2
       , avg(tmp.cvp_post3) AS cvp_post3
       , avg(tmp.cvp_post4) AS cvp_post4
       , avg(tmp.cvp_post5) AS cvp_post5
       , avg(tmp.cvp_post6) AS cvp_post6
       , avg(tmp.dbp_post1) AS dbp_post1
       , avg(tmp.dbp_post2) AS dbp_post2
       , avg(tmp.dbp_post3) AS dbp_post3
       , avg(tmp.dbp_post4) AS dbp_post4
       , avg(tmp.dbp_post5) AS dbp_post5
       , avg(tmp.dbp_post6) AS dbp_post6
       , avg(tmp.peep_post1) AS peep_post1
       , avg(tmp.peep_post2) AS peep_post2
       , avg(tmp.peep_post3) AS peep_post3
       , avg(tmp.peep_post4) AS peep_post4
       , avg(tmp.peep_post5) AS peep_post5
       , avg(tmp.peep_post6) AS peep_post6
       , avg(tmp.heartrate_post1) AS heartrate_post1
       , avg(tmp.heartrate_post2) AS heartrate_post2
       , avg(tmp.heartrate_post3) AS heartrate_post3
       , avg(tmp.heartrate_post4) AS heartrate_post4
       , avg(tmp.heartrate_post5) AS heartrate_post5
       , avg(tmp.heartrate_post6) AS heartrate_post6
  FROM tmp
 GROUP BY subject_id, hadm_id, onsettime, pao2fio2ratio;

