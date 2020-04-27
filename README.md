# PowerWaterModels.jl 

Dev:
[![Build Status](https://travis-ci.org/lanl-ansi/PowerWaterModels.jl.svg?branch=master)](https://travis-ci.org/lanl-ansi/PowerWaterModels.jl)
[![codecov](https://codecov.io/gh/lanl-ansi/PowerWaterModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/PowerWaterModels.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/PowerWaterModels.jl/latest)

PowerWaterModels.jl is a Julia/JuMP Package for the joint optimization of power and water distribution networks.

**Core Problem Specifications**
* Power-Water Flow (pwf)
* Optimal Power-Water Flow (opwf)

**Core Network Formulations**
* NCNLP - nonconvex nonlinear program

## Development
Community-driven development and enhancement of PowerWaterModels is welcomed and encouraged.
Please feel free to fork this repository and share your contributions to the master branch with a pull request.
That said, it is important to keep in mind the code quality requirements and scope of PowerWaterModels before preparing a contribution.
See [CONTRIBUTING.md](https://github.com/lanl-ansi/WaterModels.jl/blob/master/CONTRIBUTING.md) for code contribution guidelines.

## Installation
PowerWaterModels.jl should be installed using the command
```julia
] add PowerWaterModels
```

## Acknowledgments
This work is conducted under the auspices of the National Nuclear Security Administration of the U.S. Department of Energy at Los Alamos National Laboratory under Contract No. 89233218CNA000001.
The code is provided under a [modified BSD license](https://github.com/lanl-ansi/PowerWaterModels.jl/blob/master/LICENSE.md) as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT), LA-CC-13-108.
