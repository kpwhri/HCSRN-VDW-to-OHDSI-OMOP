/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Builds SAS data files that represent an OMOP-CDM based on a cohort of patients
* Date Created:: 2019-05-23
*********************************************/

/* remove in production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";


/* leave in */
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_JIFFI.sas";
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_RCMExt.sas";

options
  linesize  = 150
  msglevel  = i
  formchar  = '|-++++++++++=|-/|<>*'
  dsoptions = note2err 
  nocenter
  noovp
  nosqlremerge
  extendobscounter = no
  
;


/* %let root=&GHRIDW_ROOT.\management\Workspace\CESR_Dev\<subjectdir>\etl; */

%let root=//HOME/weekjm1/td_rcm_omop/vdw2omop;

libname omop "&root./omop_files";

/* I will populate facility location information since that is the only
*  one that exists in VDW.
*/

proc sql;
  create table omop.location as
select monotonic() as location_id, 
	left(fa.street_address) as address_1, 
	'' as address_2,
	fa.city,
	fa.state,
	fa.zip,
	'' as county,
	fa.facility_code as location_source_value
    from
 &_vdw_facility as fa
order by fa.facility_code
;
quit;


 /* populate omop.care_site */

proc sql;
  create table omop.location_pos_bridge as
    select distinct
      ue.facility_code as care_site_source_value,
      ue.enctype||'-'||ue.encounter_subtype as enctype_subtype
    from &_vdw_utilization ue
  ;
quit;

proc sql;
create table unq_care_site as
  select distinct 
    loc.location_id,
    fa.ghc_facility_name as care_site_name,
    ps.omop_concept_id as place_of_service_concept_id,
		ue.care_site_source_value,
    ps.vdw_code as place_of_service_source_value
  from omop.location_pos_bridge ue
  inner join &_vdw_facility fa
	on fa.facility_code = ue.care_site_source_value
	and fa.facility_code <> '~~~~~~'
	inner join &_rcm_pos ps 
	on ue.enctype_subtype = ps.vdw_code 
	inner join omop.location loc
	on loc.location_source_value = ue.care_site_source_value
  ;
quit;



proc sql;
  create table omop.care_site as
select 
  monotonic() as care_site_id,
  cs.*
    from work.unq_care_site as cs
    ;
quit;


   /* populate omop.provider */

proc sql; 
  create table unq_provider as
  select distinct
	  '' as provider_name,
	  pe.ghc_npi,
	  '' as DEA,
	  sp.omop_concept_id as specialty_concept_id,
	  '' as care_site_id,
	  pe.provider_birth_year as year_of_birth,
	  gn.omop_concept_id as gender_concept_id,
	  pe.provider as provider_source_value,
	  sp.vdw_code as specialty_source_value,
	  0 as specialty_source_concept_id,
	  gn.vdw_code as gender_source_value,
	  0 as gender_source_concept_id
  from 
	  &_vdw_provider_specialty pe
	left join &_rcm_physician_specialty sp
	  on pe.specialty = sp.vdw_code
	  /* and sp.vdw_specialty_ord = 1 */
	  and sp.vdw_code <> 'NO_MAP'
	left join &_rcm_gender gn
	  on pe.provider_gender = gn.vdw_code
    where pe.provider <> '~~~~~~'
  /* order by pe.provider */
;
quit;

proc sql;
  create table omop.provider as
    select monotonic() as provider_id, unp.* from work.unq_provider unp;
quit;

   
/*
distinct pvcnt.pvid+ROW_NUMBER() over (order by pe.provider) as provider_id,
(select coalesce(MAX(provider_id), 0) as pvid from omop.provider) as pvcnt,

--	select top 10000 * from dbo.vdw_provider_em
--	select count(*), provider_source_value from omop.provider group by provider_source_value
--	select count(*), provider from dbo.vdw_provider_em group by provider;
--	select * from omop.vdw_lkup_specialty
  */

