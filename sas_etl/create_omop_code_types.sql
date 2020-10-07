create table sb_ghri.omop_code_types as
(select distinct cot.vocabulary_id as omop_vocabulary, cot.domain_id as omop_domain, cot.concept_class_id as omop_class 
from sb_ghri.concept cot
) with data
;

drop table sb_ghri.vdw_codebucket_types;
create table sb_ghri.vdw_codebucket_types as
(
select distinct code_type as vcb_code_type, 
  code_source as vcb_code_source, 
  case when code_type like '10' then 'ICD10PCS'
    when code_type like '09' then 'ICD9Proc'
	when code_type like 'C4' then 'CPT4'
	when code_type like 'H4' then 'HCPCS'
	when code_type like 'RV' then 'RevenueCode'
	when code_type like 'LO' then 'Local'
    else code_type
  end as std_code_type, 
  case when code_source like 'VDW-PX%' then 'PROCEDURES' 
    else code_source
  end as std_code_source 
from sb_ghri.vdw_codebucket
where code_type <> 'code_type'
) with data
;


drop table sb_ghri.omop_code_types
create table sb_ghri.vdw_codebucket_types as
(
select distinct vcb.code_type as vcb_code_type, 
  vcb.code_source as vcb_code_source, 
  case 
    when vcb.code_type = '10' then 'ICD10PCS'
    when vcb.code_type = '09' then 'ICD9Proc'
	when vcb.code_type = 'C4' then 'CPT4'
	when vcb.code_type = 'H4' then 'HCPCS'
	when vcb.code_type = 'RV' then 'Revenue Code'
	when vcb.code_type = 'SEX_ADMIN' then 'Gender'
	when vcb.code_type = 'RxNorm_Extension' then 'RxNorm Extension'
	when vcb.code_type = 'RACE' then 'Race'
	when vcb.code_type = 'SPECIALTY' then 'Specialty'
	when vcb.code_type = 'DX_CODETYPE' then 'source'
	when vcb.code_type = 'PRINCIPAL_DX' then 'source'
	when vcb.code_type = 'PRIMARY_DX' then 'source'
	when vcb.code_type = 'HISPANIC' then 'Ethnicity'
	when vcb.code_type = 'ENCTYPE' then 'Place of Service'
	when vcb.code_type = 'ENCOUNTER_SUBTYPE' then 'Place of Service'
     else omp.omop_vocabulary
  end as std_code_type, 
  case 
  	when omp.omop_domain is null and vcb.code_type = 'SEX_ADMIN' THEN 'Gender'
  	when omp.omop_domain is null and vcb.code_type = 'HISPANIC' THEN 'Ethnicity'
  	when omp.omop_domain is null and vcb.code_type = 'RACE' THEN 'Race'
    when omp.omop_domain is null and vcb.code_source = 'OMOP_PROCEDURE' then 'Procedure' 
   when omp.omop_domain is null and vcb.code_source = 'LCL_VDW_PROCEDURE' then 'Procedure'
	when omp.omop_domain is null and vcb.code_source = 'ENCOUNTER' then 'Visit'
	when omp.omop_domain is null and vcb.code_source = 'SOCIAL_HISTORY' THEN 'Measurement'
	when omp.omop_domain is null and vcb.code_source = 'PROVIDER' then 'Provider Specialty'
	when omp.omop_domain is null and vcb.code_source = 'DIAGNOSIS' THEN 'Condition'
	when omp.omop_domain is null and vcb.code_source = 'ENROLLMENT' THEN 'Plan'
	when omp.omop_domain is null and vcb.code_source = 'SOCIAL_HISTORY' THEN 'Measurement'
 	when omp.omop_domain is null and vcb.code_source = 'LAB_RESULTS' THEN 'Measurement'
 	when omp.omop_domain is null and vcb.code_source = 'DEATH' THEN 'Type Concept'
 	when omp.omop_domain is null and vcb.code_source = 'CAUSE_OF_DEATH' THEN 'Type Concept'
 	when omp.omop_domain is null and vcb.code_source = 'CENSUS_LOCATION' THEN 'Geography'
 	when omp.omop_domain is null and vcb.code_source = 'VITAL_SIGNS' THEN 'Measurement'
 	when omp.omop_domain is null and vcb.code_source = 'OMOP_PHARMACY' THEN 'Drug'
 	when omp.omop_domain is null and vcb.code_source = 'DEMOGRAPHICS' THEN 'Person'
 	when omp.omop_domain is null and vcb.code_source = 'LANGUAGE' THEN 'Person'
 	when omp.omop_domain is null and vcb.code_source = 'EVERNDC' THEN 'Drug'
 	when omp.omop_domain is null and vcb.code_source = 'PHARMACY' THEN 'Drug'
   else omp.omop_domain
  end as std_code_source 
from sb_ghri.vdw_codebucket vcb
left join sb_ghri.omop_code_types omp
on vcb.code_type = omp.omop_vocabulary
where vcb.code_type <> 'code_type'
) with data
;


