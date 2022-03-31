@testset "Optimal Power-Water Network Expansion Problems" begin
    @testset "3-bus LinDist3FlowPowerModel and CRDWaterModel" begin 
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_file = "../test/data/json/case3-pump.json"

        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = solve_ne(p_file, w_file, link_file, pwm_type, nlp_solver; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2932.00, rtol = 1.0e-2)

        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = run_ne(p_file, w_file, link_file, pwm_type, nlp_solver; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2932.00, rtol = 1.0e-2)
    end

    @testset "3-bus LinDist3FlowPowerModel and CRDWaterModel (Multistep)" begin
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_file = "../test/data/json/case3-pump.json"

        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = solve_ne(p_file, w_file, link_file, pwm_type, nlp_solver; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 8794.26, rtol = 1.0e-2)

        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = run_ne(p_file, w_file, link_file, pwm_type, nlp_solver; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 8794.26, rtol = 1.0e-2)
    end
end
