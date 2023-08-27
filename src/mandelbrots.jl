
############
# Mandelbrot
############

"""
Create a function to return the scape time of iterations of a point.
"""
function createseedescapetime(f::Function; topoint::Function,
    seed::Union{Number, AbstractVector{<:Real}, Function},
    hasescaped::Function=p->abs2(p)>4, maxiterations::Int=100,
    normalize::Union{Nothing, Function}=nothing)
  if isnothing(normalize)
    if seed isa Function
      return function seedfuncescapetime(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        p = seed(t) # Seed
        for n in 0:maxiterations
          if hasescaped(p)
            return n
          end # if hasescaped
          p = f(t, p)
        end # for
        maxiterations
      end # function
    else
      return function seedescapetime(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        p = seed # Seed
        for n in 0:maxiterations
          if hasescaped(p)
            return n
          end # if hasescaped
          p = f(t, p)
        end # for
        maxiterations
      end # function
    end # if function
  else
    if seed isa Function
      return function seedfuncescapetimenorm(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        p = seed(t) # Seed
        for n in 0:maxiterations
          if hasescaped(p)
            return normalize(n,p)
          end # if hasescaped
          p = f(t, p)
        end # for
        maxiterations
      end # function
    else
      return function seedescapetimenorm(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        p = seed # Seed
        for n in 0:maxiterations
          if hasescaped(p)
            return normalize(n,p)
          end # if hasescaped
          p = f(t, p)
        end # for
        maxiterations
      end # function
    end # if function
  end # if normalize

  (x,y) -> maxiterations
end


"""
Return a matrix of escape time values for Mandelbrot.
"""
function matrixmandelbrot(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  seed::Union{Number, AbstractVector{<:Real}, Function},
  hasescaped::Function=z->abs2(z)>4, maxiterations::Int=100, normalize::Union{Nothing, Function}=nothing, 
  value::Function=k::Real->k, rot90::Bool=false)

  esctime = createseedescapetime(f, seed=seed, topoint=createtopoint2D(functionfamkind2D(f)),
    hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize)

  W, H = length(xs), length(ys)
  mtrx = rot90 ? fill(value(0.0), H, W) : fill(value(0.0), W, H)

  if rot90
    _ys = Base.reverse(ys)
    for h in 1:H
      for w in 1:W
        mtrx[h,w] = value(esctime(xs[w],_ys[h]))
      end
    end
  else
    for h in 1:H
      for w in 1:W
        mtrx[w,h] = value(esctime(xs[w],ys[h]))
      end
    end
  end

  mtrx
end


"""
    imgmandelbrot(f, xs, ys; seed, [ hasescaped, maxiterations, normalize, colormap])

Return a image with the drawing of the (generalized) Mandelbrot set of a family of functions
    \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ with \$t\\in\\mathbb{C}\$ or
    \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ with \$t\\in\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The generalized Mandelbrot set of \$f_t\$ is defined as
\$\\mathcal{M}(f_t,seed)=\\{t\\in X\\,|\\,|f_t^n(seed)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A family of functions \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `seed::Union{Number, AbstractVector{Real}, Function}`: The seed for the generalized Mandelbrot set. It can be a function in the space of parameters to the dynamic space.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the escape times.
- `colormap`: Color map to escape times.
"""
function imgmandelbrot(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  seed::Union{Number, AbstractVector{<:Real}, Function},
  hasescaped::Function = p->abs2(p)>4, maxiterations::Int = 100, normalize::Union{Nothing, Function}=nothing,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis)

  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)

  matrixmandelbrot(f, xs, ys; seed=seed, hasescaped=hasescaped, maxiterations=maxiterations,
    normalize=normalize, value = k::Real -> cm[k/maxiterations], rot90=true)
end


"""
    mandelbrot(f, xs, ys; seed [, hasescaped, maxiterations, normalize, plotstyle])

Return a **Makie** plot with the drawing of the (generalized) Mandelbrot set of a family of functions
    \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ with \$t\\in\\mathbb{C}\$ or
    \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ with \$t\\in\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The generalized Mandelbrot set of \$f_t\$ is defined as
\$\\mathcal{M}(f_t,seed)=\\{t\\in X\\,|\\,|f_t^n(seed)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A family of functions \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `seed::Union{Number, AbstractVector{Real}, Function}`: The seed for the generalized Mandelbrot set. It can be a function in the space of parameters to the dynamic space.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the escape times.
- `plotstyle::Symbol`: Plot style `:heatmap` or `:image`.
"""
@recipe(Mandelbrot) do scene
  Attributes(
    seed = 0,
    maxiterations = 20,
    hasescaped = p -> abs2(p)>4,
    normalize = nothing,
    plotstyle = :heatmap
  )
end

function Makie.plot!(plt::Mandelbrot{<:Tuple{Function, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  # Plot keyword arguments
  s = plt.seed[]
  maxits = plt.maxiterations[]
  he = plt.hasescaped[]  
  nrm = plt.normalize[]  
  pltsty = plt.plotstyle[]  

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :seed)
  delete!(plt.attributes.attributes, :maxiterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :normalize)
  delete!(plt.attributes.attributes, :plotstyle)

  # Makie's Plot
  if pltsty == :image
    pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
    cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

    image!(plt, obs_xs, obs_ys,
      matrixmandelbrot(f, xs, ys, seed=s, hasescaped=he, maxiterations=maxits, normalize=nrm,
        value=k->cm[k/maxits] );
      plt.attributes.attributes...)
  else
    heatmap!(plt, obs_xs, obs_ys,
      createseedescapetime(f, seed=s, topoint=createtopoint2D(functionfamkind2D(f)),
        hasescaped=he, maxiterations=maxits, normalize=nrm);
      plt.attributes.attributes...)
  end

  plt
end


"""
    imandelbrot([g,] f, xs, ys; seed [, hasescaped, maxiterations, normalize])

Same as `mandelbrot`, but using **InteractiveViz**.
"""
imandelbrot(f::Function, xs, ys; seed::Union{Number,AbstractVector{<:Real},Function}, maxiterations::Int=100,
  hasescaped::Function=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap( createseedescapetime( f, seed=seed, topoint=createtopoint2D(functionfamkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize ),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)
imandelbrot(g, f::Function, xs, ys; seed::Union{Number,AbstractVector{<:Real},Function}, maxiterations::Int=100,
  hasescaped::Function=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap(g, createseedescapetime( f, seed=seed, topoint=createtopoint2D(functionfamkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize ),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)



#######################
# Mandelbrot Multi-Seed
#######################

"""
Create a function to return the scape time of iterations of a set of point.
"""
function createmultiseedescapetime(f::Function; topoint::Function,
    seed::AbstractVector,
    hasescaped::Function=p->abs2(p)>4, maxiterations::Int=100,
    normalize::Union{Nothing, Function}=nothing, normalizesum::Union{Symbol, Function}=:trunc,
    scale::Union{Nothing,Function}=nothing,)

  sclnrm = n::Real -> n
  if isnothing(scale)
    if normalizesum == :trunc
      sclnrm = n::Real -> ( n > maxiterations ? 1.0 : n/maxiterations )
    elseif normalizesum == :average  
      sclnrm = n::Real -> n/(maxiterations*length(seed))
    else
      sclnrm = n::Real -> normalizesum(n)/(maxiterations*length(seed))
    end
  else
    if normalizesum == :trunc
      sclnrm = n::Real -> ( n > maxiterations ? 1.0 : scale(n)/scale(maxiterations) )
    elseif normalizesum == :average  
      sclnrm = n::Real -> scale(n)/scale(maxiterations*length(seed))
    else
      sclnrm = scale(normalizesum(n)/(maxiterations*length(seed)))
    end
  end

  if isnothing(normalize)
    if seed[1] isa Function
      return function seedfuncescapetime(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        sumets = length(seed)*maxiterations
        for k in 1:length(seed)
          p = seed[k](t)
          for n in 0:maxiterations
            if hasescaped(p)
              sumets += (n-maxiterations)
              break
            end # if hasescaped
            p = f(t, p)
          end # for maxiteraions
        end # for seeds
        sclnrm(sumets)
      end # function
    else
      return function seedescapetime(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        ps = seed # Seeds
        sumets = length(seed)*maxiterations
        for k in 1:length(ps)
          p = ps[k]
          for n in 0:maxiterations
            if hasescaped(p)
              sumets += (n-maxiterations)
              break
            end # if hasescaped
            p = f(t, p)
          end # for maxiterations
        end # for seeds
        sclnrm(sumets)
      end # function
    end # if function
  else
    if seed isa Function
      return function seedfuncescapetimenorm(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        sumets = length(seed)*maxiterations
        for k in 1:length(seed)
          p = seed[k](t)
          for n in 0:maxiterations
            if hasescaped(p)
              sumets += (n-maxiterations)
              break
            end # if hasescaped
            p = f(t, p)
          end # for maxiterations
        end # for seeds
        sclnrm(normalize(sumets,p))
      end # function
    else
      return function seedescapetimenorm(x::Real, y::Real)
        t = topoint(x,y) # Family parameter
        ps = seed # Seed
        sumets = length(seed)*maxiterations
        for k in 1:length(ps)
          p = ps[k]
          for n in 0:maxiterations
            if hasescaped(p)
              sumets += (n-maxiterations)
              break
            end # if hasescaped
            p = f(t, p)
          end # for maxiterations
        end # for seeds
        sclnrm(normalize(sumets,p))
      end # function
    end # if function
  end # if normalize

  (x,y) -> sclnrm(length(seed)*maxiterations)
end


"""
Return a matrix colors of escape time values for Mandelbrot multi-seed.
"""
function matrixmandelbrotmultiseed(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  seed::AbstractVector, hasescaped::Function=z->abs2(z)>4, maxiterations::Int=100,
  normalize::Union{Nothing, Function}=nothing, normalizesum::Union{Symbol, Function}=:trunc,
  scale::Union{Nothing,Function}=nothing,
  value0=RGB(0,0,0), value::Function=k::Real->RGB(1,1,1), rot90::Bool=false)

  topt = createtopoint2D(functionfamkind2D(f))

  esctimes = [ createseedescapetime(f, seed=s, topoint=topt,
    hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize) for s in seed ]
  
  M = length(seed)

  ets = fill(maxiterations, 1, M)

  W, H = length(xs), length(ys)
  ClrType = value0 isa RGB ? RGB{Float64} : RGBA{Float64}
  value0 = value0 isa RGB ? ClrType(value0) : ClrType(value0)
  mtrx = rot90 ? fill(value0, H, W) : fill(value0, W, H)

  sclnrm = n::Real -> n
  if isnothing(scale)
    if normalizesum == :trunc
      sclnrm = n::Real -> ( n > maxiterations ? 1.0 : n/maxiterations )
    elseif normalizesum == :average  
      sclnrm = n::Real -> n/(maxiterations*M)
    else
      sclnrm = n::Real -> normalizasum(n)/(maxiterations*length(seed))
    end
  else
    if normalizesum == :trunc
      sclnrm = n::Real -> ( n > maxiterations ? 1.0 : scale(n)/scale(maxiterations) )
    elseif normalizesum == :average  
      sclnrm = n::Real -> scale(n)/scale(maxiterations*M)
    else
      sclnrm = scale(normalizasum(n)/(maxiterations*M))
    end
  end

  if rot90
    _ys = Base.reverse(ys)
    for h in 1:H
      for w in 1:W
        summaxits = 0
        for k in 1:length(seed)
          ets[k] = esctimes[k](xs[w],_ys[h])
          summaxits += ets[k]
        end # for seeds
        mtrx[h,w] = value0
        if summaxits > 0
          etvalue = ClrType(0,0,0)
          for k in 1:length(seed)
            etvalue += (ets[k]/summaxits)*ClrType(value(k))
          end
          T = sclnrm(summaxits) #log(avmaxits)/log(maxiterations)
          mtrx[h,w] = (1.0-T)*value0 + T*etvalue
        end #if summaxit
      end # for W
    end # for H
  else
    for h in 1:H
      for w in 1:W
        summaxits = 0
        for k in 1:length(seed)
          ets[k] = esctimes[k](xs[w],ys[h])
          summaxits += ets[k]
        end # for seeds
        mtrx[w,h] = value0
        if summaxits > 0
          etvalue = ClrType(0,0,0)
          for k in 1:length(seed)
            etvalue += (ets[k]/summaxits)*ClrType(value(k))
          end
          T = sclnrm(summaxits)
          mtrx[w,h] = (1.0-T)*value0 + T*etvalue
        end #if summaxit
      end
    end
  end

  mtrx
end


"""
    imgmandelbrotmultiseed(f, xs, ys; seed, [ hasescaped, maxiterations, normalize, colormap, outsidecolor])

Return a image with the drawing of the (generalized) Mandelbrot set with multiple seeds of a family of functions
    \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ with \$t\\in\\mathbb{C}\$ or
    \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ with \$t\\in\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The generalized Mandelbrot set with multiple seeds of \$f_t\$ is defined as
\$\\mathcal{M}(f_t,\\{s_1,\\dots,s_M\\})=\\{t\\in X\\,|\\,|f_t^n(s_m)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\,\\forall\\,s_m\\}\$

#### Arguments
- `f::Function`: A family of functions \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `seed::AbstractVector`: The seeds for the generalized Mandelbrot set. It can be an array of seed functions.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the individual seed escape times.
- `normalizesum::Union{Symbol,Function}`: A funtion `time::Int->Real` to normalize the sum of seed escape times. It can be also `:trunc` (default) or `:average`.
- `scale::Function`: A scale function \$S\$to the ratio \$S(\$ escape time \$)/S(\$ maxiterations \$)\$.
- `colormap`: Color map to escape times.
- `outsidecolor`: A color to be asigned when is in the "escape zone".
"""
function imgmandelbrotmultiseed(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  seed::AbstractVector, hasescaped::Function = p->abs2(p)>4, maxiterations::Int = 100,
  normalize::Union{Nothing, Function}=nothing, normalizesum::Union{Symbol, Function}=:trunc,
  scale::Union{Nothing,Function}=nothing,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis, outsidecolor=RGB(0,0,0))

  cs = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  cm = length(seed) > 1 ? [ cs[k/(length(seed)-1)] for k in 0:(length(seed)-1) ] : [cs[0.0]]

  matrixmandelbrotmultiseed(f, xs, ys; seed=seed, hasescaped=hasescaped, maxiterations=maxiterations,
    normalize=normalize, normalizesum=normalizesum, scale=scale,
    value = k::Real -> cm[k], value0=outsidecolor, rot90=true)
end


"""
    mandelbrotmultiseed(f, xs, ys; seed [, hasescaped, maxiterations, normalize, plotstyle, outsidecolor])

Return a **Makie** plot with the drawing of the (generalized) Mandelbrot set with multiple seeds of a family of functions
    \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ with \$t\\in\\mathbb{C}\$ or
    \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ with \$t\\in\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The generalized Mandelbrot set with multiple seeds of \$f_t\$ is defined as
\$\\mathcal{M}(f_t,\\{s_1,\\dots,s_M\\})=\\{t\\in X\\,|\\,|f_t^n(s_m)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\,\\forall\\,s_m\\}\$

#### Arguments
- `f::Function`: A family of functions \$f_t:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f_t:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `seed::AbstractVector`: The seeds for the generalized Mandelbrot set. It can be an array of seed functions.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the individual seed escape times.
- `normalizesum::Union{Symbol,Function}`: A funtion `time::Int->Real` to normalize the sum of seed escape times. It can be also `:trunc` (default) or `:average`.
- `scale::Function`: A scale function \$S\$to the ratio \$S(\$ escape time \$)/S(\$ maxiterations \$)\$.
- `plotstyle::Symbol`: Plot style `:heatmap` or `:image`.
- `outsidecolor`: A color to be asigned when is in the "escape zone".
"""
@recipe(MandelbrotMultiSeed) do scene
  Attributes(
    seed = [0im, 1im],
    maxiterations = 20,
    hasescaped = p -> abs2(p)>4,
    normalize = nothing,
    normalizesum = :trunc,
    scale = nothing,
    plotstyle = :heatmap,
    outsidecolor = RGB(0,0,0)
  )
end

function Makie.plot!(plt::MandelbrotMultiSeed{<:Tuple{Function, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  # Plot keyword arguments
  s = plt.seed[]
  maxits = plt.maxiterations[]
  he = plt.hasescaped[]
  nrm = plt.normalize[]
  nrmsum = plt.normalizesum[]
  scl = plt.scale[]  
  pltsty = plt.plotstyle[]  
  outclr = plt.outsidecolor[]  

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :seed)
  delete!(plt.attributes.attributes, :maxiterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :normalize)
  delete!(plt.attributes.attributes, :normalizesum)
  delete!(plt.attributes.attributes, :scale)
  delete!(plt.attributes.attributes, :plotstyle)
  delete!(plt.attributes.attributes, :outsidecolor)

  pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
  cs = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

  # Makie's Plot
  if pltsty == :image
    cm = length(s) > 1 ? [ cs[k/(length(s)-1)] for k in 0:(length(s)-1) ] : [cs[0.0]]
    image!(plt, obs_xs, obs_ys,
      matrixmandelbrotmultiseed(f, xs, ys, seed=s, hasescaped=he, maxiterations=maxits,
        normalize=nrm, normalizesum=nrmsum, scale=scl,
        value=k::Int->cm[k], value0=outclr );
      plt.attributes.attributes...)
  else
    delete!(plt.attributes.attributes, :colormap)
    cm = ColorScheme([outclr, cs.colors...])
    heatmap!(plt, obs_xs, obs_ys,
      createmultiseedescapetime(f, seed=s, topoint=createtopoint2D(functionfamkind2D(f)),
        hasescaped=he, maxiterations=maxits, normalize=nrm, normalizesum=nrmsum, scale=scl);
      plt.attributes.attributes..., colormap=cm)
  end

  plt
end


"""
    imandelbrotmultiseed([g,] f, xs, ys; seed [, hasescaped, maxiterations, normalize, outsidecolor])

Same as `mandelbrotmultiseed`, but using **InteractiveViz**.
"""
function imandelbrotmultiseed(f::Function, xs, ys; seed::AbstractVector,
    maxiterations::Int=100, hasescaped::Function=p->abs2(p)>4,
    normalize::Union{Nothing, Function}=nothing, normalizesum::Union{Symbol, Function}=:trunc,
    scale::Union{Nothing,Function}=nothing, outsidecolor=RGB(0,0,0), kwargs...)
  pltcm = haskey(kwargs, :colormap) ? kwargs[:colormap] : :viridis
  cs = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
  cm = ColorScheme([outsidecolor, cs.colors...])
  iheatmap( createmultiseedescapetime( f, seed=seed, topoint=createtopoint2D(functionfamkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normaliz, normalizesum=normalizesum, scale=scale),
    xs[1], xs[end], ys[1], ys[end];
    kwargs..., colormap=cm)
end
function imandelbrotmultiseed(g, f::Function, xs, ys; seed::AbstractVector,
    maxiterations::Int=100, hasescaped::Function=p->abs2(p)>4,
    normalize::Union{Nothing, Function}=nothing, normalizesum::Union{Symbol, Function}=:trunc,
  scale::Union{Nothing,Function}=nothing, outsidecolor=RGB(0,0,0), kwargs...)
  pltcm = haskey(kwargs, :colormap) ? kwargs[:colormap] : :viridis
  cs = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
  cm = ColorScheme([outsidecolor, cs.colors...])
  iheatmap(g, createmultiseedescapetime( f, seed=seed, topoint=createtopoint2D(functionfamkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize, normalizesum=normalizesum, scale=scale ),
    xs[1], xs[end], ys[1], ys[end];
    kwargs..., colormap=cm)
end


##
# Mandelbrot 3D
##

##
# Mandelbrot Multi-Seed 3D
##


#=
"""
    drawmandelbrotR2(f [, x0, y0; hasescaped, maxiterations])

Return the drawing of the Mandelbrot set of a family of functions
    \$f_{a,b}:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$ with \$a,b\\in\\mathbb{R}\$,
    in a rectangular region in \$\\mathbb{R}^2\$,
    using the escape time of iterations algorithm,
    over a given "critical" point \$(x_0,y_0)\$.

The Mandelbrot set of \$f_{a,b}\$ over \$(x_0,y_0)\$ is defined as
\$\\mathcal{M}(f_{a,b},(x_0,y_0))=\\{(a,b)\\in\\mathbb{R}^2\\,|\\,|f_{a,b}^n(x_0,y_0)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\times\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `x0::Real`: X coordinate of the "critical" point.
- `y0::Real`: Y coordinate of the "critical" point.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawmandelbrotR2(f::Function, x0::Real=0, y0::Real=0;
    hasescaped::Function=(x::Real,y::Real) -> x*x+y*y > 4, maxiterations::Int=100)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(0., 0., 1., 1.)) <: Tuple{Real,Real}
    @assert typeof(hasescaped(1., 1.)) <: Bool

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(maxiterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        xn,yn = x0,y0
        escapetime = maxiterations
        for n in 0:maxiterations
            if hasescaped(xn,yn)
                escapetime = n
                break
            end # if hasescaped
            xn,yn = f(x,y,xn,yn)
        end # for n maxiterations
        SDDGraphics.color(escapetime)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()

end # function drawtrappedpointsR2


"""
    drawmandelbrotC(f [, z0; hasescaped, maxiterations])

Return the drawing of the Mandelbrot set of a family of functions
    \$f_{\\lambda}:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$,
    using the escape time of iterations algorithm,
    over a given "critical" point \$z_0\$.

The Mandelbrot set of \$f_{\\lambda}\$ over \$z_0\$ is defined as
\$\\mathcal{M}(f_{\\lambda},z_0)=\\{\\lambda\\in\\mathbb{C}\\,|\\,|f_{\\lambda}^n(z_0)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\times\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `z0::Number`: A "critical" point.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawmandelbrotC(f::Function, z0::Number=0;
    hasescaped::Function=z::Number -> abs2(z) > 4, maxiterations::Int=100)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(0, 1.0im)) <: Number
    @assert typeof(hasescaped(1.0im)) <: Bool

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(maxiterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        λ = complex(x,y)
        zn = z0
        escapetime = maxiterations
        for n in 0:maxiterations
            if hasescaped(zn)
                escapetime = n
                break
            end # if hasescaped
            zn = f(λ, zn)
        end # for n maxiterations
        SDDGraphics.color(escapetime)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()

end # function drawtrappedpointsC
=#
