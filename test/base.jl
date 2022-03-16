@testset "src/core/base.jl" begin
    p_file = "$(pmd_path)/test/data/opendss/case2_diag.dss"
    w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
    link_file = "../test/data/json/case2-pump.json"

    @testset "instantiate_model (with file inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        pwm = instantiate_model(p_file, w_file, link_file, pwm_type, build_pwf)
        @test typeof(pwm.model) == JuMP.Model
    end

    @testset "instantiate_model (with network inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        data = parse_files(p_file, w_file, link_file)
        pwm = instantiate_model(data, pwm_type, build_pwf)
        @test typeof(pwm.model) == JuMP.Model
    end

    @testset "solve_model (with file inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = solve_model(p_file, w_file, link_file, pwm_type, nlp_solver, build_pwf; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "solve_model (with network inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        data = parse_files(p_file, w_file, link_file)
        result = solve_model(data, pwm_type, nlp_solver, build_pwf; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
