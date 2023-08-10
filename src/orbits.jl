
"""
    orbithpath(f, p0 [; hidediterations, iterations, coloring])

Plots the orbit of a point \$p_0\$ (or set of points) under a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$
    or
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$
    or
    \$f:\\mathbb{R}^3\\rightarrow\\mathbb{R}^3\$
    where consecutive points are connected by a line segment (or optionally not).

The orbit of \$p_0\$ under \$f\$ is defined as
    \$o(p_0,f)=\\{p_0,f(p_0),f^2(p_0),\\dots,f^n(p_0),\\dots\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `p0`: A point or set of points.
- `hidediterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `hidediterations`).
- `coloring::Symbol=:time`:
  - `:orbit`: Different colors for each orbit.
  - `:time`: Different colors for each time.
  - `:unique`: Unique color.
"""
@recipe(OrbitPath) do scene
  Attributes(
    iterations = 20,
    hidediterations = 0,
    coloring = :time
  )
end

function Makie.plot!(plt::OrbitPath{<:Tuple{Function, Any}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  #@assert typeof(f(1.)) <: Real # Function verification
  topt = topoint2f
  PtType = Point2f

  obs_p0 = plt[2]
  p0 = obs_p0[]
  p0s = []
  if p0 isa Number # A unique initial complex number
    p0s = ComplexF64[]
    push!(p0s, p0)
  elseif p0[1] isa Real # A unique initial array
    push!(p0s, p0)
    if length(p0) > 2
      topt = topoint3f
      PtType = Point3f
    end
  else # A set of points (complex or array)
    p0s = collect(obs_p0[])
    if p0s[1] isa Array && length(p0s[1]) > 2
      topt = topoint3f
      PtType = Point3f
    end
  end
  nvals = length(p0s) # Number of inital values

  # Plot keyword arguments
  nits = plt.iterations[]
  nhits = plt.hidediterations[]
  clrn = plt.coloring[]

  # Hided iterations, not to to be drawn
  if nhits > 0 
    for k in 1:nvals
      for n in 1:nhits
        p0s[k] = f(p0s[k])
      end
    end
  end

  # Initial observable arrays for interaction
  obs_pns = [ Observable( PtType[] ) for k in 1:nvals ]
  for k in 1:nvals
    push!(obs_pns[k][], topt(p0s[k]) )
  end

  # Iterations, to be drawn
  for k in 1:nvals
    kps = obs_pns[k][]
    for n in 1:nits
      p0s[k] = f(p0s[k])
      push!(kps, topt(p0s[k]) ) # Saving array of PointNf
    end
  end

  # Coloring
  funcolor = k::Int -> RGBA(0,0,0) # Default
  if haskey(plt, :color)
    funcolor = k::Int -> plt.color[] # Unique
  end
  if clrn == :orbit
    pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
    cm = pltcm isa Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)
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

  # Drawing the iterations
  #obs_tns = Observable( nhits:(nhits+nits) )

  for k in 1:nvals
    scatterlines!(plt, obs_pns[k];
      plt.attributes.attributes..., color = funcolor(k))
  end

  plt 
end


#=
function drawpointorbitR2(f::Function, x0::Real, y0::Real;
    preiterations::Integer=0, iterations::Integer=100)

    # Verifying functions
    #@assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    xn,yn = x0,y0

    for n in 1:preiterations
        xn,yn = f(xn,yn)
    end # for n preiterations

    for n in 1:iterations
        if SDDGraphics.insiderectregion(xn,yn)
            SDDGraphics.color(n)
            SDDGraphics.drawpoint(xn,yn)
        end # if
        xn,yn = f(xn,yn)
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitR2
=#

#=
"""
    drawpointorbitR2(f, x0, y0 [; preiterations, iterations])

Return the drawing of the orbit of a point \$(x_0,y_0)\$ under a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

The orbit of \$(x_0,y_0)\$ under \$f\$ is defined as
    \$o(x_0,y_0,f)=\\{(x_0,y_0),f(x_0,y_0),\\dots,f^n(x_0,y_0),\\dots\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `x0::Real`: X coordinate of the point.
- `y0::Real`: Y coordinate of the point.
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
"""
function drawpointorbitR2(f::Function, x0::Real, y0::Real;
    preiterations::Integer=0, iterations::Integer=100)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    xn,yn = x0,y0

    for n in 1:preiterations
        xn,yn = f(xn,yn)
    end # for n preiterations

    for n in 1:iterations
        if SDDGraphics.insiderectregion(xn,yn)
            SDDGraphics.color(n)
            SDDGraphics.drawpoint(xn,yn)
        end # if
        xn,yn = f(xn,yn)
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitR2

"""
    drawpointssetorbitR2(f, ps [; preiterations, iterations])

Return the drawing of the orbit of a points set under a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

The orbit of the set \$P\$ under \$f\$ is defined as
    \$o(P,f)=\\bigcup_{n\\geq 0}f^n(P)\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `ps::Array{Tuple{Real,Real},1}`: The set of points (array of pairs of real numbers).
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
"""
function drawpointssetorbitR2(f::Function, ps::Array{Tuple{T,T},1};
    preiterations::Integer=0, iterations::Integer=100) where T <: Real

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    pns = deepcopy(ps)

    for n in 1:preiterations
        for k in 1:length(pns)
            pns[k] = f(pns[k]...)
        end # for k pns
    end # for n preiterations

    for n in 1:iterations
        SDDGraphics.color(n)
        for k in 1:length(pns)
            if SDDGraphics.insiderectregion(pns[k]...)
                SDDGraphics.drawpoint(pns[k]...)
            end # if
            pns[k] = f(pns[k]...)
        end # for k pns
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitR2

"""
    drawpointorbitC(f, z0 [; preiterations, iterations])

Return the drawing of the orbit of a point \$z_0\$ under a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

The orbit of \$z_0\$ under \$f\$ is defined as
    \$o(z_0,f)=\\{z_0,f(z_0),\\dots,f^n(z_0),\\dots\\}\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `z0::Number`: The point.
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
"""
function drawpointorbitC(f::Function, z0::Number;
    preiterations::Integer=0, iterations::Integer=100)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    zn = z0

    for n in 1:preiterations
        zn = f(zn)
    end # for n preiterations

    for n in 1:iterations
        if SDDGraphics.insiderectregion(zn)
            SDDGraphics.color(n)
            SDDGraphics.drawpoint(zn)
        end #if
        zn = f(zn)
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitC

"""
    drawpointssetorbitC(f, ps [; preiterations, iterations])

Return the drawing of the orbit of a points set under a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

The orbit of the set \$P\$ under \$f\$ is defined as
    \$o(P,f)=\\bigcup_{n\\geq 0}f^n(P)\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `ps::Array{Number,1}`: The set of points (array of numbers).
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
"""
function drawpointssetorbitC(f::Function, ps::Array{T,1};
    preiterations::Integer=0, iterations::Integer=100) where T <: Number

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    pns = deepcopy(ps)

    for n in 1:preiterations
        pns = f.(pns)
    end # for n preiterations

    for n in 1:iterations
        SDDGraphics.color(n)
        for k in 1:length(pns)
            if SDDGraphics.insiderectregion(pns[k])
                SDDGraphics.drawpoint(pns[k])
            end # if
            pns[k] = f(pns[k])
        end # for k pns
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitR2

"""
    drawpointorbitpathR2(f, x0, y0 [; preiterations, iterations, kind])

Return the drawing of the orbit's path of a point \$(x_0,y_0)\$ under a function
\$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$.

The orbit of \$(x_0,y_0)\$ under \$f\$ is defined as
\$o(x_0,y_0,f)=\\{(x_0,y_0),f(x_0,y_0),\\dots,f^n(x_0,y_0),\\dots\\}\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `x0::Real`: X coordinate of the point.
- `y0::Real`: Y coordinate of the point.
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
- `kind::Symbol`: Kind of path: `:line` or `:arc`.
"""
function drawpointorbitpathR2(f::Function, x0::Real, y0::Real;
    preiterations::Integer=0, iterations::Integer=100, kind::Symbol=:line)

    drawsegment = SDDGraphics.drawlinesegment

    if kind == :arc
        SDDGraphics.supported(:drawarc)
        drawsegment = SDDGraphics.drawarc
    else
        SDDGraphics.supported(:drawlinesegment)
    end

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    xn0,yn0 = x0,y0

    for n in 1:preiterations
        xn0,yn0 = f(xn0,yn0)
    end # for n preiterations

    for n in 1:iterations
        xn1,yn1 = f(xn0,yn0)
        SDDGraphics.color(n)
        drawsegment(xn0,yn0,xn1,yn1)
        xn0,yn0 = xn1,yn1
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitpathR2

"""
    drawpointorbitpathC(f, z0 [; preiterations, iterations, kind])

Return the drawing of the orbit's path of a point \$z_0\$ under a function
\$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
in a rectangular region in \$\\mathbb{C}\$.

The orbit of \$z_0\$ under \$f\$ is defined as
\$o(z_0,f)=\\{z_0,f(z_0),\\dots,f^n(z_0),\\dots\\}\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `z0::Number`: The point.
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
- `kind::Symbol`: Kind of path: `:line` or `:arc`.
"""
function drawpointorbitpathC(f::Function, z0::Number;
    preiterations::Integer=0, iterations::Integer=100, kind::Symbol=:line)

    drawsegment = SDDGraphics.drawlinesegment

    if kind == :arc
        SDDGraphics.supported(:drawarc)
        drawsegment = SDDGraphics.drawarc
    else
        SDDGraphics.supported(:drawlinesegment)
    end

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    zn0 = z0

    for n in 1:preiterations
        zn0 = f(zn0)
    end # for n preiterations

    for n in 1:iterations
        zn1 = f(zn0)
        SDDGraphics.color(n)
        drawsegment(zn0,zn1)
        zn0 = zn1
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitpathC

"""
    drawpointorbitpathR(f, x0 [; preiterations, iterations])

Return the drawing of the orbit's arc-path of a point \$x_0\$ under a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

The orbit of \$x_0\$ under \$f\$ is defined as
\$o(x_0,f)=\\{x_0,f(x_0,\\dots,f^n(x_0,\\dots\\}\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `x0::Real`: X coordinate of the point.
- `preiterations::Integer`: Number of first iterations to calculate but not to draw.
- `iterations::Integer`: Number of iterations to calculate (after `preiterations`).
"""
function drawpointorbitpathR(f::Function, x0::Real;
    preiterations::Integer=0, iterations::Integer=100)

    SDDGraphics.supported(:drawarc)

    # Verifying functions
    @assert typeof(f(1.)) <: Real

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations)

    xn0 = x0

    for n in 1:preiterations
        xn0 = f(xn0)
    end # for n preiterations

    for n in 1:iterations
        xn1 = f(xn0)
        SDDGraphics.color(n)
        SDDGraphics.drawarc(xn0,0,xn1,0)
        xn0 = xn1
    end # for n iterations

    SDDGraphics.drawing()

end # function drawpointorbitpathR2

=#