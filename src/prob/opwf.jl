# Definitions for solving a combined optimal power-water flow problem.

"Entry point into running the optimal power-water flow problem."
function run_opwf(pfile, wfile, pwfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, pwfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the optimal power-water flow problem."
function build_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
    # Power-only related variables and constraints
    _PMD.build_mc_mld(pm)

    # Water-only related variables and constraints
    _WM.build_wf(wm)

    # Add constraints related to pump and non-pump loads.
    for (i, load) in _PMD.ref(pm, :load)
        if "pump_id" in keys(load)
            constraint_pump_load(pm, wm, i, load["pump_id"])
        else
            constraint_fixed_load(pm, wm, i)
        end
    end

    # TODO: Add an objective that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end

"Entry point into running the multinetwork optimal power-water flow problem."
function run_mn_opwf(pfile, wfile, pwfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, pwfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the multinetwork optimal power-water flow problem."
function build_mn_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
    # Water-only related variables and constraints
    _WM.build_mn_owf(wm)

    # Power-only related variables and constraints
    _PMD.build_mc_mld(pm)

    # TODO: Add an objective that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
