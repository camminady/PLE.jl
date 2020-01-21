export  Obstacles, 
        Particle, 
        Event,
        Metadata

mutable struct Obstacles # We will use this as a struct of arrays
    x::Array{Float64,1}
    y::Array{Float64,1}
    r::Array{Float64,1}
    n::Int64
end

mutable struct Metadata
    nx::Int64
    ny::Int64
    edgesx::Array{Float64,1}
    edgesy::Array{Float64,1}
end

mutable struct Particle
    x::Float64
    y::Float64
    r::Float64
    vx::Float64
    vy::Float64
end

mutable struct Event
    oldx::Float64
    oldy::Float64
    oldvx::Float64
    oldvy::Float64
    oldi::Int64
    oldj::Int64
    newx::Float64
    newy::Float64
    newvx::Float64
    newvy::Float64
    newi::Int64
    newj::Int64
    distance::Float64
    collision::Bool
    crossinterfaceperiodic::Bool
end