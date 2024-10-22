using GLMakie
using Colors, ColorSchemes
using ImageFiltering

init = 12
grid_size = ceil(Int, 2*sqrt(2^init / 2π)) + 4
grid = fill(0, (grid_size, grid_size))
grid[grid_size ÷ 2, grid_size ÷ 2] = 2^init

neighbors = [0 1 0; 1 0 1; 0 1 0]
# neighbors = [1 1 0; 1 0 1; 0 1 1]
# neighbors = [0 0 1 0 0; 0 0 1 0 0; 1 1 0 1 1; 0 0 1 0 0; 0 0 1 0 0]
# neighbors = [1 0 1; 0 0 0; 1 0 1]
num_neighbors = sum(neighbors)
kernel = centered(neighbors / num_neighbors)

figure = (; font="CMU Serif")
fig, ax, pltobj = heatmap(grid;
    colormap=Makie.Categorical(cgrad(:sunset, rev=true)),
    figure=figure)
cbar = Colorbar(fig[1, 2], pltobj)
hidedecorations!(ax)
colsize!(fig.layout, 1, Aspect(1, 1.0))
# save("test.png", fig)

# Define the update function
function update_grid!(grid, kernel, num_neighbors)
    arr_to_conv = num_neighbors .* (grid .>= num_neighbors) .* (grid .÷ num_neighbors)
    arr_conv = round.(Int, imfilter(arr_to_conv, kernel, Fill(0, kernel)))
    grid .= (grid .% num_neighbors) + arr_conv
end

# Create the animation
record(fig, "sandpile_animation.mp4", framerate=10) do i
    while any(x -> x >= num_neighbors, grid)
        update_grid!(grid, kernel, num_neighbors)
        pltobj[1] = clamp.(grid, 0, 4)  # Update the heatmap data
        recordframe!(i)
        # display(grid)
    end
end