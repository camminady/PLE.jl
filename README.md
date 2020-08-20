# PLE.jl
Path-lengths estimator in Julia


With PLE it is possible to compute trajectories of particles inside an obstacle field. Particles undergo elastic collisions with the background obstacles (which have fixed positions).


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


## Performance
`PLE.jl` doesn't approximate collisions but computes them exactly. This is expensive since we need to check possible collisions with each obstacle. To avoid that, we superimpose a grid on the lattice and assign obstacles to grid cells (under consideration of the fact that some obstacles might overlap multiple cells and also considering periodicity). We then only check with the obstacles inside the current particle's cell. If there is no collision, the particle is moved to the next cell and the process is repeated. 

The numbre of cells depends on the MFP. For example, in `[0,1] x [0,1]` with `sigma=1` and `1e6` obstacles, we superimpose a grid of `354x354` cells. If we change to `sigma=10`, we end up with `1119x1119` cells. 

For `sigma=1` and `1e4` random obstacles, we can compute `1e4`trajectories of a `1e2` particle in `9.3` seconds.
Alternatively, we can also compute `1` trajectory for `1e6`particles in `11.3`seconds. For one particle, `1e6` trajectories take `7.3` seconds.

If we go down to `1e2` obstacles, we gain approximately a factor of `10` in speed. 

