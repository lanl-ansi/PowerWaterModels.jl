# Quick Start Guide
The following guide walks through the solution of an optimal power-water flow (`opwf`) problem using the `LinDist3FlowPowerModel` power distribution formulation (via [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl)) and the `MILPRWaterModel` water distribution formulation (via [WaterModels](https://github.com/lanl-ansi/WaterModels.jl)).

## Installation
The latest stable release of PowerWaterModels can be installed using the Julia package manager with
```julia
] add PowerWaterModels
```

For the current development version, install the package using
```julia
] add PowerWaterModels#master
```

Finally, test that the package works by executing
```julia
] test PowerWaterModels
```

## Selection of an Optimization Solver
Because of the constraints that link power loads between the two systems in the `LinDist3FlowPowerModel`/`MILPRWaterModel` formulation for optimal power-water flow, the overall model is mixed-integer _nonconvex_ quadratic.
At the time of writing, [Gurobi](https://github.com/jump-dev/Gurobi.jl) appears to be the best choice for solving this type of problem.
Assuming Gurobi has been installed on your system, its interface can be installed using the Julia package manager via

```julia
] add Gurobi
```

However, if Gurobi is not available, any other mixed-integer nonlinear programming solver can be used in its place.
As one example, the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl) may prove adequate for testing purposes.
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [CBC](https://github.com/jump-dev/Cbc.jl)).
Installation of the interfaces to Juniper, Ipopt, and Cbc can be performed using the Julia package manager via

```julia
] add JuMP Juniper Ipopt Cbc
```

Note that other problem formulations may rely on the availability of mixed-integer nonlinear programming solvers that support [user-defined nonlinear functions in JuMP](http://www.juliaopt.org/JuMP.jl/dev/nlp/#User-defined-Functions-1).
However, these solvers (e.g., [Juniper](https://github.com/lanl-ansi/Juniper.jl), [KNITRO](https://github.com/JuliaOpt/KNITRO.jl)) either require additional effort to register user-defined functions or are proprietary and require a commercial license.

## Solving an Optimal Power-Water Flow Problem
After installation of the required solvers, an example power-water flow feasibility problem (whose inputs are found in the `examples` directory within the [PowerWaterModels repository](https://github.com/lanl-ansi/PowerWaterModels.jl) can be solved via

```julia
using JuMP, Juniper, Ipopt, Cbc
using PowerWaterModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1.0e-8, "print_level"=>0, "sb"=>"yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt, "mip_solver"=>cbc)

# Specify paths to the power, water, and power-water linkage files.
p_file = "examples/data/opendss/IEEE13_CDPSM.dss"
w_file = "examples/data/epanet/cohen.inp"
pw_file = "examples/data/json/zamzam.json"

# Specify the power and water formulations separately.
p_type, w_type = LinDist3FlowPowerModel, MILPRWaterModel

# Specify the number of breakpoints used in the linearized water formulation.
wm_ext = Dict{Symbol,Any}(:pump_breakpoints=>5, :pipe_breakpoints=>5)

# Solve the joint optimal power-water flow problem and store its result.
result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper; wm_ext=wm_ext)
```

## Obtaining Results

## Accessing Different Formulations

## Modifying Network Data

## Alternate Methods for Building and Solving Models