drop view sb_ghri.zrcm_utl_pos;
create view sb_ghri.zrcm_utl_pos as
	select  0 as vdw_code_id, cast(ue.vdw_code as char(5)) as vdw_code, vdw_cd_desc, 'enctype-subtype' as vdw_cd_type, cp.concept_id as omop_code_id,
	  cp.concept_code as omop_code, cp.concept_name as concept_cd_desc, cp.vocabulary_id as omop_cd_type
	from
	( select distinct trim(ent.enctype)||'-'||trim(es.encounter_subtype) as vdw_code, cast(trim(ent.code_desc)||'-'||trim(es.code_desc) as varchar(1200)) as vdw_cd_desc,
		case trim(ent.enctype)||'-'||trim(es.encounter_subtype)
			when 'AV-DI' then '17'
			when 'AV-HA' then '24'
			when 'AV-OB' then '17'
			when 'AV-OC' then '17'
			when 'AV-RH' then '62'
			when 'AV-SD' then '24'
			when 'AV-UC' then '20'
			when 'ED-HA' then '23'
			when 'ED-OC' then '20'
			when 'EM-OT' then '2'
			when 'IP-AI' then '21'
			when 'IS-DI' then '22'
			when 'IS-HS' then '34'
			when 'IS-NH' then '13'
			when 'IS-OT' then '99'
			when 'IS-RH' then '61'
			when 'IS-SN' then '31'
			when 'LO-OC' then '81'
			when 'LO-OT' then '81'
			when 'OE-AI' then '21'
			when 'OE-HH' then '12'
			when 'OE-HS' then '34'
			when 'OE-OT' then '99'
			when 'OE-SN' then '31'
			when 'RO-OC' then '17'
			when 'RO-OT' then '17'
			when 'TE-HH' then '2'
			when 'TE-OT' then '2'
			else '99'
		end as pos
	from (select trim(code) as enctype, code_desc from sb_ghri.vdw_codebucket where code_type = 'enctype') ent,
	  (select trim(code) as encounter_subtype, code_desc from sb_ghri.vdw_codebucket where code_type = 'encounter_subtype') es
	) ue
	left join sb_ghri.concept cp
	on cp.concept_code = ue.pos
	where cp.vocabulary_id = 'Place of Service'
	and cp.concept_code NOT LIKE 'OMOP%'
	;



create view sb_ghri.zrcm_dem_gender as
	(  select distinct 
	   0 as vdw_code_id,
	   dem.code as vdw_code, 
	   dem.code_desc as vdw_cd_desc,
	   dem.code_type as vdw_cd_type,
          cp.concept_id as omop_code_id,
          cp.concept_code as omop_code,
	        cp.concept_name as omop_cd_desc,
	        cp.vocabulary_id as omop_cd_type 
	  from sb_ghri.concept cp
	  left join sb_ghri.vdw_codebucket dem
	  on cp.concept_code = upper(dem.code)
	  where upper(dem.code_type) = 'SEX_ADMIN'
	  and cp.vocabulary_id = 'Gender'
	);


