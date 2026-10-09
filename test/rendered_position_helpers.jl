# Measure saved PNG pixels independently of annotation coordinates.
render_channel(pixel, shift) = Int((pixel >> shift) & 0xff)
render_is_black(pixel) = all(render_channel(pixel, shift) < 80 for shift in (0, 8, 16))
render_is_red(pixel) = render_channel(pixel, 0) > render_channel(pixel, 8) + 8 &&
    render_channel(pixel, 0) > render_channel(pixel, 16) + 8

function render_matching_pixels(pixels, predicate, columns)
    matches = [index for index in CartesianIndices(pixels)
        if index[1] in columns && predicate(pixels[index])]
    isempty(matches) && error("No matching pixels in rendered panel")
    return matches
end
function render_bounds(points)
    xs, ys = [point[1] for point in points], [point[2] for point in points]
    return (minimum(xs), minimum(ys), maximum(xs), maximum(ys))
end
render_box_center(box) = ((box[1] + box[3]) / 2, (box[2] + box[4]) / 2)

function rendered_centers(path, panels; angle=30)
    width, _, pixels = Plots.GR.readimage(path)
    cosine, sine = cosd(angle), sind(angle)
    return map(1:panels) do panel
        columns = (floor(Int, (panel - 1) * width / panels) + 1):floor(Int, panel * width / panels)
        frame = render_bounds(render_matching_pixels(pixels, render_is_black, columns))
        ink = render_matching_pixels(pixels, render_is_red, columns)
        # Use a rectangle aligned with the letters. On rotation, a horizontal
        # box changes shape because the P and Y have different ink corners.
        aligned = [(cosine * point[1] - sine * point[2],
            sine * point[1] + cosine * point[2]) for point in ink]
        u, v = render_box_center(render_bounds(aligned))
        text_center = (cosine * u + sine * v, -sine * u + cosine * v)
        frame_center = render_box_center(frame)
        delta = (text_center[1] - frame_center[1], text_center[2] - frame_center[2])
        (; panel, frame_center, text_center, delta,
            frame_bbox=frame, text_bbox=render_bounds(ink))
    end
end

function render_position_fixture(x=[0., 10.], y=[0., 10.]; kwargs...)
    # Blue data separates the curve from the default translucent red stamp.
    return plot(x, y; size=(640, 440), framestyle=:box, ticks=false,
        grid=false, legend=false, linecolor=:blue, kwargs...)
end
const RENDER_POSITION_CASES = ("linear", "angle_zero", "changed_limits", "added_data",
    "empty_then_data", "log_axes", "resized", "asymmetric_margins", "different_panels")

function render_position_case(name; stamp! = add_preliminary!)
    if name == "linear" || name == "angle_zero"
        p = render_position_fixture(; xlims=(0., 10.), ylims=(0., 10.))
        stamp!(p; angle=name == "angle_zero" ? 0 : 30)
    elseif name == "changed_limits"
        p = render_position_fixture(; xlims=(0., 10.), ylims=(0., 10.))
        stamp!(p)
        xlims!(p, (0., 100.))
        ylims!(p, (0., 100.))
    elseif name == "added_data"
        p = render_position_fixture()
        stamp!(p)
        plot!(p, [0., 100.], [0., 100.]; linecolor=:blue)
    elseif name == "empty_then_data"
        p = render_position_fixture(Float64[], Float64[])
        stamp!(p)
        plot!(p, [0., 100.], [0., 100.]; linecolor=:blue)
    elseif name == "log_axes"
        p = render_position_fixture([1., 100.], [1., 100.]; xscale=:log10, yscale=:log10,
            xlims=(1., 100.), ylims=(1., 100.))
        stamp!(p)
    elseif name == "resized"
        p = render_position_fixture()
        stamp!(p)
        plot!(p; size=(960, 440))
    elseif name == "asymmetric_margins"
        p = render_position_fixture(; left_margin=30 * Plots.mm, right_margin=3 * Plots.mm)
        stamp!(p)
    elseif name == "different_panels"
        p = plot(render_position_fixture(; xlims=(0., 10.), ylims=(0., 10.)),
            render_position_fixture([100., 110.], [100., 110.]; xlims=(100., 110.), ylims=(100., 110.));
            layout=(1, 2), size=(1280, 440))
        stamp!(p)
    else
        error("Unknown rendered-position case: $name")
    end
    return p
end

# The image oracle must reject the original incorrect algorithm.
function render_legacy_stamp!(p; angle=30)
    label = Plots.text("PRELIMINARY", 40, RGBA(1, 0, 0, 0.15);
        halign=:center, valign=:center, rotation=angle)
    annotate!(p, (sum(xlims(p)) / 2, sum(ylims(p)) / 2, label))
end
