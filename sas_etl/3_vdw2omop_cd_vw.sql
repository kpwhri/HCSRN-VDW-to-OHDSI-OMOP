/*** Code Lookups For Location ***/
	--NONE

/*** Code Lookups For Care_Site ***/
	-- Place of Service
	-- probably incorrectly mapped look at email from Roy about CMD code
	if OBJECT_ID('omop.vdw_lkup_pos') is not null drop view omop.vdw_lkup_pos;
	GO
	create view omop.vdw_lkup_pos as
	select distinct cp.*, ue.enctype, ue.encounter_subtype
	from
	( select enctype, encounter_subtype, 
		case enctype+'||'+encounter_subtype 
			when 'AV||DI' then 17
			when 'AV||HA' then 24
			when 'AV||OB' then 17
			when 'AV||OC' then 17
			when 'AV||RH' then 62
			when 'AV||SD' then 24
			when 'AV||UC' then 20
			when 'ED||HA' then 23
			when 'ED||OC' then 20
			when 'EM||OT' then 2
			when 'IP||AI' then 21
			when 'IS||DI' then 22
			when 'IS||HS' then 34
			when 'IS||NH' then 13
			when 'IS||OT' then 99
			when 'IS||RH' then 61
			when 'IS||SN' then 31
			when 'LO||OC' then 81
			when 'LO||OT' then 81
			when 'OE||AI' then 21
			when 'OE||HH' then 12
			when 'OE||HS' then 34
			when 'OE||OT' then 99
			when 'OE||SN' then 31
			when 'RO||OC' then 17
			when 'RO||OT' then 17
			when 'TE||HH' then 2
			when 'TE||OT' then 2
			else 99
		end as pos
	from dbo.vdw_utilization_em ) ue, omop.concept cp
	where cp.concept_class_id = 'Place Of Service'
	and cp.concept_code NOT LIKE 'OMOP%'
	and cast(cp.concept_code as int) = ue.pos
	;
	GO

--	select * from omop.concept where concept_class_id = 'Place Of Service'

