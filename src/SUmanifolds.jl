using LinearAlgebra: norm2
using ForwardDiff
using LinearAlgebra
using Printf

function convertToVectorFunction(f::Function)
    function fnew(v::Vector{T}) where T <: Real
      x,y = f(v...)
      [x,y]
    end
  end

# Function to iterate function f 2*m times. This is a bang function because it modifies the vector x.
function iter_f!(x::Vector, m::Int, f::Function)
    for i in 1:(2*m) # Second iterate assures manifold stays on same side
        fx = f(x)
        [x[i] = fx[i] for i in 1:length(x)]
    end
end

# Function to check wether a given point is within the boundaries of the extended screen (region of interest)
function inScreen(y::Vector, extendedScreen::Vector)
    return !(y[1]<extendedScreen[1] || y[2]<extendedScreen[3] || y[1]>extendedScreen[2] || y[2]>extendedScreen[4])
end

# This function returns a vector of points which trace out the unstable manifold of a function f according to the method of You, Kostelich & Yorke (1991).
function getUnstableManifoldR2(f::Function, p_fix::Vector;
    SD::Float64 = 0.5, n::Int = 6, minJump::Real = 1e-6, maxJump::Real = 1e-3, minStep::Real = 1e-16, ds::Real = 1e-5)

    ΔX = SD*(SDDGraphics.xlims()[2] - SDDGraphics.xlims()[1])
    ΔY = SD*(SDDGraphics.ylims()[2] - SDDGraphics.ylims()[1])
    extendedScreen = [SDDGraphics.xlims()[1] - ΔX, SDDGraphics.xlims()[2] + ΔX, SDDGraphics.ylims()[1] - ΔY, SDDGraphics.ylims()[2] + ΔY]

    # Derivative is only used to find direction of unstable manifold
    D_F = x->ForwardDiff.jacobian(f,x)
    
    D_eigen = eigen(D_F(p_fix), sortby = abs)
    (abs(D_eigen.values[2])>=1.) ? du = normalize(D_eigen.vectors[:,2]) : error("The fixed point must be a saddle point")

    Δp = du ./ 1000
    a⁺ = p_fix .+ Δp
    a⁻ = p_fix .- Δp


    # Function used to calculate relative distance between y = G(s) and yc = G(s + ds)
    function ychange!(s::Float64, y::Vector, yc::Vector, m::Int)
        # first we set yc equal to the next point in the segment we are iterating
        [yc[i] = p_fix[i] + (s*Δp[i]) for i in 1:2]
        # then we apply f to yc 2*m times
        iter_f!(yc, m, f)
        # and get the difference
        dif = max(abs(y[1]-yc[1])/ΔX, abs(y[2]-yc[2])/ΔY)
        # dif cannot be smaller than minJump
        return max(dif, minJump)
    end

    # Revise makes sure the step ds is greater than minStep but the jump it determines in the image is smaller than maxJump
    function revise(s::Float64, ds::Float64, y::Vector, yc::Vector, m::Int)
        prev = deepcopy(ds)
        # while the jump satisfies some conditions keep cutting is in half
        while ((delta = ychange!(s+ds,y,yc,m)) > maxJump || (ds *= 0.2 + 0.8/delta) <= prev * 0.5) && ds > minStep
            ds = prev = prev * 0.5
        end
        ds = min(ds, prev * 2.0)
        return max(ds, minStep)
    end

    # This function takes y which, if m != 0, is assumed to be the m th iterate of the function f^2. Otherwise if m == 0, or the point y lies outside the extended screen, we assign to y the value of γ(s) point on the line segment and set m = 0. The function then proceeds to iterate y as long as the number of iterations is less than or equal to n and each iteration stays within the extended screen. 
    # The function returns the max(m∈N | m ≤ n & ∀k ≤ m, inScreen(iter!(y, k, f))). It also sets the value of y to the m th iterate of f^2.
    function iterate!(s::Float64, y::Vector, m::Int, n::Int)
        if m==0 || !inScreen(y, extendedScreen)
            [y[i] = p_fix[i] + s*Δp[i] for i in 1:2]
            m = 0
        end
        prev = deepcopy(y)
        cont = true
        if m<n 
            while true
                iter_f!(y, 1, f)
                if (cont = inScreen(y, extendedScreen))
                    prev = deepcopy(y)
                    m+=1
                else
                    [y[i] = prev[i] for i in 1:2]
                end
                (cont && m<n) || break
            end
        end
        return m
    end

    OK = false
    m = 0
    y = [0.0, 0.0]
    yc = [0.0, 0.0]
    s = 0.0

    dsog = ds

    yList = []

    count = 0
    while s < 1.
        ds = dsog
        if !OK || m<n 
            m = iterate!(s, y, m, n)
        end
        ds = revise(s, ds, y, yc, m)
        if m<n
            iter_f!(y, 1, f)
            iter_f!(yc, 1, f)
            if inScreen(y, extendedScreen) || inScreen(yc, extendedScreen)
                m += 1
                ds = revise(s, ds, y, yc, m)
            end
        end
        [y[i] = yc[i] for i in 1:2]
        if (OK = inScreen(y, extendedScreen)) && m == n
            append!(yList, [deepcopy(y)])
        end
        if count == 100000
            @printf("%.2f %% done, with %i points in list. ds = %e.  \n", s*100, length(yList), ds*100)
            count = 0
        end
        # println(y)
        s = min(s + ds, 1)
        count += 1
    end

    return yList

