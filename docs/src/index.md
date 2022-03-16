# PowerWaterModels.jl Documentation

```@meta
CurrentModule = PowerWaterModels
```

## Overview
PowerWaterModels.jl is a Julia/JuMP package for the joint optimization of steady-state power and water distribution networks.
It is designed to enable the computational evaluation of historical and emerging power-water network optimization formulations and algorithms using a common platform.
The code is engineered to decouple [Problem Specifications](@ref) (e.g., power-water flow, optimal power-water flow) from [Network Formulations](@ref) (e.g., mixed-integer linear, mixed-integer nonlinear).
This decoupling enables the definition of a variety of optimization formulations and their comparison on common problem specifications.

## Installation
The latest stable release of PowerWaterModels can be installed using the Julia package manager with
```julia
] add PowerWaterModels
```

For the current development version, install the package using
```julia
] add PowerWaterModels#master
```

Finally, test that the package works as expected by executing
```julia
] test PowerWaterModels
```

## Usage at a Glance
At least one optimization solver is required to run PowerWaterModels.
The solver selected typically depends on the type of problem formulation being employed.
As an example, the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl) can be used for testing any of the problem formulations considered in this package.
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [HiGHS](https://github.com/jump-dev/HiGHS.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and HiGHS can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt HiGHS
```

After installation of the required solvers, an example optimal power-water flow problem (whose file inputs can be found in the `examples` directory within the [PowerWaterModels repository](https://github.com/lanl-ansi/PowerWaterModels.jl)) can be solved via

```julia
using JuMP, Juniper, Ipopt, HiGHS
using PowerWaterModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0, "sb" => "yes")
highs = JuMP.optimizer_with_attributes(HiGHS.Optimizer, "log_to_console" => false)
juniper = JuMP.optimizer_with_attributes(
    Juniper.Optimizer, "nl_solver" => ipopt, "mip_solver" => highs,
    "time_limit" => 60.0)

# Specify paths to the power, water, and power-water linking files.
p_file = "examples/data/opendss/IEEE13_CDPSM.dss" # Power network.
w_file = "examples/data/epanet/cohen-short.inp" # Water network.
pw_file = "examples/data/json/zamzam.json" # Power-water linking.

# Specify the power and water formulation types separately.
pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}

# Solve the joint optimal power-water flow problem and store the result.
result = solve_opwf(p_file, w_file, pw_file, pwm_type, juniper)
```

After solving the problem, results can then be analyzed, e.g.,

```julia
# Objective value, representing the cost of power generation.
result["objective"]

# Generator 1's real power generation at the first time step.
result["solution"]["it"]["pmd"]["nw"]["1"]["gen"]["1"]["pg"]

# Pump 2's head gain at the third time step.
result["solution"]["it"]["wm"]["nw"]["3"]["pump"]["2"]["g"]
```
