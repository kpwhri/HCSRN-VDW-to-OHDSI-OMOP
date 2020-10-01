select distinct domain_id from sb_ghri.concept where concept_class_id like 'ICD9%' 

select cpt.* from sb_ghri.concept cpt,
(
select	distinct concept_code as code 
from	sb_ghri.concept 
where	domain_id = 'Procedure'  
and vocabulary_id <> 'ICD10PCS'
and vocabulary_id <> 'SNOMED'
minus
select	distinct code 
from	sb_ghri.vdw_codebucket 
where	code_type = '09' 
) cds
where cpt.concept_code = cds.code

-- 0
select	distinct concept_code as code 
from	sb_ghri.concept 
where	vocabulary_id = 'ICD9Proc'
minus
select	distinct code 
from	sb_ghri.vdw_codebucket 
where	code_type = '09'

-- 69149
select	distinct concept_code as code 
from	sb_ghri.concept 
where	concept_class_id = 'ICD10PCS'
minus
select	distinct code 
from	sb_ghri.vdw_codebucket 
where	code_type = '10'

select	* 
from	sb_ghri.vdw_codebucket 
where	code_type like 'ICD10%'

insert into sb_ghri.vdw_codebucket  
select	rws.rowcnt + row_number() over (
order by cpts.concept_id) as code_id, cpts.code, cpts.code_desc,
		cpts.code_type, cpts.code_source
from	(
	select	max(code_id) as rowcnt 
	from	sb_ghri.vdw_codebucket) rws,
(
	select	cpt.concept_id, cpt.concept_code as code, cpt.concept_name as code_desc,
			'09' as code_type, 'ICD9PCS' as code_source
	from	(
		select	concept_code as code 
		from	sb_ghri.concept 
		where	vocabulary_id = 'ICD9Proc'
		minus
		select	distinct code 
		from	sb_ghri.vdw_codebucket 
		where	code_type = '09'
	) miss
	inner join sb_ghri.concept cpt 
		on miss.code = cpt.concept_code) cpts


