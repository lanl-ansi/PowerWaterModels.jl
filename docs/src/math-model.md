# The PowerWaterModels Mathematical Model
As PowerWaterModels can implement a variety of coupled power-water network optimization problems, the implementation is the best reference for precise mathematical formulations.
This section provides a mathematical specification for constraints that couple power and water distribution networks.
For more information about constituent power and water models, refer to the [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/) documentation.

## Coupled Power and Water Flow
PowerWaterModels implements steady-state models of power and water flow, based on the implementations of power flows in [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl) and water flows in [WaterModels](https://github.com/lanl-ansi/WaterModels.jl).
The key coupling constraints between power and water systems are through pumps that act as power loads are specified in [Constraints](@ref).
