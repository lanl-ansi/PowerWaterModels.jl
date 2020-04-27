using PowerWaterModels

import Memento
import MathOptInterface
import InfrastructureModels
import WaterModels
import PowerModels

const _MOI = MathOptInterface
const _IM = InfrastructureModels
const _WM = WaterModels
const _PM = PowerModels

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(_IM), "error")
Memento.setlevel!(Memento.getlogger(_WM), "error")
Memento.setlevel!(Memento.getlogger(_PM), "error")
PowerWaterModels.logger_config!("error")

import Cbc
import Ipopt
import JuMP
import Juniper

using Test

# Setup for optimizers.
ipopt = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-8, print_level=0, sb="yes")
cbc = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
juniper = JuMP.with_optimizer(Juniper.Optimizer, nl_solver=ipopt, mip_solver=cbc, log_levels=[])

@testset "PowerWaterModels" begin

end
