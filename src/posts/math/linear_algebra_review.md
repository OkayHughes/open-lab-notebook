---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Linear algebra
  parent: math
layout: layouts/post.njk
---

Let's say that you're mostly familiar with vectors of the form `$$x \in \mathbb{R}^n$$`, and you're most familiar with 
formulating linear systems of equations in terms of `$$ A\mathbf{x} = \mathbf{b}$$`, where `$$A \in \mathbb{R}^{n\times m}$$`, `$$\mathbf{x} \in \mathbb{R}^m$$`,
and `$$ \mathbf{b} \in \mathbb{R}^n$$`. 

## bWhy would we want more generality than this? 
"Linearity" typically looks like various extensions of the 1D linear system `$$y=mx+b$$`. We want to be able to multiply by coefficients (e.g., `$$m$$`)
and add potential solutions (`$$x, b$$`) together. You can verify using the laws of matrix multiplication that `$$A(\mathbf{x} + \mathbf{y}) = A\mathbf{x} + A\mathbf{y}$$`,
and that `$$A(a\mathbf{x} + \mathbf{y}) = aA\mathbf{x} + A\mathbf{y} $$` (`$$a \in \mathbb{R}$$`). These equation show that vector addition and scalar multiplication,
even if you've only encountered them as "joining arrows" or "scaling arrows" in `$$\mathbb{R}^n$$`, are sort of "preserved", in some sense, by matrix multiplication.  

We know from introductory calculus that for (suitably not-evil) functions `$$ f, g : \mathbb{R} \to \mathbb{R}$$`, `$$ \int_0^1 f + g \intd{x} = \int_0^1 f \intd{x} + \int_0^1 g \intd{x}$$`, and that 
`$$ \int_0^1 af + g \intd{x} = a\int_0^1 f \intd{x} + \int_0^1 g \intd{x}$$`. Likewise, if `$$ f, g $$` are continuously first-differentiable `$$ \der{}{x} \left[af + g \right] = a\der{f}{x} + \der{g}{x}  $$`.
In a sense that can be made extremely mathematically precise, the operations of differentiation and integration can be used to formulate linear equations that can be solved.

Let's continue this analogy even further: suppose I have the system of equations
`$$$A\mathbf{x} = 
\begin{pmatrix}
1& 0 & 0 \\ 
0 & 1 & 0 \\
0 & 0 & 0
\end{pmatrix} \mathbf{x} = \begin{pmatrix} 1 \\ 1 \\ 0 \end{pmatrix} $$$`
`$$ \mathbf{x} = (1, 1, 0)^\top$$` is a solution, but so is `$$ \mathbf{x} = (1, 1, \textrm{one hkjdillion})^\top$$`. It turns out that this is because for `$$ \mathbf{n} = (0, 0, 1)^\top$$`,  `$$ A\mathbf{n} = 0$$`, meaning that for any scalar `$$ a \in \mathbb{R}$$`, `$$A(a\mathbf{n}) = aA\mathbf{n} = 0a = 0$$`. Therefore if we have a solution to `$$A\mathbf{x} = \mathbf{b}$$`, then `$$A (\mathbf{x} + a\mathbf{n}) = A\mathbf{x} + aA\mathbf{n} = A\mathbf{x} + 0 = b$$`, so `$$\mathbf{x} + a\mathbf{n}$$` is also a solution. Therefore this system of linear equations has an infinite number of solutions.
Suppose your calculus teacher asked you to find functions `$$f$$` 



## A little finite dimensional example 
 
  

