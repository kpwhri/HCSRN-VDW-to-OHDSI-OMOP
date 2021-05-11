/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: provide standard variables for Code Management views
* Date Created::<2019-06-03>
*********************************************/


/* codes required for Source -> VDW -> OMOP translation */
%let _rcm_cod                 = dat.rcm_cod_cod                  ;
%let _rcm_causetype           = dat.rcm_cod_causetype            ;
%let _rcm_deathtype           = dat.rcm_dth_deathtype            ;
%let _rcm_diagnosis           = dat.rcm_dx_dx                    ;
%let _rcm_discharge_status    = dat.rcm_utl_discharge_status     ;
%let _rcm_admit_source        = dat.rcm_utl_admit_source         ;
%let _rcm_enctype             = dat.rcm_utl_enctype              ;
%let _rcm_ethnicity           = dat.rcm_dem_ethnicity            ;
%let _rcm_gender              = dat.rcm_dem_sex_admin            ;
%let _rcm_lab_loinc           = dat.rcm_lab_loinc                ;
%let _rcm_physician_specialty = dat.rcm_prv_specialty            ;
%let _rcm_procedure           = dat.rcm_px_px                    ;
%let _rcm_race                = dat.rcm_dem_race                 ;
%let _rcm_ndc                 = dat.rcm_rx_ndc                   ;
%let _rcm_pos                 = dat.rcm_utl_pos                  ;


/* Codes and Descriptions */
%let _rcm_vdw_codebucket      = dat.rcm_vdw_codebucket           ;
%let _rcm_code_descriptions   = dat.rcm_vdw_codebucket           ;


/* OMOP Vocabulary */
%let _omop_concept            = vocab.concept                    ;
%let _omop_concept_relations  = vocab.concept_relationship       ;
%let _omop_concept_ancestor   = vocab.concept_ancestor           ;
%let _omop_concept_class      = vocab.concept_class              ;
%let _omop_concept_synonym    = vocab.concept_synonym            ;
%let _omop_domain             = vocab.domain                     ;
%let _omop_drug_strength      = vocab.drug_strength              ;
%let _omop_relationship       = vocab.relationship               ;
%let _omop_vocabulary         = vocab.vocabulary                 ;

/* VDW Tables */
%let _vdw_enroll                =  &_vdw_enroll                  ;
%let _vdw_demographic           =  &_vdw_demographic             ;
%let _vdw_language              =  &_vdw_language                ;
%let _vdw_rx                    =  &_vdw_rx                      ;
%let _vdw_everndc               =  &_vdw_everndc                 ;
%let _vdw_utilization           =  &_vdw_utilization             ;
%let _vdw_dx                    =  &_vdw_dx                      ;
%let _vdw_px                    =  &_vdw_px                      ;
%let _vdw_provider_specialty    =  &_vdw_provider_specialty      ;
%let _vdw_vitalsigns            =  &_vdw_vitalsigns              ;
%let _vdw_census                =  &_vdw_census                  ;
%let _vdw_census_loc            =  &_vdw_census_loc              ; 
%let _vdw_census_demog          =  &_vdw_census_demog            ;
%let _vdw_lab                   =  &_vdw_lab                     ;
%let _vdw_lab_notes             =  &_vdw_lab_notes               ;
%let _vdw_death                 =  &_vdw_death                   ;
%let _vdw_cause_of_death        =  &_vdw_cause_of_death          ;
%let _vdw_social_hx             =  &_vdw_social_hx               ;
%let _vdw_facility              =  &_vdw_facility                ;
