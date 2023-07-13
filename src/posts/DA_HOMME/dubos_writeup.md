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

Let `$$\mbf{q} \in \mathcal{A} $$` for some Hilbert space `$$\mathcal{A}$$`. We express scalar energy as `$$\msc{H}(\mbf{q})$$`. 

We make the definition in the sense of Gateaux:
`$$$
\pder{\msc{H}}{\mbf{q}}(h) = \lim_{\varepsilon \to 0} \frac{\msc{H}(\mbf{q} + \varepsilon h) - \msc{H}(\mbf{q}) }{\|\varepsilon h \|} 
$$$`
and as we found out in [this writeup](https://open-lab-notebook.glitch.me/posts/math/calc_of_variations/) this can be computed relatively concretely if `$$\msc{H}(\mbf{q}) = \int H(\mathbf{q}) \intd{\mu} $$` then
`$$$ 
\pder{\msc{H}}{\mbf{q}}(\delta\mbf{q}) = \int H'(\mbf{q})\delta\mbf{q} \intd{\mu}.
$$$`

Returning to the paper, they wish to write
`$$

$$`

