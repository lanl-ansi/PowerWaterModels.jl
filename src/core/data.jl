function correct_network_data!(data::Dict{String, Any})
    # Correct and prepare power network data.
    _PMD.correct_network_data!(data; make_pu = true)

    # Correct and prepare water network data.
    _WM.correct_network_data!(data)
end


function _get_load_id_from_name(data::Dict{String,<:Any}, name::String, power_source_type::String; nw::String = _PMD.nw_id_default)
    pmd_data = _PMD.get_pmd_data(data)

    if power_source_type == "matpower"
        return findfirst(x -> x["source_id"][2] == parse(Int64, name), pmd_data["nw"][nw]["load"])
    else
        return findfirst(x -> x["source_id"] == lowercase(name), pmd_data["nw"][nw]["load"])
    end
end


function assign_pump_loads!(data::Dict{String, Any})
    # Ensure power and water network multinetworks are consistent.
    if !networks_are_consistent(data["it"][_PMD.pmd_it_name], data["it"][_WM.wm_it_name])
        Memento.error(_LOGGER, "Multinetworks cannot be reconciled.")
    end

    # Ensure the multinetwork indices are the same across power and water data sets.
    nw_ids_pmd = sort(collect(keys(data["it"][_PMD.pmd_it_name]["nw"])))
    nw_ids_wm = sort(collect(keys(data["it"][_WM.wm_it_name]["nw"])))
    @assert nw_ids_pmd == nw_ids_wm
    
    # Ensure the power source data type has been specified.
    @assert haskey(data["it"][_PMD.pmd_it_name], "source_type")
    power_source_type = data["it"][_PMD.pmd_it_name]["source_type"]

    for nw in nw_ids_pmd
        # Assign the pump loads at every multinetwork index.
        _assign_pump_loads!(data, power_source_type, nw)
    end
end

function _assign_pump_loads!(data::Dict{String, Any}, power_source_type::String, nw::String)
    for pump_load in values(data["it"]["dep"]["nw"][nw]["pump_load"])
        # Change the indices of the pump to match network subdataset.
        pump_name = pump_load["pump"]["source_id"]
        pumps = data["it"][_WM.wm_it_name]["nw"][nw]["pump"]
        pump_name = typeof(pump_name) == String ? pump_name : string(pump_name)
        pump = pumps[findfirst(x -> pump_name == x["source_id"][2], pumps)]
        pump_load["pump"]["index"] = pump["index"]

        # Change the indices of the load to match network subdataset.
        load_name = pump_load["load"]["source_id"]
        loads = data["it"][_PMD.pmd_it_name]["nw"][nw]["load"]
        load_name = typeof(load_name) == String ? load_name : string(load_name)
        load_key = _get_load_id_from_name(data, load_name, power_source_type; nw = nw)
        pump_load["load"]["index"] = parse(Int, load_key)

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
    pmd_source_type = pmd_data["source_type"]
 
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

        # Ensure consistency of the multinetwork keys.
        p_nw = collect(keys(p_data_tmp["nw"]))[1]
        w_nw = collect(keys(w_data_tmp["nw"]))[1]
        p_data_tmp["nw"][w_nw] = pop!(p_data_tmp["nw"], p_nw)
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
    p_data_tmp["source_type"] = pmd_source_type
    data["it"][_PMD.pmd_it_name] = p_data_tmp
    data["it"][_WM.wm_it_name] = w_data_tmp

    # Replicate the dependency dictionary, if necessary.
    if !_IM.ismultinetwork(data["it"]["dep"])
        num_steps = get_num_networks_pmd(p_data_tmp)
        data["it"]["dep"] = _IM.replicate(data["it"]["dep"], num_steps, Set{String}())
    end

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


function _replicate_power_data(data::Dict{String,<:Any}, num_networks::Int64)
    pmd_data = _PMD.get_pmd_data(data)
    return _IM.replicate(pmd_data, num_networks, _PMD._pmd_math_global_keys)
end


function _modify_loads!(data::Dict{String,<:Any})
    # Get the separated power and water subdatasets.
    p_data = data["it"][_PMD.pmd_it_name]
    w_data = data["it"][_WM.wm_it_name]

    # Ensure the multinetwork indices are the same across power and water data sets.
    nw_ids_pmd = sort([parse(Int, x) for x in collect(keys(p_data["nw"]))])
    nw_ids_wm = sort([parse(Int, x) for x in collect(keys(w_data["nw"]))])
    nw_ids_inner = length(nw_ids_wm) > 1 ? nw_ids_wm[1:end-1] : nw_ids_wm
    @assert nw_ids_pmd == nw_ids_wm

    # Get important scaling data.
    base_mass = get(w_data, "base_mass", 1.0)
    base_length = get(w_data, "base_length", 1.0)
    base_time = get(w_data, "base_time", 1.0)

    rho_s = _WM._calc_scaled_density(base_mass, base_length)
    g_s = _WM._calc_scaled_gravity(base_length, base_time)

    for nw in nw_ids_inner # Loop over all subnetworks.
        # Where pumps are linked to power network components, change the loads.
        factor = _get_power_conversion_factor(data, string(nw))

        for pump_load in values(data["it"]["dep"]["nw"][string(nw)]["pump_load"])
            # Obtain maximum pump power in units used by the water network.
            pump = w_data["nw"][string(nw)]["pump"][string(pump_load["pump"]["index"])]
            node_fr = w_data["nw"][string(nw)]["node"][string(pump["node_fr"])]
            node_to = w_data["nw"][string(nw)]["node"][string(pump["node_to"])]
            P_max = _WM._calc_pump_power_max(pump, node_fr, node_to, rho_s, g_s)

            # Change the loads associated with pumps.
            load = p_data["nw"][string(nw)]["load"][string(pump_load["load"]["index"])]
            load_power = inv(sum(x -> x > 0.0, load["pd"])) * factor * P_max
            load["pd"][load["pd"] .> 0.0] .= load_power
            load["qd"][load["qd"] .> 0.0] .= 0.0 # Assume no reactive load.
        end
    end
end


function _scale_loads!(p_data::Dict{String,<:Any}, scalar::Float64)
    for load in values(p_data["load"])
        load["pd"] *= scalar
    end
end


function _get_power_conversion_factor(data::Dict{String,<:Any}, nw::String)::Float64
    # Get the conversion factor for power used by the power network.
    data_pmd = _PMD.get_pmd_data(data)

    if haskey(data_pmd["nw"][string(nw)], "baseMVA")
        base_mva_pmd = data_pmd["nw"][string(nw)]["baseMVA"]
    else
        sbase = data_pmd["nw"][string(nw)]["settings"]["sbase"]
        psf = data_pmd["nw"][string(nw)]["settings"]["power_scale_factor"]
        base_mva_pmd = sbase / psf
    end

    # Watts per PowerModelsDistribution power unit.
    base_power_pmd = 1.0e6 * base_mva_pmd 
    
    # Get the conversion factor for power used by the water network.
    data_wm = _WM.get_wm_data(data)
    transform_mass = _WM._calc_mass_per_unit_transform(data_wm)
    transform_time = _WM._calc_time_per_unit_transform(data_wm)
    transform_length = _WM._calc_length_per_unit_transform(data_wm)

    # Scalar for WaterModels power units per Watt.
    scalar_power_wm = transform_mass(1.0) * transform_length(1.0)^2 / transform_time(1.0)^3

    # Return the power conversion factor for pumps.
    return (1.0 / scalar_power_wm) / base_power_pmd
end