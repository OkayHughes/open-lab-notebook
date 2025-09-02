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

Throughout this work, we will work with what I call the "column sum" characterization of matrix multiplication, in which (working in `$$\mathbb{R}^3$$` for concreteness)
`$$$
\begin{align*}
\begin{pmatrix}1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9 \end{pmatrix} \begin{pmatrix}x_1 \\ x_2 \\ x_3 \end{pmatrix}
&= x_1 \begin{pmatrix} 1 \\ 4 \\ 5 \end{pmatrix} + x_2 \begin{pmatrix} 2 \\ 5 \\ 8 \end{pmatrix} + x_3 \begin{pmatrix} 3 \\ 6 \\ 9 \end{pmatrix} \\
&\stackrel{\textrm{algorithmic definition}}{=} \begin{pmatrix} x_1 + 2x_2 + 3x_3 \\ 4x_1 + 5x_2 + 6x_3 \\ 7x_1 + 8x_2 + 9x_3 \end{pmatrix}
\end{align*}
$$$`
Within this characterization of matrix multiplication, each column can be thought of in the "arrow" sense of vectors, and matrix multiplication
is simply scaling each column vector by a particular amount, then joining the scaled vectors end-to-end.

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
`$$ \mathbf{x} = (1, 1, 0)^\top$$` is a solution, but so is `$$ \mathbf{x} = (1, 1, \textrm{one hkjdillion})^\top$$`. 
It turns out that this is because for `$$ \mathbf{n} = (0, 0, 1)^\top$$`,  `$$ A\mathbf{n} = 0$$`, meaning that for any scalar `$$ a \in \mathbb{R}$$`, `$$A(a\mathbf{n}) = aA\mathbf{n} = 0a = 0$$`. 
Therefore if we have a solution to `$$A\mathbf{x} = \mathbf{b}$$`, then `$$A (\mathbf{x} + a\mathbf{n}) = A\mathbf{x} + aA\mathbf{n} = A\mathbf{x} + 0 = b$$`, so `$$\mathbf{x} + a\mathbf{n}$$` is also a solution. Therefore this system of linear equations has an infinite number of solutions.
Suppose your calculus teacher asked you to find functions `$$f$$` that satisfy `$$ \der{f}{x} = x^2$$`. 
You would immediately go "well, there are infinitely many such `$$f$$`, because `$$ \der{}{x}\left[f + C \right] = \der{f}{x}$$` for any constant `$$C$$`". 
Therefore for any `$$f$$` that is a solution to that equation, `$$ f + C $$` is also a solution. In both cases, non-uniqueness of solutions to a linear equation
can be derived from the fact that the linear operators (`$$A, \der{}{x}$$`) have certain non-zero vectors that they squash (the space of such vectors is called the nullspace). 
By talking about linear operators more generally, we can use the tools of linear algebra to examine the properties of operators like `$$\der{}{x}$$`.


This means that there should be some analogy between a summation `$$ (0, 0, 1)^\top + (0, 1, 0)^\top = (0, 1, 1)^\top $$` and `$$ f + g$$`, right? 
Exactly, but you've already been doing this since you were 13. 
If we let `$$f = x^3$$` and `$$g = x^2$$`, `$$ f + 2g = x^3 + 2x^2$$`.  
Put formally, if you have two functions `$$f, g : \mathbb{R} \to \mathbb{R}$$`, and `$$a \in \mathbb{R}$$`, `$$(af +g)(x) = af(x) + g(x)$$`. 
For a moment, let's consider polynomials of a fixed maximum degree, e.g. 1D polynomials that contain no power higher than `$$x^3$$`. 
These take the form of `$$ ax^3 + bx^2 + cx + d$$`. Hmm.
What if I make the definition `$$ \mathbf{e}_0 = 1, \mathbf{e}_1 = x, \mathbf{e}_2 = x^2, \mathbf{e}_3 = x^3 $$`. 
Then it seems that for a cubic polynomial `$$ f $$`, I can write it as `$$ f = d\mathbf{e}_0 + c \mathbf{e}_1 + b \mathbf{e}_2 + a \mathbf{e}_3$$`. 
Recall that in `$$\mathbb{R}^n$$`, we define the basis vectors as `$$ \mathbf{e}_i = (0, \ldots, \stackrel{i}{1}, \ldots, 0)^\top $$`, so a vector `$$ \mathbf{x} = (x_1, x_2, \ldots, x_n)^\top$$` can be written as `$$ \mathbf{x} = \sum_i x_i \mathbf{e}_i$$`. 
If we let the space `$$V^3_1(\mathbb{R})$$` be the set of all cubic polynomials in one real variable, it turns out that this is a four-dimensional vector space that is mathematically indistinguishable from (isomorphic to) `$$ \mathbb{R}^4 $$`. We will continue this analogy in the next section.


