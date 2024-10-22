using CircularArrays
using Plots
using Base.Threads

rows, cols = 100, 100
iterations = 1000
state = CircularArray(rand(Bool, rows, cols))
# state = CircularArray(fill(0, rows, cols))
# state = CircularArray(reshape(1:100, 10, 10)')

elapsed_time = @elapsed begin
    for gen in 1:iterations

        new_state = copy(state)

        for i in eachindex(state)
            row, col = Tuple(i)
            neighbors = [state[row + x, col + y] for x in -1:1, y in -1:1]
            neighbors[2, 2] = 0

            if sum(neighbors) < 2
                new_state[i] = 0
            elseif sum(neighbors) == 3
                new_state[i] = 1
            elseif sum(neighbors) > 3
                new_state[i] = 0
            end

            # print(i)
        end

        state .= new_state

        heatmap(state, c=:grays, title="Generation $gen", axis=false, color=:grays)

    end
end

println("Elapsed time = $elapsed_time seconds")

# gif(anim, "conways_game_of_life.gif", fps=10)