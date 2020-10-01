create table sb_ghri.ztemp_px_codes as (
SELECT distinct px.px, px_codetype
FROM	sb_ghri.px px
) with data

select count(*) from sb_ghri.ztemp_px_codes; -- 38462

select zps.px as code, zps.px_codetype as code_type, oct.concept_name as code_desc, oct.vocabulary_id as omop_code_type, oct.concept_class_id as omop_class, oct.domain_id as omop_domain
from sb_ghri.ztemp_px_codes zps
left join sb_ghri.concept oct
on zps.px = oct.concept_code
and oct.vocabulary_id <> 'RxNorm'
and oct.vocabulary_id <> 'OSM'

UPDATE sb_ghri.concept FROM (select code, code_desc from sb_ghri.vdw_codebucket where code_type = 'C4') cpt
SET concept_name = cpt.code_desc
WHERE concept_code = cpt.code
and vocabulary_id = 'CPT4'

DELETE from sb_ghri.vdw_codebucket where code_source like 'VDW-PX%'


INSERT INTO sb_ghri.vdw_codebucket
SELECT upx.code_id, upx.code, upx.code_desc, upx.code_type, upx.code_source
FROM
(
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'H4'
and cpt.vocabulary_id like '%HCPCS%'
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = '10'
and cpt.vocabulary_id like '%ICD10PCS%'
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = '09'
and cpt.vocabulary_id like '%ICD9Proc%'
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'C4'
and cpt.vocabulary_id like '%CPT4%'
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'RV'
and cpt.vocabulary_id like '%Revenue%'
) upx

INSERT INTO sb_ghri.vdw_codebucket
SELECT upx.code_id, upx.code, upx.code_desc, upx.code_type, upx.code_source
FROM
(
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'H4'
--and cpt.vocabulary_id like '%HCPCS%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = 'H4')
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = '10'
--and cpt.vocabulary_id like '%ICD%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = '10')
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = '09'
--and cpt.vocabulary_id like '%ICD9%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = '09')
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'C4'
and cpt.domain_id like '%Proc%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = 'C4')
UNION
SELECT mid.maxid + row_number() over ( order by cpt.concept_id ) as code_id, zpx.px as code, 
  cpt.concept_name as code_desc, zpx.px_codetype as code_type, 'VDW-PX and OMOP ' || cpt.vocabulary_id as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
inner join sb_ghri.concept cpt
on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'RV'
--and cpt.vocabulary_id like '%Revenue%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = 'RV')
) upx


INSERT INTO sb_ghri.vdw_codebucket
SELECT mid.maxid + row_number() over ( order by zpx.px ) as code_id, zpx.px as code, 
  '' as code_desc, zpx.px_codetype as code_type, 'VDW-PX' as code_source
FROM (select max(code_id) as maxid from sb_ghri.vdw_codebucket) mid, 
sb_ghri.ztemp_px_codes zpx
--inner join sb_ghri.concept cpt
--on cpt.concept_code = zpx.px
WHERE zpx.px_codetype = 'LO'
--and cpt.domain_id like '%Proc%'
and zpx.px not in (select code from sb_ghri.vdw_codebucket where code_type = 'LO')









select count(*) from sb_ghri.vdw_codebucket where code_source like 'VDW-PX%'
select count(*) from sb_ghri.ztemp_px_codes zpc

select code, code_type from sb_ghri.vdw_codebucket where code_type in ('10', '09', 'H4', 'C4', 'RV')
intersect
select zpc.px as code, zpc.px_codetype as code_type  
from sb_ghri.ztemp_px_codes zpc
left join sb_ghri.vdw_codebucket vcb
on zpc.px = vcb.code
and zpc.px_codetype = vcb.code_type
where vcb.code is null
or vcb.code_type is null
