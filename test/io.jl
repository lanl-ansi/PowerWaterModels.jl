@testset "src/io/common.jl" begin
    @testset "parse_json" begin
        data = parse_json("../test/data/json/case3-pump.json")
        pump_loads = data["it"]["dep"]["pump_load"]
        
        @test pump_loads["1"]["pump"]["source_id"] == "1"
        @test pump_loads["1"]["load"]["source_id"] == "3"
        @test pump_loads["1"]["status"] == 1
    end


    @testset "parse_link_file" begin
        data = parse_link_file("../test/data/json/case3-pump.json")
        pump_loads = data["it"]["dep"]["pump_load"]

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true

        @test pump_loads["1"]["pump"]["source_id"] == "1"
        @test pump_loads["1"]["load"]["source_id"] == "3"
        @test pump_loads["1"]["status"] == 1
    end


    @testset "parse_link_file (invalid extension)" begin
        path = "../examples/data/json/no_file.txt"
        @test_throws ErrorException parse_link_file(path)
    end


    @testset "parse_power_file" begin
        path = "$(pmd_path)/test/data/matpower/case3.m"
        data = parse_power_file(path)

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
    end


    @testset "parse_water_file" begin
        path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        data = parse_water_file(path)

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
    end


    @testset "parse_files" begin
        power_path = "$(pmd_path)/test/data/matpower/case3.m"
        water_path = "$(wm_path)/test/data/epanet/snapshot/pump-hw-lps.inp"
        link_path = "../test/data/json/case3-pump.json"
        data = parse_files(power_path, water_path, link_path)

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
        @test haskey(data["it"], "dep")
        @test haskey(data["it"], _PMD.pmd_it_name)
        @test haskey(data["it"], _WM.wm_it_name)
    end
end
