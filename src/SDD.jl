
"""
Drawings and calculations useful for research in Function Iteration Theory,
or Discrete Dynamical Systems.
"""
module SDD

using SDDCore
import SDDGraphics

include("orbits.jl")
include("trappedpoints.jl")
include("mandelbrots.jl")

export
    drawpointorbitR2,
    drawpointorbitC,
    drawpointssetorbitR2,
    drawpointssetorbitC,
    drawtrappedpointsR2,
    drawtrappedpointsC,
    drawmandelbrotR2,
    drawmandelbrotC

end # module
