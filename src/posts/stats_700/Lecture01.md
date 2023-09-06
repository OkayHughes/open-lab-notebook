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

### Temporal stability
* Temporal stability assumption: The value of `$$Y_i(0) $$` does not depend on when we apply `$$ 0 $$` to unit `$$ i $$` and then measure.
* If this holds, we can take a sequence of measurements, then we can measure `$$Y_i(Z)$$` by a sequence of experiments.

### Causal Transience
* The value of `$$Y_i(1)$$` is not impacted by applying control to unit `$$i$$`, then measure `$$Y_i$$`.
* This gives us the ability to measure both `$$Y_i(0)$$` and `$$Y_i(1)$$` for the same unit `$$i$$` via a sequence of experiments under limited assumptions.

Example of when this is dubious: measure the impact of a treatment of an illness (tendency of patients to get better over time).

### Lab controlled experiments and Unit Homogeneity
This is the assumption that different units respond identically to treatment, e.g. `$$Y_i(z) =  Y_j(z) $$` for `$$z \in \mathcal{A}$$`.
E.g. knockout experiments on mice: engineer nearly genetically identical mice and vary a single gene. Potential outcomes should have the same distribution across units.

## Statistical approaches to causality
A statistical approach to causal inference, we seek to infer some analogue of the difference between potential outcomes
A frequent estimand is the Average Treatment Effect (ATE):
`$$$
\begin{align*}
\tau &= \probe[Y_i(1) - Y_i(0)] \\
&= \probe[Y_i(1)] - \probe[Y_i(0)]
\end{align*}
$$$`
which is linear in a way that allows us to approximate the treatment effect using only the marginal expectations `$$\probe[Y_i(1)],\ \probe[Y_i(0)] $$`

There are estimands which do not immediately have this property and more work must be done.
* The median of `$$\tau_i $$`
* `$$ \probe [\boldsymbol{1}_{\{\tau_i > 0\}}]$$`

### A first look at SUTVA
If we are interested in `$$ \bar{tau}_i = \probe[\tau_i].$$` Why is this still challenging if we focus on marginals instead of the joint distribution?
Suppose `$$Z_i$$` is the chosen treatment that unit `$$i$$` recieves. SUTVA (which will be introduced later) gives us
`$$$
\begin{align*}
Y_i &= Y_i(Z_i) \\
  &= \begin{cases}
      Y_i(1) \quad Z_i = 1 \\
      Y_i(0) \quad z_i = 0
      \end{cases}
\end{align*}
$$$`
and thus the observed data is `$$\{(Y_i,Z_i)\}_{1 \leq i \leq n}.$$` 
The population which is treated (and for which we can observe the treatment effect) is disjoint from the population for which we 
get to observe the control.

To put this mathematically,
`$$$
\begin{align*}
  \probe[Y_i \mid Z_i = 1] = \probe[Y_i(1) \mid Z_i = 1] \\
  \probe[Y_i \mid Z_i = 0] = \probe[Y_i(0) \mid Z_i = 0]
\end{align*}
$$$`

But in general `$$ \probe[Y_i(z) \mid Z_i = z] \neq \probe[Y_i(z)].$$` Especially in observational settings, the way treatments are assigned (or self selected)
can bias these populations. 

### Modeling causality as a missing-data problem
The crux of Rubin's causal model is considering causality as a missing-data problem (e.g. Pearl takes significant issue with this).

Fundamentally, the "science table" tends to look like this:
<table>
  <tr>
    <th>$$Y_i(1)$$</th> <th>$$Y_i(0)$$</th> <th>$$\tau_i$$</th>
  </tr>
  <tr>
    <td>?</td><td>2</td><td>?</td>
  </tr>
  <tr>
    <td>6</td><td>?</td><td>?</td>
  </tr>
  <tr>
    <td>?</td><td>8</td><td>?</td>
  </tr>
  <tr>
    <td>?</td><td>10</td><td>?</td>
  </tr>
</table>

Are these entries missing completely at random (MCAR)? We don't usually know

## Randomized experiments vs Observational studies
One sufficient condition which gives `$$\probe[Y_i \mid Z_i = z] = \probe[Y_i(z)] $$` is independence:
* `$$ (Y_i(1), Y_i(0)) \bot Z_i$$` 
* `$$ \probp(Z_i = 1 \mid (Y_i(1), Y_i(0))) = \probp(Z_i=1)$$`

One can get this in a randomized experiment
### Randomized expieriments
If we assign individuals into treatment groups, then we can enforce this independence by design.

A simple starting example: **a completely randomized experiment**:
* `$$n_1$$` individuals are given treatment, `$$n_0$$` are given control, `$$n = n_0 + n_1$$`. The assignment proportions may be imbalanced e.g. if treatment is very expensive.
* `$$ Z \equiv (Z_1, \ldots, Z_n)^\top$$` 
* `$$ \Omega = \{z \mid \sum_{i} z_i = n_1\}$$` is the set of allowable treatments. 
* `$$\probp(Z=z \mid Z \in \Omega, (Y(1), Y(0)) $$`