create view sb_ghri.zrcm_prv_specialty as
	select row_number() over ( order by spcty.omop_code) as id, spcty.*
	from
	(
		select
		  cp.concept_id as vdw_code_id,
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
				else ''
			end vdw_code,
			case 
				when cp.concept_name = 'Adolescent Medicine' then 'Adolescent Medicine' 
				when cp.concept_name = 'Aerospace Medicine' then 'Aerospace Medicine' 
				when cp.concept_name = 'Psychology' then 'Chemical Dependency' -- 'Chemical Dependency'
				when cp.concept_name = 'Allergy/Immunology' then 'Allergy/Immunology' 
				when cp.concept_name = 'Ancillary Services' then 'Ancillary Services' 
				when cp.concept_name = 'Anesthesiology' then 'Anesthesiology' 
				when cp.concept_name = 'Sports Medicine' then 'Sports Medicine' 
				when cp.concept_name = 'Audiology' then 'Audiology' 
				when cp.concept_name = 'Osteopathic Manipulative Therapy' then 'Bone And Mineral' -- Bone And Mineral
				when cp.concept_name = 'Cardiology' then 'Cardiology' 
				when cp.concept_name = 'Cardiac Surgery' then 'Cardiovascular Surgery' -- 'Cardiovascular Surgery'
				when cp.concept_name = 'Chiropractic' then 'Chiropractor' -- 'Chiropractor'
				when cp.concept_name = 'Clinical Cardiac Electrophysiology' then 'Clin Cardiac Electrophysiology' -- 'Clin Cardiac Electrophysiology'
				when cp.concept_name = 'Colorectal Surgery' then 'Colon & Rectal Surgery' -- 'Colon & Rectal Surgery'
				when cp.concept_name = 'Complimentary & Alternative Medicine' then 'Complimentary & Alternative Medicine' 
				when cp.concept_name = 'Continuing Care' then 'Continuing Care' 
				when cp.concept_name = 'Critical care (intensivist)' then 'Critical Care' -- Critical Care
				when cp.concept_name = 'Dentistry' then 'Dentistry' 
				when cp.concept_name = 'Dermatology' then 'Dermatology' 
				when cp.concept_name = 'Dor' then 'Dor' 
				when cp.concept_name = 'Medical Education' then 'Medical Education' 
				when cp.concept_name = 'Emergency Medicine' then 'Emergency Medicine' 
				when cp.concept_name = 'Emi' then 'Emergency Medicine' 
				when cp.concept_name = 'Endocrinology' then 'Endocrinology' 
				when cp.concept_name = 'Otolaryngology' then 'Otolaryngology' -- VDW Specs have two of the same specialty with different codes.
				when cp.concept_name = 'Family Practice' then 'Family Medicine' -- 'Family Medicine'
				when cp.concept_name = 'Flexible' then 'Flexible' 
				when cp.concept_name = 'Gastroenterology' then 'Gastroenterology' 
				when cp.concept_name = 'Medical Genetics and Genomics' then 'Genetics' -- Genetics
				when cp.concept_name = 'Geriatric Medicine' then 'Gerontology' -- Gerontology
				when cp.concept_name = 'Hand Surgery' then 'Hand Surgery' 
				when cp.concept_name = 'Home Health Agency' then 'Home Health' -- 'Home Health'
				when cp.concept_name = 'Hospital' then 'Hospital' 
				when cp.concept_name = 'Undersea and Hyperbaric Medicine' then 'Hyperbaric Medicine' -- Hyperbaric Medicine
				when cp.concept_name = 'Hypertension' then 'Hypertension' 
				when cp.concept_name = 'Internal Medicine' then 'General Internal Medicine' -- General Internal Medicine
				when cp.concept_name = 'Infectious Disease' then 'Infectious Disease' 
				when cp.concept_name = 'Laboratory' then 'Laboratory' 
				when cp.concept_name = 'Psychiatry' then 'Mental Health' -- 'Mental Health'
				when cp.concept_name = 'Care Management' then 'Care Management' 
				when cp.concept_name = 'Midlevel' then 'Midlevel' 
				when cp.concept_name = 'Multispecialty' then 'Multispecialty' 
				when cp.concept_name = 'Nephrology' then 'Nephrology' 
				when cp.concept_name = 'Neonatal-Perinatal Medicine' then 'Neonatology' -- Neonatology
				when cp.concept_name = 'Neurosurgery' then 'Neurosurgery' 
				when cp.concept_name = 'Neurotology' then 'Neurology' -- Neurology
				when cp.concept_name = 'No Boards' then 'No Boards' 
				when cp.concept_name = 'Nuclear Medicine' then 'Nuclear Medicine' 
				when cp.concept_name = 'Nurse Practitioner' then 'Nurse' -- Nurse
				when cp.concept_name = 'Nutrition' then 'Nutrition' 
				when cp.concept_name = 'Gynecology/Oncology' then 'Gynecologyic Oncology' -- Gynecologyic Oncology
				when cp.concept_name = 'Obstetrics/Gynecology' then 'Obstetrics - Gynecology' -- Obstetrics - Gynecology
				when cp.concept_name = 'Occupational Therapy' then 'Occupational Health' -- Occupational Health
				when cp.concept_name = 'Oncology' then 'Oncology' 
				when cp.concept_name = 'Surgical Oncology' then 'Surgical Oncology' 
				when cp.concept_name = 'Ophthalmology' then 'Ophthalmology' 
				when cp.concept_name = 'Optician' then 'Optical' -- Optical
				when cp.concept_name = 'Optometry' then 'Optometry' 
				when cp.concept_name = 'Oral Surgery' then 'Oral Surgery' 
				when cp.concept_name = 'Orthodontia' then 'Orthodontia' 
				when cp.concept_name = 'Orthopedic Surgery' then 'Orthopedics' -- Orthopedics
				when cp.concept_name = 'Orthopaedic Sports Medicine' then 'Orthopedics' -- Orthopedics
				when cp.concept_name = 'Otolaryngology' then 'Otolaryngology' 
				when cp.concept_name = 'Pain Management' then 'Pain Management' 
				when cp.concept_name LIKE 'Pathology%' then 'Pathology' 
				when cp.concept_name = 'Pediatrics' then 'Pediatrics' 
				when cp.concept_name LIKE'Pediatric %' then 'Pediatric Subspecialty' -- 'Pediatric Subspecialty'
				when cp.concept_name = 'Perinatology' then 'Perinatology' 
				when cp.concept_name = 'Pharmacy' then 'Pharmacy' 
				when cp.concept_name = 'Physical Therapy' then 'Physical Therapy' 
				when cp.concept_name = 'Physiatry' then 'Physiatry' 
				when cp.concept_name = 'Plastic And Reconstructive Surgery' then 'Plastic Surgery' -- 'Plastic Surgery'
				when cp.concept_name = 'Podiatry' then 'Podiatry' 
				when cp.concept_name = 'Preventive Medicine' then 'Preventive Medicine' 
				when cp.concept_name = 'Prosthodontia' then 'Prosthodontia' 
				when cp.concept_name = 'Psychiatry' then 'Psychiatry' 
				when cp.concept_name = 'Public Health and General Preventive Medicine' then 'Public Health' -- 'Public Health'
				when cp.concept_name = 'Pulmonary Disease' then 'Pulmonary Medicine' -- 'Pulmonary Medicine'
				when cp.concept_name = 'Radiology' then 'Radiology' 
				when cp.concept_name = 'Rehabilitation Agency' then 'Rehabilitation Medicine' -- 'Rehabilitation Medicine'
				when cp.concept_name = 'Respiratory Therapy' then 'Respiratory Therapy' 
				when cp.concept_name = 'Rheumatology' then 'Rheumatology' 
				when cp.concept_name = 'Radiation Oncology' then 'Radiation Oncology' 
				when cp.concept_name = 'Sleep Medicine' then 'Sleep Center'  -- Sleep Center'
				when cp.concept_name = 'Social Services' then 'Social Services' 
				when cp.concept_name = 'Speech Patholgy' then 'Speech Patholgy' 
				when cp.concept_name = 'Surgery' then 'Surgery' 
				when cp.concept_name = 'Teen Clinic' then 'Teen Clinic' 
				when cp.concept_name = 'Medical Toxicology' then 'Medical Toxicology' 
				when cp.concept_name = 'Transportation/Non-Emergency' then 'Transportation/Non-Emergency' 
				when cp.concept_name = 'Transplant Surgery' then 'Transplant Surgery' 
				when cp.concept_name = 'Unknown' then 'Unknown' 
				when cp.concept_name = 'Urgent Care' then 'Urgent Care' 
				when cp.concept_name = 'Urology' then 'Urology' 
				when cp.concept_name = 'Vascular Surgery' then 'Vascular Surgery'
				else ''
			end vdw_cd_desc,
			'SPECIALTY' as vdw_cd_type,
			cp.concept_id as omop_code_id,
			cp.concept_code as omop_code,
			cp.concept_name as omop_cd_desc,
			cp.concept_class_id as omop_cd_type
		from sb_ghri.concept cp
		where cp.concept_class_id = 'Specialty' 
			and cp.standard_concept = 'S' 
			and cp.valid_end_date > CURRENT_DATE
	--	order by cp.concept_name
	) spcty;


