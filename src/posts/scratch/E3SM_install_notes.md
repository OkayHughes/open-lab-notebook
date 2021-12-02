---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: E3SM 2.0 install notes
  parent: scratch
layout: layouts/post.njk
---

### Installing

After installing public ssh key for greatlakes, I ran 
`git clone -b v2.0.0 --recursive git@github.com:sandialabs/CLDERA-E3SM.git` in my `~` directory.

Ran correctly.


### Creating case

<details>
<summary>Create case log</summary>

  ```
  Compset longname is 2000_XATM_XLND_XICE_XOCN_XROF_XGLC_XWAV
Compset specification file is /home/owhughes/E3SM/CLDERA-E3SM/driver-mct/cime_config/config_compsets.xml
Automatically adding SIAC to compset
Automatically adding SESP to compset
Compset forcing is 
Com forcing is present day:
ATM component is Dead atm component
LND component is Dead land component
ICE component is Dead ice component
OCN component is Dead ocean component
ROF component is Dead river component
GLC component is Dead land-ice component
WAV component is Dead wave component
IAC component is Stub iac component
ESP component is Stub external system processing (ESP) component
Pes     specification file is /home/owhughes/E3SM/CLDERA-E3SM/driver-mct/cime_config/config_pes.xml
Machine is greatlakes
Variable MAX_GPUS_PER_NODE not defined for machine greatlakes
Pes setting: grid          is a%1.9x2.5_l%1.9x2.5_oi%gx1v6_r%r05_g%null_w%null_z%null_m%gx1v6 
Pes setting: compset       is 2000_XATM_XLND_XICE_XOCN_XROF_XGLC_XWAV_SIAC_SESP 
Pes setting: tasks       is {'NTASKS_ATM': -1, 'NTASKS_ROF': -1, 'NTASKS_OCN': -1, 'NTASKS_ICE': -1, 'NTASKS_CPL': -1, 'NTASKS_LND': -1, 'NTASKS_GLC': -1, 'NTASKS_WAV': -1, 'NTASKS_IAC': -1, 'NTASKS_ESP': -1} 
Pes setting: threads     is {'NTHRDS_ATM': 1, 'NTHRDS_LND': 1, 'NTHRDS_ROF': 1, 'NTHRDS_ICE': 1, 'NTHRDS_OCN': 1, 'NTHRDS_GLC': 1, 'NTHRDS_WAV': 1, 'NTHRDS_IAC': 1, 'NTHRDS_ESP': 1, 'NTHRDS_CPL': 1} 
Pes setting: rootpe      is {'ROOTPE_ATM': 0, 'ROOTPE_ROF': 0, 'ROOTPE_ICE': 0, 'ROOTPE_OCN': 0, 'ROOTPE_CPL': 0, 'ROOTPE_LND': 0, 'ROOTPE_GLC': 0, 'ROOTPE_WAV': 0, 'ROOTPE_IAC': 0, 'ROOTPE_ESP': 0} 
Pes setting: pstrid      is {} 
Pes other settings: {}
Pes comments: none
setting additional fields from config_pes: {}
 Compset is: 2000_XATM_XLND_XICE_XOCN_XROF_XGLC_XWAV_SIAC_SESP 
 Grid is: a%1.9x2.5_l%1.9x2.5_oi%gx1v6_r%r05_g%null_w%null_z%null_m%gx1v6 
 Components in compset are: ['xatm', 'xlnd', 'xice', 'xocn', 'xrof', 'xglc', 'xwav', 'siac', 'sesp'] 
No project info available
No charge_account info available, using value from PROJECT
e3sm model version found: 1e754ed
Batch_system_type is slurm
job is case.run USER_REQUESTED_WALLTIME None USER_REQUESTED_QUEUE None WALLTIME_FORMAT %H:%M:%S
job is case.st_archive USER_REQUESTED_WALLTIME None USER_REQUESTED_QUEUE None WALLTIME_FORMAT %H:%M:%S
 Creating Case directory /home/owhughes/E3SM/X_case
  
  ```

</details>



