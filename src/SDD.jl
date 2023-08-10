
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

#using Base: iterate_continued
using Reexport

@reexport using StaticArrays, IntervalSets,
  Colors, ColorSchemes
using SDDCore, SDDGeometry, SDDGraphics, Images, Makie, InteractiveViz
#@reexport import


include("plotrealgraphs.jl")

export
    funcgraph,
    funcgraph!,
    ifuncgraph,
    ifuncgraph!,
    functangent,
    functangent!,
    orbitga,
    orbitga!,
    orbitarcpath,
    orbitarcpath!


include("timeseries.jl")

export
    functimeseries,
    functimeseries!,
    functimeseriesdiff,
    functimeseriesdiff!
    functimeseries3d,
    functimeseries3d!,
    functimeseriesdiff3d,
    functimeseriesdiff3d!


include("bifurcations.jl")

export
    imgattrbifdiagram,
    attrbifdiagram,
    attrbifdiagram!,
    #iattrbifdiagram, 
    #iattrbifdiagram!,
    scatterattrbifdiagram,
    scatterattrbifdiagram!,
    iscatterattrbifdiagram,
    iscatterattrbifdiagram!
    #bifdiagram,
    #bifdiagram!


include("orbits.jl")

export
    orbitpath,
    orbitpath!
    #orbitarcpath, #?
    #orbitarcpath! #?
    #orbitpath3d,
    #orbitpath3d!


include("trappedpoints.jl")

export
    imgtrappedpoints,
    trappedpoints,
    trappedpoints!,
    itrappedpoints,
    itrappedpoints!
    #trappedpoints3d,
    #trappedpoints3d!,


#include("mandelbrots.jl")

#export
    #mandelbrot,
    #mandelbrot!,
    #imandelbrot,
    #imandelbrot!,
    #mandelbrot3d,
    #mandelbrot3d!,


#include("preimages.jl")

#export
    #preimages,
    #preimages!,
    #ipreimages,
    #ipreimages!,


#include("basins.jl")

#export
    #basins,
    #basins!,
    #ibasins,
    #ibasins!,


#include("SUmanifolds.jl")


include("plotgraphs3d.jl")

export
    funcgraph2d,
    funcgraph2d!,
    modulusgraph,
    modulusgraph!
    arggraph,
    arggraph!


#include("bifurcations3d.jl")
#export
#    attrbifdiagram3d,
#    attrbifdiagram3d!,
#    bifdiagram3d,
#    bifdiagram3d!,
#    modulusdiagram3d,
#    modulusdiagram3d!,


#=    plot,
    graphicalanalysis,
    drawpointorbitR2,
    drawpointorbitC,
    drawpointssetorbitR2,
    drawpointssetorbitC,
    drawpointorbitpathR,
    drawpointorbitpathR2,
    drawpointorbitpathC,
    draworbitsdiagram,
    drawtrappedpointsR2,
    drawtrappedpointsC,
    drawmandelbrotR2,
    drawmandelbrotC,
    drawpreimageR2,
    drawpreimageC,
    drawbasinsR2,
    drawbasinsC,
    drawbasinsR2_BAP,
    drawbasinsC_BAP,
    drawSUmanifoldsR2,
    drawSmanifoldR2,
    drawUmanifoldR2
=#

end # module
