# Definitions for solving a joint power-water flow feasibility problem.


"Entry point for running the power-water flow feasibility problem."
function solve_pwf(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return solve_model(p_file, w_file, pw_file, pwm_type, optimizer, build_pwf; kwargs...)
end


"Entry point for running the power-water flow feasibility problem."
function solve_pwf(data, pwm_type, optimizer; kwargs...)
    return solve_model(data, pwm_type, optimizer, build_pwf; kwargs...)
end


"Construct the power-water flow feasibility problem."
function build_pwf(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_wf(wm)

    # Power-water linking constraints.
    build_linking(pwm)

    # Add a feasibility-only objective.
    JuMP.@objective(pwm.model, JuMP.FEASIBILITY_SENSE, 0.0)
end
