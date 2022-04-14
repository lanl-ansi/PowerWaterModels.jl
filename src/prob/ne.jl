# Definitions for solving a joint optimal network expansion problem.


"Entry point for running the optimal network expansion problem."
function solve_ne(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return solve_model(p_file, w_file, pw_file, pwm_type, optimizer, build_ne; kwargs...)
end


"Entry point for running the optimal network expansion problem."
function solve_ne(data, pwm_type, optimizer; kwargs...)
    return solve_model(data, pwm_type, optimizer, build_ne; kwargs...)
end


"Construct the optimal optimal network expansion problem."
function build_ne(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple_ne(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_ne(wm)

    # Power-water linking constraints.
    build_linking(pwm)

    # Add the objective that minimizes joint network expansion costs.
    objective_ne(pwm)
end