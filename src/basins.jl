
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

"""
    drawbasinsYorkeR2(f, points [; hasescaped, maxiterations, tolerance])

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
function drawbasinsNYR2(f::Function, points::AbstractArray;
    SD::Int=2, MC::Int=600, BAP::Int=6, maxiterations::Int=100)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()

    num_points = length(points)
    num_colors = 2*num_points+1
    SDDGraphics.updatecolorarray(num_colors)

    assign_array = zeros(SDDGraphics.canvassize()) .- 1

    basin_count = 1

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        if assign_array[i,j] == -1
            xn,yn = x,y
            index = (basin_count * 2) + 1  # color 1 is reserved for the basin of ∞
            color_pixels = [(i,j)]
            🛑 = false
            while !🛑
                if xmin<=xn<=xmax && ymin<=yn<=ymax
                    # indices of the pixel on which the iteration lands
                    ii = floor(Int, ncols*(xn-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                    jj = floor(Int, nrows*(yn-ymin)/(ymax-ymin)) + 1
                    # if the pixel doesn't have an assigned color we assign it the 
                    if assign_array[ii,jj] == -1 # while the orbit meets uncolored boxes it just adds them to the list
                        push!(color_pixels,(ii,jj))
                        xn, yn = f(xn, yn)
                    elseif assign_array[ii,jj] == index # if the orbit meets itself we check if it isn't periodic
                        is_periodic = true
                        mcount = 0
                        periodic_orbit = [(ii,jj)]
                        full_circle = false # keep track of whether the orbit has met itself again
                        while is_periodic && (mcount < MC || !full_circle)
                            xn, yn = f(xn,yn)
                            ii = floor(Int, ncols*(xn-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                            jj = floor(Int, nrows*(yn-ymin)/(ymax-ymin)) + 1
                            if !((ii,jj) in color_pixels) || (xn < xmin || xmax<xn || yn < ymin || ymax < yn) # if it meets a box not in the orbit then it is not periodic
                                if mcount < MC  # if it meets a box not in the orbit before MC then it is not periodic
                                    is_periodic = false
                                    break
                                elseif assign_array[ii,jj] % 2 == 0 # if the routine encounters an attracting box the whole orbit is assigned to that basin
                                    for pix in color_pixels
                                        assign_array[pix[1],pix[2]] = assign_array[ii,jj]
                                    end
                                end

                            elseif (ii,jj) in periodic_orbit
                                full_circle = true
                            end

                            push!(periodic_orbit,(ii,jj))
                            mcount += 1
                        end
                        if is_periodic
                            for pix in color_pixels
                                assign_array[pix[1],pix[2]] = index
                            end
                            for pix in periodic_orbit
                                assign_array[pix[1],pix[2]] = index - 1
                            end
                            basin_count += 1
                            🛑 = true
                            break
                        end
                    else # if the orbit meets a box of some other color

                    end

                elseif abs(xn-(xmax-xmin)/2)>SD*(xmax-xmin) || abs(yn-(ymax-ymin)/2)>SD*(ymax-ymin)

                    for pix in color_pixels
                        assign_array[pix[1],pix[2]] = 0
                    end
                    🛑 = true
                    break

                end
            end
        end

        SDDGraphics.colorinterpolationbg(escapetime/maxiterations, index)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end # function drawtrappedpointsR2