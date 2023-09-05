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

These are due to [NEYMAN1923], [RUBIN1974]. More background can be found in [Holland (1986)](https://www.jstor.org/stable/2289064).

Let `$$\mathcal{A}$$` be a set of treatments. The simplest example is perhaps `$$\mathcal{A} = \{0,1\} $$` where 0 corresponds to a control
and 1 corresponds to a treatment. 