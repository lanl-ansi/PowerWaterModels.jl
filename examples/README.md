# Examples

## Dependencies
The following examples assume that Gurobi has been installed on the system.
Install Julia dependencies with
```julia
] add CSV DataFrames Gurobi JuMP PowerWaterModels WaterModels
```

## Optimal Power-Water Flow
The example script `opwf.jl` illustrates the solution of several optimal power-water flow problems.
It can be executed from the root project directory via
```bash
mkdir results
julia examples/opwf.jl
```
