
"""
    drawpreimageR2(f [; iterations])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
    in a rectangular region in \$\\mathbb{R}^2\$.

Using the a color map function \$c:\\mathbb{R}^2\\rightarrow Colors\$,
is drawn \$c\\circ f^n(x,y)\$ for \$(x,y)\$ in the rectangular region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `iterations::Integer`: Number of iterations.
"""
function drawpreimageR2(f::Function; iterations::Int=1)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterativeR2 f iterations
    fn = foriterativeR2(f,iterations)
    #fn = SDDCore.composeR2(f,iterations) # doesn't exists... yet

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        SDDGraphics.color(fn(x,y)...)
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end


"""
    drawpreimageC(f [; iterations])

Return the drawing of the preimage of the \$n\$-iterative of a function
    \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$,
    in a rectangular region in \$\\mathbb{C}\$.

Using the a color map function \$c:\\mathbb{C}\\rightarrow Colors\$,
is drawn \$c\\circ f^n(z)\$ for \$z\$ in the rectangulr region.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$.
- `iterations::Integer`: Number of iterations.
"""
function drawpreimageC(f::Function; iterations::Int=1)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawpixel)

    # Verifying functions
    @assert typeof(f(1.0im)) <: Number

    @assert iterations > 0

    SDDGraphics.newdrawing()
    SDDGraphics.updatecolorarray(iterations+1)

    #fn = @iterative f iterations
    #fn = foriterative(f,iterations)
    fn = SDDCore.compose(f,iterations)

    @sweeprectregion SDDGraphics.xlims() SDDGraphics.ylims() SDDGraphics.canvassize() begin
        SDDGraphics.color(fn(complex(x,y)))
        SDDGraphics.drawpixel(i,j)
    end # Implemented algorithm

    SDDGraphics.drawing()
end
