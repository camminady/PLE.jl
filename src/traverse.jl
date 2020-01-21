function traverse(posx::Float64,posy::Float64,velx::Float64,vely::Float64,
                    x0::Float64,x1::Float64,y0::Float64,y1::Float64)
    # Given a particle in a cell with position (posx,posy)
    # and velocity (velx,vely) where the cell is defined by
    # [x0,x1] x [y0,y1],
    # this function returns nexti, nextj = the direction of the cell 
    # that the particle will, as well as nextx,nexty = the intersection point
    # and dist = the travelled distance.
    # move into after having passed the current cell.
    # 
    # The layout is as follows:
    #
    #                     j-1            j            j+1
    #     \  y
    #      \
    #     x \
    #
    #   i+1
    #
    #                 ---------------x1---------------
    #                 |                              |
    #                 |                              |
    #     i           y0                             y1
    #                 |                              |
    #                 |                              |
    #                 ---------------x0---------------
    #
    #   i-1 
    #
    # The coordinate system is 
    #
    #  ^  x
    #  |
    #  |
    #  |
    #    --------> y
    #

    

    # assert that we are in the domain
    #eps = 1e-14
    #@assert posx>= x0-eps
    #@assert posx<= x1+eps
    #@assert posy>= y0-eps
    #@assert posy<= y1+eps

    # assert a non zero velocity
    normv = sqrt(vely^2+velx^2)
    #@assert normv>0
   
    # are we moving north east, south east, south west or north west
    vertical   = ifelse(velx>=0,+1,-1)    
    horizontal = ifelse(vely>=0,+1,-1)
    
    # which face (left right top bottom) will we hit 
    # i.e. to which y or x do we need to calculate the distance
    x = ifelse(vertical==+1,x1,x0)
    y = ifelse(horizontal==+1,y1,y0)

    # calculate distance to that point considering the velocity
    distx = abs((x-posx)/velx)
    disty = abs((y-posy)/vely)

    # check which face we hit first and save the corresponding i/j shift
    # as well as the distance travelled
    if disty<distx
        nexti = 0
        nextj = horizontal
        dist = disty
    elseif disty>distx
        nexti = vertical
        nextj = 0
        dist = distx
    else
        nexti = vertical
        nextj = horizontal
        dist = distx # == disty
    end

    # at what point to we cross the interface
    nextx = posx + dist*velx
    nexty = posy + dist*vely
    return nexti,nextj, dist*normv, nextx,nexty,velx,vely 
end
