using CairoMakie
using ImageFiltering
using Colors, ColorSchemes

init = 16
grid_size = ceil(Int, 2*sqrt(2^init / 2π)) + 4
grid = fill(0, (grid_size, grid_size))
grid[grid_size ÷ 2, grid_size ÷ 2] = 2^init

neighbors = [0 1 0; 1 0 1; 0 1 0]
num_neighbors = sum(neighbors)
kernel = centered(neighbors / num_neighbors)

@time while any(x -> x >= num_neighbors, grid)
    arr_to_conv = num_neighbors .* (grid .÷ num_neighbors)
    arr_conv = round.(Int, imfilter(arr_to_conv, kernel, Fill(0, kernel)))
    global grid = (grid .% num_neighbors) + arr_conv
end

figure = (; font="CMU Serif")
# axis = (; ticks=false, aspect=DataAspect())
#cmap = ColorScheme(range(colorant"red", colorant"green", length=3))
# this is another way to obtain a colormap, not used here, but try it.
mycmap = ColorScheme([RGB{Float64}(i, 1.5i, 2i) for i in [0.0, 0.25, 0.35, 0.5]])
fig, ax, pltobj = heatmap(grid;
    # colormap=cgrad(:sunset, 4, categorical=true, rev=true), # cgrad and Symbol, mycmap
    colormap=Makie.Categorical(cgrad(:sunset, rev=true)),
    figure=figure)
cbar = Colorbar(fig[1, 2], pltobj)
hidedecorations!(ax)
# cbar.ticks = ([0.5, 1.5, 2.5, 3.5], ["0", "1", "2", "3"])
colsize!(fig.layout, 1, Aspect(1, 1.0))
save("test2.png", fig)