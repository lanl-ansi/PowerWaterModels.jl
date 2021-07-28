using PowerWaterModels

# Initialize shortened package names for convenience.
const _IM = PowerWaterModels._IM
const _PMD = PowerWaterModels._PMD
const _WM = PowerWaterModels._WM

# Borrow dependencies from other packages.
const JSON = _WM.JSON
const JuMP = _IM.JuMP
const Memento = _IM.Memento

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(_IM), "error")
Memento.setlevel!(Memento.getlogger(_PMD), "error")
Memento.setlevel!(Memento.getlogger(_WM), "error")
PowerWaterModels.logger_config!("error")

import Cbc
import Ipopt
import Juniper
import Logging

Logging.disable_logging(Logging.Info)

using Test

# Setup optimizers.
ipopt = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "acceptable_tol" => 1.0e-8,
    "print_level" => 0,
    "sb" => "yes",
)

cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)

juniper = JuMP.optimizer_with_attributes(
    Juniper.Optimizer,
    "nl_solver" => ipopt,
    "mip_solver" => cbc,
    "log_levels" => [],
    "branch_strategy" => :MostInfeasible,
    "time_limit" => 60.0,
)

# Setup common test data paths (from dependencies).
pmd_path = joinpath(dirname(pathof(_PMD)), "..")
wm_path = joinpath(dirname(pathof(_WM)), "..")

@testset "PowerWaterModels" begin

    include("PowerWaterModels.jl")

    include("base.jl")

    include("io.jl")

    include("data.jl")

    include("objective.jl")

    include("pwf.jl")

    include("opwf.jl")

end
