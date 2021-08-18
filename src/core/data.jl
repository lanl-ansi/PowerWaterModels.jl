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


function _get_load_id_from_name(data::Dict{String,<:Any}, name::String)
    pmd_data = _PMD.get_pmd_data(data)

    if "source_type" in keys(pmd_data) && pmd_data["source_type"] == "matpower"
        return findfirst(x -> x["source_id"][2] == parse(Int64, name), pmd_data["load"])
    else
        return findfirst(x -> x["source_id"] == lowercase(name), pmd_data["load"])
    end
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
        load_key = _get_load_id_from_name(data, load_name)
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
    return get_num_networks_pmd(p_data) == _IM.get_num_networks(w_data)
end


function get_num_networks_pmd(data::Dict{String,<:Any})
    if _IM.ismultinetwork(data)
        return length(data["nw"])
    elseif _IM.has_time_series(data)
        if haskey(data["time_series"], "num_steps")
            return data["time_series"]["num_steps"]
        else
            first_key = collect(keys(data["time_series"]))[1]
            return length(data["time_series"][first_key]["time"])
        end
    else
        return 1
    end
end


function make_multinetwork(data::Dict{String,<:Any})
    # Parse the PowerModelsDistribution data.
    pmd_data = _PMD.get_pmd_data(data)

    # If the network comes from OpenDSS data, transform to a mathematical model.
    if !(haskey(pmd_data, "source_type") && pmd_data["source_type"] == "matpower")
        pmd_data = _PMD.transform_data_model(pmd_data; multinetwork = true)
    end

    # Get multinetwork properties of the power network.
    translate_p = !_IM.ismultinetwork(pmd_data)
    num_steps_p = get_num_networks_pmd(pmd_data)

    # Get multinetwork properties of the water network.
    wm_data = _WM.get_wm_data(data)
    translate_w = !_IM.ismultinetwork(wm_data)
    num_steps_w = _IM.get_num_networks(wm_data)

    # Depending on the number of steps present in each network, adjust the data.
    if num_steps_p == 1 && num_steps_w == 1
        p_data_tmp = translate_p ? _replicate_power_data(pmd_data, 1) : pmd_data
        w_data_tmp = translate_w ? _IM.replicate(wm_data, 1, _WM._wm_global_keys) : wm_data
    elseif num_steps_p == 1 && num_steps_w > 1
        w_data_tmp = translate_w ? _WM.make_multinetwork(wm_data) : wm_data

        if translate_p
            p_data_tmp = _replicate_power_data(pmd_data, num_steps_w)
        else
            if num_steps_p == num_steps_w
                p_data_tmp = pmd_data
            elseif num_steps_p == 1
                # Get water and power network indices.
                nw_id_pmd = collect(keys(pmd_data["nw"]))[1]
                nw_ids_wm = collect(keys(w_data_tmp["nw"]))

                # Assume the same power properties across all subnetworks.
                p_data_tmp = deepcopy(pmd_data)
                p_data_tmp["nw"] = Dict(nw => deepcopy(
                    pmd_data["nw"][nw_id_pmd]) for nw in nw_ids_wm)
            else
                Memento.error(_LOGGER, "Multinetworks cannot be reconciled.")
            end
        end
    elseif num_steps_p > 1 && num_steps_w == 1
        p_data_tmp = translate_p ? _make_power_multinetwork(pmd_data) : pmd_data
        w_data_tmp = translate_w ? _WM.replicate(wm_data, num_steps_p) : wm_data
    else
        p_data_tmp = translate_p ? _make_power_multinetwork(pmd_data) : pmd_data
        w_data_tmp = translate_w ? _WM.make_multinetwork(wm_data) : wm_data
    end

    # Store the (potentially modified) power and water networks.
    data["it"][_PMD.pmd_it_name] = p_data_tmp
    data["it"][_WM.wm_it_name] = w_data_tmp

    # Return the modified data dictionary.
    return data
end


function _make_power_multinetwork(p_data::Dict{String,<:Any})
    if haskey(p_data, "source_type") && p_data["source_type"] == "matpower"
        return _IM.make_multinetwork(p_data, _PMD.pmd_it_name, _PMD._pmd_global_keys)
    else
        return _PMD.transform_data_model(p_data; multinetwork = true)
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


function _modify_loads(data::Dict{String,<:Any})
    # Get the separated power and water subdatasets.
    p_data = data["it"][_PMD.pmd_it_name]
    w_data = data["it"][_WM.wm_it_name]

    # Ensure the two networks have the same multinetwork keys.
    if keys(p_data["nw"]) != keys(w_data["nw"])
        Memento.error(_LOGGER, "Multinetworks do not have the same indices.")
    end

    for nw in keys(p_data["nw"]) # Loop over all subnetworks.
        # Where pumps are linked to power network components, change the loads.
        for (k, pump_load) in data["it"]["dep"]["pump_load"]
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