/* populate omop.person */
proc sql outobs=100;
create table omop.person as
  select 
    monotonic() as person_id,
	  lug.omop_concept_id as gender_concept_id, 
	  year(dem.birth_date) as year_of_birth, 
	  month(dem.birth_date) as month_of_birth, 
	  day(dem.birth_date) as day_of_birth, 
	  dem.birth_date as birth_datetime,
	  coalesce(lur.omop_concept_id, 8552) as race_concept_id,
	  case dem.hispanic
		  when 'Y' then let.omop_concept_id
		  when 'N' then let.omop_concept_id
		  when 'U' then 0
	  end as ethnicity_concept_id,
	  0 as location_id,
	  0 as provider_id,
	  0 as care_site_id,
	  dem.mrn as person_source_value,
	  dem.Gender as gender_source_value,
	  0 as gender_source_concept_id,
	  dem.race1 as race_source_value,
	  0 as race_source_concept_id,
	  dem.hispanic as ethnicity_source_value,
	  0 as ethnicity_source_concept_id
from 
		&_vdw_demographic dem
	left join &_rcm_gender lug
	on lug.vdw_code = dem.Gender
	left join &_rcm_race lur
	on lur.vdw_code = dem.race1
	left join &_rcm_ethnicity let
	on let.vdw_code = dem.hispanic
;
quit;

/* (select coalesce(MAX(person_id), 0) as pid from omop.person) as pcnt, */


/*
-- populate omop.visit_occurance
truncate table omop.visit_occurrence;
insert into omop.visit_occurrence
  */
proc sql;
create table omop.visit_occurrence as
  select
  monotonic() as visit_occurrence_id,
	pn.person_id,
	vi.omop_concept_id as visit_concept_id,
	ute.adate as visit_start_date,
  ute.atime as visit_start_datetime,
	ute.ddate as visit_end_date,
	ute.dtime as visit_end_datetime,
	vt.omop_concept_id as visit_type_concept_id,
	pr.provider_id,
	cs.care_site_id,
	ute.enc_id as visit_source_value,
	0 as visit_source_concept_id,
	las.omop_concept_id as admitting_source_concept_id,
	las.vdw_code as admitting_source_value,
	lds.omop_concept_id as discharge_to_concept_id,
	lds.vdw_code as discharge_to_source_value,
	0 as preceding_visit_occurrence_id
from  
	&_vdw_utilization ute
	inner join omop.person pn
	on ute.mrn = pn.person_source_value
	inner join omop.provider pr
	on ute.provider = pr.provider_source_value
	inner join omop.care_site cs
	on ute.facility_code = cs.care_site_source_value
	and ute.enctype||'-'||ute.encounter_subtype = cs.place_of_service_source_value
	inner join &_rcm_enctype vi
	on ute.enctype = vi.vdw_code
	inner join &_rcm_enc_source vt
	on (ute.kpwa_source = vt.vdw_code
	or ute.source_data = vt.vdw_code)
	left join &_rcm_admitting_source las
	on las.vdw_code = ute.admitting_source
	left join &_rcm_discharge_status lds
	on lds.vdw_code = ute.discharge_status
;
quit;




/* -- populate omop.condition_occurrence */
proc sql;
create table omop.condition_occurrence as
select 
	monotonic() as condition_occurrence_id,
	pn.person_id,
	coalesce(ldx.omop_concept_id, 0) as condition_concept_id,
	put(dx.adate, date.)  as condition_start_date,
	put(dx.adate, datetime.) as condition_start_datetime,
	put(dx.kpwa_diagdate, date.) as condition_end_date,
	put(dx.kpwa_diagdate, datetime.) as condition_end_datetime,
	case when dx.primary_dx = 'P'
		then 44786627
		when dx.primary_dx = 'S'
		then 44786628
		else 0
	end as condition_type_concept_id,
	'' as stop_reason,
	pr.provider_id,
	vo.visit_occurrence_id,
	dx.dx as condition_source_value,
	ldx.vdw_concept_id as condition_source_concept_id,
	'' as condition_status_source_value,
	4033240 as condition_status_concept_id
from 
	&_vdw_dx dx
	inner join omop.person pn
	on pn.person_source_value = dx.mrn
	inner join omop.visit_occurrence vo
	on dx.enc_id = vo.visit_source_value
	left join omop.provider pr
	on dx.diagprovider = pr.provider_source_value
  left join &_rcm_diagnosis ldx
	on dx.dx = ldx.vdw_code
  ;
