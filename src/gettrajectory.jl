
function gettrajectory(ncollisions,x0,y0,vx0,vy0,particlerad,Collection,edgesx,edgesy,fullhistory)
    # Tracks the trajectory of a particle at 
    # (x0,y0) with initial (unit speed) velocity (vx,vy)
    # through its next ncollisions collisions.
    
    # Find initial cell of the particle
    i,j  = findindex(x0,edgesx), findindex(y0,edgesy)
    
    # Make sure the particle is not already inside an obstacle
    dists =  sqrt.((x0.-Collection[i,j].x).^2 .+(y0.-Collection[i,j].y).^2) .- Collection[i,j].r
    if minimum(dists) < 0.0  error("A particle is placed inside an obstacle") end

    
    nx,ny = length(edgesx)-1, length(edgesy)-1
    lx,ly  = edgesx[end]-edgesx[1], edgesy[end]-edgesy[1]
    collisioncount = 0
    Events = []
   
    while collisioncount < ncollisions
        iscollided, attemptcount = false, 0
        while !iscollided
            # Check if the particle collides in the current cell
            iscollided,distanceincell,newx,newy,newvx,newvy = checkallcollision(
                [x0,y0],[vx0,vy0],particlerad, Collection[i,j])
            if iscollided                
                collisioncount += 1
            else # no collision took plac 
                # Find out where the particle will now move
                ishift, jshift,distanceincell,newx,newy,newvx,newvy =traverse(
                        x0,y0,vx0,vy0,edgesx[i],edgesx[i+1],edgesy[j],edgesy[j+1])
                attemptcount += 1
            end
            
            # Store an event. If a particle "makes use of periodicity", create two events
            # First event without checking for periodicity
            if fullhistory
                e = Event(x0,y0,vx0,vy0,i,j,newx,newy,newvx,newvy,i,j,distanceincell,iscollided,false)
                push!(Events,e)
            end
            x0,y0,vx0,vy0 = newx,newy,newvx,newvy
            # Second event: check for periodicity, this is only possible in the absence of a collision
            if !iscollided
               isperiodic,newx,newy, newi,newj = getperiodic(newx,newy,i,j,ishift,jshift,edgesx,edgesy) 
                if isperiodic
                    if fullhistory
                        e = Event(x0,y0,vx0,vy0,i,j,newx,newy,newvx,newvy,newi,newj,0.0,false,true) 
                        push!(Events,e)
                    end
                end
                x0,y0,vx0,vy0,i,j = newx,newy,newvx,newvy,newi,newj
            end
        end 
    end
    return Events
end