using CircularArrays

function InitializeStackedGrid(pow)
	grid_size = ceil(Int, 2 * sqrt(2^pow / 2π)) + 4
	grid = fill(0, (grid_size, grid_size))
	grid[grid_size ÷ 2, grid_size ÷ 2] = 2^pow
	
	return grid
end

function Pull(grid, neighbors)
	output = similar(grid)

    for i in CartesianIndices(grid)
        neighbor_elements = grid[i .+ neighbors]  
        output[i] = (grid[i] % 4) + sum(neighbor_elements .÷ 4)
    end

    return output
end

function StabilizePull(grid, neighbors)
	counter = 0
	grid = CircularArray(grid)
	
	t = @elapsed while any(x -> x >= 4, grid)
	    grid = Pull(grid, neighbors)
		counter += 1
	end

	output = fill(0, size(grid))
	output .= grid

	return output, counter, t
end

pow = 16
neighbors_vn = CartesianIndex.([(0,-1), (-1,0), (1,0), (0,1)])
grid_pull_init = InitializeStackedGrid(pow)
grid_pull, counter_pull, t = StabilizePull(grid_pull_init, neighbors_vn)
display(t)