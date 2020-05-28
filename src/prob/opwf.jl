# Definitions for solving a combined optimal power-water flow problem.

"Entry point into running the optimal power-water flow problem."
function run_opwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the optimal power-water flow problem."
function build_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
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

    # TODO: Add a constraint that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end

"Entry point into running the multinetwork optimal power-water flow problem."
function run_mn_opwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the multinetwork optimal power-water flow problem."
function build_mn_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
    # Water-only related variables and constraints
    _WM.build_mn_owf(wm)

    # Power-only related variables and constraints
    _PMD.build_mc_mld(pm)

    # TODO: Add a constraint that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
