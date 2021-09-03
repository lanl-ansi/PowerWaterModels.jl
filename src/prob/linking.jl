function build_linking(pwm::AbstractPowerWaterModel)
    # Get important data that will be used in the modeling loop.
    pmd = _get_powermodel_from_powerwatermodel(pwm)

    for nw in _IM.nw_ids(pwm, :dep)
        # Obtain all pump loads at multinetwork index.
        pump_loads = _IM.ref(pwm, :dep, nw, :pump_load)
        
        for pump_load in values(pump_loads)
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
end