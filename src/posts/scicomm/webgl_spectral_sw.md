---
date: 2021-08-31
tags:
  - posts
  - slurm
  - science-communication
eleventyNavigation:
  parent: Science Communication
  key: WebGL spectral transform shallow water model.
layout: layouts/post.njk

---
## The goal:
In order to allow people to play with shallow water models
and examine their dynamics, I'm going to implement
a gpu-parallelized spectral transform shallow water model.
If scalability is feasible, I will extend this to a full
eulerian spectral transform solver for the hydrostatic
primitive equations (HPE).

## The paper:
I'll be following the details of [Hack and Jakob, 92](https://opensky.ucar.edu/islandora/object/technotes%3A112/datastream/PDF/download/Description_of_a_Global_Shallow_Water_Model_Based_on_the_Spectral_Transform_Method.citation)


## The equation sets:
### The simpler continuous equation set for vorticity/divergence formulation
<table class="eqn">
  <tr> <td>$$ \partial_t \zeta  $$</td> <td>$$ = -\nabla \cdot \left(\zeta + f \right)\mathbf{v} $$</td>
  </tr>
<tr>
  <td>$$ \partial_t \delta $$</td><td>$$ =  \mathbf{k} \cdot \left(\nabla \times \left(\zeta + f \right)\mathbf{v} \right) - \nabla^2 \left(\Phi + \frac{\mathbf{v} \cdot \mathbf{v}}{2} \right) $$</td>
  </tr>
<tr>
  <td> $$\partial_t \Phi $$</td> <td>$$ = -\nabla \cdot \left(\Phi\mathbf{v}\right) - \overline{\Phi}\delta$$</td>
  </tr>
</table>

note that this assumes no baseline topography for the moment, and the equations are inviscid.

### Rewriting the equations

Make the following definitions:
<table class="eqn">
  <tr>
  <td>$$ \mu $$</td><td>$$ = \sin \varphi $$</td>
  </tr>
  <tr>
  <td>$$ U $$</td><td> $$= u\cos \varphi $$</td>
  </tr>
  <tr>
  <td>$$ V $$</td><td> $$= v\cos \varphi$$</td>
  </tr>
  <tr>
    <td>$$ \eta $$ </td><td> $$ \equiv \zeta + f  = \frac{1}{a(1-\mu^2)} \partial_\lambda V - \frac{1}{a}\partial_\mu U + f$$</td>
  </tr>
  <tr>
    <td>$$ \delta $$ </td><td> $$  = \frac{1}{a(1-\mu^2)} \partial_\lambda U + \frac{1}{a}\partial_\mu V $$</td>
  </tr>
</table>

Then we get the following set of continuous equations:

<table class="eqn">
  <tr>
    <td>$$ \partial_t \eta $$</td><td>$$= -\frac{1}{a(1-\mu^2)}\partial_\lambda \left[U\eta \right] - \frac{1}{a} \partial_\mu \left[V\eta \right] $$</td>
  </tr>
  <tr>
    <td>$$ \partial_t \delta $$</td><td>$$= \frac{1}{a(1-\mu^2)}\partial_\lambda \left[V\eta \right] - \frac{1}{a} \partial_\mu \left[U\eta \right] - \nabla^2 \left(\Phi + \frac{U^2 + V^2}{2} \right) $$</td>
  </tr>
  <tr>
    <td>$$ \partial_t \Phi $$</td><td>$$= -\frac{1}{a(1-\mu^2)}\partial_\lambda \left[U\Phi \right] - \frac{1}{a} \partial_\mu \left[V\Phi \right] - \overline{\Phi} \delta $$</td>
  </tr>
</table>


### Extracting velocity components:

Use helmholz theorem to decompose:
`$$$\mathbf{v} = \mathbf{k} \times \nabla \psi + \nabla \chi.$$$`

Rearranging this and substituting the above definitions gives that 
`$$$\eta = \nabla^2 \Psi + f $$$`
and
`$$$ \delta = \nabla^2 \chi $$$`
where we finally find
`$$$ U = \frac{1}{a} \partial_\lambda \chi - \frac{(1-\mu^2)}{a} \partial_\mu \psi $$$`
and
`$$$ V = \frac{1}{a} \partial_\lambda \psi + \frac{(1-\mu^2)}{a} \partial_\mu \chi.$$$`

## Discretizing:

Any scalar quantity `$$\xi(\lambda, \varphi) $$` will be represented by
`$$$\xi(\lambda, \varphi) = \sum_{m=-M}^M \sum_{n=|m|}^N \xi_{n,m}P_{n,m}(\mu)e^{im\lambda} $$$`

