include("MyStructs.jl")
function checkallcollision(posx::Float64,posy::Float64,vx::Float64,vy::Float64,radparticle::Float64, OF::Obstacles)

    nobs  = OF.n
    iscollided = false
    distancetravelled = Inf
    poscollidex = 0.0
    poscollidey = 0.0
    newvelocityx = 0.0
    newvelocityy = 0.0
    collidedi = 0
    # check if a collision takes place with every obstacle out there
    for i=1:nobs
        ofx,ofy,ofr = OF.x[i],OF.y[i],OF.r[i]
        # if the obstacle is too far away, it does not matter
        # if the particle collides when there is a collision taking
        # place earlier on
        
        if !((ofx-posx)^2+(ofy-posy)^2>distancetravelled^2+ofr^2+radparticle^2)
            _iscollided,_distancetravelled,_poscollidex,_poscollidey,
            _newvelocityx,_newvelocityy = 
                checksinglecollision(posx,posy,vx,vy,radparticle,ofx,ofy,ofr)
            if _iscollided
                if _distancetravelled< distancetravelled
                    iscollided = true
                    distancetravelled = _distancetravelled
                    poscollidex = _poscollidex
                    poscollidey = _poscollidey
                    newvelocityx = _newvelocityx
                    newvelocityy = _newvelocityy
                    collidedi = i
                end
            end
        end
    end

    return iscollided,distancetravelled,poscollidex,poscollidey,newvelocityx,newvelocityy
end


function checksinglecollision(px::Float64,py::Float64,vx::Float64,vy::Float64,
                  radparticle::Float64, 
                obsx::Float64,obsy::Float64,
                  radobs::Float64)
   
    # Checks whether the particle at posparticle with velocity veloparticle 
    # and raidus radparticle collides
    # with the fixed obstacle at posobs with radius radobs.
    # If a collision takes place, we compute the distance to collision,
    # the position at which the collision takes place as well as the new 
    # velocity that results from specular reflection
   
        # dist(s_min) = minimal distance between 
        # posparticle+s*veloparticle and posobs
    vdotdiffpos = vx*(obsx-px) + vy*(obsy-py) 
        if vdotdiffpos<= 0#dot(veloparticle,posobs .- posparticle)<= 0
            #s_min = -dot(posparticle .- posobs,veloparticle) / 
            #dot(veloparticle,veloparticle)
            #if s_min<=radparticle+radobs 
            # return if we are "inside" the obstacle or it is behind us
            return false,0.0,0.0,0.0,0.0,0.0
        end
        s_min = vdotdiffpos / (vx^2+vy^2)
        d_min = sqrt((px+s_min*vx-obsx)^2+(py+s_min*vy-obsy)^2)
        if d_min>=radparticle+radobs # no collision taking place
            return false,0.0,0.0,0.0,0.0,0.0
        end
        if s_min<=0# no collision taking place since the obs is behind the particle
            return false,0.0,0.0,0.0,0.0,0.0
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
            return false,0.0,0.0,0.0,0.0,0.0
        end
        colx = px + distancetravelled*vx
        coly = py + distancetravelled*vy
        # new velocity: See Martin's Kinetic Theory lecture
        # only difference: particle may have finite size
        newvx,newvy = reflect(px,py,obsx,obsy,radobs,vx,vy)
        return true,distancetravelled*sqrt(vx^2+vy^2), colx,coly, newvx,newvy
  
end

function reflect(px,py,ox,oy,r,vx,vy)
    omegax = px-ox
    omegay = py-oy
    
    normomega = sqrt(omegax^2+omegay^2)
    omegax /= normomega
    omegay /= normomega
    
    dotprod = omegax*vx+omegay*vy
    return vx- 2.0*omegax*dotprod, vy-2.0*omegay*dotprod
end


function reflect(poscollide,posobs,radobs,v)
    Ω = (poscollide .- posobs)
    Ω /= norm(Ω)
    return v  .- 2.0*Ω*dot(Ω,v)
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

