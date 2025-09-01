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

# Linear structure

## Why would we want more generality than this? 
"Linearity" typically looks like various extensions of the 1D linear system `$$y=mx+b$$`. 
We want to be able to multiply by coefficients (e.g., `$$m$$`) and add potential solutions (`$$x, b$$`) together. 
You can verify using the laws of matrix multiplication that `$$A(\mathbf{x} + \mathbf{y}) = A\mathbf{x} + A\mathbf{y}$$`,
and that `$$A(a\mathbf{x} + \mathbf{y}) = aA\mathbf{x} + A\mathbf{y} $$` (`$$a \in \mathbb{R}$$`). 
These equation show that vector addition and scalar multiplication, even if you've only encountered them as "joining arrows" or "scaling arrows" in `$$\mathbb{R}^n$$`, 
are "preserved", in some sense, by matrix multiplication.  

We know from introductory calculus that for (suitably not-evil) functions `$$ f, g : \mathbb{R} \to \mathbb{R}$$`, `$$ \int_0^1 f + g \intd{x} = \int_0^1 f \intd{x} + \int_0^1 g \intd{x}$$`, and that 
`$$ \int_0^1 af + g \intd{x} = a\int_0^1 f \intd{x} + \int_0^1 g \intd{x}$$`. 
Likewise, if `$$ f, g $$` are continuously first-differentiable `$$ \der{}{x} \left[af + g \right] = a\der{f}{x} + \der{g}{x}  $$`.
In a sense that can be made extremely mathematically precise, the operations of differentiation and integration can be used to formulate linear equations (but which are MUCH harder to solve/characterize than systems in `$$\mathbb{R}^n$$`, because they are infinite dimensional). 
However, in their most general form, there isn't a very natural way to write differentiation and integration as a matrix (integration can sometimes be thought of as an infinite-dimensional matrix, in a limiting sense, but differentiation in infinite dimensions absolutely cannot be thought of this way). 
This leads us to the question "what properties do matrices and more general linear operations share". 
This is one reason to define "linear operators", of which matrices, integration, and differentiation are examples. In finite dimensions, operators always have a matrix representation.  

Let's continue this analogy even further: suppose I have the system of equations
`$$$A\mathbf{x} = 
\begin{pmatrix}
1& 0 & 0 \\ 
0 & 1 & 0 \\
0 & 0 & 0
\end{pmatrix} \mathbf{x} = \begin{pmatrix} 1 \\ 1 \\ 0 \end{pmatrix} $$$`
`$$ \mathbf{x} = (1, 1, 0)^\top$$` is a solution, but so is `$$ \mathbf{x} = (1, 1, \textrm{one hkjdillion})^\top$$`. It turns out that this is because for `$$ \mathbf{n} = (0, 0, 1)^\top$$`,  `$$ A\mathbf{n} = 0$$`, meaning that for any scalar `$$ a \in \mathbb{R}$$`, `$$A(a\mathbf{n}) = aA\mathbf{n} = 0a = 0$$`. Therefore if we have a solution to `$$A\mathbf{x} = \mathbf{b}$$`, then `$$A (\mathbf{x} + a\mathbf{n}) = A\mathbf{x} + aA\mathbf{n} = A\mathbf{x} + 0 = b$$`, so `$$\mathbf{x} + a\mathbf{n}$$` is also a solution. Therefore this system of linear equations has an infinite number of solutions.
Suppose your calculus teacher asked you to find functions `$$f$$` that satisfy `$$ \der{f}{x} = x^2$$`. You would immediately go "well, there are infinitely many such `$$f$$`, because `$$ \der{}{x}\left[f + C \right] = \der{f}{x}$$` for any constant `$$C$$`". Therefore for any `$$f$$` that is a solution to that equation, `$$ f + C $$` is also a solution. You can see where I'm going here.


