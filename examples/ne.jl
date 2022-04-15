import CSV
import Gurobi
import JuMP
import WaterModels

using DataFrames
using PowerWaterModels

const WM = WaterModels
const PWM = PowerWaterModels

# Specify solver options.
env = Gurobi.Env(); # Initialize a common Gurobi environment.
gurobi_1 = JuMP.optimizer_with_attributes(() -> Gurobi.Optimizer(env), "OutputFlag" => 0, "MIPGap" => 0.0);
gurobi_2 = JuMP.optimizer_with_attributes(() -> Gurobi.Optimizer(env), "TimeLimit" => 60.0, "NonConvex" => 2);

# Specify paths to the input data files.
power_file = "examples/data/opendss/IEEE13_CDPSM.dss";
water_file = "examples/data/epanet/cohen-ne.inp";
linking_file = "examples/data/json/expansion.json";

# Parse the input files into a dictionary.
data = parse_files(power_file, water_file, linking_file);
WM.propagate_topology_status!(data);

# Set the partitioning for flow variables in the water model.
WM.set_flow_partitions_num!(data, 5);

# Initialize a flow partitioning function to be used in water OBBT.
flow_partition_func = x -> WM.set_flow_partitions_num!(x, 5);

# Generate WaterModels data that includes optimization-based bounds.
WM.solve_obbt!(data, WM.build_mn_ne, gurobi_1; model_type = LRDWaterModel,
   solve_relaxed = true, max_iter = 3, flow_partition_func = flow_partition_func);

# Specify the following optimization models' types.
pwm_type = PowerWaterModel{NFAUPowerModel, LRDWaterModel};

# Solve the network expansion problem.
result = solve_ne(data, pwm_type, gurobi_2);