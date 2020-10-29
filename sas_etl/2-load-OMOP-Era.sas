/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Load OMOP Era Tables
* Date Created:: 10/19/2020
*********************************************/

* temp condition era table;
proc sql;
  create table cte_condition_trgt as
    select distinct co.CONDITION_OCCURRENCE_ID, co.person_id,
      co.condition_concept_id, co.CONDITION_TYPE_CONCEPT_ID,
      input(co.CONDITION_START_DATE, date.) as condition_start_date,
      COALESCE(input(co.CONDITION_END_DATE, date.), intnx('day', input(co.CONDITION_START_DATE, date.), 1)) as CONDITION_END_DATE
  from omop.condition_occurrence co
  ;
quit;


* start a complex combination of date mergers for creating condition era table;
proc sql;
  create table cte_condcnt_b as
  select distinct person_id, condition_concept_id
  from work.cte_condition_trgt
  ORDER BY person_id, condition_concept_id
    ;
quit;


* assign a unique row number to each condition concept and person;
proc sql;
  create table cte_condcnt_a as
    select monotonic() as row_num, *
    from work.cte_condcnt_b
    ;
quit;


* pad the end dates by 30 to allow a grace period for overlapping ranges;
proc sql;
  create table cte_condition_data as
  Select ca.PERSON_ID, cc.condition_concept_id, cc.CONDITION_START_DATE AS EVENT_DATE,
      -1 as EVENT_TYPE, ca.row_num as start_ordinal
  from work.cte_condition_trgt cc
  left join work.cte_condcnt_a ca
  on cc.person_id = ca.person_id
  and cc.condition_concept_id = ca.condition_concept_id
	UNION ALL
  select ct.PERSON_ID, ct.CONDITION_CONCEPT_ID, intnx('day', 30, ct.CONDITION_END_DATE) as event_date,
    1 as EVENT_TYPE, . as start_ordinal
  FROM work.cte_condition_trgt ct
; 
quit;


* distinct condition data with max start ordinal; 
* select the start dates, assigning a row number to each;
* this re-numbers the inner UNION so all rows are numbered ordered by the event date; 
proc sql;
  create table cte_condition_ord as
    select monotonic() as overall_ord, person_id, condition_concept_id, event_date, event_type, start_ordinal
    from work.cte_condition_data
    order by event_date, event_type
    ;
quit;


* pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with;
proc sql;
  create table cte_enddates as
  select PERSON_ID, CONDITION_CONCEPT_ID, intnx('day', -30, EVENT_DATE) as END_DATE, event_date, event_type 
	FROM work.cte_condition_ord 
	WHERE (2 * START_ORDINAL) - OVERALL_ORD = 0
;
quit;


* temp condition table bringing it all together;
proc sql;
  create table cte_condition_end as
  select distinct
	  c.PERSON_ID,
	  c.CONDITION_CONCEPT_ID,
	  c.CONDITION_TYPE_CONCEPT_ID,
	  min(c.CONDITION_START_DATE) as condition_start_date,
    MIN(e.END_DATE) as CONDITION_END_DATE,
    count(*) as condition_occurrence_count
  FROM work.cte_condition_trgt c
  LEFT JOIN work.cte_enddates e
  on c.PERSON_ID = e.PERSON_ID
  and c.CONDITION_CONCEPT_ID = e.CONDITION_CONCEPT_ID
  and e.END_DATE >= c.CONDITION_START_DATE
  GROUP BY
	  c.PERSON_ID,
	  c.CONDITION_CONCEPT_ID,
	  c.CONDITION_TYPE_CONCEPT_ID,
    c.CONDITION_START_DATE
  order by c.person_id, c.condition_concept_id
    ;
quit;


* build condition_era table;
proc sql;
  create table omop.condition_era as
  select monotonic() as condition_era_id,
    person_id, CONDITION_CONCEPT_ID, CONDITION_START_DATE as CONDITION_ERA_START_DATE,
    CONDITION_END_DATE as CONDITION_ERA_END_DATE, CONDITION_OCCURRENCE_COUNT
  from work.cte_condition_end 
    ;
quit;


*************************************************************;


