# PowerWaterModels exports everything except internal symbols, which are defined as
# those whose name starts with an underscore. If you don't want all of these
# symbols in your environment, then use `import PowerWaterModels` instead of
# `using PowerWaterModels`.

# Do not add PowerWaterModels-defined symbols to this exclude list. Instead, rename
# them with an underscore.

const _EXCLUDE_SYMBOLS = [Symbol(@__MODULE__), :eval, :include]

for sym in names(@__MODULE__, all=true)
    sym_string = string(sym)

    if sym in _EXCLUDE_SYMBOLS || startswith(sym_string, "_") || startswith(sym_string, "@_")
        continue
    end

    if !(Base.isidentifier(sym) || (startswith(sym_string, "@") &&
         Base.isidentifier(sym_string[2:end])))
       continue
    end

    @eval export $sym
end

# the follow items are also exported for user friendliness when calling
# `using PowerWaterModels`

# so that users do not need to import JuMP to use a solver with PowerWaterModels
import PowerWaterModels._IM.JuMP: with_optimizer
export with_optimizer

# so that users do not need to import JuMP to use a solver with PowerWaterModels
# note does appear to be work with JuMP v0.20, but throws "could not import" warning
import PowerWaterModels._IM.JuMP: optimizer_with_attributes
export optimizer_with_attributes

import PowerWaterModels._IM.JuMP: TerminationStatusCode
export TerminationStatusCode

import PowerWaterModels._IM.JuMP: ResultStatusCode
export ResultStatusCode

for status_code_enum in [TerminationStatusCode, ResultStatusCode]
    for status_code in instances(status_code_enum)
        @eval import PowerWaterModels._IM.JuMP: $(Symbol(status_code))
        @eval export $(Symbol(status_code))
    end
end

# Export PowerModels modeling types for ease of use.
power_models = names(PowerModelsDistribution)
power_models = filter(x -> endswith(string(x), "PowerModel"), power_models)
power_models = filter(x -> !occursin("Abstract", string(x)), power_models)

for x in power_models
    @eval import PowerModelsDistribution: $(x)
    @eval export $(x)
end

# Export WaterModels modeling types for ease of use.
water_models = names(WaterModels)
water_models = filter(x -> endswith(string(x), "WaterModel"), water_models)
water_models = filter(x -> !occursin("Abstract", string(x)), water_models)

for x in water_models
    @eval import WaterModels: $(x)
    @eval export $(x)
end

# Export from InfrastructureModels.
export ids, ref, var, con, sol, nw_ids, nws, optimize_model!
