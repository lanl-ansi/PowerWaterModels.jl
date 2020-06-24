"""
    parse_json(path)

Parses a JavaScript Object Notation (JSON) file from the file path `path` and
returns a dictionary.
"""
function parse_json(path::String)
    dict = JSON.parsefile(path)
    dict["per_unit"] = false
    return dict
end

"""
    parse_files(p_path, w_path, pw_path)

Parses power, water, and power-water linking input files and returns three data
dictionaries for power, water, and power-water linking data, respectively.
"""
function parse_files(p_path::String, w_path::String, pw_path::String)
    # Read power distribution network data.
    if split(p_path, ".")[end] == "m" # If reading a MATPOWER file.
        p_data = _PM.parse_file(p_path)
        _scale_loads!(p_data, inv(3.0))
        _PMD.make_multiconductor!(p_data, real(3))
    else # Otherwise, use the PowerModelsDistribution parser.
        p_data = _PMD.parse_file(p_path)
    end

    w_data = _WM.parse_file(w_path) # Water distribution network data.
    pw_data = parse_json(pw_path) # Power-water network linkage data.

    # Create new network data, ensuring network sizes match.
    p_data, w_data = make_consistent_networks(p_data, w_data)

    # TODO: Add data consistency checks, here.

    # Return three data dictionaries.
    return p_data, w_data, pw_data
end
