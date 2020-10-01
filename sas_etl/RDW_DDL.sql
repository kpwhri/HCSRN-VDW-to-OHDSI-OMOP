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
  code_cnt int not null,
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
