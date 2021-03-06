export assign, assignlattice




function assign(n,sigma)
    magicnumber = 8 
    K = Int64(ceil(sqrt(n*sigma/magicnumber)))
    println("We use $K x $K cells.")
    return assign(n,sigma,K,K)
end

function assignlattice(n,sigma)
    magicnumber = 8
    K = Int64(ceil(sqrt(n*sigma/magicnumber)))
    println("We use $K x $K cells.")
    return assignlattice(n,sigma,K,K)
end

function assignlattice(n,sigma,nx,ny)
    x0,x1 = 0.0,1.0
    y0,y1 = 0.0,1.0
    m = Int64(floor(sqrt(n)))
    edgesx = range(x0,stop=x1,length=m+1)
    edgesy = range(y0,stop=y1,length=m+1)
    x = zeros(m*m)
    y = zeros(m*m)
    r = ones(m*m)
    count = 1
    for i=1:m
        for j=1:m
            x[count] = edgesx[i]
            y[count] = edgesy[j]
            r[count] = 2*sigma/(m*m)
            count += 1 
        end
    end
    delta1 = edgesx[2]-edgesx[1]
    radii = r[1]
    delta2 = delta1-2*radii
    println("Lattice distance: $delta1")
    println("Boundary distance $delta2")
    println("Radii: $radii")
    return assign(x0,x1,nx,y0,y1,ny,x,y,r)
end



function assign(n,sigma,nx,ny)
    x0,x1 = 0.0,1.0
    y0,y1 = 0.0,1.0
    x = x0.+(x1-x0)*rand(n)
    y = y0.+(y1-y0)*rand(n)
    r = ones(n)*(sigma/n)/2;
    return assign(x0,x1,nx,y0,y1,ny,x,y,r)
end

function assign(x0,x1,nx,y0,y1,ny,x,y,r)
    T = typeof(x[1])
    collectionx = [zeros(T,0) for i=1:nx,j=1:ny]
    collectiony = [zeros(T,0) for i=1:nx,j=1:ny]
    collectionr = [zeros(T,0) for i=1:nx,j=1:ny]
    lx = x1-x0
    ly = y1-y0
    edgesx = range(x0,stop=x1,length=nx+1)
    edgesy = range(y0,stop=y1,length=ny+1)
    @assert length(x) == length(y) == length(r)
    no = length(x)
    for n=1:no
        i = findindex(x[n],edgesx)
        j = findindex(y[n],edgesy)
        
        # Obstacle is in this cell but we have to check the neighbors
        for nexti in [-1,0,1]
            for nextj in [-1,0,1]
                shiftedx = x[n]+nexti*r[n]
                shiftedy = y[n]+nextj*r[n]
                shiftedxperiodic = x0+mod(shiftedx-x0,lx)
                shiftedyperiodic = y0+mod(shiftedy-y0,ly)
                shiftedi = mmod(i+nexti,nx)
                shiftedj = mmod(j+nextj,ny)
                
                if (edgesx[shiftedi]<=shiftedxperiodic<edgesx[shiftedi+1]) & (edgesy[shiftedj]<=shiftedyperiodic<edgesy[shiftedj+1])
                    deltax = ifelse(shiftedx<x0,lx,ifelse(shiftedx>x1,-lx,0))
                    deltay = ifelse(shiftedy<y0,ly,ifelse(shiftedy>y1,-ly,0))
                        
                    append!(collectionx[shiftedi,shiftedj],x[n]+deltax)
                    append!(collectiony[shiftedi,shiftedj],y[n]+deltay)
                    append!(collectionr[shiftedi,shiftedj],r[n])
                end
            end
        end
    end
    
    Collection = Array{Obstacles,2}(undef,nx,ny)
    for i=1:nx
        for j=1:ny
            Collection[i,j] = Obstacles(a2sa(collectionx[i,j]),
                                        a2sa(collectiony[i,j]),
                                        a2sa(collectionr[i,j]),
                                        length(collectionx[i,j]))
        end
    end
    
    Meta = Metadata(nx,ny,edgesx,edgesy)
    
    return Collection, Meta
end
