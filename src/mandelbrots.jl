
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
