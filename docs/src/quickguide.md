# Quick Start Guide
The following guide walks through the solution of an optimal power-water flow (`opwf`) problem using the `LinDist3FlowPowerModel` power distribution network formulation (specified via [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl)) and the `MILPRWaterModel` water distribution network formulation (specified via [WaterModels](https://github.com/lanl-ansi/WaterModels.jl)).

## Installation of PowerWaterModels
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

## Installation of an Optimization Solver
At least one optimization solver is required to run PowerWaterModels.
The solver selected typically depends on the type of problem formulation being employed.
Because of the constraints that link power loads between the two systems in the `LinDist3FlowPowerModel`/`MILPRWaterModel` formulation, the overall model considered in this tutorial is mixed-integer _nonconvex_ quadratic.
One example of an optimization package capable of solving this problem is the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl).
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [CBC](https://github.com/jump-dev/Cbc.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt Cbc
```

### (Optional) Installation of Gurobi
Juniper is likely _not_ the best candidate to solve the mixed-integer nonconvex quadratic problem considered in this tutorial.
As another example, the commercial package [Gurobi](https://github.com/jump-dev/Gurobi.jl) can be used in its place.
Assuming Gurobi has already been configured on your system, its Julia interface can be installed using the package manager with

```julia
] add Gurobi
```

## Solving an Optimal Power-Water Flow Problem
After installation of the required solvers, an example optimal power-water flow problem (whose file inputs can be found in the `examples` directory within the [PowerWaterModels repository](https://github.com/lanl-ansi/PowerWaterModels.jl) can be solved via

```julia
using JuMP, Juniper, Ipopt, Cbc
using PowerWaterModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0, "sb"=>"yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt, "mip_solver"=>cbc)

# Specify paths to the power, water, and power-water linking files.
p_file = "examples/data/opendss/IEEE13_CDPSM.dss" # Power network.
w_file = "examples/data/epanet/cohen-short.inp" # Water network.
pw_file = "examples/data/json/zamzam.json" # Power-water linking.

# Specify the power and water formulation types separately.
p_type, w_type = LinDist3FlowPowerModel, MILPRWaterModel

# Specify the number of breakpoints used in the linearized water formulation.
wm_ext = Dict{Symbol,Any}(:pipe_breakpoints=>5, :pump_breakpoints=>5)

# Solve the joint optimal power-water flow problem and store the result.
result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper; wm_ext=wm_ext)
```

This example will likely take over a minute to solve.

### (Optional) Solving the Problem with Gurobi
Note that [Gurobi's `NonConvex=2` parameter setting](https://www.gurobi.com/documentation/9.0/refman/nonconvex.html) ensures it will correctly handle the nonconvex quadratic constraints that link power and water variables.
The problem considered above can then be solved using Gurobi (instead of Juniper) via

```julia
import Gurobi

# Solve the joint optimal power-water flow problem and store its result.
gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer, "NonConvex"=>2)
result_grb = run_opwf(p_file, w_file, pw_file, p_type, w_type, gurobi; wm_ext=wm_ext)
```

First, note that Gurobi solves the problem much more quickly than Juniper.
Also note the slight difference in the objectives obtained between Juniper and Gurobi, i.e.,
```
result["objective"] - result_grb["objective"] # Positive difference.
```

The objective value obtained via Gurobi is _smaller_ than the one obtained via Juniper.
This is because Gurobi is capable of solving mixed-integer nonconvex quadratic programs to _global optimality_, whereas Juniper can only solve them to _local optimality_ (i.e., feasibility).

## Obtaining Results
The `run` commands in PowerWaterModels return detailed results data in the form of a Julia `Dict`.
This dictionary can be saved for further processing as follows:
```julia
result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper; wm_ext=wm_ext)
```

For example, the algorithm's runtime and final objective value can be accessed with
```
result["solve_time"]
result["objective"]
```

The `"solution"` field contains detailed information about the solution produced by the `run` method.
For example, the following can be used to inspect the temporal variation in the volume of tank 1:
```
tank_1_volume = Dict(nw=>data["tank"]["10"]["V"] for (nw, data) in result["solution"]["nw"])
```

For more information about PowerWaterModels result data see the [PowerWaterModels Result Data Format](@ref) section.

## Modifying Network Data
The following example demonstrates one way to perform multiple PowerWaterModels solves while modifying network data in Julia.
```julia
p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)

for (nw, network) in w_data["nw"]
    network["junction"]["3"]["demand"] *= 0.1
    network["junction"]["4"]["demand"] *= 0.1
    network["junction"]["5"]["demand"] *= 0.1
end

result_mod = run_opwf(p_data, w_data, pw_data, p_type, w_type, juniper; wm_ext=wm_ext)
```
Note that the smaller demands in the modified problem result in an overall smaller objective value.
For additional details about the network data, see the [PowerWaterModels Network Data Format](@ref) section.

## Alternate Methods for Building and Solving Models
The following example demonstrates how to break a `run_opwf` call into separate model building and solving steps.
This allows inspection of the JuMP model created by PowerWaterModels for the problem.
```julia
# Instantiate the joint power-water models.
pm, wm = instantiate_model(p_data, w_data, pw_data, p_type, w_type, build_opwf; wm_ext=wm_ext)

# Print the (shared) JuMP model.
print(pm.model)

# Create separate power and water result dictionaries.
power_result = PowerWaterModels._IM.optimize_model!(pm, optimizer=juniper)
water_result = PowerWaterModels._IM.build_result(wm, power_result["solve_time"])
```
