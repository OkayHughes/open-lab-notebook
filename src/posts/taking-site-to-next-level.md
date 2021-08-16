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
_Note, you should clone this code rather than rely on any releases._
Run `git checkout maint-1.2`

According to the instructions, I'm going to assume that the working directory should be on
`/scratch` somewhere.

It appears that some perl modules are necessary, and that `cime/scripts/Tools/get_case_env` has been renamed to
`cime/scripts/Tools/e3sm_check_env` which shows that some perl modules need to be installed.

None of the perl modules on greatlakes seem useful, so I do the following:

- Use the default `perl` in `/usr/bin`
- Run the following to get perl to install locally `perl -MCPAN -Mlocal::lib -e 'CPAN::install(LWP)'`
- Add the following to your .bashrc `eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"`
- Then for every module listed in `e3sm_check_env`, run `cpan {MODULENAME}`. You may need to read
  error messages to determine what dependencies are, because perl is terrible.

#### Figuring out which machine file to use:

The suggested file in the tutorial is `mach = $homme/cmake/machineFiles/cori-knl.cmake.`

The default centos configuration seems to be promising, so I'm going to use that as my starting point.
