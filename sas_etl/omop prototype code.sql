--CREATE SCHEMA rdw;
--GO

-- Table to store a list of all codes, their type and where they come from
DROP TABLE rdw.code_manager;
GO
CREATE TABLE rdw.code_manager
(
  code_id int not null,
  code varchar(50) null,
  code_desc varchar(255) null,
  code_type varchar(50) not null,
  code_type_desc varchar(255) null,
  source_code_id varchar(255) null,
  source_system varchar(255) not null,
  source_system_desc varchar(500) null
)
;
GO

-- Table to store a list of relationships between either codes or code_types
DROP TABLE rdw.code_relationship;
GO
CREATE TABLE rdw.code_relationship
(
  code_relationship_id int not null,
  code_id_a int null,
  code_id_t int null,
  code_type_g varchar(50) null,
  code_type_c varchar(50) null,
  code_relationship_type varchar(20) not null
)
;
GO

-- table to create a hierarchy of relationships between code_relationships
DROP TABLE rdw.code_hierarchy;
GO
CREATE TABLE rdw.code_hierarchy
(
  code_hierarchy_id int not null,
  code_hierarchy_name varchar(150) not null,
  parent_code_relationship_id int not null,
  child_code_relationship_id int not null,
  code_hierarchy_type varchar(50) not null,
  code_hierarchy_type_desc varchar(500) null
)
;
GO

-- table of the column names that store codes
DROP TABLE rdw.code_locations;
GO
CREATE TABLE rdw.code_locations
(
  code_location_id int not null,
  source_db varchar(50) not null,
  source_schema varchar(50) not null,
  source_column varchar(50) not null,
  code_line_id int not null,
  source_system varchar(200) not null
)
;
GO

-- Terminology that would be meaningful to Physicians and Investigators
DROP TABLE rdw.terminology_manager;
GO
CREATE TABLE rdw.terminology_manager
(
  term_id int not null,
  formal_term varchar(200) not null,
  common_term varchar(200) null,
  standard_source varchar(200) null
)
;
GO

-- Rules used to associate rules to patients
DROP TABLE rdw.rules_manager;
GO
CREATE TABLE rdw.rules_manager
(
  rule_id int not null,
  rule_name varchar(50) not null,
  rule_code varchar(4000) not null
);
GO

DROP TABLE rdw.cohorts;
GO
CREATE TABLE rdw.cohorts
(
  cohort_id int not null,
  cohort_name varchar(32) not null,
  cohort_desc varchar(2000) null
);
GO

-- Ties a cohort to a term and to rules and hierarchies
DROP TABLE rdw.cohort_codes_xwalk;
GO
CREATE TABLE rdw.cohort_codes_xwalk
(
  cohort_id int not null,
  rule_id int not null,
  term_id int not null,
  hierarchy_id int null
);
GO

-- the relationships between a cohort and a patient that are used to build a cohort
DROP TABLE rdw.cohort_manager;
GO
CREATE TABLE rdw.cohort_manager
(
  member_id varchar(30) not null,
  cohort_id int not null,
);
GO


/*************************
*  Prepare RDW Code Translation Tables with VDW Codes
*
* Written By:  John Weeks
* Date:  2/23/2018
********************************/


