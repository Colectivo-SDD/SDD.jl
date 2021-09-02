
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

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
    drawbasinsC

end # module
