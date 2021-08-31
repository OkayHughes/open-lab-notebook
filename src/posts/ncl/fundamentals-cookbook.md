---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: NCL Fundamentals Cheat Sheet
  parent: NCL Script Documentation
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


### `if else`

```
if (max_val .lt. 10) then

else

end if
```


### Accessing `$$ \pi $$`

```
pi_const = get_pi(0.0)
```



