function networks_are_consistent(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any})
    return _IM.get_num_networks(p_data) == _IM.get_num_networks(w_data)
end

function make_consistent_networks(p_data::Dict{String,<:Any}, w_data::Dict{String,<:Any})
    # Check if the networks need to be translated to multinetwork.
    translate_p = !_IM.ismultinetwork(p_data)
    translate_w = !_IM.ismultinetwork(w_data)

    # Get the maximum number of steps represented by each network.
    num_steps_p = _get_num_power_networks(p_data)
    num_steps_w = _IM.get_num_networks(w_data)

    # Depending on the number of steps present in each network, adjust the data.
    if num_steps_p == num_steps_w && num_steps_p == 1
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

function _get_num_power_networks(p_data::Dict{String,<:Any})
    if haskey(p_data, "source_type") && p_data["source_type"] == "matpower"
        return _IM.get_num_networks(p_data)
    elseif _IM.ismultinetwork(p_data)
        return length(p_data["nw"])
    elseif _IM.has_time_series(p_data)
        pattern_key = collect(keys(p_data["time_series"]))[1]
        return length(p_data["time_series"][pattern_key]["time"])
    else
        return 1
    end
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
        return _replicate_pmd_data(p_data, num_networks)
    end
end

function _replicate_pmd_data(p_data::Dict{String,<:Any}, num_networks::Int64)
    time = collect(1.0:1.0:num_networks)
    values = ones(num_networks)

    p_data_tmp = deepcopy(p_data)
    p_data_tmp["time_series"] = Dict("tmp"=>Dict("time"=>time, "values"=>values,
        "replace"=>true, "offset"=>0.0, "source_id"=>"tmp"))

    for (i, load) in p_data_tmp["load"]
        load["dummy"] = [0.0]
        load["time_series"] = Dict("dummy"=>"tmp")
    end

    return _PMD.transform_data_model(p_data_tmp; build_multinetwork=true)
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

function _modify_loads(p_data::Dict{String,<:Any}, pw_data::Dict{String,<:Any}, wm::_WM.AbstractWaterModel)
    if haskey(p_data, "source_type") && p_data["source_type"] == "matpower"
        return _modify_matpower_loads(p_data, pw_data, wm)
    else
        return _modify_opendss_loads(p_data, pw_data, wm)
    end
end

function _modify_opendss_loads(p_data::Dict{String,<:Any}, pw_data::Dict{String,<:Any}, wm::_WM.AbstractWaterModel)
    # TODO: Flesh out this function.
    return p_data
end

function _modify_matpower_loads(p_data::Dict{String,<:Any}, pw_data::Dict{String,<:Any}, wm::_WM.AbstractWaterModel)
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

function _scale_loads!(p_data::Dict{String,<:Any}, scalar::Float64)
    for (i, load) in p_data["load"]
        load["pd"] *= scalar
    end
end
