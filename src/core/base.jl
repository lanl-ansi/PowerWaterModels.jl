""
function instantiate_model(wfile::String, pfile::String, wtype::Type, ptype::Type, build_method; wext=[], pext=[], kwargs...)
    wdata, pdata = [_WM.parse_file(wfile), _PM.parse_file(pfile)]
    return instantiate_model(wdata, pdata, wtype, ptype, build_method; pext=pext, kwargs...)
end

""
function instantiate_model(wdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, wtype::Type, ptype::Type, build_method; wext=[], pext=[], kwargs...)
    # Instantiate the separate (empty) infrastructure models.
    wm = _WM.instantiate_model(wdata, wtype, m->nothing; ref_extensions=wext)
    pm = _PM.instantiate_model(pdata, ptype, m->nothing; ref_extensions=pext)

    # Unify all the optimization models.
    pm.model = wm.model

    # Build the corresponding problem.
    build_method(pm, wm, kwargs=kwargs)

    return wm, pm
end

""
function solve_model(wdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, wtype::Type, ptype::Type, optimizer, build_method; gsp=[], psp=[], wext=[], pext=[], kwargs...)
    start_time = time()
    wm, pm = instantiate_model(wdata, pdata, wtype, ptype, build_method; wext=wext, pext=pext, kwargs...)
    Memento.debug(_LOGGER, "gpm model build time: $(time() - start_time)")

    start_time = time()
    water_result = _IM.optimize_model!(wm, optimizer=optimizer, solution_processors=gsp)
    power_result = _IM.build_result(pm, water_result["solve_time"]; solution_processors=psp)
    Memento.debug(_LOGGER, "gpm model solution time: $(time() - start_time)")

    # Create a combined water-power result object.
    result = water_result # Contains most of the result data, already.
    result["solution"] = merge(water_result["solution"], power_result["solution"])

    # Return the combined result dictionary.
    return result
end

""
function solve_model(wfile::String, pfile::String, wtype::Type, ptype::Type, optimizer, build_method; wext=[], pext=[], kwargs...)
    wdata, pdata = [_WM.parse_file(wfile), _PM.parse_file(pfile)]
    return solve_model(wdata, pdata, wtype, ptype, optimizer, build_method; wext=wext, pext=pext, kwargs...)
end
