using GhostStamp,Plots
using Test

@testset "GhostStamp.jl" begin

    plt = plot(1:10, 1:10)
    add_preliminary!(plt)
    @test length(Plots.annotations(plt)) == 1

    plt = plot(1:10, 1:10)
    add_stamp!(plt; txt="TEST")
    @test length(Plots.annotations(plt)) == 1

end
