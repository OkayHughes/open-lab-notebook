---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Trying out the SHIELD container
  parent: FV3 Dycore Posts
layout: layouts/post.njk
---


Work on greatlakes.

Run `singularity pull docker://gfdlfv3/shield` in a directory `$FV3_ROOT`

Run 
```
cd ${FV3_ROOT} \
  && wget https://zenodo.org/record/5090124/files/regional_Laura.zip \
  && unzip regional_Laura.zip \
  && mkdir cases \
  && mv regional_Laura cases \
  && wget 
```