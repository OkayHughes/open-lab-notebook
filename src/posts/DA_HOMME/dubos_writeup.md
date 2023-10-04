---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Doing the hamiltonian myself
layout: layouts/post.njk
---


We assume that the derivation of the prognostic equations should be fine, aside from the definition of pseudodensity.
We use Dubos and Tort [TD14](https://doi.org/10.1175/MWR-D-14-00069.1) to explain how to get a correct pseudodensity for our equation set in Lagrangian mass coordinates.



# Useful stuff from TD14:

## Pseudodensity in Lagrangian coordinates
We work continuously for the moment. Let `$$\hat{\mu}$$` be the pseudodensity in Eulerian coordinates. The paragraph between Eqn (6) and Eqn (7) gives that `$$\hat{\mu} = \frac{r^2 \cos\phi}{\alpha} = \rho r^2 \cos\phi.$$`
Let `$$\eta$$` be an arbitrary vertical coordinate. Let `$$\xi^3$$` be the vertical Eulerian vertical coordinate. The aforementioned paragraph gives that for spherical geometry `$$\xi^3 \equiv r$$`.

The mass budget, which is quite closely related to the question we want to answer, is governed in Lagrangian coordinates  by
`$$$
\begin{align*}
    0 &= \partial_t \mu + \partial_l (\mu u^l) \\
    \mu &= J\hat{\mu} \\
    J &= \det{\partial_l \xi^k } 
\end{align*}
$$$`

Eqn (24) in TD14 states that pseudodensity under an arbitrary vertical coordinate `$$\eta$$` is 
`$$$
 \begin{align*}
     \mu &= \hat{\mu} \partial_\eta \xi^3 \\
     &= \hat{\mu} \partial_\eta r,
 \end{align*}
 $$$`
which follows from the expression for `$$J$$` and the fact that `$$\lambda, \phi$$` are still Eulerian. Therefore the Jacobian is diagonal, with all entries equal to 1 except for the `$$\partial_\eta r$$` term. 

Now suppose that `$$\eta$$` is specifically the mass-based eta coordinate used by HOMME. It is Lagrangian, i.e. `$$u^3 = \dot{\eta} = 0.$$`

 Let `$$\eta \in [0, 1]$$`. This is defined in terms of
 `$$$
 \begin{align*}
     M(\xi^{1},\xi^2, t) &= \int_0^1 \mu(\xi^{1}, \xi^{2}, \eta) \,\mathrm{d}\eta\\
     \mu &= \partial_\eta [A]M + \partial_\eta[B]
 \end{align*}
 $$$`

 The rather peculiar dependence of `$$\mu$$` on `$$M$$` leads TD14 to claim that `$$M$$` is the quantity which should be used to determine the prognostic equations. TD14 prognoses `$$M$$`. This should be equivalent to calculating it within levels, since we are prognosing `$$\int_{\eta_i}^{\eta_{i+1}} \mu \, \mathrm{d}\eta$$`?
 
 
 TD14 makes the definition `$$\mathcal{H}'[v_i, r, \mu v_3, M, S] = \mathcal{H}[v_i, r, \mu v_3, A'M + B', S].$$` Why is this a problem?}

 Note: Chris's appendix in Tea20 attempts to derive the equations of motion using
 `$$$
 \begin{align*}
     \frac{\delta \mathcal{H}}{\delta \frac{\partial \pi}{\partial s}}
 \end{align*}
 $$$`
 I suspect that the "energetically neutral transport term" of Tea20 `$$\mathcal{V} \cdot \dot{s}$$` rectifies the difference. In any case,


## Miscellany from appendix
`$$$
 \begin{align*}
     M(\xi^{1},\xi^2, t) &= \int_{\textrm{bottom}}^{\textrm{top}} \mu \, \mathrm{d}\eta = \int_{\textrm{bottom}}^{\textrm{top}} \hat{\mu} \, \mathrm{d} r
 \end{align*}
 $$$`

 This uniquely defines the position of `$$r(\xi^1, \xi^2, \eta)$$` according to
 `$$$
 \begin{align*}
     A(\eta) M(\xi^1, \xi^2) + B(\eta) = \int_{r_0}^{r(\eta)}\hat{\mu} \, \mathrm{d}r
 \end{align*}
 $$$`

