---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Creating a Made to Measure MPAS grid.
  parent: MPAS tutorials
layout: layouts/post.njk
---

## How to create a variable resolution MPAS grid for the MPAS-A model.

<span class="todo"> Add introduction here</span>

I'm doing this work on NCAR's cheyenne so I defaultly have access to the Netcdf Cinematic Universe without much setup.

## Step 0: get code

I based my code on the wonderful repository that Pedro Peixoto has put online, which can be found [here](https://github.com/pedrospeixoto/MPAS-PXT).
However, I have uploaded my modified version of the code [here](https://github.com/OkayHughes/MPAS_grid_gen)


## Step 1 installation:

This package plays very nicely with the `conda` environment manager for python. I cannot recommend enough following
an install process based on this toolkit. A minimal `conda` install can be done by running one of the scripts
found [here](https://docs.conda.io/en/latest/miniconda.html) (it doesn't even need `root` permissions!!).

Once you have your shell configured to run `conda`, you can follow these instructions:
asdfasdf
<details>
  <summary><code>create_env.run_once.sh</code></summary>
  

<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">conda create --name mpas_grid_gen <span style="color: #aa0000">python</span>=3.8 
<span style="color: #aaaaaa; font-style: italic"># I typically specify a python version which differs</span>
<span style="color: #aaaaaa; font-style: italic"># from the system version so that e.g. python and python3 both</span>
<span style="color: #aaaaaa; font-style: italic"># point to the conda version of python.</span>
conda activate mpas_grid_gen
conda install --file dev-spec.txt
conda install mpas_tools
</pre></div>


  
</details>


Actually running the code must be done after running `conda activate mpas_grid_gen`.


<span class="todo">Warning: the original code from Peixoto specifies grid spacings in km on a sphere
of radius `$$a=6371\mathrm{km} $$` but my code uses a reduced radius sphere with `$$a=3185\mathrm{km} $$`</span>


The function `localrevVsLatLon` inside of `jigsaw_util.py` defines the density function. In this project I 
care about creating a factor of 4 refinement of the grid in an axisymmetric band about the equator. 
If we define  the smallest grid spacing `$$r_0 =15\mathrm{km}, $$` the nominal width of the band of refinement `$$\varphi_0 = 7^\circ $$`
and the power which defines the sharpness of transition (larger power means sharper transition) to be `p = 4` then 
the density function which has units of kilometers is given by
`$$$ \textrm{dist}(\varphi) = r_0 \left(4 - 3 \left[ \frac{1}{\left(\frac{\varphi}{\varphi_0}\right)^p + 1} \right] \right) $$$`

you can play with this functional form [here](https://www.desmos.com/calculator/xx4sypedm4).

My implementation of the above density function is given 

<details>
<summary>here:</summary>
  

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">def localrefVsLatLon<span style="color: #f92672">(</span>r, <span style="color: #f8f8f2">earth_radius</span><span style="color: #f92672">=</span>6371e3/2, <span style="color: #f8f8f2">p</span><span style="color: #f92672">=</span>False<span style="color: #f92672">)</span>:

<span style="color: #e6db74">&quot;&quot;&quot;</span>
<span style="color: #e6db74">  Create cell width array for this mesh on a locally refined latitude-longitude grid.</span>
<span style="color: #e6db74">  Input</span>
<span style="color: #e6db74">  ---------</span>
<span style="color: #e6db74">  r : float</span>
<span style="color: #e6db74">      minimun desired cell width resolution in km</span>
<span style="color: #e6db74">  Returns</span>
<span style="color: #e6db74">  -------</span>
<span style="color: #e6db74">  cellWidth : ndarray</span>
<span style="color: #e6db74">      m x n array of cell width in km</span>
<span style="color: #e6db74">  lon : ndarray</span>
<span style="color: #e6db74">      longitude in degrees (length n and between -180 and 180)</span>
<span style="color: #e6db74">  lat : ndarray</span>
<span style="color: #e6db74">      longitude in degrees (length m and between -90 and 90)</span>
<span style="color: #e6db74">  &quot;&quot;&quot;</span>
<span style="color: #f8f8f2">dlat</span> <span style="color: #f92672">=</span> 0.125 <span style="color: #75715e">#Make the lat-lon grid ~ 10x finer than resolution at equator, where 1deg ~ 100km</span>
<span style="color: #f8f8f2">dlon</span> <span style="color: #f92672">=</span> dlat
<span style="color: #f8f8f2">constantCellWidth</span> <span style="color: #f92672">=</span> r  <span style="color: #75715e">#in km</span>

<span style="color: #f8f8f2">nlat</span> <span style="color: #f92672">=</span> int<span style="color: #f92672">(</span>180./dlat<span style="color: #f92672">)</span> + 1
<span style="color: #f8f8f2">nlon</span> <span style="color: #f92672">=</span> int<span style="color: #f92672">(</span>360./dlon<span style="color: #f92672">)</span> + 1

<span style="color: #f8f8f2">lat</span> <span style="color: #f92672">=</span> np.linspace<span style="color: #f92672">(</span>-90., 90., nlat<span style="color: #f92672">)</span>
<span style="color: #f8f8f2">lon</span> <span style="color: #f92672">=</span> np.linspace<span style="color: #f92672">(</span>-180., 180., nlon<span style="color: #f92672">)</span>

lons, <span style="color: #f8f8f2">lats</span> <span style="color: #f92672">=</span> np.meshgrid<span style="color: #f92672">(</span>lon, lat<span style="color: #f92672">)</span>

<span style="color: #66d9ef">if </span>p:
<span style="color: #f8f8f2">h</span> <span style="color: #f92672">=</span> plt.contourf<span style="color: #f92672">(</span>lons, lats, dists<span style="color: #f92672">)</span>
plt.axis<span style="color: #f92672">(</span><span style="color: #e6db74">&#39;scaled&#39;</span><span style="color: #f92672">)</span>
plt.colorbar<span style="color: #f92672">()</span>
plt.show<span style="color: #f92672">()</span>

<span style="color: #75715e">#Parameters</span>
<span style="color: #75715e">#------------------------------</span>

<span style="color: #75715e"># Radius (in degrees) of high resolution area</span>
<span style="color: #f8f8f2">maxdist</span> <span style="color: #f92672">=</span> 7
<span style="color: #75715e">#ratio of largest grid spacing to smallest grid spacing</span>
<span style="color: #f8f8f2">reduction_factor</span> <span style="color: #f92672">=</span> 4.0
<span style="color: #75715e"># defines sharpness of transition. You can play with how this looks here:</span>
<span style="color: #75715e"># https://www.desmos.com/calculator/xx4sypedm4</span>
<span style="color: #f8f8f2">power</span> <span style="color: #f92672">=</span> 4

<span style="color: #75715e"># initialize with resolution = r (min resolution)</span>
<span style="color: #f8f8f2">factor</span> <span style="color: #f92672">=</span> 1.0/<span style="color: #f92672">(</span>np.power<span style="color: #f92672">(</span>1/maxdist  lats, power<span style="color: #f92672">)</span> + 1<span style="color: #f92672">)</span>
<span style="color: #f8f8f2">resolution</span> <span style="color: #f92672">=</span> r  <span style="color: #f92672">(</span>reduction_factor - <span style="color: #f92672">(</span>reduction_factor-1<span style="color: #f92672">)</span> * factor<span style="color: #f92672">)</span>

<span style="color: #66d9ef">if </span>p:
<span style="color: #f8f8f2">h</span> <span style="color: #f92672">=</span> plt.contourf<span style="color: #f92672">(</span>lons, lats, resolution, <span style="color: #f8f8f2">cmap</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;viridis&quot;</span>, <span style="color: #f8f8f2">levels</span><span style="color: #f92672">=</span>100<span style="color: #f92672">)</span>
plt.axis<span style="color: #f92672">(</span><span style="color: #e6db74">&#39;scaled&#39;</span><span style="color: #f92672">)</span>
plt.colorbar<span style="color: #f92672">()</span>
plt.show<span style="color: #f92672">()</span>

print<span style="color: #f92672">(</span>np.min<span style="color: #f92672">(</span>resolution<span style="color: #f92672">)</span>, np.max<span style="color: #f92672">(</span>resolution<span style="color: #f92672">))</span>

<span style="color: #f8f8f2">cellWidth</span> <span style="color: #f92672">=</span> resolution <span style="color: #75715e">#constantCellWidth * np.ones((lat.size, lon.size))</span>

<span style="color: #66d9ef">return </span>cellWidth, lon, lat
</pre></div>



</details>


I use the file `invoke.sh` to generate grids. This activates the `conda` environment I need to activate and calls
the python script. <span class="todo">This script must be called like `bash -l invoke.sh` because `conda` expects to run in 
a login shell.</span>

Breaking down the invocation,

```
python spherical_grid.py -r "15" -o "120_30_grid"  -g "localref" #--plot 0
```

* `-r "15"` specifies that the minimum grid spacing is `$$15\mathrm{km} $$` on a sphere with `$$ a=3185 \mathrm{km} $$`
* `-o "120_30_grid"` specifies the output directory and grid prefix that the command will generate.
* `-g "localref"` indicates that you want to generate a locally refined unstructured grid. Other options
are icosahedral grids, or quasiuniform grids.
* `--plot 0` specifies that you want to see numpy plots of the density function. This takes forever.




Invoking this command will create a folder called `120_30_grid` which contains a file called `120_30_grid_mpas.nc` which is the file which is the closest analogue of the mesh files provided on the MPAS
website.

I copy this file to a new directory `~/grids/x4.${NCELLS}/x4.${NCELLS}.grid.nc` where `x4` designates
a 4x grid refinement and `$NCELLS` can be found by running `ncdump -h 120_30_grid/120_30_grid_mpas.nc` and looking
for the `nCells` dimension.

## Step 2: Creating processor decompositions 
* Download the MPAS-Tools repository [here](https://github.com/MPAS-Dev/MPAS-Tools)
* in the base directory of the repository, run `cd mesh_tools/processor_decompositions`

This directory contains a utility to generate processor decompositions so that 
your grid can be used with different numbers of MPI processes.

### Installing metis:
This repository requires the use of the `gpmetis` program.
You can download the source by running (note the last command is very bash-specific)

```
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz \
  && tar -xf http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz \
  && cd metis-5.1.0 \
  && make config \
  && make \
  && find ~+ -name "gpmetis"
```

Note the output from the last line. This is the value for `${PATH_TO_GPMETIS}` referenced below.

I use the following script to create processor decomposition files and automatically move them to the `~/grids/x4.${NCELLS}`
directory I mentioned earlier. 



<details>
<summary><code>invoke.sh</code></summary>

```
conda activate project_2
readonly NCELLS="92067"
readonly GRID_PREFIX="x4.${NCELLS}"
readonly GRID_DIR="/glade/u/home/owhughes/grids/x4.92067"
readonly FILE="${GRID_DIR}/${GRID_PREFIX}.grid.nc"
readonly METIS_PATH="${PATH_TO_GPMETIS}"
readonly NPROC="288"
readonly NBLOCK="288"
python make_partition_files.py --file ${FILE} --metis ${METIS_PATH} --procs ${NPROC} --blocks ${NBLOCK}


mv "graph.info.part.${NPROC}" "${GRID_DIR}/${GRID_PREFIX}.graph.info.part.${NPROC}"
mv "block.graph.info.part.${NPROC}" "${GRID_DIR}/${GRID_PREFIX}.block.graph.info.part.${NPROC}"

```
  
</details>

And note once again that this must be called as `bash -l invoke.sh.`
Here `${NPROC}` references the number of MPI processes. `${NBLOCK}` sets the decomposition
so that processes are split up so that grid cells assigned to a particular MPI process will
be in the memory of that node, and minimize communication. I rarely use this and only see minor
performance decreases. It doesn't play very well with the CESM CIME framework.

This file will create the following files for `x4.${NCELLS}.block.graph.info.part.${NBLOCK}` and
`x4.${NCELLS}.graph.info.part.${NPROC}` files in `${GRID_DIR}`. 

This will allow you to invoke MPI-enabled MPAS executables using `mpirun -np ${NPROC} ${PATH_TO_EXECUTABLE}`


## Step 3: creating ESMF and SCRIP files for this grid
If you want to use your generated grid with any non-MPAS related grid utilities, follow the instructions in this section.

In the root of the MPAS-Tools repository, run `cd mesh_tools/mpas2esmf`.

Run `make` (just that command, nothing else needed) and keep adding dependencies until it compiles correctly.

In order to generate the files run 

```
./mpas2esmf ${GRID_DIR}/x4.${NCELLS}.grid.nc "${informative_description_of_grid}" `date "+%F"` 

```

The output file `mpas_esmf.nc` contains an [ESMF](https://earthsystemmodeling.org/regrid/) description 
of the file. <span class="todo">This is crucial for using your grid within the CIME/CESM framework.</span>

The `mpas_scrip.nc` is useful for regridding. I'll write more about this if I end up using it at some point.

I move `mpas_esmf.nc` to `~/grids/x4.${NCELLS}/x4.${NCELLS}.esmf.coupling.nc`.

If you know how to use MPAS, then you can now use these exactly like the files provided by MPAS themselves.







