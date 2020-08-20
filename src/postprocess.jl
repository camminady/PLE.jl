export postprocess
function postprocess(Events::Array{Event,1})
    set_context("poster")
    set_context("poster")
    close("all")
    pathlengths = zeros(0)
    distance = 0.0
    
    distancetofirst = true
    for i=1:length(Events)
        distance += Events[i].distance
        if Events[i].collision
            if distancetofirst
                distancetofirst = false # only store distances between collision
            else
                push!(pathlengths, distance)
            end
            distance = 0.0
        end
    end
    return postprocess(pathlengths)
end


function postprocess(pathlengths::Array{Float64,1},latticeflag = false)
    set_context("poster")
    set_context("poster")
    close("all")
   
    sort!(pathlengths)
    
    
    npl = length(pathlengths)
    
    fig, ax = plt.subplots(1,1,figsize=(40,20))
    
    logpathlengths = log10.(pathlengths)
    
    h = fit(Histogram, pathlengths, nbins = 200)
    
    centers = (h.edges[1][1:end-1] .+ h.edges[1][2:end])/2 
    weights = h.weights
    weights = weights/sum(weights)/(centers[2]-centers[1])
    ax.plot(centers,weights,lw = 5,"-o",color=tuple([0,150,130]/255...))
    ax.set_xlim([0,1.05*maximum(pathlengths)])
    plt.yscale("log")
    
    d = fit(Exponential, pathlengths)
	if !latticeflag
		ax.plot(centers,pdf.(d,centers),lw=5,"--",color=tuple([163,16,124]/255...))
	end
    
    m(t, p) = p[1] .* t.^(-2.0)#p[2] 
    p0 = [3.0]#, -2.0]
    lsqfit = curve_fit(m, centers, weights, p0)
	
    m(t) = lsqfit.param[1].*t.(-2.0)#^lsqfit.param[2]
    if latticeflag
		ax.plot(centers,m.(centers),lw=2,"--")
	end
	ax.set_title("Path-length distribution for n=$npl samples.", pad = 20)
    ax.set_xlabel("Distance s")
    ax.set_ylabel("Rel. frequency")
   # ax.set_ylim([1e-16,1])
    theta = params(d)[1]
    lambda = round(1.0/theta,digits = 3)
    sigma = round(lsqfit.param[1],digits = 3)
    #alpha = round(lsqfit.param[2],digits = 3)
	#if !latticeflag
#		ax.legend(["Data","Best fit, \$ \\lambda \\cdot \\exp( -\\lambda s)\$, \$\\lambda=\$ $lambda"])#
#	else
#		ax.legend(["Best fit, \$ \\sigma \\cdot s^\\alpha \$, \$\\sigma=\$ $sigma, \$\\alpha=\$ $alpha"])
#	end
    plt.tight_layout()
    plt.savefig("Histogram.png",dpi=200)
    
    return pathlengths
end