<details>
<summary> Results of ./case.setup</summary>
  
  ```
  
  Setting resource.RLIMIT_STACK to -1 from (-1, -1)
/home/owhughes/E3SM/X_case/env_mach_specific.xml already exists, delete to replace
/home/owhughes/E3SM/X_case/env_mach_specific.xml already exists, delete to replace
job is case.run USER_REQUESTED_WALLTIME None USER_REQUESTED_QUEUE None WALLTIME_FORMAT %H:%M:%S
Creating batch scripts
Writing case.run script from input template /home/owhughes/E3SM/CLDERA-E3SM/cime_config/machines/template.case.run
Creating file .case.run
Writing case.st_archive script from input template /home/owhughes/E3SM/CLDERA-E3SM/cime_config/machines/template.st_archive
Creating file case.st_archive
Creating file .case.run.sh
Creating user_nl_xxx files for components and cpl
If an old case build already exists, might want to run 'case.build --clean' before building
Generating component namelists as part of setup
  2021-12-02 16:48:44 atm 
Create namelist for component xatm
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xatm/cime_config/buildnml
  2021-12-02 16:48:44 lnd 
Create namelist for component xlnd
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xlnd/cime_config/buildnml
  2021-12-02 16:48:44 ice 
Create namelist for component xice
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xice/cime_config/buildnml
  2021-12-02 16:48:44 ocn 
Create namelist for component xocn
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xocn/cime_config/buildnml
  2021-12-02 16:48:44 rof 
Create namelist for component xrof
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xrof/cime_config/buildnml
  2021-12-02 16:48:44 glc 
Create namelist for component xglc
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xglc/cime_config/buildnml
  2021-12-02 16:48:44 wav 
Create namelist for component xwav
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/xcpl_comps/xwav/cime_config/buildnml
  2021-12-02 16:48:44 iac 
Create namelist for component siac
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/stub_comps/siac/cime_config/buildnml
  2021-12-02 16:48:44 esp 
Create namelist for component sesp
   Calling /home/owhughes/E3SM/CLDERA-E3SM/components/stub_comps/sesp/cime_config/buildnml
  2021-12-02 16:48:44 cpl 
Create namelist for component drv
   Calling /home/owhughes/E3SM/CLDERA-E3SM/driver-mct/cime_config/buildnml
File not found: atm2ocn_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_aave.130322.nc, will attempt to download in check_input_data phase
File not found: atm2ocn_smapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_blin.130322.nc, will attempt to download in check_input_data phase
File not found: atm2ocn_vmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_patc.130322.nc, will attempt to download in check_input_data phase
File not found: ocn2atm_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/gx1v6/map_gx1v6_TO_fv1.9x2.5_aave.130322.nc, will attempt to download in check_input_data phase
File not found: ocn2atm_smapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/gx1v6/map_gx1v6_TO_fv1.9x2.5_aave.130322.nc, will attempt to download in check_input_data phase
File not found: atm2ice_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_aave.130322.nc, will attempt to download in check_input_data phase
File not found: atm2ice_smapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_blin.130322.nc, will attempt to download in check_input_data phase
File not found: atm2ice_vmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/fv1.9x2.5/map_fv1.9x2.5_TO_gx1v6_patc.130322.nc, will attempt to download in check_input_data phase
File not found: ice2atm_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/gx1v6/map_gx1v6_TO_fv1.9x2.5_aave.130322.nc, will attempt to download in check_input_data phase
File not found: ice2atm_smapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/gridmaps/gx1v6/map_gx1v6_TO_fv1.9x2.5_aave.130322.nc, will attempt to download in check_input_data phase
File not found: lnd2rof_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/lnd/clm2/mappingdata/maps/1.9x2.5/map_1.9x2.5_nomask_to_0.5x0.5_nomask_aave_da_c120522.nc, will attempt to download in check_input_data phase
File not found: rof2lnd_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/lnd/clm2/mappingdata/maps/1.9x2.5/map_0.5x0.5_nomask_to_1.9x2.5_nomask_aave_da_c120709.nc, will attempt to download in check_input_data phase
File not found: atm2rof_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/lnd/clm2/mappingdata/maps/1.9x2.5/map_1.9x2.5_nomask_to_0.5x0.5_nomask_aave_da_c120522.nc, will attempt to download in check_input_data phase
File not found: atm2rof_smapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/lnd/clm2/mappingdata/maps/1.9x2.5/map_1.9x2.5_nomask_to_0.5x0.5_nomask_aave_da_c120522.nc, will attempt to download in check_input_data phase
File not found: rof2ocn_fmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/cpl6/map_r05_TO_g16_aave.120920.nc, will attempt to download in check_input_data phase
File not found: rof2ocn_liq_rmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/cpl6/map_r05_to_gx1v6_e1000r300_090226.nc, will attempt to download in check_input_data phase
File not found: rof2ocn_ice_rmapname = /home/owhughes/E3SM/CLDERA-E3SM/inputData/cpl/cpl6/map_r05_to_gx1v6_e1000r300_090226.nc, will attempt to download in check_input_data phase
You can now run './preview_run' to get more info on how your case will be run
  ```
</details>


<details>
<summary>Results of ./preview_run</summary>
  
  ```
  CASE INFO:
  nodes: 1
  total tasks: 36
  tasks per node: 36
  thread count: 1
  ngpus per node: 0

BATCH INFO:
  FOR JOB: case.run
    ENV:
      Setting Environment LD_LIBRARY_PATH=/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-fortran/4.4.5/lib:/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-c/4.6.2/lib:/sw/arcts/centos7/stacks/intel/18.0.5/hdf5/1.8.21/lib:/sw/arcts/centos7/stacks/intel/18.0.5/szip/2.1.1/lib:/sw/arcts/centos7/stacks/intel/18.0.5/openmpi/3.1.4/lib:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/compiler/lib/intel64:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/compiler/lib/intel64_lin:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/ipp/lib/intel64:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/mkl/lib/intel64_lin:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/tbb/lib/intel64/gcc4.7:/sw/arcts/centos7/intel/18.0.5/debugger_2018/iga/lib:/sw/arcts/centos7/intel/18.0.5/debugger_2018/libipt/intel64/lib:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/daal/lib/intel64_lin:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/tbb/lib/intel64_lin/gcc4.4:/opt/slurm/lib64::
      Setting Environment NETCDF_C_PATH=/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-c/4.6.2
      Setting Environment NETCDF_FORTRAN_PATH=/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-fortran/4.4.5
      Setting Environment OMP_NUM_THREADS=1
      Setting Environment OMP_STACKSIZE=256M

    SUBMIT CMD:
      sbatch -t 00:20:00 --mail-type END --mail-type FAIL .case.run --resubmit

    MPIRUN (job=case.run):
      mpiexec -n 36 /scratch/cjablono_root/cjablono1/owhughes/E3SM/E3SMv2/X_case/bld/e3sm.exe   >> e3sm.log.$LID 2>&1 


  ```
  
  
</details>