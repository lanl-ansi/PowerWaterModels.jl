function _get_pump_bus(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, a::Int, wnw::Int=wm.cnw, pnw::Int=pm.cnw)
    pump_name = parse(Int64, _WM.ref(wm, wnw, :pump, a)["source_id"][2])
    pump_mapping = filter(x -> pump_name in x.second["pump_id"], _PM.ref(pm, pnw, :pump_mapping))
    vals = collect(values(pump_mapping))[1]
    @assert all(y->y == vals["bus_id"][1], vals["bus_id"]) && all(y->y == vals["pump_id"][1], vals["pump_id"])
    return vals["bus_id"][1]
end
