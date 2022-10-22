"""
Objective for minimizing the maximum difference between time-adjacent power
generation variables. Note that this function introduces a number of
auxiliary variables and constraints to appropriately model the objective.
Mathematically, the objective and auxiliary terms are modeled as follows:
```math
    \\begin{aligned}
    & \\text{minimize} & & z \\\\
    & \\text{subject to} & & z \\geq pg_{i, c, t} - pg_{i, c, t-1}, \\, \\forall i \\in \\mathcal{G}, \\, \\forall c \\in \\mathcal{C}, \\, \\forall t \\in \\{2, 3, \\dots, T\\} \\\\
    & & & z \\geq pg_{i, c, t-1} - pg_{i, c, t}, \\, \\forall i \\in \\mathcal{G}, \\, \\forall c \\in \\mathcal{C}, \\, \\forall t \\in \\{2, 3, \\dots, T\\} \\\\
    & & & z \\geq 0 \\\\
    & & & x \\in \\mathcal{X},
    \\end{aligned}
```
where ``\\mathcal{G}`` is the set of generators, ``\\mathcal{C}`` is the set of
conductors, and ``\\{2, 3, \\dots, T\\}`` are the non-starting time indices.
Further, ``x \\in \\mathcal{X}`` represents the remainder of the problem
formulation, i.e., variables and constraints not relevant to this description.
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