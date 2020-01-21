# PLE
Path-lengths estimator in Julia


With PLE it is possible to compute trajectories of particles inside an obstacle field. Particles undergo elastic collisions with the background obstacles (which have fixec positions).


## Simple example

We create a field of randomly distributed obstacles via:
```julia
n,sigma = 1000, 2.0
Collection, Meta = assign(n, sigma)
```

This gives `n` obstacles with radii `r` such that `2*r*n=sigma`.
To avoid having to check collisions of a particle with every obstacle, we subdivide the domain and `Collection` is a matrix of size `nx*ny` with each entry being an obstacle struct of arrays, storing the obstacle positions and radii.


We now start the simulation with a random particle and trace it through the domain via:
```julia
P = getparticle(Collection, Meta)
ncollisions = 20000
Events = gettrajectory(Collection,Meta,P,ncollisions,true);
```

Afterwards we can compute some statistics via:
```julia
postprocess(Events);
```
which yields:
![Histogram with best fits of path-lengths.](/figures/Distribution.png?raw=true "Path-lengths distribution")


For a smaller number of obstacles, here is a picture of the trajectories and the obstacles:
![Particle traveling through obstacle field.](/figures/Lattice.png?raw=true "Lattice with trajectories")
And a zoomed version:
![Particle traveling through obstacle field, zoomed.](/figures/Lattice_zoom.png?raw=true "Zoomed lattice with trajectories")


