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

