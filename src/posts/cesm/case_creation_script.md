---
date: 2021-09-01
tags:
  - posts
  - cesm
eleventyNavigation:
  key: Case creation script
  parent: 2022/05/05 CAM FV3 install on UM GreatLakes system
layout: layouts/post.njk
---

<pre>

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f8f8f2">export CESMDATAROOT</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$scratch</span>/CESM_INPUT
<span style="color: #f8f8f2">readonly CESM_PREFIX</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;2022_05_05_FV3&quot;</span>
<span style="color: #f8f8f2">readonly COMPSET</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;FADIAB&quot;</span>
<span style="color: #f8f8f2">readonly GRID_NAME</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;C96_C96_mg17&quot;</span>
<span style="color: #f8f8f2">readonly CESM_GROUP</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;test_cases&quot;</span>
<span style="color: #f8f8f2">readonly CASE_ID</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;jw06&quot;</span>
<span style="color: #f8f8f2">readonly NPROCS</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;36&quot;</span>

<span style="color: #75715e"># =================</span>
<span style="color: #f8f8f2">readonly CASE_DIR</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/cesm_cases/${CESM_PREFIX}/${CESM_GROUP}&quot;</span>
<span style="color: #f8f8f2">readonly SRC_DIR</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/cesm_src/${CESM_PREFIX}&quot;</span>
<span style="color: #f8f8f2">readonly CASE_NAME</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${CESM_PREFIX}.${GRID_NAME}.${COMPSET}.${NPROCS}.${CESM_GROUP}.${CASE_ID}&quot;</span>
<span style="color: #f8f8f2">readonly BUILD_ROOT</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${scratch}/CESM/${CESM_PREFIX}/${CASE_NAME}&quot;</span>
<span style="color: #75715e"># =================</span>
<span style="color: #f8f8f2">readonly MY_CESM_ROOT</span><span style="color: #f92672">=</span>/scratch/cjablono_root/cjablono1/owhughes/CESM_ROOT
<span style="color: #f8f8f2">readonly DIN_LOC_ROOT</span><span style="color: #f92672">=</span>/scratch/cjablono_root/cjablono1/owhughes/CESM_ROOT/input
<span style="color: #f8f8f2">readonly MY_SLURM_ACCOUNT</span><span style="color: #f92672">=</span>cjablono0
<span style="color: #f8f8f2">readonly MY_CESM_CASES</span><span style="color: #f92672">=</span><span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_DIR</span><span style="color: #66d9ef">}</span>
<span style="color: #f8f8f2">readonly MY_CESM_SRC</span><span style="color: #f92672">=</span><span style="color: #66d9ef">${</span><span style="color: #f8f8f2">SRC_DIR</span><span style="color: #66d9ef">}</span>
<span style="color: #f8f8f2">readonly MY_CESM_SCRATCH</span><span style="color: #f92672">=</span>/scratch/cjablono_root/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">MY_SLURM_ACCOUNT</span><span style="color: #66d9ef">}</span>/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">USER</span><span style="color: #66d9ef">}</span>
<span style="color: #f8f8f2">export PATH</span><span style="color: #f92672">=</span><span style="color: #66d9ef">${</span><span style="color: #f8f8f2">SRC_DIR</span><span style="color: #66d9ef">}</span>/cime/scripts/://sw/arcts/centos7/stacks/intel/18.0.5/netcdf-fortran/4.4.5/bin:/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-c/4.6.2/bin:/sw/arcts/centos7/cmake/3.13.2/bin:/sw/arcts/centos7/stacks/intel/18.0.5/hdf5/1.8.21/bin:/sw/arcts/centos7/stacks/intel/18.0.5/openmpi/3.1.4/bin:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/bin/intel64:/sw/med/centos7/ghostscript/9.27/bin:/sw/lsa/centos7/nco/4.7.2/bin:/sw/arcts/centos7/ncl/6.6.2/bin:/sw/lsa/centos7/ncview/2.1.8/bin:/opt/singularity/3.5.2/bin:/opt/TurboVNC/bin:/opt/slurm/bin:/opt/slurm/sbin:/usr/lib64/qt-3.3/bin:/sw/arcts/centos7/usertools/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lpp/mmfs/bin:/opt/ibutils/bin:/opt/ddn/ime/bin:/home/owhughes/.local/bin:/home/owhughes/bin
<span style="color: #75715e"># ================</span>


export_mach_vars<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">export </span>MY_CESM_ROOT
    <span style="color: #f8f8f2">export </span>DIN_LOC_ROOT
    <span style="color: #f8f8f2">export </span>MY_SLURM_ACCOUNT
    <span style="color: #f8f8f2">export </span>MY_CESM_CASES
    <span style="color: #f8f8f2">export </span>MY_CESM_SRC
    <span style="color: #f8f8f2">export </span>MY_CESM_SCRATCH
    <span style="color: #f8f8f2">export </span>CESM_GROUP
