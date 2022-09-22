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
That is for `$$h \in L^2([0, 1]) $$`
`$$$ 0 = \lim_{\varepsilon \to 0} \frac{\left|\mathscr{F}(\rho + \varepsilon h) - \mathscr{F}(\rho)  - \mathscr{F}'_{\rho}(\varepsilon h)\right|}{\|\varepsilon h\|} $$$`
We can make a pretty good guess that 
`$$$\mathscr{F}'_\rho(h) = \int F'(\rho(x))h(x) \intd{x} $$$`
(interesting note: the fact that `$$F'$$` is only integrated against means that I think we need `$$F$$` to be merely weakly differentiable,
but this should be verified). We then find
`$$$\lim_{\varepsilon \to 0} \frac{\left|\mathscr{F}(\rho + \varepsilon h) - \mathscr{F}(\rho)  - \mathscr{F}'_{\rho}(\varepsilon h)\right|}{\|\varepsilon h\|} = \lim_{\varepsilon \to 0} \frac{\left| \int F(\rho(x) + \varepsilon h(x)) -  F(\rho(x))  - \varepsilon F'(\rho(x)) h(x) \intd{x} \right|}{\|\varepsilon h\|}$$$`
A precise form of Taylor's theorem states that for any fixed `$$x$$`, we can find some `$$h_{\rho(x)}(y)$$` such that `$$\lim_{y \to \rho(x)} h_{\rho(x)}(y) = 0$$` and 
`$$$ F(\rho(x) + \varepsilon h(x)) = F(\rho(x)) + \varepsilon h(x)F'(\rho(x)) +  \int_{0}^{\varepsilon h(x)} F''(\rho(x) + t)t \intd{t} $$$`
Assume that `$$|F''|$$` can be essentially bounded by some `$$C,$$` then we have 
`$$$ |R(x)| = \left|  \int_{0}^{\varepsilon h(x)} F''(\rho(x) + t)t \intd{x'}\right| \intd{x} \leq  \int_{0}^{\varepsilon h(x)} \left|F''(\rho(x) + t)t \right| \intd{x'}  \leq  \int_{0}^{\varepsilon h(x)} \left|Ct \right| \intd{x} = \frac{C}{2}(\varepsilon h(x))^2$$$`
This meabs 
<table class="eqn">
  <tr>
    <td>$$\lim_{\varepsilon \to 0} \frac{\left| \int F(\rho(x) + \varepsilon h(x)) -  F(\rho(x))  - \varepsilon F'(\rho(x)) h(x) \intd{x} \right|}{\|\varepsilon h\|}$$</td><td>$$= \lim_{\varepsilon \to 0} \frac{\left| \int F(\rho(x)) + \varepsilon F'(\rho(x))h(x) + R(x) -  F(\rho(x))  - \varepsilon F'(\rho(x)) h(x) \intd{x} \right|}{\|\varepsilon h\|}$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \lim_{\varepsilon \to 0} \frac{\left| \int  R(x)  \intd{x} \right|}{\|\varepsilon h\|}$$</td>
  </tr>
  <tr>
    <td></td><td>$$\leq \lim_{\varepsilon \to 0} \frac{ \int \left| R(x) \right| \intd{x} }{\|\varepsilon h\|}$$</td>
  </tr>
  <tr>
    <td></td><td>$$\leq \lim_{\varepsilon \to 0} \frac{ \frac{1}{2} C \varepsilon^2 \int h(x)^2 \intd{x} }{\|\varepsilon h\|}$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \lim_{\varepsilon \to 0} \frac{ \frac{1}{2} C  \|\varepsilon h\|_2^2 }{\|\varepsilon h\|}$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \lim_{\varepsilon \to 0} \frac{1}{2} C  \|\varepsilon h\|_2$$</td>
  </tr>
  <tr>
    <td></td><td>$$= 0$$</td>
  </tr>
</table>

This demonstrates that, indeed, 
`$$$\mathscr{F}'_\rho(h) = \int F'(\rho(x))h(x) \intd{x} $$$`


However!! In this process we've determined that, in fact, 
`$$$\mathscr{D}_\rho(h) = \mathscr{F}'_\rho(h) = \int F'(\rho(x))h(x) \intd{x}.$$$`

Now! Here comes the fun part. This linear functional `$$\mathscr{D}_\rho(h)$$` can be represented by
integration against the measure `$$F'(\rho(x)) \intd{\mu}.$$` This functional can be used to calculate the directional
functional derivative in some "direction" `$$h(x)$$`. However, it is _extremely_ common (especially in numerical applications) to
wish to access a quantity `$$\fder{\mathscr{F}}{\rho} $$` which can be evaluated pointwise.
Here's the really clever thing, and the point of why I started writing this little article in the first place:
for any Fréchet-differentiable functional `$$\mathscr{G},$$` we can do this process to find some measure `$$\nu$$` 
against which an `$$h$$` can be integrated to calculate a directional functional derivative. If we want to find `$$ \fder{\mathscr{G}}{\rho} $$`
then we merely need to calculate the Radon-Nikodym derivative `$$\der{\nu}{\mu}$$` (we omit for the moment the considerations
that determine whether `$$\nu \ll \mu $$`). 
Let us examine this concretely for our example `$$\mathscr{F}$$`. The Radon-Nikodym derivative is some Lebesgue integrable function
`$$\der{\nu}{\mu}$$` which satisfies `$$ \nu(A) = \int_A \der{\nu}{\mu}\intd{\mu} $$` for all measurable sets `$$A$$`. Well, in the case
of our `$$\mathscr{F}$$` we are calculating the R-N derivative with respect to the underlying measure `$$\mu $$` corresponding to `$$L^2([0, 1])$$`
and so we get `$$$\fder{\mathscr{F}}{\rho}(\rho_0; x) = \der{\nu_{\rho_0}}{\mu}( x) = F'(\rho_0(x)).$$$`

## Next up: product and chain rules!