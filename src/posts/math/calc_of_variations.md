---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Quasi-rigorous Calculus of Variations
  parent: math
layout: layouts/post.njk
---




Let `$$\mathscr{F}$$` be some (potentially nonlinear functional) `$$\mathscr{F} : L^2([0, 1]) \to \mathbb{R}$$` 
taking functions `$$\rho \in L^2([0, 1])$$`  Suppose we have some `$$\varepsilon \in \mathbb{R}$$` and `$$\delta x \in L^2([0, 1]).$$` Then we can create the (linear?!) functional `$$\mathscr{D} : L^2([0, 1]) \to \mathbb{R}$$` defined by `$$$\mathscr{D}_{\rho}(\delta x) = \lim_{\varepsilon \to 0} \frac{\mathscr{F}(\rho + \varepsilon \delta x) - \mathscr{F}(\rho)}{\varepsilon}.$$$` Why is this linear?
Assume the necessary quantities exist to define the following (this appears to be equivalent to our functional `$$\mathscr{F}$$` being [Gateaux Differentiable](https://en.wikipedia.org/wiki/Gateaux_derivative) at `$$\rho_0$$`). 
`$$$ 0 = \mathscr{D}_\rho(\delta x_1 + \delta x_2) - \mathscr{D}_\rho(\delta x_1) - \mathscr{D}_\rho(\delta x_2) = \lim_{\varepsilon \to 0 } \frac{\mathscr{F}(\rho + \varepsilon(\delta x_1 + \delta x_2)) - \mathscr{F}(\rho + \varepsilon \delta x_1) - \mathscr{F}(\rho + \varepsilon\delta x_2)}{\varepsilon}$$$`
This gives us a feel for the regularity that we need `$$\mathscr{F}$$` to have. One weird thing about the Gateaux derivative is that
it is so general that it can fail to even be linear. Thus, the better requirement is to assume Fréchet differentiability of `$$\mathscr{F}$$` at `$$\rho_0$$`.
In its most general formulation, this posits that `$$\mathscr{F}$$` is a functional on a Locally Convex Metrizable Topological Vector Space, which is complete (e.g. w.r.t. the metric).
A few notes on this: the spaces `$$ \mathrm{C}^k(M) $$` works for smooth manifolds under the countable family of 
seminorms given by `$$ \| f \|_{k, n} = \sup \{ |f^k| \mid x \in [-n, n] \} $$` and holds even for `$$k = \infty$$`. 


For the purposes of most of the systems that I want to work with, we can assume that `$$\mathscr{F}$$` 
takes the form of `$$\int F(\rho(x))\intd \mu(x)$$` for some 
`$$F \in \mathrm{C}^1(\mathbb{R}).$$` 
Let us check that this is Fréchet differentiable. 
That is for `$$h \in X $$`
`$$$ 0 = \lim_{\varepsilon \to 0} \frac{\left|\mathscr{F}(\rho + \varepsilon h) - \mathscr{F}(\rho)  - \mathscr{F}'_{\rho}(\varepsilon h)\right|}{\|\varepsilon h\|} $$$`
We can make a pretty good guess that 
`$$$\mathscr{F}'_\rho(h) = \int F'(\rho(x))h(x) \intd{x} $$$`
(interesting note: the fact that `$$F'$$` is only integrated against means that I think we merely need `$$F$$` to be weakly differentiable,
but this should be verified). We then find

`$$$\lim_{\varepsilon \to 0} \frac{\left|\mathscr{F}(\rho + \varepsilon h) - \mathscr{F}(\rho)  - \mathscr{F}'_{\rho}(\varepsilon h)\right|}{\|\varepsilon h\|} = \lim_{\varepsilon \to 0} \frac{\left| \int F(\rho(x) + \varepsilon h(x)) -  F(\rho(x))  - \varepsilon F'(\rho(x)) h(x) \intd{x} \right|}{\|\varepsilon h\|}$$$`

Then `$$\mathscr{D}_\rho(\delta x)$$` is a linear functional, which we can represent by integration against some measure `$$Q\intd \mu$$` for `$$Q \in L^2([0, 1]).$$` Because of our special choice of functional, this should be guaranteed to be absolutely continuous w.r.t. the lebesgue measure. 
Then the functional derivative `$$\frac{\delta \mathscr{F}}{\delta \rho}$$` is just the R-N derivative of `$$Q\intd \mu.$$` This means that a robust, weak form of functional differentiation gives 