end

"""
    drawSUmanifoldsR2(f, finv, p_fix [; n, ninv, SD, minJump, maxJump, minStep, ds])

Return the drawing of the stable and unstable manifolds of an invertible function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$.

The stable manifold of a fixed point \$p=(x_0,y_0)\$ under \$f\$ is defined as

\$\\mathcal{S}(x_0,y_0)=\\{ q\\in \\mathbb{R}^2 \\mid (f^n(q)\\to \\infty)_{n\\to \\infty} \\}\$. 

And the unstable manifold is then just the stable manifold of the inverse function \$f^{-1}\$. The method used to approximate the manifolds was taken from You, Kostelich & Yorke [^1]. The idea consists in taking a line segment very close to the fixed point and as close to the unstable manifold as posible (by taking it in the direction tangent to the manifold), and then approximating the image of the segment after a certain number of iterations of the function.

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `finv::Function`: The inverse of function \$f\$.
- `p_fix::Vector`: The fixed point (or an approximation of it) of the function \$f\$.
- `n::Int = 6`: The \$2n\$ iteration of \$f\$ on a line segment close to the fixed point is used to approximate the unstable manifold of \$f\$.
- `ninv::Int = 6`: This is the \$n\$ used to approximate the stable manifold by using iterations of the inverse. The method works best when appropriate \$n\$ are chosen for each independently.
- `SD::Float64 = 0.5`: Determines the padding added to the screen size as a fraction of the screen size. This defines the region of interest.
- `minJump::Float64 = 1e-6`: The minimum distance that the algorith must move in the image of the segment.
- `maxJump::Float64 = 1e-3`: The maximum distance that the algotithm can move in the image of the segment.
- `minStep::Float64 = 1e-16`: The smallest step that can be taken on the line segment whose image approximates the manifold.
- `ds::Float64 = 1e-5`: The step size which the algorithm will attempt to take initially. 

#### Examples
```jldoctest
## Manifolds for a Hennon map with parameters a = 1.4 and b = 0.3
H(x::Vector) = [1.4 - x[1]*x[1] + 0.3*x[2] , x[1]]
Hinv(x::Vector) = [x[2], (x[1]+x[2]*x[2]-1.4)/0.3]
p_fix = [0.88389626793,0.88389626793]
drawSUmanifoldsR2(H, Hinv, p_fix; n = 11, ninv = 7)
```

See also: [`drawSmanifoldR2`](@ref), [`drawUmanifoldR2`](@ref)

[^1]: YOU, Zhiping; KOSTELICH, Eric J.; YORKE, James A. Calculating stable and unstable manifolds. *International Journal of Bifurcation and Chaos*, 1991, vol. 1, no 03, p. 605-623.
"""
function drawSUmanifoldsR2(f::Function, finv::Function, p_fix::Vector; 
    n::Int = 6, ninv::Int = 6, SD::Float64 = 0.5, minJump::Float64 = 1e-6, maxJump::Float64 = 1e-3, minStep::Float64 = 1e-16, ds::Float64 = 1e-5)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @printf("Approximating unstable manifold with n=%i \n", n)
    Uman = getUnstableManifoldR2(f, p_fix; SD = SD, n = n, minJump = minJump, maxJump = maxJump, minStep = minStep, ds = ds)
    @printf("Approximating stable manifold with n=%i \n", ninv)
    Sman = getUnstableManifoldR2(finv, p_fix; SD = SD, n = ninv, minJump = minJump, maxJump = maxJump, minStep = minStep, ds = ds)

    SDDGraphics.newdrawing()

    SDDGraphics.color(RGB(1,0,0))
    for i in 2:length(Uman)
        SDDGraphics.drawlinesegment(Uman[i-1][1], Uman[i-1][2], Uman[i][1], Uman[i][2])
    end
    SDDGraphics.color(RGB(0,0,1))
    for i in 2:length(Sman)
        SDDGraphics.drawlinesegment(Sman[i-1][1], Sman[i-1][2], Sman[i][1], Sman[i][2])
    end

    SDDGraphics.drawing()