This means that there should be some analogy between a summation `$$ (0, 0, 1)^\top + (0, 1, 0)^\top = (0, 1, 1)^\top $$` and `$$ f + g$$`, right? Exactly, but you've already been doing this since you were 13. If we let `$$f = x^3$$` and `$$g = x^2$$`, `$$ f + 2g = x^3 + 2x^2$$`.  Put formally, if you have two functions `$$f, g : \mathbb{R} \to \mathbb{R}$$`, and `$$a \in \mathbb{R}$$`, `$$(af +g)(x) = af(x) + g(x)$$`. For a moment, let's consider polynomials of a fixed maximum degree, e.g. 1D polynomials that contain no power higher than `$$x^3$$`. These take the form of `$$ ax^3 + bx^2 + cx + d$$`. Hmm.
What if I make the definition `$$ \mathbf{e}_0 = 1, \mathbf{e}_1 = x, \mathbf{e}_2 = x^2, \mathbf{e}_3 = x^3 $$`. Then it seems that for a cubic polynomial `$$ f $$`, I can write it as `$$ f = d\mathbf{e}_0 + c \mathbf{e}_1 + b \mathbf{e}_2 + a \mathbf{e}_3$$`. Recall that in `$$\mathbb{R}^n$$`, we define the basis vectors as `$$ \mathbf{e}_i = (0, \ldots, \stackrel{i}{1}, \ldots, 0)^\top $$`, so a vector `$$ \mathbf{x} = (x_1, x_2, \ldots, x_n)^\top$$` can be written as `$$ \mathbf{x} = \sum_i x_i \mathbf{e}_i$$`. If we let the space `$$V^3_1(\mathbb{R})$$` be the set of all cubic polynomials in one real variable, it turns out that this is a four-dimensional vector space that is mathematically indistinguishable from (isomorphic to) `$$ \mathbb{R}^4 $$`. We will continue this analogy in the next section.


As a cautionary note, you might look at the last example and say "well, I looked at the problem in the last section and started solving it by integrating both sides of the equation, so shouldn't there be a way to formalize that differentiation  and integration are analogous to `$$ A $$` and `$$A^{-1}$$`. The answer is, yes, in many contexts there are ways to formalize this (these are typically called "the fundamental theorem of calculus" for whatever structure you're working with, `$$L^p$$` spaces, general banach spaces, sobolev spaces, etc). However, if you aren't adequately mathematically precise about how you do this, you produce mathematical statements that are either wrong or so ambiguous that they may as well be wrong. I've personally wasted weeks of my life where physicists somehow got this crap published and I had to figure out what they actually meant (this gets especially hairy when you're dealing with PDEs with boundary conditions). If you aren't planning to spend a year learning intro graduate analysis, don't DIY this. Ask someone to help you.



## A little finite dimensional example 

Let's return to `$$ V^3_1(\mathbb{R}) $$`, the space of cubic polynomials in one real variable, (I forget the standard notation for this). The identity `$$ \der{}{x} \left[x^n \right] = nx^{n-1}$$`
means that if we choose the monomial basis `$$ \mathbf{e}_n = x^{n-1}, n=1,\ldots,4$$` and write polynomials as `$$ \mathbf{f} = \sum_n f_n \mathbf{e}_n $$`, then we can ask: is there a matrix `$$ D $$` such that if we associate a polynomial  `$$f $$` to its representation in `$$ \mathbf{f} \in \mathbf{R}^4 $$`, then the  `$$ D\mathbf{f} $$` is equivalent to the representation of `$$f'$$` as a vector? Yes. It looks like 
`$$$
D \equiv \begin{pmatrix}
0 & C & 0 & 0 \\
0 & 0 & 2 & 0 \\
0 & 0 & 0 & 3 \\
0 & 0 & 0 & 0   
\end{pmatrix}
$$$`
some good exercises: 
* Take a deep breath, don't panic like I did when I went through this example when I was 17. If you took high school math and understood it, you can do this!
* how would you encode our monomial basis, e.g. `$$ e_2 = x^2$$` (recall that vectors index top to bottom) ? How does the matrix act on this vector? 
* Use the information from the last question to determine the value of `$$C$$`. 
* Verify that the matrix behaves how you would expect it to when calculating `$$D(f + g) = Df + Dg$$` for `$$f = 6x^3 + 3$$`, `$$g = 2x$$`. 
* this matrix is not invertible. Why? How does this relate to your understanding of calculus?
* How would you extend this matrix for `$$V^4_1(\mathbb{R})$$`, which is the space of at-most-quartic polynomials in one real variable.
* Hard exercise: What would the matrix look like for `$$ V^1_2(\mathbb{R})$$`, the space of at-most-linear polynomials in two real variables.
  * Step 1: What is the dimension of this space?
  * Step 2: What does your monomial basis look like?
  * Step 3: Does it actually matter what order you put the monomials in?
  * Step 4: Write down the matrix. 
  
