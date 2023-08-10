
#
# Plot (nth-Iterate) Func(tion) Graph
#

"""
    funcgraph(f, xs [; iterations])

Plot the graph of the n-th iterate of a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate \$f^n\$.
"""
@recipe(FuncGraph) do scene
  Attributes(
    iterations = 1
  )
end

function Makie.plot!(plt::FuncGraph{<:Tuple{Function, Any}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_fn = Observable(iteratef(f, plt.iterations[]))

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  
  # Plot the nth-iterate of f
  lines!(plt, plt[2], obs_fn; plt.attributes.attributes...)

  plt
end

"""
    ifuncgraph([g], f, xs [; iterations])

The same as `funcgraph`, but adapted to the **InteractiveViz** pipeline for interactive data sampling.
"""
function xfuncgraph(pltf::Function, f::Function, xs, g=nothing; iterations=1, kwargs...)
  xmin, xmax = xs isa AbstractInterval ? (xs.left, xs.right) : (xs[1], xs[end])
  fn = iteratef(f, iterations)
  #vizf = isnothing(g) ? (x, y) -> pltf(x, y; kwargs...) : (x, y) -> pltf(g, x, y; kwargs...)
  #InteractiveViz.iviz( vizf, InteractiveViz.Function1D(iteratef(f, iterations), xmin, xmax))
  isnothing(g) ? pltf(fn, xmin, xmax; kwargs...) : pltf(g, fn, xmin, xmax; kwargs...)
end

ifuncgraph(f::Function, xs; iterations=1, kwargs...) =
  xfuncgraph(ilines, f, xs; iterations=iterations, kwargs...)
ifuncgraph(g, f::Function, xs; iterations=1, kwargs...) =
  xfuncgraph(ilines, f, xs, g; iterations=iterations, kwargs...)
ifuncgraph!(f::Function, xs; iterations=1, kwargs...) =
  xfuncgraph(ilines!, f, xs; iterations=iterations, kwargs...)
ifuncgraph!(g, f::Function, xs; iterations=1, kwargs...) =
  xfuncgraph(ilines!, f, xs, g; iterations=iterations, kwargs...)


#
# Plot a Func(tion) Tangent (Line)
#

"""
    functangent(f, x0, xs [; iterations])

Plot the tangent line to the graph of the \$n\$-th iteration of a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$, at the point \$(x_0, f(x_0))\$

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Real`: Base value.
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate the iterative \$f^n\$.
"""
@recipe(FuncTangent) do scene
  Attributes(
    iterations = 1
  )
end

function Makie.plot!(plt::FuncTangent{<:Tuple{Function, Real, Any}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_x0 = plt[2] 
  x0 = obs_x0[]
  obs_xs = plt[3] 
  xs = obs_xs[]

  # Plot keyword arguments
  nits = plt.iterations[]

  # Calculate tangent of f^n
  fn = iteratef(obs_f[], nits)
  xmin, xmax = xs isa AbstractInterval ? (xs.left, xs.right) : (xs[1], xs[end])
  y0 = fn(x0)
  delta = 0.00001
  m = (fn(x0+delta) - fn(x0-delta))/(2delta)
  ys = [ y0 + m*(xmin - x0), y0, y0 + m*(xmax - x0) ]

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)

  # Plot tangent
  scatterlines!(plt, Observable([xmin, x0, xmax]), Observable(ys);
      plt.attributes.attributes...)

  plt
end


#
# Plot Orbit G(raphical) A(nalysis)
#

"""
    orbitga(f, x0 [; iterations, hidediterations, coloring])

Plot the **G**raphical **A**nalysis of the orbit of \$x_0\$ (or \$[x_0,x_1]\$) under a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Union{Real, AbstractVector{Real}}`: Initial value(s).

#### Keyword Arguments
- `iterations::Int=20`: Number of iterations in the orbit to be drawn.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `coloring::Symbol=:time`:
  - `:orbit`: Different colors for each orbit.
  - `:time`: Different colors for each time.
  - `:unique`: Unique color.
"""
@recipe(OrbitGA) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time,
    colormap = :viridis
  )
end

function Makie.plot!(plt::OrbitGA{ <:Tuple{ Function, Any } })

  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification
  obs_x0 = plt[2]
  x0 = obs_x0[]
  x0s = Float64[]
  if x0 isa Real
    push!(x0s, x0)
  else
    x0s = x0 isa AbstractInterval ? [x0.left, x0.right] : collect(x0)
  end
  nvals = length(x0s) # Number of inital values

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  clrn = plt.coloring[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for k in 1:nvals
      for n in 1:nhits
        x0s[k] = f(x0s[k])
      end
    end
  end

  # Initial observable arrays for interaction
  obs_xns = [ Observable( Float64[] ) for k in 1:nvals ]
  obs_yns = [ Observable( Float64[] ) for k in 1:nvals ]

  for k in 1:nvals
    push!(obs_xns[k][], x0s[k] )
    push!(obs_yns[k][], 0.0 )
  end

  # Iterations, to be drawn
  for k in 1:nvals
    kxs = obs_xns[k][]
    kys = obs_yns[k][]
    for n in 1:nits
      x = kxs[end]
      push!(kxs, x)
      y = f(x)
      push!(kys, y)
      push!(kxs, y)
      push!(kys, y)
    end
  end

  # Coloring
  funcolor = k::Int -> RGBA(0,0,0) # Default
  if haskey(plt, :color)
    funcolor = k::Int -> plt.color[] # Unique
  end
  if clrn == :orbit
    if nvals > 1
      cm = plt.colormap[] isa Symbol ? colorschemes[plt.colormap[]] : ColorScheme(plt.colormap[])
      cmarr = [ cm[k/(nvals-1)] for k in 0:(nvals-1) ]
      funcolor = k::Int -> cmarr[k]
    end
  elseif clrn == :time
    funcolor = k::Int -> 1:(2nits+1)
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :coloring)

  # Drawing the iterations
  for k in 1:nvals
    lines!(plt, obs_xns[k], obs_yns[k];
      plt.attributes.attributes..., color = funcolor(k))
  end  

  plt 
end


#
# Plot Orbit Arc Path
#

"""
    orbitarcpath(f, x0 [; iterations, hidediterations, coloring])

Plot the graph of the \$n\$-th iterative of a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Union{Real, AbstractVector{Real}}`: Initial value(s).

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate the iterative \$f^n\$.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `coloring::Symbol=:time`:
  - `:orbit`: Different colors for each orbit.
  - `:time`: Different colors for each time.
  - `:unique`: Unique color.
"""
@recipe(OrbitArcPath) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time,
    colormap = :viridis
  )
end

function Makie.plot!(plt::OrbitArcPath{<:Tuple{ Function, Any } } )

  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  @assert typeof(f(1.)) <: Real # Function verification
  obs_x0 = plt[2]
  x0 = obs_x0[]
  x0s = Float64[]
  if x0 isa Real
    push!(x0s, x0)
  else
    x0s = x0 isa AbstractInterval ? [x0.left, x0.right] : collect(x0)
  end
  nvals = length(x0s) # Number of inital values

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  clrn = plt.coloring[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for k in 1:nvals
      for n in 1:nhits
        x0s[k] = f(x0s[k])
      end
    end
  end

  # Coloring
  funcolor = (k::Int, n::Int) -> RGBA(0,0,0) # Default
  if haskey(plt, :color)
    funcolor = (k::Int, n::Int) -> plt.color[] # Unique
  end
  cm = plt.colormap[] isa Symbol ? colorschemes[plt.colormap[]] : ColorScheme(plt.colormap[])
  if clrn == :orbit
    if nvals > 1
      cmarr = [ cm[k/(nvals-1)] for k in 0:(nvals-1) ]
      funcolor = (k::Int, n::Int) -> cmarr[k]
    else
      c0 = cm[0.0]
      funcolor = (k::Int, n::Int) -> c0
    end
  elseif clrn == :time
    cmarr = [ cm[n/(nits-1)] for n in 0:(nits-1) ]
    funcolor = (k::Int, n::Int) -> cmarr[n]
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :coloring)

  # Drawing the iterations
  k = 1
  for x0 in x0s
    x = x0
    for n in 1:nits
      y = f(x)
      c = (x+y)/2
      r = abs(c-x)

      arc!(plt, Point2f(c,0), r, 0, x < y ? pi : -pi;
        plt.attributes.attributes..., color = funcolor(k,n))
      
      x = y
    end
    k += 1
  end

  plt
end


#=
"""
    plot(f [; iterations, identity])

Plot the graph of the \$n\$-th iterative of a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `iterations::Int`: Number of iterations to calculate the iterative \$f^n\$.
- `identity::Bool`: Draw the identity graph if true.
"""
function plot(f::Function; iterations::Int=1, identity::Bool=true)
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @assert typeof(f(1.)) <: Real

    SDDGraphics.newdrawing()

    x1, x2 = SDDGraphics.xlims()
    w = SDDGraphics.width()
    Δx = (x2-x1)/w

    # Plot the graph of the identity
    if identity
        clr = SDDGraphics.color()
        SDDGraphics.color(RGB(0.5,0.5,0.5))
        y1, y2 = SDDGraphics.ylims()
        xmin = min(x1,y1)
        xmax = max(x2,y2)
        SDDGraphics.drawlinesegment(xmin,xmin,xmax,xmax)
        SDDGraphics.color(clr) # Restate the "current" color
    end

    xi0 = x1
    yi0 = xi0
    for n in 1:iterations
        yi0 = f(yi0)
    end

    for i in 1:w
        xi1 = x1 + i*Δx
        yi1 = xi1
        for n in 1:iterations
            yi1 = f(yi1)
        end
        SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
        xi0, yi0 = xi1, yi1
    end

#= ToDo: Con compose queda así :-)
fn = compose(f,iteraions)

xi0, yi0 = x1, fn(x1)
for i in 0:w
    xi1 = x1 + i*Δx
    yi1 = fn(xi1)
    SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
    xi0, yi0 = xi1, yi1
end
=#
    SDDGraphics.drawing()
end

"""
    graphicalanalysis(f, x0 [; iterations])

Plot the graph of a function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$ and
the the graphical analysis of the orbit of \$x_0\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Real`: Initial point for the orbit.
- `iterations::Int`: Number of iterations to calculate the orbit of \$x_0\$.
- `identity::Bool`: Draw the identity graph if true.
"""
function graphicalanalysis(f::Function, x0::Real;
    iterations::Int=10, identity=true, basepoint=true)
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @assert typeof(f(1.)) <: Real

    SDDGraphics.newdrawing()

    x1, x2 = SDDGraphics.xlims()
    y1, y2 = SDDGraphics.ylims()
    w = SDDGraphics.width()
    Δx = (x2-x1)/w

    # Plot of the function's graph
    clr = SDDGraphics.color()
    xi0 = x1
    yi0 = f(x1)
    for i in 1:w
        xi1 = x1 + i*Δx
        yi1 = f(xi1)
        SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
        xi0, yi0 = xi1, yi1
    end

    # Plot the graph of the identity
    if identity
        SDDGraphics.color(RGB(0.5,0.5,0.5))
        xi0 = min(x1,y1)
        xi1 = max(x2,y2)
        SDDGraphics.drawlinesegment(xi0,xi0,xi1,xi1)
    end

    # Graphical analysis of the orbit of x0
    SDDGraphics.color(RGB(1,0,0))

    if basepoint
        SDDGraphics.drawlinesegment(x0,0,x0,x0)
    end

    xi0 = x0
    for i in 1:iterations
        yi0 = f(xi0)
        SDDGraphics.drawlinesegment(xi0,xi0,xi0,yi0)
        SDDGraphics.drawlinesegment(xi0,yi0,yi0,yi0)
        xi0 = yi0
    end

    SDDGraphics.color(clr) # Restate the "current" color

    SDDGraphics.drawing()
end

=#