* temp table for targeting omop dose_era;
proc sql;
  create table dte_drug_target as
  select
    d.drug_exposure_id
		, d.person_id
    , c.concept_id AS ingredient_concept_id
    , c.concept_class_id
    , c.vocabulary_id
		, ds.amount_unit_concept_id AS unit_concept_id 
		, ds.amount_value AS dose_value 
		, d.drug_exposure_start_date
		, d.days_supply AS days_supply
		, d.drug_exposure_end_date
    FROM omop.drug_exposure d
	  LEFT JOIN vocab.drug_strength ds
	    ON d.drug_concept_id = ds.drug_concept_id	
	  LEFT JOIN vocab.concept c 
    ON d.drug_concept_id = c.concept_id
; quit;
   
/*
    LEFT JOIN vocab.concept_ancestor ca 
	    ON ca.descendant_concept_id = d.drug_concept_id
	WHERE c.concept_class_id = 'Ingredient'
	AND c.vocabulary_id = 'RxNorm'
;
quit;
*/


* start a complex combination of date mergers for creating dose era table;
proc sql;
  create table dte_dstnctdose_b as
		select distinct person_id, 
			ingredient_concept_id, 
			unit_concept_id, 
			dose_value 
		from work.dte_drug_target
    order by person_id, ingredient_concept_id, unit_concept_id, dose_value
;
quit;

* assign a unique row number to each dose era record;
proc sql;
  create table dte_dstnctdose_a as
    select monotonic() as row_num, *
    from work.dte_dstnctdose_b
    ;
quit;


* pad the end dates by 30 to allow a grace period for overlapping ranges;
proc sql;
  create table dte_dose_data as
  Select da.person_id, dt.ingredient_concept_id, dt.unit_concept_id, dt.dose_value, dt.drug_exposure_start_date AS EVENT_DATE,
      -1 as EVENT_TYPE, da.row_num as start_ordinal
  from work.dte_drug_target dt
  left join work.dte_dstnctdose_a da
  on dt.person_id = da.person_id
    and dt.ingredient_concept_id = da.ingredient_concept_id
    and dt.unit_concept_id = da.unit_concept_id
    and dt.dose_value = da.dose_value
	UNION ALL
  select dt.PERSON_ID, dt.ingredient_concept_id, dt.unit_concept_id, dt.dose_value, intnx('day', 30, dt.drug_exposure_end_date) as event_date,
    1 as EVENT_TYPE, . as start_ordinal
  FROM work.dte_drug_target dt
; 
quit;



* distinct dose data with max start ordinal; 
* select the start dates, assigning a row number to each;
* this re-numbers the inner UNION so all rows are numbered ordered by the event date; 
proc sql;
  create table dte_dose_ord as
    select monotonic() as overall_ord, person_id, ingredient_concept_id, unit_concept_id, dose_value, event_date, event_type, start_ordinal
    from work.dte_dose_data
    order by event_date, event_type
    ;
quit;


* pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with;
proc sql;
  create table dte_enddates as
  select PERSON_ID, ingredient_concept_id, unit_concept_id, dose_value, intnx('day', -30, EVENT_DATE) as END_DATE, event_date, event_type 
	FROM work.dte_dose_ord 
	WHERE (2 * START_ORDINAL) - OVERALL_ORD = 0
;
quit;

* temp table dte_dose_era_ends brings temp tables together;
proc sql;
  create table dte_dose_era_end as
  SELECT
  	dt.person_id
  	, dt.ingredient_concept_id as drug_concept_id
  	, dt.unit_concept_id
  	, dt.dose_value
  	, MIN(dt.drug_exposure_start_date) as dose_era_start_date
    , MIN(e.end_date) AS dose_era_end_date
   FROM work.dte_drug_target dt
  JOIN work.dte_enddates e
    ON dt.person_id = e.person_id
    AND dt.ingredient_concept_id = e.ingredient_concept_id
    AND dt.unit_concept_id = e.unit_concept_id
    AND dt.dose_value = e.dose_value
    AND e.end_date >= dt.drug_exposure_start_date
  GROUP BY
  	dt.drug_exposure_id
  	, dt.person_id
  	, dt.ingredient_concept_id
  	, dt.unit_concept_id
  	, dt.dose_value
    , dt.drug_exposure_start_date
  ORDER BY
    dt.person_id
    , dt.ingredient_concept_id
    , dt.unit_concept_id
    , dt.dose_value  
  ;
quit;


