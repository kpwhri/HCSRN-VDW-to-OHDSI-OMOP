
-- omop.condition_era

	select co.CONDITION_OCCURRENCE_ID, co.PERSON_ID, co.CONDITION_CONCEPT_ID, co.CONDITION_TYPE_CONCEPT_ID, co.CONDITION_START_DATE,
		COALESCE(co.CONDITION_END_DATE, DATEADD(day,1,CONDITION_START_DATE)) as CONDITION_END_DATE
	INTO omopTemp.cteConditionTarget
	FROM omop.CONDITION_OCCURRENCE co
;

 -- the magic

	select PERSON_ID, CONDITION_CONCEPT_ID, DATEADD(day,-30,EVENT_DATE) as END_DATE -- unpad the end date
	INTO omopTemp.cteEndDates
	FROM
	(
		select PERSON_ID, CONDITION_CONCEPT_ID, EVENT_DATE, EVENT_TYPE,
		MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		from
		(
			-- select the start dates, assigning a row number to each
			Select PERSON_ID, CONDITION_CONCEPT_ID, CONDITION_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY CONDITION_START_DATE) as START_ORDINAL
			from omopTemp.cteConditionTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			select PERSON_ID, CONDITION_CONCEPT_ID, DATEADD(day,30,CONDITION_END_DATE), 1 as EVENT_TYPE, NULL
			FROM omopTemp.cteConditionTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
;
GO


select
	c.PERSON_ID,
	c.CONDITION_CONCEPT_ID,
	c.CONDITION_TYPE_CONCEPT_ID,
	c.CONDITION_START_DATE,
	MIN(e.END_DATE) as CONDITION_END_DATE
into omopTemp.cteConditionEnds
FROM omopTemp.cteConditionTarget c
JOIN omopTemp.cteEndDates e  on c.PERSON_ID = e.PERSON_ID and c.CONDITION_CONCEPT_ID = e.CONDITION_CONCEPT_ID and e.END_DATE >= c.CONDITION_START_DATE
GROUP BY
	c.PERSON_ID,
	c.CONDITION_CONCEPT_ID,
	c.CONDITION_TYPE_CONCEPT_ID,
	c.CONDITION_START_DATE
;
GO

TRUNCATE TABLE omop.condition_era;
INSERT INTO omop.condition_era(
  condition_era_id,
  person_id,
  condition_concept_id,
  condition_era_start_date,
  condition_era_end_date,
  condition_occurrence_count)
select row_number() over (order by condition_concept_id), person_id, CONDITION_CONCEPT_ID, min(CONDITION_START_DATE) as CONDITION_ERA_START_DATE, CONDITION_END_DATE as CONDITION_ERA_END_DATE, COUNT(*) as CONDITION_OCCURRENCE_COUNT
from omopTemp.cteConditionEnds 
GROUP BY person_id, CONDITION_CONCEPT_ID, CONDITION_TYPE_CONCEPT_ID, CONDITION_END_DATE
order by person_id, CONDITION_CONCEPT_ID
;

drop table omopTemp.cteConditionEnds;
drop table omopTemp.cteConditionTarget;
drop table omopTemp.cteEndDates;



-- omop.dose_era

	SELECT 
		d.drug_exposure_id
		, d.person_id
		, c.concept_id AS ingredient_concept_id
		, ds.amount_unit_concept_id AS unit_concept_id
		, ds.amount_value AS dose_value
		, d.drug_exposure_start_date
		, d.days_supply AS days_supply
		, d.drug_exposure_end_date
	INTO omopTemp.cteDrugTarget
	FROM omop.drug_exposure d
	  INNER JOIN omop.drug_strength ds
	    ON d.drug_concept_id = ds.drug_concept_id	
	  INNER JOIN omop.concept_ancestor ca 
	    ON ca.descendant_concept_id = d.drug_concept_id
	  INNER JOIN omop.concept c 
	    ON ca.ancestor_concept_id = c.concept_id
	WHERE c.concept_class_id = 'Ingredient'
	AND c.vocabulary_id = 'RxNorm'
;
GO

--, cteEndDates(person_id, ingredient_concept_id, unit_concept_id, dose_value, end_date) AS 

	SELECT
		person_id, ingredient_concept_id, unit_concept_id, dose_value, dateadd(day, 30, event_date) AS end_date
	INTO omopTemp.cteEndDates
	FROM
	(
		SELECT person_id, ingredient_concept_id, unit_concept_id, dose_value, event_date, event_type, MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY event_date, event_type ROWS unbounded preceding) AS start_ordinal, ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY event_date, event_type) AS overall_ord
		FROM
		(
			SELECT person_id, 
			  ingredient_concept_id, 
			  unit_concept_id, 
			  dose_value, 
			  drug_exposure_start_date AS event_date, 
			  -1 AS event_type, 
			  ROW_NUMBER() OVER(PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY drug_exposure_start_date) AS start_ordinal
			FROM omopTemp.cteDrugTarget

			UNION ALL

			SELECT 
			  person_id, 
			  ingredient_concept_id, 
			  unit_concept_id, 
			  dose_value, 
			  dateadd(day, 30, drug_exposure_end_date) AS event_date, 
			  1 as event_type,
			  NULL as start_ordinal
			FROM omopTemp.cteDrugTarget
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
;
GO


--, cteDoseEraEnds(person_id, drug_concept_id, unit_concept_id, dose_value, drug_exposure_start_date, dose_era_end_date) AS
--( 
SELECT
	dt.person_id
	, dt.ingredient_concept_id as drug_concept_id
	, dt.unit_concept_id
	, dt.dose_value
	, dt.drug_exposure_start_date
	, MIN(e.end_date) AS dose_era_end_date
INTO omopTemp.cteDoseEraEnds
FROM omopTemp.cteDrugTarget dt
JOIN omopTemp.cteEndDates e
ON dt.person_id = e.person_id AND dt.ingredient_concept_id = e.ingredient_concept_id AND dt.unit_concept_id = e.unit_concept_id AND dt.dose_value = e.dose_value AND e.end_date >= dt.drug_exposure_start_date
GROUP BY
	dt.drug_exposure_id
	, dt.person_id
	, dt.ingredient_concept_id
	, dt.unit_concept_id
	, dt.dose_value
	, dt.drug_exposure_start_date


INSERT INTO omop.dose_era(dose_era_id, person_id, drug_concept_id, unit_concept_id, dose_value, dose_era_start_date, dose_era_end_date)
SELECT row_number() over (order by dose.person_id, dose.drug_concept_id, dose.unit_concept_id, dose.dose_value, dose.dose_era_start_date) as dose_era_id, dose.*
FROM
(
SELECT person_id, drug_concept_id, unit_concept_id, dose_value, MIN(drug_exposure_start_date) AS dose_era_start_date, dose_era_end_date
FROM omopTemp.cteDoseEraEnds
GROUP BY person_id, drug_concept_id, unit_concept_id, dose_value, dose_era_end_date
) dose
;

drop table omopTemp.cteDrugTarget;
drop table omopTemp.cteDoseEraEnds;
drop table omopTemp.cteEndDates;




-- omop.drug_era
-- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
	select d.DRUG_EXPOSURE_ID, d. PERSON_ID, c.CONCEPT_ID as DRUG_CONCEPT_ID, d.DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE,
		COALESCE(DRUG_EXPOSURE_END_DATE, DATEADD(day,DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,DRUG_EXPOSURE_START_DATE)) as DRUG_EXPOSURE_END_DATE,
		c.CONCEPT_ID as INGREDIENT_CONCEPT_ID
	INTO omopTemp.cteDrugTarget
	FROM omop.DRUG_EXPOSURE d
		join omop.CONCEPT_ANCESTOR ca on ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
		join omop.CONCEPT c on ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
		where c.VOCABULARY_ID = 'RxNorm'
		and c.CONCEPT_CLASS_ID = 'Ingredient'
;
GO


	select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,-30,EVENT_DATE) as END_DATE -- unpad the end date
	INTO omopTemp.cteEndDates
	FROM
	(
		select PERSON_ID, INGREDIENT_CONCEPT_ID, EVENT_DATE, EVENT_TYPE,
		MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		from
		(
			-- select the start dates, assigning a row number to each
			Select PERSON_ID, INGREDIENT_CONCEPT_ID, DRUG_EXPOSURE_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, DRUG_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE) as START_ORDINAL
			from omopTemp.cteDrugTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,30,DRUG_EXPOSURE_END_DATE), 1 as EVENT_TYPE, NULL
			FROM omopTemp.cteDrugTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
;
GO

select distinct
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID as DRUG_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE,
	MIN(e.END_DATE) as DRUG_ERA_END_DATE
INTO omopTemp.cteDrugExposureEnds
FROM omopTemp.cteDrugTarget d
JOIN omopTemp.cteEndDates e  on d.PERSON_ID = e.PERSON_ID and d.INGREDIENT_CONCEPT_ID = e.INGREDIENT_CONCEPT_ID and e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
GROUP BY d.DRUG_EXPOSURE_ID,
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE
;
GO

-- Add INSERT statement here
TRUNCATE TABLE omop.drug_era;
INSERT INTO omop.drug_era (
  drug_era_id,
  person_id,
  drug_concept_id,
  drug_era_start_date,
  drug_era_end_date,
  drug_exposure_count,
  gap_days
)
select row_number() over (order by drug_concept_id) as drug_era_id, 
	person_id, 
	drug_concept_id, 
	min(DRUG_EXPOSURE_START_DATE) as DRUG_ERA_START_DATE, 
	DRUG_ERA_END_DATE, 
	COUNT(*) as DRUG_EXPOSURE_COUNT,
	NULL as gap_days
from omopTemp.cteDrugExposureEnds
GROUP BY person_id, drug_concept_id, drug_type_concept_id, DRUG_ERA_END_DATE
order by person_id, drug_concept_id
;

drop table omopTemp.cteDrugExposureEnds;
drop table omopTemp.cteDrugTarget;
drop table omopTemp.cteEndDates;


-- observation_period
-- populate omop.observation_period
TRUNCATE TABLE omop.observation_period;
INSERT INTO omop.observation_period (
  observation_period_id,
  person_id,
  observation_period_start_date,
  observation_period_start_datetime,
  observation_period_end_date,
  observation_period_end_datetime,
  period_type_concept_id
)
SELECT
  opcnt.oid+row_number() over (order by current_timestamp) as observation_period_id,
  opq.*
FROM
(
SELECT
  person.person_id AS [person_id],
  MIN(visit_occurrence.visit_start_date) AS [observation_period_start_date],
  MIN(visit_occurrence.visit_start_datetime) AS [observation_period_start_datetime],
  MAX(visit_occurrence.visit_end_date) AS [observation_period_end_date],
  MAX(visit_occurrence.visit_end_datetime) AS [observation_period_end_datetime],
  44814725 as period_type_concept_id
FROM  omop.person (nolock)
JOIN omop.visit_occurrence (nolock) ON person.person_id = visit_occurrence.person_id
GROUP BY person.person_id
) opq,
 (select coalesce(MAX(observation_period_id), 0) as oid from omop.observation_period) as opcnt
;
GO





/************************************************************
************DEPRECATED ************************************
-- populate omop.drug_era
-- period of type that a drug was being received... not a VDW element

TRUNCATE TABLE omop.drug_era;
with cteDrugTarget (DRUG_EXPOSURE_ID, PERSON_ID, DRUG_CONCEPT_ID, DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE, DRUG_EXPOSURE_END_DATE, INGREDIENT_CONCEPT_ID) as
(
-- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
	select d.DRUG_EXPOSURE_ID, d. PERSON_ID, c.CONCEPT_ID, d.DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE,
		COALESCE(DRUG_EXPOSURE_END_DATE, DATEADD(day,DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,DRUG_EXPOSURE_START_DATE)) as DRUG_EXPOSURE_END_DATE,
		c.CONCEPT_ID as INGREDIENT_CONCEPT_ID
	FROM omop.DRUG_EXPOSURE d (nolock)
		join omop.CONCEPT_ANCESTOR ca (nolock) on ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
		join omop.CONCEPT c (nolock) on ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
		where c.VOCABULARY_ID = 'RxNorm'
		and c.CONCEPT_CLASS_ID = 'Ingredient'
),
cteEndDates (PERSON_ID, INGREDIENT_CONCEPT_ID, END_DATE) as -- the magic
(
	select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,-30,EVENT_DATE) as END_DATE -- unpad the end date
	FROM
	(
		select PERSON_ID, INGREDIENT_CONCEPT_ID, EVENT_DATE, EVENT_TYPE,
		MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		from
		(
			-- select the start dates, assigning a row number to each
			Select PERSON_ID, INGREDIENT_CONCEPT_ID, DRUG_EXPOSURE_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, DRUG_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE) as START_ORDINAL
			from cteDrugTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,30,DRUG_EXPOSURE_END_DATE), 1 as EVENT_TYPE, NULL
			FROM cteDrugTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
),
cteDrugExposureEnds (PERSON_ID, DRUG_CONCEPT_ID, DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE, DRUG_ERA_END_DATE) as
(
select
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE,
	MIN(e.END_DATE) as ERA_END_DATE
FROM cteDrugTarget d
JOIN cteEndDates e  on d.PERSON_ID = e.PERSON_ID and d.INGREDIENT_CONCEPT_ID = e.INGREDIENT_CONCEPT_ID and e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
GROUP BY d.DRUG_EXPOSURE_ID,
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE
)
-- Add INSERT statement here
INSERT INTO omop.drug_era (
  drug_era_id,
  person_id,
  drug_concept_id,
  drug_era_start_date,
  drug_era_end_date,
  drug_exposure_count)
select row_number() over (order by drug_concept_id), person_id, drug_concept_id, min(DRUG_EXPOSURE_START_DATE) as DRUG_ERA_START_DATE, DRUG_ERA_END_DATE, COUNT(*) as DRUG_EXPOSURE_COUNT
from cteDrugExposureEnds
GROUP BY person_id, drug_concept_id, drug_type_concept_id, DRUG_ERA_END_DATE
order by person_id, drug_concept_id
;
GO
*/