function make_three_phase_power_network(data::Dict{String,<:Any})
    PowerModelsDistribution.make_multiconductor!(data, 3)

    for (i, load) in data["load"]
        load["pd"] = [load["pd"][1]*0.333, load["pd"][2]*0.333, load["pd"][3]*0.333]
        load["qd"] = [load["qd"][1]*0.333, load["qd"][2]*0.333, load["qd"][3]*0.333]
    end

    return data
end
