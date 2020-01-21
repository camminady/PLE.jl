module PLE

using Revise
using PyPlot
using StaticArrays
using LinearAlgebra
using StatsBase
using Distributions
using Seaborn 
using LsqFit

include("MyStructs.jl")
include("helper.jl")
include("traverse.jl")
include("checkcollision.jl")
include("assignobstacles.jl")
include("gettrajectory.jl")
include("visualize.jl")
include("getparticle.jl")
include("postprocess.jl")

set_context("poster")
set_context("poster")

end