create view sb_ghri.zrcm_utl_admit_source as
	select 
		utl.code_id as vdw_code_id, 
		utl.code as vdw_code, 
		utl.code_desc as vdw_cd_desc, 
		utl.code_type as vdw_cd_type, 
		cp.concept_id as omop_code_id,
		cp.concept_code as omop_code,
		cp.concept_name as omop_cd_desc, 
		cp.vocabulary_id as omop_cd_type
	from 
		(select cb.*, 	  	
		case cb.code
			when 'AV' then 17
			when 'ED' then 23
			when 'AF' then 14
			when 'AL' then 13
			when 'HH' then 12
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
		end as omop_code 
		from sb_ghri.vdw_codebucket cb
		where code_type = 'ADMITTING_SOURCE') utl
	left join sb_ghri.concept cp
	on cp.concept_code = utl.omop_code
	where cp.concept_class_id = 'Place of Service'
	and cp.concept_code not like 'OMOP%'
	;



create view sb_ghri.zrcm_dem_ethnicity as
	( select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	  from (select c.*, case when c.code = 'Y' then 'Hispanic' when c.code = 'N' then 'Not Hispanic' end as omop_code from sb_ghri.vdw_codebucket c where lower(c.code_type) = 'hispanic') cb
	  left join sb_ghri.concept cp
	  on cb.omop_code = cp.concept_code
	);


