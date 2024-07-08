---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Semi-deep UMJS
layout: layouts/post.njk
---


Compatibility conditions:
`$$$
\begin{align*}
  \frac{u^2}{r} \frac{\sin(\phi)}{\cos(\phi)} + 2 \Omega u \sin \phi + \frac{RT}{r} \partial_\phi \log(p) &= 0\\
  -\frac{u^2}{r} - 2\Omega u \cos\phi + g \hat{r}^2 + RT \partial_r \log(p) &= 0\\
\end{align*}
$$$`

`$$$
\begin{align*}
  \partial_r\left[ \frac{r}{T}\left(\frac{u^2}{r} \frac{\sin(\phi)}{\cos(\phi)} + 2 \Omega u \sin \phi\right) \right] + R \partial_{r\phi} \log(p) &= 0\\
  \partial_\phi \left[\frac{1}{T}\left(-\frac{u^2}{r} - 2\Omega u \cos\phi + g \hat{r}^2 \right)\right]+ R \partial_{\phi r} \log(p) &= 0\\
\end{align*}
$$$`

`$$$
\begin{align*}
  \partial_r\left[ \frac{ur}{T}\left(\frac{u}{r} \frac{\sin(\phi)}{\cos(\phi)} + 2 \Omega \sin \phi\right) \right] &=  \partial_\phi \left[\frac{u}{T}\left(-\frac{u}{r} - 2\Omega  \cos\phi + g \hat{r}^2 \right)\right]
\end{align*}
$$$`

`$$$
\begin{align*}
  \partial_r\left[ \sin(\phi)\frac{r}{T}\left(\frac{u^2}{r\cos(\phi)}  + 2 \Omega u\right) \right] &=  \partial_\phi \left[\frac{\cos\phi}{T}\left(-\frac{u^2}{r\cos\phi } - 2\Omega u  + g \hat{r}^2 \right)\right]
\end{align*}
$$$`


`$$$
\begin{align*}
  \partial_r\left[ r\sin(\phi)\frac{\frac{u^2}{r\cos(\phi)}  + 2 \Omega u}{T} \right] &=  -\partial_\phi \left[\cos\phi\frac{\frac{u^2}{r\cos\phi } + 2\Omega u}{T}\right]  + \partial_\phi \left[\frac{\cos\phi}{T}g \hat{r}^2 \right]
\end{align*}
$$$`

`$$$
\begin{align*}
  \partial_r\left[ r\sin(\phi)\frac{U}{T} \right] &=  -\partial_\phi \left[\cos\phi\frac{U}{T}\right]  + \partial_\phi \left[\frac{\cos\phi}{T}g \hat{r}^2 \right]
\end{align*}
$$$`

`$$$
\begin{align*}
  \sin(\phi)\frac{U}{T} +  r\sin(\phi)\partial_r\left[\frac{U}{T} \right] &=  \sin\phi \frac{U}{T} - \cos\phi\partial_\phi \left[\frac{U}{T}\right]   + \partial_\phi \left[\frac{1}{T}g \hat{r}^2 \right]
\end{align*}
$$$`

`$$$
\begin{align*}
   \left[r\sin(\phi)\partial_r - \cos\phi \partial_\phi  \right]\left(\frac{U}{T} \right) &=    \partial_\phi \left[\frac{1}{T}g \hat{r}^2 \right]
\end{align*}
$$$`

`$$$
\begin{align*}
   \left[\sin(\phi)\partial_r - \frac{\cos\phi}{r} \partial_\phi  \right]\left(\frac{U}{T} \right) &=    \partial_\phi \left[\frac{1}{rT}g \hat{r}^2 \right]
\end{align*}
$$$`

SW form of eqn:
`$$$
\begin{align*}
   \left[\sin(\phi)\partial_r - \frac{\cos\phi}{r} \partial_\phi  \right]\left(\frac{U}{T} \right) &=    \frac{g}{a}\partial_\phi \left[\hat{r}^2\frac{a}{rT}  \right]
\end{align*}
$$$`


Choose functional form
`$$$
\begin{align*}
  T(r, \phi) = 
\end{align*}
$$$`