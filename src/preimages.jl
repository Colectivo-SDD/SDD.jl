
"""
    drawpreimageR2(f [; iterations, hasescaped])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

Using the a color map function \$c:\\mathbb{R}^2\\rightarrow Colors\$,
is drawn \$c\\circ f^n(x,y)\$ for \$(x,y)\$ in the rectangular region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `iterations::Integer`: Number of iterations.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
"""
function drawpreimageR2(f::Function; iterations::Int=1, hasescaped::Function=(x::Real,y::Real) -> x*x+y*y > 4)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterativeR2 f iterations
    #fn = foriterativeR2(f,iterations)
    #fn = SDDCore.composeR2(f,iterations) # doesn't exists... yet

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        xn,yn = x,y
        for n in 1:iterations
            if hasescaped(xn,yn)
                break
            end # if
            xn,yn = f(xn,yn)
        end # for iterations
        #SDDGraphics.color(fn(x,y)...)
        SDDGraphics.color(xn,yn)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end


"""
    drawpreimageC(f [; iterations, hasescaped])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

Using the a color map function \$c:\\mathbb{C}\\rightarrow Colors\$,
is drawn \$c\\circ f^n(z)\$ for \$z\$ in the rectangulr region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `iterations::Integer`: Number of iterations.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
"""
function drawpreimageC(f::Function; iterations::Int=1, hasescaped::Function=z::Number -> abs2(z) > 4)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterative f iterations
    #fn = foriterative(f,iterations)
    #fn = SDDCore.compose(f,iterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        zn = complex(x,y)
        for n in 1:iterations
            if hasescaped(zn)
                break
            end # if
            zn = f(zn)
        end # for iterations
        SDDGraphics.color(zn)
        #SDDGraphics.color(fn(complex(x,y)))
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end


"""
    drawpreimageperiodicsR2(f [; iterations, hasescaped])

Return the drawing of the preimage of the fixed points of the \$n\$-iterative of a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

Using the a color map function \$c:\\mathbb{R}^2\\rightarrow Colors\$,
is drawn \$c\\circ f^n(x,y)\$ for \$(x,y)\$ in the rectangular region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `iterations::Integer`: Number of iterations.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
"""
function drawpreimageperiodicsR2(f::Function; iterations::Int=1, hasescaped::Function=(x::Real,y::Real) -> x*x+y*y > 4)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        xn,yn = x,y
        for n in 1:iterations
            if hasescaped(xn-x,yn-y)
                break
            end # if
            xn,yn = f(xn,yn)
        end # for iterations
        SDDGraphics.color(xn-x, yn-y)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end


"""
    drawpreimageC(f [; iterations, hasescaped])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

Using the a color map function \$c:\\mathbb{C}\\rightarrow Colors\$,
is drawn \$c\\circ f^n(z)\$ for \$z\$ in the rectangulr region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `iterations::Integer`: Number of iterations.
- `hasescaped::Function`: A boolean function to check if the iterations has escaped.
"""
function drawpreimageperiodicsC(f::Function; iterations::Int=1, hasescaped::Function=z::Number -> abs2(z) > 4)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        z = complex(x,y)
        zn = z
        for n in 1:iterations
            if hasescaped(zn - z)
                break
            end # if
            zn = f(zn)
        end # for iterations
        SDDGraphics.color(zn - z)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end
