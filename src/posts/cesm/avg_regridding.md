---
date: 2021-09-01
tags:
  - posts
  - regridding
eleventyNavigation:
  key: Average regridding
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---


In order to go between latlon gridded data in a way that's consistent with e.g. treating low-resolution
data as an area average of high-resolution data (i.e. precipitation data). The python script is 

<details>
<summary>remap.py</summary>

```
import xarray as xr
import numpy as np
from os.path import join

def create_grid(dlon, dlat, time):
	lat = np.arange(-90, 90 + 1e-5, dlat, dtype=np.float32)
	lon = np.arange(0, 360, dlon, dtype=np.float32)
	data = np.zeros((lat.size, lon.size, time.size))
	ds = xr.DataArray(data=data,
			  dims=["lat", "lon", "time"],
			  coords={"lat": lat, 
				  "lon": lon,
				  "time": time},
			  attrs={"units":"m/s", "long_name":"Large-scale (stable) precipitation rate (liq + ice)"})
	return xr.Dataset(data_vars= {"PRECL": ds})

#def set_covars(ds):
#	colat = ds["lat"].values
#	colat = 0.5 * (colat[1:] + colat[:-1])
#	colon = ds["lon"].values
#	colon = np.append(colon, colon[0:1] + 360) 
#	colon = (0.5 * (colon[1:] + colon[:-1]) ) % 360
#	return ds.assign_coords(colon=colon, colat=colat)

lat_matrix = None
lon_matrix = None

def get_matrices(in_data, out_data):
	global lat_matrix, lon_matrix
	if lat_matrix is None:
		in_lat = in_data['lat'].values
		out_lat = out_data['lat'].values
		lat_matrix = np.zeros((out_lat.size, in_lat.size))
		for lindi, lati in enumerate(in_lat[:-1]):
			for lindo, lato in enumerate(out_lat[:-1]):
				left = max(in_lat[lindi], out_lat[lindo])
				right = min(in_lat[lindi+1], out_lat[lindo+1]) 
				dlat = right - left
				if dlat < 0:
					dlat = 0
				lat_matrix[lindo, lindi] += 0.5 * dlat
				lat_matrix[lindo+1, lindi] += 0.5 * dlat
		lat_matrix[0, :] *= 2
		lat_matrix[-1, :] *= 2
	if lon_matrix is None:
		in_lon = in_data['lon'].values
		in_nlon = in_lon.size
		out_lon = out_data['lon'].values
		out_nlon = out_lon.size
		lon_matrix = np.zeros((out_lon.size, in_lon.size))
		for lindi, loni in enumerate(in_lon):
			for lindo, lono in enumerate(out_lon):
				left = max(in_lon[lindi], out_lon[lindo])
				right = min(in_lon[(lindi+1) % in_nlon], out_lon[(lindo+1) % out_nlon])
				dlon = right - left
				if dlon < 0:
					dlon = 0	
				lon_matrix[lindo, lindi] += 0.5 * dlon
				lon_matrix[(lindo+1) % out_nlon, lindi] += 0.5 * dlon
		lon_matrix[0, :] *= 2
		lon_matrix[-1, :] *= 2
	return (lat_matrix, lon_matrix)
		


def remap(in_data, out_data, t, t_ind, opath):
	#assume that lat is non-periodic
	#assume that lon is periodic
	(lat_matrix, lon_matrix) = get_matrices(in_data, out_data)
	out_lat = out_data['lat'].values
	out_lon = out_data['lon'].values
	
	vals = np.einsum("jl,ik,lk->ji", lat_matrix, lon_matrix, in_data.values)
	vals = np.expand_dims(vals, axis=2)
	t = t.expand_dims(dim="time")
	
	da = xr.DataArray(data=vals,
			  name="PRECL",
		  dims=["lat", "lon", "time"],
		  coords={"lat": out_lat,
			  "lon": out_lon,
			  "time": t},
		  attrs={"units":"m/s", "long_name":"Large-scale (stable) precipitation rate (liq + ice)"})
	string = t.dt.strftime("%b_%d_%Y_%R").values[0] + ".nc"
	write_netcdf(opath, str(t_ind).zfill(4) + ".nc", da)

def log(process, fname, message):
	with open("log/{}_{}.txt".format(fname, str(process).zfill(4)), "a") as f:
		f.write(message)
		f.write("\n")

def write_netcdf(fdir, fname, data):
	data.to_netcdf(path=join(fdir, fname), mode='w', unlimited_dims={'time':True})
if __name__ == "__main__":
	from mpi4py import MPI
	from sys import argv
	from os import makedirs
	comm = MPI.COMM_WORLD
	rank = comm.Get_rank()
	size = comm.Get_size()
	
	fdir = "/nfs/turbo/cjablono2/owhughes/mountain_test_case_netcdf"
	fname = argv[1]
	out_dir = join(fdir, "precip_regrid", fname)
	makedirs(out_dir, exist_ok=True)
	ds = xr.open_dataset(join(fdir, fname))
	deg_1 = create_grid(1, 1, ds["time"])
	time = ds["time"]
	for i in range(rank, time.size, size):
		log(rank, fname, "Beginning time {}".format(i))
		ds_tmp = xr.Dataset(data_vars= {"PRECL": ds.loc[{"time": time[i]}]["PRECL"]})
		da = ds_tmp["PRECL"]
		remap(da, deg_1, time[i], i, out_dir)
	print("Rank {} done!".format(rank))
```
  
</details>

Remap submission script.
<details>
<summary>remap.sh</summary>
  
```
#!/bin/bash
#
#SBATCH --job-name remapping
#SBATCH --account=cjablono1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000m 
#SBATCH --time=0:60:00
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 
source /home/owhughes/.bashrc

conda activate avg_downsample

mpirun -bind-to=core -np 36 python3.8 remap.py ne30.nc  
```
  
</details>


