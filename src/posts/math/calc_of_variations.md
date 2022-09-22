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
Assume the necessary quantities exist to define the following:
`$$$ 0 = \mathscr{D}_\rho(\delta x_1 + \delta x_2) - \mathscr{D}_\rho(\delta x_1) - \mathscr{D}_\rho(\delta x_2) = \lim_{\varepsilon \to 0 } \frac{\mathscr{F}(\rho + \varepsilon(\delta x_1 + \delta x_2)) - \mathscr{F}(\rho + \varepsilon \delta x_1) - \mathscr{F}(\rho + \varepsilon\delta x_2)}{\varepsilon}$$$`
This gives us a feel for the regularity that we need `$$\mathscr{F}$$` to have. For the purposes of this class we can assume that $\mathscr{F}$ takes the form of `$$\int F(\rho(x))\intd \mu(x)$$` for some `$$F \in C^1(\mathbb{R}).$$` Then we can get the above  by using the remainder theorem for a first order Taylor expansion. I might check this later. 

Then `$$\mathscr{D}_\rho(\delta x)$$` is a linear functional, which we can represent by integration against some measure `$$Q\intd \mu$$` for `$$Q \in L^2([0, 1]).$$` Because of our special choice of functional, this should be guaranteed to be absolutely continuous w.r.t. the lebesgue measure. 
Then the functional derivative `$$\frac{\delta \mathscr{F}}{\delta \rho}$$` is just the R-N derivative of `$$Q\intd \mu.$$` This means that a robust, weak form of functional differentiation gives 