/*** Code Lookups For Provider ***/
	-- Specialty
	if OBJECT_ID('omop.vdw_lkup_specialty') is not null drop view omop.vdw_lkup_specialty;
	GO
	create view omop.vdw_lkup_specialty as
	select row_number() over (partition by spcty.vdw_specialty order by spcty.vdw_specialty) as vdw_specialty_ord, spcty.*
	from
	(
		select cp.*,  
			case 
				when cp.concept_name = 'Adolescent Medicine' then 'ADO' 
				when cp.concept_name = 'Aerospace Medicine' then 'AER' 
				when cp.concept_name = 'Psychology' then 'ALC' -- 'Chemical Dependency'
				when cp.concept_name = 'Allergy/Immunology' then 'ALL' 
				when cp.concept_name = 'Ancillary Services' then 'ANC' 
				when cp.concept_name = 'Anesthesiology' then 'ANE' 
				when cp.concept_name = 'Sports Medicine' then 'ATH' 
				when cp.concept_name = 'Audiology' then 'AUD' 
				when cp.concept_name = 'Osteopathic Manipulative Therapy' then 'BON' -- Bone And Mineral
				when cp.concept_name = 'Cardiology' then 'CAR' 
				when cp.concept_name = 'Cardiac Surgery' then 'CAV' -- 'Cardiovascular Surgery'
				when cp.concept_name = 'Chiropractic' then 'CHR' -- 'Chiropractor'
				when cp.concept_name = 'Clinical Cardiac Electrophysiology' then 'CLC' -- 'Clin Cardiac Electrophysiology'
				when cp.concept_name = 'Colorectal Surgery' then 'COL' -- 'Colon & Rectal Surgery'
				when cp.concept_name = 'Complimentary & Alternative Medicine' then 'COM' 
				when cp.concept_name = 'Continuing Care' then 'CON' 
				when cp.concept_name = 'Critical care (intensivist)' then 'CRI' -- Critical Care
				when cp.concept_name = 'Dentistry' then 'DEN' 
				when cp.concept_name = 'Dermatology' then 'DER' 
				when cp.concept_name = 'Dor' then 'DOR' 
				when cp.concept_name = 'Medical Education' then 'EDU' 
				when cp.concept_name = 'Emergency Medicine' then 'EME' 
				when cp.concept_name = 'Emi' then 'EMI' 
				when cp.concept_name = 'Endocrinology' then 'END' 
				when cp.concept_name = 'Otolaryngology' then 'ENT' -- VDW Specs have two of the same specialty with different codes.
				when cp.concept_name = 'Family Practice' then 'FAM' -- 'Family Medicine'
				when cp.concept_name = 'Flexible' then 'FLX' 
				when cp.concept_name = 'Gastroenterology' then 'GAS' 
				when cp.concept_name = 'Medical Genetics and Genomics' then 'GEN' -- Genetics
				when cp.concept_name = 'Geriatric Medicine' then 'GER' -- Gerontology
				when cp.concept_name = 'Hand Surgery' then 'HAN' 
				when cp.concept_name = 'Home Health Agency' then 'HOM' -- 'Home Health'
				when cp.concept_name = 'Hospital' then 'HOS' 
				when cp.concept_name = 'Undersea and Hyperbaric Medicine' then 'HYM' -- Hyperbaric Medicine
				when cp.concept_name = 'Hypertension' then 'HYP' 
				when cp.concept_name = 'Internal Medicine' then 'IMG' -- General Internal Medicine
				when cp.concept_name = 'Infectious Disease' then 'INF' 
				when cp.concept_name = 'Laboratory' then 'LAB' 
				when cp.concept_name = 'Psychiatry' then 'MEN' -- 'Mental Health'
				when cp.concept_name = 'Care Management' then 'MGM' 
				when cp.concept_name = 'Midlevel' then 'MID' 
				when cp.concept_name = 'Multispecialty' then 'MUL' 
				when cp.concept_name = 'Nephrology' then 'NEH' 
				when cp.concept_name = 'Neonatal-Perinatal Medicine' then 'NEO' -- Neonatology
				when cp.concept_name = 'Neurosurgery' then 'NES' 
				when cp.concept_name = 'Neurotology' then 'NEU' -- Neurology
				when cp.concept_name = 'No Boards' then 'NOB' 
				when cp.concept_name = 'Nuclear Medicine' then 'NUM' 
				when cp.concept_name = 'Nurse Practitioner' then 'NUR' -- Nurse
				when cp.concept_name = 'Nutrition' then 'NUT' 
				when cp.concept_name = 'Gynecology/Oncology' then 'OBO' -- Gynecologyic Oncology
				when cp.concept_name = 'Obstetrics/Gynecology' then 'OBS' -- Obstetrics - Gynecology
				when cp.concept_name = 'Occupational Therapy' then 'OCM' -- Occupational Health
				when cp.concept_name = 'Oncology' then 'ONC' 
				when cp.concept_name = 'Surgical Oncology' then 'ONS' 
				when cp.concept_name = 'Ophthalmology' then 'OPH' 
				when cp.concept_name = 'Optician' then 'OPL' -- Optical
				when cp.concept_name = 'Optometry' then 'OPT' 
				when cp.concept_name = 'Oral Surgery' then 'ORA' 
				when cp.concept_name = 'Orthodontia' then 'ORD' 
				when cp.concept_name = 'Orthopedic Surgery' then 'ORT' -- Orthopedics
				when cp.concept_name = 'Orthopaedic Sports Medicine' then 'ORT' -- Orthopedics
				when cp.concept_name = 'Otolaryngology' then 'OTO' 
				when cp.concept_name = 'Pain Management' then 'PAI' 
				when cp.concept_name LIKE 'Pathology%' then 'PAT' 
				when cp.concept_name = 'Pediatrics' then 'PED' 
				when cp.concept_name LIKE'Pediatric %' then 'PES' -- 'Pediatric Subspecialty'
				when cp.concept_name = 'Perinatology' then 'PEY' 
				when cp.concept_name = 'Pharmacy' then 'PHA' 
				when cp.concept_name = 'Physical Therapy' then 'PHT' 
				when cp.concept_name = 'Physiatry' then 'PHY' 
				when cp.concept_name = 'Plastic And Reconstructive Surgery' then 'PLA' -- 'Plastic Surgery'
				when cp.concept_name = 'Podiatry' then 'POD' 
				when cp.concept_name = 'Preventive Medicine' then 'PRE' 
				when cp.concept_name = 'Prosthodontia' then 'PRO' 
				when cp.concept_name = 'Psychiatry' then 'PSY' 
				when cp.concept_name = 'Public Health and General Preventive Medicine' then 'PUB' -- 'Public Health'
				when cp.concept_name = 'Pulmonary Disease' then 'PUL' -- 'Pulmonary Medicine'
				when cp.concept_name = 'Radiology' then 'RAD' 
				when cp.concept_name = 'Rehabilitation Agency' then 'REH' -- 'Rehabilitation Medicine'
				when cp.concept_name = 'Respiratory Therapy' then 'RES' 
				when cp.concept_name = 'Rheumatology' then 'RHE' 
				when cp.concept_name = 'Radiation Oncology' then 'ROP' 
				when cp.concept_name = 'Sleep Medicine' then 'SLC'  -- Sleep Center'
				when cp.concept_name = 'Social Services' then 'SOC' 
				when cp.concept_name = 'Speech Patholgy' then 'SPP' 
				when cp.concept_name = 'Surgery' then 'SUR' 
				when cp.concept_name = 'Teen Clinic' then 'TEE' 
				when cp.concept_name = 'Medical Toxicology' then 'TOX' 
				when cp.concept_name = 'Transportation/Non-Emergency' then 'TRN' 
				when cp.concept_name = 'Transplant Surgery' then 'TRS' 
				when cp.concept_name = 'Unknown' then 'UNK' 
				when cp.concept_name = 'Urgent Care' then 'URG' 
				when cp.concept_name = 'Urology' then 'URO' 
				when cp.concept_name = 'Vascular Surgery' then 'VAS'
				else 'NO_MAP'
			end vdw_specialty	
		from omop.concept cp
		where cp.concept_class_id = 'Specialty' 
			and cp.standard_concept = 'S' 
			and cp.valid_end_date > CURRENT_TIMESTAMP
	--	order by cp.concept_name
	) spcty
	;
	GO



	-- Gender Code
	select distinct hispanic from dbo.vdw_demographics_em;
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


