DROP MATERIALIZED VIEW IF EXISTS hypoxemia_charts CASCADE;
CREATE MATERIALIZED VIEW hypoxemia_charts AS 
SELECT 
	subject_id, hadm_id, icustay_id, charttime,
	MAX(CASE WHEN itemid IN (3785, 3837, 490, 779) THEN valuenum ELSE NULL END) AS PaO2,
	ROUND(CAST(MAX(
      case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end) AS NUMERIC), 2) AS fio2,
	MAX(CASE WHEN itemid IN (60, 437, 505, 506, 686, 3555, 220339, 224700) THEN valuenum ELSE NULL END) AS peep 
FROM 
	chartevents
WHERE itemid IN (
		-- PaO2
		3785,	-- PO2
		3837,	-- PO2
		-- 3838,	-- pO2 (other)
		-- 4203,	-- pO2 (cap)
		-- 227516,	-- PO2 (Mixed Venous)
		490, -- PaO2
		779, -- Arterial PaO2

		-- FiO2
		3420, -- FiO2
		190, -- FiO2 set
		223835, -- Inspired O2 Fraction (FiO2)
		3422, -- FiO2 [measured]
		-- PEEP  
		60,		-- Auto-PEEP level | carevue
		437,	-- Low Peep |	carevue 					 			
		505,	-- PEEP			|	carevue 
		506,	-- PEEP Set	|	carevue 
		686,	-- Total PEEP LEVEL	|	carevue 
		3555,	-- PEEP Alarm	| carevue 
		220339,	-- PEEP Set	|	metavision
		224700	-- Total PEEP	Level	| metavision 
) AND value IS NOT NULL 
	GROUP BY subject_id, hadm_id, icustay_id, charttime
	ORDER BY subject_id, hadm_id, icustay_id, charttime