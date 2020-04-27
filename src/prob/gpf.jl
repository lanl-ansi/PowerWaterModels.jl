# Definitions for running a feasible combined water and power flow

"Entry point into running the water-power flow feasibility problem."
function solve_pwf(gfile, pfile, gtype, ptype, optimizer; kwargs...)
    return solve_model(gfile, pfile, gtype, ptype, optimizer, post_pwf; kwargs...)
end

"Construct the water flow feasbility problem."
function post_pwf(pm::_PM.AbstractPowerModel, gm::_WM.AbstractWaterModel; kwargs...)
    # Power-only related variables and constraints
    post_pwf_pm(pm)

    # Water-only related variables and constraints
    post_pwf_wm(gm)
end

"Post the electric power variables and constraints."
function post_pwf_pm(pm::_PM.AbstractPowerModel; kwargs...)
    _PM.variable_bus_voltage(pm, bounded=false)
    _PM.variable_gen_power(pm, bounded=false)
    _PM.variable_branch_power(pm, bounded=false)
    _PM.variable_dcline_power(pm, bounded=false)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
        _PM.constraint_voltage_magnitude_setpoint(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)

        # PV Bus Constraints
        if length(_PM.ref(pm, :bus_gens, i)) > 0 && !(i in _PM.ids(pm,:ref_buses))
            _PM.constraint_voltage_magnitude_setpoint(pm, i)

            for j in _PM.ref(pm, :bus_gens, i)
                _PM.constraint_gen_setpoint_active(pm, j)
            end
        end
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_dcline_setpoint_active(pm, i)

        f_bus = _PM.ref(pm, :bus)[dcline["f_bus"]]

        if f_bus["bus_type"] == 1
            _PM.constraint_voltage_magnitude_setpoint(pm, f_bus["index"])
        end

        t_bus = _PM.ref(pm, :bus)[dcline["t_bus"]]

        if t_bus["bus_type"] == 1
            _PM.constraint_voltage_magnitude_setpoint(pm, t_bus["index"])
        end
    end
end

"Post the water flow variables and constraints."
function post_pwf_wm(gm::_WM.AbstractWaterModel; kwargs...)
end
