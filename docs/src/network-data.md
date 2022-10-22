# PowerWaterModels Network Data Format

## The Network Data Dictionary
Internally, PowerWaterModels uses a dictionary to store network data for both power distribution systems (see [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/)) and water distribution systems (see [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/)).
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The I/O for PowerWaterModels utilizes the serializations available in [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/) to construct the joint network model.
All data are assumed to be in per-unit (non-dimensionalized) or SI units.
Power, water, and interdependency data are each stored in the `data["it"]["pmd"]`, `data["it"]["wm"]`, and `data["it"]["dep"]` subdictionaries of `data`, respectively.
Descriptions of the first two subdictionaries are presented in the documentation of [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/), respectively.

Beside the standard network data supported by [PowerModelsDistribution.jl](https://lanl-ansi.github.io/PowerModelsDistribution.jl/stable/) and [WaterModels.jl](https://lanl-ansi.github.io/WaterModels.jl/stable/), there are a few extra fields that are required to couple the two systems together.
These fields are described in the following subsection.

### Interdependency Information
Note that the current version of PowerWaterModels supports only one type of interdependency, i.e., modeling select pumps in the water distribution network as loads in the power distribution network.
This is represented by an interdependency type named `"pump_load"`.
Aside from the interdependency definitions, additional `"source_type"` entries are added to the PowerModelsDistribution (`"pmd"`) and WaterModels (`"wm"`) subdictionaries to assist in ultimately transforming and linking power and water network inputs.
```json
{
    "it": {
        "dep": {
            "pump_load": {
                "1": {
                    "pump": {
                        "source_id": <String> # Index in the source water
                        # network data file of the pump that is being modeled
                        # in the interdependency.
                    },
                    "load": {
                        "source_id": <String> # Index in the source power
                        # network data file of the load that is being modeled
                        # in the interdependency.
                    },
                    "status": <Int64> # Indicator (-1, 0, or 1) specifying if
                    # the status of the interdependency is unknown (-1, i.e.,
                    # potentially on _or_ off), inactive (0, i.e., off) or 
                    # active (1, i.e., on).
                },
                "2": {
                    ...
                },
                ...
            }
        },
    "pmd": {
        "source_type": <String> # Type of input file used to describe the power
        # distribution network model. Can be "opendss" or "matpower".
        ...
    },
    "wm": {
        "source_type": <String> # Type of input file used to describe the water
        # distribution network model. Can currently only be set to "epanet".
        ...
    }
}
```
