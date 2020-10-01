create table sb_ghri.xlkup_code_types as
(
select distinct vct.*, oct.*, xcf."table_name" as vdw_table, xcf.field_name as vdw_field
from sb_ghri.vdw_codebucket_types vct
left join sb_ghri.omop_code_types oct
on vct.vcb_code_type = oct.omop_vocabulary
left join sb_ghri.xlkup_codetype2field xcf
on vct.vcb_code_type = xcf.code_type
) with data
;

update sb_ghri.xlkup_code_types from (select omop_vocabulary, omop_domain, omop_class from sb_ghri.omop_code_types where omop_vocabulary = 'ICD10PCS' and omop_class = 'ICD10PCS') oct 
set omop_vocabulary = oct.omop_vocabulary, omop_domain = oct.omop_domain, omop_class = oct.omop_class 
where vcb_code_type = '10'
;

update sb_ghri.xlkup_code_types from (select omop_vocabulary, omop_domain, omop_class from sb_ghri.omop_code_types where omop_vocabulary = 'ICD9Proc' and omop_class = 'Procedure') oct 
set omop_vocabulary = oct.omop_vocabulary, omop_domain = oct.omop_domain, omop_class = oct.omop_class 
where vcb_code_type = '09'
;

update sb_ghri.xlkup_code_types from (select omop_vocabulary, omop_domain, omop_class from sb_ghri.omop_code_types where omop_vocabulary = 'CPT4' and omop_domain = 'Procedure' and omop_class = 'CPT4') oct 
set omop_vocabulary = oct.omop_vocabulary, omop_domain = oct.omop_domain, omop_class = oct.omop_class 
where vcb_code_type = 'C4'
;

update sb_ghri.xlkup_code_types from (select omop_vocabulary, omop_domain, omop_class from sb_ghri.omop_code_types where omop_vocabulary = 'HCPCS' and omop_domain = 'Procedure' and omop_class = 'HCPCS') oct 
set omop_vocabulary = oct.omop_vocabulary, omop_domain = oct.omop_domain, omop_class = oct.omop_class 
where vcb_code_type = 'H4'
;

