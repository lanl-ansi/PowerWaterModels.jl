function constraint_fixed_load(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel, i::Int64)
    JuMP.@constraint(pm.model, _PMD.var(pm, :z_demand, i) == 1.0)
end
