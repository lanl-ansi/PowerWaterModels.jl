# Definitions for solving a joint optimal power-water flow problem.


"Entry point for running the optimal power-water flow problem."
function solve_opwf(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return solve_model(p_file, w_file, pw_file, pwm_type, optimizer, build_opwf; kwargs...)
end


"Entry point for running the optimal power-water flow problem."
function solve_opwf(data, pwm_type, optimizer; kwargs...)
    return solve_model(data, pwm_type, optimizer, build_opwf; kwargs...)
end


"Construct the optimal power-water flow problem."
function build_opwf(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_owf(wm)

    # Power-water linking constraints.
    build_linking(pwm)

    # Add the objective that minimizes power generation costs.
    _PMD.objective_mc_min_fuel_cost(pmd)
end
