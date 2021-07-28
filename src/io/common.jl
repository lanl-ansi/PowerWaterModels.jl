"""
    parse_link_file(path)

Parses a linking file from the file path `path`, depending on the file extension, and
returns a PowerWaterModels data structure that links power and water networks (a dictionary).
"""
function parse_link_file(path::String)
    if endswith(path, ".json")
        data = parse_json(path)
    else
        error("\"$(path)\" is not a valid file type.")
    end

    if !haskey(data, "multiinfrastructure")
        data["multiinfrastructure"] = true
    end

    return data
end


function parse_power_file(file_path::String; skip_correct::Bool = true)
    # TODO: What should `skip_correct` do, here?
    data = _PMD.parse_file(file_path)
    return _IM.ismultiinfrastructure(data) ? data :
           Dict("multiinfrastructure" => true, "it" => Dict(_PMD.pmd_it_name => data))
end


function parse_water_file(file_path::String; skip_correct::Bool = true)
    data = _WM.parse_file(file_path; skip_correct = skip_correct)
    return _IM.ismultiinfrastructure(data) ? data :
           Dict("multiinfrastructure" => true, "it" => Dict(_WM.wm_it_name => data))
end


"""
    parse_files(power_path, water_path, link_path)

Parses power, water, and linking data from `power_path`, `water_path`, and `link_path`,
respectively, into a single data dictionary. Returns a PowerWaterModels
multi-infrastructure data structure keyed by the infrastructure type `it`.
"""
function parse_files(power_path::String, water_path::String, link_path::String)
    joint_network_data = parse_link_file(link_path)
    _IM.update_data!(joint_network_data, parse_power_file(power_path))
    _IM.update_data!(joint_network_data, parse_water_file(water_path))

    # Store whether or not each network uses per-unit data.
    p_per_unit = get(joint_network_data["it"][_PMD.pmd_it_name], "per_unit", false)
    w_per_unit = get(joint_network_data["it"][_WM.wm_it_name], "per_unit", false)

    # Correct the network data.
    correct_network_data!(joint_network_data)

    # Ensure all datasets use the same units for power.
    resolve_units!(joint_network_data, p_per_unit, w_per_unit)

    # Return the network dictionary.
    return joint_network_data
end
