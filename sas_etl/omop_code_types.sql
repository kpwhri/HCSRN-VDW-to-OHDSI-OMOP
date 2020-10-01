create table sb_ghri.omop_code_types as 
select distinct cot.vocabulary_id as omop_vocabulary, cot.domain_id as omop_domain, cot.concept_class_id as omop_class 
from sb_ghri.concept cot
;
/*
select vct.code_type as vcb_code_type, vct.code_source as vcb_code_source, 
  cot.vocabulary_id as omop_vocabulary, cot.domain_id as omop_domain, cot.concept_class_id as omop_class, 
  xcf."table_name" as vdw_table, xcf.field_name as vdw_field 
from sb_ghri.vdw_codebucket vct 
inner join sb_ghri.concept cot
on vct.code_type = cot.vocabulary_id
inner join sb_ghri.xlkup_codetype2field xcf
on vct.code_type = xcf.code_type
;
*/