export postprocess
function postprocess(Events)
    set_context("poster")
    set_context("poster")
    close("all")
    set_context("poster")
    set_context("poster")
    pathlengths = zeros(0)
    distance = 0.0
    for i=1:length(Events)
        distance += Events[i].distance
        if Events[i].collision
            push!(pathlengths, distance)
            distance = 0.0
        end
    end
    pathlengths = sort(pathlengths)
    npl = length(pathlengths)
    
    fig, ax = plt.subplots(1,1,figsize=(10,10))
    
    logpathlengths = log10.(pathlengths)
    
    h = fit(Histogram, pathlengths)
    
    centers = (h.edges[1][1:end-1] .+ h.edges[1][2:end])/2 
    weights = h.weights
    weights = weights/sum(weights)/(centers[2]-centers[1])
    ax.plot(centers,weights,lw = 3,"-o")
    ax.set_xlim([0,1.05*maximum(pathlengths)])
    plt.yscale("log")
    d = fit(Exponential, pathlengths)
    ax.plot(centers,pdf.(d,centers),lw=2,"--")
    ax.set_title("Pathlengths distribution for n=$npl samples.")
    ax.set_xlabel("Distance s")
    ax.set_ylabel("Frequency")
    theta = params(d)[1]
    lambda = round(1.0/theta,digits = 3)
    ax.legend(["Data","Best fit, \$ \\lambda \\exp( -\\lambda s)\$, \$\\lambda=\$ $lambda"])
    plt.tight_layout()
    #plt.savefig("Histogram.png",dpi=200)
end