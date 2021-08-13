using LinearAlgebra: norm2
using ForwardDiff
using LinearAlgebra

"""
    drawSUmanifolds(f [; hasescaped, maxiterations, tolerance])

Return the drawing of the stable and unstable manifolds of a function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$,
in a rectangular region in \$\\mathbb{R}^2\$.

The stable manifold of a fixed point \$p=(x_0,y_0)\$ under \$f\$ is defined as
\$\\mathcal{S}(x_0,y_0)=\\cup\\{\\{q_n \\mid n\\in \\mathbb{N}\\}\\subseteq \\mathbb{R}^2 \\mid \\forall n\\in\\mathbb{N}, f(q_n)=q_{n+1} \\wedge \\lim_{n\\to\\infty} q_n = p \\}\$

#### Arguments
- `f::Function`: A function \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- 
"""

function drawUnstableManifoldR2(f::Function, pFix::Tuple{Real,Real};
    SD::Int = 2, DIV::Int = 100, K::Int = 20, maxStep::Real = 0.1, minStep::Real = 0.0001)

    # Veryfying if graphics backend supports functions
    SDDGraphics.supported(:drawlinesegment)

    # Verifying functions
    @assert typeof(f(1., 1.)) <: Tuple{Real,Real}
    @assert typeof(hasescaped(1., 1.)) <: Bool

    F = iterativeR2(f, 2)
    Fᵏ = iterativeR2(F, K)
    ΔX = SD*(SDDGraphics.xlims()[2] - SDDGraphics.xlims()[1])
    ΔY = SD*(SDDGraphics.ylims()[2] - SDDGraphics.ylims()[1])
    extendedScreen = [SDDGraphics.xlims()[1] - ΔX, SDDGraphics.xlims()[2] + ΔX, SDDGraphics.xlims()[1] - ΔY, SDDGraphics.xlims()[2] + ΔY]

    SDDGraphics.newdrawing()

    D_f = x->ForwardDiff.jacobian(F,x)

    D_eigen = eigen(D_Hennon(pFix), sortby = abs)
    (abs(D_eigen.values[2])>1) ? du = normalize(D_eigen.vectors[:,2]) : throw(e)

    a⁺ = pFix .+ (du ./ 100)
    a⁻ = pFix .- (du ./ 100)
    b⁺ = F(a⁺)
    b⁻ = F(a⁻)


    forwardPts = [Fᵏ(a⁺)]
    stop = false
    p = a⁺
    while !stop

        ## Select next point on the segment [a⁺,b⁺]
        p = selectNext(Fᵏ, forwardPts[-1], p .+ ((b⁺ .- a⁺)./DIV), ((b⁺ .- a⁺)./DIV), minStep, maxStep)
        if norm2(p .- a⁺) < norm2(b⁺ .- a⁺)
            append!(forwardPts, Fᵏ(p))
        else
            stop = true
        end
    end
end

function selectNext(G::Function, lastP::Tuple{Real,Real}, nextP::Tuple{Real,Real}, Δ::Real, minStep::Real, maxStep::Real, EXTSCREEN::Tuple{Real, Real, Real, Real})
    Gp = G(nextP)
    imDist = norm2(Gp - G(lastP))
    inScreen = (Gp[1]<EXTSCREEN[1] || Gp[3]<EXTSCREEN[3] || Gp[2]>EXTSCREEN[2] || Gp[4]>EXTSCREEN[4]) ? false : true

    if (minStep < imDist < maxStep) && inScreen
        return nextP
    else if (minStep > imDist) || !inScreen
        return selectNext(G, nextP, nextP .+ Δ, Δ, minStep, maxStep)
    else if imDist > maxStep
        return selectNext(G, lastP, (nextP.-lastP) ./ 2, Δ, minStep, maxStep)
    end
end