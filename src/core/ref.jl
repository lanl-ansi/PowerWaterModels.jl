function _get_power_conversion_factor(pwm::AbstractPowerWaterModel; nw::Int = _IM.nw_id_default)::Float64
    # Get the conversion factor for power used by the power network.
    data_pmd = _PMD.get_pmd_data(pwm.data)

    if haskey(data_pmd["nw"][string(nw)], "baseMVA")
        base_mva_pmd = data_pmd["nw"][string(nw)]["baseMVA"]
    else
        sbase = data_pmd["nw"][string(nw)]["settings"]["sbase"]
        psf = data_pmd["nw"][string(nw)]["settings"]["power_scale_factor"]
        base_mva_pmd = sbase / psf
    end

    # Watts per PowerModelsDistribution power unit.
    base_power_pmd = 1.0e6 * base_mva_pmd 
    
    # Get the conversion factor for power used by the water network.
    data_wm = _WM.get_wm_data(pwm.data)
    transform_mass = _WM._calc_mass_per_unit_transform(data_wm)
    transform_time = _WM._calc_time_per_unit_transform(data_wm)
    transform_length = _WM._calc_length_per_unit_transform(data_wm)

    # Scalar for WaterModels power units per Watt.
    scalar_power_wm = transform_mass(1.0) * transform_length(1.0)^2 / transform_time(1.0)^3

    # Return the power conversion factor for pumps.
    return (1.0 / scalar_power_wm) / base_power_pmd
end