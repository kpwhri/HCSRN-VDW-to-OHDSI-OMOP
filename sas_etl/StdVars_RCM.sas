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
%let _rcm_cod                 = __tdvdw.zrcm_cod_cod                  ;
%let _rcm_causetype           = __tdvdw.zrcm_cod_causetype            ;
%let _rcm_deathtype           = __tdvdw.zrcm_dth_deathtype            ;
%let _rcm_diagnosis           = __tdvdw.zrcm_dx_dx                    ;
%let _rcm_discharge_status    = __tdvdw.zrcm_utl_discharge_status     ;
%let _rcm_admit_source        = __tdvdw.zrcm_utl_admit_source         ;
%let _rcm_enctype             = __tdvdw.zrcm_utl_enctype              ;
%let _rcm_ethnicity           = __tdvdw.zrcm_dem_ethnicity            ;
%let _rcm_gender              = __tdvdw.zrcm_dem_gender               ;
%let _rcm_lab_loinc           = __tdvdw.zrcm_lab_loinc                ;
%let _rcm_physician_specialty = __tdvdw.zrcm_prv_specialty            ;
%let _rcm_procedure           = __tdvdw.zrcm_px_px                    ;
%let _rcm_race                = __tdvdw.zrcm_dem_race                 ;
%let _rcm_rx                  = __tdvdw.zrcm_rx_ndc                   ;
%let _rcm_pos                 = __tdvdw.zrcm_utl_pos                  ;

/* Standard Code cross walks */
%let _rcm_xwlk_diagnosis_std  = __tdvdw.zcms_xwlk_diagnosis_std       ;

/* Code lists with descriptions */
%let _rcm_list_icd9cm         = __tdvdw.zcms_list_icd9cm              ;
%let _rcm_list_icd10cm        = __tdvdw.zcms_list_icd10cm             ;


