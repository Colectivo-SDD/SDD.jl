
######
# 2D #
######

#
# Plot Func(tion) Time Series
#

"""
    functimeseries(f, x0 [; iterations, hidediterations, coloring, plotstyle])

Plot the time series of the orbit of \$x_0\$ (or a set) under a function
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
- `plotstyle::Symbol=:scatterlines`: Plot style `:scatterlines` or `:stem`.
"""
@recipe(FuncTimeSeries, f, x0) do scene
  attrs = Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time
    #colormap = :viridis,
    #plotstyle = :scatterlines
  )
  #Makie.merge(attrs, default_theme(scene, Stem))  
  Makie.merge(attrs, default_theme(scene, ScatterLines))
end

function Makie.plot!(plt::FuncTimeSeries{ <:Tuple{ Function, Any } })
  # Recipe attributes
  obs_f = plt[:f]
  #f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification
  obs_x0 = plt[:x0]

  # Observables to the final plot
  obs_tns = Observable(Float32[])
  obs_xns = Observable(Float32[])
  #obs_tns = Observable{Any}[]
  #obs_xns = Observable{Vector{Float64}}[]
  #obs_funccolor = Observable{Any}(k::Int -> RGBA(0,0,0,1))
  #obs_plotter = Observable(scatter!)

  # Update plot function
  function update_plot(f, x0, iterations, hidediterations, coloring, colormap) #, plotstyle)

    x0s = Float32[]
    if x0 isa Real
      push!(x0s, x0)
    else
      x0s = collect(x0)
    end
    nvals = length(x0s) # Number of inital values

    empty!(obs_tns[])
    empty!(obs_xns[])
    notify(obs_tns)
    notify(obs_xns)

    #if nvals > 1 && plotstyle == :stem
    #  obs_tns = [ Observable( (hidediterations+k/nvals):(hidediterations+iterations+k/nvals) ) for k in 0:nvals ]
    #else
      #obs_tns = [ Observable( hidediterations:(hidediterations+iterations) ) ]
    #end

    for k in 1:nvals
      for n in hidediterations:(hidediterations+iterations)
        push!(obs_tns[], n)
      end
      push!(obs_tns[], NaN)
    end

    # Hided iterations, not to to be drawn
    if hidediterations > 0 
      for k in 1:nvals
        for n in 1:hidediterations
          x0s[k] = f(x0s[k])
        end
      end
    end

    # Initial observable arrays for interaction
    #obs_xns = [ Observable( Float64[] ) for k in 1:nvals ]
    #for k in 1:nvals
    #  push!(obs_xns[k][], x0s[k] )
    #end

    # Iterations, to be drawn
    for k in 1:nvals
      x = x0s[k]
      push!(obs_xns[], x)
      #kxs = obs_xns[k][]
      for n in 1:iterations
        x = f(x)
        #push!(kxs, f(kxs[end]) )
        push!(obs_xns[], x)
      end
      push!(obs_xns[], NaN)
    end

    # Coloring
    cm = getcolorscheme(colormap)
    #obs_funccolor[] = k::Int -> RGBA(0,0,0,1) # Default
    if coloring == :orbit
      loc_colors = []
      if nvals > 1
        K = nvals-1
        for k in 0:K
          c = cm[k/K]
          for n in 0:(iterations+1)
            push!(loc_colors, c)
          end
        end
      else
        loc_colors = fill(cm[0.0], iterations+2)
      end
      plt.color[] = loc_colors
    elseif coloring == :time
      K = nvals-1
      N = iterations+1
      loc_colors = []
      for k in 0:K
        for n in 0:N
          push!(loc_colors, cm[n/N])
        end
      end
      plt.color[] = loc_colors
    elseif coloring == :unique
      plt.color[] = fill(cm[0.0], (iterations+2)*nvals)
    end

    # Plotstyle
    #=if plotstyle == :stem
      obs_plotter[] = stem!
    else # :scatterlines
      #obs_tns = Observable( hidediterations:(hidediterations+iterations) )
      obs_plotter[] = scatter!
    end  =#

    notify(obs_tns)
    notify(obs_xns)

  end # Function update_plot

  # connect `update_plot` so that it is called whenever arguments change
  Makie.Observables.onany(update_plot, obs_f, obs_x0, plt.iterations, plt.hidediterations,
    plt.coloring, plt.colormap) #, plt.plotstyle )

  # then call it once manually with the first argument contents so we prepopulate all observables with correct values
  update_plot(obs_f[], obs_x0[], plt.iterations[], plt.hidediterations[],
    plt.coloring[], plt.colormap[]) #, plt.plotstyle[])
    
