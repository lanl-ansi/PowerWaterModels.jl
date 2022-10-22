# Examples Documentation

## Optimal Power-Water Flow Example

In the example script located at [`examples/opwf.jl`](https://github.com/lanl-ansi/PowerWaterModels.jl/blob/master/examples/opwf.jl), we demonstrate the utility of PowerWaterModels for exploring the tradeoffs encountered in the coordination of joint power and water distribution system operation.
Specifically, we draw inspiration from [1], where the joint [Optimal Power-Water Flow (OPWF)](@ref) problem is formalized, which coordinates tanks and pumps in the water network to improve operations in the power network.
In PowerWaterModels, similar OPWF problems can easily be constructed using a variety of power and water network formulations while forgoing the need to develop specialized algorithms.
This enables an efficient and systematic analysis of solutions under various modeling assumptions.

Within the script, `LinDist3FlowPowerModel` is based on the power flow approximation of [2], and `PWLRDWaterModel` is a piecewise-linear water flow relaxation similar to the relaxations of [3] and [4]. The example is based on benchmark data described by [1], which couples the IEEE 13-node test feeder of [5] with a synthetic municipal water network developed by [6].
Notably, the data uses a time series of twelve hours discretized into thirty minute intervals.
This analysis thus highlights the temporal modeling features of PowerWaterModels.

Joint OPWF problems are naturally geared toward understanding the tradeoffs between power and water network operations.
These tradeoffs are easily explored via modification of the joint objective function.
In the example, we test three objectives to explore these tradeoffs.
The first minimizes operational cost of the single generating unit in the power network while assuming inexpensive midday fuel prices.
The second does the same while assuming expensive midday fuel prices.
The final objective minimizes the deviation in active power generation between adjacent time steps, i.e., minimizes fluctuations in the generation profile.
Each objective has implications for optimal operations of the power network as well as the water network, where pumps are modeled as power loads and water tanks provide indirect energy storage.

The results from executing the example generate a number of plots.
In one plot, the three distinct price signals are shown.
These correspond to the various time profiles of generation cost coefficients used in the different analyses.
The remaining figures indicate how the power generation and water storage vary based on these different objective functions.  
When generation prices are high, it is less advantageous to operate water pumps, which correspond to drops in power generation and tank volumes during the midday period.
Otherwise, if generation is inexpensive, it's advantageous to operate water pumps and increase tank volumes during the midday period.
If the objective is to smooth the generation profile, it can be facilitated through careful use of pumps throughout the day.

## Sources

[1] Zamzam, A. S., Dall’Anese, E., Zhao, C., Taylor, J. A., & Sidiropoulos, N. D. (2018). Optimal water–power flow-problem: Formulation and distributed optimal solution. _IEEE Transactions on Control of Network Systems_, _6_(1), 37-47.

[2] Gan, L., & Low, S. H. (2014, August). Convex relaxations and linear approximation for optimal power flow in multiphase radial networks. In _2014 Power Systems Computation Conference_ (pp. 1-9). IEEE.

[3] Tasseff, B., Bent, R., Coffrin, C., Barrows, C., Sigler, D., Stickel, J., ... & Van Hentenryck, P. (2022). Polyhedral relaxations for optimal pump scheduling of potable water distribution networks. _arXiv preprint arXiv:2208.03551_.

[4] Vieira, B. S., Mayerle, S. F., Campos, L. M., & Coelho, L. C. (2020). Optimizing drinking water distribution system operations. _European Journal of Operational Research_, _280_(3), 1035-1050.

[5] Kersting, W. H. (1991). Radial distribution test feeders. _IEEE Transactions on Power Systems_, _6_(3), 975-985.

[6] Cohen, D., Shamir, U., & Sinai, G. (2000). Optimal operation of multi-quality water supply systems-II: The QH model. _Engineering Optimization+ A35_, _32_(6), 687-719.