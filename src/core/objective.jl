"""
    objective_min_max_generation_fluctuation(pm::AbstractPowerModel)
"""
function objective_min_max_generation_fluctuation(pm::_PM.AbstractPowerModel)
    z = JuMP.@variable(pm.model, lower_bound = 0.0)
    nw_ids = sort(collect(_PM.nw_ids(pm)))

    for n in 2:length(nw_ids)
        nw_1, nw_2 = nw_ids[n-1], nw_ids[n]

        for (i, gen) in _PMD.ref(pm, nw_2, :gen)
            pg_1 = _PM.var(pm, nw_1, :pg, i)
            pg_2 = _PM.var(pm, nw_2, :pg, i)

            JuMP.@constraint(pm.model, z >= pg_1[1] - pg_2[1])
            JuMP.@constraint(pm.model, z >= pg_2[1] - pg_1[1])
            JuMP.@constraint(pm.model, z >= pg_1[2] - pg_2[2])
            JuMP.@constraint(pm.model, z >= pg_2[2] - pg_1[2])
            JuMP.@constraint(pm.model, z >= pg_1[3] - pg_2[3])
            JuMP.@constraint(pm.model, z >= pg_2[3] - pg_1[3])
        end
    end

    return JuMP.@objective(pm.model, _IM._MOI.MIN_SENSE, z);
end