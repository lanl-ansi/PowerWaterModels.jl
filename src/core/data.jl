function make_three_phase_power_network(data::Dict{String,<:Any})
    PowerModelsDistribution.make_multiconductor!(data, 3)

    for (i, load) in data["load"]
        load["pd"] = [load["pd"][1]*0.333, load["pd"][2]*0.333, load["pd"][3]*0.333]
        load["qd"] = [load["qd"][1]*0.333, load["qd"][2]*0.333, load["qd"][3]*0.333]
    end

    return data
end

function _get_bus_id_from_name(name::String, pdata::Dict{String,<:Any})
    name_dict = Dict(i=>bus["index"] for (i, bus) in pdata["bus"])
    return name_dict[name]
end

function _get_pump_id_from_name(name::String, wdata::Dict{String,<:Any})
    name_dict = Dict(a=>pump["index"] for (a, pump) in wdata["pump"])
    return name_dict[name]
end

function _get_loads_from_bus(pdata::Dict{String,<:Any}, i::Int64)
    return filter(x -> i in x.second["load_bus"], pdata["load"])
end
