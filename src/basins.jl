
"""
    drawbasinsR2(f, points [; hasescaped, maxiterations, tolerance])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$.

The attracting (parabolic) basin of a periodic point \$(x_0,y_0)\$ of period
\$k\$ under \$f\$ is defined as
\$\\mathcal{B}(x_0,y_0)=\\{(x,y)\\in\\mathbb{R}^2\\,|\\,|(f^k)^n(x,y)|\\rightarrow (x_0,y_0)\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `points::AbstractArray`: List of points \$(x,y)\$ assumning to be peridic attrating or parabolic.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped (useful for the infinity basin).
- `maxiterations::Integer`: Maximum number of iterations to check.
- `tolerance::Real`: Small number to check closeness to given points.
"""
function drawbasinsR2(f::Function, points::AbstractArray;
    hasescaped::Function=(x,y)->false, maxiterations::Int=100, tolerance::Real=1.0e-6)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}
    @assert typeof(hasescaped(1., 1.)) <: Bool

    SDDGraphics.newdrawing()

    num_points = length(points)
    num_colors = num_points+1
    SDDGraphics.updatecolorarray(num_colors)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        xn,yn = x,y
        escapetime = maxiterations
        index = num_colors
        for n in 1:maxiterations
            for k in 1:num_points
                if (points[k][1]-xn)^2 + (points[k][2]-yn)^2 < tolerance
                    index = k
                    break
                end
            end
            if index < num_colors
                escapetime = n
                break
            end
            if hasescaped(xn,yn)
                escapetime = n
                index = num_colors
                break
            end # if hasescaped
            xn,yn = f(xn,yn)
        end # for n maxiterations
        SDDGraphics.colorinterpolationbg(escapetime/maxiterations, index)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end # function drawtrappedpointsR2


"""
    drawbasinsC(f, points [; hasescaped, maxiterations, tolerance])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
in a rectangular region in \$\\mathbb{C}\$.

The attracting (parabolic) basin of a periodic point \$z_0\$ of period
\$k\$ under \$f\$ is defined as
\$\\mathcal{B}(z_0)=\\{z\\in\\mathbb{C}\\,|\\,|(f^k)^n(z)|\\rightarrow z_0\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `points::AbstractArray`: List of complex numbers \$z\$ assumning to be peridic attrating or parabolic.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped (useful for the infinity basin).
- `maxiterations::Integer`: Maximum number of iterations to check.
- `tolerance::Real`: Small number to check closeness to given points.
"""
function drawbasinsC(f::Function, points::AbstractArray;
    hasescaped::Function=z->false, maxiterations::Int=100, tolerance::Real=1.0e-6)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(.1im)) <: Number
    @assert typeof(hasescaped(.1im)) <: Bool

    SDDGraphics.newdrawing()

    num_points = length(points)
    num_colors = num_points+1
    SDDGraphics.updatecolorarray(num_colors)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        zn = complex(x,y)
        escapetime = maxiterations
        index = num_colors
        for n in 1:maxiterations
            for k in 1:num_points
                if abs2(points[k]-zn) < tolerance
                    index = k
                    break
                end
            end
            if index < num_colors
                escapetime = n
                break
            end
            if hasescaped(zn)
                escapetime = n
                index = num_colors
                break
            end # if hasescaped
            zn = f(zn)
        end # for n maxiterations
        SDDGraphics.colorinterpolationbg(escapetime/maxiterations, index)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end # function drawtrappedpointsR2
