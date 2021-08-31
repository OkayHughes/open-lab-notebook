---
title: NCL Fundamentals Cheat Sheet
date: 2021-08-16
tags:
  - posts
  - ncl
layout: layouts/post.njk
---

### Creating a new array:
```array := new((ARRAY, DIMENSION, SIZES),TYPE)```


### Loops:
While loops:

```
i=0
do while(i.lt. LIMIT)
  
  i=i+1
end do
```

### Opening a file:

```
f     = addfile(diri + fname,"r")
```


### getting dimension sizes:

```
latsize = dimsizes(lat)
```




