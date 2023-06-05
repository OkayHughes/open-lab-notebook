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
\implies \phi R_0^2 + 2\phi zR_0 + \phi z^2 &= zg_0R_0^2 \\
\implies \phi z^2 + (2\phi R_0 - g_0R_0^2)z + \phi R_0^2 = 0 \\
\end{align*}
$$$`
and applying the quadratic formula we get
`$$$
\begin{align*}
z &= \frac{-b \pm \sqrt{b^2-4ac}}{2a} \\
&= \frac{(g_0R_0^2- 2\phi R_0 ) + \sqrt{(2\phi R_0 - g_0R_0^2)^2 - 4\phi^2 R_0^2}}{2\phi}\\
&= \frac{(g_0R_0^2-2\phi R_0 ) + \sqrt{R_0^2(2\phi- g_0R_0)^2 - 4\phi^2R_0^2}}{2\phi}\\
&= \frac{(g_0R_0^2-2\phi R_0 ) + R_0 \sqrt{(2\phi- g_0R_0)^2 - 4\phi^2}}{2\phi}\\
\end{align*}
$$$`
verify:

