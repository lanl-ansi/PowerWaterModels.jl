function constraint_pump_load(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, i::Int, a::Int, pnw::Int=pm.cnw, wnw::Int=wm.cnw)
    efficiency = 0.85 # TODO: How can the efficiency curve be used?
    rho = 1000.0 # Water density (kilogram per cubic meter).
    gravity = 9.80665 # Gravitational acceleration (meter per second squared).
    coeff = inv(efficiency) * rho * gravity
    q, g = _WM.var(wm, wnw)[:qp][a], _WM.var(wm, wnw)[:g][a]

    pump_power = JuMP.@NLexpression(pm.model, inv(pm.data["baseMVA"]) * 1.0e-6 * g * q^2)
    pd = _PM.ref(pm, pnw, :load, i)["pd"]
    z = _PM.var(pm, pnw, :z_demand, i)
    JuMP.@NLconstraint(pm.model, pump_power == pd[1] * z)
end
