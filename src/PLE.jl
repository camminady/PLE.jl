module PLE
using Revise
using PyPlot
using StaticArrays
using LinearAlgebra

include("MyStructs.jl")
include("helper.jl")
include("traverse.jl")
include("checkcollision.jl")
include("assignobstacles.jl")
greet() = print("Hello World!")
export Obstacles, Particle, Event 
export gettrajectory, visualizeevents, assign 

end
