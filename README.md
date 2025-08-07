# GhostStamp

[![Build Status](https://github.com/akio-tomiya/GhostStamp.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/akio-tomiya/GhostStamp.jl/actions/workflows/CI.yml?query=branch%3Amain)

*A lightweight helper to stamp translucent labels (“PRELIMINARY”, “DRAFT”, ­…​), watermakrs onto figures created with **Plots.jl***. 

<img width="40%" height="40%" alt="image" src="https://github.com/akio-tomiya/GhostStamp.jl/blob/main/logo.png" >


---

## 1. Features

- **One-liner watermark** – call `add_preliminary!` or `add_stamp!` on any `Plots.Plot`.
- **Fully style-able** – text, font size, rotation, colour and alpha can be customised.
- **Backend-agnostic** – works with GR, PyPlot, PlotlyJS, …​ anything supported by Plots.jl.
- **Zero dependencies except Plots & Colors** – no splash of Cairo or Makie.

---

## 2. Installation

```julia
pkg> add https://github.com/akio-tomiya/GhostStamp.jl
```

## 3. Quick start
```julia
using Plots, GhostStamp

plt = plot(1:10, rand(10); lw=2, label="demo")
add_preliminary!(plt)                # red “PRELIMINARY” watermark
savefig(plt, "figure_prelim.png")
```

## 4. Custom stamp
```julia
plt = plot(rand(100); seriestype=:histogram, label="")
add_stamp!(plt;
           text = "CONFIDENTIAL",
           fs   = 60,
           angle = 25,
           color = :blue,
           alpha = 0.12)
display(plt)
```

