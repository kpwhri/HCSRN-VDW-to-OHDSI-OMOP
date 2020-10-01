/* This is based on III_CkdPq_eMERGE_LocalValidation_V4_queryTemplate_CU_patientId.sql. The database schema is ohdsi5 and codes are mostly non-OMOP concepts
--Lab: MED vocabulary
--Diagnosis: ICD9/ICD10
--Procedure: CPT4, ICD9, ICD10
*/

/* *** BLOCK 1: Extract relevant data element FROM source data and store a physical database table *** */
IF OBJECT_ID('ckd.CkdAlg_Block1Tmp') IS NOT NULL
	DROP TABLE ckd.CkdAlg_Block1Tmp;
CREATE TABLE ckd.CkdAlg_Block1Tmp (
	person_id numeric(12,0) NOT NULL
	,eventStartDate DATETIME2(6) NOT NULL
	,eventEndDate DATETIME2(6) NULL
	,eventConceptId VARCHAR(50) NOT NULL
	,eventType VARCHAR(100)
	,eventNumValue FLOAT NULL
	,eventStringValue NVARCHAR(100) NULL
);


/** Step 1: retrieve CKD relevant data element **/
/* lab: creatinine, A24, P24, UACR, UPCR */
/* lab units used here
serum creatinine: mg/dL
A24: mg/24hr
P24: mg/24hr
UACR: mg/g Cr (others: 1 ug/mg Cr = 1 mg/g Cr, 1 mcg/mg = 1 mg/g Cr, 1 mg/mg Cr = 1000 mg/g Cr)
UPCR: mg/g Cr (others: 1 mg/mg Cr = 1000 mg/g Cr)
Spot urine albumin: mg/dL
Spot urine protein: mg/dL
Spot urine creatinine: mg/dL
*/

PRINT '';
PRINT 'LabSerumCreatinine';
/* LabSerumCreatinine -- 91 --*/
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabSerumCreatinine' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN 
(
'11041-1', '11042-9', '16188-5', '16189-3', '2160-0', '35203-9', '39955-0', '39956-8', 
'39957-6', '39958-4', '39959-2', '39960-0', '39961-8', '39962-6', '39963-4', '39964-2', 
'39965-9', '39966-7', '39967-5', '39968-3', '39969-1', '39970-9', '39971-7', '39972-5', 
'39973-3', '39974-1', '39975-8', '39976-6', '40248-7', '40249-5', '40250-3', '40251-1', 
'40252-9', '40253-7', '40254-5', '40255-2', '40256-0', '40257-8', '40258-6', '44784-7', 
'54052-6', '57811-2', '67764-1', '72271-0', '74256-9', '38483-4', '44784-7', '59826-8',  
'11041-1', '11042-9', '51619-5', '51620-3' 
) AND value_as_number IS NOT NULL  AND ISNUMERIC(value_as_number) =1

PRINT '';
PRINT 'LabA24';
/* LabA24 -- 0 -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabA24' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('14956-7', '30003-8')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
; 


PRINT '';
PRINT 'LabP24';
/* LabP24 -- 283 -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabP24' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('2889-4', '42482-0')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
; 

PRINT '';
PRINT 'LabUacr';
/* LabUacr -- 8983 if we use the broader UaCR test '14959-1' non-24 hour -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabUacr' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('14958-3', '14959-1')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
; 

PRINT '';
PRINT 'LabUpcr';
/* LabUpcr -- 1074 -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabUpcr' AS eventType
	,value_as_number * 1000 AS eventNumValue /* local data UPCR's unit is mg/mg Cr */
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('13801-6', '2890-2')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1 
; 

PRINT '';
PRINT 'LabSpotUrineAlbumin';
/* LabSpotUrineAlbumin -- 393 --*/
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabSpotUrineAlbumin' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('14957-5', '2161-8')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
; 

PRINT '';
PRINT 'LabSpotUrineProtein';
/* LabSpotUrineProtein -- 1651 -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabSpotUrineProtein' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('2888-6', '21482-5', '35560-2', '5804-0', '35663-4') 
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
; 

PRINT '';
PRINT 'LabSpotUrineCr';
/* LabSpotUrineCr -- 125381 -- */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,measurement_source_concept_id AS eventConceptId
	,'LabSpotUrineCr' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('2161-8')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1 
; 


PRINT '';
PRINT 'LabUaProtein';
/*qualitative urine protein from urine analysis -- 39590 -- UaProtein */
/* For UA protein category of 'Negative','Trace','1+', '2+','3+','4+' */
/* LabUaProtein */
INSERT INTO ckd.CkdAlg_Block1Tmp
SELECT person_id
	,measurement_datetime AS eventStartDate
	, NULL AS eventEndDate
	, measurement_source_concept_id AS eventCocneptId
	,'LabUaProtein' AS eventType
	, NULL AS eventNumValue
	, CASE WHEN value_source_value IN ('NEG','NEG^NEGATIVE','NEGATIVE') THEN 'Negative' 
			WHEN value_source_value IN ('TARCE','TR','TR1^TRACE','TRACE') THEN 'Trace'
			WHEN value_source_value IN ('+1','1+') THEN '1+'
			WHEN value_source_value IN ('+2','2+') THEN '2+'
			WHEN value_source_value IN ('+3','3+') THEN '3+'
			WHEN value_source_value IN ('+4','4+') THEN '4+' END AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('2887-8', '20454-5', '5804-0', '26034-9', '1753-3')
	AND value_source_value IN ('NEGATIVE','1+','TRACE','2+','3+','4+','NEG','+1','TR','+2','+3','NEG^NEGATIVE','TR1^TRACE','+4','TARCE')
; 

PRINT '';
PRINT 'LabUrineSpecificGravity';
/* LabUrineSpecificGravity -- 39 --
select * from omop.measurement WHERE measurement_source_value IN ('5811-5')
*/
INSERT INTO ckd.CkdAlg_Block1Tmp 
SELECT DISTINCT person_id
	,measurement_datetime AS eventStartDate
	,NULL AS eventEndDate
	,0 AS eventConceptId
	,'LabUrineSpecificGravity' AS eventType
	,value_as_number AS eventNumValue
	,NULL AS eventStringValue
FROM omop.measurement
WHERE measurement_source_value IN ('5810-7', '2965-2', '5811-5', '53326-5')
	AND value_as_number IS NOT NULL AND ISNUMERIC(value_as_number) =1
;