# Oksana's notes
For the purposes of disambiguation, I'll stick with calling pseudodensity `$$\mu$$` and refer to the pressure adjustment factor (`$$\mu$$` in Oksana's notes) as `$$\psi$$`.

A pseudodensity is simply a quantity which evolves according to a flux-form continuity equaiton. The simplest such density is a rewrite of the continuity equation
`$$$
\begin{align*}
    \rho_t + \nabla \cdot (\rho \mathbf{v}) = 0
\end{align*}
$$$`
and the notes state that from this we could derive `$$(r_sr^2\rho)_\tau + \nabla_s (r^{-1} r_s r^2 \mathbf{u}) + (\dot{s}r_sr^2\rho)_s.$$`
The definition above `$$\mu = \hat{\mu} \partial_s r$$` combined with `$$\hat{\mu} = r^2\rho$$` gives `$$\mu = r_s r^2\rho.$$`

The trouble with defining 
`$$$
\begin{align*}
    \partial_s p_h &= \partial_s [p_h] \partial_r [s] \\
    &= -g\rho r_s \hat{r}^2
\end{align*}
$$$`
is that `$$g = g_0 \hat{r}^{-2}.$$` This implies that the actual pressure _value_ per gridpoint in the deep atmosphere would be essentially the same, but it would represent a fundamentally different quantity.

Ok so the hypsometric equation is hidden in here (assume shallow atm for the moment):
`$$$
\begin{align*}
    &\partial_s \phi = -R_d \partial_s[\pi] \theta_v \frac{\Pi}{p}\\
    \implies& \int \partial_s [\phi] \, \mathrm{d}s = -R_d \int \partial_s[\pi] \theta_v \frac{\Pi}{p} \, \mathrm{d}s\\
    \implies& \Delta \phi = -R_d \int \partial_s[\pi] \theta_v \frac{\Pi}{p} \, \mathrm{d}s\\
    \implies& \Delta \phi = -R_d \int \frac{T}{p} \partial_s[\pi]\, \mathrm{d}s\\
    \implies& \Delta \phi = -R_d \int \frac{T}{p}\, \mathrm{d}\pi\\
\end{align*}
$$$`
Assuming `$$T=T_0$$`  and `$$p=\pi,$$` then we get the standard hydrostatic hypsometric equation.



## Following Quasi-hamiltonian derivation in [Tea20](https://doi.org/10.1029/2019MS001783)

The definition for the mass coordinate is
`$$$
\begin{align*}
    \pi \equiv A(\eta) p_0 + B(\eta) p_s
\end{align*}
$$$`

which allows us to back out that 
`$$$
\begin{align*}
    \dot{\eta} \partial_\eta \pi = B(\eta) \int_{\eta_{\textrm{top}}}^{1} \nabla_{\eta}\cdot \partial_{\eta} [\pi ] \mathbf{u} \intd{\eta} - \int_{\eta_{\textrm{top}}}^{\eta} \nabla_\eta \cdot \partial_\eta [\pi] \mathbf{u} \intd{s} 
\end{align*}
$$$`

Assuming that `$$\pi$$` is defined with respect to the deep atmosphere, I see no problems with this so far.

The components to assemble the equation of state include 
`$$$
\begin{align*}
    \partial_{\eta}[\pi] \partial_{z} [\eta] &= -\rho g\\
    &= -\partial_{\eta} [\pi] \left(\partial_{\eta} [gz] \right)^{-1} \cdot g
\end{align*}
$$$`

