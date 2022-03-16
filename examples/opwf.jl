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
gurobi_2 = JuMP.optimizer_with_attributes(() -> Gurobi.Optimizer(env), "TimeLimit" => 900.0, "NonConvex" => 2);

# Specify paths to the input data files.
power_file = "examples/data/opendss/IEEE13_CDPSM.dss";
water_file = "examples/data/epanet/cohen-modified.inp";
linking_file = "examples/data/json/zamzam.json";

# Parse the input files into a dictionary.
data = parse_files(power_file, water_file, linking_file);

# Set the partitioning for flow variables in the water model.
WM.set_flow_partitions_num!(data, 5);

# Initialize a flow partitioning function to be used in water OBBT.
flow_partition_func = x -> WM.set_flow_partitions_num!(x, 5);

# Generate WaterModels data that includes optimization-based bounds.
WM.solve_obbt_owf!(data, gurobi_1; model_type = LRDWaterModel,
    use_relaxed_network = false, solve_relaxed = true, max_iter = 3,
    flow_partition_func = flow_partition_func);

# Specify the following optimization models' types.
pwm_type = PowerWaterModel{LinDist3FlowPowerModel, PWLRDWaterModel};

# Exaggerate the costs to be small in the middle of the time period.
map(x -> data["it"]["pmd"]["nw"][string(x)]["gen"]["1"]["cost"][1] = 10.0, 9:16);
result_1 = solve_opwf(data, pwm_type, gurobi_2);
cost_1 = [data["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["cost"][1] / data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * 1000.0 for nw in 1:24];
pg_1 = [sqrt(sum((data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * result_1["solution"]["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["pg"] / 1000.0).^2)) for nw in 1:24];
V_1 = [result_1["solution"]["it"]["wm"]["nw"][string(nw)]["tank"]["10"]["V"] for nw in 1:25];

# Exaggerate the costs to be large in the middle of the time period.
map(x -> data["it"]["pmd"]["nw"][string(x)]["gen"]["1"]["cost"][1] = 1000.0, 9:16)
result_2 = solve_opwf(data, pwm_type, gurobi_2)
cost_2 = [data["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["cost"][1] / data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * 1000.0 for nw in 1:24];
pg_2 = [sqrt(sum((data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * result_2["solution"]["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["pg"] / 1000.0).^2)) for nw in 1:24];
V_2 = [result_2["solution"]["it"]["wm"]["nw"][string(nw)]["tank"]["10"]["V"] for nw in 1:25];

# Build a version of the joint model that minimizes the maximum generation deviation.
map(x -> data["it"]["pmd"]["nw"][string(x)]["gen"]["1"]["cost"][1] = 100.0, 9:16)
pwm = instantiate_model(data, pwm_type, build_opwf);
PWM.objective_min_max_generation_fluctuation(pwm);

# Solve the problem that was constructed above.
result_3 = PWM._IM.optimize_model!(pwm, optimizer = gurobi_2);
cost_3 = [data["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["cost"][1] / data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * 1000.0 for nw in 1:24];
pg_3 = [sqrt(sum((data["it"]["pmd"]["nw"][string(nw)]["settings"]["sbase"] * result_3["solution"]["it"]["pmd"]["nw"][string(nw)]["gen"]["1"]["pg"] / 1000.0).^2)) for nw in 1:24];
V_3 = [result_3["solution"]["it"]["wm"]["nw"][string(nw)]["tank"]["10"]["V"] for nw in 1:25];

df_cost = DataFrame(time = 0.5 .* collect(0:23), cost_cheap = cost_1, cost_expensive = cost_2, cost_fluc = cost_3);
CSV.write("results/pwm-demo-cost.csv", df_cost);

df_pg = DataFrame(time = 0.5 .* collect(0:23), pg_cheap = pg_1, pg_expensive = pg_2, pg_fluc = pg_3);
CSV.write("results/pwm-demo-power.csv", df_pg);

df_V = DataFrame(time = 0.5 .* collect(0:24),
    V_cheap = data["it"]["wm"]["base_length"]^3 * V_1,
    V_expensive = data["it"]["wm"]["base_length"]^3 * V_2,
    V_fluc = data["it"]["wm"]["base_length"]^3 * V_3);
CSV.write("results/pwm-demo-volume.csv", df_V);
