===---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Meshing
layout: layouts/post.njk
---

If hexahedral meshes could be used in our solver, the use of GLL basis elements would yield automatically mass-lumped finite element formulations
of our equations. While this is not strictly a requirement, I'm fairly sure it would improve parallel throughput if we go to GPU parallelism.
It significantly simplifies the sparsity structure of the global matrices and the assembly/stiffness summation procedure.

# Spatial twist continuum
A valid hexahedral mesh can be characterized using the
[Spatial Twist Continuum (STC)](https://www.sciencedirect.com/science/article/abs/pii/S0168874X97819567).
To each edge in the primal mesh, a dual 2-cell is associated. It is formed by connecting the centroids of the cells on this edge.
On each primal quadrilateral `$$q$$` which contains the edge `$$e_1$$`, there is another edge `$$e_2$$` which is "opposite" in the sense that it shares no vertices with `$$e_1$$`. 
As each face is associated to a dual edge, we see that both of the 2-cells dual to `$$e_1,e_2$$` contain the centroids of the hexahedra which are joined at `$$q$$`.
Continuing in this way, we can build so-called "twist sheets" throughout the mesh.
If you play around with some candidate meshes, you will see that hexahedral elements arise as the intersection between three orthogonal twist sheets. 
On the boundary of a mesh, edges are associated with dual edges, and these dual edges can be connected across opposite faces of a quadrilateral. 
These are the 2d analogue of twist sheets, and are called chords. As the boundary of the mesh is closed, these chords are closed loops.
Furthermore, these twist sheets contain no boundaries on the interior of the primal mesh but can have as boundaries
any number of the closed curves on the mesh boundary.

Question: can a closed manifold such as a torus arise in the interior of a mesh? First guess: no, because this would result in degenerate
connectivity near the center of the torus, which could only be resolved with degenerate elements (e.g. a square cut along diagonals
# using KC's stuff

Several potential ideas:
  * Three fields of repulsive surfaces with orthogonality penalty. Boundaries of initial surfaces are closed loops on boundary (known _a priori_). 
  A good option for choosing (potentially geometrically bad-but-) topologically valid choices are to use the [whisker weaving algorithm](https://onlinelibrary.wiley.com/doi/abs/10.1002/%28SICI%291097-0207%2819961015%2939%3A19%3C3327%3A%3AAID-NME2%3E3.0.CO%3B2-H) 
  that was derived using the STC. This option essentially black-boxes both methods and would be absurdly fast to implement.
  * Formulate a mesh-free PDE finding three potential functions `$$V_1, V_2, V_3$$` whose level sets obey (a weak version of) the orthogonality constraints that one would expect. 
  The boundary conditions are Neumann if potentials are used, using the direction field induced by the (potentially remeshed) surface chords. 
  * Adapt the vector heat method to this problem (possibly with a background mesh). 
  * See if the striping paper is usable (probably not, as it relies on structure of complex functions). Quaternions might be usable?
  
The most mathematically amenable (to me) option is the formulation as a PDE. Admittedly this option would also be adaptable to solution on a tetrahedral mesh. A downside to this method is that it would
almost certainly result in internal levelsets that are non-spherical. That is, the continuum analogue of the torus error I mention above
occurs on a set of measure zero. Furthermore, vanishing gradients in this sort of mismatch would allow this as a valid solution to the strong form of the equations as wellThe key to all of these: How to encode topological information that holds in the continuum limit (kinda fractal in nature). Geometric information is very easy to formulate.
Start at center, branch as necessary with diffusive process. 