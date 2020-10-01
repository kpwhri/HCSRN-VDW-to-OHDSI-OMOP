/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [payer_plan_period_id]
      ,[person_id]
      ,[payer_plan_period_start_date]
      ,[payer_plan_period_end_date]
      ,[payer_source_value]
      ,[plan_source_value]
      ,[family_source_value]
  FROM [EMERGE].[omop].[payer_plan_period]


  SELECT ppp.p_id+row_number() over (order by enr.mrn, current_timestamp) as payer_plan_period_id, pr.person_id, enr.enr_start as [payer_plan_period_start_date],
	enr.enr_end as [payer_plan_period_end_date], enr.mrn as [payer_source_value],
	'' as [plan_source_value], '' as [family_source_value]
  FROM (select coalesce(max(payer_plan_period_id), 0) as p_id from omop.payer_plan_period) as ppp, dbo.vdw_enrollment_em enr, omop.person pr
  WHERE pr.person_source_value = enr.mrn