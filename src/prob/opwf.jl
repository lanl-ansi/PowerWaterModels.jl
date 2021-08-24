# Definitions for solving a joint optimal power-water flow problem.

"Entry point for running the optimal power-water flow problem."
function run_opwf(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return run_model(p_file, w_file, pw_file, pwm_type, optimizer, build_opwf; kwargs...)
end


"Construct the optimal power-water flow problem."
function build_opwf(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_owf(wm)

    for (nw, network) in _PMD.nws(pmd)
        # Get all loads defined in the power network.
        loads = _PMD.ref(pmd, nw, :load)

        # Constrain load variables if they are connected to a pump.
        for (i, load) in filter(x -> "pump_id" in keys(x.second), loads)
            # constraint_pump_load(pwm, i, load["pump_id"]; nw=nw)
        end

        # Constrain load variables if they are not connected to a pump.
        for (i, load) in filter(x -> !("pump_id" in keys(x.second)), loads)
            # constraint_fixed_load(pwm, i; nw=nw)
        end
    end

    # Add the objective that minimizes power generation costs.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.objective_mc_min_fuel_cost(pmd)
end
