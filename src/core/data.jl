function correct_network_data!(data::Dict{String, Any})
    # Correct and prepare linking data.
    assign_pump_loads!(data)

    # Correct and prepare power network data.
    _PMD.correct_network_data!(data; make_pu = true)

    # Correct and prepare water network data.
    _WM.correct_network_data!(data)

    # Correct linking data again.
    assign_pump_loads!(data)
end


function assign_pump_loads!(data::Dict{String, Any})
    for pump_load in values(data["it"]["dep"]["pump_load"])
        # Change the indices of the pump to match network subdataset.
        pump_name = pump_load["pump"]["source_id"]
        pumps = data["it"][_WM.wm_it_name]["pump"]
        pump_name = typeof(pump_name) == String ? pump_name : string(pump_name)
        pump = pumps[findfirst(x -> pump_name == x["source_id"][2], pumps)]
        pump_load["pump"]["index"] = pump["index"]

        # Change the indices of the load to match network subdataset.
        load_name = pump_load["load"]["source_id"]
        loads = data["it"][_PMD.pmd_it_name]["load"]
        load_name = typeof(load_name) == String ? load_name : string(load_name)
        load_key = findfirst(x -> lowercase(load_name) == x["source_id"], loads)
        pump_load["load"]["index"] = load_key

        # Check if either of the components or the dependency is inactive.
        load_is_inactive = loads[load_key]["status"] == _PMD.DISABLED
        pump_is_inactive = pump["status"] == _WM.STATUS_INACTIVE
        pump_load_is_inactive = pump_load["status"] == STATUS_INACTIVE

        if (load_is_inactive || pump_is_inactive) || pump_load_is_inactive
            # If any of the above statuses are inactive, all are inactive.
            loads[load_key]["status"] = _PMD.DISABLED
            pump["status"] = _WM.STATUS_INACTIVE
            pump_load["status"] = STATUS_INACTIVE
        end
    end
end


function networks_are_consistent(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any})
    return _IM.get_num_networks(p_data) == _IM.get_num_networks(w_data)
end


function make_multinetworks(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any})
    # If the network comes from OpenDSS data, transform to a mathematical model.
    if !(haskey(p_data, "source_type") && p_data["source_type"] == "matpower")
        p_data = _PMD.transform_data_model(p_data; build_multinetwork=true)
    end

    # Check if the networks need to be translated to multinetwork.
    translate_p = !_IM.ismultinetwork(p_data)
    translate_w = !_IM.ismultinetwork(w_data)

    # Get the maximum number of steps represented by each network.
    num_steps_p = _IM.get_num_networks(p_data)
    num_steps_w = _IM.get_num_networks(w_data)

    # Depending on the number of steps present in each network, adjust the data.
    if num_steps_p == 1 && num_steps_w == 1
        p_data_tmp = translate_p ? _replicate_power_data(p_data, 1) : p_data
        w_data_tmp = translate_w ? _IM.replicate(w_data, 1, _WM._wm_global_keys) : w_data
    elseif num_steps_p == 1 && num_steps_w > 1
        p_data_tmp = translate_p ? _replicate_power_data(p_data, num_steps_w) : p_data
        w_data_tmp = translate_w ? _IM.make_multinetwork(w_data, _WM._wm_global_keys) : w_data
    elseif num_steps_p > 1 && num_steps_w == 1
        p_data_tmp = translate_p ? _make_power_multinetwork(p_data) : p_data
        w_data_tmp = translate_w ? _IM.replicate(w_data, num_steps_p, _WM._wm_global_keys) : w_data
    else
        p_data_tmp = translate_p ? _make_power_multinetwork(p_data) : p_data
        w_data_tmp = translate_w ? _IM.make_multinetwork(w_data, _WM._wm_global_keys) : w_data
    end

    # Return the (potentially modified) power and water networks.
    return p_data_tmp, w_data_tmp
end


function _make_power_multinetwork(p_data::Dict{String,<:Any})
    if haskey(p_data, "source_type") && p_data["source_type"] == "matpower"
        return _IM.make_multinetwork(p_data, _PM._pm_global_keys)
    else
        return _PMD.transform_data_model(p_data; build_multinetwork=true)
    end
end


function _replicate_power_data(p_data::Dict{String,<:Any}, num_networks::Int64)
    if haskey(p_data, "source_type") && p_data["source_type"] == "matpower"
        return _IM.replicate(p_data, num_networks, _PM._pm_global_keys)
    else
        return _IM.replicate(p_data, num_networks, _PMD._pmd_math_global_keys)
    end
end


function _get_pump_from_name(name::String, w_data::Dict{String,<:Any})
    pump_id = findfirst(x -> x["source_id"][2] == name, w_data["pump"])
    return w_data["pump"][pump_id]
end


function _get_load_from_name(name::String, p_data::Dict{String,<:Any})
    if "source_type" in keys(p_data) && p_data["source_type"] == "matpower"
        load_id = findfirst(x -> x["source_id"][2] == parse(Int64, name), p_data["load"])
    else
        load_id = findfirst(x -> x["source_id"] == lowercase(name), p_data["load"])
    end

    return p_data["load"][load_id]
end


function _modify_loads(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any}, pw_data::Dict{String,<:Any})
    # Ensure the two networks have the same multinetwork keys.
    if keys(p_data["nw"]) != keys(w_data["nw"])
        Memento.error(_LOGGER, "Multinetworks do not have the same indices.")
    end

    for nw in keys(p_data["nw"]) # Loop over all subnetworks.
        # Where pumps are linked to power network components, change the loads.
        for link in pw_data["power_water_links"]
            # Estimate maximum pump power in units used by the power network.
            base_power = 1.0e-6 * inv(p_data["nw"][nw]["baseMVA"])
            pump = _get_pump_from_name(link["pump_source_id"], w_data["nw"][nw])
            node_fr = w_data["nw"][nw]["node"][string(pump["node_fr"])]
            node_to = w_data["nw"][nw]["node"][string(pump["node_to"])]
            max_pump_power = base_power * _WM._calc_pump_power_max(pump, node_fr, node_to)

            # Change the loads associated with pumps.
            load = _get_load_from_name(link["load_source_id"], p_data["nw"][nw])
            load_power = inv(sum(x -> x > 0.0, load["pd"])) * max_pump_power
            load["pd"][load["pd"] .> 0.0] .= load_power
            load["qd"][load["qd"] .> 0.0] .= 0.0 # Assume no reactive load.

            # Add an index variable for the pump within the load object.
            load["pump_id"] = pump["index"]
        end
    end

    # Return the modified power network data.
    return p_data
end


function _scale_loads!(p_data::Dict{String,<:Any}, scalar::Float64)
    for (i, load) in p_data["load"]
        load["pd"] *= scalar
    end
end
