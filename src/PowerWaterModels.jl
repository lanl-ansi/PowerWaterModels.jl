module PowerWaterModels
    import InfrastructureModels
    import InfrastructureModels: optimize_model!, @im_fields, ismultinetwork, nw_id_default
    import PowerModels
    import PowerModelsDistribution
    import WaterModels

    # Initialize shortened package names for convenience.
    const _PM = PowerModels
    const _PMD = PowerModelsDistribution
    const _WM = WaterModels
    const _IM = InfrastructureModels
    const _MOI = _IM._MOI # MathOptInterface

    # Borrow dependencies from other packages.
    const JSON = _WM.JSON
    const JuMP = _IM.JuMP
    const Memento = _IM.Memento

    # Create our module level logger (this will get precompiled)
    const _LOGGER = Memento.getlogger(@__MODULE__)

    # Register the module level logger at runtime so that folks can access the logger via `getlogger(PowerWaterModels)`
    # NOTE: If this line is not included then the precompiled `PowerWaterModels._LOGGER` won't be registered at runtime.
    __init__() = Memento.register(_LOGGER)

    "Suppresses information and warning messages output. For fine-grained control use the Memento package."
    function silence()
        Memento.info(_LOGGER, "Suppressing information and warning messages for "
            * "the rest of this session. Use the Memento package for more "
            * "fine-grained control of logging.")
        Memento.setlevel!(Memento.getlogger(_IM), "error")
        Memento.setlevel!(Memento.getlogger(_WM), "error")
        Memento.setlevel!(Memento.getlogger(_PMD), "error")
    end

    "Allows the user to set the logging level without the need to add Memento."
    function logger_config!(level)
        Memento.config!(Memento.getlogger("PowerWaterModels"), level)
    end

    const _pwm_global_keys = union(_PMD._pmd_global_keys, _WM._wm_global_keys)

    include("io/json.jl")
    include("io/common.jl")

    include("core/base.jl")
    include("core/constants.jl")
    include("core/data.jl")
    include("core/helpers.jl")
    include("core/constraint.jl")
    include("core/objective.jl")
    include("core/types.jl")

    include("prob/pwf.jl")
    include("prob/opwf.jl")

    # This must come last to support automated export.
    include("core/export.jl")
end
