@testset "Optimal Power-Water Flow Problems" begin
    @testset "4-bus DCPPowerModel and MILPWaterModel" begin
        p_file = "../test/data/matpower/case4.m"
        w_file = "$(wm_path)/test/data/epanet/example_1-sp.inp"
        pw_file = "../test/data/json/case4-example_1.json"

        p_type, w_type = _PMD.DCPPowerModel, _WM.MILPWaterModel
        result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 1000.0, rtol=1.0e-4)
    end

    @testset "4-bus DCPPowerModel and MILPWaterModel (Multistep)" begin
        p_file = "../test/data/matpower/case4.m"
        w_file = "$(wm_path)/test/data/epanet/example_1.inp"
        pw_file = "../test/data/json/case4-example_1.json"

        p_type, w_type = _PMD.DCPPowerModel, _WM.MILPWaterModel
        result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 4000.0, rtol=1.0e-4)
    end
end
