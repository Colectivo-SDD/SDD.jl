
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
        real(zn),yn = x,y
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
    drawbasinsR2_NY(f [; SD, MC, BAP, maxiterations])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$.

The attracting (parabolic) basin of a periodic point \$(x_0,y_0)\$ of period
\$k\$ under \$f\$ is defined as
\$\\mathcal{B}(x_0,y_0)=\\{(x,y)\\in\\mathbb{R}^2\\,|\\,|(f^k)^n(x,y)|\\rightarrow (x_0,y_0)\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `SD::Int`: Number of screenwidths away from the origin before a point is considered to have escaped.
- `MC::Int`: Number of iterations used to verify whether an orbit is periodic.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawbasinsR2_NY(f::Function;
    SD::Int=2, MC::Int=60, BAP::Int=6, maxiterations::Int=100000)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    SDDGraphics.newdrawing()

    assign_array = zeros(Int8,SDDGraphics.canvassize()) .- 1

    basin_count = 1
    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        ii = i
        jj = j
        if assign_array[ii,jj] == -1
            xn,yn = x,y
            index = (basin_count * 2) + 1  # color 1 is reserved for the basin of ∞
            color_pixels = [(ii,jj)]
            🛑 = false # indicating whether routine has reached a stop point
            count_orbit = 0 # variable to keep track of repeating orbit
            ⭕️ = false # set to true once the routine changes for a periodic orbit
            iter_count = 0

            assign_array[ii,jj] = index

            while !🛑 && iter_count < maxiterations
                xn, yn = f(xn,yn)
                ii = floor(Int, ncols*(xn-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                jj = floor(Int, nrows*(yn-ymin)/(ymax-ymin)) + 1
                if xmin<=xn<=xmax && ymin<=yn<=ymax
                    # if the pixel doesn't have an assigned color we assign it the 
                    if assign_array[ii,jj] == -1 # while the orbit meets uncolored boxes it just adds them to the list
                        push!(color_pixels,(ii,jj))
                        count_orbit = 0
                        if !⭕️
                            assign_array[ii,jj] = index
                        else
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index
                        if !⭕️ && (count_orbit < MC)
                            count_orbit += 1
                        elseif !⭕️ && (count_orbit >= MC)
                            ⭕️ = true
                            count_orbit = 0
                            assign_array[ii,jj] = index - 1
                        else
                            count_orbit = 0  
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index - 1
                        count_orbit += 1
                        if count_orbit >= MC
                            basin_count += 1
                            🛑 = true
                            break
                        end
                    elseif !⭕️  && assign_array[ii,jj] % 2 == 1
                        for pix in color_pixels
                            assign_array[pix[1],pix[2]] = assign_array[ii,jj]
                        end
                        🛑 = true
                        break
                    elseif assign_array[ii,jj] % 2 == 0
                        for pix in color_pixels
                            assign_array[pix[1],pix[2]] = assign_array[ii,jj] + 1
                        end
                        🛑 = true
                        break
                    end
                
                elseif abs(xn-(xmax-xmin)/2)>SD*(xmax-xmin) || abs(yn-(ymax-ymin)/2)>SD*(ymax-ymin)

                    for pix in color_pixels
                        assign_array[pix[1],pix[2]] = 1
                    end
                    🛑 = true
                    break
                end
                iter_count += 1
            end
        end
    end # Implemented algorithm
    SDDGraphics.updatecolorarray(basin_count*2 + 1)
    for i in 1:SDDGraphics.canvassize()[1]
        for j in 1:SDDGraphics.canvassize()[2]
            SDDGraphics.color(assign_array[i,j])
            SDDGraphics.drawpixel(i,j)
        end
    end
    SDDGraphics.drawing()
end # function drawtrappedpointsR2

"""
    drawbasinsC_NY(f [; SD, MC, BAP, maxiterations])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
in a rectangular region in \$\\mathbb{C}\$.

The attracting (parabolic) basin of a periodic point \$z_0\$ of period
\$k\$ under \$f\$ is defined as
\$\\mathcal{B}(z_0)=\\{z\\in\\mathbb{C}\\,|\\,|(f^k)^n(z)|\\rightarrow z_0\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `SD::Int`: Number of screenwidths away from the origin before a point is considered to have escaped.
- `MC::Int`: Number of iterations used to verify whether an orbit is periodic.
- `BAP::Int`: Number of iterations used to verify whether an orbit falls in another basin.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawbasinsC_NY(f::Function;
    SD::Int=2, MC::Int=60, BAP::Int=6, maxiterations::Int=100000)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(.1im)) <: Number

    SDDGraphics.newdrawing()

    assign_array = zeros(Int8,SDDGraphics.canvassize()) .- 1

    basin_count = 1
    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        ii = i
        jj = j
        if assign_array[ii,jj] == -1
            zn = complex(x,y)
            index = (basin_count * 2) + 1  # color 1 is reserved for the basin of ∞
            color_pixels = [(ii,jj)]
            🛑 = false # indicating whether routine has reached a stop point
            count_orbit = 0 # variable to keep track of repeating orbit
            ⭕️ = false # set to true once the routine changes for a periodic orbit
            iter_count = 0

            assign_array[ii,jj] = index

            while !🛑 && iter_count < maxiterations
                zn = f(zn)
                ii = floor(Int, ncols*(real(zn)-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                jj = floor(Int, nrows*(imag(zn)-ymin)/(ymax-ymin)) + 1
                if xmin<=real(zn)<=xmax && ymin<=imag(zn)<=ymax
                    # if the pixel doesn't have an assigned color we assign it the 
                    if assign_array[ii,jj] == -1 # while the orbit meets uncolored boxes it just adds them to the list
                        push!(color_pixels,(ii,jj))
                        count_orbit = 0
                        if !⭕️
                            assign_array[ii,jj] = index
                        else
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index
                        if !⭕️ && (count_orbit < MC)
                            count_orbit += 1
                        elseif !⭕️ && (count_orbit >= MC)
                            ⭕️ = true
                            count_orbit = 0
                            assign_array[ii,jj] = index - 1
                        else
                            count_orbit = 0  
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index - 1
                        count_orbit += 1
                        if count_orbit >= MC
                            basin_count += 1
                            🛑 = true
                            break
                        end
                    elseif !⭕️  && assign_array[ii,jj] % 2 == 1
                        for pix in color_pixels
                            assign_array[pix[1],pix[2]] = assign_array[ii,jj]
                        end
                        🛑 = true
                        break
                    elseif assign_array[ii,jj] % 2 == 0
                        for pix in color_pixels
                            assign_array[pix[1],pix[2]] = assign_array[ii,jj] + 1
                        end
                        🛑 = true
                        break
                    end
                
                elseif abs(real(zn)-(xmax-xmin)/2)>SD*(xmax-xmin) || abs(imag(zn)-(ymax-ymin)/2)>SD*(ymax-ymin)

                    for pix in color_pixels
                        assign_array[pix[1],pix[2]] = 1
                    end
                    🛑 = true
                    break
                end
                iter_count += 1
            end
        end
    end # Implemented algorithm
    SDDGraphics.updatecolorarray(basin_count*2 + 1)
    for i in 1:SDDGraphics.canvassize()[1]
        for j in 1:SDDGraphics.canvassize()[2]
            SDDGraphics.color(assign_array[i,j])
            SDDGraphics.drawpixel(i,j)
        end
    end
    SDDGraphics.drawing()
end # function drawtrappedpointsR2