## Mass integrals:
### Shallow:
`$$$
\begin{align*}
    \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \rho X \intd{z} &= \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \partial_{\eta} [\pi] \left(\partial_{\eta} [g_0z] \right)^{-1}  X \intd{z}\\
    &= g_0^{-1} \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \partial_{\eta} [\pi] \partial_{z} [\eta]  X \intd{z}\\
    &= g_0^{-1} \int_{\eta_\textrm{top}}^{\eta_{\textrm{surf}}} \partial_{\eta} [\pi]  X \intd{\eta}
\end{align*}
$$$`
which demonstrates the shallow atmosphere identity from the paper. 
### Deep:
Let's do this for the deep atmosphere in a naive way:
`$$$
\begin{align*}
    \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \rho X \intd{z} &= \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \partial_{\eta} [\pi] \left(\partial_{\eta} \left[g_0\frac{zR_0^2}{(R_0+z)^2}\right] \right)^{-1}  X \intd{z}
\end{align*}
$$$`
which is garbage. But can we get further if we don't expand geopotential (it's still monotonic in `$$\eta$$` so we can use the inverse function theorem)
`$$$
\begin{align*}
    \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \rho X \intd{z} &= \int_{z_\textrm{surf}}^{z_{\textrm{top}}} \partial_{\eta} [\pi] \partial_{\phi} \left[\eta \right]  X \intd{z}
\end{align*}
$$$`
which invites the question whether the physical integral on the LHS can be restated in terms of geopotential.
`$$$
\begin{align*}
    \int_{z_{\textrm{bot}}}^{z_{\textrm{top}}} \rho X \intd{z} &= \int_{\phi_{\textrm{bot}}}^{\phi_{\textrm{top}}} \rho \left(\partial_{z} [\phi]\right)^{-1} X \intd{\phi} \\
    &= \int_{\phi_{\textrm{bot}}}^{\phi_{\textrm{top}}} \partial_{\eta} [\pi] \partial_{\phi} [\eta] \left(\partial_{z} [\phi]\right)^{-1} X \intd{\phi} \\
    &= \int_{\eta_{\textrm{top}}}^{\eta_{\textrm{bot}}} \partial_{\eta} [\pi] \left(\partial_{z} [\phi]\right)^{-1} X \intd{\eta} \\
\end{align*}
$$$`
where 
`$$$
\begin{align*}
    \partial_z [\phi] &= g'(z) z + g(z)
\end{align*}
$$$`
where 
`$$$
\begin{align*}
    &g'(z)z = -R_0^2 z\frac{2}{(R_0+z)^3}\\
    \implies& |g'(z) z| \approx 0.024 \textrm{~m~s}^{-2}
\end{align*}
$$$`
so in assuming that `$$\left(\partial_z \phi\right)^{-1} = \frac{1}{g_0}$$` we incur a 0.3% multiplicative error.

## The Hamiltonian derivation
Kinetic, internal, and potential energy are supposedly given by 
`$$$
\begin{align*}
    K = \frac{1}{2} \partial_{\eta} [\pi] \mathbf{v}^2, \qquad I = c_p \Theta \Pi - \partial_{\eta} [\pi] \frac{1}{\rho} p + p_{\textrm{top}} \phi_{\textrm{top}} \qquad P = \partial_{\eta} [\pi] \phi
\end{align*}
$$$`
and note that `$$p_{\textrm{top}}$$` is really a hydrostatic `$$p$$`. This section simply notes that `$$\intd{A}$$` is an "area" metric. This has no radial dependence in the shallow atmosphere but (in the most naive formulation) gains a radial dependence in the deep atmosphere. 
Note: no functional derivatives with respect to non-hydrostatic pressure `$$p$$` are sought. Due to the EOS `$$p$$` is subjugated by`$$\phi$$`.  

