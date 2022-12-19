function _get_powermodel_from_powerwatermodel(pwm::AbstractPowerWaterModel{PMDT,WMT}) where {PMDT,WMT}
    # Power-only variables and constraints.
    return PMDT(pwm.model, pwm.data, pwm.setting, pwm.solution,
        pwm.ref, pwm.var, pwm.con, pwm.sol, pwm.sol_proc, pwm.ext)
end


function _get_watermodel_from_powerwatermodel(pwm::AbstractPowerWaterModel{PMDT,WMT}) where {PMDT,WMT}
    # Water-only variables and constraints.
    return WMT(pwm.model, pwm.data, pwm.setting, pwm.solution,
        pwm.ref, pwm.var, pwm.con, pwm.sol, pwm.sol_proc, pwm.ext)
end