end


"""
    drawSmanifoldR2(finv, p_fix [; ninv, SD, minJump, maxJump, minStep, ds])

See [`drawSUmanifoldsR2`](@ref). This function only draws the stable manifold, so the arguments `f` and `n` are omited. 
"""
function drawSmanifoldR2(finv::Function, p_fix::Vector; 
    ninv::Int = 6, SD::Float64 = 0.5, minJump::Float64 = 1e-6, maxJump::Float64 = 1e-3, minStep::Float64 = 1e-16, ds::Float64 = 1e-5)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @printf("Approximating stable manifold with n=%i \n", ninv)
    Sman = getUnstableManifoldR2(finv, p_fix; SD = SD, n = ninv, minJump = minJump, maxJump = maxJump, minStep = minStep, ds = ds)

    SDDGraphics.newdrawing()

    SDDGraphics.color(RGB(0,0,1))
    for i in 2:length(Sman)
        SDDGraphics.drawlinesegment(Sman[i-1][1], Sman[i-1][2], Sman[i][1], Sman[i][2])
    end

    SDDGraphics.drawing()

end

"""
    drawUmanifoldR2(f, finv, p_fix [; n, ninv, SD, minJump, maxJump, minStep, ds])

    See [`drawSUmanifoldsR2`](@ref). This function only draws the unstable manifold, so the arguments `finv` and `ninv` are omited. 
"""
function drawUmanifoldR2(f::Function, p_fix::Vector; 
    n::Int = 6, SD::Float64 = 0.5, minJump::Float64 = 1e-6, maxJump::Float64 = 1e-3, minStep::Float64 = 1e-16, ds::Float64 = 1e-5)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @printf("Approximating unstable manifold with n=%i \n", n)
    Uman = getUnstableManifoldR2(f, p_fix; SD = SD, n = n, minJump = minJump, maxJump = maxJump, minStep = minStep, ds = ds)

    SDDGraphics.newdrawing()

    SDDGraphics.color(RGB(1,0,0))
    for i in 2:length(Uman)
        SDDGraphics.drawlinesegment(Uman[i-1][1], Uman[i-1][2], Uman[i][1], Uman[i][2])
    end

    SDDGraphics.drawing()

end