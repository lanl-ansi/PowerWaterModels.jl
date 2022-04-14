"""
    objective_min_max_generation_fluctuation(pm::AbstractPowerWaterModel)
"""
function objective_min_max_generation_fluctuation(pwm::AbstractPowerWaterModel)
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    z = JuMP.@variable(pmd.model, lower_bound = 0.0)
    nw_ids = sort(collect(_PMD.nw_ids(pmd)))

    for n in 2:length(nw_ids)
        nw_1, nw_2 = nw_ids[n-1], nw_ids[n]

        for (i, gen) in _PMD.ref(pmd, nw_2, :gen)
            pg_1 = _PMD.var(pmd, nw_1, :pg, i)
            pg_2 = _PMD.var(pmd, nw_2, :pg, i)

            JuMP.@constraint(pwm.model, z >= pg_1[1] - pg_2[1])
            JuMP.@constraint(pwm.model, z >= pg_2[1] - pg_1[1])
            JuMP.@constraint(pwm.model, z >= pg_1[2] - pg_2[2])
            JuMP.@constraint(pwm.model, z >= pg_2[2] - pg_1[2])
            JuMP.@constraint(pwm.model, z >= pg_1[3] - pg_2[3])
            JuMP.@constraint(pwm.model, z >= pg_2[3] - pg_1[3])
        end
    end

    return JuMP.@objective(pwm.model, _IM.JuMP.MIN_SENSE, z);
end


"""
    objective_ne(pm::AbstractPowerWaterModel)
"""
function objective_ne(pwm::AbstractPowerWaterModel)
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    power_ne_cost = _PMD.objective_ne(pmd)

    wm = _get_watermodel_from_powerwatermodel(pwm)
    water_ne_cost = _WM.objective_ne(wm)

    total_ne_cost = power_ne_cost + water_ne_cost
    return JuMP.@objective(pwm.model, JuMP.MIN_SENSE, total_ne_cost)
end