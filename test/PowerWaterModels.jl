@testset "src/PowerWaterModels.jl" begin
    @testset "silence" begin
        # This should silence everything except error messages.
        PowerWaterModels.silence()

        # Ensure the the InfrastructureModels logger is silenced.
        im_logger = Memento.getlogger(_IM)
        @test Memento.getlevel(im_logger) == "error"
        Memento.warn(im_logger, "Silenced message should not be displayed.")

        # Ensure the the PowerModelsDistribution logger is silenced.
        pmd_logger = Memento.getlogger(_PMD)
        @test Memento.getlevel(pmd_logger) == "error"
        Memento.warn(pmd_logger, "Silenced message should not be displayed.")

        # Ensure the the WaterModels logger is silenced.
        wm_logger = Memento.getlogger(_WM)
        @test Memento.getlevel(wm_logger) == "error"
        Memento.warn(wm_logger, "Silenced message should not be displayed.")
    end
end
