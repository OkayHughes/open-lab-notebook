---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Plan June 2023
layout: layouts/post.njk
---


Tomorrow:
Create fork

Add enable/disable flag
Finish gravity change


## notes on gravity
Note 
`$$$ 
\begin{align*}
g &= G\frac{m_1m_2}{r^2} \\
&= G\frac{m_1m_2}{(R_0+z)^2} \\
&= G\frac{m_1m_2}{R_0^2} \left(\frac{R_0}{R_0+z}\right)^2\\
&= g_0 \left(\frac{R_0}{R_0+z} \right)^2
\end{align*}
$$$`
Alright let's do geopotential
`$$$
\begin{align*}
\phi &= zg(z)\\
&= zg_0 \left(\frac{R_0}{R_0 + z}\right)^2\\
\implies (R_0+z)^2 \phi &= zg_0R_0^2 \\
\implies R_0^2 + 2zR_0 + z^2 &= zg
\end{align*}
$$$`

