module GhostStamp

using Plots
using Colors # Colorant, RGBA
# using Statistics: mean      # xmid, ymid

export add_preliminary!,add_stamp!     # Public API

"""
    add_preliminary!(plt; txt="PRELIMINARY", angle=30, fs=40,
                     color=:red, alpha=0.15)

A helper to add a watermark for a figure (`plt`) by Plots.jl 
"""
function add_preliminary!(plt; text="PRELIMINARY", angle=30,
    fs=40, color=:red, alpha=0.15)
    add_stamp!(plt; text=text, angle=angle,fs=fs, color=color, alpha=alpha)
end
function add_stamp!(plt; text="", angle=30,
                          fs=40, color=:red, alpha=0.15)

    base = color isa Colorant ? color : parse(Colorant, string(color))
    txtcol = RGBA(red(base), green(base), blue(base), alpha)
    t = text(text, fs, txtcol; halign=:center, valign=:center, rotation=angle)

    xmid = sum(xlims(plt)) / 2
    ymid = sum(ylims(plt)) / 2
    annotate!(plt, (xmid, ymid, t))
end

end # module
