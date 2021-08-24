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

    @testset "instantiate_model (with network inputs; error)" begin
        p_file_mn = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        w_file_mn = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_file_mn = "../test/data/json/case3-pump-dss.json"
        data = parse_files(p_file_mn, w_file_mn, link_file_mn)
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        @test_throws ErrorException instantiate_model(data, pwm_type, build_pwf)
    end

    @testset "run_model (with file inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        result = run_model(p_file, w_file, link_file, pwm_type, juniper, build_pwf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "run_model (with network inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, CRDWaterModel}
        data = parse_files(p_file, w_file, link_file)
        result = run_model(data, pwm_type, juniper, build_pwf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
