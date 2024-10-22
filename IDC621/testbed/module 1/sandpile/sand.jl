using Plots

init = 16
grid_size = ceil(Int, 2*sqrt(2^init / 2π)) + 4 #2^(init ÷ 2 + 1)
grid = fill(0, (grid_size, grid_size))
grid[grid_size ÷ 2, grid_size ÷ 2] = 2^init
neighbors = CartesianIndex.([(-1,0), (0,-1), (1,0), (0,1)])

@time while any(x -> x >= 4, grid)
    for i in CartesianIndices(grid)
        if grid[i] >= 4
            grid[i] -= 4
            grid[i .+ neighbors] .+= 1
            # println(i .+ neighbors)
        end
    end
end

# gif(anim, "sandpile.gif", fps=50)
# display(grid)
heatmap(grid, size=(3000,2000), axis=false, clims=(0, 4), aspect_ratio=:equal, c=cgrad(:sunset, rev=true))
savefig("sandpile-temp.png") 