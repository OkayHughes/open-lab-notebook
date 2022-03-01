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