/*** Code Lookups For Person ***/
	-- Same Gender Code mapping as from above

	-- Ethnicity 
	if OBJECT_ID('omop.vdw_lkup_ethnicity') is not null drop view omop.vdw_lkup_ethnicity;
	GO
	create view omop.vdw_lkup_ethnicity as
	(  select distinct cp.*, dem.vdw_ethnicity
	  from omop.concept cp
	  full outer join 
		(select distinct
			case hispanic 
				when 'Y' then 'Hispanic'
				when 'N' then 'Not Hispanic'
				when 'U' then '0'
			end as omop_hispanic,
			hispanic as vdw_ethnicity
		 from
			dbo.vdw_demographics_em
		 ) dem
	  on cp.concept_code = dem.omop_hispanic
	  where cp.vocabulary_id like '%ethnicity%'
		or dem.omop_hispanic = '0'
	);
	GO

	-- Gender Source

	-- Race 
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
		end as vdw_race
	  from omop.concept cp
	  where cp.vocabulary_id like '%race%'
	);
	GO
	-- select * from omop.vdw_lkup_race;


/*** Code Lookups For Visit Occurrence ***/
	
	-- Visit Code
	if OBJECT_ID('omop.vdw_lkup_visit') is not null drop view omop.vdw_lkup_visit;
	GO
	create view omop.vdw_lkup_visit as
	(select distinct cp.*, ut.vdw_enctype
	  from (select distinct enctype as vdw_enctype, 
				case when enctype = 'IP' then 'IP' 
				when enctype = 'AV' then 'OP'
				when enctype = 'IS' then 'LTCP'
				when enctype = 'ED' then 'ER'
				when enctype = 'EM' then 'ERIP'
				when enctype = 'LO' then 'OP'
				when enctype = 'OE' then 'OP'
				when enctype = 'RO' then 'OP'
				when enctype = 'TE' then 'OP'
			end as visit_cds 
			from dbo.vdw_utilization_em) ut 
	  full outer join omop.concept cp
	  on ut.visit_cds = cp.concept_code
	where cp.domain_id like '%visit%'
	);
	GO	
