""
function instantiate_model(pfile::String, wfile::String, ptype::Type, wtype::Type, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    pdata, wdata = _PMD.parse_file(pfile), _WM.parse_file(wfile)
    return instantiate_model(pdata, wdata, ptype, wtype, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
end

""
function instantiate_model(pdata::Dict{String,<:Any}, wdata::Dict{String,<:Any}, ptype::Type, wtype::Type, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    # Instantiate the PowerModelsDistribution object.
    pm = _PMD.instantiate_mc_model(pdata, ptype, m->nothing; ref_extensions=pm_ref_extensions)

    # Instantiate the WaterModels object.
    wm = _WM.instantiate_model(wdata, wtype, m->nothing; ref_extensions=wm_ref_extensions, jump_model=pm.model)

    # Build the corresponding problem.
    build_method(pm, wm, kwargs=kwargs)

    # Return the two individual *Models objects.
    return pm, wm
end

""
function run_model(pdata::Dict{String,<:Any}, wdata::Dict{String,<:Any}, ptype::Type, wtype::Type, optimizer, build_method; pm_solution_processors=[], wm_solution_processors=[], pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    start_time = time()
    pm, wm = instantiate_model(pdata, wdata, ptype, wtype, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
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
function run_model(pfile::String, wfile::String, ptype::Type, wtype::Type, optimizer, build_method; pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), wm_ref_extensions=[], kwargs...)
    pdata, wdata = _PMD.parse_file(pfile), _WM.parse_file(wfile)
    return run_model(pdata, wdata, ptype, wtype, optimizer, build_method; pm_ref_extensions=pm_ref_extensions, wm_ref_extensions=wm_ref_extensions, kwargs...)
end
