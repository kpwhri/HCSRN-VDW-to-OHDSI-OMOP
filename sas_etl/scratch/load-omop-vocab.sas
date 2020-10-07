/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Load the CSV files produced by OHDSI Athena
* Date Created:: 2020-01-22
*********************************************/

/* remove in production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";

/* leave in */
%include "&GHRIDW_ROOT./management/OfflineData/DataWarehouseMgt/StdVars_Write.sas";
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_OMOP.sas";

%let root=\\home.ghc.org\home$\weekjm1\RCM\vocab\;
libname vcb "&root.";

/* Grab Data from Athena CSV downloads */

data vcb.concept_temp;
  infile "&root.CONCEPT.csv" dsd dlm='09'x firstobs=2;
  input concept_id :11. concept_name :$255. domain_id :$20. vocabulary_id :$20. concept_class_id :$20. standard_concept :$1. concept_code :$50. valid_start_date :$10. valid_end_date :$10. invalid_reason :$1. ;
  output;
run;

data vcb.concept_ancestor_temp;
  infile "&root.CONCEPT_ANCESTOR.csv" dsd dlm='09'x firstobs=2;
  input ancestor_concept_id :11. descendant_concept_id :11. min_levels_of_separation :11. max_levels_of_separation :11. ;
  output;
run;

data vcb.concept_class_temp;
  infile "&root.CONCEPT_CLASS.csv" dsd dlm='09'x firstobs=2;
  input concept_class_id :$20. concept_class_name :$255. concept_class_concept_id :11. ;
  output;
run;

data vcb.concept_relationship_temp;
  infile "&root.CONCEPT_RELATIONSHIP.csv" dsd dlm='09'x firstobs=2;
  input concept_id_1 :11. concept_id_2 :11. relationship_id :$20. valid_start_date :$10. valid_end_date :$10. invalid_reason :$1. ;
  output;
run;

data vcb.concept_synonym_temp;
  infile "&root.CONCEPT_SYNONYM.csv" dsd dlm='09'x firstobs=2;
  input concept_id :11. concept_synonym_name :$1000. language_concept_id :11. ;
  output;
run;

data vcb.domain_temp;
  infile "&root.DOMAIN.csv" dsd dlm='09'x firstobs=2;
  input domain_id :$20. domain_name :$255. domain_concept_id :11. ;
  output;
run;

data vcb.drug_strength_temp;
  infile "&root.DRUG_STRENGTH.csv" dsd dlm='09'x firstobs=2;
  input drug_concept_id :11. ingredient_concept_id :11. amount_value :11. amount_unit_concept_id :11. numerator_value :11. numerator_unit_concept_id :11. denominator_value :11. denominator_unit_concept_id :11. box_size :11. valid_start_date :$10. valid_end_date :$10. invalid_reason :1. ;
  output;
run;

data vcb.relationship_temp;
  infile "&root.RELATIONSHIP.csv" dsd dlm='09'x firstobs=2;
  input relationship_id :$20. relationship_name :$255. is_hierarchical :$1. defines_ancestry :$1. reverse_relationship_id :$20. relationship_concept_id :11. ;
  output;
run;

data vcb.vocabulary_temp;
  infile "&root.VOCABULARY.csv" dsd dlm='09'x firstobs=2;
  input vocabulary_id :$20. vocabulary_name :$255. vocabulary_reference :$255. vocabulary_version :$255. vocabulary_concept_id :11. ;
  output;
run;


/* Process and Load New Concepts into Concept table */
proc sql;
  create table vcb.concept_in as
    select ctp.*
    from vcb.concept_temp ctp
    left outer join &_omop_concept oct
    on ctp.concept_id = oct.concept_id
    where oct.concept_id is null;
quit;

proc sql;
  create table __tdvdw.into_concept(FASTLOAD=yes) as select * from vcb.concept_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.concept select * from sb_ghri.into_concept) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;

/* Process and Load New Concept_ancestor records into Concept_ancestor table */
proc sql;
  create table vcb.concept_ancestor_in as
    select ctp.*
    from vcb.concept_ancestor_temp ctp
    left outer join &_omop_concept_ancestor oct
    on ctp.ancestor_concept_id = oct.ancestor_concept_id
    and ctp.descendant_concept_id = oct.descendant_concept_id
    where oct.ancestor_concept_id is null
    and oct.descendant_concept_id is null;
quit;

proc sql;
  create table __tdvdw.into_concept_ancestor(FASTLOAD=yes) as select * from vcb.concept_ancestor_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.concept_ancestor select * from sb_ghri.into_concept_ancestor) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;

