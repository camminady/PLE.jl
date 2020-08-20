export gettrajectory

function gettrajectory(Collection,Meta,PArray,ncollisions,fullhistory)
    # Tracks the trajectory of a particle at 
    # (x0,y0) with initial (unit speed) velocity (vx,vy)
    # through its next ncollisions collisions.

    edgesx,edgesy  = Meta.edgesx, Meta.edgesy
    nx,ny = length(edgesx)-1, length(edgesy)-1
    lx,ly  = edgesx[end]-edgesx[1], edgesy[end]-edgesy[1]
	nparticles = size(PArray)[1]
	allEvents = Array{Event,1}(undef, 0)
	allPathlengths = zeros(nparticles*ncollisions)
	allCollisionsCounter = 1
	
	for particleid = 1:nparticles
		P = PArray[particleid]
		collisioncount = 0
		Events = []
		Pathlengths = zeros(ncollisions)

		x0,y0,vx0,vy0,particlerad =  P.x,P.y,P.vx,P.vy,P.r
		# Normalize velocity
		normv = norm([vx0,vy0])
		vx0,vy0 = vx0/normv,vy0/normv
		
		
		# Find initial cell of the particle
		i,j  = findindex(x0,edgesx), findindex(y0,edgesy)

		# Make sure the particle is not already inside an obstacle
		if length(Collection[i,j].x)>0
			dists =  sqrt.((x0.-Collection[i,j].x).^2 .+(y0.-Collection[i,j].y).^2) .- Collection[i,j].r
			if minimum(dists) < 0.0  error("A particle is placed inside an obstacle") end
		end

		


		while collisioncount < ncollisions
			if (collisioncount > 0 )&( mod(collisioncount+1,1000000)==0 )
				println("Collision $(1+collisioncount) of $ncollisions.")
			end
			iscollided = false
			distancesincelastreset = 0.0
			while !iscollided
				# Check if the particle collides in the current cell
				iscollided,distanceincell,newx,newy,newvx,newvy = checkallcollision(
					x0,y0,vx0,vy0,particlerad, Collection[i,j])

				# find out where the particle where to move if it did not collide
				ishift, jshift,distanceincelltrav,newxtrav,newytrav,newvxtrav,newvytrav =traverse(
							x0,y0,vx0,vy0,edgesx[i],edgesx[i+1],edgesy[j],edgesy[j+1])

				if !iscollided
					distanceincell = distanceincelltrav
					newx,newy,newvx,newvy = newxtrav,newytrav, newvxtrav, newvytrav
				else
					# Even if we collided, there is this weird case where a scatterer's center
					# is in the neighboring cell and a particle collides with that scatterer
					# but outside of its current cell 
					# This would then not actually be a collisions
					if distanceincell>distanceincelltrav # That is the case!
						iscollided = false
						distanceincell = distanceincelltrav
						newx,newy,newvx,newvy = newxtrav,newytrav, newvxtrav, newvytrav
					else
						collisioncount += 1 # A collision takes place inside the cell
					end
				end



				# Store an event. If a particle "makes use of periodicity", create two events
				# First event without checking for periodicity
				if fullhistory
					e = Event(x0,y0,vx0,vy0,i,j,newx,newy,newvx,newvy,i,j,distanceincell,iscollided,false)
					push!(Events,e)
				end
				# Always store pathlengths if this is the end
				distancesincelastreset += distanceincell


				x0,y0,vx0,vy0 = newx,newy,newvx,newvy


				# Second event: check for periodicity, this is only possible in the absence of a collision
				# actually this is not correct. it can also happy in the case of a collision with a particle
				if !iscollided
				   isperiodic,newx,newy, newi,newj = getperiodic(newx,newy,i,j,ishift,jshift,edgesx,edgesy) 
					if isperiodic
						if fullhistory
							e = Event(x0,y0,vx0,vy0,i,j,newx,newy,newvx,newvy,newi,newj,0.0,false,true) 
							#println(e)
							push!(Events,e)
						end
					end
					x0,y0,vx0,vy0,i,j = newx,newy,newvx,newvy,newi,newj
				end
			end 
			allPathlengths[allCollisionsCounter] = distancesincelastreset
			allCollisionsCounter += 1
			if (x0>edgesx[end]) | (x0<edgesx[1]) | (y0>edgesy[end]) | (y0<edgesy[1])
				error("Out of bounds problem. Log: $x0, $y0, $vx0, $vy0,  $i, $j, $iscollided")
			end
		end
		if fullhistory
			allEvents = [allEvents;Events]
		end
	end
    return allEvents, allPathlengths
end