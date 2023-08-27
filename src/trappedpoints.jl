
"""
Create a function to return the scape time of iterations of a point.
"""
function createescapetime(f::Function; topoint::Function,
    hasescaped::Function=p->abs2(p)>4, maxiterations::Int=100,
    normalize::Union{Nothing, Function}=nothing)
  if isnothing(normalize)
    return function escapetime(x::Real, y::Real)
      p = topoint(x,y)
      for n in 0:maxiterations
        if hasescaped(p)
          return n
        end
        p = f(p)
      end
      maxiterations
    end
  else
    return function escapetimenorm(x::Real, y::Real)
      p = topoint(x,y)
      for n in 0:maxiterations
        if hasescaped(p)
          return normalize(n, p)
        end
        p = f(p)
      end
      #normalize(maxiterations, p)
      maxiterations
    end
  end
  (x,y) -> maxiterations
end


"""
Return a matrix of escape time values.
"""
function matrixtrappedpoints(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function=z->abs2(z)>4, maxiterations::Int=100, normalize::Union{Nothing, Function}=nothing, 
  value::Function=k::Real->k, rot90::Bool=false)

  esctime = createescapetime(f, topoint=createtopoint2D(functionkind2D(f)),
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
    imgtrappedpoints(f, xs, ys [; hasescaped, maxiterations, normalize, colormap])

Return a image with the drawing of the trapped points set of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The trapped points set of \$f\$ is defined as
\$\\mathcal{K}(f)=\\{p\\in X\\,|\\,|f^n(p)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the escape times.
- `colormap`: Color map to escape times.
"""
function imgtrappedpoints(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function = p->abs2(p)>4, maxiterations::Int = 100, normalize::Union{Nothing, Function}=nothing,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis)

  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  #cm = [ cs[k/maxiterations] for k in 0.0:maxiterations ]

  matrixtrappedpoints(f, xs, ys; hasescaped=hasescaped, maxiterations=maxiterations,
    normalize=normalize, value = k::Real -> cm[k/maxiterations], rot90=true)
end


"""
    trappedpoints(f, xs, ys, [; hasescaped, maxiterations, normalize, plotstyle])

Return a **Makie** plot with the drawing of the trapped points set of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    using the escape time of iterations algorithm.

The trapped points set of \$f\$ is defined as
\$\\mathcal{K}(f)=\\{p\\in X\\,|\\,|f^n(p)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check the escape.
- `normalize::Function`: A function `(time::Int, p)->Real` to normalize the escape times.
- `plotstyle::Symbol`: Plot style `:heatmap` or `:image`.
"""
@recipe(TrappedPoints) do scene
  Attributes(
    maxiterations = 20,
    hasescaped = p -> abs2(p)>4,
    normalize = nothing,
    plotstyle = :heatmap
  )
end

function Makie.plot!(plt::TrappedPoints{<:Tuple{Function, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  # Plot keyword arguments
  maxits = plt.maxiterations[]
  he = plt.hasescaped[]  
  nrm = plt.normalize[]  
  pltsty = plt.plotstyle[]  

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :maxiterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :normalize)
  delete!(plt.attributes.attributes, :plotstyle)

  # Makie's Plot
  if pltsty == :image
    pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
    cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

    image!(plt, obs_xs, obs_ys,
      matrixtrappedpoints(f, xs, ys, hasescaped=he, maxiterations=maxits, normalize=nrm,
        value=k->cm[k/maxits] );
      plt.attributes.attributes...)
  else
    heatmap!(plt, obs_xs, obs_ys,
      createescapetime(f, topoint=createtopoint2D(functionkind2D(f)),
        hasescaped=he, maxiterations=maxits, normalize=nrm);
      plt.attributes.attributes...)
  end

  plt
end


"""
    itrappedpoints([g,] f, xs, ys, [; hasescaped, maxiterations, normalize])

Same as `trappedpoints`, but using **InteractiveViz**.
"""
itrappedpoints(f::Function, xs, ys; maxiterations::Int=100,
  hasescaped::Function=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap( createescapetime( f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize ),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)
itrappedpoints(g, f::Function, xs, ys; maxiterations::Int=100,
  hasescaped::Function=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap(g, createescapetime( f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize ),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)
#=itrappedpoints!(f::Function, xs, ys; maxiterations=100, hasescaped=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap!(f, xs[1], xs[end], ys[1], ys[end],
    createescapetimexy(f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize);
    kwargs...)
itrappedpoints!(g, f::Function, xs, ys; maxiterations=100, hasescaped=p->abs2(p)>4, normalize::Union{Nothing, Function}=nothing, kwargs...) =
  iheatmap!(g, f, xs[1], xs[end], ys[1], ys[end],
    createescapetimexy(f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, normalize=normalize);
    kwargs...)
=#


#=
"""
    drawtrappedpointsR2(f [; hasescaped, maxiterations])

Return the drawing of the trapped points set of a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$,
    using the escape time of iterations algorithm.

The trapped points set of \$f\$ is defined as
\$\\mathcal{K}(f)=\\{(x,y)\\in\\mathbb{R}^2\\,|\\,|f^n(x,y)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawtrappedpointsR2(f::Function;
    hasescaped::Function=(x::Real,y::Real) -> x*x+y*y > 4, maxiterations::Int=100)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}
    @assert typeof(hasescaped(1., 1.)) <: Bool

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(maxiterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        xn,yn = x,y
        escapetime = maxiterations
        for n in 1:maxiterations
            if hasescaped(xn,yn)
                escapetime = n
                break
            end # if hasescaped
            xn,yn = f(xn,yn)
        end # for n maxiterations
        SDDGraphics.color(escapetime)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()

#= # Classical code
    width, height = SDDGraphics.canvassize()
    xmin, xmax = xlims
    ymin, ymax = ylims
    Δx, Δy = (xmax-xmin)/width, (ymax-ymin)/height

    x, y = 0., 0.

    y = ymax
    for j in 1:height

        x = xmin
        for i in 1:width

            xn, yn = x, y
            escapetime = 1.
            for n in 0:maxiterations

                if hasescaped(xn,yn)
                    escapetime = n/maxiterations
                    break
                end # if hasescaped

                xn,yn = f(xn,yn)

            end # for n maxiterations

            SDDGraphics.drawpixel(j,i,escapetime)

            x += Δx

        end # for i width

        y -= Δy

    end # for j height

    SDDGraphics.plot()
=#
end # function drawtrappedpointsR2


"""
    drawtrappedpointsC(f [; hasescaped, maxiterations])

Return the drawing of the trapped points set of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$,
    using the escape time of iterations algorithm.

The trapped points set of \$f\$ is defined as
\$\\mathcal{K}(f)=\\{z\\in\\mathbb{C}\\,|\\,|f^n(z)|\\nrightarrow\\infty\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawtrappedpointsC(f::Function;
    hasescaped::Function=z::Number -> abs2(z) > 4, maxiterations::Int=100)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number
    @assert typeof(hasescaped(1.0im)) <: Bool

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(maxiterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        zn = complex(x,y)
        escapetime = maxiterations
        for n in 1:maxiterations
            if hasescaped(zn)
                escapetime = n
                break
            end # if hasescaped
            zn = f(zn)
        end # for n maxiterations
        SDDGraphics.color(escapetime)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()

end # function drawtrappedpointsC
=#