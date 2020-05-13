@testset "Power-Water Flow Feasibility Problems" begin
    @testset "3-bus Balanced ACRPowerModel and MILPRWaterModel" begin
        pfile = "$(pm_path)/test/data/opendss/case3_balanced.dss"
        wfile = "$(wm_path)/test/data/epanet/example_1-sp.inp"
        ptype, wtype = _PMD.ACRPowerModel, _WM.MILPRWaterModel
        result = run_pwf(pfile, wfile, ptype, wtype, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
    end      
end
