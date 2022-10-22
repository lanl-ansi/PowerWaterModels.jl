# File I/O
Parsing functions in PowerWaterModels use the native parsing features of [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl) and [WaterModels](https://github.com/lanl-ansi/WaterModels.jl) with extra features to parse information used to couple the two infrastructures.

```@meta
CurrentModule = PowerWaterModels
```

## Coupling Data Format
The PowerWaterModels parsing implementation relies on data formats that support extensions to accommodate arbitrary extra data fields, such as those required to define couplings between infrastructures.
Thus, PowerWaterModels largely relies on parsing of [MATPOWER](https://matpower.org/), [OpenDSS](https://www.epri.com/pages/sa/opendss), and [EPANET](https://www.epa.gov/water-research/epanet) input files to populate some data fields.
In addition, the coupling between loads and pumps is accomplished via a tertiary JSON linking file of the following form (further detailed in [Interdependency Information](@ref)):
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

## Parsing Functions
The following functions can be used for convenient parsing of input files.

```@docs
parse_files
parse_json
```
