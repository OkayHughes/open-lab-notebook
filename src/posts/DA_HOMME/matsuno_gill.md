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
  \implies& \int_{0}^{z'} p^{1-\ka} \pder{p}{z} = -\frac{p^{1-\kappa}g p_0^\kappa}{R_d T_0} \exp\left(-\frac{N^2}{g} z\right)  \\
\end{align*}
$$$`