# PowerWaterModels.jl Documentation

```@meta
CurrentModule = PowerWaterModels
```

## Overview
PowerWaterModels.jl is a Julia/JuMP package for steady state joint power-water distribution network optimization.
It is designed to enable computational evaluation of historical and emerging power-water network optimization formulations and algorithms using a common platform.
The code is engineered to decouple [Problem Specifications](@ref) (e.g., power-water flow, optimal power-water flow) from [Network Formulations](@ref) (e.g., mixed-integer linear, mixed-integer nonlinear).
This decoupling enables the definition of a wide variety of network optimization formulations and their comparison on common problem specifications.

## Installation
The latest stable release of PowerWaterModels can be installed using the Julia package manager with
```julia
] add PowerWaterModels
```

For the current development version, install the package using
```julia
] add PowerWaterModels#master
```

Test that the package works by executing
```julia
] test PowerWaterModels
```

## Usage at a Glance
At least one optimization solver is required to run PowerWaterModels.
The solver selected typically depends on the type of problem formulation being employed.
Installation of the JuMP interface to Juniper can be performed via the Julia package manager, i.e.,

```julia
] add Cbc Ipopt Juniper
```

```julia
using Juniper, Ipopt, Cbc
using PowerWaterModels
result = run_pwf("shamir.inp", MILPWaterModel, Cbc.Optimizer, ext=ext)
```
