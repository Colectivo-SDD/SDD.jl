function drawbasinsR2(f::Function, fixed::Array{Tuple{T}{T},1}; 
    iterations::Integer = 100, tolerance = 0.001) where T <: Real

    # Verifying function
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}

    # Create new drawing 
    SDDGraphics.newdrawing()
    # We need as many colors as attracting/parabolic points plus a color for diverging points (the attracting basin of infinity if it's the case)
    SDDGraphics.updatecolorarray(length(fixed))

    

end