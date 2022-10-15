# Quick Start Guide
The following guide walks through the solution of an optimal power-water flow (`opwf`) problem using the `LinDist3FlowPowerModel` power distribution network formulation (specified via [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl)) and the `PWLRDWaterModel` water distribution network formulation (specified via [WaterModels](https://github.com/lanl-ansi/WaterModels.jl)).

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
Because of the `LinDist3FlowPowerModel`/`PWLRDWaterModel` joint formulation, the overall model considered in this tutorial is mixed-integer _nonconvex_ quadratic.
One example of an optimization package capable of solving this problem is the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl).
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [HiGHS](https://github.com/jump-dev/HiGHS.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and HiGHS can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt HiGHS
```

### (Optional) Installation of Gurobi
Juniper is likely _not_ the best candidate to solve the mixed-integer nonconvex quadratic problem considered in this tutorial.
As another example, the commercial package [Gurobi](https://github.com/jump-dev/Gurobi.jl) can be used in its place.
Assuming Gurobi has already been configured on your system, its Julia interface can be installed using the package manager with

```julia
] add Gurobi
```

## Solving an Optimal Power-Water Flow Problem
After installation of the required solvers, an example optimal power-water flow problem (whose file inputs can be found in the `examples` directory within the [PowerWaterModels repository](https://github.com/lanl-ansi/PowerWaterModels.jl)) can be solved via

```julia
using JuMP, Juniper, Ipopt, HiGHS
using PowerWaterModels
const WM = PowerWaterModels.WaterModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0, "sb" => "yes")
highs = JuMP.optimizer_with_attributes(HiGHS.Optimizer, "log_to_console" => false)
juniper = JuMP.optimizer_with_attributes(
    Juniper.Optimizer, "nl_solver" => ipopt, "mip_solver" => highs,
    "branch_strategy" => :MostInfeasible, "time_limit" => 60.0)

# Specify paths to the power, water, and power-water linking files.
p_file = "examples/data/opendss/IEEE13_CDPSM.dss" # Power network.
w_file = "examples/data/epanet/cohen-short.inp" # Water network.
pw_file = "examples/data/json/zamzam.json" # Power-water linking.

# Parse the input files as a multi-infrastructure data object.
data = parse_files(p_file, w_file, pw_file)

# Perform OBBT on water network to improve variable bounds.
WM.solve_obbt_owf!(data, ipopt; use_relaxed_network = false,
    model_type = WM.CRDWaterModel, max_iter = 3)

# Use WaterModels to set the partitioning of flows in the water network.
WM.set_flow_partitions_num!(data, 5)

# Specify the power and water formulation types jointly.
pwm_type = PowerWaterModel{LinDist3FlowPowerModel, PWLRDWaterModel}

# Solve the joint optimal power-water flow problem and store the result.
result = solve_opwf(data, pwm_type, juniper)
```

### (Optional) Solving the Problem with Gurobi
Note that [Gurobi's `NonConvex=2` parameter setting](https://www.gurobi.com/documentation/9.1/refman/nonconvex.html) ensures it will correctly handle the nonconvex quadratic constraints that are associated with the power network formulation.
The problem considered above can then be solved using Gurobi (instead of Juniper) via

```julia
import Gurobi

# Solve the joint optimal power-water flow problem and store its result.
gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer, "NonConvex" => 2)
result_grb = solve_opwf(data, pwm_type, gurobi)
```

First, note that Gurobi solves the problem much more quickly than Juniper.
Also note the difference in the objectives obtained between Juniper and Gurobi, i.e.,
```
result["objective"] - result_grb["objective"] # Positive difference.
```

The objective value obtained via Gurobi is _smaller_ than the one obtained via Juniper, indicating that Gurobi discovered a better solution.

## Obtaining Results
The `solve` commands in PowerWaterModels return detailed results data in the form of a Julia `Dict`.
This dictionary can be saved for further processing as follows:
```julia
result = solve_opwf(data, pwm_type, juniper)
```

For example, the algorithm's runtime and final objective value can be accessed with
```
result["solve_time"] # Total solve time required (seconds).
result["objective"] # Final objective value (in units of the objective).
```

The `"solution"` field contains detailed information about the solution produced by the `solve` method.
For example, the following can be used to inspect the temporal variation in the volume of tank 1 in the water distribution network:
```
tank_1_volume = Dict(nw=>data["tank"]["10"]["V"] for (nw, data) in result["solution"]["it"]["wm"]["nw"])
```

For more information about PowerWaterModels result data, see the [PowerWaterModels Result Data Format](@ref) section.

## Accessing Different Formulations
As an example, to reformulate the previous problem using the `NFAUPowerModel` model for power flow and the `LRDWaterModel` model for water flow, which can then be jointly solved with HiGHS, the following can be executed:
```julia
# Instantiate a verbose version of the HiGHS optimizer.
highs_verbose = JuMP.optimizer_with_attributes(HiGHS.Optimizer, "log_to_console" => true)

# Specify the power and water formulation types jointly.
pwm_type_reformulation = PowerWaterModel{NFAUPowerModel, LRDWaterModel}

# Solve the joint optimal power-water flow problem and store the result.
result_reformulation = solve_opwf(data, pwm_type_reformulation, highs_verbose)
```


## Modifying Network Data
The following example demonstrates one way to perform PowerWaterModels solves while modifying network data.
```julia
for (nw, network) in data["it"]["wm"]["nw"]
    network["demand"]["3"]["flow_nominal"] *= 0.90
    network["demand"]["4"]["flow_nominal"] *= 0.90
    network["demand"]["5"]["flow_nominal"] *= 0.90
end

result_mod = solve_opwf(data, pwm_type, juniper)
```
Note that the smaller demands in the modified problem result in an overall smaller objective value, i.e.,
```julia
# The comparison below should return `true`.
result_mod["objective"] < result["objective"]
```
For additional details about the network data, see the [PowerWaterModels Network Data Format](@ref) section.

## Alternate Methods for Building and Solving Models
The following example demonstrates how to decompose a `solve_opwf` call into separate model building and solving steps.
This allows for inspection of the JuMP model created by PowerWaterModels:
```julia
# Instantiate the model.
pwm = instantiate_model(data, pwm_type, build_opwf);

# Print the contents of the JuMP model.
println(pwm.model)
```
The problem can then be solved and its two result dictionaries can be stored via:
```julia
# Solve the PowerWaterModels problem and store the result.
result = PowerWaterModels._IM.optimize_model!(pwm, optimizer = juniper)
```