module PowerWaterModels
    import JSON
    import JuMP
    import Memento
    import PowerModelsDistribution
    import WaterModels

    const _PMD = PowerModelsDistribution
    const _WM = WaterModels

    const _IM = _PMD._IM # InfrastructureModels
    const _PM = _PMD._PM # PowerModels
    const _MOI = _IM._MOI # MathOptInterface

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

    include("io/common.jl")

    include("core/base.jl")
    include("core/data.jl")
    include("core/constraint.jl")

    include("prob/pwf.jl")
    include("prob/opwf.jl")

    # This must come last to support automated export.
    include("core/export.jl")
end
