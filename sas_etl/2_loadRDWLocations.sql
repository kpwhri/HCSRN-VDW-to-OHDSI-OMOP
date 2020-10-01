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




/*
select * from rdw.code_manager
TRUNCATE table rdw.code_manager
INSERT INTO rdw.code_manager 
	SELECT mxCntCd.cntStart+row_number() over (order by hispanic) as [code_id]
		,hispanic as [code]
		,NULL as [code_desc]
		,'hispanic' as [code_type]
		,NULL as [code_type_desc]
		,hispanic as [source_code_id]
		,'VDW' as [source_system]
		,'Virtual Data Warehouse' as [source_system_desc]
	FROM 
		(SELECT coalesce(max(code_id)+1, 0) as cntStart from rdw.code_manager) mxCntCd,
		(SELECT DISTINCT hispanic from dbo.vdw_demographics_em) dm

-- dbo.vdw_demographics_em (hispanic, gender)
-- dbo.vdw_utilization_em (enctype, source, admitting_source, discharge_status)
-- dbo.vdw_dx_em (dx, 
-- dbo.vdw_procedures_em (px, 
-- dbo.vdw_causeofdeath_em (cod, causetype
-- dbo.vdw_death_em (source_list
-- dbo.vdw_pharmacy_em (ndc
-- dbo.vdw_labresults_em (loinc
*/