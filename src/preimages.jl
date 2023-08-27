
###
# Preimages, with "simple" coloring function (compatible with colormaps)
###

"""
Create a function to return the nth-preimage asociated value for the color map.
"""
function createpreimageval(f::Function; topoint::Function,
    hasescaped::Function=p->abs2(p)>100, iterations::Int=1,
    coloringfunction::Function=p->abs2(p)/100, outsidecolor::Real=1.0)
  return function preimageval(x::Real, y::Real)
    p = topoint(x,y)
    if iterations == 0
      if hasescaped(p)
        return outsidecolor
      else
        return coloringfunction(p)
      end
    end
    for n in 1:iterations
      p = f(p)
      if hasescaped(p)
        return outsidecolor
      end
    end
    coloringfunction(p)
  end
end


"""
Return a matrix of "simple" preimage values.
"""
function matrixsimplepreimages(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function=z->abs2(z)>100, iterations::Int=1,
  coloringfunction::Function=p->abs2(p)/100, outsidecolor::Real=1.0,
  value::Function=k::Real->k, rot90::Bool=false)

  preval = createpreimageval(f, topoint=createtopoint2D(functionkind2D(f)),
    hasescaped=hasescaped, iterations=iterations,
    coloringfunction=coloringfunction, outsidecolor=outsidecolor)

  W, H = length(xs), length(ys)
  mtrx = rot90 ? fill(value(0.0), H, W) : fill(value(0.0), W, H)

  if rot90
    _ys = Base.reverse(ys)
    for h in 1:H
      for w in 1:W
        mtrx[h,w] = value(preval(xs[w],_ys[h]))
      end
    end
  else
    for h in 1:H
      for w in 1:W
        mtrx[w,h] = value(preval(xs[w],ys[h]))
      end
    end
  end

  mtrx
end


"""
    imgsimplepreimages(f, xs, ys [; iterations, coloringfunction, colormap, hasescaped, outsidecolor])

Return an image with the drawing of the nth-preimage of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    with a given a coloring function over the plane.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `iterations::Integer`: Number of iterations to calculate \$f^n\$.
- `coloringfunction::Function`: A plane coloring function.
- `colormap`: Color map for the coloring function.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `outsidecolor`: Color index asigned to escaped points.
"""
function imgsimplepreimages(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function = p->abs2(p)>100, iterations::Int = 1, 
  coloringfunction::Function=p->abs2(p)/100, outsidecolor::Real=1.0,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis)

  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  #cm = [ cs[k/maxiterations] for k in 0.0:maxiterations ]

  matrixsimplepreimages(f, xs, ys; hasescaped=hasescaped, iterations=iterations,
    coloringfunction=coloringfunction, outsidecolor=outsidecolor,
    value=k::Real->cm[k], rot90=true)
end


"""
    simplepreimages(f, xs, ys, [; iterations, coloringfunction, hasescaped, outsidecolor, plotstyle])

Return a **Makie** plot with the drawing of the preimages of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$
    with a given a coloring function over the plane.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `iterations::Integer`: Number of iterations to calculate \$f^n\$.
- `coloringfunction::Function`: A plane coloring function.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `outsidecolor`: Color index asigned to escaped points.
- `plotstyle::Symbol`: Plot style `:heatmap` or `:image`.
"""
@recipe(SimplePreImages) do scene
  Attributes(
    iterations = 1,
    hasescaped = p -> abs2(p)>100,
    coloringfunction = p -> abs2(p)/100,
    outsidecolor = 1.0,
    plotstyle = :heatmap
  )
end

