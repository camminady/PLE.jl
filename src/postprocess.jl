export postprocess
function postprocess(Events)
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
    pathlengths = sort(pathlengths)
    
    
    npl = length(pathlengths)
    
    fig, ax = plt.subplots(1,1,figsize=(10,10))
    
    logpathlengths = log10.(pathlengths)
    
    h = fit(Histogram, pathlengths, nbins = 20)
    
    centers = (h.edges[1][1:end-1] .+ h.edges[1][2:end])/2 
    weights = h.weights
    weights = weights/sum(weights)/(centers[2]-centers[1])
    ax.plot(centers,weights,lw = 3,"-o")
    ax.set_xlim([0,1.05*maximum(pathlengths)])
    plt.yscale("log")
    
    d = fit(Exponential, pathlengths)
    ax.plot(centers,pdf.(d,centers),lw=2,"--")
    
    
    m(t, p) = p[1] .* t.^p[2] 
    p0 = [0.5, 0.5]
    lsqfit = curve_fit(m, centers, weights, p0)
    m(t) = lsqfit.param[1].*t.^lsqfit.param[2]
    ax.plot(centers,m.(centers),lw=2,"--")
    ax.set_title("Pathlengths distribution for n=$npl samples.")
    ax.set_xlabel("Distance s")
    ax.set_ylabel("Rel. frequency")
    theta = params(d)[1]
    lambda = round(1.0/theta,digits = 3)
    sigma = round(lsqfit.param[1],digits = 3)
    alpha = round(lsqfit.param[2],digits = 3)
    ax.legend(["Data","Best fit, \$ \\lambda \\cdot \\exp( -\\lambda s)\$, \$\\lambda=\$ $lambda",
            "Best fit, \$ \\sigma \\cdot s^\\alpha \$, \$\\sigma=\$ $sigma, \$\\alpha=\$ $alpha"])
    plt.tight_layout()
    #plt.savefig("Histogram.png",dpi=200)
    
    return pathlengths
end