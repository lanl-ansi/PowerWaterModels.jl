""
function instantiate_model(pfile::String, wfile::String, pwfile::String, ptype::Type, wtype::Type, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    pwdata = parse_json(pwfile)
    pdata, wdata = _PMD.parse_file(pfile), _WM.parse_file(wfile)
    return instantiate_model(pdata, wdata, pwdata, ptype, wtype, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
end

""
function instantiate_model(pdata::Dict{String,<:Any}, wdata::Dict{String,<:Any}, pwdata::Dict{String,<:Any}, ptype::Type, wtype::Type, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    # Instantiate the WaterModels object.
    wm = _WM.instantiate_model(wdata, wtype, m->nothing; ref_extensions=wm_ref_extensions)

    for link in pwdata["power_water_links"]
        a = _get_pump_id_from_name(link["pump_id"], wdata)
        i = _get_bus_id_from_name(link["bus_id"], pdata)
        max_power = inv(pdata["baseMVA"]) * _get_pump_max_power(wm, a) * 1.0e-6

        for (k, load) in _get_loads_from_bus(pdata, i)
            Memento.info(_LOGGER, "Modifying load bounds at bus $(link["bus_id"]).")
            load["pd"] = inv(3.0) * max_power * ones(length(load["pd"]))
            load["pump_id"] = a
        end
    end

    # Instantiate the PowerModelsDistribution object.
    pm = _PMD.instantiate_mc_model(pdata, ptype, m->nothing; ref_extensions=pm_ref_extensions, jump_model=wm.model)

    # Build the corresponding problem.
    build_method(pm, wm)

    # Return the two individual *Models objects.
    return pm, wm
end

""
function run_model(pdata::Dict{String,<:Any}, wdata::Dict{String,<:Any}, pwdata::Dict{String,<:Any}, ptype::Type, wtype::Type, optimizer, build_method; pm_solution_processors=[], wm_solution_processors=[], pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    start_time = time()
    pm, wm = instantiate_model(pdata, wdata, pwdata, ptype, wtype, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
    Memento.debug(_LOGGER, "pwm model build time: $(time() - start_time)")

    start_time = time()
    power_result = _IM.optimize_model!(pm, optimizer=optimizer, solution_processors=pm_solution_processors)
    water_result = _IM.build_result(wm, power_result["solve_time"]; solution_processors=wm_solution_processors)
    Memento.debug(_LOGGER, "pwm model solution time: $(time() - start_time)")

    # Create a combined water-power result object.
    result = power_result # Contains most of the result data, already.

    # TODO: There could possibly be component name clashes, here, later on.
    result["solution"] = merge(power_result["solution"], water_result["solution"])

    # Return the combined result dictionary.
    return result
end

""
function run_model(pfile::String, wfile::String, pwfile::String, ptype::Type, wtype::Type, optimizer, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    pwdata = parse_json(pwfile)
    pdata, wdata = _PMD.parse_file(pfile), _WM.parse_file(wfile)
    return run_model(pdata, wdata, pwdata, ptype, wtype, optimizer, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
end