Therefore define
`$$$
\begin{align*}
    \mathcal{H} = \iint \textcolor{#2a3d45}{\stackrel{(1)}{\frac{1}{2} \partial_{\eta} [\pi](\langle \mathbf{u}, \mathbf{u}\rangle + w^2)}} + \textcolor{#DDC9B4}{\stackrel{(2)}{c_p  \Theta \Pi + \partial_{\eta} [\phi] p + p_{\textrm{top}} \phi_{\textrm{top}}}} + \textcolor{#C17C74}{\stackrel{(3)}{\partial_{\eta} [\pi] \phi}}  \intd{A} \intd{\eta}
\end{align*}
$$$`
and we do the typical algebraic shenanigans and discard second-order terms:
`$$$
\begin{align*}
    \textcolor{#2a3d45}{(1)}:&\frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u} + \delta \mathbf{u}, \mathbf{u} + \delta \mathbf{u} \rangle + (w + \delta w)^2)\\
    =&  \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle + \langle  \delta \mathbf{u}, \delta \mathbf{u} \rangle + w^2 + 2w\delta w + \delta w^2)\\
    =& \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle  + w^2 + 2w\delta w ) + \mathcal{O}(\varepsilon^2)\\
    =& \frac{1}{2} \partial_{\eta}[\pi]( \langle \mathbf{u}, \mathbf{u} \rangle + w^2) + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) + \delta \left[\partial_{\eta} [\pi]\right] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w\delta w) + \mathcal{O}(\varepsilon^2)\\
    =& K + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) +\mathcal{O}(\varepsilon^2) \\
    =& K +  \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right] +\mathcal{O}(\varepsilon^2) \\
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#DDC9B4}{(2)}:& c_p (\Theta + \delta \Theta) \Pi + (\partial_{\eta} [\phi] + \delta [\partial_{\eta} [\phi]]) p + p_{\textrm{top}} (\phi_{\textrm{top}} + \delta \phi_{\textrm{top}}) \\
    =& c_p \Theta \Pi + \partial_{\eta} [\phi] p + p_{\textrm{top}}\phi_{\textrm{top}} + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] \\
    =& I + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}]
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#C17C74}{(3)}:& (\partial_\eta [\pi] + \delta [\partial_{\eta}[\pi]])(\phi + \delta \phi) \\
    =& \partial_{\eta}[\pi] \phi + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] + \delta[\partial_{\eta}[\pi]] \delta \phi \\
    =& P + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] +\mathcal{O}(\varepsilon^2)
\end{align*}
$$$`
giving 
`$$$
\begin{align*}
    \delta \mathcal{H} &= \lim_{\varepsilon \to 0} \frac{\mathcal{H}(\mathbf{u} + \varepsilon \delta \mathbf{u}, w + \varepsilon \delta w, \phi + \varepsilon \delta \phi, \Theta + \delta \Theta, \partial_{\eta}[\pi] + \delta[\partial_{\eta}[\pi]] )- \mathcal{H}(\mathbf{u}, w, \phi , \Theta , \partial_{\eta}[\pi] )}{\varepsilon}\\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] \intd{A} \intd{\eta} \\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
and we rewrite
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int \int p\delta[\partial_{\eta}[\phi]] \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int [p \delta \phi]_{\eta = \eta_{\textrm{top}}}^{\eta = 1} - \int \partial_{\eta} [p] \delta \phi \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}} - p_{\textrm{top}}\delta\phi_{\textrm{top}} + p_{\textrm{top}} \delta \phi_{\textrm{top}} - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}
$$$`
and we now note that `$$\delta \phi_{\textrm{bot}} = 0$$` due to the stationary topography at the lower boundary condition. Therefore
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}}  - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
    &= \int \int -\partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}.
$$$`
where we have relied on the fact that `$$\partial_{\eta} \delta \phi = \delta \partial_{\eta} \phi$$`. We can return to the total functional differential to find
`$$$
\begin{align*}
    \delta \mathcal{H} &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + (\partial_{\eta} [\pi] - \partial_{\eta} [p]) \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
which gives
`$$$
\begin{align*}
    \fder{\mathcal{H}}{\mathbf{u}} &= \partial_{\eta}[\pi] \mathbf{u}\\
    \fder{\mathcal{H}}{w} &= \partial_{\eta} [\pi] w \\
    \fder{\mathcal{H}}{\phi} &= \partial_{\eta} [\pi] - \partial_{\eta} [p]\\
    \fder{\mathcal{H}}{\Theta} &= c_p \Pi \\
    \fder{\mathcal{H}}{\partial_{\eta} [\pi]} &= \frac{\mathbf{u}^2 + w^2}{2} + \phi
\end{align*}
$$$`
which agrees precisely with Tea20. However: does the integration by parts trickery work if we do the pseudodensity trick instead of modifying `$$\mathrm{d}A$$`?

