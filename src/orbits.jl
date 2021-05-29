
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
    drawpointorbitpathR(f, x0, y0 [; preiterations, iterations])

Return the drawing of the orbit's arc-path of a point \$x_0\$ under a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

The orbit of \$x_0\$ under \$f\$ is defined as
\$o(x_0,f)=\\{x_0,f(x_0,\\dots,f^n(x_0,\\dots\\}\$.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `x0::Real`: X coordinate of the point.
- `y0::Real`: Y coordinate of the point.
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
