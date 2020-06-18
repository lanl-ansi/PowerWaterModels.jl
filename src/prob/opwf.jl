# Definitions for solving a combined optimal power-water flow problem.

"Entry point into running the optimal power-water flow problem."
function run_opwf(pfile, wfile, pwfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, pwfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end

"Construct the optimal power-water flow problem."
function build_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints.
    _PMD.build_mn_mc_mld(pm)

    # Water-only related variables and constraints.
    _WM.build_mn_wf(wm)

    # Add constraints related to loads.
    for (nw, network) in _WM.nws(wm)
        for (i, load) in _PMD.ref(pm, nw, :load)
            if "pump_id" in keys(load)
                constraint_pump_load(pm, wm, i, load["pump_id"], nw=nw)
            else
                constraint_fixed_load(pm, i, nw=nw)
            end
        end
    end

    # Add a feasibility-only objective.
    _PM.objective_min_fuel_cost(pm)
end
