using Random
using Plots
using ArrayPadding
using StatsBase
using OffsetArrays: Origin
using EasyFit
using Statistics
using Distributions

Random.seed!(1234)
grid_size = 100
grid = rand(0:3, (grid_size+2, grid_size+2))
pad!(grid, -(2^16), 1)
grid = Origin(0)(grid)
indices_unpadded = CartesianIndices((1:grid_size, 1:grid_size))
avalanche_sizes = Int[]

neighbors = CartesianIndex.([(-1,0), (0,-1), (1,0), (0,1)])

for iter in 1:1000
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

# Fit a Categorical distribution to the avalanche sizes
dist = fit(Categorical, avalanche_sizes)

# Calculate the PMF
unique_sizes = unique(avalanche_sizes)
pmf = [pdf(dist, size) for size in unique_sizes]

# Plot the PMF
scatter(unique_sizes, pmf, xscale=:log10, yscale=:log10)

# Save the plot
savefig("pmf_avalanche_sizes.png")