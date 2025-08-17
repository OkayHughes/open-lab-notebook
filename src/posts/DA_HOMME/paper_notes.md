---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Misc notes on the paper
layout: layouts/post.njk
---


### Summary of the Augmented Equations
 The horizontal differential operators in the \cite{taylor2010compatible} numerical scheme are formulated with respect to a metric tensor defined on the unit sphere. Discrete differential operators and horizontal integrals are scaled by a constant nominal radius. Restoring dependence on the vertical dimension to this metric would require substantial changes of the numerical implementation of the dynamical core. The choice of The prognostic equations are specified in spherical coordinates, and the mapping into terrain-following coordinates can be decomposed into $(\lambda, \varphi, r) \mapsto (x, y, z) \mapsto (x', y', s)$, with Jacobian
 \begin{align}
     \begin{pmatrix}
       r  & 0 & 0 \\
       0 & r & 0 \\
       0 & 0 & 1 \\
     \end{pmatrix}
\begin{pmatrix}
 \multicolumn{2}{c}{ D  }   &  \begin{matrix} 0 \\ 0 \end{matrix}
  \\
  0 & 0 & 1
\end{pmatrix}
     \begin{pmatrix}
       1 & 0 & 0 \\
       0 & 1 & 0 \\
       \frac{\partial r}{\partial x'} & \frac{\partial r}{\partial y'} & \frac{\partial r}{\partial s} \\
     \end{pmatrix}
 \end{align}
with $D = \begin{pmatrix} \cos\phi & 0 \\ 0 & 1\end{pmatrix} \frac{ \partial(\lambda,\theta)}{\partial(x,y)}$.

HOMME uses a 2-D vector invariant formulation of the equations of fluid motion, specified using
 
