# Definitions for solving a budget-constrained joint optimal power-water flow problem.


"Entry point for running the budget-constrained optimal power-water flow problem."
function solve_opwf_ne(p_file, w_file, pw_file, pwm_type, optimizer; kwargs...)
    return solve_model(p_file, w_file, pw_file, pwm_type, optimizer, build_opwf_ne; kwargs...)
end


"Entry point for running the budget-constrained optimal power-water flow problem."
function solve_opwf_ne(data, pwm_type, optimizer; kwargs...)
    return solve_model(data, pwm_type, optimizer, build_opwf_ne; kwargs...)
end


"Construct the budget-constrained optimal power-water flow problem."
function build_opwf_ne(pwm::AbstractPowerWaterModel)
    # Power-only related variables and constraints.
    pmd = _get_powermodel_from_powerwatermodel(pwm)
    _PMD.build_mn_mc_mld_simple(pmd)

    # Water-only related variables and constraints.
    wm = _get_watermodel_from_powerwatermodel(pwm)
    _WM.build_mn_owf(wm)

    # Power-water linking constraints.
    build_linking(pwm)

    # Constraints on the total expansion budget.
    constraint_budget_ne(pwm)

    # Add the objective that minimizes power generation costs.
    _PMD.objective_mc_min_fuel_cost(pmd)
end