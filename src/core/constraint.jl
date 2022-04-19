function constraint_fixed_load(pwm::AbstractPowerWaterModel, i::Int; nw::Int = _IM.nw_id_default)
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    z = _PMD.var(pmd, nw, :z_demand, i)
    JuMP.@constraint(pmd.model, z == 1.0)
end


function constraint_pump_load(pwm::AbstractPowerWaterModel, i::Int, a::Int; nw::Int = _IM.nw_id_default)
    power_load = _get_power_load_expression(pwm, i, nw = nw)
    pump_load = _get_pump_load_expression(pwm, a, nw = nw)
    factor = _get_power_conversion_factor(pwm.data, string(nw))
    JuMP.@constraint(pwm.model, factor * pump_load == power_load)
end


"""
    constraint_budget_ne(pm::AbstractPowerWaterModel)
"""
function constraint_budget_ne(pwm::AbstractPowerWaterModel)
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    power_ne_cost = _PMD.objective_ne(pmd)

    wm = _get_watermodel_from_powerwatermodel(pwm)
    water_ne_cost = _WM.objective_ne(wm)

    total_ne_cost = power_ne_cost + water_ne_cost
    first_nw_id = sort(collect(_PMD.nw_ids(pmd)))[1]
    budget_ne = _IM.ref(pwm, :dep, first_nw_id, :budget_ne)    

    JuMP.@constraint(pwm.model, total_ne_cost <= budget_ne)
end


function _get_power_load_expression(pwm::AbstractPowerWaterModel, i::Int; nw::Int = _IM.nw_id_default)
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    pd = sum(_PMD.ref(pmd, nw, :load, i)["pd"])
    z = _PMD.var(pmd, nw, :z_demand, i)
    return JuMP.@expression(pmd.model, pd * z)
end


function _get_pump_load_expression(pwm::AbstractPowerWaterModel, i::Int; nw::Int = _IM.nw_id_default)
    wm = _get_watermodel_from_powerwatermodel(pwm)
    return _WM.var(wm, nw, :P_pump, i)
end