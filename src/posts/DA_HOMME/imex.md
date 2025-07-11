---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: efficient IMEX
layout: layouts/post.njk
---

All we need to modify are the Jacobian terms for `$$\phi$$`. 
From the [IMEX preprint](https://arxiv.org/pdf/1906.07219.pdf)

`$$$ G_{m,j}(g_{m,j}^\phi) = g_{m,j} - E_{m,j}^\phi - g \Delta t \hat{A}_{j,j} E_m^w + (g \Delta t \hat{A}_{j,j})^2 (1-\mu_{m,j})$$$`

which gets translated into (dicarding any terms that disappear under differentiation),

`$$$ C_1 - \sum(\delta \phi) - C_2 - C_3  - (g\Delta t A_{j,j})^2\mu_{m,j} $$$`.
The tricky thing is that we are calculating this quantity at model interfaces, which means
and so we find
`$$$
\begin{align*}
  \mu_k &= \frac{p_{k+1} - p_k}{\frac{1}{2}(\textrm{dp3d}_{k+1} + \textrm{dp3d}_k)}\\
  &= (\textrm{dp3d}_i)^{-1}  p_0 \left[ 
  \left( p_0^{-1} \frac{R_d \theta_{v, k+1} \textrm{dp3d}_{k+1}}{\phi_{k+1}-\phi_{k}} \right)^{\frac{1}{1-\kappa}} - 
 \left( p_0^{-1} \frac{R_d \theta_{v, k} \textrm{dp3d}_{k}}{\phi_{k}-\phi_{k-1}} \right)^{\frac{1}{1-\kappa}} \right]\\
 &= (\textrm{dp3d}_i)^{-1}  p_0 \left[ 
  \left( p_0^{-1} R_d \theta_{v, k+1} \textrm{dp3d}_{k+1}  \right)^{\frac{1}{1-\kappa}} \left( \phi_{k+1}-\phi_{k} \right)^{\frac{1}{1-\kappa}} - 
 \left( p_0^{-1} R_d \theta_{v, k} \textrm{dp3d}_{k} \right)^{\frac{1}{1-\kappa}}  \left(\phi_{k}-\phi_{k-1} \right)^{\frac{1}{1-\kappa}}\right]
\end{align*}
$$$`

and so to make everything as easy to read as possible

`$$$
\begin{align*}
  \partial_{\phi_{k+1}} [ \mu_k]  &= (\textrm{dp3d}_i)^{-1}  p_0 \left[ 
  \left( p_0^{-1} R_d \theta_{v, k+1} \textrm{dp3d}_{k+1}  \right)^{\frac{1}{1-\kappa}} \left( \phi_{k+1}-\phi_{k} \right)^{\frac{1}{1-\kappa}}\frac{1}{(1-\kappa)\left( \phi_{k+1}-\phi_{k} \right)} \right]\\
  &= -\frac{p_{k+1}}{\textrm{dp3d}_{i, k+1}(\phi_{k+1} - \phi_k)}
\end{align*}
$$$`
which gives us the template 


`$$$
\begin{align*}
  a &= \frac{(\Delta t g(\phi_1))^2}{(1-\kappa)}\\
  b &= \frac{a}{\textrm{dp3d}_{\textrm{int}, 1}}\\
  c_1 &= \frac{p_1}{\Delta \phi_1} \\
  J_L &= b_{k+1}c_k \\
  J_{U,k=1} &= 2b_kc_k \\
  J_{U,k\neq 1} &= b_k c_k \\
  J_{D, k=1} &= 1- J_{U, 1} \\
  J_{D, k \neq 1} &= 1-J_{L,k-1} - J_{U, k}
\end{align*}
$$$`

where we can expand
`$$$
\begin{align*}
  b_m c_n &= \frac{(\Delta t g(\phi_m))^2}{(1-\kappa) \cdot \textrm{dp3d}_{\textrm{int}, m}} \cdot \frac{p_n}{\Delta \phi_n}\\
  &= \frac{(\Delta t g(\phi_m))^2}{(1-\kappa) \cdot \textrm{dp3d}_{\textrm{int}, m}} \cdot \frac{p_n}{\Delta \phi_n}\\
\end{align*}
$$$`


The trick comes from differentiating `$$\mu$$` with respect to `$$\phi$$`
`$$$
\begin{align*}
  \mu &= \frac{p_k - p_{k+1}}{\textrm{dp3d}_{\textrm{int}, k}} \\
      &= \frac{ \frac{R_d T_k \textrm{dp3d}_k }{\Delta \phi_k} - \frac{R_d T_{k+1} \textrm{dp3d}_{k+1} }{\Delta \phi_{k+1}}}{\textrm{dp3d}_{\textrm{int}, k+1}} 
\end{align*}
$$$`
and thus
`$$$
\begin{align*}
 \partial_{\Delta \phi_k} \mu &= -\frac{p_k}{\textrm{dp3d}_{\textrm{int}, k+1}} [\Delta \phi_{k}]^{-1}
\end{align*}
$$$`


## averaging
`$$$ 
\begin{align*}
  \frac{1}{z_1-z_0}\int_{z_0}^{z_1} \left( \frac{a+z}{a} \right)^2 \intd{z} &= \frac{1}{a^2(z-z_0)}\int_{z_0}^{z_1} \left( a+z \right)^2 \intd{z}\\
  &= \frac{1}{a^2(z-z_0)}\left[ \frac{\left( a+z \right)^3}{3}\right]_{z_0}^{z_1}\\
  &= \frac{1}{a^2(z_1-z_0)}\left[ \frac{\left( (a+z_1) - (a+z_0) \right) \left( (a+z_1)^2 + (a+z_0)^2 + (a+z_0)(a+z_1)  \right)}{3} \right]\\
  &=  \frac{\left( z_1 - z_0 \right) \left( (a+z_1)^2 + (a+z_0)^2 + (a+z_0)(a+z_1)  \right)}{3a^2(z_1-z_0)} \\
  &=  \frac{1}{3}\left[\left(\frac{a+z_1}{a}\right)^2 + \left(\frac{a+z_0}{a}\right)^2 + \left(\frac{a+z_0}{a}\right)\left(\frac{a+z_1}{a}\right) \right]\\
\end{align*}
$$$`


## With good averaging:
Let `$$ \hat{r}^2(\phi_{iph}, \phi_{imh})$$` be the energy-consistent average found above.

`$$$
\mu_{iph} = \left(\frac{\phi_{iph}/g + R_0}{R_0}\right)^2  \frac{p_{ip1} - p_i}{\Delta\pi_{iph}}
$$$`
with 
`$$$
  \phi_{iph} - \phi_{imh} = \frac{R_0^2}{(\phi_{iph}/g  + R_0)^2 + (\phi_{iph}/g + R_0)(\phi_{imh}/g + R_0) + (\phi_{imh}/g + R_0)^2 } R_d \Theta_i p_0^\kappa p_i^{\kappa-1}
$$$`
We calculate the necessary partial derivatives `$$ \partial_{\phi_{iph+\{-1, 0, 1\}}} \mu_{iph}$$` using symbolic differentiation
in [This notebook](https://colab.research.google.com/drive/1wfTwWYAt4iyODP3m5nTeWUkjBtNCGBT1?usp=sharing)

If we let 
On interior points this gives:
`$$$
   \partial_{\phi_{i-1/2}} \mu_{i+1/2} = \left(\frac{ \phi_{i+1/2}-\phi_{i-1/2}}{(R_d p_0^\kappa \Theta_i \hat{r}_{i}^2 )}\right)^{1/(\kappa - 1)} \frac{((\phi_{i-1/2} - \phi_{i+1/2}) \partial_{\phi_{i-1/2}}[ \hat{r}_i^2] - \hat{r}_i^2)\hat{r}_{i+1/2}^2}{(\pi_{i+1/2}(\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) \hat{r}_{i}^2) }
$$$`

`$$$
   \partial_{\phi_{i+3/2}} \mu_{i+1/2} = \left(\frac{(\phi_{i+3/2} -\phi_{i+1/2})}{(R_d p_0^\kappa\Theta_{i+1} \hat{r}_{i+1}^2 }\right)^{1/(\kappa - 1)}\frac{((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+3/2}} [\hat{r}_{i+1}^2] - \hat{r}_{i+1}^2) \hat{r}_{i+\frac{1}{2}}^2 }{(\pi_{i+1/2} (\kappa - 1)(\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_{i+1}^2} 
$$$`

`$$$
   \partial_{\phi_{i+1/2}} \mu_{i+1/2} = \frac{((\kappa - 1)(\phi_{i+1/2} - \phi_{i-1/2})(\phi_{i+1/2} - \phi_{i+3/2})((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2)})^{1/(\kappa - 1)} - (\frac{( \phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)}) \hat{r}_i^2  \hat{r}_{i+1}^2 \partial_{\phi_{i+1/2}}[\hat{r}_{i+1/2}^2] + ((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)} (\phi_{i+1/2} - \phi_{i+3/2}) ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2) \hat{r}_{i+1}^2 + (\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)} (\phi_{i-1/2} - \phi_{i+1/2}) ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 ) \hat{r}_i^2)  \hat{r}_{i+1/2}^2)}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)}
$$$`

We make the assumption that `$$\partial_{\phi_{i+[]}} [\hat{r}_{[]}^2] = 0$$`

`$$$
\begin{align*}
   \partial_{\phi_{i-1/2}} \mu_{i+1/2} &= \left(\frac{ \phi_{i+1/2}-\phi_{i-1/2}}{(R_d p_0^\kappa \Theta_i \hat{r}_{i}^2 )}\right)^{1/(\kappa - 1)} \frac{(- \hat{r}_i^2)\hat{r}_{i+1/2}^2}{(\pi_{i+1/2}(\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) \hat{r}_{i}^2) }\\
   &= -\left(\frac{ \phi_{i+1/2}-\phi_{i-1/2}}{R_d p_0^\kappa \Theta_i \hat{r}_{i}^2 }\right)^{1/(\kappa - 1)} \frac{\hat{r}_{i+1/2}^2}{\pi_{i+1/2}(\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) }\\
\end{align*}
$$$`

`$$$
\begin{align*}
   \partial_{\phi_{i+3/2}} \mu_{i+1/2} &= \left(\frac{(\phi_{i+3/2} -\phi_{i+1/2})}{(R_d p_0^\kappa\Theta_{i+1} \hat{r}_{i+1}^2) }\right)^{1/(\kappa - 1)}\frac{( - \hat{r}_{i+1}^2) \hat{r}_{i+\frac{1}{2}}^2 }{(\pi_{i+1/2} (\kappa - 1)(\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_{i+1}^2}  \\
   &= -\left(\frac{(\phi_{i+3/2} -\phi_{i+1/2})}{R_d p_0^\kappa\Theta_{i+1} \hat{r}_{i+1}^2 }\right)^{1/(\kappa - 1)}\frac{ \hat{r}_{i+\frac{1}{2}}^2 }{\pi_{i+1/2} (\kappa - 1)(\phi_{i+1/2} - \phi_{i+3/2}) }  \\
\end{align*}
$$$`

`$$$
\begin{align*}
   \partial_{\phi_{i+1/2}} \mu_{i+1/2} &= \frac{((\kappa - 1)(\phi_{i+1/2} - \phi_{i-1/2})(\phi_{i+1/2} - \phi_{i+3/2})((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2)})^{1/(\kappa - 1)} - (\frac{( \phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)}) \hat{r}_i^2  \hat{r}_{i+1}^2 0 + ((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)} (\phi_{i+1/2} - \phi_{i+3/2}) ((\phi_{i-1/2} - \phi_{i+1/2})  0 + \hat{r}_i^2) \hat{r}_{i+1}^2 + (\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)} (\phi_{i-1/2} - \phi_{i+1/2}) ((\phi_{i+3/2} - \phi_{i+1/2}) 0 + \hat{r}_{i+1}^2 ) \hat{r}_i^2)  \hat{r}_{i+1/2}^2)}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)}\\
   &= \frac{( ((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)} (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2 + (\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)} (\phi_{i-1/2} - \phi_{i+1/2}) \hat{r}_{i+1}^2  \hat{r}_i^2)  \hat{r}_{i+1/2}^2)}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)}\\
   &= \frac{( ((\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)} (\phi_{i+1/2} - \phi_{i+3/2}) + (\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)} (\phi_{i-1/2} - \phi_{i+1/2}))  \hat{r}_{i+1/2}^2)}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}))}\\
   &= \frac{(\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)} (\phi_{i+1/2} - \phi_{i+3/2})\hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}))} + \frac{(\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)} (\phi_{i-1/2} - \phi_{i+1/2})  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}))}\\
   &= \frac{(\frac{(\phi_{i+1/2}-\phi_{i-1/2})}{(R_d p_0^\kappa \Theta_i \hat{r}_i^2 )})^{1/(\kappa - 1)}\hat{r}_{i+1/2}^2 }{\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) } + \frac{(\frac{(\phi_{i+3/2}-\phi_{i+1/2})}{(R_d p_0^\kappa \Theta_{i+1} \hat{r}_{i+1}^2)})^{1/(\kappa - 1)}   \hat{r}_{i+1/2}^2}{\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) }\\
\end{align*}
$$$`

This means that, discarding product-rule terms that should be quite small in typical simulations,
my IMEX routine should be nearly correct. Given the ridiculous additional computational expense of 
calculating the product-rule terms, I would suggest omitting them from the operational analytic Jacobian,
leaving a comment noting that these terms were ommitted, and possibly adding a conditional that
uses the numerical Jacobian if the ratio of rearth/rearth0 is sufficiently small.
To determine what "sufficiently small" means, consider `$$\varepsilon =  \partial_z \left[\left(\frac{R_0 + z}{R_0}\right)^2\right] = 2\frac{R_0 + z}{R_0^2}$$`.
Assume that the model top is around 40 km. On a planet of Earth, `$$\varepsilon \approx 0.0003$$`.
On a planet 100x smaller we see `$$\varepsilon \approx 0.05$$`, which is still quite small considering that
an approximate Jacobian typically still gives (slower) convergence. Running HOMME with a 100x reduction is radius is 
quite rare, in any case.


## implementing the hell Jacobian:
`$$$
   \partial_{\phi_{i-1/2}} \mu_{i+1/2} = p_i \frac{((\phi_{i-1/2} - \phi_{i+1/2}) \partial_{\phi_{i-1/2}}[ \hat{r}_i^2] - \hat{r}_i^2)\hat{r}_{i+1/2}^2}{(\pi_{i+1/2}(\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) \hat{r}_{i}^2) }
$$$`

`$$$
   \partial_{\phi_{i+3/2}} \mu_{i+1/2} = p_{i+1} \frac{((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+3/2}} [\hat{r}_{i+1}^2] - \hat{r}_{i+1}^2) \hat{r}_{i+\frac{1}{2}}^2 }{(\pi_{i+1/2} (\kappa - 1)(\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_{i+1}^2} 
$$$`

`$$$
\begin{align*}
   \partial_{\phi_{i+1/2}} \mu_{i+1/2} &= \frac{(\kappa - 1)(\phi_{i+1/2} - \phi_{i-1/2})(\phi_{i+1/2} - \phi_{i+3/2})( p_i - p_{i+1} ) \hat{r}_i^2  \hat{r}_{i+1}^2 \partial_{\phi_{i+1/2}}[\hat{r}_{i+1/2}^2] + ( p_i  (\phi_{i+1/2} - \phi_{i+3/2}) ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2) \hat{r}_{i+1}^2 + p_{i+1}  (\phi_{i-1/2} - \phi_{i+1/2}) ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 ) \hat{r}_i^2)  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)}\\
   &= \frac{(\kappa - 1)(\phi_{i+1/2} - \phi_{i-1/2})(\phi_{i+1/2} - \phi_{i+3/2})( p_i - p_{i+1} ) \hat{r}_i^2  \hat{r}_{i+1}^2 \partial_{\phi_{i+1/2}}[\hat{r}_{i+1/2}^2]}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)} + 
   \frac{ p_i  (\phi_{i+1/2} - \phi_{i+3/2}) ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2) \hat{r}_{i+1}^2 \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)} + 
   \frac{p_{i+1}  (\phi_{i-1/2} - \phi_{i+1/2}) ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 ) \hat{r}_i^2 \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2}) (\phi_{i+1/2} - \phi_{i+3/2}) \hat{r}_i^2 \hat{r}_{i+1}^2)}\\
   &= -\frac{( p_i - p_{i+1} )  \partial_{\phi_{i+1/2}}[\hat{r}_{i+1/2}^2]}{(\pi_{i+1/2}  )} + 
   \frac{ p_i   ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2)  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2})  \hat{r}_i^2 )} + 
   \frac{p_{i+1}   ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 )  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i+1/2} - \phi_{i+3/2})  \hat{r}_{i+1}^2)}\\
\end{align*}
$$$`

so there are three new terms to calculate:
`$$$
\begin{align*}
q_k &= -\frac{( p_i - p_{i+1} )  \partial_{\phi_{i+1/2}}[\hat{r}_{i+1/2}^2]}{(\pi_{i+1/2}  )} \\
d_k &=   \frac{    ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2) }{ \hat{r}_i^2 }\\
e_k &= \frac{  ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 ) }{ \hat{r}_{i+1}^2}\\
\end{align*}
$$$`
Since these all depend on the interface value of `$$\phi_{i+1/2}$$`, we can't reuse any of this.

We make the definitions
`$$$
\begin{align*}
    a &= \frac{(\Delta t g)^2}{1-\kappa} \\
    b_k &= \frac{a}{\Delta \pi_{k+1/2} } \\
    c_k &= \frac{p_k}{\Delta \phi_k}
\end{align*}
$$$`
and 
`$$$
\begin{align*}
\frac{2(a g + \phi_{i+1/2})}{(a^2 g^2)}\\
\frac{(3 a g + \phi_{i-1/2} + 2 \phi_{i+1/2})}{(3 a^2 g^2)}
\end{align*}
$$$`


Top boundary:
`$$$
\begin{align*}
   \partial_{\phi_{1/2}} \mu_{1/2}  &= -\frac{( p_{1/2} - p_{1} )  \partial_{\phi_{1/2}}[\hat{r}_{1/2}^2]}{(\frac{1}{2}\pi_{1}  )} + 
   \frac{ p_i   ((\phi_{i-1/2} - \phi_{i+1/2})  \partial_{\phi_{i+1/2}}[\hat{r}_i^2] + \hat{r}_i^2)  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i-1/2} - \phi_{i+1/2})  \hat{r}_i^2 )} + 
   \frac{p_{i+1}   ((\phi_{i+3/2} - \phi_{i+1/2}) \partial_{\phi_{i+1/2}} [\hat{r}_{i+1}^2 ] + \hat{r}_{i+1}^2 )  \hat{r}_{i+1/2}^2}{(\pi_{i+1/2} (\kappa - 1) (\phi_{i+1/2} - \phi_{i+3/2})  \hat{r}_{i+1}^2)}\\
\end{align*}
$$$`