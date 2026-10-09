# Keep GR rendering headless in CI unless the caller selects a workstation.
get!(ENV, "GKSwstype", "100")

using GhostStamp, Plots, Colors
using Test

gr()
include("rendered_position_helpers.jl")

# Resolve the annotation as the backend does, rather than testing its storage format.
function stamp_position(sp)
    x, y, _ = Plots.locate_annotation(sp, only(sp[:annotations])...)
    return (x, y)
end

function test_position(sp, expected)
    actual = stamp_position(sp)
    @test actual[1] ≈ expected[1]
    @test actual[2] ≈ expected[2]
end

@testset "GhostStamp.jl" begin
    @testset "Default and custom stamps" begin
        plt = plot([0., 10.], [0., 10.]; xlims=(0., 10.), ylims=(0., 10.))
        original_series = length(plt.series_list)
        @test add_preliminary!(plt) === plt
        test_position(plt[1], (5., 5.))
        _, _, label = Plots.locate_annotation(plt[1], only(plt[1][:annotations])...)
        @test label.str == "PRELIMINARY"
        @test label.font.pointsize == 40
        @test label.font.rotation == 30
        @test label.font.color == RGBA(1, 0, 0, 0.15)
        @test length(plt.series_list) == original_series
        @test xlims(plt) == (0., 10.)
        @test ylims(plt) == (0., 10.)

        custom = plot([1., 100.], [1., 100.]; xscale=:log10, yscale=:log10,
            xlims=(1., 100.), ylims=(1., 100.))
        @test add_stamp!(custom; text="DRAFT", fs=24, angle=15,
            color=:blue, alpha=0.25) === custom
        test_position(custom[1], (10., 10.))
        _, _, label = Plots.locate_annotation(custom[1], only(custom[1][:annotations])...)
        @test label.str == "DRAFT"
        @test label.font.pointsize == 24
        @test label.font.rotation == 15
        @test label.font.color == RGBA(0, 0, 1, 0.25)
    end

    @testset "Logarithmic axes: $scale" for scale in (:log10, :log2, :ln)
        plt = plot([1., 100.], [1., 100.]; xscale=scale, yscale=scale,
            xlims=(1., 100.), ylims=(1., 100.))
        add_preliminary!(plt)
        test_position(plt[1], (10., 10.))
    end

    @testset "Axis changes after stamping" begin
        plt = plot([0., 10.], [0., 10.]; xlims=(0., 10.), ylims=(0., 10.))
        add_preliminary!(plt)
        xlims!(plt, (0., 100.))
        ylims!(plt, (100., 200.))
        test_position(plt[1], (50., 150.))

        plot!(plt; xscale=:log10, yscale=:log10, xlims=(1., 100.), ylims=(1., 100.))
        test_position(plt[1], (10., 10.))
    end

    @testset "Data added after stamping" begin
        plt = plot([0., 10.], [0., 10.])
        add_preliminary!(plt)
        plot!(plt, [0., 100.], [0., 100.])
        test_position(plt[1], (50., 50.))

        empty_plot = plot()
        add_preliminary!(empty_plot)
        plot!(empty_plot, [0., 100.], [0., 100.])
        test_position(empty_plot[1], (50., 50.))
    end

    @testset "Each subplot uses its own axes" begin
        plt = plot(
            plot([0., 10.], [0., 10.]; xlims=(0., 10.), ylims=(0., 10.)),
            plot([100., 110.], [100., 110.]; xlims=(100., 110.), ylims=(100., 110.));
            layout=(1, 2))
        @test add_preliminary!(plt) === plt
        test_position(plt[1], (5., 5.))
        test_position(plt[2], (105., 105.))

        # Check after the final rendering/layout pass as well.
        mktempdir() do directory
            output = joinpath(directory, "stamped.png")
            savefig(plt, output)
            @test filesize(output) > 0
            test_position(plt[1], (5., 5.))
            test_position(plt[2], (105., 105.))
        end
    end

    @testset "Existing annotations are preserved" begin
        plt = plot([0., 10.], [0., 10.]; annotations=(2., 3., "existing"))
        add_preliminary!(plt)
        @test length(plt[1][:annotations]) == 2
        existing = only(filter(annotation -> annotation[end].str == "existing",
            plt[1][:annotations]))
        @test Plots.locate_annotation(plt[1], existing...)[1:2] == (2., 3.)
    end

    @testset "Visible text is centered in rendered PNGs" begin
        mktempdir() do directory
            for name in RENDER_POSITION_CASES
                plt = render_position_case(name)
                path = joinpath(directory, "$name.png")
                savefig(plt, path)
                angle = name == "angle_zero" ? 0 : 30
                for measured in rendered_centers(path, length(plt.subplots); angle=angle)
                    # One pixel allows rasterization/antialiasing at each edge.
                    @test abs(measured.delta[1]) <= 1
                    @test abs(measured.delta[2]) <= 1
                end
            end
            for name in ("changed_limits", "added_data", "log_axes")
                plt = render_position_case(name; stamp! = render_legacy_stamp!)
                path = joinpath(directory, "legacy_$name.png")
                savefig(plt, path)
                measured = only(rendered_centers(path, 1))
                @test maximum(abs.(measured.delta)) > 50
            end
        end
    end
end
