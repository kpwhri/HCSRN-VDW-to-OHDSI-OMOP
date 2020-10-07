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
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars.sas";
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_RCMandCNTRS.sas";

proc sql outobs=10;
  select px.px, vcb.*, px.*
  from &_vdw_px px
  inner join &_rcm_vdw_codebucket vcb
    on px.px = vcb.code
  where vcb.code_type='10';
quit;
