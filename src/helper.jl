
function findindex(x,X)
    # For an array X of increasing values,
    # we find i, sucht that X[i]<=x<X[i+1].
    for i=1:length(X)-1
        if X[i]<= x < X[i+1]
            return i
        end
    end
    error(x," is not between ",X[1]," and ",X[end],".")
    return NaN 
end

function mmod(a,b) # Stupid arrays starting at 1....
    return mod(a-1,b)+1
end

function a2sa(a) # takes an array, returns a static array
    if length(a)==0
        return SVector{0,typeof(Float64)}(a)
    else
        return SVector{length(a),typeof(a[1])}(a)
    end
end



function getperiodic(newx,newy,i,j,ishift,jshift,edgesx,edgesy) 

    isperiodic = false
    nx = length(edgesx)-1
    ny = length(edgesy)-1
    i += ishift
    j += jshift
    if i<1
        i = nx
        newx = edgesx[end]
        isperiodic = true
    elseif  i>nx
        i = 1
        newx = edgesx[1]
        isperiodic = true
    end
    
    if j<1
        j = ny
        newy = edgesy[end]
        isperiodic = true
    elseif  j>ny
        j = 1
        newy = edgesy[1]
        isperiodic = true
    end
    return isperiodic,newx,newy, i,j
end
