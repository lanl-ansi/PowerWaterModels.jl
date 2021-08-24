@testset "src/io/objective.jl" begin
    @testset "objective_min_max_generation_fluctuation" begin
        p_file = "$(pmd_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_file = "../test/data/json/case3-pump.json"        
        data = parse_files(p_file, w_file, link_file)

        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        pwm = instantiate_model(data, pwm_type, build_opwf)
        objective_min_max_generation_fluctuation(pwm)

        result = _IM.optimize_model!(pwm, optimizer = juniper)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end