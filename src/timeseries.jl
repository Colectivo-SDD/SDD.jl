
######
# 2D #
######

#
# Plot Func(tion) Time Series
#

"""
    functimeseries(f, x0 [; iterations, hidediterations, coloring])

Plot the time series of the orbit of \$x_0\$ (or \$[x_0,x_1]\$) under a function
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
- `plotstyle::Symbol=:scatterlines`: Plot style, `:scatterlines` or `:stem`.
"""
@recipe(FuncTimeSeries) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time,
    colormap = :viridis,
    plotstyle = :scatterlines
  )
end

function Makie.plot!(plt::FuncTimeSeries{ <:Tuple{ Function, Any} })
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
    x0s = collect(obs_x0[])
  end
  nvals = length(x0s) # Number of inital values

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  clrn = plt.coloring[]
  pltsty = plt.plotstyle[]

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
  for k in 1:nvals
    push!(obs_xns[k][], x0s[k] )
  end

  # Iterations, to be drawn
  for k in 1:nvals
    kxs = obs_xns[k][]
    for n in 1:nits
      push!(kxs, f(kxs[end]) )
    end
  end

  # Coloring
  funcolor = k::Int -> RGBA(0,0,0) # Default
  if haskey(plt, :color)
    funcolor = k::Int -> plt.color[] # Unique
  end
  if clrn == :orbit
    cm = plt.colormap[] isa Symbol ? colorschemes[plt.colormap[]] : ColorScheme(plt.colormap[])
    if nvals > 1
      cmarr = [ cm[k/(nvals-1)] for k in 0:(nvals-1) ]
      funcolor = k::Int -> cmarr[k]
    else
      c0 = cm[0.0]
      funcolor = k::Int -> c0
    end
  elseif clrn == :time
    funcolor = k::Int -> 0:nits
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :coloring)
  delete!(plt.attributes.attributes, :plotstyle)

  # Drawing the iterations
  if pltsty == :stem
    obs_tns = [ Observable( (nhits):(nhits+nits) ) ]
    if nvals > 1
      obs_tns = [ Observable( (nhits+k/nvals):(nhits+nits+k/nvals) ) for k in 0:nvals ]
    end

    for k in 1:nvals    
      stem!(plt, obs_tns[k], obs_xns[k];
        plt.attributes.attributes..., color = funcolor(k))
    end    
  else
    obs_tns = Observable( nhits:(nhits+nits) )

    for k in 1:nvals
      scatterlines!(plt, obs_tns, obs_xns[k];
        plt.attributes.attributes..., color = funcolor(k))
    end  
  end

  plt 
end


#
# Plot Func(tion) Time Series Diff(erences)
#

"""
    functimeseriesdiff(f, x0, x1 [; iterations, hidediterations, coloring])

Plot the time series of the difference of two orbits (of \$x_0\$ and \$x_0\$) under a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Real`: Initial value.
- `x1::Real`: Initial value.

#### Keyword Arguments
- `iterations::Int=20`: Number of iterations in the orbit to be drawn.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `plotstyle::Symbol=:scatterlines`: Plot style, `:scatterlines` or `:stem`.
"""
@recipe(FuncTimeSeriesDiff) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    plotstyle = :scatterline
  )
end

function Makie.plot!(plt::FuncTimeSeriesDiff{ <:Tuple{ Function, Real, Real } })

  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification
  obs_x0 = plt[2]
  x0 = obs_x0[]
  obs_x1 = plt[3]
  x1 = obs_x1[]

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  pltsty = plt.plotstyle[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for n in 1:nhits
      x0 = f(x0)
      x1 = f(x1)
    end
  end

  # Initial observable arrays for interaction
  obs_xns = Observable( Float64[] )
  obs_tns = Observable( nhits:(nhits+nits) )

  # Iterations, to be drawn
  for n in 0:nits
    push!(obs_xns[], x0 - x1 )
    x0 = f(x0)
    x1 = f(x1)
  end

  # Coloring
  clr = 0:nits
  if haskey(plt, :color)
    clr = plt.color[]
  end

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :plotstyle)

  # Drawing the iterations
  if pltsty == :stem
    stem!(plt, obs_tns, obs_xns; plt.attributes.attributes..., color = clr)
  else
    scatterlines!(plt, obs_tns, obs_xns; plt.attributes.attributes..., color = clr)
  end

  plt 
end


######
# 3D #
######
