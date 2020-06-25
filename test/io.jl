@testset "src/io/common.jl" begin
    @testset "parse_json" begin
        pw_data = parse_json("../test/data/json/case3-pump.json")
        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "matpower"
    end

    @testset "parse_files (.m, .inp, .json)" begin
        p_file = "$(pm_path)/test/data/matpower/case3.m"
        w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        pw_file = "../test/data/json/case3-pump.json"
        p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)

        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "matpower"
    end

    @testset "parse_files (.dss, .inp, .json)" begin
        p_file = "$(pmd_path)/test/data/opendss/case2_diag.dss"
        w_file = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        pw_file = "../test/data/json/case2-pump.json"
        p_data, w_data, pw_data = parse_files(p_file, w_file, pw_file)

        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "opendss"
    end
end
