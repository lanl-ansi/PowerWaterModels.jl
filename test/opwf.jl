@testset "Optimal Power-Water Flow Problems" begin
    @testset "3-bus LinDist3FlowPowerModel and MILPWaterModel" begin
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        pw_file = "../test/data/json/case3-pump.json"

        p_type, w_type = LinDist3FlowPowerModel, MILPWaterModel
        w_ext = Dict{Symbol,Any}(:pump_breakpoints=>3)
        result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper, w_ext=w_ext)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 2932.00, atol=1.0e-2)
    end

    @testset "3-bus LinDist3FlowPowerModel and MILPWaterModel (Multistep)" begin
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        pw_file = "../test/data/json/case3-pump.json"

        p_type, w_type = LinDist3FlowPowerModel, MILPWaterModel
        w_ext = Dict{Symbol,Any}(:pump_breakpoints=>3)
        result = run_opwf(p_file, w_file, pw_file, p_type, w_type, juniper, w_ext=w_ext)
        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 8794.26, rtol=1.0e-2)
    end
end
