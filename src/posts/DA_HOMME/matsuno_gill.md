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
  
\end{align*}
$$$`