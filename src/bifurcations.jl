
"""
Implementation of the attracting orbits bifurcation diagram for a family of real functions.
"""
function matrixattrbifdiagram(ff::Function,
    ts::AbstractVector{<:Real}, xs::AbstractVector{<:Real},
    x0::Union{Real,Nothing} = nothing;
    hidediterations::Int = 200, iterations::Int = 2000,
    rot90::Bool = false, value::Function = k::Int -> k, fillvalue=0)

  # Matrix and rectangular region
  w, h = length(ts), length(xs)
  rr = RectRegion(ts, xs)
  fv = fillvalue #convert(typeof(value(1)), fillvalue)
  mtrx = rot90 ? fill(fv, h, w) : fill(fv, w, h)
  mtrxindx = rot90 ? torot90matrixindex : tomatrixindex

  # Initial data for random orbit
  x0 = isnothing(x0) ? rand(xs) : x0 

  # The Attracting Orbits Biffuraction Diagram Algorithm
  k = 1
  for t in ts
    f(x::Real) = ff(t,x)

    xn = x0      

    # Orbit without drawing
    for n in 1:hidediterations
      xn = f(xn)
    end

    # Orbit with drawing
    for n in 1:iterations
      xn = f(xn)
      pn = [t,xn]
      if isinside(pn, rr)
        mtrx[mtrxindx(pn, w, h, rr, k)...] = value(n)
      end
    end

    k += 1
  end
  
  # Return matrix
  mtrx
end


"""
    imgattrbifdiagram(ff, ts, xs, x0[; kwargs])

The same as `attrbifdiagram`.

#### Notes
- This is the "classic" bifurcation diagram.
- Using **Image**'s image.

#### Aditional Keyword Arguments
- `colormap::Union{Symbol, Vector{Colorant}} = :viridis`: Colormap.
"""
function imgattrbifdiagram(ff::Function,
  ts::AbstractVector{<:Real}, xs::AbstractVector{<:Real},
  x0::Union{Real,Nothing} = nothing;
  hidediterations::Int = 200, iterations::Int = 2000,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis,
  bgcolor::Colorant = RGBf(1,1,1))

  # Veryfying function family
  #@assert typeof(ff(.1,.1)) <: Real

  # Coloring
  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  colors = iterations > 1 ? [ cm[k/(iterations-1)] for k in 0:(iterations-1) ] : [cm[0.0]]

  # Return the image (matrix of colors)
  matrixattrbifdiagram(ff, ts, xs, x0,
    iterations = iterations, hidediterations = hidediterations,
    rot90 = true, value = k::Int -> colors[k], fillvalue = bgcolor)
end


#=
"""
    attrbifdiagram(ff, ts, xs, x0[; kwargs])

The same as `plotaobifdiagram`.

#### Notes
- This is the "classic" bifurcation diagram.
- Using **Makie**'s `image` plot.

#### Aditional Keyword Arguments
- `colormap::Union{Symbol, Vector{Colorant}} = :viridis`: Colormap.
"""
@recipe(PlotImgAOBifDiagram) do scene
  Attributes(
    iterations = 2000,
    hidediterations = 200,
    bgcolor = RGBA(1,1,1,0)
  )
end

function Makie.plot!(
  plt::PlotImgAOBifDiagram{<:Tuple{Function,
  AbstractVector{<:Real}, AbstractVector{<:Real}, Real} })

  # Recipe attributes
  ff = plt[1][]
  obs_ts = plt[2] 
  ts = obs_ts[]
  obs_xs = plt[3]
  xs = obs_xs[]
  x0 = plt[4][]

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  bgc = plt.bgcolor[]

  # Coloring
  pltcm = [RGBA(0,0,0,0.75)]
  if haskey(plt, :colormap)
    pltcm = plt.colormap[] # From Makie
  end
  cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
  colors = nits > 1 ? [ cm[k/(nits-1)] for k in 0:(nits-1) ] : [cm[0.0]]

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)

  # Plot
  image!(plt, obs_ts, obs_xs,
    matrixaobifdiagram(ff, ts, xs, x0,
      iterations = nits, hidediterations = nhits,
      value = k::Int -> colors[k], fillvalue=bgc);
    plt.attributes.attributes...)
  
  plt
