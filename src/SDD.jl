
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

using Base: iterate_continued
using Reexport

@reexport using SDDCore, SDDGeometry, StaticArrays, IntervalSets,
  Colors, ColorSchemes
using Images, Makie, InteractiveViz
#@reexport import
# SDDGraphics # Deprecated!!!

include("plotrealgraphs.jl")

export
    plotgraph,
    plotgraph!,
    iplotgraph,
    iplotgraph!,
    plottangent,
    plottangent!,
    plotorbitga,
    plotorbitga!,
    plotorbitarcpath,
    plotorbitarcpath!,
    plottimeseries,
    plottimeseries!,
    plottimeseriesdiff,
    plottimeseriesdiff!


include("bifurcations.jl")

export
    imgaobifdiagram,
    imgaobifdiagram!,
    plotimgaobifdiagram,
    plotimgaobifdiagram!,
    plotaobifdiagram,
    plotaobifdiagram!,
    iplotaobifdiagram,
    iplotaobifdiagram!,
    plotscatteraobifdiagram,
    plotscatteraobifdiagram!,
    iplotscatteraobifdiagram,
    iplotscatteraobifdiagram!
    #plotbifdiagram,
    #plotbifdiagram!


#include("orbits2d.jl")
#export
    #plotorbit,
    #plotorbit!


#include("trappedpoints.jl")
#include("mandelbrots.jl")
#include("preimages.jl")
#include("basins.jl")
#include("SUmanifolds.jl")


#include("basic3d.jl")    
#export
    #plotmodulusgraph,
    #plotmodulusgraph!
    #plotargumentgraph,
    #plotargumentgraph!
    #plottimeseries3d,
    #plottimeseries3d!,
    #plottimeseriesdiff3d,
    #plottimeseriesdiff3d!,


#include("orbits3d.jl")
#export
    #plotorbit3d,
    #plotorbit3d!


#include("bifurcations3d.jl")
#export
#    plotorbitsdiagram3d,
#    plotorbitsdiagram3d!,
#    plotbifurcationdiagram3d,
#    plotbifurcationdiagram3d!,
#    plotmodulusdiagram3d,
#    plotmodulusdiagram3d!,



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
