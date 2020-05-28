function _get_pump_from_load(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, i::Int64)
    load_source_id = _PM.ref(pm, :load, i)["source_id"][2]
    mapping = filter(x -> load_source_id in x.second["bus_id"], pm.data["pump_mapping"])

    if length(mapping) <= 0
        return nothing
    else
        pump_name = string(mapping["1"]["pump_id"][1])
        return findfirst(x -> x["source_id"][2] == pump_name, _WM.ref(wm, :pump))
    end
end

function _get_pump_bus(wm::_WM.AbstractWaterModel, pdata::Dict{String,<:Any}, a::Int64)
    pump_name = parse(Int64, _WM.ref(wm, :pump, a)["source_id"][2])
    pump_mapping = filter(x -> pump_name in x.second["pump_id"], pdata["pump_mapping"])
    vals = collect(values(pump_mapping))[1]
    @assert all(y->y == vals["bus_id"][1], vals["bus_id"]) && all(y->y == vals["pump_id"][1], vals["pump_id"])
    return vals["bus_id"][1]
end

function _get_pump_max_power(wm::_WM.AbstractWaterModel, a::Int, wnw::Int=wm.cnw)
    rho = 1000.0 # Water density (kilogram per cubic meter).
    gravity = 9.80665 # Gravitational acceleration (meter per second squared).
    pump = _WM.ref(wm, wnw, :pump, a)

    # Get the minimum efficiency used in describing the pump.
    if haskey(pump, "efficiency_curve")
        min_eff = minimum(x[2] for x in pump["efficiency_curve"])
    else
        min_eff = wm.ref[:option]["energy"]["global_efficiency"]
    end

    # Get important maximal gain and flow values.
    c = _WM._get_function_from_pump_curve(pump["pump_curve"])
    q_at_max = -0.5 * c[2] * inv(c[1]) 
    g_max = c[1] * q_at_max^2 + c[2] * q_at_max + c[3]
    q_max = (-c[2] + sqrt(c[2]^2 - 4.0*c[1]*c[3])) * inv(2.0*c[1])
    q_max = max(q_max, (-c[2] - sqrt(c[2]^2 - 4.0*c[1]*c[3])) * inv(2.0*c[1]))
   
    # TODO: This bound can probably be improved...
    return inv(min_eff) * rho * gravity * g_max * q_max
end
