-- populate omop.location
-- wants patient, facility and provider address information
/* I will populate facility location information since that is the only
*  one that exists in VDW.
*/
truncate table omop.location;
insert into omop.location 
select lcnt.lid+ROW_NUMBER() over (order by fa.facility_code) as location_id, 
	left(fa.street_address, 50) as address_1, 
	NULL as address_2,
	fa.city,
	fa.[state],
	fa.zip,
	NULL as county,
	fa.facility_code as location_source_value
from (select coalesce(MAX(location_id), 0) as lid from omop.location) as lcnt, 
	dbo.vdw_facilities_em as fa
;
GO
-- select * from omop.location



-- populate omop.care_site
truncate table omop.care_site;
insert into omop.care_site
select
	cscnt.csid+ROW_NUMBER() over (order by ds.location_id, current_timestamp) as care_site_id,
	ds.*
from
(
	select distinct
		fa.ghc_facility_name as care_site_name,
		ps.concept_id as place_of_service_concept_id,
		loc.location_id,
		fa.facility_code as care_site_source_value,
		ps.enctype+'|'+ps.encounter_subtype+'|'+ps.concept_code as place_of_service_source_value
	from dbo.vdw_facilities_em fa
	inner join dbo.vdw_utilization_em ue
	on fa.facility_code = ue.facility_code
	and fa.facility_code <> '~~~~~~'
	and fa.ghc_facility_name <> '?'
	inner join omop.vdw_lkup_pos ps
	on ue.enctype = ps.enctype
	and ue.encounter_subtype = ps.encounter_subtype
	inner join omop.location loc
	on loc.location_source_value = fa.facility_code
) ds,
(select coalesce(MAX(care_site_id), 0) as csid from omop.care_site) as cscnt
;
	

-- select * from omop.care_site

-- populate omop.provider
truncate table omop.provider;
GO
insert into omop.provider
select distinct pvcnt.pvid+ROW_NUMBER() over (order by pe.provider) as provider_id,
	NULL as provider_name,
	cast(REPLACE(pe.ghc_npi, '?', '') as varchar(20)) as NPI,
	cast(NULL as varchar(20)) as DEA,
	sp.concept_id as specialty_concept_id,
	cast(NULL as int) as care_site_id,
	cast(REPLACE(pe.provider_birth_year, '?', '') as int) as year_of_birth,
	gn.concept_id as gender_concept_id,
	pe.provider as provider_source_value,
	sp.vdw_specialty as specialty_source_value,
	0 as specialty_source_concept_id,
	gn.vdw_gender as gender_source_value,
	0 as gender_source_concept_id
from (select coalesce(MAX(provider_id), 0) as pvid from omop.provider) as pvcnt,
	dbo.vdw_provider_em pe
	left join omop.vdw_lkup_specialty sp
	on pe.specialty = sp.vdw_specialty
	and sp.vdw_specialty_ord = 1
	and sp.vdw_specialty <> 'NO_MAP'
	left join omop.vdw_lkup_gender gn
	on pe.provider_gender = gn.vdw_gender
where pe.provider <> '~~~~~~'
;
GO
--	select top 10000 * from dbo.vdw_provider_em
--	select count(*), provider_source_value from omop.provider group by provider_source_value
--	select count(*), provider from dbo.vdw_provider_em group by provider;
--	select * from omop.vdw_lkup_specialty

-- populate omop.person
truncate table omop.person;
insert into omop.person
select pcnt.pid+row_number() over (order by dem.mrn) as person_id, 
	lug.concept_id as gender_concept_id, 
	cast(datepart(yyyy, dem.birth_date) as int) as year_of_birth, 
	cast(datepart(m, dem.birth_date) as int) as month_of_birth, 
	cast(datepart(d, dem.birth_date) as int) as day_of_birth, 
	dem.birth_date as birth_datetime,
	coalesce(lur.concept_id, 8552) as race_concept_id,
	case dem.hispanic
		when 'Y' then let.concept_id
		when 'N' then let.concept_id
		when 'U' then 0
	end as ethnicity_concept_id,
	NULL as location_id,
	NULL as provider_id,
	NULL as care_site_id,
	dem.mrn as person_source_value,
	dem.Gender as gender_source_value,
	0 as gender_source_concept_id,
	dem.race1 as race_source_value,
	0 as race_source_concept_id,
	dem.hispanic as ethnicity_source_value,
	0 as ethnicity_source_concept_id
from (select coalesce(MAX(person_id), 0) as pid from omop.person) as pcnt,
		dbo.vdw_demographics_em dem
	left join omop.vdw_lkup_gender lug
	on lug.vdw_gender = dem.Gender
	left join omop.vdw_lkup_race lur
	on lur.vdw_race = dem.race1
	left join omop.vdw_lkup_ethnicity let
	on let.vdw_ethnicity = dem.hispanic
