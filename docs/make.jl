push!(LOAD_PATH, "./../src/")
using SDD

using Documenter
makedocs(
    modules = [SDD],
    sitename = "SDD Reference",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        warn_outdated = true,
        collapselevel=1,
        )
)