TRUNCATE TABLE rdw.code_locations;

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (1, 'EMERGE', 'dbo', 'vdw_demographics_em', 'hispanic', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (2, 'EMERGE', 'dbo', 'vdw_demographics_em', 'gender', 2, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (3, 'EMERGE', 'dbo', 'vdw_utilization_em', 'enctype', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (4, 'EMERGE', 'dbo', 'vdw_utilization_em', 'encounter_subtype', 2, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (5, 'EMERGE', 'dbo', 'vdw_utilization_em', 'source', 3, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (6, 'EMERGE', 'dbo', 'vdw_utilization_em', 'source_data', 4, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (7, 'EMERGE', 'dbo', 'vdw_utilization_em', 'admitting_source', 5, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (8, 'EMERGE', 'dbo', 'vdw_utilization_em', 'discharge_status', 6, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (9, 'EMERGE', 'dbo', 'vdw_dx_em', 'dx', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (10, 'EMERGE', 'dbo', 'vdw_procedures_em', 'px', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (11, 'EMERGE', 'dbo', 'vdw_causeofdeath_em', 'causetype', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (12, 'EMERGE', 'dbo', 'vdw_causeofdeath_em', 'cod', 2, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (13, 'EMERGE', 'dbo', 'vdw_death_em', 'source_list', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (14, 'EMERGE', 'dbo', 'vdw_pharmacy_em', 'ndc', 1, 'VDW');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (15, 'EMERGE', 'dbo', 'vdw_labresults_em', 'loinc', 1, 'VDW');


IF OBJECT_ID('dbo.vdw_race_em') is not null drop view dbo.vdw_race_em;
GO
CREATE VIEW dbo.vdw_race_em as
(
SELECT distinct race1 as race from dbo.vdw_demographics_em
union
SELECT distinct race2 as race from dbo.vdw_demographics_em
union
SELECT distinct race3 as race from dbo.vdw_demographics_em
union
SELECT distinct race4 as race from dbo.vdw_demographics_em
union
SELECT distinct race5 as race from dbo.vdw_demographics_em
);
GO

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system)
VALUES (16, 'EMERGE', 'dbo', 'vdw_race_em', 'race', 1, 'VDW');





/*************************
*  Populate Code Translation Tables with VDW Codes
*
* Written By:  John Weeks
* Date:  2/23/2018
********************************/


BEGIN

  DECLARE @schema varchar(30);
  DECLARE @codeTable varchar(35);
  DECLARE @codeCol varchar(35);
  DECLARE @sqlStr varchar(2000);
  DECLARE @codeCnt int;
  DECLARE @index int = 1;

  SET @codeCnt = (SELECT count(*) FROM rdw.code_locations WHERE source_system = 'VDW');
  WHILE @index <= @codeCnt 
  BEGIN
    SET @schema = (select source_schema from rdw.code_locations where code_location_id = @index);
    SET @codeTable = (select source_table from rdw.code_locations where code_location_id = @index);
    SET @codeCol = (select source_column from rdw.code_locations where code_location_id = @index);

    SET @sqlStr = 'INSERT INTO rdw.code_manager 
    SELECT mxCntCd.cntStart+row_number() over (order by '+@codeCol+') as [code_id]
      ,'+@codeCol+' as [code]
      ,NULL as [code_desc]
      ,'''+@codeCol+''' as [code_type]
      ,NULL as [code_type_desc]
      ,'+@codeCol+' as [source_code_id]
      ,''VDW'' as [source_system]
      ,''Virtual Data Warehouse'' as [source_system_desc]
    FROM 
      (SELECT coalesce(max(code_id)+1, 0) as cntStart from rdw.code_manager) mxCntCd,
      (SELECT DISTINCT '+@codeCol+' from '+@schema+'.'+@codeTable+') dm';

    EXECUTE (@sqlStr);
    SET @index = @index + 1;
  END
END



-- INSERTS Lab Result Test Type into RDW code manager.
DELETE FROM rdw.code_manager WHERE code_type = 'Lab Test Type';
INSERT INTO rdw.code_manager
select 
  mxCntCd.cntStart+row_number() over (order by lr.test_type) as [code_id]
  , lr.test_type as [code]
  , NULL as [code_desc]
  , 'Lab Test Type' as [code_type]
  , 'Type of Lab Performed' as [code_type_desc]
  , lr.test_type as [source_code_id]
  , 'VDW' as [source_system]
  , 'Virtual Data Warehouse' as [source_system_desc]
from (select distinct test_type from dbo.vdw_labresults_fin where test_type <> '') lr
  , (SELECT coalesce(max(code_id)+1, 0) as cntStart from rdw.code_manager) mxCntCd
;






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



  -- Visit Type
  if OBJECT_ID('omop.vdw_lkup_visit_type') is not null drop view omop.vdw_lkup_visit_type;
  GO
  create view omop.vdw_lkup_visit_type as
  select distinct cp.*, ut.[source] as vdw_ute_source, ut.source_data as vdw_ute_source_data
  from 
  ( select distinct [source], [source_data],
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
  ( select distinct px from dbo.vdw_procedures_em
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
--  and lr.lab_tm is not null
  and ltrim(rtrim(lr.lab_dt)) <> 'NULL'
  ;
  GO




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