## Rectifying pseudodensity using TD14:
A fundamental property of our pseudodensity is that 
`$$$
\begin{align*}
m_s = \frac{p_s}{g} &= \int_0^1 \mu \intd{\eta} 
\end{align*}
$$$`
and TD14 suggests that we define `$$\mu = \partial_{\eta} (A) M + \partial_{\eta} (B) M_0 $$`. Let's validate that this works:
`$$$
\begin{align*}
    \int_0^1 \partial_{\eta} (A) M + \partial_{\eta} (B) \intd{\eta} &= \left[A\right]_{\eta=0}^{\eta =1} M + \left[B\right]_{\eta=0}^{\eta =1} \\
    &= M 
\end{align*}
$$$`
so this constrains that the `$$ \textrm{dp3d} = p_s\Delta A  + p_0 \Delta B = g_0(m_s \Delta A + m_0 \Delta B)$$`.
Dividing by `$$g_0$$`, even in the deep atmosphere, gives the _mass_ located between particular model levels.
This means that the correct generalization to the deep atmosphere is `$$$ \textrm{dp3d} = g_0 \frac{a^2}{(a+z)^2} (m_s \Delta A + m_0 \Delta B)$$$`
This would make the value of `$$\sum \textrm{dp3d}$$` coincide with the mass-weighted integral. However, this means
that the `$$g$$` correction really must be inside the integral. 




## Curl form for mass coordinates in TD14:
In TD14 notation we have
`$$$
\begin{align*}
  \partial_t M + \partial_i \int \fder{\mathcal{H}'}{v_i} \intd{\eta} &= 0 \\
  \partial_t S + \partial_i \left(s \fder{\mathcal{H}'}{v_i} \right) + \partial_{\eta} \left( S \dot{\eta} \right) &= 0 \\
  \partial_{t} v_i + (\partial_\eta v_i - \partial_i v_3) \dot{\eta} + \frac{\partial_j v_i - \partial_i v_j}{\mu} \fder{\mathcal{H'}}{v_j} + \partial_i \left( \fder{\mathcal{H}}{\mu} + \dot{\eta} v_3 \right) + s \partial_i \left(\fder{\mathcal{H}'}{S} \right) &= 0\\
  \partial_t V_3 + \partial_{\eta} (V_3 \dot{\eta}) + \fder{\mathcal{H}'}{\xi^3} = 0\\
  \partial_t \xi^3 + \dot{\eta} \partial_{\eta} \xi^3 - \fder{\mathcal{H}'}{V_3} = 0
\end{align*}
$$$`
where
`$$$
\begin{align*}
V_3 &\equiv \mu \hat{v}_3 \\
v_i &\equiv \hat{v}_i + \hat{v}_3 \partial_i \xi^3 \\
\hat{v_l} &\equiv \pder{\hat{L}}{\hat{u}^l}.
\end{align*}
$$$`
We note that `$$\xi^3 = r$$`.

Tea20 makes the definition `$$\mu = \partial_{\eta} [A] M + \partial_{\eta} [B]$$`. With this definition
`$$$
\begin{align*}
 \partial_t M + \partial_i \int \fder{\mathcal{H}'}{v_i} \intd{\eta} &= \partial_t \int \mu \intd{\eta} + \partial_i \int \mu u_i \intd{\eta}
\end{align*}
$$$`
which is quite straightforwardly the continuity equation in weak form. It remains to show that (43) and (44) in TD14 are satisfied by this definition,
but I suspect they are.

Let's examine
`$$$
\begin{align*}
  \int \partial_{\eta} 
\end{align*}
$$$`

<!--
## Hamiltonian formulation for `$$M$$`


Kinetic, internal, and potential energy are supposedly given by 
`$$$
\begin{align*}
    K = \frac{1}{2} (A' M + B' M_0) \mathbf{v}^2, \qquad I = c_p \Theta \Pi - (A'M + B' M_0) \frac{1}{\rho} p + p_{\textrm{top}} \phi_{\textrm{top}} \qquad P = (A'M + B' M_0) \phi
\end{align*}
$$$`
and note that `$$p_{\textrm{top}}$$` is really a hydrostatic `$$p$$`. This section simply notes that `$$\intd{A}$$` is an "area" metric. This has no radial dependence in the shallow atmosphere but (in the most naive formulation) gains a radial dependence in the deep atmosphere. 
Note: no functional derivatives with respect to non-hydrostatic pressure `$$p$$` are sought. Due to the EOS `$$p$$` is subjugated by`$$\phi$$`.  

