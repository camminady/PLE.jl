include("MyStructs.jl")
using LinearAlgebra
function checkallcollision(posparticle::Array{Float64,1},
               veloparticle::Array{Float64,1},
               radparticle::Float64,
               OF::Obstacles)

    nobs  = OF.n
    iscollided = false
    distancetravelled = Inf
    poscollide = [0.0;0.0]
    newvelocity = [0.0;0.0]
    collidedi = 0
    # check if a collision takes place with every obstacle out there
    for i=1:nobs
        _iscollided,_distancetravelled,_poscollide,_newvelocity = 
        checksinglecollision(posparticle,veloparticle,radparticle,
                     [OF.x[i],OF.y[i]],OF.r[i])
        if _iscollided
            if _distancetravelled< distancetravelled
                iscollided = true
                distancetravelled = _distancetravelled
                poscollide = _poscollide
                newvelocity = _newvelocity
                collidedi = i
            end
        end
    end

    return iscollided,distancetravelled,poscollide[1],poscollide[2],newvelocity[1],newvelocity[2]
end

function checksinglecollision(posparticle::Array{Float64,1},
                  veloparticle::Array{Float64,1},
                  radparticle::Float64, 
                  posobs::Array{Float64,1},
                  radobs::Float64)
   
    # Checks whether the particle at posparticle with velocity veloparticle 
    # and raidus radparticle collides
    # with the fixed obstacle at posobs with radius radobs.
    # If a collision takes place, we compute the distance to collision,
    # the position at which the collision takes place as well as the new 
    # velocity that results from specular reflection
    dim = size(posparticle,1)
    if dim==2
        # dist(s_min) = minimal distance between 
        # posparticle+s*veloparticle and posobs
        if dot(veloparticle,posobs .- posparticle)<= 0
            #s_min = -dot(posparticle .- posobs,veloparticle) / 
            #dot(veloparticle,veloparticle)
            #if s_min<=radparticle+radobs 
            # return if we are "inside" the obstacle or it is behind us
            return false,0.0,[0.0;0.0],[0.0;0.0]
        end
        s_min = -dot(posparticle .- posobs,veloparticle) / dot(veloparticle,veloparticle)
        d_min = norm(posparticle .+ s_min*veloparticle .- posobs)
        if d_min>=radparticle+radobs # no collision taking place
            return false,0.0,[0.0;0.0],[0.0;0.0]
        end
        if s_min<=0# no collision taking place since the obs is behind the particle
            return false,0.0,[0.0;0.0],[0.0;0.0]
        end
        if d_min> radobs+radparticle
            error("something went wrong")
        end
        if s_min<=0
            error("something went wrong here")
        end
        # d_min is the minimum, 
        # but we collide earlier since radobs,radobs,radparticle>=0
        correction = sqrt((radobs+radparticle)^2 - d_min^2)
        
        distancetravelled = s_min - correction
        if distancetravelled<=0# no collision taking place since the obs is behind the particle
            return false,0.0,[0.0;0.0],[0.0;0.0]
        end
        poscollide = posparticle .+ distancetravelled*veloparticle
        # new velocity: See Martin's Kinetic Theory lecture
        # only difference: particle may have finite size
        newvelocity = reflect(poscollide,posobs,radobs,veloparticle)
        return true,distancetravelled*norm(veloparticle), poscollide, newvelocity
    elseif dim==3
        error("Not yet implemented")
    end
end

function reflect(poscollide,posobs,radobs,v)
    Ω = (poscollide .- posobs)
    Ω /= norm(Ω)
    return v  .- 2.0*Ω*dot(Ω,v)
end
