mutable struct PowerWaterModel{T1,T2} <: AbstractPowerWaterModel{T1,T2}
    @pwm_fields
end

RelaxedPowerModels = Union{_PMD.LinDist3FlowPowerModel}
RelaxedWaterModels = Union{_WM.LRDWaterModel,_WM.PWLRDWaterModel}
RelaxedPowerWaterModel = PowerWaterModel{<:RelaxedPowerModels,<:RelaxedWaterModels}
