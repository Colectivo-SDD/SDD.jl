

"""
Create a function to return the nth-preimage asociated value for the color map.
"""
function createbasinsval(f::Function, points::Vector; topoint::Function,
    hasescaped::Function=p->false, maxiterations::Int=100, tolerance::Real=1.0e-12)
  return function preimageval(x::Real, y::Real)
    p = topoint(x,y)
    for n in 0:maxiterations
      if hasescaped(p)
        return 0.0
      end
      for k in 1:length(points)
        if abs2(p-points[k]) < tolerance
          return (k/length(points))*(1.0-n/maxiterations)
        end
      end
      p = f(p)
    end
    0.0
  end
end


"""
Return a matrix of basins values.
"""
function matrixbasins(f::Function, points::Vector, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function=p->false, maxiterations::Int=100, tolerance::Real=1.0e-12,
  value::Function=k::Real->k, rot90::Bool=false)

  basval = createbasinsval(f, points, topoint=createtopoint2D(functionkind2D(f)),
    hasescaped=hasescaped, maxiterations=maxiterations, tolerance=tolerance)

  W, H = length(xs), length(ys)
  mtrx = rot90 ? fill(value(0.0), H, W) : fill(value(0.0), W, H)

  if rot90
    _ys = Base.reverse(ys)
    for h in 1:H
      for w in 1:W
        mtrx[h,w] = value(basval(xs[w],_ys[h]))
      end
    end
  else
    for h in 1:H
      for w in 1:W
        mtrx[w,h] = value(basval(xs[w],ys[h]))
      end
    end
  end

  mtrx
end


"""
    imgbasins(f, xs, ys, points [; maxiterations, hasescaped, tolerance, colormap])

Return an image with the drawing of the basins of attraction of givn points of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$.

A basin of attraction of a fixed point \$p_0\$ is

\$\\{p\\,|\\,\\lim_{n\\rigtharrow\\infty}f^n(p)=p_0\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
- `points::AbstractVector=[]`: List of attracting points to drawn its basins.
#### Keyword arguments
- `maxiterations::Integer`: Maximum number of iterations to calculate \$f^n(p)\$.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `tolerance::Real`: A small real number to determine the closeness of \$f^n(p)\$ to an attractor.
- `colormap`: Color map for the coloring function.
"""
function imgbasins(f::Function, points::Vector, xs::AbstractVector{<:Real}, ys::AbstractVector{<:Real};
  hasescaped::Function = p->false, maxiterations::Int = 100, tolerance::Real=10.e-12,
  colormap::Union{Symbol, Vector{<:Colorant}} = :viridis)

  cm = typeof(colormap) == Symbol ? colorschemes[colormap] : ColorScheme(colormap)
  #cm = [ cs[k/maxiterations] for k in 0.0:maxiterations ]

  matrixbasins(f, points, xs, ys; hasescaped=hasescaped, maxiterations=maxiterations,
    tolerance=tolerance, value=k::Real->cm[k], rot90=true)
end


"""
    basins(f, xs, ys, points, [; maxiterations, hasescaped, tolerance, plotstyle])

Return a **Makie** plot with the drawing of the basins of attraction of given points of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region \$[x_{min},x_{max}]\\times[y_{min},y_{max}]\$.

A basin of attraction of a fixed point \$p_0\$ is

\$\\{p\\,|\\,\\lim_{n\\rigtharrow\\infty}f^n(p)=p_0\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{<:Real}`: Base \$x\$ coordinates for the rectangular region.
- `ys::AbstractVector{<:Real}`: Base \$y\$ coordinates for the rectangular region.
- `points::AbstractVector=[]`: List of attracting points to drawn its basins.
#### Keyword arguments
- `maxiterations::Integer`: Maximum number of iterations to calculate \$f^n(p)\$.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
- `tolerance::Real`: A small real number to determine the closeness of \$f^n(p)\$ to an attractor.
- `plotstyle::Symbol`: Plot style `:heatmap` or `:image`.
"""
@recipe(Basins) do scene
  Attributes(
    maxiterations = 100,
    hasescaped = p -> false,
    tolerance = 1.0e-12,
    plotstyle = :heatmap
  )
end