<span style="color: #f92672">}</span>

handle_case_exists<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local abs_case_dir</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF</span>
<span style="color: #e6db74">Case directory </span>
<span style="color: #e6db74">${abs_case_dir} </span>
<span style="color: #e6db74">already exists! </span>

<span style="color: #e6db74">Cowardly refusing to overwrite it :(</span>

<span style="color: #e6db74">EOF</span>
    <span style="color: #f8f8f2">exit </span>1

<span style="color: #f92672">}</span>

create_case<span style="color: #f92672">(){</span>
    is_dir <span style="color: #e6db74">&quot;${CASE_DIR}/${CASE_NAME}&quot;</span> <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> handle_case_exists <span style="color: #e6db74">&quot;${CASE_DIR}/${CASE_NAME}&quot;</span>
    export_mach_vars
    yes r | <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">SRC_DIR</span><span style="color: #66d9ef">}</span>/cime/scripts/create_newcase --compset <span style="color: #e6db74">&quot;${COMPSET}&quot;</span> --res <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">GRID_NAME</span><span style="color: #66d9ef">}</span> --case <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_DIR</span><span style="color: #66d9ef">}</span>/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_NAME</span><span style="color: #66d9ef">}</span> --run-unsupported --pecount <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">NPROCS</span><span style="color: #66d9ef">}</span>
<span style="color: #f92672">}</span>

create_xml_config_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/xml_config_helper.sh&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>

<span style="color: #e6db74"># ------------------</span>

<span style="color: #e6db74">readonly DEBUG=FALSE</span>

<span style="color: #e6db74"># ------------------</span>
<span style="color: #e6db74"># set this to true if you want an archive directory</span>

<span style="color: #e6db74">readonly DOUT_S=FALSE</span>

<span style="color: #e6db74">#-------------------</span>
<span style="color: #e6db74"># valid options for this value are:</span>
<span style="color: #e6db74">#  nsteps, nseconds, nminutes, nhours, ndays, nmonths, nyears</span>

<span style="color: #e6db74">readonly STOP_OPTION=ndays</span>

<span style="color: #e6db74"># ------------------</span>

<span style="color: #e6db74">readonly STOP_N=20</span>


<span style="color: #e6db74">readonly ATM_NCPL=96</span>

<span style="color: #e6db74"># ------------------</span>
<span style="color: #e6db74"># Set the frequency at which files for restarting the model (e.g. in the </span>
<span style="color: #e6db74"># case of a blowup) are written. If TRUE, make sure to set REST_N</span>

<span style="color: #e6db74">readonly REST_OPTION=none</span>
<span style="color: #e6db74">readonly REST_N=1</span>

<span style="color: #e6db74"># ====================</span>
<span style="color: #e6db74"># CAM build flag (note: this is quite finicky and causes compiler errors if done wrong)</span>

<span style="color: #e6db74">readonly CAM_CONFIG_OPTS=&quot;--phys adiabatic --analytic_ic&quot;</span>

<span style="color: #e6db74"> #--------------------</span>
<span style="color: #e6db74"># Maximum runtime:</span>

<span style="color: #e6db74">readonly HOURS=11</span>
<span style="color: #e6db74">readonly MINUTES=50</span>
<span style="color: #e6db74">readonly SECONDS=00</span>

<span style="color: #e6db74"># --------------------</span>


<span style="color: #e6db74">main() {</span>
<span style="color: #e6db74">    ./xmlchange DEBUG=\${DEBUG},DOUT_S=\${DOUT_S},STOP_OPTION=\${STOP_OPTION},STOP_N=\${STOP_N},REST_OPTION=\${REST_OPTION},REST_N=\${REST_N},ATM_NCPL=\${ATM_NCPL} \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val &quot;\${CAM_CONFIG_OPTS}&quot; \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlquery CAM_CONFIG_OPTS \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlchange JOB_WALLCLOCK_TIME=\${HOURS}:\${MINUTES}:\${SECONDS} \</span>
<span style="color: #e6db74">        &amp;&amp; ./case.setup</span>

<span style="color: #e6db74">}</span>


<span style="color: #e6db74">main</span>
<span style="color: #e6db74">EOF</span>
<span style="color: #f92672">}</span>

create_user_nl_cam<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/user_nl_cam&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>
<span style="color: #e6db74"> avgflag_pertape  = &#39;I&#39;</span>
<span style="color: #e6db74"> fincl1           = &#39;PS:I&#39;,&#39;T:I&#39;,&#39;U:I&#39;,&#39;V:I&#39;,&#39;OMEGA:I&#39;,&#39;T850:I&#39;,&#39;U850:I&#39;,&#39;V850:I&#39;,&#39;OMEGA850:I&#39;,&#39;PHIS:I&#39;</span>
<span style="color: #e6db74"> MFILT            = 90</span>
<span style="color: #e6db74"> NHTFRQ       = -24</span>
<span style="color: #e6db74"> NDENS          = 2</span>
<span style="color: #e6db74">EOF</span>

