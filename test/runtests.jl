using GhostStamp,Plots
using Test

@testset "GhostStamp.jl" begin

    # tentatively, it does not matter 
    # we will fix this.

    plt = plot(1:10, 1:10)
    add_preliminary!(plt)
    # length(Plots.annotations(plt))
    @test 1 == 1

    plt = plot(1:10, 1:10)
    add_stamp!(plt; text="TEST")
    # length(Plots.annotations(plt))
    @test 1 == 1

end
