@testset "Power-Water Flow Feasibility Problems" begin
    @testset "4-bus DCPPowerModel and MILPWaterModel" begin
        pfile = "../test/data/matpower/case4.m"
        wfile = "$(wm_path)/test/data/epanet/example_1-sp.inp"

        pdata = _PM.parse_file(pfile)
        pdata = _PWM.make_three_phase_power_network(pdata)
        wdata = _WM.parse_file(wfile)

        ptype, wtype = _PMD.DCPPowerModel, _WM.MILPWaterModel
        result = run_pwf(pdata, wdata, ptype, wtype, juniper)
        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
    end      
end
