---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Testing the hypothesis that it's a lamb wave
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---


##The mathematics of lamb waves
In the atmosphere there is a special kind of acoustic wave called a Lamb wave, which is a horizontally propagating sound wave 
with no vertical velocity propagation (`$$w'$$` = 0). They are supported by a hydrostatic equation set. It has been observed that the amplitudes of the oscillations of a Lamb wave vary with height.

Use the equations: `$$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)u'  + \frac{1}{\overline{\rho}} \pder{p'}{x} = 0 $$$`
    \left(\pder{}{t} + \overline{u} \pder{}{x} \right)p'  + \gamma \overline{p} \pder{u'}{x}  &= 0
\end{align*}

and

\begin{align*}
    \pder{p'}{z} &= -\rho' g \\
    \left(\pder{}{t} + \overline{u} \pder{}{x} \right) \rho' + \overline{\rho} \pder{u'}{x} &= 0 
\end{align*}

$\overline{p}(z)$,  $\overline{\rho}(z)$ depend on height, $\overline{u}$ is constant, $\overline{T}$ is isothermal, and $\gamma \equiv c_p/c_v$

\subsection*{Derive the physical solutions for the Lamb wave equations for $p', u', \rho'$ assuming that the pressure perturbation has the form $p' = \hat{p}\exp(ik(x - ct))$, $\hat{p}(z=0) = p_{00}$}


We start by writing 

\begin{align*}
    -\frac{1}{g}\pder{p'}{z} &= \rho' \\
\end{align*}
and eliminate $\rho'$ in the last equation:
\begin{align*}
    -\frac{1}{g}\left(\pder{}{t} + \overline{u} \pder{}{x} \right) \pder{p'}{z} + \overline{\rho} \pder{u'}{x} &= 0 
\end{align*}

We multiply through by $-g$ to get 

\begin{align*}
    \left(\pder{}{t} + \overline{u} \pder{}{x} \right) \pder{p'}{z} -g \overline{\rho} \pder{u'}{x} &= 0 
\end{align*}

Before we go further that if $\rho = \overline{\rho} + \rho'$ and $p = \overline{p} + p',$ then we find that $\pder{p}{z} = - \rho g$ which gives us $\pder{p'}{z} + \pder{\overline{p}}{z} = - g \left(\overline{\rho} + \rho' \right)$ and using what we know about $\rho'$ and $p'$ we get that $\pder{\overline{p}}{z} = -g\overline{\rho}$ which should be true just from physical intuition. We note that $\gamma \neq 0$ and $\overline{p} \neq 0$ and thus
\begin{align*}
    \overline{p} \gamma \left(\pder{}{t} + \overline{u} \pder{}{x} \right) \pder{p'}{z} - g \gamma \overline{p} \overline{\rho}  \pder{u'}{x} &= 0 \\
        g \overline{\rho} \left(\pder{}{t} + \overline{u} \pder{}{x} \right)p'  + g \gamma \overline{\rho} \overline{p} \pder{u'}{x}  &= 0
\end{align*}

and we add these equations to get 

\begin{align*}    
    \overline{p} \gamma \left(\pder{}{t} + \overline{u} \pder{}{x} \right) \pder{p'}{z} + g \overline{\rho} \left(\pder{}{t} + \overline{u} \pder{}{x} \right)p'  &= 0 \\
    \left(\pder{}{t} + \overline{u} \pder{}{x} \right)u'  + \frac{1}{\overline{\rho}} \pder{p'}{x} &= 0
\end{align*}

Which allows us to solve for $p'$ (note we started with 3 equations and 4 unknowns) and then back-substitute to get other values: assume that $p' = \hat{p}\exp(ik(x - ct))$ $\hat{p}(z=0) = p_{00}$ and get

\begin{align*}
    i\overline{p}\gamma\left( -kc + \overline{u}k \right)\left(\pder{\hat{p}}{z} \right)\Psi + ig\overline{\rho} \left( k\overline{u} - k c\right)\hat{p}\Psi = 0
\end{align*}

and therefore we find the following:

\begin{align*}
    ik\overline{p}\gamma\left( \overline{u} -c \right)\left(\pder{\hat{p}}{z} \right)\Psi + ik g\overline{\rho} \left( \overline{u} - c\right)\hat{p}\Psi = 0
