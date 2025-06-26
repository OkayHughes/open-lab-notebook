---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Quasi-hydrostatic CAM-SE
  key: QHE-SE shallow
layout: layouts/post.njk
---

The idea here is to try the equations given in [Tort and Dubos](https://rmets.onlinelibrary.wiley.com/doi/10.1002/qj.2274)
adapted for CAM-SE's hybrid `$$\eta$$` coordinate.

The equations given in that paper read
`$$$
\begin{align*}
\der{u}{t} - \left[2\Omega \left(1 + \frac{2z}{a} \right) + \frac{u}{\cos\phi} \right]v\sin \phi + 2 \Omega w \cos \phi + \frac{1}{\rho a \cos \phi} \pder{p}{\lambda} &= 0 \\
\der{v}{t} + \left[2 \Omega \left( 1 + \frac{2z}{a}\right) + \frac{u}{a\cos\phi}  \right] u \sin\phi + \frac{1}{\rho a} \pder{p}{\phi} &= 0 \\
-2\Omega \cos\phi + g + \frac{1}{\rho} \pder{p}{z} &= 0
\end{align*}$$$`
where the factor of two comes from an asymptotic expansion of the Lagrangian used to derive these equations.
Theoretically, the derivation in [Tort and Dubos 2014](https://journals.ametsoc.org/view/journals/mwre/142/10/mwr-d-14-00069.1.xml) could be used
to prove the desired continuum conservation properties, but the notational differences would make this a 
substantial project. If this becomes publishable it would be worth doing this derivation.

For now we adapt the [White and Bromley](https://rmets.onlinelibrary.wiley.com/doi/abs/10.1002/qj.49712152208) form of the quasi-hydrostatic equation
The original W&B equation reads
`$$$
\begin{align*}
r_s(p) &= a + \int_p^{p_\textrm{surf}} \frac{R_d T_s(p)}{gp'} \intd{p'}\\
\pder{}{p} \left[ gz\right] &= \frac{R_d}{p} \left(T_v + \frac{2 \Omega u r_s \cos \phi + u^2 + v^2}{r_s g}T_s \right).
\end{align*}
$$$`
The resulting equations are 
`$$$
\begin{align*}
\der{u}{t} - \left[2\Omega \left(1 + \frac{2z}{a} \right) + \frac{u}{\cos\phi} \right]v\sin \phi - 2 \Omega \frac{\omega}{\rho g} \cos \phi + \frac{1}{\rho a \cos \phi} \pder{p}{\lambda} &= 0 \\
\der{v}{t} + \left[2 \Omega \left( 1 + \frac{2z}{a}\right) + \frac{u}{a\cos\phi}  \right] u \sin\phi + \frac{1}{\rho a} \pder{p}{\phi} &= 0 \\
\pder{}{p} \left[ gz\right] + \frac{R_dT_v}{p} \left(1  + \frac{2 \Omega u  \cos \phi}{g}\right) &= 0
\end{align*}
$$$`

Hydrostatic balance in CAM-SE reads
`$$$
\pder{\Phi}{\eta} = -\frac{R_d T_v }{p} \pder{p}{\eta},
$$$`
discretized as
`$$$
\Phi_{k+\half} = \Phi_{\textrm{surf}} + R_d \sum_{j=k}^{\textrm{nlev}} \left[ \frac{ (T_v)_j}{p_j} \Delta p_j\right]
$$$`
which we adapt to
`$$$
\Phi_{k+\half} = \Phi_{\textrm{surf}} + R_d \sum_{j=k}^{\textrm{nlev}} \left[ \frac{ (T_v)_j}{p_j} \left(1 + 2\Omega u\cos \phi  \right) \Delta p_j\right]
$$$`
where the Lorenz staggering removes the need to decide on an averaging for `$$u$$`