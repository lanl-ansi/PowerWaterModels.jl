function constraint_fixed_load(pm::_PM.AbstractPowerModel, i::Int64; nw::Int=pm.cnw)
    JuMP.@constraint(pm.model, _PMD.var(pm, nw, :z_demand, i) == 1.0)
end


function constraint_pump_load(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, i::Int, a::Int; nw::Int=wm.cnw)
    power_load = _get_power_load_expression(pm, i, nw=nw)
    pump_load = _get_pump_load_expression(pm, wm, a, nw=nw)
    c = JuMP.@constraint(pm.model, pump_load == power_load)
end


function _get_power_load_expression(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    pd = sum(_PM.ref(pm, nw, :load, i)["pd"])
    z = _PM.var(pm, nw, :z_demand, i)
    return JuMP.@expression(pm.model, pd * z)
end


function _get_pump_load_expression(pm::_PM.AbstractPowerModel, wm::_WM.AbstractNCModel, a::Int; nw::Int=pm.cnw)
    coeff = _get_pump_power_coeff(pm, wm; nw=nw)
    q, g = _WM.var(wm, nw, :q_pump, a), _WM.var(wm, nw, :g_pump, a)
    return JuMP.@expression(wm.model, coeff * g * q)
end


function _get_pump_load_expression(pm::_PM.AbstractPowerModel, wm::_WM.AbstractNCDModel, a::Int; nw::Int=pm.cnw)
    coeff = _get_pump_power_coeff(pm, wm; nw=nw)
    qp, g = _WM.var(wm, nw, :qp_pump, a), _WM.var(wm, nw, :g_pump, a)
    return JuMP.@expression(wm.model, coeff * g * qp)
end


function _get_pump_power_coeff(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; nw::Int=pm.cnw)
    efficiency = 0.85 # TODO: How can the efficiency curve be used?
    scalar = 1.0e-6 * inv(_PM.ref(pm, nw, :baseMVA)) # Scaling factor for power.
    coeff = scalar * inv(efficiency) * _WM._DENSITY * _WM._GRAVITY
end
