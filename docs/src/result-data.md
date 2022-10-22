# PowerWaterModels Result Data Format

## The Result Data Dictionary
PowerWaterModels uses a dictionary to organize the results of a `solve_` command.
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The data dictionary organization is designed to be consistent with [The Network Data Dictionary](@ref).

At the top level, the results data dictionary is structured as follows:
```json
{
  "optimizer": <string>,        # name of the solver used to solve the model
  "termination_status": <type>, # optimizer status at termination
  "dual_status": <type>,        # optimizer dual status at termination
  "primal_status": <type>,      # optimizer primal status at termination
  "solve_time": <float>,        # reported solve time (in seconds)
  "objective": <float>,         # the final evaluation of the objective function
  "objective_lb": <float>,      # the final lower bound of the objective function (if available)
  "solution": {...}             # complete solution information (details below)
}
```

### Solution Data
The `"solution"` subdictionary provides detailed information about the problem solution produced by the `solve_` command.
The solution is organized similarly to [The Network Data Dictionary](@ref) with the same nested structure and parameter names, when available.
The solution object merges the solution information for both the power distribution system and water distribution system into the same dictionary.
For example, `result["solution"]["it"]["pmd"]["nw"]["2"]["load"]["6"]` reports all the solution values associated with the load at load index `"6"` and time index `"2"`, e.g.,
```json
{
    "status": 1.0,
    "qd": [0.00068],
    "pd": [0.00117]
}
```
Similarly, `result["solution"]["it"]["wm"]["nw"]["1"]["pump"]["2"]` reports all the solution values associated with the water system pump at pump index `"2"` and time index `"1"`, e.g.,
```json
{
    "qn": 0.0,
    "c": 195.57961638739798,
    "g": 0.8511119380321539,
    "P": 0.01313949265910189,
    "status": 1.0,
    "qp": 0.04295470349204493,
    "q": 0.04295470349204493,
    "E": 0.0001487826668832342,
    "y": 1.0
}
```

Because the data dictionary and the solution dictionary have the same structure, the InfrastructureModels `update_data!` helper function can be used to update a data dictionary with values from a solution, e.g.,
```julia
import InfrastructureModels

InfrastructureModels.update_data!(
  data["it"]["wm"]["nw"]["1"]["pump"]["2"],
  result["solution"]["it"]["wm"]["nw"]["1"]["pump"]["2"]
)
```

Note that, by default, all results are reported in a per-unit (non-dimensionalized) system.
Functions and/or additional data from PowerModelsDistribution and WaterModels can be used to convert such data back to their dimensionalized forms.
For example, the code block below translates a per-unit pump flow rate to SI units, then the more conventional units of liters per second.
```julia
# Get a pump volumetric flow rate solution in the per-unit system.
flow_per_unit = result["solution"]["it"]["wm"]["nw"]["1"]["pump"]["2"]["q"]

# Get the per-unit scalar used to convert back to SI units.
base_flow = data["it"]["wm"]["base_flow"]

# Compute the volumetric flow rate in SI units (cubic meters per second).
base_flow * flow_per_unit

# Compute the volumetric flow rate in liters per second.
base_flow * flow_per_unit * 1000.0
```