# Definitions for solving a joint optimal power-water flow problem.

"Entry point into running the optimal power-water flow problem."
function run_opwf(pfile, wfile, pwfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, pwfile, ptype, wtype, optimizer, build_opwf; kwargs...)
end


"Construct the optimal power-water flow problem."
function build_opwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints.
    _PMD.build_mn_mc_mld_simple(pm)

    # Water-only related variables and constraints.
    _WM.build_mn_wf(wm)

    for (nw, network) in _PMD.nws(pm)
        loads = _PMD.ref(pm, nw, :load) # Loads in the power network.

        # Constrain load variables if they are connected to a pump.
        for (i, load) in filter(x -> "pump_id" in keys(x.second), loads)
            constraint_pump_load(pm, wm, i, load["pump_id"]; nw=nw)
        end

        # Constrain load variables if they are not connected to a pump.
        for (i, load) in filter(x -> !("pump_id" in keys(x.second)), loads)
            constraint_fixed_load(pm, i; nw=nw)
        end
    end

    # Add a feasibility-only objective.
    _PM.objective_min_fuel_cost(pm)
end
