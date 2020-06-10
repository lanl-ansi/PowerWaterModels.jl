using PowerWaterModels

import Memento
import MathOptInterface
import InfrastructureModels
import PowerModels
import PowerModelsDistribution
import WaterModels

const _MOI = MathOptInterface
const _IM = InfrastructureModels
const _PM = PowerModels
const _PMD = PowerModelsDistribution
const _PWM = PowerWaterModels
const _WM = WaterModels

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
pm_path = joinpath(dirname(pathof(PowerModelsDistribution)), "..")
wm_path = joinpath(dirname(pathof(WaterModels)), "..")

@testset "PowerWaterModels" begin

    include("pwf.jl")

    include("opwf.jl")

end