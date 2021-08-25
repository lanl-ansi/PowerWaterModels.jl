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

    nw_ids = sort(collect(_IM.nw_ids(pwm, :dep)))
    nw_ids_inner = length(nw_ids) > 1 ? nw_ids[1:end-1] : nw_ids

    for nw in nw_ids_inner
        # Obtain all pump loads at multinetwork index.
        pump_loads = _IM.ref(pwm, :dep, nw, :pump_load)
        
        for (pump_load_id, pump_load) in pump_loads
            # Constrain load variables if they are connected to a pump.
            pump_index = pump_load["pump"]["index"]
            load_index = pump_load["load"]["index"]
            constraint_pump_load(pwm, load_index, pump_index; nw = nw)
        end

        # Discern the indices for variable loads (i.e., loads connected to pumps).
        load_ids = _PMD.ids(pmd, nw, :load)
        var_load_ids = [x["load"]["index"] for x in values(pump_loads)]

        for load_index in setdiff(load_ids, var_load_ids)
            # Constrain load variables if they are not connected to a pump.
            constraint_fixed_load(pwm, load_index; nw = nw)
        end
    end

    # Add a feasibility-only objective.
    JuMP.@objective(pwm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