end
=#

"""
    attrbifdiagram(ifs, ts, xs, x0[; kwargs])

Plot the **Attr**acting orbits **Bif**urcation **Diagram** of a family of funcions

\$\\{f_t:\\mathbb{R}\\rightarrow\\mathbb{R}\\}_\\{t\\in [a,b]\\}\$

#### Notes
- This is the "classic" bifurcation diagram.
- Using the **Makie**'s `heatmap` or `image` plot.

#### Arguments
- `ff::Function`: A family of functions \$f:[a,b]\\times\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `ts::AbstractVector{Real}`: Base \$t\$ coordinates (family parameter).
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.
- `x0::Real = nothing`: Initial value for orbits calculation. Taked randomly if is `nothing`.
    
#### Keyword Arguments
- `iterations::Int = 1000`: Iterations for drawing.
- `hidediterations::Int = 10`: Iterations without drawing.
- `bgcolor=RGB(1,1,1)`: Background color.
- `plotstyle=:image`: Type of plot, `:heatmap` or `:image`.
"""
@recipe(AttrBifDiagram) do scene
  Attributes(
    iterations = 2000,
    hidediterations = 200,
    bgcolor = RGBA(1,1,1,0),
    plotstyle = :image
  )
end

function Makie.plot!(
  plt::AttrBifDiagram{<:Tuple{Function,
  AbstractVector{<:Real}, AbstractVector{<:Real}, Any} })

  # Recipe attributes
  ff = plt[1][]
  obs_ts = plt[2] 
  ts = obs_ts[]
  obs_xs = plt[3]
  xs = obs_xs[]
  x0 = plt[4][]

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  bgc = plt.bgcolor[]
  pltsty = plt.plotstyle[]

  # Coloring
  pltcm = [RGBA(0,0,0,0.75)]
  if haskey(plt, :colormap)
    pltcm = plt.colormap[] # From Makie
  end
  cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
  colors = nits > 1 ? [ RGBA(cm[k/(nits-1)],1) for k in 0:(nits-1) ] : [ RGBA(cm[0.0],1) ]
  if pltsty != :image
    pushfirst!(colors, bgc)
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :bgcolor)
  delete!(plt.attributes.attributes, :plotstyle)

  # Plot
  if pltsty == :image
    image!(plt, obs_ts, obs_xs,
      matrixattrbifdiagram(ff, ts, xs, x0,
        iterations = nits, hidediterations = nhits,
        value = k::Int -> colors[k], fillvalue=bgc);
      plt.attributes.attributes...)
  else # :heatmap
    heatmap!(plt, obs_ts, obs_xs,
      matrixattrbifdiagram(ff, ts, xs, x0,
        iterations = nits, hidediterations = nhits,
        value = k::Int -> k, fillvalue=0);
      plt.attributes.attributes..., colormap=colors)
  end
  
  plt
end


#=
"""
    iplotaobifdiagram([g], f, ts, xs, x0 [; iterations, hidediterations, bgcolor, colormap])

The same as `plotaobifdiagram`, but adapted to the **InteractiveViz** pipeline for interactive data sampling.
"""
function xplotaobifdiagram(pltf::Function, ff::Function,
  ts::AbstractVector{<:Real}, xs::AbstractVector{<:Real}, x0::Real, g=nothing;
  iterations=2000, hidediterations=200, bgcolor=RGBA(1,1,1,0), colormap=:viridis,
  kwargs...)

  # Coloring
  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  colors = iterations > 1 ? [ RGBA(cm[k/(iterations-1)],1) for k in 0:(iterations-1) ] : [ RGBA(cm[0.0],1) ]
  pushfirst!(colors, bgcolor)

  # Matrix
  mtrx = matrixaobifdiagram(ff, ts, xs, x0,
    iterations = iterations, hidediterations = hidediterations,
    value = k::Int -> k, fillvalue=0.0)

  # Plot
  isnothing(g) ?
    pltf(ts, xs, mtrx; colormap=colors, kwargs...) :
    pltf(g, ts, xs, mtrx; colormap=colors, kwargs...)  
