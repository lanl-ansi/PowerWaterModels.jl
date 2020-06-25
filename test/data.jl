@testset "src/core/data.jl" begin
    @testset "make_consistent_networks" begin
        # Snapshot MATPOWER and EPANET networks.
        p_data = _PM.parse_file("$(pm_path)/test/data/matpower/case3.m")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test networks_are_consistent(p_new, w_new)

        # Snapshot MATPOWER and multistep EPANET networks.
        p_data = _PM.parse_file("$(pm_path)/test/data/matpower/case3.m")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test networks_are_consistent(p_new, w_new)

        # Snapshot OpenDSS and EPANET networks.
        p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test networks_are_consistent(p_new, w_new)

        # Snapshot OpenDSS and multistep EPANET networks.
        p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case2_diag.dss")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test networks_are_consistent(p_new, w_new)

        # Multistep OpenDSS and snapshot EPANET networks.
        p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case3_balanced.dss")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test networks_are_consistent(p_new, w_new)

        # Multistep OpenDSS and EPANET networks.
        p_data = _PMD.parse_file("$(pmd_path)/test/data/opendss/case3_balanced.dss")
        w_data = _WM.parse_file("$(wm_path)/test/data/epanet/multinetwork/pump-hw-lps.inp")
        p_new, w_new = make_consistent_networks(p_data, w_data)
        @test !networks_are_consistent(p_new, w_new) # Multinetwork mismatch.
    end
end
