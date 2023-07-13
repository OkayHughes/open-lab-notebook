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

Let `$$\mbf{q} \in \mathcal{A}_1 \times \mathcal{A}_2\times \ldots \mathcal{A}_n $$` for some Hilbert spaces `$$\mathcal{A}_i$$`. We express scalar energy as `$$\msc{H}(\mbf{q})$$`. 

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
\pder{\msc{H}}{\mbf{q}_i}(\delta\mbf{q}_i) = \int H'(\mbf{q}_1)\delta\mbf{q}_1 \intd{\mu}.
$$$`

Returning to the paper, they wish to write
`$$
  \frac{}{}
$$`

