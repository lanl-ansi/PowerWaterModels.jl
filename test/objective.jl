@testset "src/io/objective.jl" begin
    @testset "objective_min_max_generation_fluctuation" begin
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        pw_file = "../test/data/json/case3-pump.json"

        w_ext = Dict{Symbol,Any}(:pump_breakpoints => 3)
        p_type, w_type = LinDist3FlowPowerModel, PWLRDWaterModel
        p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)
        pm, wm = instantiate_model(p_data, w_data, pw_data, p_type, w_type, build_opwf; w_ext=w_ext)
        objective_min_max_generation_fluctuation(pm)

        power_result = _IM.optimize_model!(pm, optimizer=juniper)
        @test power_result["termination_status"] == LOCALLY_SOLVED
    end
end