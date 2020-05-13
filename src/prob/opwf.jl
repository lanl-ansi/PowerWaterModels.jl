# Definitions for solving a combined optimal power-water flow problem.

"Entry point into running the optimal power-water flow problem."
function run_opwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the optimal power-water flow problem."
function build_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
    # Power-only related variables and constraints
    _PMD.build_mc_pf(pm) # TODO: Construct a multinetwork pf.

    # Water-only related variables and constraints
    _WM.build_wf(wm)

    # Power-water related parts of the problem formulation.
    # TODO: The coupled power balance constraints will go here.

    # TODO: Add a constraint that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end

"Entry point into running the multinetwork optimal power-water flow problem."
function run_mn_opwf(pfile, wfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the multinetwork optimal power-water flow problem."
function build_mn_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel; kwargs...)
    # Power-only related variables and constraints
    _PMD.build_mc_pf(pm) # TODO: Construct a multinetwork pf.

    # Water-only related variables and constraints
    _WM.build_wf(wm)

    # Power-water related parts of the problem formulation.
    # TODO: The coupled power balance constraints will go here.

    # TODO: Add a constraint that minimizes total energy.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
