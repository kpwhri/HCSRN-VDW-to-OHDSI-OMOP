/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Merge Molecular Marker Providers with Providers from EDW
* Date Created:: <2020-03-21>
*********************************************/
/* remove in production */
%include "\\home.ghc.org\home$\weekjm1\sas\scripts\sasntlogon.sas";
%include "&GHRIDW_ROOT.\remote\RemoteStart.sas";

/* leave in */
%include "&GHRIDW_ROOT./management/OfflineData/DataWarehouseMgt/StdVars_Write.sas";
%include "&GHRIDW_ROOT./sasdata/crn_vdw/lib/StdVars_OMOP.sas";


%macro set_libedw ;

    libname __tdedw teradata
      user              = "&nuid@LDAP"
      password          = "&cspassword"
      server            = "edwtdp"
      schema            = "dw_prsn_v"
      access            = readonly
      multi_datasrc_opt = in_clause
      connection        = global
    ;

%mend set_libedw ;

%set_libedw ;

%let _edw_provider = __tdedw.v_dim_practitioner;

%let root_dir=//ghcmaster/ghri/Warehouse/management/Workspace/weekjm1/molecularmarkers;

libname rtdir "&root_dir.";

proc sql noprint;
  create table __tdvdw.edw_vdw_prov(FASTLOAD=yes) as    
      select vdp.practitioner_nbr as vdw_provider, vdp.last_name as prov_last_name, vdp.first_name as prov_first_name,
      vdp.middle_name as prov_middle_name, vdp.npi_nbr as prov_npi, vdp.washington_practitioner_license_ as prov_wa_lic,
      upcase(vdp.first_name)||' '||upcase(vdp.last_name) as prov_fl_name, upcase(vdp.last_name) || ', ' || upcase(vdp.first_name) as prov_lf_name
  from &_edw_provider vdp
  inner join (select distinct provider from &_vdw_utilization) ute
  on ute.provider = vdp.practitioner_nbr
  where vdp.edw_current_record_ind = 'Y'
  ;
quit;



/*
proc sql noprint;
    create table rtdir.mm_prov_xwalk as
        select ep.*, mp.*, 'npi' as prov_id_type  
        from rtdir.edw_ute_prov ep
        inner join rtdir.mm_provider_data mp
        on ep.prov_npi = mp.prov_id
        union
        select ep.*, mp.*, 'license' as prov_id_type
        from rtdir.edw_ute_prov ep
        inner join rtdir.mm_provider_data mp
        on ep.prov_wa_lic = mp.prov_id
        union
        select ep.*, mp.*, 'fl_name' as prov_id_type
        from rtdir.edw_ute_prov ep
        inner join rtdir.mm_provider_data mp        
        on ep.prov_fl_name = upcase(mp.prov_name)
        union
        select ep.*, mp.*, 'lf_name' as prov_id_type
        from rtdir.edw_ute_prov ep
        inner join rtdir.mm_provider_data mp        
        on ep.prov_lf_name = upcase(mp.prov_name)
          ;
quit;

proc sql noprint;
    create table rtdir.vdw_prov_id_xwalk as
        select
          mpc.prov_name as vendor_prov_name
          , mpx.prov_npi as vendor_prov_npi
          , mpc.count_of_orders
          , mpx.vdw_provider as vdw_provider_id
          , mpc.prov_id
        from rtdir.mm_provider_cnt mpc
        left join rtdir.mm_prov_xwalk mpx
        on mpc.prov_name = mpx.prov_name
        and mpc.prov_id = mpx.prov_id
        where mpc.prov_name <> ','
        ;
quit;

*/

