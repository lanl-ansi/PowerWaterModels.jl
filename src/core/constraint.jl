function constraint_fixed_load(pm::_PMD.AbstractUnbalancedPowerModel, i::Int64; nw::Int=pm.cnw)
    JuMP.@constraint(pm.model, _PMD.var(pm, nw, :z_demand, i) == 1.0)
end


function constraint_pump_load(pwm::AbstractPowerWaterModel, i::Int, a::Int; nw::Int=wm.cnw)
    power_load = _get_power_load_expression(pwm, i, nw=nw)
    pump_load = _get_pump_load_expression(pwm, a, nw=nw)
    c = JuMP.@constraint(pm.model, pump_load == power_load)
end


function _get_power_load_expression(pm::_PMD.AbstractUnbalancedPowerModel, i::Int; nw::Int=pm.cnw)
    pd = sum(_PM.ref(pm, nw, :load, i)["pd"])
    z = _PM.var(pm, nw, :z_demand, i)
    return JuMP.@expression(pm.model, pd * z)
end


function _get_pump_load_expression(pm::_PMD.AbstractUnbalancedPowerModel, wm::_WM.AbstractWaterModel, a::Int; nw::Int=pm.cnw)
    scaling = 1.0e-6 * inv(_PM.ref(pm, nw, :baseMVA)) # Scaling factor for power.
    return JuMP.@expression(wm.model, scaling * _WM.var(wm, nw, :P_pump, a))
end