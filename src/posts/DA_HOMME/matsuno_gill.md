---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: matsuno gill
layout: layouts/post.njk
---

## Slow-wave MG

Gill's paper nondimensionalizes the equations using the
length scale corresponding to the equatorial rossby radius on
a `$$\beta$$` plane (`$$\beta = \frac{2\Omega \cos(0)}{a}$$`) Letting `$$c = \frac{ND}{\pi} $$`, with `$$z_{\textrm{top}} = D$$` and `$$N$$` the B-V frequency,
then the equatorial Rossby radius is `$$ \sqrt{\frac{c}{2\beta}} $$` and the time scale `$$\sqrt{\frac{1}{2\beta c}} $$`. The resulting equations of motion are
`$$$
\begin{align*}
  \pder{u}{t} - \frac{1}{2} y v &= -\pder{p}{x} \\
  \pder{v}{t} + \frac{1}{2} y u &= -\pder{p}{y} \\
  \pder{p}{t} + \pder{u}{x} + \pder{v}{y} &= -Q
\end{align*}
$$$`
with `$$Q$$` our forced heating.
We then add ODE damping to heat and wind, under which the steady state equations look like

`$$$
\begin{align*}
  \varepsilon u - \frac{1}{2} y v &= -\pder{p}{x} \\
  \varepsilon v+ \frac{1}{2} y u &= -\pder{p}{y} \\
  \varepsilon p + \pder{u}{x} + \pder{v}{y} &= -Q \\
  (w &= \varepsilon p + Q) \\
\end{align*}
$$$`

Under the cosine-x-gaussian heating profile, the 
steady-state kelvin wave takes the form
`$$$
\begin{align*}
u &= p = \frac{1}{2} q_0(x) \exp(-\frac{1}{4} y^2) \\
v &= 0 \\
w &= \frac{1}{2}(\varepsilon q_0(x) + F(x)) \exp(-\frac{1}{4}y^2) \\
\varepsilon q_0 + \der{q_0}{x} = -F(x) \stackrel{?}= 
\end{align*}
$$$`


## BV frequency derivation (slightly wrong)
Assume `$$p(z=0) = p_0, T(z=0) = T_0$$`.
A constant BV frequency gives `$$ \frac{g}{\theta}\pder{\theta}{z} = N^2 $$` so
`$$$ 
\begin{align*}
  & \pder{}{z} \log(\theta) = \frac{N^2}{g} \\
  \implies& \log(\theta) - \log(\theta_0) = \frac{N^2}{g}(z-z_0) \\
  \implies& \log\left( \frac{T \left(\frac{p_0}{p} \right)^{\kappa}}{T_0} \right) = \frac{N^2}{g} z \\
  \implies& T = T_0 \left(\frac{p}{p_0} \right)^\kappa \exp\left(\frac{N^2}{g} z\right)
\end{align*}
$$$`
and using hydrostatic balance we get
`$$$ 
\begin{align*}
  &\pder{p}{z} = -\rho g \\
  \implies& \pder{p}{z} = -\frac{pg}{R_d T} \\
  \implies& \pder{p}{z} = -\frac{pg}{R_d T_0 \left(\frac{p}{p_0} \right)^\kappa \exp\left(\frac{N^2}{g} z\right)}  \\
  \implies& \pder{p}{z} = -\frac{pg p_0^\kappa}{R_d T_0 p^\kappa  \exp\left(\frac{N^2}{g} z\right)}  \\
  \implies& \pder{p}{z} = -\frac{p^{1-\kappa}g p_0^\kappa}{R_d T_0} \exp\left(-\frac{N^2}{g} z\right)  \\
  \implies& \int_{0}^{z'} p^{\kappa-1} \pder{p}{z} \intd{z} = -\frac{g p_0^\kappa}{R_d T_0} \int_0^{z'}  \exp\left(-\frac{N^2}{g} z\right) \intd{z} \\
  \implies& \int_{p_0}^{p'} p^{\kappa-1}  \intd{p} = -\frac{g p_0^\kappa}{R_d T_0} \int_0^{z'}  \exp\left(-\frac{N^2}{g} z\right) \intd{z} \\
  \implies&  p^\kappa - p_0^\kappa = -\frac{g p_0^\kappa}{R_d T_0} \frac{g}{N^2} \left(1-\exp\left(-\frac{N^2}{g}z\right)\right)  \\
  \implies&  p^\kappa  =p_0^\kappa \left[1 -\frac{g^2}{R_d T_0 N^2} \left(1-\exp\left(-\frac{N^2}{g}z\right)\right) \right] \\
\end{align*}
$$$`

and based on `$$p(z=\infty) = 0$$` we see `$$T_0 = \frac{g^2}{R_d N^2} $$`

`$$$
\begin{align*}
  &p  = p_0 \left[1 -\frac{g^2}{R_d T_0 N^2} \left(1-\exp\left(-\frac{N^2}{g}z\right)\right) \right]^{1/\kappa} \\
  \implies& \left(\frac{p}{p_0}\right)^\kappa  =  \left[1 -\frac{g^2}{R_d T_0 N^2} \left(1-\exp\left(-\frac{N^2}{g}z\right)\right) \right]\\
  \implies& 1-\left(\frac{p}{p_0}\right)^\kappa  =  \frac{g^2}{R_d T_0 N^2} \left(1-\exp\left(-\frac{N^2}{g}z\right)\right)  \\
  \implies& 1-\frac{R_d T_0 N^2}{g^2}\left[1-\left(\frac{p}{p_0}\right)^\kappa\right] =  \exp\left(-\frac{N^2}{g}z\right) \\
  \implies& \log\left[1-\frac{R_d T_0 N^2}{g^2}\left(1-\left(\frac{p}{p_0}\right)^\kappa\right)\right] =  \left(-\frac{N^2}{g}z\right) \\
  \implies& -\frac{g}{N^2}\log\left[1-\frac{R_d T_0 N^2}{g^2}\left(1-\left(\frac{p}{p_0}\right)^\kappa\right)\right] =  z 
\end{align*}
$$$`