create view sb_ghri.zrcm_dem_race as
(	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from (
		select c.*, 
			case 
				when c.code = 'HP' then 'Native Hawaiian or Other Pacific Islander' 
				when c.code = 'MU' then 'Unknown'
				when c.code = 'BA' then 'Black or African American'
				when c.code = 'AS' then 'Asian'
				when c.code = 'OT' then 'Other Race'
				when c.code = 'IN' then 'American Indian or Alaska Native'
				when c.code = 'UN' then 'Unknown'
				when c.code = 'WH' then 'White'
				else 'Unknown'
			end omop_cd_desc
		from sb_ghri.vdw_codebucket c where lower(c.code_type) = 'race'
	) cb
	left join sb_ghri.concept cp
	on cb.omop_cd_desc = cp.concept_name
	where lower(cp.vocabulary_id) like '%race%'
);



create view sb_ghri.zrcm_dem_sex_admin as
(	select
   		c.code_id as vdw_code_id,
		c.code as vdw_code, 
		c.code_desc as vdw_cd_desc,
		c.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
  	from sb_ghri.vdw_codebucket c
	left join sb_ghri.concept cp
	on c.code = cp.concept_code
	where lower(cp.vocabulary_id) = 'gender'
	and upper(c.code_type) = 'SEX_ADMIN'
);



create view sb_ghri.zrcm_dth_deathtype as
	select distinct 0 as vdw_code_id, vcd.source_list||vcd.causetype as vdw_code, cp.concept_name as vdw_cd_desc, 'death_type' as vdw_cd_type,
	  cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from sb_ghri.concept cp
	inner join
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
			end as omop_concept_id
		from sb_ghri.death dt
		inner join sb_ghri.cod
		on dt.mrn = cod.mrn
	) as vcd
	on vcd.omop_concept_id = cp.concept_id;
;

