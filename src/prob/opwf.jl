# Definitions for solving a joint optimal power-water flow problem.

"Entry point for running the optimal power-water flow problem."
function run_opwf(p_file, w_file, pw_file, p_type, w_type, optimizer; kwargs...)
    return run_model(p_file, w_file, pw_file, p_type, w_type, optimizer, build_opwf; kwargs...)
end


"Construct the optimal power-water flow problem."
function build_opwf(pm::_PMD.AbstractUnbalancedPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints.
    _PMD.build_mn_mc_mld_simple(pm)

    # Water-only related variables and constraints.
    _WM.build_mn_owf(wm)

    for (nw, network) in _PMD.nws(pm)
        # Get all loads defined in the power network.
        loads = _PMD.ref(pm, nw, :load)

        # Constrain load variables if they are connected to a pump.
        for (i, load) in filter(x -> "pump_id" in keys(x.second), loads)
            constraint_pump_load(pm, wm, i, load["pump_id"]; nw=nw)
        end

        # Constrain load variables if they are not connected to a pump.
        for (i, load) in filter(x -> !("pump_id" in keys(x.second)), loads)
            constraint_fixed_load(pm, i; nw=nw)
        end
    end

    # Add the objective that minimizes power generation costs.
    _PM.objective_min_fuel_cost(pm)
end