Therefore define
`$$$
\begin{align*}
    \mathcal{H} = \iint \textcolor{#2a3d45}{\stackrel{(1)}{\frac{1}{2} (A'M + B')(\langle \mathbf{u}, \mathbf{u}\rangle + w^2)}} + \textcolor{#DDC9B4}{\stackrel{(2)}{c_p  \Theta \Pi + \partial_{\eta} [\phi] p + B_{top} M_0 \phi_{\textrm{top}}}} + \textcolor{#C17C74}{\stackrel{(3)}{\partial_{\eta} [\pi] \phi}}  \intd{A} \intd{\eta}
\end{align*}
$$$`
and we do the typical algebraic shenanigans and discard second-order terms:
`$$$
\begin{align*}
    \textcolor{#2a3d45}{(1)}:&\frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u} + \delta \mathbf{u}, \mathbf{u} + \delta \mathbf{u} \rangle + (w + \delta w)^2)\\
    =&  \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle + \langle  \delta \mathbf{u}, \delta \mathbf{u} \rangle + w^2 + 2w\delta w + \delta w^2)\\
    =& \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle  + w^2 + 2w\delta w ) + \mathcal{O}(\varepsilon^2)\\
    =& \frac{1}{2} \partial_{\eta}[\pi]( \langle \mathbf{u}, \mathbf{u} \rangle + w^2) + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) + \delta \left[\partial_{\eta} [\pi]\right] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w\delta w) + \mathcal{O}(\varepsilon^2)\\
    =& K + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) +\mathcal{O}(\varepsilon^2) \\
    =& K +  \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right] +\mathcal{O}(\varepsilon^2) \\
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#DDC9B4}{(2)}:& c_p (\Theta + \delta \Theta) \Pi + (\partial_{\eta} [\phi] + \delta [\partial_{\eta} [\phi]]) p + p_{\textrm{top}} (\phi_{\textrm{top}} + \delta \phi_{\textrm{top}}) \\
    =& c_p \Theta \Pi + \partial_{\eta} [\phi] p + p_{\textrm{top}}\phi_{\textrm{top}} + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] \\
    =& I + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}]
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#C17C74}{(3)}:& (\partial_\eta [\pi] + \delta [\partial_{\eta}[\pi]])(\phi + \delta \phi) \\
    =& \partial_{\eta}[\pi] \phi + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] + \delta[\partial_{\eta}[\pi]] \delta \phi \\
    =& P + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] +\mathcal{O}(\varepsilon^2)
\end{align*}
$$$`
giving 
`$$$
\begin{align*}
    \delta \mathcal{H} &= \lim_{\varepsilon \to 0} \frac{\mathcal{H}(\mathbf{u} + \varepsilon \delta \mathbf{u}, w + \varepsilon \delta w, \phi + \varepsilon \delta \phi, \Theta + \delta \Theta, \partial_{\eta}[\pi] + \delta[\partial_{\eta}[\pi]] )- \mathcal{H}(\mathbf{u}, w, \phi , \Theta , \partial_{\eta}[\pi] )}{\varepsilon}\\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] \intd{A} \intd{\eta} \\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
and we rewrite
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int \int p\delta[\partial_{\eta}[\phi]] \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int [p \delta \phi]_{\eta = \eta_{\textrm{top}}}^{\eta = 1} - \int \partial_{\eta} [p] \delta \phi \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}} - p_{\textrm{top}}\delta\phi_{\textrm{top}} + p_{\textrm{top}} \delta \phi_{\textrm{top}} - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}
$$$`
and we now note that `$$\delta \phi_{\textrm{bot}} = 0$$` due to the stationary topography at the lower boundary condition. Therefore
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}}  - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
    &= \int \int -\partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}.
$$$`
where we have relied on the fact that `$$\partial_{\eta} \delta \phi = \delta \partial_{\eta} \phi$$`. We can return to the total functional differential to find
`$$$
\begin{align*}
    \delta \mathcal{H} &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + (\partial_{\eta} [\pi] - \partial_{\eta} [p]) \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
which gives
`$$$
\begin{align*}
    \fder{\mathcal{H}}{\mathbf{u}} &= \partial_{\eta}[\pi] \mathbf{u}\\
    \fder{\mathcal{H}}{w} &= \partial_{\eta} [\pi] w \\
    \fder{\mathcal{H}}{\phi} &= \partial_{\eta} [\pi] - \partial_{\eta} [p]\\
    \fder{\mathcal{H}}{\Theta} &= c_p \Pi \\
    \fder{\mathcal{H}}{\partial_{\eta} [\pi]} &= \frac{\mathbf{u}^2 + w^2}{2} + \phi
\end{align*}
$$$`
which agrees precisely with Tea20. However: does the integration by parts trickery work if we do the pseudodensity trick instead of modifying `$$\mathrm{d}A$$`?

