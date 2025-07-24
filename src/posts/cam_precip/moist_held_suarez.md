---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: CAM precip project
  key: Modified moist held suarez
layout: layouts/post.njk
---

I'll describe the process of using topography with idealized physics. In this document I'll be explaining
how to use the `landfrac` variable in the TJ16 compset to only apply 
surface fluxes over the ocean.

The implicit update reads as
`$$$\pder{q_a}{t} = \frac{C_E |\boldsymbol{v}_a| (q_{\textrm{sat}, a} - q_a)}{z_a}$$$`
(with an analogous expression for `$$T_a$$`). It is updated with one step of a fixed-point iterationpatterned on backwards Euler. This reads as
`$$$
\begin{align*}
    &\phantom{\implies} \frac{q_a^{t+1} - q_a^t}{\Delta t} = \frac{C_E |\boldsymbol{v}_a| (q_{\textrm{sat}, a} - q_a^{t+1})}{z_a} \\
    &\implies q_a^{t+1} - q_a^t = \frac{\Delta t C_E |\boldsymbol{v}_a| q_{\textrm{sat}, a}}{z_a} - \frac{\Delta t C_E |\boldsymbol{v}_a| q_a^{t+1}}{z_a}   \\
    &\implies \left( \frac{\Delta t C_E |\boldsymbol{v}_a|}{z_a} + 1 \right)q_a^{t+1}  = \frac{\Delta t C_E |\boldsymbol{v}_a| q_{\textrm{sat}, a}}{z_a}  + q_a^t   \\
    &\implies q_a^{t+1}  = \frac{q_{\textrm{sat}, a} + \frac{\Delta t C_E |\boldsymbol{v}_a| }{z_a} }{ 1 + \frac{\Delta t C_E |\boldsymbol{v}_a|}{z_a}}     \\
\end{align*}
$$$`

So if we assume that the RHS of the continuous-time equation is scaled by `$$C_{\textrm{landfrac}}$$`, then anywhere that a `$$C_E$$` appears, you also apply `$$ C_{\textrm{landfrac}}$$`.  


