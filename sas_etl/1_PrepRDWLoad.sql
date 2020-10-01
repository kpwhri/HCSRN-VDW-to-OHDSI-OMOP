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

/*
INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (16, 'EMERGE', 'omop', 'concept', 'concept_class_id', 3, 'OMOP', 'Place Of Service');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (16, 'EMERGE', 'omop', 'concept', 'concept_class_id', 3, 'OMOP', 'Specialty');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (16, 'EMERGE', 'omop', 'concept', 'concept_class_id', 1, 'OMOP', 'Gender');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (17, 'EMERGE', 'omop', 'concept', 'concept_class_id', 2, 'OMOP', 'Ethnicity');

INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (16, 'EMERGE', 'omop', 'concept', 'concept_class_id', 4, 'OMOP', 'Race');

--select * from omop.concept where concept_class_id = 'Visit'
INSERT INTO rdw.code_locations
(code_location_id, source_db, source_schema, source_table, source_column, code_line_id, source_system, filter)
VALUES (16, 'EMERGE', 'omop', 'concept', 'concept_class_id', 4, 'OMOP', 'Visit');

*/

