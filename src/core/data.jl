function make_consistent_networks(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any})
    num_steps_p = _IM.get_num_steps(p_data)
    num_steps_w = _IM.get_num_steps(w_data)

    if num_steps_p == num_steps_w && num_steps_p == 1
        p_data_tmp = _IM.replicate(p_data, 1, _PM._pm_global_keys)
        w_data_tmp = _IM.replicate(w_data, 1, _WM._wm_global_keys)
    elseif num_steps_p == 1 && num_steps_w > 1
        p_data_tmp = _IM.replicate(p_data, num_steps_w, _PM._pm_global_keys)
        w_data_tmp = _IM.make_multinetwork(w_data, _WM._wm_global_keys)
    elseif num_steps_p > 1 && num_steps_w == 1
        p_data_tmp = _IM.make_multinetwork(p_data, _PM._pm_global_keys)
        w_data_tmp = _IM.replicate(w_data, num_steps_p, _WM._wm_global_keys)
    end

    return p_data_tmp, w_data_tmp
end

function _get_bus_id_from_name(name::String, p_data::Dict{String,<:Any})
    name_dict = Dict(i=>bus["index"] for (i, bus) in p_data["bus"])
    return name_dict[name]
end

function _get_pump_id_from_name(name::String, w_data::Dict{String,<:Any})
    name_dict = Dict(a=>pump["index"] for (a, pump) in w_data["pump"])
    return name_dict[name]
end

function _get_loads_from_bus(p_data::Dict{String,<:Any}, i::Int64)
    return filter(x -> i in x.second["load_bus"], p_data["load"])
end

function _modify_pump_loads(p_data::Dict{String,<:Any}, pw_data::Dict{String,<:Any}, wm::_WM.AbstractWaterModel)
    for n in _IM.nw_ids(wm)
        for link in pw_data["power_water_links"]
            w_network = wm.data["nw"][string(n)]
            a = _get_pump_id_from_name(link["pump_source_id"], w_network)
            p_network = p_data["nw"][string(n)]
            i = _get_bus_id_from_name(link["load_source_id"], p_network)
            max_power = inv(p_network["baseMVA"]) * _get_pump_max_power(wm, a; nw=n) * 1.0e-6

            for (k, load) in _get_loads_from_bus(p_network, i)
                Memento.info(_LOGGER, "Modifying load bounds at bus $(i).")
                load["pd"] = max_power * ones(length(load["pd"]))
                load["qd"] = zeros(length(load["qd"]))
                load["pump_id"] = a
            end
        end
    end

    return p_data
end

function _read_networks(p_file::String, w_file::String, pw_file::String)
    # Read power distribution network data.
    if split(p_file, ".")[end] == "m" # If reading a MATPOWER file.
        p_data = _PM.parse_file(p_file)
        _scale_loads!(p_data, inv(3.0))
        _PMD.make_multiconductor!(p_data, real(3))
    else # Otherwise, use the PowerModelsDistribution parser.
        p_data = _PMD.parse_file(p_file)
    end

    w_data = _WM.parse_file(w_file) # Water distribution network data.
    pw_data = parse_json(pw_file) # Power-water network linkage data.

    # Create new network data, ensuring network sizes match.
    p_data, w_data = make_consistent_networks(p_data, w_data)

    # Return three data dictionaries.
    return p_data, w_data, pw_data
end

function _scale_loads!(p_data::Dict{String,<:Any}, scalar::Float64)
    for (i, load) in p_data["load"]
        load["pd"] *= scalar
    end
end