end

iplotaobifdiagram(ff::Function, ts, xs, x0; iterations=1, hidediterations=200, bgcolor=RGBA(1,1,1,0), colormap=:viridis, kwargs...) =
  xplotaobifdiagram(iheatmap, ff, ts, xs, x0; iterations=iterations, hidediterations=hidediterations, bgcolor=bgcolor, colormap=colormap, kwargs...)
iplotaobifdiagram(g, ff::Function, ts, xs, x0; iterations=1, hidediterations=200, bgcolor=RGBA(1,1,1,0), colormap=:viridis, kwargs...) =
  xplotaobifdiagram(iheatmap, ff, ts, xs, x0, g; iterations=iterations, hidediterations=hidediterations, bgcolor=bgcolor, colormap=colormap, kwargs...)
=#


"""
    scatterattrbifdiagram(ff, ts, xs, x0[; kwargs])

The same as `attrbifdiagram`.

#### Notes
- This is the "classic" bifurcation diagram.
- Using **Makie**'s `scatter` plot.
"""
@recipe(ScatterAttrBifDiagram) do scene
  Attributes(
    iterations = 2000,
    hidediterations = 200,
    markersize = 0.01
  )
end

function Makie.plot!(
  plt::ScatterAttrBifDiagram{<:Tuple{Function,
  AbstractVector{<:Real}, AbstractVector{<:Real}, Any} })

  # Recipe attributes
  ff = plt[1][]
  obs_ts = plt[2] 
  ts = obs_ts[]
  obs_xs = plt[3]
  xs = obs_xs[]
  x0 = plt[4][]

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]

  rr = RectRegion(ts, xs)

  # Initial data for random orbit
  x0 = isnothing(x0) ? rand(xs) : x0 

  # Coloring
  pltcm = [ RGBA(0,0,0,0.5) ]
  if haskey(plt, :colormap)
    pltcm = plt.colormap[] # From Makie
  end
  cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
  colors = nits > 1 ? [ cm[k/(nits-1)] for k in 0:(nits-1) ] : [cm[0.0]]

  tns = Float64[]
  xns = Float64[]

  # The Attracting Orbits Biffuraction Diagram Algorithm
  k = 1
  for t in ts
    f(x::Real) = ff(t,x)
    xn = x0

    # Orbit without drawing
    for n in 1:nhits
      xn = f(xn)
    end

    # Orbit with drawing
    for n in 1:nits
      xn = f(xn)
      if isinside([t, xn], rr)
        push!(tns, t)
        push!(xns, xn)
      end
    end

    k += 1
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)

  # Plot
  scatter!(plt, Observable(tns), Observable(xns); plt.attributes.attributes...)
  
  plt
end

"""
    iscatterattrbifdiagram([g], f, ts, xs, x0 [; iterations, hidediterations, bgcolor, colormap])

The same as `scatterattrbifdiagram`, but adapted to the **InteractiveViz** pipeline for interactive data sampling.
"""
function xscatterattrbifdiagram(pltf::Function, ff::Function, ts::AbstractVector{<:Real}, xs::AbstractVector{<:Real},
  x0::Real, g=nothing; iterations=2000, hidediterations=200, markersize=0.01, kwargs...)

  rr = RectRegion(ts, xs)

  tns = Float64[]
  xns = Float64[]

  # The Attracting Orbits Biffuraction Diagram Algorithm
  k = 1
  for t in ts
    f(x::Real) = ff(t,x)
    xn = x0

    # Orbit without drawing
    for n in 1:hidediterations
      xn = f(xn)
    end

    # Orbit with drawing
    for n in 1:iterations
      xn = f(xn)
      if isinside([t, xn], rr)
        push!(tns, t)
        push!(xns, xn)
      end
    end

    k += 1
  end

  # Plot
  isnothing(g) ?
    pltf(tns, xns; markersize=markersize, kwargs...) :
    pltf(g, tns, xns; markersize=markersize, kwargs...)
