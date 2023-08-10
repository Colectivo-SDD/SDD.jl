
"""
    funcgraph2d(f, xs, ys [; iterations, func])

Plot of graph of a function \$F\\circ f^n\$, where \$f^n\$ is the n-th iterate of a function
\$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$, and
\$F\$ is a function \$F:\\mathbb{C}\\rightarrow\\mathbb{R}\$ or \$F:\\mathbb{R}^2\\rightarrow\\mathbb{R}\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.
- `ys::AbstractVector{Real}`: Base \$y\$ coordinates.

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate \$f^n\$.
- `func::Function`: Function \$F:\\mathbb{C}\\rightarrow\\mathbb{R}\$ or \$F:\\mathbb{R}^2\\rightarrow\\mathbb{R}\$
- `plotstyle::Symbol=:surface`: Plot style `:surface`, `:wireframe` or `:both`.
"""
@recipe(FuncGraph2D) do scene
  Attributes(
    iterations = 1,
    func = z -> abs(z),
    plotstyle = :surface
  )
end

function Makie.plot!(plt::FuncGraph2D{<:Tuple{Function, Any, Any}})
  # Recipe attributes
  obs_f = plt[1]
  f = obs_f[] # Function
  fn = iteratef(f, plt.iterations[])
  obs_fn = Observable(fn)

  obs_xs = plt[2]
  xs = obs_xs[]
  obs_ys = plt[3]
  ys = obs_ys[]

  F = plt.func[]

  zs = functionkind2D(f) == :onnumbers ?
    [ F(fn(complex(x,y))) for x in xs, y in ys ] :
    [ F(fn([x,y])) for x in xs, y in ys ]

  pltsty = plt.plotstyle[]
  # Remove non Makie keyword arguments to avoid errors
  delete!(plt.attributes.attributes, :iterations)
  delete!(plt.attributes.attributes, :func)
  delete!(plt.attributes.attributes, :plotstyle)

  # Plot the nth-iterate of f
  if pltsty == :surface
    surface!(plt, obs_xs, obs_ys, Observable(zs); plt.attributes.attributes...)
  elseif pltsty == :wireframe
    wireframe!(plt, obs_xs, obs_ys, Observable(zs); plt.attributes.attributes...)
  else
    surface!(plt, obs_xs, obs_ys, Observable(zs); plt.attributes.attributes...)
    wireframe!(plt, obs_xs, obs_ys, Observable(zs); plt.attributes.attributes...)
  end

  plt
end



#
# Plot Modulus Graph (of the nth-Iterate of a complex function)
#

"""
    modulusgraph(f, xs, ys [; iterations])

Plot of graph of the modulus function of the n-th iterate of a function
\$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.
- `ys::AbstractVector{Real}`: Base \$y\$ coordinates.

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate \$f^n\$.
"""
@recipe(ModulusGraph) do scene
  Attributes(
    iterations = 1
  )
end

function Makie.plot!(plt::ModulusGraph{<:Tuple{Function, Any, Any}})
  funcgraph2d!(plt, plt[1], plt[2], plt[3],
    func=functionkind2D(plt[1][]) == :onnumbers ? abs : p->sqrt(p[1]^2+p[2]^2);
    plt.attributes.attributes...)
end



"""
    arggraph(f, xs, ys [; iterations])

Plot of graph of the argument function of the n-th iterate of a function
\$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.

#### Arguments
- `f::Function`: Function \$f:\\mathbb{C}\\rightarrow\\mathbb{C}\$ or \$f:\\mathbb{R}^2\\rightarrow\\mathbb{R}^2\$.
- `xs::AbstractVector{Real}`: Base \$x\$ coordinates.
- `ys::AbstractVector{Real}`: Base \$y\$ coordinates.

#### Keyword Arguments
- `iterations::Int`: Number of iterations to calculate \$f^n\$.
"""
@recipe(ArgGraph) do scene
  Attributes(
    iterations = 1
  )
end

function Makie.plot!(plt::ArgGraph{<:Tuple{Function, Any, Any}})
  funcgraph2d!(plt, plt[1], plt[2], plt[3],
    func=functionkind2D(plt[1][]) == :onnumbers ? angle : p->atan(p[2]/p[1]);
    plt.attributes.attributes...)
end
