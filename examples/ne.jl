using Revise

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
linking_file = "examples/data/json/water-expansion.json";

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
result = solve_opwf(data, pwm_type, gurobi_2); # This should turn on all short pipes.

# This should turn on the smallest short pipe.
result = solve_ne(data, pwm_type, gurobi_2);

# data_copy = deepcopy(data);

# # This should turn on the next largest short pipe.
# for (nw, nw_data) in data_copy["it"]["wm"]["nw"]
#    map(x -> x["flow_nominal"] *= 1.005, values(nw_data["demand"]))
#    map(x -> x["flow_min"] *= 1.005, values(nw_data["demand"]))
#    map(x -> x["flow_max"] *= 1.005, values(nw_data["demand"]))
# end

# result = solve_ne(data_copy, pwm_type, gurobi_2);