;
GO
--select * from omop.person



-- populate omop.visit_occurance
truncate table omop.visit_occurrence;
insert into omop.visit_occurrence
select 
	enccnt.vid+row_number() over (order by current_timestamp) as visit_occurrence_id, voc.*
from
(
select
	pn.person_id,
	vi.concept_id as visit_concept_id,
	cast (replace (ute.adate, '?', '') as date) as visit_start_date,
	cast (replace (ute.atime, '?', '') as time) as visit_start_datetime,
	cast (replace (ute.ddate, '?', '') as date) as visit_end_date,
	cast (replace (ute.dtime, '?', '') as time) as visit_end_datetime,
	vt.concept_id as visit_type_concept_id,
	pr.provider_id,
	cs.care_site_id,
	ute.enc_id as visit_source_value,
	0 as visit_source_concept_id,
	las.concept_id as admitting_source_concept_id,
	las.vdw_admitting_source as admitting_source_value,
	lds.concept_id as discharge_to_concept_id,
	lds.vdw_discharge_status as discharge_to_source_value,
	0 as preceding_visit_occurrence_id
from  
	dbo.vdw_utilization_em ute
	inner join omop.person pn
	on ute.mrn = pn.person_source_value
	inner join omop.provider pr
	on ute.provider = pr.provider_source_value
	inner join omop.care_site cs
	on ute.facility_code = cs.care_site_source_value
	and ute.enctype+'|'+ute.encounter_subtype = left(cs.place_of_service_source_value, 5)
	inner join omop.vdw_lkup_visit vi
	on ute.enctype = vi.vdw_enctype
	inner join omop.vdw_lkup_visit_type vt
	on (ute.[source] = vt.vdw_ute_source
	and ute.source_data = vt.vdw_ute_source_data)
	left join omop.vdw_lkup_admitting_source las
	on las.vdw_admitting_source = ute.admitting_source
	left join omop.vdw_lkup_discharge_status lds
	on lds.vdw_discharge_status = ute.discharge_status
) voc,
(select coalesce(MAX(visit_occurrence_id), 0) as vid from omop.visit_occurrence) as enccnt
;
GO




-- populate omop.condition_occurrence
truncate table omop.condition_occurrence;
insert into omop.condition_occurrence
select 
	pxcnt.pid+row_number() over (order by dx.mrn, current_timestamp) as condition_occurrence_id,
	pn.person_id,
	coalesce(ldx.concept_id, 0) as condition_concept_id,
	cast (replace (dx.adate, '?', '') as date) as condition_start_date,
	cast (replace (dx.adate, '?', '') as date) as condition_start_datetime,
	cast (replace (dx.ghc_diagdate, '?', '') as date) as condition_end_date,
	cast (replace (dx.ghc_diagdate, '?', '') as date) as condition_end_datetime,
	case when dx.primary_dx = 'P'
		then 44786627
		when dx.primary_dx = 'S'
		then 44786628
		else 0
	end as condition_type_concept_id,
	null as stop_reason,
	pr.provider_id,
	vo.visit_occurrence_id,
	dx.dx as condition_source_value,
	ldx.source_concept_id as condition_source_concept_id,
	null as condition_status_source_value,
	4033240 as condition_status_concept_id
from (select coalesce(MAX(condition_occurrence_id), 0) as pid from omop.condition_occurrence) as pxcnt, 
	dbo.vdw_dx_em dx
	inner join omop.person pn
	on pn.person_source_value = dx.mrn
	inner join omop.visit_occurrence vo
	on dx.enc_id = vo.visit_source_value
	left join omop.provider pr
	on dx.diagprovider = pr.provider_source_value
	left join omop.lkup_std_condition ldx
	on dx.dx = ldx.source_concept_code
;
GO

-- select top 100 * from dbo.vdw_dx_em;
-- select top 100 * from omop.concept where concept_class_id like 'condition%';



-- populate omop.procedure_occurrence
truncate table omop.procedure_occurrence;
insert into omop.procedure_occurrence
SELECT 
	pxcnt.pid+row_number() over (order by px.mrn, current_timestamp) as procedure_occurrence_id
    ,pn.person_id
    ,pxt.concept_id as procedure_concept_id
    ,cast (replace (px.procdate, '?', '') as date) as procedure_date
    ,cast (replace (px.procdate, '?', '') as datetime) as procedure_datetime
    ,38000266 as [procedure_type_concept_id]
    ,pxm.concept_id as [modifier_concept_id]
    ,0 as [quantity]
    ,pr.provider_id
    ,vo.visit_occurrence_id
    ,px.px as [procedure_source_value]
    ,0 as [procedure_source_concept_id]
    ,'' as [qualifier_source_value] 
