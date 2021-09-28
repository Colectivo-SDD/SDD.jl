
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

using Base: iterate_continued
using Reexport

@reexport using SDDCore, SDDGeometry, SDDGraphics
#@reexport import


include("graphicalanalysis.jl")
include("orbits.jl")
include("bifurcations.jl")
include("trappedpoints.jl")
include("mandelbrots.jl")
include("preimages.jl")
include("basins.jl")
include("SUmanifolds.jl")

export
    plot,
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

end # module
