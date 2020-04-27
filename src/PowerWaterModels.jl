module PowerWaterModels
    import JSON
    import JuMP
    import Memento
    import InfrastructureModels
    import MathOptInterface
    import WaterModels
    import PowerModelsDistribution

    const _MOI = MathOptInterface
    const _IM = InfrastructureModels
    const _WM = WaterModels
    const _PMD = PowerModelsDistribution

    # Create our module level logger (this will get precompiled)
    const _LOGGER = Memento.getlogger(@__MODULE__)

    # Register the module level logger at runtime so that folks can access the logger via `getlogger(PowerWaterModels)`
    # NOTE: If this line is not included then the precompiled `PowerWaterModels._LOGGER` won't be registered at runtime.
    __init__() = Memento.register(_LOGGER)

    "Suppresses information and warning messages output. For fine-grained control use the Memento package."
    function silence()
        Memento.info(_LOGGER, "Suppressing information and warning messages for the rest of this session. Use the Memento package for more fine-grained control of logging.")
        Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
        Memento.setlevel!(Memento.getlogger(WaterModels), "error")
        Memento.setlevel!(Memento.getlogger(PowerModelsDistribution), "error")
    end

    "Allows the user to set the logging level without the need to add Memento."
    function logger_config!(level)
        Memento.config!(Memento.getlogger("PowerWaterModels"), level)
    end
end