/* Process and Load New Concepts_class records into Concept_class table */
proc sql;
  create table vcb.concept_class_in as
    select ctp.*
    from vcb.concept_class_temp ctp
    left outer join &_omop_concept_class oct
    on ctp.concept_class_id = oct.concept_class_id
    where oct.concept_class_id is null;
quit;

proc sql;
  create table __tdvdw.into_concept_class(FASTLOAD=yes) as select * from vcb.concept_class_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.concept_class select * from sb_ghri.into_concept_class) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New Concept_relationship records into Concept_relationship table */
proc sql;
  create table vcb.concept_relationship_in as
    select ctp.*
    from vcb.concept_relationship_temp ctp
    left outer join &_omop_concept_relationship oct
    on ctp.concept_id_1 = oct.concept_id_1
    and ctp.concept_id_2 = oct.concept_id_2
    and ctp.relationship_id = oct.relationship_id
    where oct.concept_id_1 is null
    and oct.concept_id_2 is null
    and oct.relationship_id is null
;
quit;

proc sql;
  create table __tdvdw.into_concept_relationship(FASTLOAD=yes) as select * from vcb.concept_relationship_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.concept_relationship select * from sb_ghri.into_concept_relationship) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New Concept_synonym records into Concept_synonym table */
proc sql;
  create table vcb.concept_synonym_in as
    select ctp.*
    from vcb.concept_synonym_temp ctp
    left outer join &_omop_concept_synonym oct
    on ctp.concept_id = oct.concept_id
    where oct.concept_id is null;
quit;

proc sql;
  create table __tdvdw.into_concept_synonym(FASTLOAD=yes) as select * from vcb.concept_synonym_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.concept_synonym select * from sb_ghri.into_concept_synonym) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New Domain records into Domain table */
proc sql;
  create table vcb.domain_in as
    select ctp.*
    from vcb.domain_temp ctp
    left outer join &_omop_domain oct
    on ctp.domain_id = oct.domain_id
    where oct.domain_id is null;
quit;

proc sql;
  create table __tdvdw.into_domain(FASTLOAD=yes) as select * from vcb.domain_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.domain select * from sb_ghri.into_domain) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New drug_strength records into drug_strength table */
proc sql;
  create table vcb.drug_strength_in as
    select ctp.*
    from vcb.drug_strength_temp ctp
    left outer join &_omop_drug_strength oct
    on ctp.drug_concept_id = oct.drug_concept_id
    where oct.drug_concept_id is null;
quit;

proc sql;
  create table __tdvdw.into_drug_strength(FASTLOAD=yes) as select * from vcb.drug_strength_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.drug_strength select * from sb_ghri.into_drug_strength) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New relationship records into Relationship table */
proc sql;
  create table vcb.relationship_in as
    select ctp.*
    from vcb.relationship_temp ctp
    left outer join &_omop_relationship oct
    on ctp.relationship_id = oct.relationship_id
    where oct.relationship_id is null;
quit;

proc sql;
  create table __tdvdw.into_relationship(FASTLOAD=yes) as select * from vcb.relationship_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.relationship select * from sb_ghri.into_relationship) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;


/* Process and Load New vocabulary records into Vocabulary table */
proc sql;
  create table vcb.vocabulary_in as
    select ctp.*
    from vcb.vocabulary_temp ctp
    left outer join &_omop_vocabulary oct
    on ctp.vocabulary_id = oct.vocabulary_id
    where oct.vocabulary_id is null;
quit;

proc sql;
  create table __tdvdw.into_vocabulary(FASTLOAD=yes) as select * from vcb.vocabulary_in;
quit;

proc sql;
  &_explicit_tera;
  execute (insert into sb_ghri.vocabulary select * from sb_ghri.into_vocabulary) by teradata;
  execute (commit) by teradata;
  disconnect from teradata;
quit;



/* drop temp tables */
proc sql;
  drop table __tdvdw.into_concept;
quit;

proc sql;
  drop table __tdvdw.into_concept_ancestor;
quit;

proc sql;
  drop table __tdvdw.into_concept_class;
quit;

proc sql;
  drop table __tdvdw.into_concept_synonym;
quit;

proc sql;
  drop table __tdvdw.into_concept_relationship;
quit;

proc sql;
  drop table __tdvdw.into_domain;
quit;

proc sql;
  drop table __tdvdw.into_drug_strength;
quit;

proc sql;
  drop table __tdvdw.into_relationship;
quit;

proc sql;
  drop table __tdvdw.into_vocabulary;
quit;