from (select coalesce(MAX(procedure_occurrence_id), 0) as pid from omop.procedure_occurrence) as pxcnt,
	dbo.vdw_procedures_em px
	inner join omop.person pn
	on pn.person_source_value = px.mrn
	inner join omop.visit_occurrence vo
	on px.enc_id = vo.visit_source_value
	left join omop.provider pr
	on px.performingprovider = pr.provider_source_value
	inner join omop.vdw_lkup_px pxt
	on pxt.vdw_px = px.px
	left join omop.vdw_lkup_px pxm
	on pxm.vdw_px = px.cptmod1
;
GO


-- populate omop.death
truncate table omop.death;
insert into omop.death
select distinct pe.person_id, 
	cast (replace (dt.deathdt, '?', '') as date) as death_date,
	cast (replace (dt.deathdt, '?', '') as datetime) as death_datetime,
	dtht.concept_id as death_type_concept_id,
	cod.concept_id as cause_concept_id,
	cod.vdw_cod as cause_source_value,
	0 as cause_source_concept_id
from omop.person pe
inner join dbo.vdw_death_em dt
	on pe.person_source_value = dt.mrn
left join dbo.vdw_causeofdeath_em cc
	on cc.mrn = dt.mrn
left join omop.vdw_lkup_cod cod
	on cc.cod = cod.vdw_cod
left join omop.vdw_lkup_deathtype dtht
	on dt.source_list = dtht.vdw_source_list
;
GO





-- populate omop.drug_exposure
truncate table omop.drug_exposure;
insert into omop.drug_exposure
select
	rxcnt.rid+row_number() over (order by rx.mrn, current_timestamp) as drug_exposure_id
	,pn.person_id
	,coalesce (ndc.concept_id, 0) as drug_concept_id
	,cast (replace (rx.rxdate, '?', '') as date) as [drug_exposure_start_date]
	,cast (replace (rx.rxdate, '?', '') as datetime) as [drug_exposure_start_datetime]
	,cast (replace (rx.rxdate, '?', '') as date) as [drug_exposure_end_date]
	,cast (replace (rx.rxdate, '?', '') as datetime) as [drug_exposure_end_datetime]
	,null as [verbatim_end_date]
	,0 as [drug_type_concept_id]
	,null as [stop_reason]
	,case rx.rxfill
		when 'I' then 0
		when 'R' then 1
		else 0
	 end as [refills]
	,replace(rx.rxamt, '?', NULL) as [quantity]
	,replace(rx.rxsup, '?', NULL) as [days_supply]
	,null as [sig]
	,0 as [route_concept_id]
	,0 as [lot_number]
	,pr.provider_id
	,0 as [visit_occurrence_id]
	,rx.ndc as [drug_source_value]
	,0 as [drug_source_concept_id]
	,rx.source as [route_source_value]
	,null as [dose_unit_source_value]
from (select coalesce(MAX(drug_exposure_id), 0) as rid from omop.drug_exposure) as rxcnt,
	dbo.vdw_pharmacy_em rx
	inner join omop.person pn
	on pn.person_source_value = rx.mrn
	left join omop.provider pr
	on pr.provider_source_value = rx.rxmd
	left join omop.vdw_lkup_rx_ndc ndc
	on rx.ndc = ndc.vdw_ndc
;
GO






-- populate omop.drug_strength
-- Rx fill information


-- populate omop.dose_era
-- period of time that a specific dose was being give for a specific drug at a specific dosage


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




-- populate omop.observation **Would Need Social_History
/*	The OBSERVATION table captures clinical facts about a Person 
	obtained in the context of examination, questioning or a procedure.
	Any data that cannot be represented by any other domains, such as social and lifestyle facts, 
	medical history, family history, etc. are recorded here.
*/


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


-- populate omop.measurement  ** Would still need to add Vital Signs
/* The MEASUREMENT table contains records of Measurement, i.e. structured values (numerical 
	or categorical) obtained through systematic and standardized examination or testing of 
	a Person or Person's sample. The MEASUREMENT table contains both orders and results of 
	such Measurements as laboratory tests, vital signs, quantitative findings from pathology 
	reports, etc.
*/
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

--select * from omop.concept where concept_code = '5811-5'
--	select top 500 * from omop.vdw_lkup_measurement_loinc where concept_name like '%urine%spec%grav%'
--	select top 5000 * from #tmp_measurement_labs where time_flag = 0 --where [measurement_date] like 'nd_%'


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