
"""
    plot(f [; iterations, identity])

Plot the graph of the \$n\$-th iterative of a function
\$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `iterations::Int`: Number of iterations to calculate the iterative \$f^n\$.
- `identity::Bool`: Draw the identity graph if true.
"""
function plot(f::Function; iterations::Int=1, identity::Bool=true)
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @assert typeof(f(1.)) <: Real

    SDDGraphics.newdrawing()

    x1, x2 = SDDGraphics.xlims()
    w = SDDGraphics.width()
    Δx = (x2-x1)/w

    # Plot the graph of the identity
    if identity
        clr = SDDGraphics.color()
        SDDGraphics.color(RGB(0.5,0.5,0.5))
        y1, y2 = SDDGraphics.ylims()
        xmin = min(x1,y1)
        xmax = max(x2,y2)
        SDDGraphics.drawlinesegment(xmin,xmin,xmax,xmax)
        SDDGraphics.color(clr) # Restate the "current" color
    end

    xi0 = x1
    yi0 = xi0
    for n in 1:iterations
        yi0 = f(yi0)
    end

    for i in 1:w
        xi1 = x1 + i*Δx
        yi1 = xi1
        for n in 1:iterations
            yi1 = f(yi1)
        end
        SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
        xi0, yi0 = xi1, yi1
    end

#= ToDo: Con compose queda así :-)
fn = compose(f,iteraions)

xi0, yi0 = x1, fn(x1)
for i in 0:w
    xi1 = x1 + i*Δx
    yi1 = fn(xi1)
    SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
    xi0, yi0 = xi1, yi1
end
=#
    SDDGraphics.drawing()
end

"""
    graphicalanalysis(f, x0 [; iterations])

Plot the graph of a function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$ and
the the graphical analysis of the orbit of \$x_0\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{R}\\rightarrow\\mathbb{R}\$.
- `x0::Real`: Initial point for the orbit.
- `iterations::Int`: Number of iterations to calculate the orbit of \$x_0\$.
- `identity::Bool`: Draw the identity graph if true.
"""
function graphicalanalysis(f::Function, x0::Real;
    iterations::Int=10, identity=true, basepoint=true)
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @assert typeof(f(1.)) <: Real

    SDDGraphics.newdrawing()

    x1, x2 = SDDGraphics.xlims()
    y1, y2 = SDDGraphics.ylims()
    w = SDDGraphics.width()
    Δx = (x2-x1)/w

    # Plot of the function's graph
    clr = SDDGraphics.color()
    xi0 = x1
    yi0 = f(x1)
    for i in 1:w
        xi1 = x1 + i*Δx
        yi1 = f(xi1)
        SDDGraphics.drawlinesegment(xi0,yi0,xi1,yi1)
        xi0, yi0 = xi1, yi1
    end

    # Plot the graph of the identity
    if identity
        SDDGraphics.color(RGB(0.5,0.5,0.5))
        xi0 = min(x1,y1)
        xi1 = max(x2,y2)
        SDDGraphics.drawlinesegment(xi0,xi0,xi1,xi1)
    end

    # Graphical analysis of the orbit of x0
    SDDGraphics.color(RGB(1,0,0))

    if basepoint
        SDDGraphics.drawlinesegment(x0,0,x0,x0)
    end

    xi0 = x0
    for i in 1:iterations
        yi0 = f(xi0)
        SDDGraphics.drawlinesegment(xi0,xi0,xi0,yi0)
        SDDGraphics.drawlinesegment(xi0,yi0,yi0,yi0)
        xi0 = yi0
    end

    SDDGraphics.color(clr) # Restate the "current" color

    SDDGraphics.drawing()
end
