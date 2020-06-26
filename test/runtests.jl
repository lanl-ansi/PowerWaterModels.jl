using PowerWaterModels

import Memento

const _IM = PowerWaterModels._IM
const _PM = PowerWaterModels._PM
const _PMD = PowerWaterModels._PMD
const _WM = PowerWaterModels._WM

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(_IM), "error")
Memento.setlevel!(Memento.getlogger(_PM), "error")
Memento.setlevel!(Memento.getlogger(_PMD), "error")
Memento.setlevel!(Memento.getlogger(_WM), "error")
PowerWaterModels.logger_config!("error")

import Cbc
import Ipopt
import JuMP
import Juniper

using Test

# Setup for optimizers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1.0e-8, "print_level"=>0, "sb"=>"yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt, "mip_solver"=>cbc, "log_levels"=>[])

# Setup common test data paths (from dependencies).
pm_path = joinpath(dirname(pathof(_PM)), "..")
pmd_path = joinpath(dirname(pathof(_PMD)), "..")
wm_path = joinpath(dirname(pathof(_WM)), "..")

@testset "PowerWaterModels" begin

    include("PowerWaterModels.jl")

    include("base.jl")

    include("io.jl")

    include("data.jl")

    include("pwf.jl")

    include("opwf.jl")

end