As a cautionary note, you might look at the last example and say "well, I looked at the problem in the last section and started solving it by integrating both sides of the equation, so shouldn't there be a way to formalize that differentiation  and integration are analogous to `$$ A $$` and `$$A^{-1}$$`. 
The answer is yes, in many contexts there are ways to formalize this (these are typically called "the fundamental theorem of calculus" for whatever structure you're working with, `$$L^p$$` spaces, general banach spaces, sobolev spaces, etc). 
However, if you aren't adequately mathematically precise about how you do this, you produce mathematical statements that are either wrong or so ambiguous that they may as well be wrong. 
I've personally wasted weeks of my life where physicists somehow got this crap published and I had to figure out what they actually meant (this gets especially hairy when you're dealing with PDEs with boundary conditions). 
If you aren't planning to spend a year learning intro graduate analysis, don't DIY this. Ask someone to help you.



## A little finite dimensional example 

Let's return to `$$ V^3_1(\mathbb{R}) $$`, the space of cubic polynomials in one real variable, (I forget the standard notation for this). 
The identity `$$ \der{}{x} \left[x^n \right] = nx^{n-1}$$`
means that if we choose the monomial basis `$$ \mathbf{e}_n = x^{n-1}, n=1,\ldots,4$$` and write polynomials as `$$ \mathbf{f} = \sum_n f_n \mathbf{e}_n $$`, then we can ask: is there a matrix `$$ D $$` such that if we associate a polynomial  `$$f $$` to its representation in `$$ \mathbf{f} \in \mathbf{R}^4 $$`, then the  `$$ D\mathbf{f} $$` is equivalent to the representation of `$$f'$$` as a vector? 
Yes. It looks like 
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
Let's now work over `$$ V_1^2(\mathbb{R})$$` for brevity. 
Let's say I want to compute `$$ \int_I f \intd{x} = \int_I \sum_n f_n x^n \intd{x}$$` for some interval `$$I$$` (you can assume `$$ I = [0,1]$$` without losing any generality).  
Well, by expanding we find that `$$ \int_I \sum_n f_n x^n \intd{x} = \sum_n f_n \int_I x^n \intd{x}$$`. 
Wait, `$$ \int_I x^n \intd{x}$$` doesn't seem to depend on my specific polynomial, `$$f$$`, at all! 
In fact, it doesn't, so one can compute `$$ w_n = \int_I x^n \intd{x}$$`. 
Suddenly, we can compute `$$\int_I f \intd{x} = \sum_n f_n w_n = \langle \mathbf{f}, \mathbf{w} \rangle $$` and this is an analytic integral that contains no numerical approximation whatsoever. 
`$$ \langle \cdot, \cdot \rangle $$` is the standard inner (dot) product on `$$\mathbb{R}^3$$` (see below).
This is one way in which integration can be represented as a linear operator (in this case, the matrix representation of `$$w_n$$` would be the "row vector" `$$ (w_1, \ldots, w_n) $$`.

# You actually do need to learn what a basis is

First we need to talk about what bases are. 
In `$$\mathbb{R}^n$$`, a basis is a set of `$$n$$` vectors `$$\mathbf{b}_k$$` such that any `$$ \mathbf{x} \in \mathbb{R}^n$$` can be written as `$$ \sum_k b_k \mathbf{b}_k = \mathbf{x}$$` (where `$$b_k \in \mathbb{R}$$` in exactly one way. 
It can be shown that a basis must contain exactly `$$n$$` vectors. 
Any more than that, and there will be multiple `$$b_k$$` that can be used to reconstruct `$$\mathbf{x}$$`.  
Any fewer and there will be vectors `$$x$$` that cannot be reconstructed by any choice of `$$b_k$$`. 
To see why this is, imagine that I choose `$$ \mathbf{b}_1 = (1, 0, 0)^\top $$`, `$$\mathbf{b}_2 = (0, 1, 0)^\top$$`, and `$$ \mathbf{b}_3 = (1, 1, 0)^\top$$`. 
If we let each entry of the vector be the dimensions `$$x, y, z$$`, respectively, then we see that the first two vectors can be used to reconstruct (span) the plane `$$ z = 0$$`. 
But our third vector lies in that plane. 
That means that any vector `$$\mathbf{x} = (x_1, x_2, x_3)$$` with `$$x_3 \neq 0$$` lies out of reach of our `$$\mathbf{b}_n$$`. 
Any failure of `$$n$$` vectors to be a basis for `$$\mathbb{R}^n$$` fails in exactly this way, which can be formalized. 
If you stack your `$$\mathbf{b}_k$$` as columns of a matrix, this equivalent to that matrix being invertible. 
Indeed, if you have a vector `$$ \mathbf{x} = \sum x_k \mathbf{e}_k$$`, with `$$ \mathbf{e}_k = (0, \ldots, \stackrel{k}{1}, \ldots, 0)$$` the "standard basis" on `$$\mathbb{R}^n$$`,
then solving the system `$$$ \begin{bmatrix} \mathbf{b}_1 & \ldots & \mathbf{b}_k \end{bmatrix} \mathbf{x}_\mathbf{b} = \mathbf{x}_\mathbf{e}$$$` 
finds `$$ \mathbf{x}_\mathbf{b} = (b_1, \ldots, b_n)$$` that reconstruct `$$\mathbf{x}$$` in the `$$\mathbf{b}_k$$` basis.


Ok, let's see how matrices and bases are related using the concrete example of the polynomial space above.
Let's suppose we have `$$f = \sum_{k=1}^4 f_k x^{k-1}$$`, and that I want to characterize the `$$\der{}{x}$$` operator.
Then we find `$$$ \der{f}{x} = \der{}{x} \left[ \sum_{k=1}^4 f_k x^{k-1} \right]  = \sum_{k=1}^4 f_k \der{}{x} \left[ x^{k-1} \right] = \sum_{k=1}^4 f_k (k-1)x^{k-2} $$$`.
If we make the association we made earlier, with `$$ x^{0} \simeq (1, 0, 0, 0)^\top, x \simeq (0, 1, 0, 0)^\top, x^2 \simeq (0, 0, 1, 0)^\top, x^3 \simeq (0, 0, 0, 1)^\top $$`
then we find that the matrix representation of our differentiation operator, `$$D$$` should satisfy
`$$$
\begin{align*}
    \der{f}{x} &= f_1 \der{}{x} \left[1 \right] + f_2 \der{}{x} \left[x \right] + f_3\cdot \der{}{x} \left[x^2 \right] + f_4 \cdot \der{}{x}\left[ x^3\right]   \\
    &= f_1 (0) + f_2 \cdot 1  + f_3\cdot 2 x + f_4 \cdot 3x^2   \\
&\simeq f_1 \cdot 0 + f_2 \cdot 1 \begin{pmatrix}1 \\ 0 \\ 0 \\ 0 \end{pmatrix} + f_3 \cdot 2 \begin{pmatrix}0 \\ 1 \\ 0 \\ 0 \end{pmatrix} + f_4 \cdot 3 \begin{pmatrix}0 \\ 0 \\ 1 \\ 0 \end{pmatrix} \\
&= f_1 \begin{pmatrix}0 \\ 0 \\ 0 \\ 0 \end{pmatrix} + f_2 \begin{pmatrix}1 \\ 0 \\ 0 \\ 0 \end{pmatrix} + f_3 \begin{pmatrix}0 \\ 2 \\ 0 \\ 0 \end{pmatrix} + f_4 \begin{pmatrix}0 \\ 0 \\ 3 \\ 0 \end{pmatrix}  \\
&= \begin{pmatrix} 0 & 1 & 0 & 0 \\ 0 & 0 & 2 & 0 \\ 0 & 0 & 0 & 3 \\ 0 & 0 & 0 & 0 \end{pmatrix}\begin{pmatrix}f_1 \\ f_2 \\ f_3 \\ f_4 \end{pmatrix} 
\end{align*}
$$$` 
which means that we have found a matrix representation of `$$\der{}{x}$$` just by examining how it acts on a basis of `$$ V_1^3(\mathbb{R})$$`. 

Some exercises:
* The polynomials `$$ -1, x, -x^2, x^3 $$` also form a basis of `$$ V_1^3(\mathbb{R})$$`. 
    * Letting the standard monomial basis be identified with `$$ \mathbf{e}_k$$`, and this new basis be `$$ \mathbf{b}_l$$`, write each new basis vector in terms of 
    the "standard" monomial basis, i.e. find `$$e_{k, l}$$` so that `$$ \mathbf{b}_k = \sum_{l=1}^4 e_{k, l} \mathbf{e}_l$$`. Hint: `$$ e_{2,2} = 1$$`, `$$e_{2, \{1, 3, 4\}} = 0$$`. 
    * Use these coefficients to form the matrix equation `$$ \begin{bmatrix} \mathbf{b}_1 ~ \ldots ~ \mathbf{b}_k \end{bmatrix} \mathbf{x}_\mathbf{b} = \mathbf{x}_\mathbf{e}.$$` How
    does this equation show that `$$-1, x, -x^2, x^3$$` form a basis? (Hint: use invertibility and the determinant).
    * Redo the process above to derive the derivative operator in the `$$\mathbf{b}_k$$` basis. Show that the derivative of a constant polynomial is still zero.

Note: this exercise shows that the matrix representation of `$$ \der{}{x} $$` is different for different bases. However, it can be shown that features of the linear operator `$$\der{}{x}$$` like
the nullspace do not depend on this choice of basis. As a result, while representation of linear operators in a basis (i.e., as a matrix) are helpful for calculations (and certain bases can make it easy to read off properties of your linear operator from the matrix itself), most properties of `$$A$$` do not depend on what basis you write it in. I have also glossed over what happens when the dimensions of the domain and range of your linear operator are not equal, in which case you must use separate bases of the domain and range to find the coefficients of your matrix.

<!--Let's pretend that we have a linear operator `$$ A $$` that behaves "like a matrix" (most concisely, for `$$ a, b \in \mathbb{R}$$`, `$$\mathbf{x}, \mathbf{y} \in \mathbb{R}^n \textrm{ (maybe even } V)$$`, `$$ A(a\mathbf{x} + b \mathbf{y}) = aA\mathbf{x} + bA\mathbf{y} $$`) and that we have a basis `$$ \mathbf{b}_k$$`. 
First, let's write `$$ \mathbf{x} = \sum_l e_{l} \mathbf{e}_l$$` (`$$e_{l}$$` are just the entries of `$$\mathbf{x}$$` in a column vector!). What happens when we look at how `$$A$$` behaves on `$$\mathbf{x} $$`
`$$$
\begin{align*}
  A\left(\mathbf{x} \right) &= A\left(\sum_l e_{l} \mathbf{e}_l \right) \\
    &= \sum_l e_{l} A\left( \mathbf{e}_l \right) \\
    &= \sum_l e_{l} \mathbf{a}_l, 
\end{align*}
$$$`
BUT: `$$ \mathbf{a}_l$$` is the image of the basis vector `$$ \mathbf{e}_l$$` under `$$A$$`. If `$$A$$` were a matrix, this would be the `$$l$$`th column of the matrix (do the multiplication yourself to
convince yourself this is right).   -->


# Inner product structure, duals

An inner product is an additional operation `$$\langle \cdot, \cdot \rangle $$` that one can add to a vector space. 
It must satisfy certain [requirements](https://en.wikipedia.org/wiki/Inner_product_space). The most important one for our purposes is that for `$$ a \in \mathbb{R}$$`, `$$ \mathbf{x}, \mathbf{y}, \mathbf{z} \in \mathbb{R}^n$$`, `$$ \langle a\mathbf{x} + \mathbf{y}, \mathbf{z} \rangle = a\langle \mathbf{x}, \mathbf{z} \rangle + \langle \mathbf{y}, \mathbf{z} \rangle $$`
It is a generalization of the dot product on `$$\mathbb{R}^n$$`, `$$ \langle \mathbf{x}, \mathbf{y} \rangle = \sum_k x_k y_k $$`. 
The aforementioned requirements are the minimal set of constraints required to guarantee that the inner product you defined on your vector space `$$V$$`, gets you the properties that make the dot product useful.

## Why are orthogonal bases good?
Bases do not require an inner product to be defined and analyzed. However, if we have an inner product, we can define a condition for a basis to be particularly nice.
The standard basis `$$ \mathbf{e}_k$$` satisfies `$$$ \langle \mathbf{e}_i, \mathbf{e}_j \rangle = \begin{cases} 1 \textrm{ if } i = j \\ 0 \textrm{ otherwise} \end{cases} $$$`,
meaning that for distinct `$$ \mathbf{e}_i, \mathbf{e}_j$$`, the vectors are at 90º to each other. A basis that satisfies this latter property alone is called "orthogonal"; if, additionally, `$$\langle e_i, e_i \rangle = 1$$`, then the basis is called "orthonormal".  

Recall that for a general basis `$$\mathbf{b}_k $$`, solving for the coefficients `$$ b_k $$` that reconstruct a vector `$$\mathbf{x}$$` as `$$ \mathbf{x} = \sum b_k \mathbf{b_k}$$` requires a full linear solve. 
However, let `$$ \mathbf{e}_l $$` be an orthonormal basis. First, suppose we do the full solve to reconstruct `$$ \mathbf{x} = \sum e_l \mathbf{e}_l$$`.  
Then we can calculate 
`$$$
\langle x, \mathbf{e}_k \rangle = \langle \sum e_l \mathbf{e}_l, \mathbf{e}_k \rangle = \sum e_l \langle \mathbf{e}_l, \mathbf{e}_k \rangle = \sum e_l \begin{cases}1 \textrm{ if } k = l \\ 0 \textrm{ otherwise}\end{cases} = e_k.
$$$`
What this means is, the coefficient `$$ e_k $$` in the sum above can be calculated simply from `$$ \langle x, e_k \rangle $$`. You don't have to solve a full system. 


## A concrete example from function approximation


### The construction of the Legendre polynomials

Let's return to the example of polynomial quadrature above. It turns out that for, e.g., `$$ f, g \in V^3_1 (\mathbb{R})$$`, making the definition `$$ \langle f, g \rangle \equiv \int_I fg \intd{x} $$` satisfies the requirements of an inner product! Starting with the convention `$$\mathbf{l}_1 = 1$$`, and requiring that the polynomial `$$\mathbf{l}_{k+1}$$` satisfy `$$ \langle \mathbf{l}_{k+1}, \mathbf{l}_l \rangle = 0$$` for `$$ l \leq k $$` (this is analogous to gram-schmidt, if you've encountered that), you generate a sequence of polynomials that are an orthogonal (easily made orthonormal) basis for `$$V_1^n(\mathbb{R})$$`. Using the standard (unweighted) inner product `$$ \int fg \intd{x} $$`, this generates the Legendre polynomials. 

For the second part of our derivation, recall that for any set of `$$n$$` points, we can uniquely fit a polynomial of degree `$$ n-1 $$` through those points (the coefficients, e.g., in the monomial
basis can be calculated by solving a linear system! An excellent exercise is to formulate this system and solve it in, e.g., python and seeing how it becomes very numerically unstable as `$$n$$` increases, if you choose your interpolation points arbitrarily).
The idea behind Gauss-Lobatto quadrature is to take the roots (zeros) of the `$$m$$`th Legendre polynomial, `$$x_1, \ldots, x_m$$` (when we eventually get to SE, we will include the endpoints of the interval `$$[-1, 1]$$`, but for now we ignore this). Then let `$$q_k$$` be the interpolating polynomial that satisfies `$$$ q_k(x_l) = \begin{cases} 1 \textrm{ if } k=l \\ 0 \textrm{ otherwise} \end{cases}. $$$` 

If we have a polynomial `$$f$$` and its evaluations `$$ f_k = f(x_k)$$`, then if we define `$$w_k = \int_{[-1, 1]} q_k \intd{x} $$` and calculate `$$ \sum_k w_k f_k$$`, then this sum exactly computes `$$ \int_{[-1, 1]} f \intd{x}$$` so long as `$$f$$` is of degree `$$ 2n-1$$` or less.

Ok, so we have constructed `$$ \sum_k w_k f_k $$` as a way to calculate an integral. It turns out that this also allows us to define an inner product, `$$ \langle f, g \rangle = \sum_k w_k f(x_k) g(x_k) $$`. First observe that `$$\langle q_k, q_l \rangle = \int q_k q_l \intd{x} = \sum_m w_m q_k(x_m) q_l(x_m) = \begin{cases} w_m \textrm{ if } k = l \\ 0 \textrm{ otherwise} \end{cases}  $$`, so `$$q_k$$` are an orthogonal basis. 
Now we're prepared to see why orthonormal bases are so useful. Suppose I have a polynomial `$$ h = \sum_k a_k q_k(x) $$`. If I want to determine the coefficients `$$ b_k $$` in the monomial basis, so `$$ h = \sum_k b_k x^k $$`, then I would need to solve the linear system I described several paragraphs ago (the monomial basis is emphatically not orthogonal). However, if I had a polynomial `$$ f = \sum_k b_k x^k$$` and I want to calculate its coefficients in the `$$q_k$$` basis, then we find `$$ \sum_k \langle f, q_k \rangle q_k = \sum_k \int f q_k \intd{x} q_k = \sum_k \left( \sum_l w_l f(x_l) q_k(x_l)\right)q_k = \sum_k f(x_k) q_k $$`

## The adjoint (basically, transpose)  



# Galerkin

## Weak form of an equation

## Bobunov-Galerkin


## Petrov-Galerkin
