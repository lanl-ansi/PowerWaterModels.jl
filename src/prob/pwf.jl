# Definitions for solving a joint power-water flow feasibility problem.

"Entry point for running the power-water flow feasibility problem."
function run_pwf(pfile, wfile, pwfile, ptype, wtype, optimizer; kwargs...)
    return run_model(pfile, wfile, pwfile, ptype, wtype, optimizer, build_pwf; kwargs...)
end


"Construct the power-water flow feasibility problem."
function build_pwf(pm::_PM.AbstractPowerModel, wm::_WM.AbstractWaterModel)
    # Power-only related variables and constraints.
    _PMD.build_mn_mc_mld_simple(pm)

    # Water-only related variables and constraints.
    _WM.build_mn_wf(wm)

    for (nw, network) in _PMD.nws(pm)
        loads = _PMD.ref(pm, nw, :load) # Loads in the power network.

        # Constrain load variables if they are connected to a pump.
        for (i, load) in filter(x -> "pump_id" in keys(x.second), loads)
            constraint_pump_load(pm, wm, i, load["pump_id"]; nw=nw)
        end

        # Constrain load variables if they are not connected to a pump.
        for (i, load) in filter(x -> !("pump_id" in keys(x.second)), loads)
            constraint_fixed_load(pm, i; nw=nw)
        end
    end

    # Add a feasibility-only objective.
    JuMP.@objective(pm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
