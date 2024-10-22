using CairoMakie
using ImageFiltering
using Colors, ColorSchemes

function InitializeStackedGrid(pow)
	grid_size = ceil(Int, 2 * sqrt(2^pow / 2π)) + 4
	grid = fill(0, (grid_size, grid_size))
	grid[grid_size ÷ 2, grid_size ÷ 2] = 2^pow
	
	return grid
end

function Convolve(grid)
    neighbors = [0 1 0; 1 0 1; 0 1 0]
	kernel = centered(neighbors / 4)
	
	arr_to_conv = 4 .* (grid .÷ 4)
	arr_convd = round.(Int, imfilter(arr_to_conv, kernel, Fill(0, kernel)))
	grid_new = (grid .% 4) + arr_convd

	return grid_new
end

function StabilizeConv(grid)
	counter = 0
	
	while any(x -> x >= 4, grid)
		grid = Convolve(grid)
		counter += 1
	end

	return grid, counter
end

pow = 14
grid = InitializeStackedGrid(pow)
grid, counter = StabilizeConv(grid)


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