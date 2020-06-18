function _get_pump_max_power(wm::_WM.AbstractWaterModel, a::Int; nw::Int=wm.cnw)
    rho = 1000.0 # Water density (kilogram per cubic meter).
    gravity = 9.80665 # Gravitational acceleration (meter per second squared).
    pump = _WM.ref(wm, nw, :pump, a)

    # Get the minimum efficiency used in describing the pump.
    if haskey(pump, "efficiency_curve")
        min_eff = minimum(x[2] for x in pump["efficiency_curve"])
    else
        min_eff = wm.ref[:option]["energy"]["global_efficiency"]
    end

    # Get important maximal gain and flow values.
    c = _WM._get_function_from_pump_curve(pump["pump_curve"])
    q_at_max = -0.5 * c[2] * inv(c[1]) 
    g_max = c[1] * q_at_max^2 + c[2] * q_at_max + c[3]
    q_max = (-c[2] + sqrt(c[2]^2 - 4.0*c[1]*c[3])) * inv(2.0*c[1])
    q_max = max(q_max, (-c[2] - sqrt(c[2]^2 - 4.0*c[1]*c[3])) * inv(2.0*c[1]))
   
    # TODO: This bound can probably be improved...
    return inv(min_eff) * rho * gravity * g_max * q_max
end