### Quadrature
Let's now work over `$$ V_1^2(\mathbb{R})$$` for brevity. Let's say I want to compute `$$ \int_I f \intd{x} = \int_I \sum_n f_n x^n \intd{x}$$` for some interval `$$I$$` (you can assume `$$ I = [0,1]$$` without losing any generality).  Well, by expanding we find that `$$ \int_I \sum_n f_n x^n \intd{x} = \sum_n f_n \int_I x^n \intd{x}$$`. Wait, `$$ \int_I x^n \intd{x}$$` doesn't seem to depend on my specific polynomial, `$$f$$`, at all! In fact, it doesn't, so one can compute `$$ w_n = \int_I x^n \intd{x}$$`. Suddenly, we can compute `$$\int_I f \intd{x} = \sum_n f_n w_n = \langle \mathbf{f}, \mathbf{w} \rangle $$` and this is an analytic integral that contains no numerical approximation whatsoever. `$$ \langle \cdot, \cdot \rangle $$` is the standard inner (dot) product on `$$\mathbb{R}^3$$` (see below).

# Inner product structure, duals

An inner product is an additional operation `$$\langle \cdot, \cdot \rangle $$` that one can add to a vector space. It must satisfy certain [requirements](https://en.wikipedia.org/wiki/Inner_product_space). It is a generalization of the dot product on `$$\mathbb{R}^n$$`, `$$ \langle \mathbf{x}, \mathbf{y} \rangle = \sum_k x_k y_k $$`. The aforementioned requirements are the minimal set of constraints required to guarantee that the inner product you defined on your vector space `$$V$$`, gets you the properties that make the dot product useful.

## Why are orthogonal bases good?
First we need to talk about what bases are. In `$$\mathbb{R}^n$$`, a basis is a set of `$$n$$` vectors `$$\mathbf{b}_k$$` such that any `$$ \mathbf{x} \in \mathbb{R}^n$$` can be written as `$$ \sum_k b_k \mathbf{b}_k = \mathbf{x}$$` in exactly one way. It can be shown that a basis must contain exactly `$$n$$` vectors. Any more than that, and there will be multiple `$$b_k$$` that can be used to reconstruct `$$\mathbf{x}$$`.  Any fewer and there will be vectors `$$x$$` that cannot be reconstructed by any choice of `$$b_k$$`. To see why this is, imagine that I choose `$$ \mathbf{b}_1 = (1, 0, 0)^\top $$`, `$$\mathbf{b}_2 = (0, 1, 0)^\top$$`, and `$$ \mathbf{b}_3 = (1, 1, 0)^\top$$`. If we let each entry of the vector be the dimensions `$$x, y, z$$`, respectively, then we see that the first two vectors can be used to reconstruct (span) the plane `$$ z = 0$$`. But our third vector lies in that plane. That means that any vector `$$\mathbf{x} = (x_1, x_2, x_3)$$` with `$$x_3 \neq 0$$` lies out of reach of our `$$\mathbf{b}_n$$`. Any failure of `$$n$$` vectors to be a basis for `$$\mathbb{R}^n$$` fails in exactly this way, which can be formalized. If you stack your `$$\mathbf{b}_k$$` as columns of a matrix, this equivalent to that matrix being invertible. 


## What is a dual space?


# Galerkin

## Weak form of an equation

## Bobunov-Galerkin


## Petrov-Galerkin
