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

Let's put together a climate example: measure whether tropical cyclone forms under deep/shallow dynamics in a weather-scale experiment. 
* `$$\tau_i = 1 $$` would show that deep atmosphere causes tropical cyclone for unit `$$i$$`.
* `$$\tau_i = 0$$` means deep atmosphere does not cause for unit `$$i$$`.
* `$$ \tau_i = -1 $$` means deep atmosphere inhibits tropical cyclone from forming for unit `$$ i$$`.

Some notes on causal effects:
* The causal effect of a treatment can only be defined in reference to another treatment (e.g. a control). Do these treatments have to be mutually exclusive?
* This framework focuses on effects which result from causes (effect of deep/shallow atmosphere on tropical cyclones) rather than causes of effects (why did tropical cyclone form?)
In the real world (why did Judy get lung cancer?) you have the problem of infinite regress (she has lung cancer because she smoked, because her parents smoked, because her parents hated each other...).
In the computational world this might not be true?
  * Potential outcomes gives actionable information on how to live our lives. And can do so in purely observational situations.
* Cause-effect relationships have to have a temporal ordering.
  * Can't have effect before a cause.
  * Can't have causal simultaneity --> impossible to distinguish directionality.
* Relationship to do calculus
  * `$$\tau_i = \probp(Y_i=y \mid \textrm{do}(1)) - \probp(Y_i=y \mid \textrm{do}(0))  $$`

## Before-after study: temporal stability and causal transience
### Fundamental problem of causal inference:
* We cannot observe both `$$Y_i(1)$$` and `$$Y_i(0)$$` in the real world, and therefore we cannot observe the causal effect of the active treatment

### Causal transience
* Temporal stability assumption: The value of `$$Y_i(0) $$` does not de