* build dose_era table;
proc sql;
  create table dose_era as
    SELECT monotonic() as dose_era_id
    , person_id
    , drug_concept_id
    , unit_concept_id
    , dose_value
    , dose_era_start_date
    , dose_era_end_date
    FROM work.dte_dose_era_end
  ;
quit;


*************************************************************;


* create temp file to target drug exposure era table;
proc sql;
  create table dxe_rx_target as
    select d.DRUG_EXPOSURE_ID
    , d.PERSON_ID
    , c.CONCEPT_ID as ingredient_concept_id
    , d.DRUG_TYPE_CONCEPT_ID
    , d.DRUG_EXPOSURE_START_DATE
    , d.DRUG_EXPOSURE_END_DATE
	FROM omop.DRUG_EXPOSURE d
	  LEFT JOIN vocab.concept c 
    ON d.drug_concept_id = c.concept_id
;
quit;

/*
		join .CONCEPT_ANCESTOR ca on ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
		join omop.CONCEPT c on ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
		where c.VOCABULARY_ID = 'RxNorm'
		and c.CONCEPT_CLASS_ID = 'Ingredient'
    */


* start a complex combination of date mergers for creating dose era table;
proc sql;
  create table dxe_dstnctrx_b as
		select distinct person_id, 
			ingredient_concept_id
		from work.dxe_rx_target
    order by person_id, ingredient_concept_id
;
quit;

* assign a unique row number to each dose era record;
proc sql;
  create table dxe_dstnctrx_a as
    select monotonic() as row_num, *
    from work.dxe_dstnctrx_b
    ;
quit;

* pad the end dates by 30 to allow a grace period for overlapping ranges;
proc sql;
  create table dxe_rx_data as
  Select da.person_id, dt.ingredient_concept_id, dt.drug_exposure_start_date AS EVENT_DATE,
      -1 as EVENT_TYPE, da.row_num as start_ordinal
  from work.dxe_rx_target dt
  left join work.dxe_dstnctrx_a da
  on dt.person_id = da.person_id
    and dt.ingredient_concept_id = da.ingredient_concept_id
	UNION ALL
  select dt.PERSON_ID, dt.ingredient_concept_id, intnx('day', 30, dt.drug_exposure_end_date) as event_date,
    1 as EVENT_TYPE, . as start_ordinal
  FROM work.dxe_rx_target dt
; 
quit;


* distinct dose data with max start ordinal; 
* select the start dates, assigning a row number to each;
* this re-numbers the inner UNION so all rows are numbered ordered by the event date; 
proc sql;
  create table dxe_rx_ord as
    select monotonic() as overall_ord, person_id, ingredient_concept_id, event_date, event_type, start_ordinal
    from work.dxe_rx_data
    order by event_date, event_type
    ;
quit;


* pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with;
proc sql;
  create table dxe_enddates as
  select PERSON_ID, ingredient_concept_id, intnx('day', -30, EVENT_DATE) as END_DATE, event_date, event_type 
	FROM work.dxe_rx_ord 
	WHERE (2 * START_ORDINAL) - OVERALL_ORD = 0
;
quit;


* temp table dxe_drug_era_ends brings temp tables together;
proc sql;
  create table dxe_drug_era_end as
  SELECT
  	dt.person_id
    , dt.ingredient_concept_id as drug_concept_id
    , dt.drug_type_concept_id
  	, MIN(dt.drug_exposure_start_date) as drug_era_start_date
    , MIN(e.end_date) AS drug_era_end_date
    , count(*) as drug_exposure_count
   FROM work.dxe_rx_target dt
  JOIN work.dxe_enddates e
    ON dt.person_id = e.person_id
    AND dt.ingredient_concept_id = e.ingredient_concept_id
    AND e.end_date >= dt.drug_exposure_start_date
  GROUP BY
  	dt.drug_exposure_id
  	, dt.person_id
  	, dt.ingredient_concept_id
  	, dt.drug_type_concept_id
     , dt.drug_exposure_start_date
  ORDER BY
    dt.person_id
    , dt.ingredient_concept_id
    ;
quit;

* build drug_era table;
proc sql;
  create table omop.drug_era as
    SELECT monotonic() as drug_era_id
    , person_id
    , drug_concept_id
     , drug_era_start_date
    , drug_era_end_date
    , drug_exposure_count
    , . as gap_days
    FROM work.dxe_drug_era_end
  ;
quit;