#=
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
=#
  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :coloring)
  #delete!(plt.attributes.attributes, :plotstyle)

  # Drawing the iterations
  #=
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
  end=#
  #for k in 1:length(obs_xns)
    #obs_plotter[](plt, obs_tns[k], obs_xns[k];
    scatterlines!(plt, obs_tns, obs_xns;
      plt.attributes.attributes...)#, color = obs_funccolor[](k))
  #end  

  #plt 
end


#
# Plot Func(tion) Time Series Diff(erences)
#

"""
    functimeseriesdiff(f, x0, x1 [; iterations, hidediterations, plotstyle])

Plot the time series of the difference of two orbits (of \$x_0\$ and \$x_1\$) under a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Real`: Initial value.
- `x1::Real`: Initial value.

#### Keyword Arguments
- `iterations::Int=20`: Number of iterations in the orbit to be drawn.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `plotstyle::Symbol=:scatterlines`: Plot style `:scatterlines` or `:stem`.
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
  #f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification
  obs_x0 = plt[2]
  #x0 = obs_x0[]
  obs_x1 = plt[3]
  #x1 = obs_x1[]

  obs_tns = Observable( 0:100 )
  obs_xns = Observable( Float64[] )
  obs_colors = Observable{Any}(0:100)
  obs_plotter = Observable(scatter!)

  function update_plot(f, x0, x1, iterations, hidediterations, plotstyle)
    #
    if hidediterations > 0 
      for n in 1:hidediterations
        x0 = f(x0)
        x1 = f(x1)
      end
    end

    # Initial observable arrays for interaction
    obs_tns = Observable( hidediterations:(hidediterations+iterations) )

    # Iterations, to be drawn
    for n in 0:iterations
      push!(obs_xns[], x0 - x1 )
      x0 = f(x0)
      x1 = f(x1)
    end

    # Coloring
    obs_colors[] = 0:iterations
    if haskey(plt, :color)
      obs_colors[] = plt.color[]
    end

    # Plotstyle
    if plotstyle == :stem
      obs_plotter[] = stem!
    else # :scatterlines
      #obs_tns = Observable( hidediterations:(hidediterations+iterations) )
      obs_plotter[] = scatter!
    end  

  end # Function update_plot

  # connect `update_plot` so that it is called whenever arguments change
  Makie.Observables.onany(update_plot, obs_f, plt.iterations, plt.hidediterations, plt.plotstyle)

  # then call it once manually with the first argument contents so we prepopulate all observables with correct values
  update_plot(obs_f[], obs_x0[], obs_y0[], plt.iterations[], plt.hidediterations[], plt.plotstyle[])

#=
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
=#
  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hidediterations)
  delete!(plt.attributes.attributes, :plotstyle)

  # Drawing the iterations
  #=if pltsty == :stem
    stem!(plt, obs_tns, obs_xns; plt.attributes.attributes..., color = clr)
  else
    scatterlines!(plt, obs_tns, obs_xns; plt.attributes.attributes..., color = clr)
  end=#
  obs_plotter[](plt, obs_tns, obs_xns; plt.attributes.attributes..., color = obs_colors)

  plt 
end


######
# 3D #
######

#
# Plot Func(tion) Time Series 3D
#

"""
    functimeseries3d(f, p0 [; iterations, hidediterations, coloring, plotstyle])

Plot the time series of the orbit of \$p_0\$ under a function
\$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ or \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ or \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `p0::Union{Number, AbstractVector{Real}}`: Initial value(s).

#### Keyword Arguments
- `iterations::Int=20`: Number of iterations in the orbit to be drawn.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `coloring::Symbol=:time`:
  - `:orbit`: Different colors for each orbit.
  - `:time`: Different colors for each time.
  - `:unique`: Unique color.
