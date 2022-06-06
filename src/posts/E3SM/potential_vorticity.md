---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Potential vorticity in E3SM
  parent: E3SM
layout: layouts/post.njk
---

Define `$$\zeta_\eta = \partial^\eta_x v - \partial^\eta_y u  $$`

<table class="eqn">
  <tr>
  <td>$$\mathrm{PV}$$</td> <td> $$= -g(f \cdot \mathbf{k} + \nabla_\eta \times \mathbf{v}) \cdot \nabla_\eta \theta $$</td>
  </tr>
  <tr>
    <td></td> <td>$$= -\frac{g}{p_0\partial_\eta a + p_s \partial_\eta b } \left[\left((\zeta_\eta + f) \partial_\eta \theta - \left(\partial_\eta v \right) \left(\partial^\eta_x \theta \right) + \left(\partial_\eta u\right) \left( \partial^\eta_y \theta \right) \right) \right]  $$</td>
  </tr>
</table>


In order to compute vertical derivatives, we'll just need to use a finite difference method. 
I'll use a second-order method to start with.

Because we have a vertically lagrangian model, I need to derive an appropriate stencil.
It's always fun when I get to actually use a thing that I learned in a class.

Suppose we have measurements of a quantity `$$u$$` at points `$$z_0, z_1, z_2$$`.
Call these measurements `$$u_0, u_1, u_2$$`.
One could think of these as being ordered along the `$$z$$` axis, but for the sake
of not having to explicitly dealing with boundary conditions I'll try not to actually
use that assumption.

We derive a quadratic approximation to `$$u$$`. 
We use an affine change of variables `$$ \zeta: z \mapsto (z-z_1) $$` 
for notational convenience. We therefore denote `$$\zeta_i = \zeta(z_i) = z_i - z_1$$`
(note, this encodes "signed `$$h$$`s" in some sense).
Our main equation of interest takes
the form 
`$$$f(\zeta) = a_1\zeta^2 + a_2\zeta + a_3 $$$`

with constraints 
<table class="eqn">
  <tr>
    <td>$$ u_1 $$</td><td>$$= a_1\zeta_1^2 + a_2\zeta_1 + a_3 $$ </td>
  </tr>
  <tr>
    <td></td><td>$$\implies a_3 = u_1$$</td>
  </tr>
  <tr>
    <td>$$ u_0 $$</td><td>$$=a_1\zeta_0^2 + a_2\zeta_0 + u_1  $$</td>
  </tr>
  <tr>
    <td>$$ u_2 $$</td><td>$$=a_1\zeta_2^2 + a_2\zeta_2 + u_1 $$</td>
  </tr>
</table>


which we can rewrite as
`$$$
\begin{bmatrix}
\zeta_0^2 & \zeta_0\\
\zeta_2^2 & \zeta_2  
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2
\end{bmatrix} =
\begin{bmatrix}
u_0 - u_1\\
u_2 - u_1
\end{bmatrix}
$$$`
asdf

We care about the estimate `$$f'(\zeta_0) = a_2 $$`. 
The solution to the above equations will exist iff `$$z_0 \neq z_1 \neq z_2 $$`. 
We can find said solution analytically
`$$$\begin{bmatrix}
a_1 \\
a_2
\end{bmatrix} =
\frac{1}{\zeta_0^2 \zeta_2 - \zeta_0 \zeta_2^2}
\begin{bmatrix}
  \zeta_2 & -\zeta_0 \\
   -\zeta_2^2 & \zeta_0^2
\end{bmatrix}
\begin{bmatrix}
u_0-u_1\\
u_2 - u_1
\end{bmatrix}$$$`
And so find our second-order approximation of slope to be

<table class="eqn">
  <tr>
    <td>$$a_2$$</td><td>$$= \frac{1}{\zeta_0^2\zeta_2 - \zeta_0\zeta_2^2} \left(-(u_0-u_1)\zeta_2^2 + (u_2-u_1) \zeta_0^2 \right)$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \frac{(u_1-u_0)(z_2-z_1)^2 + (u_2-u_1) (z_0-z_1)^2}{(z_0-z_1)^2(z_2-z_1) - (z_0-z_1)(z_2-z_1)^2} $$</td>
  </tr>
</table>

The following python code verifies that this should be second order:

<details>
<summary><code>Benchmark finite difference stencil</code></summary>
  
