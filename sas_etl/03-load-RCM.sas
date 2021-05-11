/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Builds RCM Code Views
* Date Created:: 2020-10-01
*********************************************/


* mappings for codetypes between vdw and omop;
proc sql;
create table dat.vdw_codebucket_types as
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
	when vcb.code_type = 'ENCTYPE' then 'Visit'
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
from dat.vdw_codebucket vcb
left join (select distinct vocabulary_id as omop_vocabulary, domain_id as omop_domain from vocab.concept) omp
on vcb.code_type = omp.omop_vocabulary
where vcb.code_type <> 'code_type'
  )
  ;
quit;


* maps encounter type to visit type;
proc sql;
  create table dat.rcm_utl_enctype as
    select cb.vdw_code_id, cb.vdw_code, cb.vdw_cd_desc, cb.vdw_cd_type,
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
	from dat.vdw_codebucket c
	where lower(c.code_type) = 'enctype'
	) cb
	left join vocab.concept cp
	on cb.omop_code = cp.concept_code
    where lower(cp.vocabulary_id) = 'visit'
    ;
quit;


* maps discharge status to place of service;
proc sql;
create table dat.rcm_utl_discharge_status as
	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from (
	select c.*, 		
		case c.code
			when 'AM' then '12'
			when 'AW' then '99'
			when 'AF' then '14'
			when 'AL' then '13'
			when 'EX' then '99'
			when 'HH' then '12'
			when 'HS' then '34'
			when 'HO' then '12'
			when 'IP' then '21'
			when 'NH' then '54'
			when 'OT' then '99'
			when 'RS' then '13'
			when 'RH' then '62'
			when 'SN' then '31'
			when 'SH' then '21'
			when 'UN' then '10'
			else '10'
		end as omop_code
	from dat.vdw_codebucket c
	where lower(c.code_type) = 'discharge_status'
	) cb
	left join vocab.concept cp
	on cb.omop_code = cp.concept_code
	where lower(cp.vocabulary_id) = 'place of service'
  and cp.concept_code not like 'OMOP%'
  ;
quit;


* maps admit source to place of service;
proc sql;
create table dat.rcm_utl_admit_source as
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
			when 'AV' then '17'
			when 'ED' then '23'
			when 'AF' then '14'
			when 'AL' then '13'
			when 'HH' then '12'
			when 'HS' then '34'
			when 'HO' then '12'
			when 'IP' then '21'
			when 'NH' then '54'
			when 'OT' then '99'
			when 'RS' then '13'
			when 'RH' then '62'
			when 'SN' then '31'
			when 'UN' then '10'
			else '10'
		end as omop_code 
		from dat.vdw_codebucket cb
		where code_type = 'ADMITTING_SOURCE') utl
	left join vocab.concept cp
	on cp.concept_code = utl.omop_code
	where cp.concept_class_id = 'Place of Service'
	and cp.concept_code not like 'OMOP%'
	;
quit;


* maps vdw px codes to omop procedure codes;
proc sql;
  create table dat.rcm_px_px AS
  SELECT	cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cb.code_source as vdw_cd_source, 
     cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
  FROM	dat.vdw_codebucket cb
  LEFT JOIN vocab.concept cp
  on cb.code = cp.concept_code
  WHERE lower(cb.code_source) like '%procedure%'
    ;
quit;


* maps vdw loinc codes to omop loinc codes;
proc sql;
  create table dat.rcm_lab_loinc as 
	select lr.code_id as vdw_code_id, lr.code as vdw_code, lr.code_desc as vdw_cd_desc, lr.code_type as vdw_cd_type,
	  cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from dat.vdw_codebucket lr
	left join vocab.concept cp
	on cp.concept_code = lr.code
	where cp.vocabulary_id = 'LOINC'
    and lower(lr.code_type) = 'loinc'
    ;
quit;


* maps vdw ethnicity to omop Hispanic;
proc sql;
  create table dat.rcm_dem_ethnicity as
	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	 from (select c.*, case when c.code = 'Y' then 'Hispanic' when c.code = 'N' then 'Not Hispanic' end as omop_code from dat.vdw_codebucket c where lower(c.code_type) = 'hispanic') cb
	 left join vocab.concept cp
	 on cb.omop_code = cp.concept_code
    ;
quit;


* maps vdw race to omop race;
proc sql;
  create table dat.rcm_dem_race as
	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
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
			end as omop_cd_desc
		from dat.vdw_codebucket c where lower(c.code_type) = 'race'
	) cb
	left join vocab.concept cp
	on cb.omop_cd_desc = cp.concept_name
	where lower(cp.vocabulary_id) like '%race%'
