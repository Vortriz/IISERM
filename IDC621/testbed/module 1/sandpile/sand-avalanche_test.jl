using Random
using Plots
using ArrayPadding
using StatsBase
using OffsetArrays: Origin
using EasyFit
using Statistics

Random.seed!(1234)
grid_size = 100

indices_unpadded = CartesianIndices((1:grid_size, 1:grid_size))
avalanche_sizes = Int[]

neighbors = CartesianIndex.([(-1,0), (0,-1), (1,0), (0,1)])

for iter in 1:10000
    grid = rand(0:3, (grid_size+2, grid_size+2))
    pad!(grid, -(2^16), 1)
    grid = Origin(0)(grid)
    counter = 0

    # unstabilize the grid
    while !any(x -> x >= 4, grid)
        site = rand(indices_unpadded)
        grid[site] += 1
    end

    # display(grid)

    while any(x -> x >= 4, grid)
        for i in indices_unpadded
            if grid[i] >= 4
                grid[i] -= 4
                grid[i .+ neighbors] .+= 1
                counter += 1
            end
        end
    end

    push!(avalanche_sizes, counter)
    # println(counter)

end

hist_data = countmap(avalanche_sizes; alg=:dict)
fit_data = Dict{Float64, Int64}()

threshold = 100

for val in filter(x -> x >= threshold, unique(values(hist_data)))
    push!(fit_data, mean(keys(filter((k,v)::Pair -> v == val, hist_data))) => Int(val))
end

scatter(log10.(keys(hist_data)), log10.(values(hist_data)))

fit = fitlinear(log10.(keys(fit_data)), log10.(values(fit_data)))
plot!(fit.x, fit.y)
savefig("sandpile-avalanche_sizes_test.png") 

display(fit.a)
# display(hist_data)