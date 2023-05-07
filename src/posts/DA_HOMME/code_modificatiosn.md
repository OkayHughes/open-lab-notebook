---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Code modifications
layout: layouts/post.njk
---

# Finding and modifying the vertical integral
The idea is to do this by modifying the underlying subroutine. Hopefully one exists.
Geopotential used in NH model: called `phinh_i` (only at interfaces). 

In order to calculate a vertical integral, either `phinh_i` or `dp3d` must be referenced.

So: plan for tomorrow. 
0) Ensure deep atmosphere 2016 base state is available.  (Looks to be true!)
1) Modify EOS + elem ops following MT document
2) Identify as many vertical integrals as possible. Figure out how to change them.


# Assumptions
* We assume that `$$\phi = g(r-R_0) $$` uses a constant `$$g$$` defined in the code by
`use physical_constants, only: g`. This means that computation of `dphinh_i` 
does not need to be changed.
* We assume that `$$\phi_{i} = 0.5(\phi_{i-1/2} + \phi_{i+1/2})$$`, i.e. midpoint values
of interface quantities can be reconstructed by averaging.
* `theta_hydrostatic_mode=.false.`. We disregard the case of a hydrostatic-but-deep atmosphere
because, honestly, who would use that?



# List of changes

## `dp3d`


### Calculating `$$ r $$`
In order to do this we first determine a way to calculate `$$r$$` on model 
interfaces as well as model levels.

Here is the first complication: midpoints are defined to be in the middle of the interval `$$s_{i-1/2}$$` and
`$$ s_{i+1/2}$$`. If `$$s$$` is not a height coordinate, then taking the average of `$$ \phi_{i-1/2} $$` and `$$\phi_{i+1/2} $$`
may not give the geometric midpoint of the interval. In the proofs of conservation
provided in Taylor (2020), Eqn 30 shows that this is good enough for the moment. This is consistent with the `element_ops.F90` routine
for calculating it at midpoints.

These are added to the `element_ops.F90` file. The `get_radius` subroutine
is not publicly exported because we assume it's only usable in theta_hydrostatic.
`get_field` and `get_field_i` must be called to calculate radius or r_hat. 

### Modifying dp3d calculation

So `dp3d` is calculated at initialization, but grepping for `dp3d` shows that
the only assignments to dp3d are through time stepping. Therefore, test initialization
will need to be modified to calculate `dp3d` with the correct pseudodensity. However, so long as our updates 
to the CAAR routines are internally consistent, we needn't change how `dp3d` is used after it is initialized.


## EOS changes

At line 176 in `eos.F90` calculates `$$\frac{p_{\tm{nh}}}{\Pi} $$`.
In the shallow HOMME formulation, 
`$$$
\begin{align*}
\pder{\phi}{s} &= -R_{d}\left(\pder{p_{\tm{h}}}{s}\theta_v\right)\frac{\Pi}{p_{\tm{nh}}} \\
\implies \frac{\Delta \phi}{\Delta s} &= -R_d \left(\frac{\Delta p_{\tm{h}}}{\Delta s}\theta_v \right) \frac{\Pi}{p_{\tm{nh}}}\\
\implies \Delta \phi &= -R_d \Theta \frac{\Pi}{p_{\tm{nh}}}\\
\implies \frac{p_{\tm{nh}}}{\Pi} &= \frac{R_d \Theta}{\Delta \phi} 
\end{align*}
$$$`
Using the definition `$$\Pi = \left(\frac{p_{\tm{nh}}}{p_0} \right)^{R_d/c_p},$$` line 178 calculates
`$$$
\begin{align*}
p_{\tm{nh}} &= p_0 \left(\frac{\frac{p_{\tm{nh}}}{\Pi}}{p_0} \right)^{\frac{1}{1-\frac{R_d}{c_p}}}\\
&= p_0 \left(\frac{\frac{p_{\tm{nh}}}{\left(\frac{p_{\tm{nh} }}{p_0} \right)^{R_d/c_p}}}{p_0} \right)^{\frac{1}{1-\frac{R_d}{c_p}}} \\
&= p_0 \left(\frac{p_{\tm{nh}}}{p_0} \cdot \left(\frac{p_{\tm{nh}}}{p_0}\right)^{-\frac{R_d}{c_p}} \right)^{\frac{1}{1-\frac{R_d}{c_p}}} \\
&= p_0 \left(\left(\frac{p_{\tm{nh}}}{p_0}\right)^{1-\frac{R_d}{c_p}} \right)^{\frac{1}{1-\frac{R_d}{c_p}}} \\
&= p_0 \left(\frac{p_{\tm{nh}}}{p_0}\right)^{\frac{1-\frac{R_d}{c_p} }{1-\frac{R_d}{c_p}}} \\
&= p_0 \cdot \frac{p_{\tm{nh}}}{p_0}\\
&= p_{\tm{nh}}
\end{align*}
$$$`
and then line 182 calculates
`$$$
\begin{align*}
\Pi = \frac{p_{\tm{nh}}}{\frac{p_{\tm{nh}}}{\Pi}}.
\end{align*}
$$$`
Therefore line 176 is an intermediate quantity that allows for the calculation of nonhydrostatic pressure by line 178,
and the exner function by line 182.

Therefore in the deep HOMME formulation, 
`$$$
\begin{align*}
\Delta \phi &= -\hat{r}^{-2} R_d (\Delta p_{\tm{h},d} \cdot \theta_v)\frac{\Pi}{p_{\tm{nh}}}\\
&= -\hat{r}^{-2} R_d (\hat{r}^2\Delta p_{\tm{h}} \cdot \theta_v)\frac{\Pi}{p_{\tm{nh}}}\\
&= R_d (\Delta p_{\tm{h}} \cdot \theta_v)\frac{\Pi}{p_{\tm{nh}}}
\end{align*}
$$$`
and the rest of the derivation remains the same.
