@testset "src/core/base.jl" begin
    p_file = "$(pmd_path)/test/data/opendss/case2_diag.dss"
    w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
    link_file = "../test/data/json/case2-pump.json"

    @testset "instantiate_model (with file inputs)" begin
        pwm_type = PowerWaterModel{LinDist3FlowPowerModel, PWLRDWaterModel}
        pwm = instantiate_model(p_file, w_file, link_file, pwm_type, build_pwf)
        @test typeof(pwm.model) == JuMP.Model
    end

    @testset "instantiate_model (with file inputs)" begin
        pwm = instantiate_model(p_file, w_file, pw_file, p_type, w_type, build_pwf)
        @test pm.model == wm.model
    end

    @testset "instantiate_model (with network inputs)" begin
        p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)
        pm, wm = instantiate_model(p_data, w_data, pw_data, p_type, w_type, build_pwf)
        @test pm.model == wm.model
    end

    @testset "instantiate_model (with network inputs; error)" begin
        p_file_mn = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        w_file_mn = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        pw_file_mn = "../test/data/json/case3-pump.json"
        p_data, w_data, pw_data = parse_files(p_file_mn, w_file_mn, pw_file_mn)
        @test_throws ErrorException instantiate_model(p_data, w_data, pw_data, p_type, w_type, build_pwf)
    end

    @testset "run_model (with file inputs)" begin
        result = run_model(p_file, w_file, pw_file, p_type, w_type, juniper, build_pwf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "run_model (with network inputs)" begin
        p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)
        result = run_model(p_data, w_data, pw_data, p_type, w_type, juniper, build_pwf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
