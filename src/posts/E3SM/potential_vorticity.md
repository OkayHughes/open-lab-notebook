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


# Quick derivation:

`$$PV = \frac{f + \mathbf{k} \cdot \left( \nabla_\theta \times \mathbf{v} \right)}{-g^{-1}\pder{p}{\theta}} $$`

``$$$
\begin{align*}
  &g \left[\frac{1}{a\cos\phi}  \pder{v}{p}\left( \pder{\theta}{\lambda} \right)_p - \frac{1}{a}\pder{u}{p}\left(\pder{\theta}{\phi}\right)_p+ (f + \zeta_p) \left(-\pder{\theta}{p} \right) \right]\\
  &= g\left[\frac{1}{a\cos\phi}  \pder{v}{\eta}\pder{\eta}{p}\left( \pder{\theta}{\lambda} \right)_p - \frac{1}{a}\pder{u}{\eta}\pder{\eta}{p}\left(\pder{\theta}{\phi}\right)_p+ (f + \zeta_p) \left(-\pder{\theta}{\eta}\pder{\eta}{p} \right) \right]
\end{align*}
$$$``

Useful identity:
`$$$
\partial_{s} \left[u(x, y, s) \right] = \partial_{t}\left[s \right]  \partial_x \left[ t(x, y, s) \right] \partial_{x} \left[u(x, y, t) \right]+ \partial_{x} \left[ u(x, y, t)  \right]
$$$`

`$$$
\partial_{p} \left[\theta(x, y, p) \right] = \partial_{t}\left[s \right]  \partial_x \left[ t(x, y, s) \right] \partial_{x} \left[u(x, y, t) \right]+ \partial_{x} \left[ u(x, y, t)  \right]
$$$`





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

<details>
<summary>Complete diff of <code>${E3SM_ROOT}/components/homme</code></summary>
  
  
<pre>
<code>
diff --git a/components/homme/src/common_movie_mod.F90 b/components/homme/src/common_movie_mod.F90
index 0762d19..66fd6fc 100644
--- a/components/homme/src/common_movie_mod.F90
+++ b/components/homme/src/common_movie_mod.F90
@@ -27,7 +27,7 @@ module common_movie_mod
 #ifndef HOMME_WITHOUT_PIOLIBRARY
 
 #ifdef _PRIM
-  integer, parameter :: varcnt =  38
+  integer, parameter :: varcnt =  39
 
   integer, parameter :: maxdims =  6
 
@@ -44,6 +44,7 @@ module common_movie_mod
                                                  'div        ', &
                                                  'T          ', &
                                                  'Th         ', &
+                                                 'PV         ', &
                                                  'u          ', &
                                                  'v          ', &
                                                  'w          ', &
@@ -84,6 +85,7 @@ module common_movie_mod
                                                                1,2,5,0,0,0, & ! div
                                                                1,2,5,0,0,0, & ! T
                                                                1,2,5,0,0,0, & ! Th
+                                                               1,2,5,0,0,0, & ! PV
                                                                1,2,5,0,0,0, & ! u
                                                                1,2,5,0,0,0, & ! v
                                                                1,2,5,0,0,0, & ! w
