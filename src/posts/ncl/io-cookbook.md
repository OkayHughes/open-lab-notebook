---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: NCL IO Cheat Sheet
  parent: NCL Script Documentation
layout: layouts/post.njk
---


### Reading multiple files + plot labels from the command line

```
diri = "/path/to/files"
fname1 = getenv("fname1")
fnames = (/ fname1 /)
label1 = getenv("label1")
labels = (/ label1 /)
```

### Getting a time index from the command line:

``` time_ind = stringtointeger(getenv("time")) ```

### Creating a new directory:


This can also be used for general script calling from within ncl.

``` out = systemfunc("mkdir -p " + "figures/" + dir_fig + "/" + comp_identifier) ```


### Creating an image to output to:

``` wks_frame = gsn_open_wks("png", "figures/" + dir_fig + "/" + comp_identifier + "/" +  label + level ) ```