function Makie.plot!(plt::Basins{<:Tuple{Function, Vector, <:AbstractVector{<:Real}, <:AbstractVector{<:Real}}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  obs_pts = plt[2]
  pts = obs_pts[] # List of points
  obs_xs = plt[3]
  xs = obs_xs[]
  obs_ys = plt[4]
  ys = obs_ys[]

  if isempty(pts)
    #calculate attractive and parabolic fixed points...
  end

  # Plot keyword arguments
  maxits = plt.maxiterations[]
  he = plt.hasescaped[]  
  tol = plt.tolerance[]
  pltsty = plt.plotstyle[]  

  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :hasescaped)
  delete!(plt.attributes.attributes, :tolerance)
  delete!(plt.attributes.attributes, :plotstyle)

  # Makie's Plot
  if pltsty == :image
    pltcm = haskey(plt.attributes.attributes, :colormap) ? plt.colormap[] : :viridis
    cm = typeof(pltcm) == Symbol ? colorschemes[pltcm] : ColorScheme(pltcm)

    image!(plt, obs_xs, obs_ys,
      matrixbasins(f, pts, xs, ys, hasescaped=he, maxiterations=maxits,
        tolerance=tol, value=k::Real->cm[k] );
      plt.attributes.attributes...)
  else
    heatmap!(plt, obs_xs, obs_ys,
      createbasinsval(f, pts, topoint=createtopoint2D(functionkind2D(f)),
        hasescaped=he, maxiterations=maxits, tolerance=tol);
      plt.attributes.attributes...)
  end

  plt
end


"""
    ibasins([g,] f, xs, ys, points, [; maxiterations, hasescaped, tolerance])

Same as `basins`, but using **InteractiveViz**.
"""
ibasins(f::Function, points, xs, ys; maxiterations::Int=100, hasescaped::Function=p->false,
  tolerance=1.0e-12, kwargs...) =
  iheatmap( createbasinsval( f, points, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, tolerance=tolerance),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)
ibasins(g, f::Function, points, xs, ys; maxiterations::Int=100, hasescaped::Function=p->false,
  tolerance=1.0e-12, kwargs...) =
  iheatmap(g, createbasinsval( f, points, topoint=createtopoint2D(functionkind2D(f)),
      hasescaped=hasescaped, maxiterations=maxiterations, tolerance=tolerance),
    xs[1], xs[end], ys[1], ys[end];
    kwargs...)


#=
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
    drawbasinsR2_BAP(f [; SD, MC, BAP, maxiterations])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$, using the BAP method described by Nusse & Yorke (1994).

The attracting (parabolic) basin of a periodic point \$(x_0,y_0)\$ of period
\$k\$ under \$f\$ is defined as
\$\\mathcal{B}(x_0,y_0)=\\{(x,y)\\in\\mathbb{R}^2\\,|\\,|(f^k)^n(x,y)|\\rightarrow (x_0,y_0)\\,n\\rightarrow\\infty\\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `SD::Int`: Number of screenwidths away from the origin before a point is considered to have escaped.
- `MC::Int`: Number of iterations used to verify whether an orbit is periodic.
- `maxiterations::Integer`: Maximum number of iterations to check.
"""
function drawbasinsR2_BAP(f::Function;
    SD::Int=2, MC::Int=60, BAP::Int=1, maxiterations::Int=100000)

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
        if assign_array[ii,jj] == -1 # we leave the pixel as is if it is already colored
            xn,yn = x,y
            index = (basin_count * 2) + 1  # color 1 is reserved for the basin of ∞
            color_pixels = [(ii,jj)]
            🛑 = false # indicating whether routine has reached a stop point
            count_orbit = 0 # variable to keep track of repeating orbit
            ⭕️ = false # set to true once the routine changes for a periodic orbit
            iter_count = 0 #
            BAP_count = 0

            assign_array[ii,jj] = index # provisionally color the pixel with index

            while !🛑 && iter_count < maxiterations
                xn, yn = f(xn,yn) # take next iteration
                ii = floor(Int, ncols*(xn-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                jj = nrows - floor(Int, nrows*(yn-ymin)/(ymax-ymin)) # the minus is due to the way the @sweeprectregion macro works
                if xmin<=xn<=xmax && ymin<=yn<=ymax # if the point is within the canvas
                    if assign_array[ii,jj] == -1 # if pixel is uncolored
                        push!(color_pixels,(ii,jj)) # add it to list 
                        count_orbit = 0 # not consecutive index or index-1
                        BAP_count = 0 # not consecutive other color
                        if !⭕️
                            assign_array[ii,jj] = index 
                        else
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index # if pixel is already colored index
                        BAP_count = 0
                        if !⭕️ && (count_orbit < MC) # not yet enough consecutive index-colored pixels
                            count_orbit += 1
                        elseif !⭕️ && (count_orbit >= MC)
                            ⭕️ = true
                            count_orbit = 0
                            assign_array[ii,jj] = index - 1
                        else # routine is already in periodic orbit mode
                            count_orbit = 0  
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index - 1 # if pixel is already colored (index-1) this means it is in periodic attracting orbit
                        BAP_count = 0
                        count_orbit += 1 # in this case count_orbit gets reused for to count consecutive (index-1)-colored pixels
                        if count_orbit >= MC
                            basin_count += 1
                            🛑 = true
                            break
                        end
                    elseif !⭕️  && assign_array[ii,jj] % 2 == 1 # if pixel is colored as the basin for some other attracting orbit
                        BAP_count += 1 # orbit must meet BAP consecutive of these 
                        if BAP_count>=BAP
                            for pix in color_pixels
                                assign_array[pix[1],pix[2]] = assign_array[ii,jj]
                            end
                            🛑 = true
                            break
                        end
                    elseif assign_array[ii,jj] % 2 == 0 # if orbit encounters a pixel identified as another attracting orbit
                        for pix in color_pixels
                            assign_array[pix[1],pix[2]] = assign_array[ii,jj] + 1
                        end
                        🛑 = true
                        break
                    end
                
                elseif abs(xn-(xmax-xmin)/2)>SD*(xmax-xmin) || abs(yn-(ymax-ymin)/2)>SD*(ymax-ymin) # if point is SD screens away from the center of interest region it is colored as the basin of ∞

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
            SDDGraphics.drawpixel(i,SDDGraphics.canvassize()[1]-j+1) # due to how everything is defined abobe the y axis needs to be inverted...
        end
    end
    SDDGraphics.drawing()
end # function drawtrappedpointsR2

"""
    drawbasinsC_BAP(f [; SD, MC, BAP, maxiterations])

Return the drawing of the attracting or parabolic basins of given periodic
points of a function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
in a rectangular region in \$\\mathbb{C}\$, using the BAP method described by Nusse & Yorke (1994).

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
function drawbasinsC_BAP(f::Function;
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
            BAP_count = 0

            assign_array[ii,jj] = index

            while !🛑 && iter_count < maxiterations
                zn = f(zn)
                ii = floor(Int, ncols*(real(zn)-xmin)/(xmax-xmin)) + 1 # plus one since index starts at one
                jj = nrows-floor(Int, nrows*(imag(zn)-ymin)/(ymax-ymin))
                if xmin<=real(zn)<=xmax && ymin<=imag(zn)<=ymax
                    # if the pixel doesn't have an assigned color we assign it the 
                    if assign_array[ii,jj] == -1 # while the orbit meets uncolored boxes it just adds them to the list
                        push!(color_pixels,(ii,jj))
                        count_orbit = 0
                        BAP_count = 0
                        if !⭕️
                            assign_array[ii,jj] = index
                        else
                            assign_array[ii,jj] = index - 1
                        end
                    elseif assign_array[ii,jj] == index
                        BAP_count = 0
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
                        BAP_count = 0
                        count_orbit += 1
                        if count_orbit >= MC
                            basin_count += 1
                            🛑 = true
                            break
                        end
                    elseif !⭕️  && assign_array[ii,jj] % 2 == 1
                        if BAP_count<BAP
                            BAP_count += 1
                        else
                            for pix in color_pixels
                                assign_array[pix[1],pix[2]] = assign_array[ii,jj]
                            end
                            🛑 = true
                            break
                        end
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
            SDDGraphics.drawpixel(i,SDDGraphics.canvassize()[1]-j+1)
        end
    end
    SDDGraphics.drawing()
end # function drawtrappedpointsR2

=#