quit;


/* -- select top 100 * from dbo.vdw_dx_em; */
/* -- select top 100 * from omop.concept where concept_class_id like 'condition%'; */



/* -- populate omop.procedure_occurrence */
proc sql;
  create table omop.procedure_occurrence as
  SELECT   
    monotonic() as procedure_occurrence_id
    , procs.*
  FROM (
    SELECT DISTINCT       
       pn.person_id
      ,pxt.omop_concept_id as procedure_concept_id
      ,px.procdate as procedure_date
      ,px.procdate as procedure_datetime format=datetime.
      ,38000266 as procedure_type_concept_id
      ,pxm.omop_concept_id as modifier_concept_id
      ,0 as quantity
      ,pr.provider_id
      ,vo.visit_occurrence_id
      ,px.px as procedure_source_value
      ,0 as procedure_source_concept_id
      ,'' as qualifier_source_value
    FROM 
	  &_vdw_px px
	  inner join omop.person pn
	   on pn.person_source_value = px.mrn
	  inner join omop.visit_occurrence vo
	   on px.enc_id = vo.visit_source_value
	  left join omop.provider pr
	   on px.performingprovider = pr.provider_source_value
	  inner join &_rcm_procedure pxt
	   on pxt.vdw_code = px.px
	  left join &_rcm_procedure pxm
     on pxm.vdw_code = px.cptmod1
  ) procs
;
quit;


/* -- populate omop.death */
proc sql;
create table omop.death as
  select distinct
    monotonic() as death_id,
    pe.person_id, 
	  dt.deathdt as death_date,
	  put(dt.deathdt, datetime.) as death_datetime,
	  dtht.omop_concept_id as death_type_concept_id,
	  cod.omop_concept_id as cause_concept_id,
	  cod.vdw_code as cause_source_value,
	  0 as cause_source_concept_id
  from omop.person pe
  inner join &_vdw_death dt
	 on pe.person_source_value = dt.mrn
  left join &_vdw_cause_of_death cc
	 on cc.mrn = dt.mrn
  left join &_rcm_cod cod
	 on cc.cod = cod.vdw_code
  left join &_rcm_deathtype dtht
	 on dt.source_list = dtht.vdw_code
;
quit;





/* -- populate omop.drug_exposure */
proc sql;
create table omop.drug_exposure as
select
	monotonic() as drug_exposure_id
	,pn.person_id
	,coalesce (ndc.omop_concept_id, 0) as drug_concept_id
	,rx.rxdate as drug_exposure_start_date
	,put(rx.rxdate, datetime.) as drug_exposure_start_datetime
	,rx.rxdate as drug_exposure_end_date
	,put(rx.rxdate, datetime.) as drug_exposure_end_datetime
	,'' as verbatim_end_date
	,0 as drug_type_concept_id
	,'' as stop_reason
	,case rx.rxfill
		when 'I' then 0
		when 'R' then 1
		else 0
	 end as refills
	,rx.rxamt as quantity
	,rx.rxsup as days_supply
	,'' as sig
	,0 as route_concept_id
	,0 as lot_number
	,pr.provider_id
	,0 as visit_occurrence_id
	,rx.ndc as drug_source_value
	,0 as drug_source_concept_id
	,rx.source as route_source_value
	,'' as dose_unit_source_value
from 
	&_vdw_rx rx
	inner join omop.person pn
	on pn.person_source_value = rx.mrn
	left join omop.provider pr
	on pr.provider_source_value = rx.rxmd
	left join &_rcm_rx ndc
	on rx.ndc = ndc.vdw_code
  ;
quit;





/* -- populate omop.drug_strength */
/* -- Rx fill information */


/* -- populate omop.dose_era */
/* -- period of time that a specific dose was being give for a specific drug at a specific dosage */


