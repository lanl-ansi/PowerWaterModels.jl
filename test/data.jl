function consistent_multinetworks(power_path::String, water_path::String, link_path::String)
    data = parse_files(power_path, water_path, link_path)
    mn_data = make_multinetwork(data)
        
    # Ensure the networks are consistently sized.
    pmd_data = mn_data["it"][_PMD.pmd_it_name]
    wm_data = mn_data["it"][_WM.wm_it_name]
    return networks_are_consistent(pmd_data, wm_data)
end

@testset "src/core/data.jl" begin
    @testset "make_multinetwork" begin
        # Snapshot MATPOWER and snapshot EPANET networks.
        power_path = "$(pmd_path)/test/data/matpower/case3.m"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Multistep OpenDSS and snapshot EPANET networks.
        power_path = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump-dss.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Snapshot MATPOWER and multistep EPANET networks.
        power_path = "$(pmd_path)/test/data/matpower/case3.m"
        water_path = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Snapshot OpenDSS and EPANET networks.
        power_path = "$(pmd_path)/test/data/opendss/case2_diag.dss"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case2-pump.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Snapshot OpenDSS and multistep EPANET networks.
        power_path = "$(pmd_path)/test/data/opendss/case2_diag.dss"
        water_path = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_path = "../test/data/json/case2-pump.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Multistep OpenDSS and snapshot EPANET networks.
        power_path = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump-dss.json"
        @test consistent_multinetworks(power_path, water_path, link_path)

        # Multistep OpenDSS and EPANET networks (mismatch, should fail).
        power_path = "$(pmd_path)/test/data/opendss/case3_balanced.dss"
        water_path = "$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump-dss.json"
        @test_throws ErrorException parse_files(power_path, water_path, link_path)
    end

    @testset "_make_power_multinetwork" begin
        p_data = _PM.parse_file("$(pmd_path)/test/data/matpower/case3.m")
        p_data["time_series"] = Dict{String,Any}("num_steps" => 3)
        p_data = PowerWaterModels._make_power_multinetwork(p_data)
        @test length(p_data["nw"]) == 3

        p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
        p_data = PowerWaterModels._make_power_multinetwork(p_data)
        @test length(p_data["nw"]) == 1
    end
end
