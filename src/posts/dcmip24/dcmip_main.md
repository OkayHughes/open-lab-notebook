---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Idealized eta coordinates
  parent: DCMIP 2024
layout: layouts/post.njk
---


## Main content:

We're going to follow the strategy outlined in DCMIP 2008.
We use the definition `$$ p(\eta) = A(\eta) p_0 + B(\eta) p_s$$`

1. Establishing a reference temperature profile `$$T(z)$$`.
2. Use this to determine pressure levels `$$p_{\textrm{int}, k} = p(z_{\textrm{int}, k}) $$`
4. Define `$$A(\eta) = \eta - B(\eta)$$`, and `$$ B = \left(\frac{\eta - \eta_{\textrm{top}}}{1 - \eta_{\textrm{top}}}\right)^c$$`, `$$\eta(z) \equiv \frac{p(z)}{p_s}$$`
5. Calculate full model levels by averaging interfaces.

We will be using `$$c \equiv 1$$`.


## special considerations:
Suppose we want `$$ \Delta z(p) $$` to have a specific (approximate) height profile, e.g. [in Skamarock, et al.](https://journals.ametsoc.org/view/journals/mwre/147/7/mwr-d-19-0043.1.xml).
Suppose we have already found `$$ p_k, k=K+1, \dots, k$$` (`$$\eta_{\textrm{top}} $$` is a free parameter, while bad things happend if `$$ \eta_{s}\neq 1$$`)

Assume the atmosphere is in hydrostatic balance.
Under a constant lapse rate, `$$ p(z) = p_0 \left(\frac{T_0 - \Gamma z}{T_0}\right)^{\frac{g}{\Gamma R_d}}$$`
The temperature is then `$$T(p) = T_0 \left(\frac{p}{p_0} \right)^{-\frac{R_d \Gamma}{g}} $$`,
and the height is `$$z(p) = \frac{T_0}{\Gamma} \left[1 - \left( \frac{p}{p_0} \right)^{\frac{R_d \Gamma}{g}} \right] $$`

Suppose we have `$$p_{\textrm{int}, k+1}, z_{\textrm{int}, k+1}$$`.

Note `$$ \eta_{\textrm{mid}, k} = \frac{1}{2}\left(\frac{p_{\textrm{int},k+1}}{p_s} + \frac{p_{\textrm{int}, k}}{p_s}\right)  $$`

The equation we want to solve is `$$ \Delta z\left(\frac{p_{\textrm{int}, k+1} + p_{\textrm{int, k}}}{2} \right) = z(p_{\textrm{int}, k}) - z(p_{\textrm{int}, k+1})$$`

The equation that's easy to solve is `$$ \Delta z\left(p_{\textrm{int, k+1}} \right) = z(p_{\textrm{int}, k}) - z(p_{\textrm{int}, k+1}) $$`,
or `$$p_{k+1} = p(\Delta z\left(p_{\textrm{int, k+1}}) +z(p_{\textrm{int}, k+1}) \right) $$`

This is an approximation, but we are making several other approximations that won't hold since we have topography.




## Brief digression:
Under the profile `$$T(z) = T_0$$`, the pressure looks like `$$ p = p_0 \exp\left(\frac{z}{R_d T_0 g^{-1}} \right)$$`
while under `$$T(z) = T_0 - \Gamma z$$` the pressure looks like `$$p = p_0\left(\frac{T_0 - \Gamma z}{T_0} \right)^{\frac{g}{R_d \Gamma}} $$`.
The fact that these don't immediately agree when `$$\Gamma = 0$$` has always irritated me. Here's why that is:

An intermediate step in integrating the hydrostatic integral reads
`$$$
\begin{align*}
  \log(p) &= \log(p_0) +  \log\left(\left[\frac{T_0 - \Gamma z}{T_0} \right]^{\frac{g}{R_d \Gamma}} \right) \\
  &= \log(p_0) +  \frac{\log\left(\left[\frac{T_0 - \Gamma z}{T_0} \right]^{\frac{g}{R_d}} \right)}{\Gamma}
\end{align*}
$$$`

Noting that the numerator and denominator are both differentiable functions of `$$\Gamma$$`, we then find 
`$$$ 
\begin{align*}
  \lim_{\Gamma \to 0^+} \log(p/p_0) = \log(p/p_0) &= \lim_{\Gamma \to 0^+} \frac{\log\left(\left[\frac{T_0 - \Gamma z}{T_0} \right]^{\frac{g}{R_d}} \right)}{\Gamma}  \\
  &= \lim_{\Gamma \to 0^+} \frac{\partial_\Gamma \left[\frac{g}{R_d}\log\left(\frac{T_0 - \Gamma z}{T_0} \right)\right]}{\partial_\Gamma \Gamma} \\
  &= \lim_{\Gamma \to 0^+} \frac{g}{R_d}\cdot -\frac{z}{T_0}\cdot\frac{T_0}{T_0 - \Gamma z} \\
  &= -\frac{z}{R_d T_0 g^{-1}}
\end{align*}
$$$`

Unfortunately, this makes it very difficult to find, e.g., a unified expression for `$$p(z)$$` that agrees in both cases in floating point arithmetic :(.
