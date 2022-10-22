using Documenter, PowerWaterModels

makedocs(
    modules = [PowerWaterModels],
    format = Documenter.HTML(analytics="UA-367975-10", mathengine=Documenter.MathJax()),
    sitename = "PowerWaterModels",
    authors = "Byron Tasseff and contributors",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "quickguide.md",
            "Network Data Format" => "network-data.md",
            "Result Data Format" => "result-data.md"
        ],
        "Library" => [
            "Network Formulations" => "formulations.md",
            "Problem Specifications" => "specifications.md",
            "Modeling Components" => [
                "Objective" => "objective.md",
                "Constraints" => "constraints.md"
            ],
            "File I/O" => "parser.md"
        ],
        "Developer" => "developer.md",
        "Examples" => "examples.md"
    ]
)

deploydocs(
    repo = "github.com/lanl-ansi/PowerWaterModels.jl.git",
)
