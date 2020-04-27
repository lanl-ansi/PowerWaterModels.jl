using Documenter, PowerWaterModels

makedocs(
    modules = [PowerWaterModels],
    format = Documenter.HTML(analytics="UA-367975-10", mathengine=Documenter.MathJax()),
    sitename = "PowerWaterModels",
    authors = "Byron Tasseff and contributors",
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/lanl-ansi/PowerWaterModels.jl.git",
)
