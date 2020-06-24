@testset "src/io/common.jl" begin
    @testset "parse_json" begin
        pw_data = parse_json("../test/data/json/case4-example_1.json")
        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "matpower"
    end

    @testset "parse_files (.m, .inp, .json)" begin
        p_path = "../test/data/matpower/case4.m"
        w_path = "$(wm_path)/test/data/epanet/example_1-sp.inp"
        pw_path = "../test/data/json/case4-example_1.json"
        p_data, w_data, pw_data = parse_files(p_path, w_path, pw_path)

        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "matpower"
    end

    @testset "parse_files (.dss, .inp, .json)" begin
        p_path = "$(pm_path)/test/data/opendss/case2_diag.dss"
        w_path = "$(wm_path)/test/data/epanet/example_1-sp.inp"
        pw_path = "../test/data/json/opendss-epanet.json"
        p_data, w_data, pw_data = parse_files(p_path, w_path, pw_path)

        @test pw_data["water_metadata"]["source_type"] == "epanet"
        @test pw_data["power_metadata"]["source_type"] == "opendss"
    end
end
