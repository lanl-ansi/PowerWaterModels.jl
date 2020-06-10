function constraint_fixed_load(pm::_PM.AbstractPowerModel, i::Int64; pnw::Int=pm.cnw)
    JuMP.@constraint(pm.model, _PMD.var(pm, pnw, :z_demand, i) == 1.0)
end

function constraint_pump_load(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, i::Int, a::Int; pnw::Int=pm.cnw, wnw::Int=wm.cnw)
    power_load = _get_power_load_expression(pm, i, pnw=pnw)
    pump_load = _get_pump_load_expression(pm, wm, a, wnw=wnw)
    JuMP.@constraint(pm.model, pump_load == power_load)
end

function _get_power_load_expression(pm::_PM.AbstractPowerModel, i::Int; pnw::Int=pm.cnw)
    pd = sum(_PM.ref(pm, pnw, :load, i)["pd"])
    z = _PM.var(pm, pnw, :z_demand, i)
    return JuMP.@expression(pm.model, pd * z)
end

function _get_pump_load_expression(pm::_PM.AbstractPowerModel, wm::_WM.AbstractUndirectedFlowModel, a::Int; wnw::Int=wm.cnw)
    coeff = _get_pump_power_coeff(pm, wm)
    q, g = _WM.var(wm, wnw, :q, a), _WM.var(wm, wnw, :g, a)
    return JuMP.@expression(wm.model, coeff * g * q)
end

function _get_pump_load_expression(pm::_PM.AbstractPowerModel, wm::_WM.AbstractDirectedFlowModel, a::Int; wnw::Int=wm.cnw)
    coeff = _get_pump_power_coeff(pm, wm)
    qp, g = _WM.var(wm, wnw, :qp, a), _WM.var(wm, wnw, :g, a)
    return JuMP.@expression(wm.model, coeff * g * qp)
end

function _get_pump_power_coeff(pm::_PM.AbstractPowerModel, wm::_WM.AbstractUndirectedFlowModel)
    efficiency = 0.85 # TODO: How can the efficiency curve be used?
    rho = 1000.0 # Water density (kilogram per cubic meter).
    gravity = 9.80665 # Gravitational acceleration (meter per second squared).
    coeff = inv(pm.data["baseMVA"]) * 1.0e-6 * inv(efficiency) * rho * gravity
end
