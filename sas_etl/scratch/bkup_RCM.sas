/*********************************************
* Program:  bkup_RCM.sas
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Bkup RCM codes
* Date Created:: 9/24/2020
*********************************************/

/* remove personal login for production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";

/* VDW Standard Variables */
%include "&GHRIDW_ROOT.\Sasdata\CRN_VDW\lib\StdVars.sas";

/* RCM Standard Variables */
%include "&GHRIDW_ROOT.\Sasdata\CRN_VDW\lib\StdVars_RCMandCNTRS.sas";

/* SAS Prefix Sync Macros */
%include "&GHRIDW_ROOT.\management\Programs\DataWarehouseMgt\prefix_sync_macros.sas";

/* Debug Options */
options nocenter missing='~' errorabend errors=1
formchar  = '|-++++++++++=|-/|<>*'
macrogen symbolgen mprint mlogic linesize  = 132
noquotelenmax ;

/* root folder */
%let  code_home =\\home.ghc.org\home$\weekjm1\HCSRN-VDW-to-OHDSI-OMOP;

libname datout "&code_home./sasdat";

proc sql;
  create table datout.vdw_standard_codes as
    select * from __tdvdw.vdw_standard_codes
    order by code_source, code_type, code
  ;
quit;
