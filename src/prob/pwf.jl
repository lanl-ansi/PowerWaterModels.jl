# Definitions for solving a joint power-water flow feasibility problem.

"Entry point for running the power-water flow feasibility problem."
function run_pwf(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return run_model(p_file, w_file, pw_file, pwm_type, optimizer, build_pwf; kwargs...)
end


"Construct the power-water flow feasibility problem."
function build_pwf(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_wf(wm)

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

    # Add a feasibility-only objective.
    JuMP.@objective(pwm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
