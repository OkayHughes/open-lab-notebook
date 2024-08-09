---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Optimizing IMEX convergence
layout: layouts/post.njk
---

In the first phase of this work, we compare SA HOMME and DA HOMME with the numerical Jacobian 
to remove the analytic Jacobian math in DA HOMME as a source of error. 

For the Matsuno-gill heating pattern (20 levels, full-size earth, 10km model top), time steps 
at the two-day mark converge in 6 iterations in DA HOMME but 3 iterations in SA HOMME.
Both models are using their respective numerical jacobian routines.

This indicates that the form of the analytic Jacobian is not the source of our problems.

Next steps:
  * Ensure that there is no mis-treatment of upper boundary condition in DA HOMME numerical Jacobian code
  * Test sensitivity to initial guess.
  * Identify tuning parameters for convergence and test sensitivity.


## Checking if rest of imex routines are broken:
Hypothesis: treatment of Fn (residual) does not include QHE terms?
Experiment: disable QHE terms in explicit. Is convergence better?
  * If extra terms of QHE are omitted, numerical Jacobian converges in 3 iterations past day 10!
  * Do addition of QHE change acoustic mode? 
  
Todo:
  * Verify numerical Jacobian is stable to 20 days with "hydrostatic" initial guess
  * Verify analytic Jacobian is dogshit at 20 days with "hydrostatic" initial guess
  * Contingent on this: analyze |J_analytic - J_numerical| test residual by level.
  * If it's bad at boundaries, life's good. If not, rework analytic Jacobian.

