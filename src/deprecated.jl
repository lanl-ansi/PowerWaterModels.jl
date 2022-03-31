# Function deprecation warnings.
# Can be removed in a breaking release after 09/01/2022.
function run_model(args...; kwargs...)
    @warn("`run_model` has been replaced with `solve_model`", maxlog = 1)
    solve_model(args...; kwargs...)
end


function run_opwf(args...; kwargs...)
    @warn("`run_opwf` has been replaced with `solve_opwf`", maxlog = 1)
    solve_opwf(args...; kwargs...)
end


function run_ne(args...; kwargs...)
    @warn("`run_ne` has been replaced with `solve_ne`", maxlog = 1)
    solve_ne(args...; kwargs...)
end


function run_pwf(args...; kwargs...)
    @warn("`run_pwf` has been replaced with `solve_pwf`", maxlog = 1)
    solve_pwf(args...; kwargs...)
end