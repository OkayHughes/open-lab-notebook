---
title: Installing HOMME
date: 2021-05-15
tags:
  - posts
layout: layouts/post.njk
---


Ok so after talking to some very talented folks over at the DOE, 
I decided that it was time to try to install the Higher Order Method Modeling Environment
(HOMME) on our local cluster computer at U of M. 

After some googling I found the following [instructions](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/2735079654/Standalone+HOMME)

I'm going to detail here the process of trying to install this.

### Downloading the code:

The E3SM source seems to be available [here](https://github.com/E3SM-Project/E3SM).
*Note, you should clone this code rather than rely on any releases.*
Run `git checkout maint-1.2`

According to the instructions, I'm going to assume that the working directory should be on 
`/scratch` somewhere.

#### Figuring out which machine file to use:
The suggested file in the tutorial is `mach = $homme/cmake/machineFiles/cori-knl.cmake.`

The default centos configuration seems to be promising, so I'm going to use that as my starting point.