<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f92672">import</span> <span style="color: #f8f8f2">numpy</span> <span style="color: #66d9ef">as</span> <span style="color: #f8f8f2">np</span>
<span style="color: #f92672">import</span> <span style="color: #f8f8f2">matplotlib.pyplot</span> <span style="color: #66d9ef">as</span> <span style="color: #f8f8f2">plt</span>

<span style="color: #66d9ef">def</span> <span style="color: #a6e22e">fin_dif_2ord</span><span style="color: #f8f8f2">(u,</span> <span style="color: #f8f8f2">z):</span>
    <span style="color: #66d9ef">assert</span><span style="color: #f8f8f2">(u</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">shape</span> <span style="color: #f92672">==</span> <span style="color: #f8f8f2">z</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">shape)</span>
    <span style="color: #f8f8f2">z_0</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(z)</span>
    <span style="color: #f8f8f2">z_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(z)</span>
    <span style="color: #f8f8f2">z_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(z)</span>
    <span style="color: #f8f8f2">z_0[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">z_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z</span>
    <span style="color: #f8f8f2">z_2[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span>
    <span style="color: #f8f8f2">z_0[:,</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #ae81ff">2</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">z_2[:,</span> <span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #f92672">-</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">]</span>

    <span style="color: #f8f8f2">u_0</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(u)</span>
    <span style="color: #f8f8f2">u_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(u)</span>
    <span style="color: #f8f8f2">u_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(u)</span>
    <span style="color: #f8f8f2">u_0[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">u_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u</span>
    <span style="color: #f8f8f2">u_2[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span>
    <span style="color: #f8f8f2">u_0[:,</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #ae81ff">2</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">u_2[:,</span> <span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #f92672">-</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">]</span>
	
    <span style="color: #f8f8f2">numerator</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(u_1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">u_0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(z_2</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(u_2</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">u_1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(z_0</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span>
    <span style="color: #f8f8f2">denominator</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(z_0</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(z_2</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(z_0</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(z_2</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_1)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span>
    <span style="color: #66d9ef">return</span><span style="color: #f8f8f2">(numerator</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">denominator)</span>

<span style="color: #66d9ef">def</span> <span style="color: #a6e22e">fin_dif_1ord</span><span style="color: #f8f8f2">(u,</span> <span style="color: #f8f8f2">z):</span>
    <span style="color: #66d9ef">assert</span><span style="color: #f8f8f2">(u</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">shape</span> <span style="color: #f92672">==</span> <span style="color: #f8f8f2">z</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">shape)</span>
    <span style="color: #f8f8f2">z_0</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(z)</span>
    <span style="color: #f8f8f2">z_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(z)</span>
    <span style="color: #f8f8f2">z_0[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">z_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z</span>
    <span style="color: #f8f8f2">z_0[:,</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>

    <span style="color: #f8f8f2">u_0</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(u)</span>
    <span style="color: #f8f8f2">u_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros_like(u)</span>
    <span style="color: #f8f8f2">u_0[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #f8f8f2">:</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>
    <span style="color: #f8f8f2">u_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u</span>
    <span style="color: #f8f8f2">u_0[:,</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u[:,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">]</span>
	
    <span style="color: #f8f8f2">numerator</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u_1</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">u_0</span>
    <span style="color: #f8f8f2">denominator</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">z_1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">z_0</span>
    <span style="color: #66d9ef">return</span><span style="color: #f8f8f2">(numerator</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">denominator)</span>



<span style="color: #f8f8f2">n_h</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">32</span>
<span style="color: #f8f8f2">n_z</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">100</span>
<span style="color: #f8f8f2">h_base</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.01</span>
<span style="color: #f8f8f2">u_arr</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros((n_h,</span> <span style="color: #f8f8f2">n_z))</span>
<span style="color: #f8f8f2">z_arr</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros((n_h,</span> <span style="color: #f8f8f2">n_z))</span>
<span style="color: #f8f8f2">hs</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">linspace(</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">,</span> <span style="color: #ae81ff">8</span><span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">n_h)</span>
<span style="color: #f8f8f2">hrange</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">arange(</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">n_z,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">hstep</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(hrange</span> <span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">print(hstep)</span>

<span style="color: #66d9ef">for</span> <span style="color: #f8f8f2">hind,</span> <span style="color: #f8f8f2">h</span> <span style="color: #f92672">in</span> <span style="color: #f8f8f2">enumerate(hs):</span>
	<span style="color: #f8f8f2">z_arr[hind,</span> <span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">h_base</span> <span style="color: #f92672">*</span> <span style="color: #ae81ff">2</span><span style="color: #f92672">**</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">h)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">hstep</span>
	<span style="color: #f8f8f2">u_arr[hind,</span> <span style="color: #f8f8f2">:]</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">sin(z_arr[hind,</span> <span style="color: #f8f8f2">:])</span>

<span style="color: #f8f8f2">du_dz_analytic</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">cos(</span> <span style="color: #f8f8f2">u_arr)</span>
<span style="color: #f8f8f2">du_dz_numeric_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">fin_dif_1ord(u_arr,</span> <span style="color: #f8f8f2">z_arr)</span>
<span style="color: #f8f8f2">du_dz_numeric_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">fin_dif_2ord(u_arr,</span> <span style="color: #f8f8f2">z_arr)</span>
<span style="color: #f8f8f2">residual_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">abs(du_dz_analytic</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">du_dz_numeric_1)</span>
<span style="color: #f8f8f2">residual_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">abs(du_dz_analytic</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">du_dz_numeric_2)</span>
<span style="color: #f8f8f2">max_res_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">residual_1</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">max(axis</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">max_res_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">residual_2</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">max(axis</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>

<span style="color: #f8f8f2">lplot_1</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">log(max_res_1)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">log(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">lplot_2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">log(max_res_2)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">log(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> 


<span style="color: #f8f8f2">plt</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">figure()</span>
<span style="color: #f8f8f2">plt</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">plot(hs,</span> <span style="color: #f8f8f2">lplot_1,</span> <span style="color: #f8f8f2">label</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;first ord&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">plt</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">plot(hs,</span> <span style="color: #f8f8f2">lplot_2,</span> <span style="color: #f8f8f2">label</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;second ord&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">plt</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">legend()</span>
<span style="color: #f8f8f2">plt</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">show()</span>
</pre></div>


</pre>
</details>


## Choosing actual functions for PV formulation:

We use the folliwng formulation of potential vorticity:

`$$$ \mathrm{PV} = - \frac{g}{p_0 \partial_\eta a + p_s \partial_\eta b } \left[ \left(\zeta_\eta + f \right) \partial_\eta \theta - \frac{1}{\overline{r} \cos \varphi} \left(\partial_\eta v \right) \left(^\eta\partial_\lambda \theta\right) + \frac{1}{\overline{r}} (\partial_\eta u)\left(^\eta\partial_\varphi \theta\right) \right] $$$`


with `$$ \zeta_\eta = \frac{1}{\overline{r}\cos\varphi} \left((^\eta \partial_\lambda v) - (^\eta \partial_\varphi u\cos \phi ) \right) $$`


### how to calculate the thing

* ✅ `$$ \overline{r}, g $$` Use constants provided by ESM framework.
  * `physical_constants, only: g0=>g,kappa0=>kappa,Rgas,Cp0=>Cp,Rwater_vapor,rearth0,omega0, dd_pi`
* ✅ `$$ p_0, p_s $$` 
  * For `$$p_0$$`: member of `hvcoord_t,`  `hvcoord%ps0`
  * For `$$p_s$$`: member of member of `elem_state_t`, `ps_v`;   
* ✅ `$$ \theta $$`:
  * in `elem_ops` there is `get_field` which can be called with `name` `pottemp`/
* ✅ `$$ \partial_\eta a, \partial_\eta b $$`
  * Use finite difference above and `hvcoord_t` i.e. `hvcoord%hyam`, `hycoord%hybm`
  * Use `hvcoord%d_etai` (distance between `etam(k)` and `etam(k-1)`) or `hvcoord%etam` if that's simpler.
* ✅ `$$ \zeta_\eta $$`
  *  `vorticity_sphere` in `derivative_mod`
* ✅ `$$ f $$`
  * ` fcor ` in `element_t`
* ✅ `$$ \partial_\eta \theta $$`
  *  Use calculated `theta` which should be stored somewhere
* ✅ `$$ \cos(\varphi) $$`
  * `elem(ie)%spherep(i,j)%lat`
* ✅ `$$ \partial_\eta v$$`
  * Use finite differences and `elem_state%v`
* ✅ `$$ \partial_\lambda \theta $$`
  * Use `gradient_sphere` from `derivative_mod`
* ✅ `$$ \partial_\eta u $$`
  * Use finite differences and `elem_state%v`
* ✅ `$$ \partial_\varphi \theta $$`
  * Use `gradient_sphere` from `derivative_mod`


`share/prim_advance_mod.F90` is where to put the code

## changes:
New routines to create:
`partial_eta_scalar` in `derivative_mod`


### `theta-l/element_state.F90`
* `66:     real (kind=real_ind) :: ertel_pv                                  ! hydrostatic ertel's potential vorticity`

### `share/derivative_mod_base.F90`

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #75715e">!DIR$ ATTRIBUTES FORCEINLINE :: partial_eta</span>
  <span style="color: #66d9ef">function </span><span style="color: #f8f8f2">partial_eta(s,etam)</span> <span style="color: #66d9ef">result</span><span style="color: #f8f8f2">(du_deta)</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!   input:  u = scalar </span>
<span style="color: #75715e">!   ouput:  du_deta = vertical derivative of u</span>
<span style="color: #75715e">!</span>


    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">s(np,</span> <span style="color: #f8f8f2">np,</span> <span style="color: #f8f8f2">nlev)</span>  <span style="color: #75715e">! in lat-lon coordinates</span>
    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">etam(nlev)</span>
    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">du_deta(np,</span> <span style="color: #f8f8f2">np,</span> <span style="color: #f8f8f2">nlev)</span>

    <span style="color: #75715e">! Local</span>

    <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">i,</span> <span style="color: #f8f8f2">j</span> 

    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">u1(nlev),</span> <span style="color: #f8f8f2">u2(nlev),</span> <span style="color: #f8f8f2">u3(nlev)</span>
    
    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">eta1(nlev),</span> <span style="color: #f8f8f2">eta2(nlev),</span> <span style="color: #f8f8f2">eta3(nlev)</span>
    
    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">num(nlev),</span> <span style="color: #f8f8f2">den(nlev)</span>

    <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
       <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">l</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
 
       <span style="color: #f8f8f2">eta1(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">:nlev)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">etam(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
       <span style="color: #f8f8f2">eta2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">etam(:)</span>
       <span style="color: #f8f8f2">eta3(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">etam(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">:nlev)</span>
       <span style="color: #f8f8f2">eta1(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">etam(</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span>
       <span style="color: #f8f8f2">eta3(nlev)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">etam(nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span>
    
       <span style="color: #f8f8f2">u1(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">:nlev)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
       <span style="color: #f8f8f2">u2</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #f8f8f2">:)</span>
       <span style="color: #f8f8f2">u3(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #ae81ff">2</span><span style="color: #f8f8f2">:nlev)</span>
       <span style="color: #f8f8f2">u1(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span>
       <span style="color: #f8f8f2">u3(nlev)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">u(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #f8f8f2">nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span>


     
       <span style="color: #f8f8f2">num</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(u2</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">u1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(eta3</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2.0</span><span style="color: #960050; background-color: #1e0010">_</span><span style="color: #f8f8f2">real_kind</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(u3</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">u2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(eta1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2.0</span><span style="color: #960050; background-color: #1e0010">_</span><span style="color: #f8f8f2">real_kind</span>
       <span style="color: #f8f8f2">den</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(eta1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2.0</span><span style="color: #960050; background-color: #1e0010">_</span><span style="color: #f8f8f2">real_kind</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(eta3</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(eta1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(eta3</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta2)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2.0</span><span style="color: #960050; background-color: #1e0010">_</span><span style="color: #f8f8f2">real_kind</span>
       <span style="color: #f8f8f2">du_deta(i,</span> <span style="color: #f8f8f2">j,</span> <span style="color: #f8f8f2">:)</span>  <span style="color: #f92672">=</span> <span style="color: #f8f8f2">num</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">den</span>
       <span style="color: #66d9ef">end do</span>
<span style="color: #66d9ef">    end do</span>
<span style="color: #66d9ef">   </span>
<span style="color: #66d9ef">    </span>
<span style="color: #66d9ef">  end function </span><span style="color: #f8f8f2">partial_eta</span>
</pre></div>


</pre>


## `theta-l/share/element_ops.F90`


## `theta-l/share/prim_advance_mod.F90`

Add code around line `1210`.


## `theta-l/share/derivative_mod.F90`

Add `partial_eta` to list of used subroutines.


## designing output:

In file `prim_movie_mod.F90` around line `715` add the following code:

```

```

Around line `222`: create field in netcdf

Use a getter method?