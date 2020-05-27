@testset "Power-Water Flow Feasibility Problems" begin
    @testset "4-bus ACPPowerModel and MILPRWaterModel" begin
        pfile = "../test/data/matpower/case4.m"
        wfile = "$(wm_path)/test/data/epanet/example_1-sp.inp"

        pdata = _PWM.make_three_phase_power_network(pfile)
        wdata = _WM.parse_file(wfile)

        ptype, wtype = _PMD.DCPPowerModel, _WM.MILPRWaterModel
        result = run_pwf(pdata, wdata, ptype, wtype, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
    end      
end
