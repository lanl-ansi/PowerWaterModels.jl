function _get_powermodel_from_powerwatermodel(pwm::AbstractPowerWaterModel)
    # Determine the PowerModelsDistribution modeling type.
    pmd_type = typeof(pwm).parameters[1]

    # Power-only variables and constraints.
    return pmd_type(pwm.model, pwm.data, pwm.setting, pwm.solution,
        pwm.ref, pwm.var, pwm.con, pwm.sol, pwm.sol_proc, pwm.ext)
end


function _get_watermodel_from_powerwatermodel(pwm::AbstractPowerWaterModel)
    # Determine the WaterModels modeling type.
    wm_type = typeof(pwm).parameters[2]

    # Water-only variables and constraints.
    return wm_type(pwm.model, pwm.data, pwm.setting, pwm.solution,
        pwm.ref, pwm.var, pwm.con, pwm.sol, pwm.sol_proc, pwm.ext)
end