end

iscatterattrbifdiagram(ff::Function, ts, xs, x0; iterations=2000, hidediterations=200, markersize=0.01, kwargs...) =
  xscatterattrbifdiagram(iscatter, ff, ts, xs, x0; iterations=iterations, hidediterations=hidediterations, markersize=0.01, kwargs...)
iscatterattrbifdiagram(g, ff::Function, ts, xs, x0; iterations=2000, hidediterations=200, markersize=0.01, kwargs...) =
  xscatterattrbifdiagram(iscatter, ff, ts, xs, x0, g; iterations=iterations, hidediterations=hidediterations, markersize=0.01, kwargs...)
iscatterattrbifdiagram!(ff::Function, ts, xs, x0; iterations=2000, hidediterations=200, markersize=0.01, kwargs...) =
  xscatterattrbifdiagram(iscatter!, ff, ts, xs, x0; iterations=iterations, hidediterations=hidediterations, markersize=0.01, kwargs...)
iscatterattrbifdiagram!(g, ff::Function, ts, xs, x0; iterations=2000, hidediterations=200, markersize=0.01, kwargs...) =
  xscatterattrbifdiagram(iscatter!, ff, ts, xs, x0, g; iterations=iterations, hidediterations=hidediterations, markersize=0.01, kwargs...)

#=
"""
"""
function draworbitsdiagram(f::Function, x0::Real=Inf; preiterations::Int=500, iterations::Int=500)
  # Veryfying functions
  @assert typeof(f(.1,.1)) <: Real

  SDDGraphics.newdrawing()

  #SDDGraphics.updatecolorarray(iterations)

  if isinf(x0)
    x0 = (SDDGraphics.ymax() - SDDGraphics.ymin())/2
  end

  λmin = SDDGraphics.xmin()
  λmax = SDDGraphics.xmax()

  if SDDGraphics.backend() == :luxor ## || other vectorial
    Δλ = (λmax - λmin)/SDDGraphics.width()

    for λ in λmin:Δλ:λmax
      xn = x0
      for n in 1:preiterations
          xn = f(λ,xn)
      end # for n preiterations
      #SDDGraphics.color(escapetime)
      for n in 1:iterations
        xn = f(λ,xn)
        if SDDGraphics.insiderectregion(λ,xn)
          SDDGraphics.drawpoint(λ,xn)
        end
      end # for n iterations
    end # for λ

  elseif SDDGraphics.backend() == :images

    for w in 1:SDDGraphics.width()
      λ = λmin + w*(λmax - λmin)/SDDGraphics.width()
      xn = x0
      for n in 1:preiterations
          xn = f(λ,xn)
      end # for n preiterations
      #SDDGraphics.color(escapetime)
      for n in 1:iterations
        xn = f(λ,xn)
        if xn > SDDGraphics.ymin() && xn < SDDGraphics.ymax()
          h = Integer(ceil(SDDGraphics.height() + SDDGraphics.height()*(SDDGraphics.ymin()-xn)/(SDDGraphics.ymax()-SDDGraphics.ymin())))
          #if h > 0 && h <= SDDGraphics.height()
          SDDGraphics.drawpixel(w,h)
        end
      end # for n iterations
    end # for w

  end # if :luxor elseif :images

  SDDGraphics.drawing()
end


"""
"""
#function drawbifurcationsdiagram
=#