module GhostStamp

using Plots
using Colors # Colorant, RGBA

export add_preliminary!,add_stamp!     # Public API

"""
    add_preliminary!(plt; text="PRELIMINARY", angle=30, fs=40,
                     color=:red, alpha=0.15)

Add a watermark at the center of each 2D subplot in a Plots.jl figure (`plt`).
"""
function add_preliminary!(plt; text="PRELIMINARY", angle=30,
    fs=40, color=:red, alpha=0.15)
    add_stamp!(plt; text=text, angle=angle,fs=fs, color=color, alpha=alpha)
end

"""
    add_stamp!(plt; text="", angle=30, fs=40, color=:red, alpha=0.15)

Add a translucent label at the center of each 2D subplot and return the modified
plot. The position follows axis-limit and scale changes, including logarithmic
axes, and subsequent data additions.
"""
function add_stamp!(plt; text="", angle=30,
                          fs=40, color=:red, alpha=0.15)

    base = color isa Colorant ? color : parse(Colorant, string(color))
    txtcol = RGBA(red(base), green(base), blue(base), alpha)
    t = Plots.text(text, fs, txtcol; halign=:center, valign=:center, rotation=angle)

    # Resolve the center in each subplot's coordinates at rendering time.
    annotate!(plt, ((0.5, 0.5), t))
end

end # module