--	select distinct enctype from dbo.vdw_utilization_em	
--	select distinct concept_code, concept_name from omop.concept where domain_id like '%visit%'


	-- Visit Type
	if OBJECT_ID('omop.vdw_lkup_visit_type') is not null drop view omop.vdw_lkup_visit_type;
	GO
	create view omop.vdw_lkup_visit_type as
	select distinct cp.*, ut.[source] as vdw_ute_source, ut.source_data as vdw_ute_source_data
	from 
	(	select distinct [source], [source_data],
			case [source_data]
				when 'B' then 'Visit derived from encounter on claim'
				when 'C' then 'Visit derived from encounter on claim'
				when 'E' then 'Visit derived from EHR record'
				when 'L' then 'Visit derived from EHR record' -- 'Clinical Study visit'
			end as vo_map
		from dbo.vdw_utilization_em) ut, omop.concept cp
	where cp.concept_class_id like '%visit type%'
	and cp.concept_name = ut.vo_map
	; 
	GO

	
	-- Admitting Source
	if OBJECT_ID('omop.vdw_lkup_admitting_source') is not null drop view omop.vdw_lkup_admitting_source;
	GO
	create view omop.vdw_lkup_admitting_source as
	select cp.*, ue.vdw_admitting_source
	from
	(
	select distinct admitting_source as vdw_admitting_source,
		case admitting_source
			when 'AV' then 17
			when 'ED' then 23
			when 'AF' then 14
			when 'AL' then 13
			when 'HH' then 14
			when 'HS' then 34
			when 'HO' then 12
			when 'IP' then 21
			when 'NH' then 54
			when 'OT' then 99
			when 'RS' then 13
			when 'RH' then 62
			when 'SN' then 31
			when 'UN' then 10
			else 10
		end as poscd
	from dbo.vdw_utilization_em
	) ue, omop.concept cp
	where cp.concept_class_id = 'Place of Service'
	and cp.concept_code not like 'OMOP%'
	and cp.concept_code = ue.poscd
	;GO

	-- Discharge To

	if OBJECT_ID('omop.vdw_lkup_discharge_status') is not null drop view omop.vdw_lkup_discharge_status;
	GO
	create view omop.vdw_lkup_discharge_status as
	select cp.*, ue.vdw_discharge_status
	from	
	(
	select distinct discharge_status as vdw_discharge_status,
		case discharge_status
			when 'AM' then 12
			when 'AW' then 99
			when 'AF' then 14
			when 'AL' then 13
			when 'EX' then 99
			when 'HH' then 14
			when 'HS' then 34
			when 'HO' then 12
			when 'IP' then 21
			when 'NH' then 54
			when 'OT' then 99
			when 'RS' then 13
			when 'RH' then 62
			when 'SN' then 31
			when 'SH' then 21
			when 'UN' then 10
			else 10
		end as poscd	
	from dbo.vdw_utilization_em
	) ue, omop.concept cp
	where cp.concept_class_id = 'Place of Service'
	and cp.concept_code not like 'OMOP%'
	and cp.concept_code = ue.poscd
	;GO

/*** Code Lookups For Condition Occurrence ***/
	-- Condition Lkup
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

if OBJECT_ID('omop.lkup_std_condition') is not null drop view omop.lkup_std_condition;
GO
create view omop.lkup_std_condition as
select distinct ldx.concept_id as source_concept_id, 
	ldx.concept_name as source_concept_name, 
	ldx.domain_id as source_domain_id,
	ldx.vocabulary_id as source_vocabulary_id,
	ldx.concept_class_id as source_concept_class_id, 
	ldx.standard_concept as source_standard_concept,
	ldx.concept_code as source_concept_code,
	cc.*
from omop.vdw_lkup_dx ldx
left join omop.concept_relationship cr 
	on ldx.concept_id = cr.concept_id_1
left join omop.concept cc
	on cr.concept_id_2 = cc.concept_id
where cc.standard_concept = 'S'
;
GO

	-- Condition Type Lkup
	/*	A Condition Occurrence Type is assigned based on the data source and type of 
		condition attribute, for example:
			ICD-9-CM Primary Diagnosis from inpatient and outpatient Claims
			ICD-9-CM Secondary Diagnoses from inpatient and outpatient Claims
			Diagnoses or problems recorded in an EHR.
	*/
--	select * from omop.concept where concept_class_id = 'Condition Type';

	-- Condition Stop Reason
	/* The Stop Reason indicates why a Condition is no longer valid with respect to 
		the purpose within the source data. Typical values include “Discharged”, “Resolved”, etc. 
		Note that a Stop Reason does not necessarily imply that the condition is no 
		longer occurring. 
	*/

	

	/*	The Condition Status reflects when the condition was diagnosed, implying a different depth of diagnostic work-up:
		Admitting diagnosis: use concept_id 4203942
		Preliminary diagnosis: use concept_id 4033240
		Final diagnosis: use concept_id 4230359 – should also be used for ‘Discharge diagnosis’
	*/




/*** Code Lookups For Procedure Occurrence ***/

	-- Procedure
	if OBJECT_ID('omop.vdw_lkup_px') is not null drop view omop.vdw_lkup_px;
	GO
	create view omop.vdw_lkup_px as
	select distinct cp.*, px.px as vdw_px
	from omop.concept cp
	inner join dbo.vdw_procedures_em px
	on cp.concept_code = px.px
	where cp.domain_id = 'Procedure'
	or cp.domain_id = 'Device'
	or cp.vocabulary_id = 'HCPCS'
	union
	select cp.*, px.px as vdw_px
	from omop.concept cp,
	(	select distinct px from dbo.vdw_procedures_em
		except
		select distinct pc.px from dbo.vdw_procedures_em pc
		inner join omop.concept ct
		on pc.px = ct.concept_code
		and (ct.domain_id = 'Procedure'
		or ct.domain_id = 'Device'
		or ct.vocabulary_id = 'HCPCS')
	) px
	where cp.concept_id = 0
	;
	GO
	-- select * from omop.vdw_lkup_px;
