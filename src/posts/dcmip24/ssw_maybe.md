---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Odd function base state
  parent: DCMIP 2024
layout: layouts/post.njk
---

The idea is to look and see if the Staniforth & White generalized thermal wind solutions
can be generalized further if we place less of a premium on closed-form solutions.
Can we derive an interesting stratosphere using this method?

The compatibility condition is, letting `$$U \equiv 2\Omega u + \frac{u^2}{r\cos\phi} $$` and `$$ T(r, \phi) = \left(\frac{a}{r} \right)^3 \left[ \tau_1(r) - \tau_2(r) \tau_3\left(\frac{r}{a}\cos\phi \right) \right]^{-1}$$`,
`$$$ \left(\sin(\phi) \pder{}{r} + \frac{\cos\phi}{r} \pder{}{\phi}\right)\left(\frac{U}{T}\right) = \frac{g}{a} \pder{}{\phi} \left(\frac{a^3}{r^3 T} \right) = -\frac{g}{a} \tau_2(r) \pder{}{\phi} \left[ \tau_3\left( \frac{r}{a} \cos\phi \right) \right] $$$`

The 2011 paper indicates that one specifies the latitudinal dependence and then leave `$$\tau_1, \tau_2$$` underdetermined.

`$$$ 
\tau_2\pder{}{\phi} \left[ \tau_3 \left(\frac{r}{a} \cos \phi \right) \right] = \left(\sin \phi \pder{}{r} + \frac{\cos \phi}{r} \pder{}{\phi} \right) \left[ \left( \frac{a^2}{r^2} \int_a^r \frac{r'}{a}\tau_2(r') \intd{r} \right)  \right]
$$$`




`$$$
\begin{align*}
  &\left(\sin\phi \pder{}{r} + \frac{\cos\phi}{r} \pder{}{\phi} \right) \left[ \frac{a^2}{r^2} \int_a^{r'} \frac{r'}{a} \tau_2(r') \intd{r'}\left( \left(\frac{r}{a}\right)^{k+1} \cos(\phi)^{k-1} - \left(\frac{r}{a} \right)^{k+3} \cos(\phi)^{k+1} \right)\right]\\
  &= \left(\sin\phi \pder{}{r}  \right) \left[ \frac{a^2}{r^2} \int_a^{r'} \frac{r'}{a} \tau_2(r') \intd{r'}\left( \left(\frac{r}{a}\right)^{k+1} \cos(\phi)^{k-1} - \left(\frac{r}{a} \right)^{k+3} \cos(\phi)^{k+1} \right)\right] + \\
  &\qquad \left(\frac{\cos\phi}{r} \pder{}{\phi}\right)\left[ \frac{a^2}{r^2} \int_a^{r'} \frac{r'}{a} \tau_2(r') \intd{r'}\left( \left(\frac{r}{a}\right)^{k+1} \cos(\phi)^{k-1} - \left(\frac{r}{a} \right)^{k+3} \cos(\phi)^{k+1} \right)\right] \\
  &= \left(\sin\phi \pder{}{r}  \right) \left[ \frac{a^2}{r^2} \int_a^{r'} \frac{r'}{a} \tau_2(r') \intd{r'}\left( \left(\frac{r}{a}\right)^{k+1} \cos(\phi)^{k-1} - \left(\frac{r}{a} \right)^{k+3} \cos(\phi)^{k+1} \right)\right] + \\
  &\qquad \left(\frac{\cos\phi}{r} \pder{}{\phi}\right)\left[ \frac{a^2}{r^2} \int_a^{r'} \frac{r'}{a} \tau_2(r') \intd{r'}\left( \left(\frac{r}{a}\right)^{k+1} \cos(\phi)^{k-1} - \left(\frac{r}{a} \right)^{k+3} \cos(\phi)^{k+1} \right)\right] \\
\end{align*}
$$$`