/***** Not Ready ****************
-- populate omop.specimen
INSERT INTO omop.specimen
SELECT
  0 as [specimen_id]
  ,pn.[person_id]
  ,0 as [specimen_concept_id]
  ,0 as [specimen_type_concept_id]
  ,cast(tm.BDate as date) as [specimen_date]
  ,cast(tm.BDate as datetime) as [specimen_datetime]
  ,tm. as [quantity]
  ,0 as [unit_concept_id]
  ,0 as [anatomic_site_concept_id]
  ,0 as [disease_status_concept_id]
  , as [specimen_source_id]
  , as [specimen_source_value]
  , as [unit_source_value]
  , as [anatomic_site_source_value]
  , as [disease_status_source_value]
FROM dbo.vdw_tumor_em tm
  INNER JOIN omop.person pn
  on tm.mrn = pn.person_source_value
;
GO


-- populate omop.fact_relationship


-- populate omop.payer_plan_period
INSERT INTO omop.payer_plan_period
SELECT
  0 as [payer_plan_period_id]
  ,pn.[person_id]
  ,en.enr_start as [payer_plan_period_start_date]
  ,en.enr_end as [payer_plan_period_end_date]
  ,en.mainnet as [payer_source_value]
  ,null as [plan_source_value]
  ,null as [family_source_value]
FROM dbo.vdw_enrollment_em en
  INNER JOIN omop.person pn
  on pn.person_source_value = en.mrn

*******************/




 /* populate omop.observation **Would Need Social_History */
/*	The OBSERVATION table captures clinical facts about a Person 
	obtained in the context of examination, questioning or a procedure.
	Any data that cannot be represented by any other domains, such as social and lifestyle facts, 
	medical history, family history, etc. are recorded here.
*/


 /* populate omop.observation_period */
/*
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
*/

 /* populate omop.measurement  ** Would still need to add Vital Signs */
/* The MEASUREMENT table contains records of Measurement, i.e. structured values (numerical 
	or categorical) obtained through systematic and standardized examination or testing of 
	a Person or Person's sample. The MEASUREMENT table contains both orders and results of 
	such Measurements as laboratory tests, vital signs, quantitative findings from pathology 
	reports, etc.
  */
 /*
	if OBJECT_ID('tempdb..#tmp_measurement_labs') is not null drop table #tmp_measurement_labs;
	GO
	select DISTINCT
	pn.[person_id]
	,ml.concept_id as [measurement_concept_id]
	,CASE isdate(lr.lab_dt) WHEN 1 then 
		case when lr.lab_dt like '%/%'
			then convert(varchar, convert(date, lr.lab_dt, 101), 120)
			else lr.lab_dt
		end
		else 'nd_'+lr.lab_dt
	 end as [measurement_date]
	 ,case when lr.lab_tm like '[0-9][0-9][:][0-9][0-9][:][0-9][0-9][.][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' then 1
		when lr.lab_tm like '[0-9][0-9][:][0-9][0-9][:][0-9][0-9]' then 1
		else 0
	  end as [time_flag]
	,lr.lab_dt +' '+ replace(lr.lab_tm, 'NULL', '') as [measurement_datetime]
	,44818702 as [measurement_type_concept_id]
	,0 as [operator_concept_id]
	,case WHEN isnumeric(replace(lr.result_c, ' ', '')+'e0') = 1 
		THEN cast(replace (lr.result_c, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,0 as [unit_concept_id]
	,case WHEN isnumeric(replace(lr.normal_low_c, ' ', '')+'e0') = 1
		THEN cast(replace (lr.normal_low_c, ' ', '') as float)
		ELSE NULL
	 END as [range_low]
	,case WHEN isnumeric(replace(lr.normal_high_c, ' ', '')+'e0') = 1
		THEN cast(replace (lr.normal_high_c, ' ', '') as float)
		ELSE NULL
	END as [range_high]
	,pv.[provider_id]
	,vo.[visit_occurrence_id]
	,lr.loinc as [measurement_source_value]
	,ml.concept_id as [measurement_source_concept_id]
	,lr.result_unit as [unit_source_value]
	,lr.result_c as [value_source_value]
into #tmp_measurement_labs
from dbo.vdw_labresults_fin lr
	inner join omop.person pn
	on lr.mrn = pn.person_source_value
	inner join omop.provider pv
	on lr.order_prov = pv.provider_source_value
	left join omop.vdw_lkup_measurement_loinc ml
	on lr.loinc = ml.vdw_loinc
	left join omop.visit_occurrence vo
	on (vo.person_id = pn.person_id
	and cast(lr.lab_dt as varchar(25)) = cast(vo.visit_start_date as varchar(25))
	and vo.provider_id = pv.provider_id)
where lr.lab_dt is not null 
--	and lr.lab_tm is not null
	and ltrim(rtrim(lr.lab_dt)) <> 'NULL'
	;
	GO

    /*
--select * from omop.concept where concept_code = '5811-5'
--	select top 500 * from omop.vdw_lkup_measurement_loinc where concept_name like '%urine%spec%grav%'
--	select top 5000 * from #tmp_measurement_labs where time_flag = 0 --where [measurement_date] like 'nd_%'
*/
/*
	if OBJECT_ID('tempdb..#tmp_meas_vitals_ht_est') is not null drop table #tmp_meas_vitals_ht_est;
	GO
	select DISTINCT
	pn.[person_id]
	,3035463 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.ht_estimate, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.ht_estimate, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,9330 as [unit_concept_id] -- domain=Unit vocab=UCUM
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'8301-4' as [measurement_source_value]
	,3023540 as [measurement_source_concept_id]
	,'[in_us]' as [unit_source_value]
	,vs.ht_estimate as [value_source_value]
into #tmp_meas_vitals_ht_est
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.ht_estimate <> '?'
;



	if OBJECT_ID('tempdb..#tmp_meas_vitals_ht') is not null drop table #tmp_meas_vitals_ht;
	GO
	select DISTINCT
	pn.[person_id]
	,3023540 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.ht, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.ht, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,9330 as [unit_concept_id] -- domain=Unit vocab=UCUM
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'3137-7' as [measurement_source_value]
	,3023540 as [measurement_source_concept_id]
	,'[in_us]' as [unit_source_value]
	,vs.ht as [value_source_value]
into #tmp_meas_vitals_ht
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.ht <> '?'
;



	if OBJECT_ID('tempdb..#tmp_meas_vitals_wt') is not null drop table #tmp_meas_vitals_wt;
	GO
	select DISTINCT
	pn.[person_id]
	,3025315 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.wt, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.wt, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8739 as [unit_concept_id] -- domain=Unit vocab=UCUM
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'29463-7' as [measurement_source_value]
	,3023540 as [measurement_source_concept_id]
	,'[lb_us]' as [unit_source_value]
	,vs.wt as [value_source_value]
into #tmp_meas_vitals_wt
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.wt <> '?'
;


	if OBJECT_ID('tempdb..#tmp_meas_vitals_wt_est') is not null drop table #tmp_meas_vitals_wt_est;
	GO
	select DISTINCT
	pn.[person_id]
	,3026600 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.wt_estimate, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.wt_estimate, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8739 as [unit_concept_id] -- domain=Unit vocab=UCUM
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'8335-2' as [measurement_source_value]
	,3023540 as [measurement_source_concept_id]
	,'[lb_us]' as [unit_source_value]
	,vs.wt_estimate as [value_source_value]
into #tmp_meas_vitals_wt_est
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.wt_estimate <> '?'
;



	if OBJECT_ID('tempdb..#tmp_meas_vitals_bmi') is not null drop table #tmp_meas_vitals_bmi;
	GO
	select DISTINCT
	pn.[person_id]
	,3038553 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.bmi, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.bmi, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8554 as [unit_concept_id] -- domain=Unit vocab=UCUM
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'39156-5' as [measurement_source_value]
	,3038553 as [measurement_source_concept_id]
	,'%' as [unit_source_value]
	,vs.bmi as [value_source_value]
into #tmp_meas_vitals_bmi
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.bmi <> '?'
;



	if OBJECT_ID('tempdb..#tmp_meas_vitals_bpd') is not null drop table #tmp_meas_vitals_bpd;
	GO
	select DISTINCT
	pn.[person_id]
	,3012888 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.diastolic, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.diastolic, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8876 as [unit_concept_id] -- domain=Unit vocab=UCUM mmHg
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'8462-4' as [measurement_source_value]
	,3012888 as [measurement_source_concept_id]
	,'mm[Hg]' as [unit_source_value]
	,vs.diastolic as [value_source_value]
into #tmp_meas_vitals_bpd
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.diastolic <> '?'
;

	if OBJECT_ID('tempdb..#tmp_meas_vitals_bps') is not null drop table #tmp_meas_vitals_bps;
	GO
	select DISTINCT
	pn.[person_id]
	,3004249 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.systolic, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.systolic, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8876 as [unit_concept_id] -- domain=Unit vocab=UCUM mmHG
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'8480-6' as [measurement_source_value]
	,3004249 as [measurement_source_concept_id]
	,'mm[Hg]' as [unit_source_value]
	,vs.systolic as [value_source_value]
into #tmp_meas_vitals_bps
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.systolic <> '?'
;



	if OBJECT_ID('tempdb..#tmp_meas_vitals_pulse') is not null drop table #tmp_meas_vitals_pulse;
	GO
	select DISTINCT
	pn.[person_id]
	,3027018 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.pulse_raw, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.pulse_raw, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8541 as [unit_concept_id] -- domain=Unit vocab=UCUM mmHG /min
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'8867-4' as [measurement_source_value]
	,3027018 as [measurement_source_concept_id]
	,'{beats}/min' as [unit_source_value]
	,vs.pulse_raw as [value_source_value]
into #tmp_meas_vitals_pulse
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.pulse_raw <> '?'
;
*/
/*
select * from omop.concept where domain_id like '%oper%'
select * from omop.concept where concept_class_id like '%meas%type%'
select * from omop.concept where domain_id like '%unit%' and vocabulary_id = 'UCUM' and concept_name like '%true%'
select top 100 * from dbo.vdw_vitalsigns_em
select * from omop.concept where domain_id like '%meas%' and concept_name like '%pregnancy'
select * from omop.concept where concept_id in ('147652','147650','147660','109021','147658','121599','147663','147655');



	if OBJECT_ID('tempdb..#tmp_meas_vitals_preg') is not null drop table #tmp_meas_vitals_preg;
	GO
	select DISTINCT
	pn.[person_id]
	,45885207 as [measurement_concept_id]
	,vs.measure_date as [measurement_date]
	,vs.measure_date+' '+replace(replace(vs.measure_time, '?', ''), '1/1/1960', '') as [measurement_datetime]
	,44818701 as [measurement_type_concept_id] --from Physical Exam
	,4172703 as [operator_concept_id] -- =
	,case WHEN isnumeric(replace(vs.kpwa_known_pregnancy, ' ', '')+'e0') = 1 
		THEN cast(replace (vs.kpwa_known_pregnancy, ' ', '') as float)
		ELSE NULL
	end as [value_as_number]
	,0 as [value_as_concept_id]
	,8541 as [unit_concept_id] -- domain=Unit vocab=UCUM mmHG /min
	,0 as [range_low]
	,0 as [range_high]
	,vo.[provider_id]
	,vo.[visit_occurrence_id]
	,'LA6530-5' as [measurement_source_value]
	,45885207 as [measurement_source_concept_id]
	,'' as [unit_source_value]
	,vs.kpwa_known_pregnancy as [value_source_value]
-- into #tmp_meas_vitals_preg
FROM dbo.vdw_vitalsigns_em vs 
	INNER JOIN omop.person pn
	ON vs.mrn = pn.person_source_value
	LEFT JOIN omop.visit_occurrence vo
	ON vs.enc_id = vo.visit_source_value
WHERE vs.kpwa_known_pregnancy = '1'
;

*/
/*
TRUNCATE TABLE omop.measurement;
INSERT INTO omop.measurement
select 
  mscnt.mid+row_number() over (order by current_timestamp) as measurement_id
  , msr.[person_id]
  , msr.[measurement_concept_id]
  , msr.[measurement_date]
  , msr.[measurement_datetime]
  , msr.[measurement_type_concept_id]
  , msr.[operator_concept_id]
  , msr.[value_as_number]
  , msr.[value_as_concept_id]
  , msr.[unit_concept_id]
  , msr.[range_low]
  , msr.[range_high]
  , msr.[provider_id]
  , msr.[visit_occurrence_id]
  , msr.[measurement_source_value]
  , msr.[measurement_source_concept_id]
  , msr.[unit_source_value]
  , msr.[value_source_value]
from
(
select 
  [person_id]
  , coalesce ([measurement_concept_id], 0) as measurement_concept_id
  , cast([measurement_date] as date) as [measurement_date]
  , CAST([measurement_datetime] as datetime2(7)) as [measurement_datetime]
  , [measurement_type_concept_id]
  , [operator_concept_id]
  , [value_as_number]
  , [value_as_concept_id]
  , [unit_concept_id]
  , [range_low]
  , [range_high]
  , [provider_id]
  , [visit_occurrence_id]
  , [measurement_source_value]
  , [measurement_source_concept_id]
  , [unit_source_value]
  , SUBSTRING([value_source_value],1 ,50) as value_source_value
from #tmp_measurement_labs 
where measurement_source_value is not null 
and measurement_date like '[12][0-9][0-9][0-9][-][0-9][0-9][-][0-9][0-9]'
UNION 
SELECT * FROM #tmp_meas_vitals_ht_est
UNION
SELECT * FROM #tmp_meas_vitals_ht
UNION
SELECT * FROM #tmp_meas_vitals_wt_est
UNION
SELECT * FROM #tmp_meas_vitals_wt
UNION
SELECT * FROM #tmp_meas_vitals_bmi
UNION
SELECT * FROM #tmp_meas_vitals_bpd
UNION
SELECT * FROM #tmp_meas_vitals_bps
UNION
SELECT * FROM #tmp_meas_vitals_pulse
) msr,
 (select coalesce(MAX(measurement_id), 0) as mid from omop.measurement) as mscnt
; 


--select top 1000 * from omop.measurement

--select * from omop.test_measurement where dateflag = '0'
  */
