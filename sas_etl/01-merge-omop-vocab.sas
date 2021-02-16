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

%let vcb=&rt.\omop_vocab\;

/* Grab Data from Athena CSV downloads */

/* Note:  In some cases the Concept.csv file is not loading in SAS.  
 *  This may be due to an incompatible character in the file.  Saving the file in UTF16 encoding seems to fix the problem.  
 */
data vocab.concept_temp;
  infile "&vcb.CONCEPT.csv" dsd dlm='09'x firstobs=2;
  input concept_id :11. concept_name :$255. domain_id :$20. vocabulary_id :$20. concept_class_id :$20. standard_concept :$1. concept_code :$50. valid_start_date :$10. valid_end_date :$10. invalid_reason :$1. ;
  output;
run;

data vocab.concept_ancestor_temp;
  infile "&vcb.CONCEPT_ANCESTOR.csv" dsd dlm='09'x firstobs=2;
  input ancestor_concept_id :11. descendant_concept_id :11. min_levels_of_separation :11. max_levels_of_separation :11. ;
  output;
run;

data vocab.concept_class_temp;
  infile "&vcb.CONCEPT_CLASS.csv" dsd dlm='09'x firstobs=2;
  input concept_class_id :$20. concept_class_name :$255. concept_class_concept_id :11. ;
  output;
run;

data vocab.concept_relationship_temp;
  infile "&vcb.CONCEPT_RELATIONSHIP.csv" dsd dlm='09'x firstobs=2;
  input concept_id_1 :11. concept_id_2 :11. relationship_id :$20. valid_start_date :$10. valid_end_date :$10. invalid_reason :$1. ;
  output;
run;

data vocab.concept_synonym_temp;
  infile "&vcb.CONCEPT_SYNONYM.csv" dsd dlm='09'x firstobs=2;
  input concept_id :11. concept_synonym_name :$1000. language_concept_id :11. ;
  output;
run;

data vocab.domain_temp;
  infile "&vcb.DOMAIN.csv" dsd dlm='09'x firstobs=2;
  input domain_id :$20. domain_name :$255. domain_concept_id :11. ;
  output;
run;

data vocab.drug_strength_temp;
  infile "&vcb.DRUG_STRENGTH.csv" dsd dlm='09'x firstobs=2;
  input drug_concept_id :11. ingredient_concept_id :11. amount_value :11. amount_unit_concept_id :11. numerator_value :11. numerator_unit_concept_id :11. denominator_value :11. denominator_unit_concept_id :11. box_size :11. valid_start_date :$10. valid_end_date :$10. invalid_reason :$1. ;
  output;
run;

data vocab.relationship_temp;
  infile "&vcb.RELATIONSHIP.csv" dsd dlm='09'x firstobs=2;
  input relationship_id :$20. relationship_name :$255. is_hierarchical :$1. defines_ancestry :$1. reverse_relationship_id :$20. relationship_concept_id :11. ;
  output;
run;

data vocab.vocabulary_temp;
  infile "&vcb.VOCABULARY.csv" dsd dlm='09'x firstobs=2;
  input vocabulary_id :$20. vocabulary_name :$255. vocabulary_reference :$255. vocabulary_version :$255. vocabulary_concept_id :11. ;
  output;
run;


/* Process and Load New Concepts into Concept table  */
%if %sysfunc( exist(vocab.concept) ) %then %do;
  proc sql;
  create table vocab.concept_in as
    select cp.* from vocab.concept cp
    union
    select ctp.*
    from vocab.concept_temp ctp
    left outer join vocab.concept oct
    on ctp.concept_id = oct.concept_id
      where oct.concept_id is null;
  quit;
%end;
%else %do;
  proc sql;
    create table vocab.concept_in as
    select ctp.*
      from vocab.concept_temp ctp;
  quit;
%end;


/* Process and Load New Concept_ancestor records into Concept_ancestor table */
  %if %sysfunc( exist(vocab.concept_ancestor) ) %then %do;
proc sql;
  create table vocab.concept_ancestor_in as
    select cp.* from vocab.concept_ancestor cp
    union
    select ctp.*
    from vocab.concept_ancestor_temp ctp
    left outer join vocab.concept_ancestor oct
    on ctp.ancestor_concept_id = oct.ancestor_concept_id
    and ctp.descendant_concept_id = oct.descendant_concept_id
    where oct.ancestor_concept_id is null
      and oct.descendant_concept_id is null;
    quit;
 %end;
%else %do;
    proc sql;
  create table vocab.concept_ancestor_in as        
    select ctp.*
      from vocab.concept_ancestor_temp ctp;
quit;
%end;

/* Process and Load New Concepts_class records into Concept_class table */
%if %sysfunc( exist(vocab.concept_class) ) %then %do;
proc sql;
 create table vocab.concept_class_in as
    select cp.* from vocab.concept_class cp
    union
    select ctp.*
    from vocab.concept_class_temp ctp
    left outer join vocab.concept_class oct
    on ctp.concept_class_id = oct.concept_class_id
      where oct.concept_class_id is null;
    quit;
  %end;