\end{align*}

and by canceling we find:
\begin{align*}
    &\qquad \overline{p}\gamma\left(\pder{\hat{p}}{z} \right) +  g\overline{\rho}\hat{p}  = 0\\
    &\implies \left(\pder{\hat{p}}{z} \right)   = -\frac{g\overline{\rho}}{\overline{p}\gamma}\hat{p}
\end{align*}

and we use the ideal gas law to find $\overline{p} = \overline{\rho} R_d \overline{T} \implies \frac{\overline{p}}{\overline{\rho}} =  R_d \overline{T}$ and therefore

\begin{align*}
         \left(\pder{\hat{p}}{z} \right) = - \frac{g}{R_d\gamma \overline{T}}\hat{p}
\end{align*}

The righthand size has units $\Pa/\m$ which agrees with the lefthand side. Clearly this has solution $\ln(\hat{p}(z)) - \ln(\hat{p}(z=0)) = - \frac{g}{R_d \gamma \overline{T}}(z - 0)$ and therefore
\begin{align*}
    \hat{p}(z) = p_{00}\exp\left(- \frac{g}{R_d \gamma \overline{T}}z\right)
\end{align*}

In order to find the physical solution we take 
\begin{align*}
    p' &= \Re \left(p_{00}\exp\left(- \frac{g}{R_d \gamma \overline{T}} z\right) \exp \left(ik(x - ct) \right)  \right)\\
    &= p_{00}\exp\left(- \frac{g}{R_d \gamma \overline{T}} z\right) \Re \left( \exp \left(ik(x - ct) \right)  \right)\\
    &= p_{00}\exp\left(- \frac{g}{R_d \gamma \overline{T}} z\right) \Re \left( \cos(k(x - ct)) + i \sin(k(x - ct)) \right)\\
    &= p_{00}\exp\left(- \frac{g}{R_d \gamma \overline{T}} z\right) \cos(k(x - ct))\\
\end{align*}


And we use the linearized hydrostatic equation $\pder{p'}{z} = -\rho' g$ to find

\begin{align*}
    \rho' &= -\frac{1}{g} \pder{p'}{z} \\
    &= -\frac{1}{g}\pder{}{z}\left(p_{00}\exp\left(-\frac{g}{R_d\gamma \overline{T}}z\right)\cos(k(x-ct))  \right) \\
    &= \frac{1}{g}\cdot\frac{g}{R_d\gamma \overline{T}}\left(p_{00}\exp\left(-\frac{g}{R_d\gamma \overline{T}}z\right)\cos(k(x-ct))  \right) \\
    &= \frac{p_{00}}{R_d\gamma \overline{T}}\exp\left(-\frac{g}{R_d\gamma \overline{T}}z\right)\cos(k(x-ct))\\
\end{align*}

which we check has units $\frac{\unit{N}/\m^2}{\K\m \unit{N}/\kg/\K} = \frac{\kg}{\m^3}$ which is the units for density. 

We return to the remaining equation $\left(
\pder{}{t} + \overline{u} \pder{}{x}\right)u' + \frac{1}{\overline{\rho}} \pder{p'}{x} = 0$ and assume that $u' = \Re \left[\hat{u}(z) \exp(ik(x-ct)) \right]$ to find

\begin{align*}
   &\qquad (-ikc + i\overline{u}k)\hat{u}(z)\Psi + \frac{1}{\overline{\rho}} (ik) \hat{p} \Psi \\
   &\implies (-c + \overline{u})\hat{u}(z) + \frac{\hat{p}}{\overline{\rho}}   \\
    &\implies \hat{u}(z)  = - \frac{\hat{p}}{\overline{\rho}( \overline{u}-c)}   \\
    &\implies \hat{u}(z)  = - \frac{p_{00}}{\overline{\rho}( \overline{u}-c)} \exp\left(-\frac{g}{R_d\gamma \overline{T}}z\right) \cos(k(x-ct)) \\
\end{align*}

Where we check that this has units $\frac{\kg\cdot\m/\s^2/\m^2}{\kg/\m^3 \cdot \m/\s} = \frac{\m}{\s}$ which is what we would expect.

