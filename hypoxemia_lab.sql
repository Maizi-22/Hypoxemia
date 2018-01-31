DROP MATERIALIZED VIEW IF EXISTS hypoxemia_labs CASCADE;
CREATE MATERIALIZED VIEW hypoxemia_labs AS
	SELECT idet.subject_id, idet.hadm_id, idet.icustay_id, le.charttime, 
		MAX(CASE WHEN itemid = 50816 THEN valuenum ELSE NULL END) AS fio2,
		MAX(CASE WHEN itemid = 50821 THEN valuenum ELSE NULL END) AS pao2,
		MAX(CASE WHEN itemid = 50819 THEN valuenum ELSE NULL END) AS peep
	FROM labevents le 
	LEFT JOIN icustay_detail idet
		ON idet.subject_id = le.subject_id AND idet.hadm_id = le.hadm_id
	WHERE le.itemid IN (50821, 50816, 50819)
		AND le.charttime BETWEEN idet.intime AND idet.outtime 
	GROUP BY idet.subject_id, idet.hadm_id, idet.icustay_id, le.charttime
	ORDER BY idet.subject_id, idet.hadm_id, idet.icustay_id, le.charttime