%else %do;
    proc sql;
 create table vocab.concept_class_in as    
    select ctp.*
    from vocab.concept_class_temp ctp; 
quit;
%end;

/* Process and Load New Concept_relationship records into Concept_relationship table */
  %if %sysfunc( exist(vocab.concept_relationship) ) %then %do;
proc sql;
  create table vocab.concept_relationship_in as
    select cp.* from vocab.concept_relationship cp
    union
    select ctp.*
    from vocab.concept_relationship_temp ctp
    left outer join vocab.concept_relationship oct
    on ctp.concept_id_1 = oct.concept_id_1
    and ctp.concept_id_2 = oct.concept_id_2
    and ctp.relationship_id = oct.relationship_id
    where oct.concept_id_1 is null
    and oct.concept_id_2 is null
      and oct.relationship_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.concept_relationship_in as      
    select ctp.*
    from vocab.concept_relationship_temp ctp; 
quit;
%end;

/* Process and Load New Concept_synonym records into Concept_synonym table */
  %if %sysfunc( exist(vocab.concept_synonym) ) %then %do;
proc sql;
  create table vocab.concept_synonym_in as
    select cp.* from vocab.concept_synonym cp
    union
    select ctp.*
    from vocab.concept_synonym_temp ctp
    left outer join vocab.concept_synonym oct
    on ctp.concept_id = oct.concept_id
    where oct.concept_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.concept_synonym_in as
    select ctp.*
    from vocab.concept_synonym_temp ctp; 
quit;
%end;

/* Process and Load New Domain records into Domain table */
  %if %sysfunc( exist(vocab.domain) ) %then %do;
proc sql;
  create table vocab.domain_in as
    select cp.* from vocab.domain cp
    union
    select ctp.*
    from vocab.domain_temp ctp
    left outer join vocab.domain oct
    on ctp.domain_id = oct.domain_id
    where oct.domain_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.domain_in as
    select ctp.*
    from vocab.domain_temp ctp; 
quit;
%end;

/* Process and Load New drug_strength records into drug_strength table */
  %if %sysfunc( exist(vocab.drug_strength) ) %then  %do;
proc sql;
  create table vocab.drug_strength_in as
    select cp.* from vocab.drug_strength cp
    union
    select ctp.*
    from vocab.drug_strength_temp ctp
    left outer join vocab.drug_strength oct
    on ctp.drug_concept_id = oct.drug_concept_id
    where oct.drug_concept_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.drug_strength_in as
    select ctp.*
    from vocab.drug_strength_temp ctp; 
quit;
%end;

/* Process and Load New relationship records into Relationship table */
%if %sysfunc( exist(vocab.relationship) ) %then %do;
proc sql;
  create table vocab.relationship_in as
    select cp.* from vocab.relationship cp
    union
    select ctp.*
    from vocab.relationship_temp ctp
    left outer join vocab.relationship oct
    on ctp.relationship_id = oct.relationship_id
    where oct.relationship_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.relationship_in as
    select ctp.*
    from vocab.relationship_temp ctp; 
quit;
%end;

/* Process and Load New vocabulary records into Vocabulary table */
  %if %sysfunc( exist(vocab.vocabulary) ) %then %do;
proc sql;
  create table vocab.vocabulary_in as
    select cp.* from vocab.vocabulary cp
    union
    select ctp.*
    from vocab.vocabulary_temp ctp
    left outer join vocab.vocabulary oct
    on ctp.vocabulary_id = oct.vocabulary_id
    where oct.vocabulary_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocab.vocabulary_in as
    select ctp.*
    from vocab.vocabulary_temp ctp; 
quit;
%end;

/* Delete Existing bkup files */
%if %sysfunc( exist(vocab.concept_bkup) ) %then %do;
proc datasets library=vocab;
  delete vocabulary_bkup relationship_bkup drug_strength_bkup domain_bkup concept_synonym_bkup concept_relationship_bkup concept_class_bkup concept_ancestor_bkup concept_bkup;
run;
%end;

/* Delete Existing bk files */
proc datasets library=vocab;
  delete vocabulary_temp relationship_temp drug_strength_temp domain_temp concept_synonym_temp concept_relationship_temp concept_class_temp concept_ancestor_temp concept_temp;
run;

/* Move previous OMOP Vocabulary to bkup files. There is the possibility of an unhandled exception on this process if all data files were created in first run then it should work fine. */
%if %sysfunc( exist(vocab.concept) ) %then %do;
proc datasets library=vocab;
  change vocabulary=vocabulary_bkup relationship=relationship_bkup drug_strength=drug_strength_bkup domain=domain_bkup concept_synonym=concept_synonym_bkup concept_relationship=concept_relationship_bkup concept_class=concept_class_bkup concept_ancestor=concept_ancestor_bkup concept=concept_bkup;
run;
%end;

/* Move input files into OMOP Vocabulary files */
proc datasets library=vocab;
  change vocabulary_in=vocabulary relationship_in=relationship drug_strength_in=drug_strength domain_in=domain concept_synonym_in=concept_synonym concept_relationship_in=concept_relationship concept_class_in=concept_class concept_ancestor_in=concept_ancestor concept_in=concept;
run;

