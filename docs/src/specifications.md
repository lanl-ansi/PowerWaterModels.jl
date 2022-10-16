# Problem Specifications
In these specifications, `_PMD` refers to `PowerModelsDistribution` and `_WM` refers to `WaterModels`.

## Power-Water Flow (PWF)
### Inherited Variables and Constraints
```julia
# Power-only related variables and constraints.
pmd = _get_powermodel_from_powerwatermodel(pwm)
_PMD.build_mn_mc_mld_simple(pmd)

# Water-only related variables and constraints.
wm = _get_watermodel_from_powerwatermodel(pwm)
_WM.build_mn_wf(wm)
```

### Constraints
```julia
# Power-water linking constraints.
build_linking(pwm)
```

### Objective
```julia
# Add a feasibility-only objective.
JuMP.@objective(pwm.model, JuMP.FEASIBILITY_SENSE, 0.0)
```

## Optimal Power-Water Flow (OPWF)
```julia
# Power-only related variables and constraints.
pmd = _get_powermodel_from_powerwatermodel(pwm)
_PMD.build_mn_mc_mld_simple(pmd)

# Water-only related variables and constraints.
wm = _get_watermodel_from_powerwatermodel(pwm)
_WM.build_mn_owf(wm)
```

### Constraints
```julia
# Power-water linking constraints.
build_linking(pwm)
```

### Objective
```julia
# Add the objective that minimizes power generation costs.
_PMD.objective_mc_min_fuel_cost(pmd)
```