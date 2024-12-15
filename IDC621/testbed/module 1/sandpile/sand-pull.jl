using Plots
using CircularArrays

init = 16
grid_size = ceil(Int, 2*sqrt(2^init / 2π)) + 4
grid = fill(0, (grid_size, grid_size))
grid[grid_size ÷ 2, grid_size ÷ 2] = 2^init

input = CircularArray(grid)
output = copy(input)

function update!(input, output)
    neighbors = CartesianIndex.([(-1,0), (0,-1), (1,0), (0,1)])

    @Threads.threads for i in CartesianIndices(input)
        neighbor_elements = input[i .+ neighbors] 
        
        output[i] = (input[i] % 4) + sum(neighbor_elements .÷ 4)
    end

    return output
end

@time while any(x -> x >= 4, output)
    fill!(output, 0)
    update!(input, output)

    global input .= output
end

# display(input)
heatmap(input, size=(3000,2000), axis=false, clims=(0, 4), aspect_ratio=:equal, c=cgrad(:sunset, rev=true))
# heatmap(input, axis=false, clims=(0, 4), aspect_ratio=:equal, c=cgrad(:sunset, rev=true))
savefig("sandpile-pull.png") 