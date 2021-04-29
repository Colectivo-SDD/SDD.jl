
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

using Reexport

@reexport using SDDCore, SDDGraphics
#@reexport import 


include("orbits.jl")
include("trappedpoints.jl")
include("mandelbrots.jl")
include("preimages.jl")

export
    drawpointorbitR2,
    drawpointorbitC,
    drawpointssetorbitR2,
    drawpointssetorbitC,
    drawtrappedpointsR2,
    drawtrappedpointsC,
    drawmandelbrotR2,
    drawmandelbrotC,
    drawpreimageR2,
    drawpreimageC

end # module
