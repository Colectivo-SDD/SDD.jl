
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