;
quit;


* maps vdw sex_admin to omop gender;
proc sql;
  create table dat.rcm_dem_sex_admin as
  select distinct 
	   0 as vdw_code_id,
	   dem.code as vdw_code, 
	   dem.code_desc as vdw_cd_desc,
	   dem.code_type as vdw_cd_type,
          cp.concept_id as omop_code_id,
          cp.concept_code as omop_code,
	        cp.concept_name as omop_cd_desc,
	        cp.vocabulary_id as omop_cd_type 
	  from vocab.concept cp
	  left join dat.vdw_codebucket dem
	  on cp.concept_code = upper(dem.code)
	  where upper(dem.code_type) = 'SEX_ADMIN'
	  and cp.vocabulary_id = 'Gender'
	;
quit;


* maps vdw provider specialty to omop specialty;
proc sql;
  create table dat.rcm_prv_specialty as
    select cbt.code_id as vdw_code_id, cbt.code as vdw_code, cbt.code_desc as vdw_cd_desc, cbt.code_type as vdw_cd_type, cn.concept_id as omop_code_id, cn.concept_code as omop_code, cn.concept_name as omop_cd_desc, cn.vocabulary_id as omop_cd_type
    from dat.vdw_codebucket cbt
    left join (
  select 
    cp.concept_id as omop_code_id,
			case 
				when cp.concept_name = 'Adolescent Medicine' then 'ADO' 
				when cp.concept_name = 'Aerospace Medicine' then 'AER' 
				when cp.concept_name = 'Psychology' then 'ALC'
				when cp.concept_name = 'Allergy/Immunology' then 'ALL' 
				when cp.concept_name = 'Ancillary Services' then 'ANC' 
				when cp.concept_name = 'Anesthesiology' then 'ANE' 
				when cp.concept_name = 'Sports Medicine' then 'ATH' 
				when cp.concept_name = 'Audiology' then 'AUD' 
				when cp.concept_name = 'Osteopathic Manipulative Therapy' then 'BON' 
				when cp.concept_name = 'Cardiology' then 'CAR' 
				when cp.concept_name = 'Cardiac Surgery' then 'CAV'
				when cp.concept_name = 'Chiropractic' then 'CHR'
				when cp.concept_name = 'Clinical Cardiac Electrophysiology' then 'CLC'
				when cp.concept_name = 'Colorectal Surgery' then 'COL'
				when cp.concept_name = 'Complimentary & Alternative Medicine' then 'COM' 
				when cp.concept_name = 'Continuing Care' then 'CON' 
				when cp.concept_name = 'Critical care (intensivist)' then 'CRI'
				when cp.concept_name = 'Dentistry' then 'DEN' 
				when cp.concept_name = 'Dermatology' then 'DER' 
				when cp.concept_name = 'Dor' then 'DOR' 
				when cp.concept_name = 'Medical Education' then 'EDU' 
				when cp.concept_name = 'Emergency Medicine' then 'EME' 
				when cp.concept_name = 'Emi' then 'EMI' 
				when cp.concept_name = 'Endocrinology' then 'END' 
				when cp.concept_name = 'Otolaryngology' then 'ENT' 
				when cp.concept_name = 'Family Practice' then 'FAM'
				when cp.concept_name = 'Flexible' then 'FLX' 
				when cp.concept_name = 'Gastroenterology' then 'GAS' 
				when cp.concept_name = 'Medical Genetics and Genomics' then 'GEN'
				when cp.concept_name = 'Geriatric Medicine' then 'GER'
				when cp.concept_name = 'Hand Surgery' then 'HAN' 
				when cp.concept_name = 'Home Health Agency' then 'HOM'
				when cp.concept_name = 'Hospital' then 'HOS' 
				when cp.concept_name = 'Undersea and Hyperbaric Medicine' then 'HYM'
				when cp.concept_name = 'Hypertension' then 'HYP' 
				when cp.concept_name = 'Internal Medicine' then 'IMG'
				when cp.concept_name = 'Infectious Disease' then 'INF' 
				when cp.concept_name = 'Laboratory' then 'LAB' 
				when cp.concept_name = 'Psychiatry' then 'MEN'
				when cp.concept_name = 'Care Management' then 'MGM' 
				when cp.concept_name = 'Midlevel' then 'MID' 
				when cp.concept_name = 'Multispecialty' then 'MUL' 
				when cp.concept_name = 'Nephrology' then 'NEH' 
				when cp.concept_name = 'Neonatal-Perinatal Medicine' then 'NEO'
				when cp.concept_name = 'Neurosurgery' then 'NES' 
				when cp.concept_name = 'Neurotology' then 'NEU'
				when cp.concept_name = 'No Boards' then 'NOB' 
				when cp.concept_name = 'Nuclear Medicine' then 'NUM' 
				when cp.concept_name = 'Nurse Practitioner' then 'NUR' 
				when cp.concept_name = 'Nutrition' then 'NUT' 
				when cp.concept_name = 'Gynecology/Oncology' then 'OBO'
				when cp.concept_name = 'Obstetrics/Gynecology' then 'OBS'
				when cp.concept_name = 'Occupational Therapy' then 'OCM'
				when cp.concept_name = 'Oncology' then 'ONC' 
				when cp.concept_name = 'Surgical Oncology' then 'ONS' 
				when cp.concept_name = 'Ophthalmology' then 'OPH' 
				when cp.concept_name = 'Optician' then 'OPL'
				when cp.concept_name = 'Optometry' then 'OPT' 
				when cp.concept_name = 'Oral Surgery' then 'ORA' 
				when cp.concept_name = 'Orthodontia' then 'ORD' 
				when cp.concept_name = 'Orthopedic Surgery' then 'ORT'
				when cp.concept_name = 'Orthopaedic Sports Medicine' then 'ORT'
				when cp.concept_name = 'Otolaryngology' then 'OTO' 
				when cp.concept_name = 'Pain Management' then 'PAI' 
				when cp.concept_name LIKE 'Pathology%' then 'PAT' 
				when cp.concept_name = 'Pediatrics' then 'PED' 
				when cp.concept_name LIKE'Pediatric %' then 'PES'
				when cp.concept_name = 'Perinatology' then 'PEY' 
				when cp.concept_name = 'Pharmacy' then 'PHA' 
				when cp.concept_name = 'Physical Therapy' then 'PHT' 
				when cp.concept_name = 'Physiatry' then 'PHY' 
				when cp.concept_name = 'Plastic And Reconstructive Surgery' then 'PLA'
				when cp.concept_name = 'Podiatry' then 'POD' 
				when cp.concept_name = 'Preventive Medicine' then 'PRE' 
				when cp.concept_name = 'Prosthodontia' then 'PRO' 
				when cp.concept_name = 'Psychiatry' then 'PSY' 
				when cp.concept_name = 'Public Health and General Preventive Medicine' then 'PUB'
				when cp.concept_name = 'Pulmonary Disease' then 'PUL'
				when cp.concept_name = 'Radiology' then 'RAD' 
				when cp.concept_name = 'Rehabilitation Agency' then 'REH'
				when cp.concept_name = 'Respiratory Therapy' then 'RES' 
				when cp.concept_name = 'Rheumatology' then 'RHE' 
				when cp.concept_name = 'Radiation Oncology' then 'ROP' 
				when cp.concept_name = 'Sleep Medicine' then 'SLC'
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
			end as vdw_code
    from vocab.concept cp
    	where lower(cp.vocabulary_id) = 'specialty'
  ) cpt
    on cbt.code = cpt.vdw_code
    left join vocab.concept cn
    on cpt.omop_code_id = cn.concept_id
		where lower(cbt.code_type) = 'specialty'
			and cn.standard_concept = 'S'  
			and input(cn.valid_end_date, anydtdte.) > today() 