-->

## The Hamiltonian derivation for Oksana's notes
Kinetic, internal, and potential energy are supposedly given by 
`$$$
\begin{align*}
    K = \frac{1}{2}  \partial_{\eta} [\pi]_{\hat{r}^2} \mathbf{v}^2, \qquad I = c_p \Theta \Pi - \partial_{\eta} [\pi]_{\hat{r}^2} \frac{1}{\rho} p + p_{\textrm{top}} \phi_{\textrm{top}} \qquad P = \partial_{\eta} [\pi]_{\hat{r}^2} \phi
\end{align*}
$$$`
and note that `$$p_{\textrm{top}}$$` is really a hydrostatic `$$p$$`. Since `$$\Theta = \partial_{\eta} [\pi] \theta_v$$`, terms containing `$$\Theta$$` gain a correction.
This time we are rather more careful, noting that if 
`$$$
\begin{align*}
\partial_{\eta} \phi &= -R_d \partial_{\eta} [\pi]_{\hat{r}^2} \theta_v \frac{\Pi}{p} \\
  &= -\frac{R_d}{p} \theta_v\frac{T_v}{\theta_v} \partial_{\eta} [\pi]_{\hat{r}^2} \\
  &= -\frac{1}{\rho} \partial_{\eta} [\pi]_{\hat{r}^2}.
\end{align*}.
$$$`  