--	select * from omop.concept where concept_id = 0

	-- Procedure Type
/*
	select cp.*
	from omop.concept cp
	where cp.concept_class_id like 'Procedure Type'
*/

	-- Procedure Modifier








/*** Code Lookups For Death ***/

	-- Cause of Death
	if OBJECT_ID('omop.vdw_lkup_cod') is not null drop view omop.vdw_lkup_cod;
	GO
	create view omop.vdw_lkup_cod as
	select distinct cp.*, cod.cod as vdw_cod, cod.dx_codetype as vdw_cod_type
	from omop.concept cp, dbo.vdw_causeofdeath_em cod
	where cp.concept_code = cod.cod
	;
	GO

	-- Death Type
	if OBJECT_ID('omop.vdw_lkup_deathtype') is not null drop view omop.vdw_lkup_deathtype;
	GO
	create view omop.vdw_lkup_deathtype as
	select distinct cp.*, vcd.source_list as vdw_source_list, vcd.causetype as vdw_causetype
	from omop.concept cp,
	(
		select distinct dt.source_list, cod.causetype,
			case 
				when cod.causetype = 'I' and dt.source_list like 'B%' then 261
				when cod.causetype = 'I' and dt.source_list like 'N%' then 242
				when cod.causetype = 'I' and dt.source_list like 'S%' then 242
				when cod.causetype = 'I' and dt.source_list like 'T%' then 254
				when cod.causetype = 'I' and dt.source_list like 'E%' then 254
				when cod.causetype = 'I' and dt.source_list like 'P%' then 254
				when cod.causetype = 'I' and dt.source_list like 'M%' then 254
				when cod.causetype = 'U' and dt.source_list like 'B%' then 261
				when cod.causetype = 'U' and dt.source_list like 'N%' then 242
				when cod.causetype = 'U' and dt.source_list like 'S%' then 242
				when cod.causetype = 'U' and dt.source_list like 'T%' then 256
				when cod.causetype = 'U' and dt.source_list like 'E%' then 256
				when cod.causetype = 'U' and dt.source_list like 'P%' then 256
				when cod.causetype = 'U' and dt.source_list like 'M%' then 256
				when cod.causetype = 'C' and dt.source_list like 'B%' then 261
				when cod.causetype = 'C' and dt.source_list like 'N%' then 242
				when cod.causetype = 'C' and dt.source_list like 'S%' then 242
				when cod.causetype = 'C' and dt.source_list like 'T%' then 255
				when cod.causetype = 'C' and dt.source_list like 'E%' then 255
				when cod.causetype = 'C' and dt.source_list like 'P%' then 255
				when cod.causetype = 'C' and dt.source_list like 'M%' then 255
			end as omop_death_type
		from dbo.vdw_death_em dt, dbo.vdw_causeofdeath_em cod
	) as vcd
	where vcd.omop_death_type = cp.concept_id
	;
	GO


/*** Code Lookups For Drug Exposure ***/


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



/*** Code Lookups For Location ***/




-- select * from omop.vdw_lkup_gender;



/*** Code Lookups for Measurements ***/

-- codes for omop.measurement measurement_concept loinc codes
	if OBJECT_ID('omop.vdw_lkup_measurement_loinc') is not null drop view omop.vdw_lkup_measurement_loinc;
	GO
	create view omop.vdw_lkup_measurement_loinc as (
	select distinct cp.*, lr.loinc as vdw_loinc 
	from omop.concept cp
	inner join dbo.vdw_labresults_fin lr
	on cp.concept_code = lr.loinc
	where cp.vocabulary_id = 'LOINC'
	);
	GO

/*
	update dbo.vdw_labresults_fin set loinc = '2160-0' where test_type = 'CREATININE' and loinc = '?';
	select * from dbo.vdw_labresults_fin where test_type = 'CREATININE'
*/
--select * from omop.measurement_concept_loinc








-- Observation is like social history and Problem list and Personal Health Records



-- select * from omop.relationship;

/*
select top 1000 * from dbo.vdw_enrollment_em
select count(*), location, pcc from dbo.vdw_enrollment_em
group by location, pcc
order by count(*) desc
*/






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