<span style="color: #f92672">}</span>



create_bash_source<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/bash.source&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>
<span style="color: #e6db74">module load intel/18.0.5</span>
<span style="color: #e6db74">module load openmpi/3.1.4</span>
<span style="color: #e6db74">module load netcdf-c/4.6.2</span>
<span style="color: #e6db74">module load netcdf-fortran/4.4.5</span>
<span style="color: #e6db74">readonly MY_CESM_ROOT=${MY_CESM_ROOT}</span>
<span style="color: #e6db74">export MY_CESM_ROOT</span>
<span style="color: #e6db74">readonly DIN_LOC_ROOT=${MY_CESM_ROOT}</span>
<span style="color: #e6db74">export  DIN_LOC_ROOT</span>
<span style="color: #e6db74">readonly MY_SLURM_ACCOUNT=${MY_SLURM_ACCOUNT}</span>
<span style="color: #e6db74">export MY_SLURM_ACCOUNT</span>
<span style="color: #e6db74">readonly MY_CESM_CASES=${MY_CESM_CASES}</span>
<span style="color: #e6db74">export MY_CESM_CASES</span>
<span style="color: #e6db74">readonly MY_CESM_SRC=${MY_CESM_SRC}</span>
<span style="color: #e6db74">export MY_CESM_SRC</span>
<span style="color: #e6db74">readonly MY_CESM_SCRATCH=${MY_CESM_SCRATCH}</span>
<span style="color: #e6db74">export MY_CESM_SCRATCH</span>
<span style="color: #e6db74">readonly ESMFMKFILE=/home/owhughes/esmf/esmf-ESMF_8_1_1/lib/libO/Linux.intel.64.openmpi.default/esmf.mk</span>
<span style="color: #e6db74">export ESMFMKFILE</span>
<span style="color: #e6db74">export PATH=${PATH}</span>
<span style="color: #e6db74">EOF</span>

<span style="color: #f92672">}</span>

create_preview_namelists_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/preview_namelists_helper.sh&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>
<span style="color: #e6db74">./preview_namelists &gt; preview_namelists.log 2&gt; preview_namelists.err </span>
<span style="color: #e6db74">EOF</span>
<span style="color: #f92672">}</span>

create_case_build_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/case_build_helper.sh&quot;</span> 
    <span style="color: #f8f8f2">echo</span> <span style="color: #e6db74">&quot;qcmd -A ${PROJECT} -- ${CASE_DIR}/${CASE_NAME}/case.build&quot;</span> &gt; <span style="color: #f8f8f2">$config_script</span>
<span style="color: #f92672">}</span>




main<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    create_case <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_xml_config_helper <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_user_nl_cam <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_preview_namelists_helper <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_case_build_helper <span style="color: #ae81ff">\</span>
	<span style="color: #f92672">&amp;&amp;</span> create_bash_source
    
<span style="color: #f92672">}</span>


<span style="color: #75715e"># ============================================================================</span>
<span style="color: #75715e"># begin namelist</span>
<span style="color: #75715e"># ============================================================================</span>

<span style="color: #75715e"># ===========================================================================</span>


<span style="color: #75715e"># ============================================================================</span>
<span style="color: #75715e"># begin boilerplate </span>
<span style="color: #75715e"># ============================================================================</span>

<span style="color: #f8f8f2">readonly PROGNAME</span><span style="color: #f92672">=</span><span style="color: #66d9ef">$(</span>basename <span style="color: #f8f8f2">$0</span><span style="color: #66d9ef">)</span>
<span style="color: #f8f8f2">readonly PROGDIR</span><span style="color: #f92672">=</span><span style="color: #66d9ef">$(</span>readlink -m <span style="color: #66d9ef">$(</span>dirname <span style="color: #f8f8f2">$0</span><span style="color: #66d9ef">))</span>
<span style="color: #f8f8f2">readonly ARGS</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$@&quot;</span>

is_empty<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -z <span style="color: #f8f8f2">$var</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_not_empty<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -n <span style="color: #f8f8f2">$var</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_file<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local file</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -f <span style="color: #f8f8f2">$file</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_link<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> <span style="color: #e6db74">`</span><span style="color: #f8f8f2">test</span> -L <span style="color: #f8f8f2">$1</span><span style="color: #e6db74">`</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>


is_dir<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local dir</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -d <span style="color: #f8f8f2">$dir</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>


<span style="color: #75715e"># =================================================================</span>
<span style="color: #75715e"># end boilerplate</span>
<span style="color: #75715e"># =================================================================</span>


main
</pre></div>

</pre>

