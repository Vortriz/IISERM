function InitializeStackedGrid(pow)
	grid_size = ceil(Int, 2 * sqrt(2^pow / 2π)) + 4
	grid = fill(0, (grid_size, grid_size))
	grid[grid_size ÷ 2, grid_size ÷ 2] = 2^pow
	
	return grid
end

function StabilizeNormal(grid, neighbors)
	counter = 0
	
	t = @elapsed while any(x -> x >= 4, grid)
	    for i in CartesianIndices(grid)
	        if grid[i] >= 4
				grid[i] -= 4
				current_neighbors = i .+ neighbors
				grid[current_neighbors] .+= 1
			end
	    end
		
		counter += 1
	end

	return grid, counter, t
end

pow = 16
neighbors_vn = CartesianIndex.([(0,-1), (-1,0), (1,0), (0,1)])
grid_normal = InitializeStackedGrid(pow)
grid_normal, counter_normal, t = StabilizeNormal(grid_normal, neighbors_vn)
display(t)