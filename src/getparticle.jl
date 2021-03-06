export getparticle,getparticles


function getparticle(Collection,Meta)
	return getparticles(Collection,Meta,1)
end

function getparticles(Collection, Meta,nparticles) 
	PArray = Array{Particle,1}(undef, nparticles)
    edgesx,edgesy  = Meta.edgesx, Meta.edgesy
    for particleid=1:nparticles
		foundparticle = false
		r = 0.0
		x,y = 0.0,0.0
		nattempt = 0
		while !foundparticle
			nattempt +=1 
			x,y = rand(2)
			i,j  = findindex(x,edgesx), findindex(y,edgesy)
			if length(Collection[i,j].x)==0
				break
			end
			foundparticle = true

			# Make sure the particle is not already inside an obstacle

			dists =  sqrt.((x.-Collection[i,j].x).^2 .+(y.-Collection[i,j].y).^2) .- Collection[i,j].r
			if minimum(dists) < 0.0  foundparticle=false; end
			if nattempt>1000 error("Did not find initial position after $nattempt attempts."); end
		end

		vx,vy = randn(2)
		normv = norm([vx,vy])
		vx /= normv
		vy /= normv
		PArray[particleid] = Particle(x,y,r,vx,vy)
	end
    return PArray
    
end