- `plotstyle::Symbol=:scatterlines`: Plot style `:scatterlines` or `:stem`.
"""
@recipe(FuncTimeSeries3D) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time,
    colormap = :viridis,
    plotstyle = :scatterlines
  )
end

function Makie.plot!(plt::FuncTimeSeries3D{ <:Tuple{ Function, Any } })
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification

  obs_p0 = plt[2]
  p0 = obs_p0[]
  p0s = []

  if p0 isa Number # A unique initial complex number
    p0s = ComplexF64[]
    push!(p0s, p0)
  elseif p0[1] isa Real # A unique initial array
    push!(p0s, p0)
  else # A set of points (complex or array)
    p0s = collect(obs_p0[])
  end
  nvals = length(p0s) # Number of inital values

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  clrn = plt.coloring[]
  pltsty = plt.plotstyle[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for k in 1:nvals
      for n in 1:nhits
        p0s[k] = f(p0s[k])
      end
    end
  end

  # Initial observable arrays for interaction
  obs_pns = [ Observable( Point3f[] ) for k in 1:nvals ]
  for k in 1:nvals
    push!(obs_pns[k][], Point3f(nhits, topoint2f(p0s[k])...) )
  end

  # Iterations, to be drawn
  for k in 1:nvals
    kps = obs_pns[k][]
    for n in 1:nits
      p0s[k] = f(p0s[k])
      push!(kps, Point3f(nhits+n, topoint2f(p0s[k])...) ) # Saving array of PointNf
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
    #=obs_tns = [ Observable( (nhits):(nhits+nits) ) ]
    if nvals > 1
      obs_tns = [ Observable( (nhits+k/nvals):(nhits+nits+k/nvals) ) for k in 0:nvals ]
    end=#

    for k in 1:nvals    
      stem!(plt, obs_pns[k];
        plt.attributes.attributes..., color = funcolor(k))
    end    
  else
    #obs_tns = Observable( nhits:(nhits+nits) )

    for k in 1:nvals
      scatterlines!(plt, obs_pns[k];
        plt.attributes.attributes..., color = funcolor(k))
    end  
  end

  plt 
end


#
# Plot Func(tion) Time Series Diff(erences)
#

"""
    functimeseriesdiff3d(f, p0, p1 [; iterations, hidediterations, coloring])

Plot the time series of the difference of two orbits (of \$p_0\$ and \$p_1\$) under a function
\$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ or \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ or \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `p0::Union{Number, Array{Real}}`: Initial value.
- `p1::Union{Number, Array{Real}}`: Initial value.

#### Keyword Arguments
- `iterations::Int=20`: Number of iterations in the orbit to be drawn.
- `hidediterations::Int=0`: Number of iterations in the orbit not drawn.
- `plotstyle::Symbol=:scatterlines`: Plot style, `:scatterlines` or `:stem`.
"""
@recipe(FuncTimeSeriesDiff3D) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    plotstyle = :scatterline
  )
end

function Makie.plot!(plt::FuncTimeSeriesDiff3D{ <:Tuple{ Function, Any, Any } })

  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification

  obs_p0 = plt[2]
  p0 = obs_p0[]
  obs_p1 = plt[3]
  p1 = obs_p1[]

  if p0 isa AbstractArray
    p0 = SVector(p0...)
    p1 = SVector(p1...)
  end

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  pltsty = plt.plotstyle[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for n in 1:nhits
      p0 = f(p0)
      p1 = f(p1)
    end
  end

  # Initial observable arrays for interaction
  obs_pns = Observable( Point3f[] )
  #obs_tns = Observable( nhits:(nhits+nits) )

  # Iterations, to be drawn
  for n in 0:nits
    push!(obs_pns[], Point3f(nhits+n, topoint2f(p0 - p1)...) )
    p0 = f(p0)
    p1 = f(p1)
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
    stem!(plt, obs_pns; plt.attributes.attributes..., color = clr)
  else
    scatterlines!(plt, obs_pns; plt.attributes.attributes..., color = clr)
  end

  plt 
end
