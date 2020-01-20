struct Obstacles{T} # We will use this as a struct of arrays
    x::T
    y::T
    r::T
    n::Int64
end
mutable struct Particle{T}
    x::T
    y::T
    r::T
    vx::T
    vy::T
end


struct Event{T}
    oldx::T
    oldy::T
    oldvx::T
    oldvy::T
    oldi::Int64
    oldj::Int64
    newx::T
    newy::T
    newvx::T
    newvy::T
    newi::Int64
    newj::Int64
    distance::T
    collision::Bool
    crossinterfaceperiodic::Bool
end