Therefore define
`$$$
\begin{align*}
    \mathcal{H} = \iint \textcolor{#2a3d45}{\stackrel{(1)}{\frac{1}{2}  \hat{r}^2 \partial_{\eta} [\pi](\langle \mathbf{u}, \mathbf{u}\rangle + w^2)}} + \textcolor{#DDC9B4}{\stackrel{(2)}{c_p \hat{r}^2 \Theta \Pi + \partial_{\eta} [\phi] p + p_{\textrm{top}} \phi_{\textrm{top}}}} + \textcolor{#C17C74}{\stackrel{(3)}{\partial_{\eta} [\pi] \phi}}  \intd{A} \intd{\eta}
\end{align*}
$$$`
and we do the typical algebraic shenanigans and discard second-order terms:
`$$$
\begin{align*}
    \textcolor{#2a3d45}{(1)}:&\frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u} + \delta \mathbf{u}, \mathbf{u} + \delta \mathbf{u} \rangle + (w + \delta w)^2)\\
    =&  \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle + \langle  \delta \mathbf{u}, \delta \mathbf{u} \rangle + w^2 + 2w\delta w + \delta w^2)\\
    =& \frac{1}{2} (\partial_{\eta} [\pi] + \delta \left[\partial_{\eta} [\pi]\right])(\langle \mathbf{u}, \mathbf{u} \rangle + 2 \langle \delta \mathbf{u}, \mathbf{u} \rangle  + w^2 + 2w\delta w ) + \mathcal{O}(\varepsilon^2)\\
    =& \frac{1}{2} \partial_{\eta}[\pi]( \langle \mathbf{u}, \mathbf{u} \rangle + w^2) + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) + \delta \left[\partial_{\eta} [\pi]\right] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w\delta w) + \mathcal{O}(\varepsilon^2)\\
    =& K + \partial_{\eta} [\pi] (\langle \delta \mathbf{u}, \mathbf{u} \rangle + w \delta w) + \frac{1}{2} \delta \left[\partial_{\eta} [\pi]\right] (\langle \mathbf{u}, \mathbf{u}) + w^2) +\mathcal{O}(\varepsilon^2) \\
    =& K +  \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right] +\mathcal{O}(\varepsilon^2) \\
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#DDC9B4}{(2)}:& c_p (\Theta + \delta \Theta) \Pi + (\partial_{\eta} [\phi] + \delta [\partial_{\eta} [\phi]]) p + p_{\textrm{top}} (\phi_{\textrm{top}} + \delta \phi_{\textrm{top}}) \\
    =& c_p \Theta \Pi + \partial_{\eta} [\phi] p + p_{\textrm{top}}\phi_{\textrm{top}} + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] \\
    =& I + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}]
\end{align*}
$$$`
and
`$$$
\begin{align*}
    \textcolor{#C17C74}{(3)}:& (\partial_\eta [\pi] + \delta [\partial_{\eta}[\pi]])(\phi + \delta \phi) \\
    =& \partial_{\eta}[\pi] \phi + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] + \delta[\partial_{\eta}[\pi]] \delta \phi \\
    =& P + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] +\mathcal{O}(\varepsilon^2)
\end{align*}
$$$`
giving 
`$$$
\begin{align*}
    \delta \mathcal{H} &= \lim_{\varepsilon \to 0} \frac{\mathcal{H}(\mathbf{u} + \varepsilon \delta \mathbf{u}, w + \varepsilon \delta w, \phi + \varepsilon \delta \phi, \Theta + \delta \Theta, \partial_{\eta}[\pi] + \delta[\partial_{\eta}[\pi]] )- \mathcal{H}(\mathbf{u}, w, \phi , \Theta , \partial_{\eta}[\pi] )}{\varepsilon}\\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \frac{1}{2}  (\langle \mathbf{u}, \mathbf{u}\rangle + w^2) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi + \phi \delta [\partial_{\eta}[\pi]] \intd{A} \intd{\eta} \\
    &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + p \delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta[\phi_{\textrm{top}}] + \partial_{\eta} [\pi] \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
and we rewrite
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int \int p\delta[\partial_{\eta}[\phi]] \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int [p \delta \phi]_{\eta = \eta_{\textrm{top}}}^{\eta = 1} - \int \partial_{\eta} [p] \delta \phi \intd{\eta}  + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \\
    &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}} - p_{\textrm{top}}\delta\phi_{\textrm{top}} + p_{\textrm{top}} \delta \phi_{\textrm{top}} - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}
$$$`
and we now note that `$$\delta \phi_{\textrm{bot}} = 0$$` due to the stationary topography at the lower boundary condition. Therefore
`$$$
\begin{align*}
    \int \int p\delta[\partial_{\eta}[\phi]] + p_{\textrm{top}} \delta \phi_{\textrm{top}} \intd{A} \intd{\eta} &= \int p_{\textrm{bot}}\delta\phi_{\textrm{bot}}  - \int \partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
    &= \int \int -\partial_{\eta} [p] \delta \phi \intd{\eta} \intd{A} \\
\end{align*}.
$$$`
where we have relied on the fact that `$$\partial_{\eta} \delta \phi = \delta \partial_{\eta} \phi$$`. We can return to the total functional differential to find
`$$$
\begin{align*}
    \delta \mathcal{H} &= \iint \langle \partial_{\eta} [\pi]  \mathbf{u}, \delta \mathbf{u} \rangle + \partial_{\eta} [\pi] w \delta w + \left(  \frac{\langle \mathbf{u}, \mathbf{u}\rangle + w^2}{2} + \phi \right) \delta \left[\partial_{\eta} [\pi]\right]  + c_p \Pi \delta \Theta  + (\partial_{\eta} [\pi] - \partial_{\eta} [p]) \delta \phi \intd{A} \intd{\eta}.
\end{align*}
$$$`
which gives
`$$$
\begin{align*}
    \fder{\mathcal{H}}{\mathbf{u}} &= \partial_{\eta}[\pi] \mathbf{u}\\
    \fder{\mathcal{H}}{w} &= \partial_{\eta} [\pi] w \\
    \fder{\mathcal{H}}{\phi} &= \partial_{\eta} [\pi] - \partial_{\eta} [p]\\
    \fder{\mathcal{H}}{\Theta} &= c_p \Pi \\
    \fder{\mathcal{H}}{\partial_{\eta} [\pi]} &= \frac{\mathbf{u}^2 + w^2}{2} + \phi
\end{align*}
$$$`
which agrees precisely with Tea20. However: does the integration by parts trickery work if we do the pseudodensity trick instead of modifying `$$\mathrm{d}A$$`?



Todo tomorrow:
  * Disambiguate pressure/mass at the surface (i.e. do continuum integral for dp3d)
  * Either perform derivation of Hamiltonian using A'M+B'M_0 formulation or plug in Oksana's cheats and check cancelation.