@testset "src/core/data.jl" begin
    @testset "make_multinetwork" begin
        # Snapshot MATPOWER and snapshot EPANET networks.
        power_path = "$(pmd_path)/test/data/matpower/case3.m"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump.json"

        # Parse the data and use `make_multinetwork`
        data = parse_files(power_path, water_path, link_path)
        mn_data = make_multinetwork(data)
        
        # Ensure the networks are consistently sized.
        pmd_data = mn_data["it"][_PMD.pmd_it_name]
        wm_data = mn_data["it"][_WM.wm_it_name]
        @test networks_are_consistent(pmd_data, wm_data)

        # # Multistep OpenDSS and snapshot EPANET networks.
        # power_path = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        # water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        # link_path = "../test/data/json/case3-pump.json"

        # # Parse the data and use `make_multinetwork`
        # data = parse_files(power_path, water_path, link_path)
        # mn_data = make_multinetwork(data)
        
        # # Ensure the networks are consistently sized.
        # pmd_data = mn_data["it"][_PMD.pmd_it_name]
        # wm_data = mn_data["it"][_WM.wm_it_name]
        # @test networks_are_consistent(pmd_data, wm_data)

        # # Snapshot MATPOWER and multistep EPANET networks.
        # p_data = _PM.parse_file("$(pm_path)/test/data/matpower/case3.m")
        # w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        # p_new, w_new = make_multinetworks(p_data, w_data)
        # @test networks_are_consistent(p_new, w_new)

        # # Snapshot OpenDSS and EPANET networks.
        # p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
        # w_data = _WM.parse_file("$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp")
        # p_new, w_new = make_multinetworks(p_data, w_data)
        # @test networks_are_consistent(p_new, w_new)

        # # Snapshot OpenDSS and multistep EPANET networks.
        # p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
        # w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        # p_new, w_new = make_multinetworks(p_data, w_data)
        # @test networks_are_consistent(p_new, w_new)

        # # Multistep OpenDSS and snapshot EPANET networks.
        # p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case3_balanced.dss")
        # w_data = _WM.parse_file("$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp")
        # p_new, w_new = make_multinetworks(p_data, w_data)
        # @test networks_are_consistent(p_new, w_new)

        # # Multistep OpenDSS and EPANET networks.
        # p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case3_balanced.dss")
        # w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        # p_new, w_new = make_multinetworks(p_data, w_data)
        # @test !networks_are_consistent(p_new, w_new) # Multinetwork mismatch.
    end

    # @testset "_modify_loads" begin
    #     p_file_mn = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
    #     w_file_mn = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
    #     pw_file_mn = "../test/data/json/case3-pump.json"
    #     p_data, w_data, pw_data = parse_files(p_file_mn, w_file_mn, pw_file_mn)
    #     @test_throws ErrorException PowerWaterModels._modify_loads(p_data, w_data, pw_data)
    # end

    # @testset "_make_power_multinetwork" begin
    #     p_data = _PM.parse_file("$(pm_path)/test/data/matpower/case3.m")
    #     p_data["time_series"] = Dict{String,Any}("num_steps"=>3)
    #     p_data = PowerWaterModels._make_power_multinetwork(p_data)

    #     p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
    #     p_data = PowerWaterModels._make_power_multinetwork(p_data)
    # end
end