;
quit;


* map vdw ndc codes to omop ndc codes;
proc sql;
create table dat.rcm_rx_ndc as
	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from dat.vdw_codebucket cb
	left join vocab.concept cp
	on cb.code = cp.concept_code
	where lower(cb.code_type) = 'ndc'
	and lower(cp.vocabulary_id) = 'ndc'
;
quit;


* map vdw dx to omop dx;
proc sql;
  create table dat.rcm_dx_dx as
  SELECT cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cb.code_source as vdw_cd_source, 
   cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
  FROM	dat.vdw_codebucket cb
  INNER JOIN vocab.concept cp
  on cb.code = cp.concept_code
    WHERE lower(cb.code_source) = 'omop_diagnosis'
    or lower(cb.code_source) = 'omop_observation'
    ;
quit;


* map vdw death cause to omop dx;
proc sql;
  create table dat.rcm_cod_cod as
  SELECT	cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type, cb.code_source as vdw_cd_source, 
   cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
  FROM dat.vdw_codebucket cb
  INNER JOIN vocab.concept cp
  on cb.code = cp.concept_code
  where lower(cb.code_source) = 'omop_diagnosis'
    ;
quit;


* maps vdw death type to omop concept;
proc sql;
  create table dat.rcm_dth_deathtype as
	select   vcd.vdw_code_id, vcd.vdw_code, vcd.vdw_cd_desc, vcd.vdw_cd_type,
	  cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from vocab.concept cp
    join
    ( select vd.*,
        case 
				  when vd.vdw_code = 'I_B' then 261
				  when vd.vdw_code = 'I_N' then 242
				  when vd.vdw_code = 'I_S' then 242
				  when vd.vdw_code = 'I_T' then 254
				  when vd.vdw_code = 'I_E' then 254
				  when vd.vdw_code = 'I_P' then 254
				  when vd.vdw_code = 'I_M' then 254
				  when vd.vdw_code = 'U_B' then 261
				  when vd.vdw_code = 'U_N' then 242
				  when vd.vdw_code = 'U_S' then 242
				  when vd.vdw_code = 'U_T' then 256
				  when vd.vdw_code = 'U_E' then 256
				  when vd.vdw_code = 'U_P' then 256
				  when vd.vdw_code = 'U_M' then 256
				  when vd.vdw_code = 'C_B' then 261
				  when vd.vdw_code = 'C_N' then 242
				  when vd.vdw_code = 'C_S' then 242
				  when vd.vdw_code = 'C_T' then 255
				  when vd.vdw_code = 'C_E' then 255
				  when vd.vdw_code = 'C_P' then 255
				  when vd.vdw_code = 'C_M' then 255
        end as omop_concept_id
      from  
      ( select distinct put(ce.code_id, 5.)||'_'||put(sl.code_id, 5.) as vdw_code_id, trim(ce.code)||'_'||sl.code as vdw_code,
          ce.code_desc||'_-_'||sl.code_desc as vdw_cd_desc, ce.code_type||'_-_'||sl.code_type as vdw_cd_type,
      ce.code_source||'_-_'||sl.code_source as vdw_cd_source
      from
        ( select * from dat.vdw_codebucket where lower(code_type) = 'causetype' ) ce,
        ( select * from dat.vdw_codebucket where lower(code_type) = 'source_list' ) sl
      ) as vd
    ) as vcd
	on vcd.omop_concept_id = cp.concept_id
