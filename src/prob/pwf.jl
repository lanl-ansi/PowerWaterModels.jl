# Definitions for solving a combined water and power flow feasibility problem.

"Entry point into running the power-water flow feasibility problem."
function run_pwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_pwf; kwargs...)
end

"Construct the power-water flow feasibility problem."
function build_pwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints
    _PMD.build_mc_mld(pm)

    # Water-only related variables and constraints
    _WM.build_wf(wm)

    for (i, load) in _PMD.ref(pm, :load)
        a = _get_pump_from_load(pm, wm, i)

        if a != nothing
            constraint_pump_load(pm, wm, i, a)
        else
            constraint_fixed_load(pm, wm, i)
        end
    end

    # Add a feasibility-only objective.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end

"Entry point into running the multinetwork power-water flow feasibility problem."
function run_mn_pwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_pwf; kwargs...)
end

"Construct the multinetwork power-water flow feasbility problem."
function build_mn_pwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints
    _PMD.build_mc_mld_uc(pm) # TODO: Construct a multinetwork pf.

    # Water-only related variables and constraints
    _WM.build_mn_wf(wm)

    # Add a feasibility-only objective.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
