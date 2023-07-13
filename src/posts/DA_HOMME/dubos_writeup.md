---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Explicating Dubos
layout: layouts/post.njk
---

This is trying to explain [this paper](https://journals.ametsoc.org/view/journals/mwre/142/10/mwr-d-14-00069.1.xml).

Let `$$\mbf{q} \in \mathcal{A}_1 \times \mathcal{A}_2\times \ldots \mathcal{A}_n $$` for some suitably nice function spaces `$$\mathcal{A}_i$$`. We express scalar energy as `$$\msc{H}(\mbf{q})$$`. 

We make the definition in the sense of Gateaux:
`$$$
\pder{\msc{H}}{\mbf{q}}(h) = \lim_{\varepsilon \to 0} \frac{\msc{H}(\mbf{q} + \varepsilon h) - \msc{H}(\mbf{q}) }{\|\varepsilon h \|} 
$$$`
and as we found out in [this writeup](https://open-lab-notebook.glitch.me/posts/math/calc_of_variations/) that if `$$\msc{H}(\mbf{q}_1) = \int H(\mathbf{q}_1) \intd{\mu} $$` then this can be computed relatively concretely as
`$$$ 
\fder{\msc{H}}{\mbf{q}_1}(\delta\mbf{q}_1) = \int H'(\mbf{q}_1)\delta\mbf{q}_1 \intd{\mu}.
$$$`
One of the annoying bits of the paper is the use of bold face `$$\mbf{q}$$`. To explicate this fully, we note that if `$$ \msc{H}(\mbf{q}) = \int H(\mbf{q}_1, \ldots, \mbf{q}_n) \intd \mu $$` then, analogous with vector calculus,
`$$$ 
\pder{\msc{H}}{\mbf{q}_i}(\delta\mbf{q}_i) = \int \partial_i H(\mbf{q}_1, \ldots, \mbf{q}_n)\delta\mbf{q}_i \intd{\mu}.
$$$`

Returning to the paper, they wish to write
`$$
  \der{\mbf{q}}{t} = \left.\mbf{J}\right|_{\mbf{q}} \left(\fder{\msc{H}}{\mbf{q}}\right)
$$`
where `$$\mbf{J}$$` is an anti-symmetric linear operator (i.e. could be an anti-symmetric matrix of linear operators which act on `$$\pder{\msc{H}}{\mbf{q}_i} $$`) and `$$\fder{\msc{H}}{\mbf{q}} $$` is a functional "gradient" in each component of `$$ \mbf{q}$$`.

Note that `$$\partial_{\mbf{q}_i}\msc{H}$$` is, strictly speaking, an element of the dual space. However, using the particular form of `$$\msc{H}$$`, we can get a concrete representation of a Poisson bracket:
`$$$
\begin{align*}
\der{\msc{F}}{t} &= \{\msc{F},\msc{H}\}  \\
  &= \mbf{J}\left(\fder{\msc{F}}{\mbf{q}}, \fder{\msc{H}}{\mbf{q}}\right) \\
  &= \int (\nabla F)^\top \mathbf{J}(\nabla H) \intd{\mu}
\end{align*}
$$$`

Anyways, this needs more clarification. Let's move on to 

