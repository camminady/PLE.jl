export visualizeevents

function visualizeevents(Collection,Meta,Events)
    pygui(true)
    close("all")
    set_context("poster")
    set_context("poster")
    
    nx,ny,x0,x1,y0,y1 = Meta.nx, Meta.ny, Meta.edgesx[1], Meta.edgesx[end], Meta.edgesy[1], Meta.edgesy[end]
    fig, ax = plt.subplots(1,1,figsize=(10,10))
    cols = plt.cm.tab10(range(0,stop=1,length=nx*ny))
    cols[:,end] .= 0.3 # alpha
    edgesx = range(x0,stop=x1,length=nx+1)
    edgesy = range(y0,stop=y1,length=ny+1)
    for i=1:nx
        for j=1:ny
            ax.axvline(edgesx[i],y0,y1,color="grey",lw=0.2,linestyle="--")
            ax.axhline(edgesy[j],x0,x1,color="grey",lw=0.2,linestyle="--")
            for n=1:Collection[i,j].n
                x,y,r = Collection[i,j].x[n], Collection[i,j].y[n], Collection[i,j].r[n]
                ax.add_artist(plt.Circle((x,y), r,color=cols[j+(i-1)*ny,:]))
                xx = round(x,digits=2)
                yy = round(y,digits=2)
                #ax.text(x,y,"($i,$j,$n)",horizontalalignment="center")
            end
        end
    end

    ax.axvline(edgesx[nx+1],y0,y1,color="grey",lw=1,linestyle="--")
    ax.axhline(edgesy[ny+1],x0,x1,color="grey",lw=1,linestyle="--")
    ax.set_xlim([x0-2*Collection[1,1].r[1],x1+2*Collection[1,1].r[1]])
    ax.set_ylim([y0-2*Collection[1,1].r[1],y1+2*Collection[1,1].r[1]])
   
    #cols = plt.cm.Blues(range(0.2,stop=1,length=length(Events)))
    for i=1:length(Events)
        e = Events[i]
        if !e.crossinterfaceperiodic
            col = ifelse(e.collision,"red","blue")
            #col = cols[i,:]
            col = "darkblue"
            col = ifelse(i==1,"green",col)
            ax.plot([e.oldx,e.newx],[e.oldy,e.newy],color=col,lw = 1,alpha=1)
        end
    end
    fig.tight_layout()
    ax.set_aspect("equal")
    ax.set_xlim([x0,x1])
    ax.set_ylim([y0,y1])
    ax.set_xticks(edgesx)
    ax.set_yticks(edgesy)
    return fig, ax 
end


