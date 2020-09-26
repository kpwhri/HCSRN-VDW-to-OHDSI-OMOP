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
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_JIFFI.sas";


/* EDIT SECTION */
/* VDW standard variable inclusion */
*%include "VDW standard vars";
/* Root location of folder HCSRN VDW to OHDSI OMOP */
  %let root=//home.ghc.org/home$/weekjm1/DataWarehouse/RDWandOMOP/omop-sas-build/HCSRN-VDW-to-OHDSI-OMOP;
/* library for code */
  libname sas "&root./sas";
  libname ipt "&root./input";

/* End Edit Section */
*%include "RCM standard vars";
%include "&root./input/StdVars_RCM.sas";


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


/* %let root=&GHRIDW_ROOT.\management\Workspace\CESR_Dev\<subjectdir>\etl; */
%let files=//home.ghc.org/home$/weekjm1/DataWarehouse/RDWandOMOP/td_rcm_omop/vdw2omop;

libname omop "&files./omop_files";

/* Run Build */
%include "&root./sas/1-load-OMOP.sas";

