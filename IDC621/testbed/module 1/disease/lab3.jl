using CircularArrays
using Plots
using Distributions

grid_size = 200
rows, cols = grid_size, grid_size
iterations = 500
state = CircularArray(fill(0, rows, cols))
custom_colors = [:white, :red, :black]

init = 50
# state[rand(1:100, init), rand(1:100, init)] .= 1

for i in 1:init
    state[rand(1:grid_size), rand(1:grid_size)] = 1
end

τ_i, τ_r = 5, 40
τ_0 = τ_i + τ_r

neighborhood = "moore"

if neighborhood == "moore"
    num_neighbors = 8
elseif neighborhood == "von_neumann"
    num_neighbors = 4
end

anim = @animate for gen in 1:iterations
    new_state = copy(state)
     
    for i in CartesianIndices(state)
        row, col = Tuple(i)
        # neighbors = state[CartesianIndex.([row-1 row row+1 row], [col col-1 col col+1])]
        neighbors = [state[row + x, col + y] for x in -1:1, y in -1:1]

        if state[i] == 0 && any(x -> 1 <= x <= τ_i, neighbors)
            new_state[i] = rand(Bernoulli(length(filter(x -> 1 <= x <= τ_i, neighbors)) / num_neighbors))
        end
        if 1 <= state[i] < τ_0
            new_state[i] = state[i] + 1
        end
        if state[i] == τ_0
            new_state[i] = 0
        end

    end

    state .= new_state

    heatmap(state, c=cgrad(custom_colors, [1/τ_0, (1 + τ_i)/τ_0], categorical=true), clims=(0, τ_0), title="t=$gen", axis=false, aspect_ratio=:equal)
end

gif(anim, "sirs_1_random_init_moore.gif", fps=10)

# heatmap(map(x -> min(x, 4), grid), axis=false, clims=(0, 4), ticks=(1,2,3), aspect_ratio=:equal, c=cgrad(:sunset, 4, categorical=true, rev=true))
# gif(anim, "sandpile.gif", fps=1)
# anim = @animate 