create table sb_ghri.xwalk_enctype_serplc as (
	select  0 as vdw_code_id, cast(ue.vdw_code as char(5)) as vdw_code, vdw_cd_desc, 'enctype-subtype' as vdw_cd_type, cp.concept_id as omop_code_id,
	  cp.concept_code as omop_code, cp.concept_name as concept_cd_desc, cp.vocabulary_id as omop_cd_type
	from
	( select distinct trim(ent.enctype)||'-'||trim(es.encounter_subtype) as vdw_code, cast(trim(ent.code_desc)||'-'||trim(es.code_desc) as varchar(1200)) as vdw_cd_desc,
		case trim(ent.enctype)||'-'||trim(es.encounter_subtype)
			when 'AV-DI' then '17'
			when 'AV-HA' then '24'
			when 'AV-OB' then '17'
			when 'AV-OC' then '17'
			when 'AV-RH' then '62'
			when 'AV-SD' then '24'
			when 'AV-UC' then '20'
			when 'ED-HA' then '23'
			when 'ED-OC' then '20'
			when 'EM-OT' then '2'
			when 'IP-AI' then '21'
			when 'IS-DI' then '22'
			when 'IS-HS' then '34'
			when 'IS-NH' then '13'
			when 'IS-OT' then '99'
			when 'IS-RH' then '61'
			when 'IS-SN' then '31'
			when 'LO-OC' then '81'
			when 'LO-OT' then '81'
			when 'OE-AI' then '21'
			when 'OE-HH' then '12'
			when 'OE-HS' then '34'
			when 'OE-OT' then '99'
			when 'OE-SN' then '31'
			when 'RO-OC' then '17'
			when 'RO-OT' then '17'
			when 'TE-HH' then '2'
			when 'TE-OT' then '2'
			else '99'
		end as pos
	from (select trim(code) as enctype, code_desc from sb_ghri.vdw_codebucket where code_type = 'enctype') ent,
	  (select trim(code) as encounter_subtype, code_desc from sb_ghri.vdw_codebucket where code_type = 'encounter_subtype') es
	) ue
	left join sb_ghri.concept cp
	on cp.concept_code = ue.pos
	where cp.vocabulary_id = 'Place of Service'
	and cp.concept_code NOT LIKE 'OMOP%'
	) WITH DATA
	;

create view sb_ghri.zrcm_utl_pos as
select * from sb_ghri.xwalk_enctype_serplc;


DROP VIEW sb_ghri.zrcm_px_px;
CREATE VIEW sb_ghri.zrcm_px_px AS
SELECT	cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cb.code_source as vdw_cd_source, 
   cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
FROM	SB_GHRI.vdw_codebucket cb
LEFT JOIN SB_GHRI.concept cp
on cb.code = cp.concept_code
WHERE lower(cb.code_source) like '%procedure%'
;



drop view sb_ghri.zrcm_utl_discharge_status
create view sb_ghri.zrcm_utl_discharge_status as
( 	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from (
	select c.*, 		
		case c.code
			when 'AM' then 12
			when 'AW' then 99
			when 'AF' then 14
			when 'AL' then 13
			when 'EX' then 99
			when 'HH' then 12
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
		end as omop_code
	from sb_ghri.vdw_codebucket c
	where lower(c.code_type) = 'discharge_status'
	) cb
	left join sb_ghri.concept cp
	on cb.omop_code = cp.concept_code
	where lower(cp.vocabulary_id) = 'place of service'
	and cp.concept_code not like 'OMOP%'
);




drop view sb_ghri.zrcm_utl_enctype;
create view sb_ghri.zrcm_utl_enctype as
(	select cb.vdw_code_id, cb.vdw_code, cb.vdw_cd_desc, cb.vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from (
	select c.code_id as vdw_code_id, c.code as vdw_code, c.code_desc as vdw_cd_desc, c.code_type as vdw_cd_type,
		case when c.code = 'IP' then 'IP' 
			when c.code = 'AV' then 'OP'
			when c.code = 'IS' then 'LTCP'
			when c.code = 'ED' then 'ER'
			when c.code = 'EM' then 'ERIP'
			when c.code = 'LO' then 'OP'
			when c.code = 'OE' then 'OP'
			when c.code = 'RO' then 'OP'
			when c.code = 'TE' then 'OP'
		end as omop_code	
	from sb_ghri.vdw_codebucket c
	where lower(c.code_type) = 'enctype'
	) cb
	left join sb_ghri.concept cp
	on cb.omop_code = cp.concept_code
	where lower(cp.vocabulary_id) = 'visit'
);




drop view sb_ghri.zrcm_rx_ndc;
create view sb_ghri.zrcm_rx_ndc as
(	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from sb_ghri.vdw_codebucket cb
	left join sb_ghri.concept cp
	on cb.code = cp.concept_code
	where lower(cb.code_type) = 'ndc'
	and lower(cp.vocabulary_id) = 'ndc'
);