function Makie.plot!(plt::SimplePreImages{<:Tuple{Function, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  # Plot keyword arguments
  its = plt.iterations[]
  he = plt.hasescaped[]  
  cf = plt.coloringfunction[]  
  outclr = plt.outsidecolor[]
  pltsty = plt.plotstyle[]  

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :coloringfunction)
  delete!(plt.attributes.attributes, :outsidecolor)
  delete!(plt.attributes.attributes, :plotstyle)

  # Makie's Plot
  if pltsty == :image
    pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
    cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

    image!(plt, obs_xs, obs_ys,
      matrixsimplepreimages(f, xs, ys, hasescaped=he, iterations=its,
        coloringfunction=cf, outsidecolor=outclr, value=k::Real->cm[k] );
      plt.attributes.attributes...)
  else
    heatmap!(plt, obs_xs, obs_ys,
      createpreimageval(f, topoint=createtopoint2D(functionkind2D(f)),
        hasescaped=he, iterations=its, coloringfunction=cf, outsidecolor=outclr);
      plt.attributes.attributes...)
  end

  plt
end


"""
    isimplepreimages([g,] f, xs, ys, [; iterations, coloringfunction, hasescaped, outsidecolor])

Same as `simplepreimages`, but using **InteractiveViz**.
"""
isimplepreimages(f::Function, xs, ys; iterations::Int=1, hasescaped::Function=p->abs2(p)>100,
  coloringfunction::Function=p->abs2(p)/100, outsidecolor::Float64=1.0, kwargs...) =
  iheatmap( createpreimageval( f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, iterations=iterations,
      coloringfunction=coloringfunction, outsidecolor=outsidecolor),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)
isimplepreimages(g, f::Function, xs, ys; iterations::Int=1, hasescaped::Function=p->abs2(p)>100,
  coloringfunction::Function=p->abs2(p)/100, outsidecolor::Float64=1.0, kwargs...) =
  iheatmap(g, createpreimageval( f, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, iterations=iterations,
      coloringfunction=coloringfunction, outsidecolor=outsidecolor),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)



###
# Preimages, with "complicated" coloring function, returning colors
###


"""
Return a matrix of preimage colors.
"""
function matrixpreimages(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function=z->abs2(z)>100, iterations::Int=1,
  coloringfunction::Function=ClassicDomainCF(), outsidecolor::Colorant=RGBf(0,0,0),
  rot90::Bool=false)

  topoint=createtopoint2D(functionkind2D(f))

  W, H = length(xs), length(ys)
  mtrx = rot90 ? fill(outsidecolor, H, W) : fill(outsidecolor, W, H)

  if rot90
    _ys = Base.reverse(ys)
    for h in 1:H
      for w in 1:W
        p = topoint(xs[w], _ys[h])
        for n in 1:iterations
          p = f(p)
        end
        mtrx[h,w] = coloringfunction(p)
      end
    end
  else
    for h in 1:H
      for w in 1:W
        p = topoint(xs[w], ys[h])
        for n in 1:iterations
          p = f(p)
        end
        mtrx[w,h] = coloringfunction(p)
      end
    end
  end

  mtrx
end


"""
    imgpreimages(f, xs, ys [; iterations, coloringfunction, hasescaped, outsidecolor])

Return an image with the drawing of the nth-preimage of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$,
    with a given a coloring function over the plane.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `iterations::Integer`: Number of iterations to calculate \$f^n\$.
- `coloringfunction::Function`: A plane coloring function.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `outsidecolor`: Color asigned to escaped points.
"""
function imgpreimages(f::Function, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function = p->abs2(p)>100, iterations::Int = 1, 
  coloringfunction::Function=ClassicDomainCF(), outsidecolor::Colorant=RGBf(0,0,0))


  matrixpreimages(f, xs, ys; hasescaped=hasescaped, iterations=iterations,
    coloringfunction=coloringfunction, outsidecolor=outsidecolor,
    rot90=true)
end


"""
    preimages(f, xs, ys, [; iterations, coloringfunction, hasescaped, outsidecolor])

Return a **Makie** plot with the drawing of the preimages of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$
    with a given a coloring function over the plane.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
#### Keyword arguments
- `iterations::Integer`: Number of iterations to calculate \$f^n\$.
- `coloringfunction::Function`: A plane coloring function.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `outsidecolor`: Color or index to be asigned to escaped points.
"""
@recipe(PreImages) do scene
  Attributes(
    iterations = 1,
    hasescaped = p -> abs2(p)>100,
    coloringfunction = ClassicDomainCF(),
    outsidecolor = RGBf(0,0,0)
  )
end

function Makie.plot!(plt::PreImages{<:Tuple{Function, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  # Plot keyword arguments
  its = plt.iterations[]
  he = plt.hasescaped[]  
  cf = plt.coloringfunction[]  
  outclr = plt.outsidecolor[]

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :coloringfunction)
  delete!(plt.attributes.attributes, :outsidecolor)

  # Makie's Plot
  pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
  cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

  image!(plt, obs_xs, obs_ys,
    matrixpreimages(f, xs, ys, hasescaped=he, iterations=its,
      coloringfunction=cf, outsidecolor=outclr );
    plt.attributes.attributes...)

  plt
end



#=
"""
    drawpreimageR2(f [; iterations])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

Using the a color map function \$c:\\mathbb{R}^2\\rightarrow Colors\$,
is drawn \$c\\circ f^n(x,y)\$ for \$(x,y)\$ in the rectangular region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `iterations::Integer`: Number of iterations.
"""
function drawpreimageR2(f::Function; iterations::Int=1)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterativeR2 f iterations
    fn = foriterativeR2(f,iterations)
    #fn = SDDCore.composeR2(f,iterations) # doesn't exists... yet

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        SDDGraphics.color(fn(x,y)...)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end


"""
    drawpreimageC(f [; iterations])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

Using the a color map function \$c:\\mathbb{C}\\rightarrow Colors\$,
is drawn \$c\\circ f^n(z)\$ for \$z\$ in the rectangulr region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `iterations::Integer`: Number of iterations.
"""
function drawpreimageC(f::Function; iterations::Int=1)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterative f iterations
    #fn = foriterative(f,iterations)
    fn = SDDCore.iterative(f,iterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        SDDGraphics.color(fn(complex(x,y)))
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end
=#