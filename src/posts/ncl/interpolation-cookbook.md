---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: NCL Interpolation Cookbook
  parent: NCL Script Documentation
layout: layouts/post.njk
---

### CESM Interpolating to one constant pressure level:

```
time_ind = 5 ; in days, interpolating all fields is quite expensive!
level = 500 ; pressure in hPa to which to interpolate
f     = addfile(diri + fnames(i),"r")
lon := f->lon
lat := f->lat
time := f->time
var_all := f->$label$ ; label is a string variable containing the field to interpolate
ps := f->PS
hyam := f->hyam
hybm := f->hybm

interp = 2 ; log interpolation
extrap = True
P0mb = 1000 ; reference pressure in hPa

var_tmp := var_all({time_ind}, :, :, :)

; if you want to take a subset of latitude and longitude
var = interpolated_var(0, {0:45}, {-180:180})

```

###