/*
--select distinct measurement_source_concept_id from omop.measurement

select count(*), measurement_datetime
from omop.measurement
group by measurement_datetime
*/




























/*
if OBJECT_ID('omop.vdw_lkup_race') is not null drop view omop.vdw_lkup_race;
GO
create view omop.vdw_lkup_race as
(  select distinct cp.*,
	case when cp.concept_name = 'Asian' then 'AS'
		when cp.concept_name = 'Unknown' then 'MU'
		when cp.concept_name = 'Black or African American' then 'BA'
		when cp.concept_name = 'White' then 'WH'
		when cp.concept_name = 'American Indian or Alaska Native' then 'IN'
		when cp.concept_name = 'Native Hawaiian or Other Pacific Islander' then 'HP'
		when cp.concept_name = 'Unknown' then 'UN'
		when cp.concept_name = 'Other Race' then 'OT'
	end as vdw_race,
	case when cp.concept_name = 'Non-white' then 'Y'
	end as vdw_hispanic 
  from omop.concept cp
  where cp.vocabulary_id like '%race%'
);
GO
-- select * from omop.vdw_lkup_race;



if OBJECT_ID('omop.vdw_lkup_gender') is not null drop view omop.vdw_lkup_gender;
GO
create view omop.vdw_lkup_gender as
(  select distinct cp.*, dem.gender as vdw_gender
  from omop.concept cp
  full outer join dbo.vdw_demographics_em dem
  on cp.concept_code = upper(dem.gender)
  where cp.vocabulary_id like '%gender%'
);
GO
-- select * from omop.vdw_lkup_gender;



if OBJECT_ID('omop.vdw_lkup_px') is not null drop view omop.vdw_lkup_px;
GO
create view omop.vdw_lkup_px as
(  select distinct cp.*, px.px as vdw_px
  from omop.concept cp
  inner join dbo.vdw_procedures_em px
  on cp.concept_code = px.px
  where cp.domain_id = 'Procedure'
);
GO
-- select * from omop.vdw_lkup_px;



if OBJECT_ID('omop.vdw_lkup_dx') is not null drop view omop.vdw_lkup_dx;
GO
create view omop.vdw_lkup_dx as
(  select distinct cp.*, dx.dx as vdw_dx
  from omop.concept cp
  inner join dbo.vdw_dx_em dx
  on cp.concept_code = dx.dx
  where cp.domain_id = 'Condition' or cp.domain_id = 'Observation'
);
GO
-- select * from omop.vdw_lkup_dx;



if OBJECT_ID('omop.vdw_lkup_labresults_loinc') is not null drop view omop.vdw_lkup_labresults_loinc;
GO
create view omop.vdw_lkup_labresults_loinc as
(  select distinct cp.*, lr.loinc as vdw_loinc
  from omop.concept cp
  inner join dbo.vdw_labresults_em lr
  on cp.concept_code = lr.loinc
);
GO
-- select * from omop.vdw_lkup_labresults_loinc;




if OBJECT_ID('omop.vdw_lkup_rx_ndc') is not null drop view omop.vdw_lkup_rx_ndc;
GO
create view omop.vdw_lkup_rx_ndc as
(  select distinct cp.*, rx.ndc as vdw_ndc
  from omop.concept cp
  inner join dbo.vdw_pharmacy_em rx
  on cp.concept_code = rx.ndc
);
GO
-- select * from omop.vdw_lkup_rx_ndc;


-- Observation is like social history and Problem list and Personal Health Records

if OBJECT_ID('omop.vdw_lkup_visit_enctype') is not null drop view omop.vdw_lkup_visit_enctype;
GO
create view omop.vdw_lkup_visit_enctype as
(select distinct cp.*, ut.enctype
  from dbo.vdw_utilization_em ut 
  full outer join 
	(select *, 
		case when concept_code = 'IP' then 'IP' 
			when concept_code = 'OP' then 'AV'
			when concept_code = 'LTCP' then 'IS'
			when concept_code = 'ER' then 'ED'
			when concept_code = 'ERIP' then 'IP'
			when concept_code = 'ERIP' then 'ER'
		end as concept_codet from omop.concept
	) cp
  on cp.concept_codet = ut.enctype
  where cp.domain_id like '%visit%'
	or ut.enctype is not null
);
GO

select * from omop.relationship;




  -- **************************************
/*

select cp.*
  from omop.concept cp
  where cp.domain_id like '%source%'

select cp.*
  from omop.concept cp
  where cp.concept_code like 'm%'


    select distinct cp.concept_id, cp.concept_name
  from omop.concept cp
  where cp.vocabulary_id like '%race%' and standard_concept = 'S'


  SELECT 
	concnt.ccid+ROW_NUMBER() over (order by g.gender) as concept_id 
	, case when g.gender = 'F' then 'Female'
		when g.gender = 'M' then 'Male'
		when g.gender = 'U' then 'Unknown'
		else ''
	  end concept_name
	, g.gender as concept_code 
	, 
  FROM (SELECT distinct gender FROM dbo.vdw_demographics_em) g,
  (SELECT MAX(concept_id) as ccid from omop.concept) as concnt
  ;


  SELECT 
	concnt.ccid+ROW_NUMBER() over (order by g.race1) as concept_id 
	, case when g.race1 = 'AS' then 'Asian'
		when g.race1 = 'BA' then 'Black or African American'
		when g.race1 = 'HP' then 'Native Hawaiian / Pacific Islander'
		when g.race1 = 'IN' then 'American Indian / Alaskan Native'
		when g.race1 = 'WH' then 'White'
		when g.race1 = 'OT' then 'Other'
		when g.race1 = 'UN' then 'Unknown'
		else ''
	  end concept_name
	, g.race1 as concept_code 
  FROM (SELECT distinct race1 FROM dbo.vdw_demographics_em) g,
  (SELECT MAX(concept_id) as ccid from omop.concept) as concnt
  ;

  
	select race1 as vdw_concept_name from dbo.vdw_demographics_em
	union
	select race2 as vdw_concept_name from dbo.vdw_demographics_em
	union
	select race3 as vdw_concept_name from dbo.vdw_demographics_em
	union
	select race4 as vdw_concept_name from dbo.vdw_demographics_em
	union
	select race5 as vdw_concept_name from dbo.vdw_demographics_em
;
GO
*/
