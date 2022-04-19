import CSV
import Gurobi
import JuMP
import WaterModels

using DataFrames

using Revise
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

for (nw, nw_data) in data["it"]["pmd"]["nw"]
    for (i, load) in nw_data["load"]
        load["pd"] = load["pd"] .* 1.0
    end
end


# Set the partitioning for flow variables in the water model.
WM.set_flow_partitions_num!(data, 5);

# Initialize a flow partitioning function to be used in water OBBT.
flow_partition_func = x -> WM.set_flow_partitions_num!(x, 5);

# Specify the following optimization models' types.
pwm_type = PowerWaterModel{NFAUPowerModel, LRDWaterModel};

# Solve the network expansion problem.
result = solve_opwf_ne(data, pwm_type, gurobi_2);