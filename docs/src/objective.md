# Objective
The objective used by the [Power-Water Flow (PWF)](@ref) problem specification is a feasibility-only objective.
The default objective used by the [Optimal Power-Water Flow (OPWF)](@ref) problem specification is [`_PMD.objective_mc_min_fuel_cost(pmd)`](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/reference/objectives.html#PowerModelsDistribution.objective_mc_min_fuel_cost-Tuple{AbstractUnbalancedPowerModel}), which is described in the [PowerModelsDistribution documentation](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and represents a standard fuel cost minimization.
In addition to these objectives, PowerWaterModels also defines an additional objective, `objective_min_max_generation_fluctuation(pwm)`, defined over `AbstractPowerWaterModel`.
```@autodocs
Modules = [PowerWaterModels]
Pages   = ["core/objective.jl"]
Order   = [:function]
Private  = true
```