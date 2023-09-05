---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Lecture 01
  parent: STATS 700
layout: layouts/post.njk
---

## Goals of the course:
* Quantify causal questions using the mathematical language of potential outcomes (one framework)
* Design studies to estimate causal effects 
* Analyze data from these studies to estimate causal effects
* Assess robustness of analysis to violations of underlying modeling assumptions.

# Potential Outcomes Model for Defining Effects Caused by a Treatment
## Definitions

These are due to [Neyman 1923](https://www.jstor.org/stable/2245382), [Rubin 1974](https://drive.google.com/file/d/1jW9kZhwSSAddQJ83IvcEviAnERbsi1Da/view?usp=sharing). More background can be found in [Holland (1986)](https://www.jstor.org/stable/2289064).

Let `$$\mathcal{A}$$` be a set of treatments. The simplest example is perhaps `$$\mathcal{A} = \{0,1\} $$` where 0 corresponds to a control
and 1 corresponds to a treatment. 

A "unit" refers to a sample to which a treatment can be applied. E.g. a patient, or perhaps a model run?
We use the notation
* `$$ Y_i(1)$$` denotes the potential outcome if treatment is applied.
* `$$ Y_i(0)$$` denotes the potential outcome if control is applied.

The causal effect of treatment compared to control for unit `$$i$$` can be expressed as `$$$ \tau_i = Y_i(1) - Y_i(0).$$$`

Let's put together a climate example: SSW with EP flux above a certain threshold