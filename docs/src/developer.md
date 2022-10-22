# Developer Documentation

## Data Processing Functions
The PowerWaterModels data format allows the user to specify power network data, water network data, and data related to the interdependencies between power and water systems.
PowerWaterModels relies on the automated data processing routines of [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl) and [WaterModels](https://github.com/lanl-ansi/WaterModels.jl), which include capabilities for status propagation, nondimensionalization, topology correction, etc.
However, these capabilities are typically used on independent infrastructure data, whereas PowerWaterModels must join these data.
Thus, in preprocessing routines, it is recommended that capabilities be invoked explictly so that external dependencies are accounted for.
For example, the core data parsing function `parse_files` performs the following operations:
```julia
function parse_files(power_path::String, water_path::String, link_path::String)
    joint_network_data = parse_link_file(link_path)
    _IM.update_data!(joint_network_data, parse_power_file(power_path))
    _IM.update_data!(joint_network_data, parse_water_file(water_path))
    correct_network_data!(joint_network_data)

    # Store whether or not each network uses per-unit data.
    p_per_unit = get(joint_network_data["it"][_PMD.pmd_it_name], "per_unit", false)
    w_per_unit = get(joint_network_data["it"][_WM.wm_it_name], "per_unit", false)

    # Make the power and water data sets multinetwork.
    joint_network_data_mn = make_multinetwork(joint_network_data)

    # Prepare and correct pump load linking data.
    assign_pump_loads!(joint_network_data_mn)

    # Modify variable load properties in the power network.
    _modify_loads!(joint_network_data_mn)

    # Return the network dictionary.
    return joint_network_data_mn
end
```

Here, the `parse_power_file` and `parse_water_file` use custom routines to parse and transform the input data, i.e.,
```julia
function parse_power_file(file_path::String)
    if split(file_path, ".")[end] == "m" # If reading a MATPOWER file.
        data = _PM.parse_file(file_path)
        _scale_loads!(data, 1.0 / 3.0)
        _PMD.make_multiconductor!(data, 3)
    else
        data = _PMD.parse_file(file_path)
    end

    return _IM.ismultiinfrastructure(data) ? data :
          Dict("multiinfrastructure" => true, "it" => Dict(_PMD.pmd_it_name => data))
end


function parse_water_file(file_path::String; skip_correct::Bool = true)
    data = _WM.parse_file(file_path; skip_correct = skip_correct)
    return _IM.ismultiinfrastructure(data) ? data :
           Dict("multiinfrastructure" => true, "it" => Dict(_WM.wm_it_name => data))
end
```

After these routines are called, `correct_network_data!` executes various data and topology correction routines on power, water, and linking data.
Then, `make_multinetwork` ensures that the temporal dimension of each infrastructure and interdependency subdictionary match.
Finally, interdependency data are corrected and modified via `assign_pump_loads!` and `_modify_loads!` to ensure linking constraints will be modeled appropriately.

## Compositional Problems
A best practice is to adopt a compositional approach for building problems in PowerWaterModels, leveraging problem definitions of PowerModelsDistribution and WaterModels.
This helps lessen the impact of breaking changes across independent infrastructure packages.
For example, the joint optimal power-water flow problem invokes similar problems of PowerModelsDistribution and WaterModels directly with routines like

```julia
# Power-only related variables and constraints.
pmd = _get_powermodel_from_powerwatermodel(pwm)
_PMD.build_mn_mc_mld_simple(pmd)

# Water-only related variables and constraints.
wm = _get_watermodel_from_powerwatermodel(pwm)
_WM.build_mn_owf(wm)

# Power-water linking constraints.
build_linking(pwm)

# Add the objective that minimizes power generation costs.
_PMD.objective_mc_min_fuel_cost(pmd)
```

Compared to the `PowerModelsDistribution` (`_PMD`) and `WaterModels` (`_WM`) routines, the PowerWaterModels routines only specify interdependency constraints.