@@ -113,13 +115,13 @@ module common_movie_mod
 
   integer, parameter :: vartype(varcnt)=(/nf_double, nf_double, nf_double,nf_double, nf_double,nf_double,nf_double,& !ps:cv_lon
                                           nf_int,    nf_double,nf_double,nf_double,nf_double,& !corners:T
-                                          nf_double, nf_double,nf_double,nf_double,nf_double,nf_double,& !Th:w
+                                          nf_double, nf_double,nf_double,nf_double,nf_double,nf_double,nf_double,& !Th:w
                                           nf_double, nf_double, nf_double,nf_double,& 
                                           nf_double, nf_double,nf_double,nf_double,nf_double,& !Q:geo
                                           nf_double, nf_double,nf_double,nf_double,nf_double,nf_double,& !omega:ilev
                                           nf_double, nf_double,nf_double,nf_double,nf_double/)
   logical, parameter :: varrequired(varcnt)=(/.false.,.false.,.false.,.false.,.false.,.false.,.false.,&
-                                              .false.,.false.,.false.,.false.,.false.,&
+                                              .false.,.false.,.false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,.false.,&
diff --git a/components/homme/src/interp_movie_mod.F90 b/components/homme/src/interp_movie_mod.F90
index e4e1bf2..065b2fb 100644
--- a/components/homme/src/interp_movie_mod.F90
+++ b/components/homme/src/interp_movie_mod.F90
@@ -51,7 +51,7 @@ module interp_movie_mod
 #undef V_IS_LATLON
 #if defined(_PRIM)
 #define V_IS_LATLON
-  integer, parameter :: varcnt = 45
+  integer, parameter :: varcnt = 46
   integer, parameter :: maxdims =  5
   character*(*), parameter :: varnames(varcnt)=(/'ps       ', &
                                                  'geos     ', &
@@ -64,6 +64,7 @@ module interp_movie_mod
                                                  'div      ', &
                                                  'T        ', &
                                                  'Th       ', &
+                                                 'PV       ', &
                                                  'u        ', &
                                                  'v        ', &
                                                  'w        ', &
@@ -99,7 +100,7 @@ module interp_movie_mod
                                                  'hybi     ', &
                                                  'time     '/)
   integer, parameter :: vartype(varcnt)=(/PIO_double,PIO_double,PIO_double,PIO_double,PIO_double,&
-                                          PIO_double,PIO_double,PIO_double,PIO_double, &
+                                          PIO_double,PIO_double,PIO_double,PIO_double,PIO_double, &
                                           PIO_double,PIO_double,PIO_double,PIO_double, PIO_double,&
                                           PIO_double,PIO_double,PIO_double,PIO_double,&
                                           PIO_double,PIO_double,PIO_double,PIO_double,&
@@ -113,7 +114,7 @@ module interp_movie_mod
                                           PIO_double,PIO_double,&
                                           PIO_double/)
   logical, parameter :: varrequired(varcnt)=(/.false.,.false.,.false.,.false.,.false.,&
-                                              .false.,.false.,.false.,.false.,.false.,&
+                                              .false.,.false.,.false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,.false.,&
                                               .false.,.false.,.false.,.false.,.false.,&
@@ -136,6 +137,7 @@ module interp_movie_mod
        1,2,3,5,0,  &   ! div
        1,2,3,5,0,  &   ! T
        1,2,3,5,0,  &   ! Th
+       1,2,3,5,0,  &   ! PV
        1,2,3,5,0,  &   ! u
        1,2,3,5,0,  &   ! v
        1,2,3,5,0,  &   ! w
@@ -375,6 +377,7 @@ contains
     call nf_variable_attributes(ncdf, 'hyai', 'hybrid A coefficiet at layer interfaces' ,'dimensionless')
     call nf_variable_attributes(ncdf, 'hybi', 'hybrid B coefficiet at layer interfaces' ,'dimensionless')
     call nf_variable_attributes(ncdf, 'Th',   'potential temperature \theta','degrees kelvin')
+    call nf_variable_attributes(ncdf, 'PV',   'Ertel Potential Vorticity','K \cdot m^2 / (kg \cdot s)')
     call nf_variable_attributes(ncdf, 'w_i',  'vertical wind component on interfaces','meters/second')
     call nf_variable_attributes(ncdf, 'mu_i', 'mu=dp/d\pi on interfaces','dimensionless')
     call nf_variable_attributes(ncdf, 'geo_i','geopotential on interfaces','meters')
@@ -930,6 +933,21 @@ contains
                 call nf_put_var(ncdf(ios),datall,start3d, count3d, name='Th')
                 deallocate(datall,var3d)
              end if
+             if(nf_selectedvar('PV', output_varnames)) then
+                if (par%masterproc) print *,'writing PV...'
+                st=1
+                allocate(datall(ncnt,nlev),var3d(np,np,nlev,1))
+                do ie=1,nelemd
+                   call get_field(elem(ie),'PV',temp3d,hvcoord,n0,n0_Q)
+                   en=st+interpdata(ie)%n_interp-1
+                   call interpolate_scalar(interpdata(ie), temp3d, &
+                        np, nlev, datall(st:en,:))
+                   st=st+interpdata(ie)%n_interp
+                end do
+                call nf_put_var(ncdf(ios),datall,start3d, count3d, name='PV')
+                deallocate(datall,var3d)
+             end if
+
 
 
              do qindex=1,min(qsize,5)
diff --git a/components/homme/src/preqx/element_state.F90 b/components/homme/src/preqx/element_state.F90
index e565218..ff90ec6 100644
--- a/components/homme/src/preqx/element_state.F90
+++ b/components/homme/src/preqx/element_state.F90
@@ -66,7 +66,6 @@ module element_state
   !___________________________________________________________________
   type, public :: elem_accum_t
 
-#ifdef ENERGY_DIAGNOSTICS
 
     ! Energy equation:
     ! KE_t  = T1 + T2  + D1   + Err   +  vertical & horizontal advection terms
@@ -113,7 +112,6 @@ module element_state
     real (kind=real_kind) :: DIFF(np,np,2,nlev)                       ! net hypervis term
     real (kind=real_kind) :: DIFFT(np,np,nlev)                        ! net hypervis term
     real (kind=real_kind) :: CONV(np,np,2,nlev)                       ! dpdn u dot CONV = T1 + T2
-#endif
 
     ! the "4" timelevels represents data computed at:
     !  1  t-.5
diff --git a/components/homme/src/prim_movie_mod.F90 b/components/homme/src/prim_movie_mod.F90
index 7e5c125..3f2b58a 100644
--- a/components/homme/src/prim_movie_mod.F90
+++ b/components/homme/src/prim_movie_mod.F90
@@ -233,6 +233,7 @@ contains
 
     call nf_variable_attributes(ncdf, 'T', 'Temperature','degrees kelvin')
     call nf_variable_attributes(ncdf, 'Th','potential temperature \theta','degrees kelvin')
+    call nf_variable_attributes(ncdf, 'PV','Ertel potential vorticity','K\cdot m^2 / (kg \cdot s)')
     call nf_variable_attributes(ncdf, 'w', 'vertical wind component','meters/second')
     call nf_variable_attributes(ncdf, 'w_i',  'vertical wind component on interfaces','meters/second')
     call nf_variable_attributes(ncdf, 'mu_i', 'mu=dp/d\pi on interfaces','dimensionless')
@@ -608,6 +609,17 @@ contains
                 end do
                 call nf_put_var(ncdf(ios),var3d,start, count, name='Th')
              end if
+             if(nf_selectedvar('PV', output_varnames)) then
+                st=1
+                do ie=1,nelemd
+                   call get_field(elem(ie),'potvort',vartmp,hvcoord,n0,n0_Q)
+                   en=st+elem(ie)%idxp%NumUniquePts-1
+                   call UniquePoints(elem(ie)%idxP,nlev,vartmp,var3d(st:en,:))
+                   st=en+1
+                end do
+                call nf_put_var(ncdf(ios),var3d,start, count, name='PV')
+             end if
+
 
             if(nf_selectedvar('rho', output_varnames)) then
                 if (par%masterproc) print *,'writing rho...'
@@ -713,6 +725,18 @@ contains
                 enddo
                 call nf_put_var(ncdf(ios),var3d,start, count, name='w')
              end if
+             if(nf_selectedvar('w', output_varnames)) then
+                if (par%masterproc) print *,'writing w...'
+                st=1
+                do ie=1,nelemd
+                   en=st+elem(ie)%idxp%NumUniquePts-1
+                   call get_field(elem(ie),'w',vartmp,hvcoord,n0,n0_Q)
+                   call UniquePoints(elem(ie)%idxP,nlev,vartmp,var3d(st:en,:))
+                   st=en+1
+                enddo
+                call nf_put_var(ncdf(ios),var3d,start, count, name='w')
+             end if
+
 
              if(nf_selectedvar('w_i', output_varnames)) then
                 if (par%masterproc) print *,'writing w_i...'
diff --git a/components/homme/src/share/derivative_mod_base.F90 b/components/homme/src/share/derivative_mod_base.F90
index e6f795e..ecfe6c1 100644
--- a/components/homme/src/share/derivative_mod_base.F90
+++ b/components/homme/src/share/derivative_mod_base.F90
@@ -57,6 +57,8 @@ private
       module procedure gradient_wk_nonstag
   end interface
 
+ 
+
   private :: dvvinit
 
 ! these routines compute spherical differential operators as opposed to
@@ -81,13 +83,13 @@ private
   public  :: vlaplace_sphere_wk
   public  :: vlaplace_sphere_wk_contra
   public  :: vlaplace_sphere_wk_cartesian
+  public  :: partial_eta
 !  public  :: laplace_eta
   public  :: laplace_z
   public  :: element_boundary_integral
   public  :: edge_flux_u_cg
   public  :: limiter_optim_iter_full
   public  :: limiter_clip_and_sum
-
 contains
 
 ! ==========================================
@@ -1351,6 +1353,56 @@ contains
   end function vlaplace_sphere_wk_contra
 
 
+!DIR$ ATTRIBUTES FORCEINLINE :: second_order_findiff
+  function second_order_findiff(u1, u2, u3, zeta1, zeta3) result(du_dzeta)
+        real(kind=real_kind), intent(in) :: u1, u2, u3, zeta1, zeta3
+        real(kind=real_kind) :: du_dzeta
+        du_dzeta = (u2-u1) * zeta3**2.0_real_kind + (u3-u2) * zeta1**2.0_real_kind
+        du_dzeta = du_dzeta / (zeta1**2.0_real_kind * zeta3 - zeta1 * zeta3**2.0_real_kind)
+
+  end function second_order_findiff
+!DIR$ ATTRIBUTES FORCEINLINE :: partial_eta
+  function partial_eta(u,etam) result(du_deta)
+!
+!   input:  u = scalar 
+!   ouput:  du_deta = vertical derivative of u
+!
+
+
+    real(kind=real_kind), intent(in) :: u(nlev)  ! in lat-lon coordinates
+    real(kind=real_kind), intent(in) :: etam(nlev)
+    real(kind=real_kind) :: du_deta(nlev)
+
+    ! Local
+
+
+    real(kind=real_kind) :: u1(nlev), u2(nlev), u3(nlev)
+    
+    real(kind=real_kind) :: eta1(nlev), eta2(nlev), eta3(nlev)
+    
+    real(kind=real_kind) :: num(nlev), den(nlev)
+
+ 
+    eta1(2:nlev) = etam(1:nlev-1)
+    eta2 = etam(:)
+    eta3(1:nlev-1) = etam(2:nlev)
+    eta1(1) = etam(3)
+    eta3(nlev) = etam(nlev-2)
+ 
+    u1(2:nlev) = u(1:nlev-1)
+    u2 = u
+    u3(1:nlev-1) = u(2:nlev)
+    u1(1) = u( 3)
+    u3(nlev) = u(nlev-2)
+
+
+        
+    num = (u2-u1)*(eta3-eta2)**2.0_real_kind + (u3-u2)*(eta1-eta2)**2.0_real_kind
+    den = (eta1-eta2)**2.0_real_kind * (eta3-eta2) - (eta1-eta2)*(eta3-eta2)**2.0_real_kind
+    du_deta  = num/den
+    
+  end function partial_eta
+
 
 #if 0
   subroutine laplace_eta(v,laplace,ncomp,etam) 
diff --git a/components/homme/src/theta-l/element_state.F90 b/components/homme/src/theta-l/element_state.F90
index 7d57dc0..38033b4 100644
--- a/components/homme/src/theta-l/element_state.F90
+++ b/components/homme/src/theta-l/element_state.F90
@@ -87,7 +87,6 @@ module element_state
   !___________________________________________________________________
   type, public :: elem_accum_t
 
-#ifdef ENERGY_DIAGNOSTICS
     ! Energy equation:
     real (kind=real_kind) :: KEu_horiz1(np,np)
     real (kind=real_kind) :: KEu_horiz2(np,np)
@@ -115,7 +114,6 @@ module element_state
     real (kind=real_kind) :: T2_nlevp_term(np,np)
 
     real (kind=real_kind) :: CONV(np,np,2,nlev)                       ! dpdn u dot CONV = T1 + T2
-#endif
 
     ! the "4" timelevels represents data computed at:
     !  1  t-.5
diff --git a/components/homme/src/theta-l/share/derivative_mod.F90 b/components/homme/src/theta-l/share/derivative_mod.F90
index a2efb73..72e5ef4 100644
--- a/components/homme/src/theta-l/share/derivative_mod.F90
+++ b/components/homme/src/theta-l/share/derivative_mod.F90
@@ -7,6 +7,6 @@ module derivative_mod
                                  derivinit, gradient, gradient_wk, vorticity, divergence, &
                                  gradient_sphere_wk_testcov, gradient_sphere_wk_testcontra, ugradv_sphere, vorticity_sphere, vorticity_sphere_diag, curl_sphere,     &
                                  curl_sphere_wk_testcov, vlaplace_sphere_wk, element_boundary_integral, edge_flux_u_cg, limiter_optim_iter_full, limiter_clip_and_sum,&
-                                 laplace_sphere_wk, divergence_sphere_wk, gradient_sphere, divergence_sphere, laplace_z, get_deriv
+                                 laplace_sphere_wk, divergence_sphere_wk, gradient_sphere, divergence_sphere, laplace_z, get_deriv, partial_eta
   implicit none
 end module derivative_mod
diff --git a/components/homme/src/theta-l/share/element_ops.F90 b/components/homme/src/theta-l/share/element_ops.F90
index 7d75e7f..ea7f94d 100644
--- a/components/homme/src/theta-l/share/element_ops.F90
+++ b/components/homme/src/theta-l/share/element_ops.F90
@@ -40,7 +40,6 @@
 !  get_temperature()   used in CAM dp_coupling layer
 !
 ! UTILITY ROUTINES USED BY THETA-L MODEL
-!  get_pottemp()
 !  get_dpnh_dp()
 !  get_hydro_pressure()
 !  get_nonhydro_pressure()
@@ -96,6 +95,7 @@ recursive subroutine get_field(elem,name,field,hvcoord,nt,ntQ)
   select case(name)
     case ('temperature','T'); call get_temperature(elem,field,hvcoord,nt)
     case ('pottemp','Th');    call get_pottemp(elem,field,hvcoord,nt,ntQ)
+    case ('potvort', 'PV');   call get_pot_vort(elem,field,hvcoord,nt)
     case ('phi','geo');       call get_phi(elem,field,phi_i,hvcoord,nt)
     case ('dpnh_dp');         call get_dpnh_dp(elem,field,hvcoord,nt)
     case ('pnh');             call get_nonhydro_pressure(elem,field,tmp ,hvcoord,nt)
@@ -170,6 +170,63 @@ recursive subroutine get_field(elem,name,field,hvcoord,nt,ntQ)
  
   end subroutine get_field_i
 
+  !_____________________________________________________________________
+  subroutine get_pot_vort(elem,pot_vort,hvcoord,nt)
+  !
+  use physical_constants, only: g,rearth
+  use derivative_mod, only: partial_eta, vorticity_sphere, gradient_sphere, derivative_t, get_deriv
+  implicit none
+    
+  type (element_t), intent(in)        :: elem
+  real (kind=real_kind), intent(out)  :: pot_vort(np,np,nlev)
+  type (hvcoord_t),     intent(in)    :: hvcoord                      ! hybrid vertical coordinate struct
+  integer, intent(in) :: nt! time level
+  
+  !   local
+  integer :: i, j, k
+  real(kind=real_kind), dimension(np,np,nlev) :: pottemp, rel_vort
+  real(kind=real_kind), dimension(nlev) :: da_deta, db_deta, du_deta, dv_deta
+  real(kind=real_kind), dimension(np, np, nlev, 2) :: grad_theta
+  real(kind=real_kind) :: eps = 1e-10
+  type (derivative_t)                    :: deriv
+
+  call get_deriv(deriv)
+  call get_pottemp(elem, pottemp, hvcoord, nt,-1)
+
+  da_deta = partial_eta(hvcoord%hyam, hvcoord%etam)
+  db_deta = partial_eta(hvcoord%hybm, hvcoord%etam)
+
+  do k=1,nlev
+      rel_vort(:, :, k) = vorticity_sphere(elem%state%v(:, :, :, k, nt), deriv, elem)
+      grad_theta(:, :, k, :) = gradient_sphere(pottemp(:, :, k), deriv, elem%Dinv)
+  end do
+
+  do j=1,np
+      do i=1,np
+        ! f ~ elem%fcor(i, j)
+        pot_vort(i, j, :) = cos(elem%spherep(i,j)%lat) * (rel_vort(i, j, :) + elem%fcor(i, j)) * partial_eta(pottemp(i, j, :), hvcoord%etam)
+        pot_vort(i, j, :) = pot_vort(i, j, :) - (1.0_real_kind / rearth) * (&
+                                                 partial_eta(elem%state%v(i,j,2,:,nt), hvcoord%etam) * &
+                                                 grad_theta(i, j, :, 1))
+        pot_vort(i, j, :) = pot_vort(i, j, :) + cos(elem%spherep(i,j)%lat) * (1.0_real_kind / rearth) * (&
+                                                partial_eta(elem%state%v(i,j,1,:,nt), hvcoord%etam) * &
+                                                grad_theta(i, j, :, 2))
+        pot_vort(i, j, :) = pot_vort(i, j, :) * -1.0_real_kind * (g / &
+                                                                 (hvcoord%ps0 *da_deta + &
+                                                                  elem%state%ps_v(i,j,nt) * &
+                                                                  db_deta))
+        do k=1,nlev
+            !if (abs(pot_vort(i, j, k)) < eps .and. cos(elem%spherep(i,j)%lat) < eps) then
+            !  pot_vort(i, j, k) = 0.0_real_kind
+            !else
+            pot_vort(i, j, k) = pot_vort(i, j, k) / cos(elem%spherep(i,j)%lat)
+            !end if
+        end do
+      end do
+  end do
+
+  end subroutine get_pot_vort
+ 
 
   !_____________________________________________________________________
   subroutine get_pottemp(elem,pottemp,hvcoord,nt,ntQ)
</pre>
</code>
</details>
