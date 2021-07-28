"Root of the PowerWaterModels formulation hierarchy."
abstract type AbstractPowerWaterModel{
    T1<:_PMD.AbstractUnbalancedPowerModel,
    T2<:_WM.AbstractWaterModel,
} <: _IM.AbstractInfrastructureModel end


"A macro for adding the base PowerWaterModels fields to a type definition."
_IM.@def pwm_fields begin
    PowerWaterModels.@im_fields
end


function instantiate_model(
    data::Dict{String,<:Any},
    model_type::Type,
    build_method::Function;
    kwargs...,
)
    return _IM.instantiate_model(
        data,
        model_type,
        build_method,
        ref_add_core!,
        _pwm_global_keys;
        kwargs...,
    )
end


"""
    instantiate_model(p_file, w_file, link_file, model_type, build_method; kwargs...)

    Instantiates and returns a PowerWaterModels modeling object from power and water input
    files `p_file` and `w_file`. Additionally, `link_file` is an input file that links
    power and water networks, `model_type` is the power-water modeling type, and
    `build_method` is the build method for the problem specification being considered.
"""
function instantiate_model(
    p_file::String,
    w_file::String,
    link_file::String,
    model_type::Type,
    build_method::Function;
    kwargs...,
)
    # Read power, water, and linking data from files.
    data = parse_files(p_file, w_file, link_file)

    # Instantiate PowerModels and WaterModels modeling objects.
    return instantiate_model(data, model_type, build_method; kwargs...)
end


"""
    run_model(
        data, model_type, optimizer, build_method;
        ref_extensions, solution_processors, kwargs...)

    Instantiates and solves the joint PowerWaterModels model from input data `data`, where
    `model_type` is the power-water modeling type, `build_method` is the build method for
    the problem specification being considered, `ref_extensions` is an array of power and
    water modeling extensions, and `solution_processors` is an array of power and water
    modeling solution data postprocessors. Returns a dictionary of model results.
"""
function run_model(
    data::Dict{String,<:Any},
    model_type::Type,
    optimizer,
    build_method::Function;
    ref_extensions = [],
    solution_processors = [],
    relax_integrality::Bool = false,
    kwargs...,
)
    start_time = time()

    pwm = instantiate_model(
        data,
        model_type,
        build_method;
        ref_extensions = ref_extensions,
        ext = get(kwargs, :ext, Dict{Symbol,Any}()),
        setting = get(kwargs, :setting, Dict{String,Any}()),
        jump_model = get(kwargs, :jump_model, JuMP.Model()),
    )

    Memento.debug(_LOGGER, "pwm model build time: $(time() - start_time)")

    start_time = time()

    solution_processors = transform_solution_processors(pwm, solution_processors)

    result = _IM.optimize_model!(
        pwm,
        optimizer = optimizer,
        solution_processors = solution_processors,
        relax_integrality = relax_integrality,
    )

    Memento.debug(_LOGGER, "pwm model solution time: $(time() - start_time)")

    return result
end


function transform_solution_processors(
    pwm::AbstractPowerWaterModel,
    solution_processors::Array,
)
    pm = _get_powermodel_from_powerwatermodel(pwm)
    wm = _get_watermodel_from_powerwatermodel(pwm)

    for (i, solution_processor) in enumerate(solution_processors)
        model_type = methods(solution_processor).ms[1].sig.types[2]

        if model_type <: _PMD.AbstractPowerModel
            solution_processors[i] = (pwm, sol) -> solution_processor(pm, sol)
        elseif model_type <: _WM.AbstractWaterModel
            solution_processors[i] = (pwm, sol) -> solution_processor(wm, sol)
        end
    end

    return solution_processors
end


"""
    run_model(p_file, w_file, link_file, model_type, optimizer, build_method; kwargs...)

    Instantiates and solves a PowerWaterModels modeling object from power and water input
    files `p_file` and `w_file`. Additionally, `link_file` is an input file that links
    power and water networks, `model_type` is the power-water modeling type, and
    `build_method` is the build method for the problem specification being considered.
    Returns a dictionary of model results.
"""
function run_model(
    p_file::String,
    w_file::String,
    link_file::String,
    model_type::Type,
    optimizer,
    build_method::Function;
    kwargs...,
)
    # Read power, water, and linking data from files.
    data = parse_files(p_file, w_file, link_file)

    # Solve the model and return the result dictionary.
    return run_model(data, model_type, optimizer, build_method; kwargs...)
end


function ref_add_core!(ref::Dict{Symbol,<:Any})
    # Populate the PowerModels portion of the `ref` dictionary.
    _PMD._ref_add_core!(ref)

    # Populate the WaterModels portion of the `ref` dictionary.
    _WM.ref_add_core!(ref)
end
