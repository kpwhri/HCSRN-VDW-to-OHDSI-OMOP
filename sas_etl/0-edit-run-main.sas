/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Populates variables with user's parameters
* Date Created:: 2019-09-05
*********************************************/

/* remove in production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";

/* Std Vars JIFFI */
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_JIFFI.sas";

/* EDIT SECTION */
/* VDW standard variable inclusion */
/* *%include "VDW standard vars"; */

options
  linesize  = 150
  msglevel  = i
  formchar  = '|-++++++++++=|-/|<>*'
  dsoptions = note2err 
  nocenter
  noovp
  nosqlremerge
  extendobscounter = no
;

/* Root location of folder HCSRN VDW to OHDSI OMOP */
%let root=\\home.ghc.org\home$\weekjm1;

/* library for code */
%let rt=&root.\HCSRN-VDW-to-OHDSI-OMOP\;

libname etl "&rt.sas_etl";
libname dat "&rt.sas_dat";
libname omop "rt.omop_files";
libname vocab "rt.omop_vocab";

/* Run Build */
%include "&rt./sas_etl/1-load-OMOP.sas";
