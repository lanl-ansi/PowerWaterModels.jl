@testset "Power-Water Flow Feasibility Problems" begin
    @testset "4-bus DCPPowerModel and MILPWaterModel" begin
        p_file = "../test/data/matpower/case4.m"
        w_file = "$(wm_path)/test/data/epanet/example_1-sp.inp"
        pw_file = "../test/data/json/case4-example_1.json"

        p_type, w_type = _PMD.DCPPowerModel, _WM.MILPWaterModel
        result = run_pwf(p_file, w_file, pw_file, p_type, w_type, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
    end

    @testset "4-bus DCPPowerModel and MILPWaterModel (Multistep)" begin
        p_file = "../test/data/matpower/case4.m"
        w_file = "$(wm_path)/test/data/epanet/example_1.inp"
        pw_file = "../test/data/json/case4-example_1.json"

        p_type, w_type = _PMD.DCPPowerModel, _WM.MILPWaterModel
        result = run_pwf(p_file, w_file, pw_file, p_type, w_type, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
    end
end
