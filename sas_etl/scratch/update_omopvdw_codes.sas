/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Update the VDW_Codebucket with any new codes that have been added to the OMOP Vocabulary tables
* Date Created:: 2020-01-24
*********************************************/

/* remove in production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";

/* leave in */
%include "&GHRIDW_ROOT./management/OfflineData/DataWarehouseMgt/StdVars_Write.sas";
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_OMOP.sas";

proc sql;
  &_explicit_tera;
  execute (create table sb_ghri.codebucket_temp as select 
