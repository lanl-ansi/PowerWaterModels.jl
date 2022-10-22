# Network Formulations
The network formulations for joint power-water modeling use the formulations defined in [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/).

# PowerWaterModels Types
```@meta
CurrentModule = PowerWaterModels
```

Specification of a `PowerWaterModel` requires the specification of both a `PowerModelsDistribution.AbstractUnbalancedPowerModel` and a `WaterModels.AbstractWaterModel`, respectively.
For example, to specify a formulation that leverages the `LinDist3FlowPowerModel` and `PWLRDWaterModel` types, the corresponding `PowerWaterModel` type would be
```julia
PowerWaterModel{LinDist3FlowPowerModel, PWLRDWaterModel}
```

PowerWaterModels then utilizes the following (internal) function to construct a `PowerWaterModel` object:
```@docs
instantiate_model
```