;
quit;



proc sql;
  create table dat.rcm_utl_pos as
    select ue.vdw_code, ue.vdw_desc, 'ENCTYPE_ENCOUNTER_SUBTYPE' as vdw_code_type, cp.concept_id as omop_code_id,
    cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type, ue.enctype,
    ue.enc_desc as enctype_desc, ue.encounter_subtype, ue.sub_desc as enc_subtype_desc
  from
    ( select enc.enctype, enc.enc_desc, sub.encounter_subtype, sub.sub_desc,
        enc.enctype||'_'||sub.encounter_subtype as vdw_code, 
        enc.enc_desc||'_'||sub.sub_desc as vdw_desc, 
          case enc.enctype||'_'||sub.encounter_subtype 
          when 'AV_DI' then '17'
          when 'AV_HA' then '24'
          when 'AV_OB' then '17'
          when 'AV_OC' then '17'
          when 'AV_RH' then '62'
          when 'AV_SD' then '24'
          when 'AV_UC' then '20'
          when 'ED_HA' then '23'
          when 'ED_OC' then '20'
          when 'EM_OT' then '2'
          when 'IP_AI' then '21'
          when 'IS_DI' then '22'
          when 'IS_HS' then '34'
          when 'IS_NH' then '13'
          when 'IS_OT' then '99'
          when 'IS_RH' then '61'
          when 'IS_SN' then '31'
          when 'LO_OC' then '81'
          when 'LO_OT' then '81'
          when 'OE_AI' then '21'
          when 'OE_HH' then '12'
          when 'OE_HS' then '34'
          when 'OE_OT' then '99'
          when 'OE_SN' then '31'
          when 'RO_OC' then '17'
          when 'RO_OT' then '17'
          when 'TE_HH' then '2'
          when 'TE_OT' then '2'
          else '99'
        end as pos
    from
    ( select put(code, $2.) as enctype, code_desc as enc_desc
      from dat.vdw_codebucket where code_type = 'ENCTYPE') enc,
    ( select put(code, $2.) as encounter_subtype, code_desc as sub_desc
      from dat.vdw_codebucket where code_type = 'ENCOUNTER_SUBTYPE') sub
    ) ue
	left join vocab.concept cp
	on ue.pos = cp.concept_code
	where lower(cp.vocabulary_id) = 'place of service'
  and cp.concept_code not like 'OMOP%'
    ;
quit;


