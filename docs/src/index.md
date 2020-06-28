# PowerWaterModels.jl Documentation

```@meta
CurrentModule = PowerWaterModels
```

## Overview
PowerWaterModels.jl is a Julia/JuMP package for steady state joint power-water distribution network optimization.
It is designed to enable computational evaluation of historical and emerging power-water network optimization formulations and algorithms using a common platform.
The code is engineered to decouple [Problem Specifications](@ref) (e.g., power-water flow, optimal power-water flow) from [Network Formulations](@ref) (e.g., mixed-integer linear, mixed-integer nonlinear).
This decoupling enables the definition of a wide variety of optimization formulations and their comparison on common problem specifications.

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

## Usage at a Glance
At least one optimization solver is required to run PowerWaterModels.
The solver chosen typically depends on the type of problem formulation being employed.
As an example, the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl) can be used for testing any of problem the formulations considered herein.
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [CBC](https://github.com/jump-dev/Cbc.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt Cbc
```

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

Note that Juniper is not the best-performing choice of solver for this formulation.
At the time of writing, [Gurobi](https://github.com/jump-dev/Gurobi.jl) appears to be the best choice for this joint formulation.
To solve the same problem with Gurobi, it can first be installed via

```julia
] add Gurobi
```

Then, the problem can be solved using

```julia
# Solve the joint optimal power-water flow problem and store its result.
gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer, "NonConvex"=>2)
result = run_opwf(p_file, w_file, pw_file, p_type, w_type, gurobi; wm_ext=wm_ext)
```

Note that the `NonConvex=2` option ensures Gurobi will correctly handle the constraints that link water and power variables.
