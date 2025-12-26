### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 5e49e92a-8c4a-4eb4-9275-ae3eeb7fbb90
# ╠═╡ show_logs = false
begin
    import Pkg

    # activate the shared project environment
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 3caf3cb2-8295-11ef-05f1-1f8bd52bb4a1
begin
	using Plots
	using CairoMakie
	using Colors, ColorSchemes
	using Random
	using ArrayPadding
	using StatsBase
	using EasyFit
	using Statistics
	using PlutoUI
	using Distributions
	using ImageFiltering
	using CircularArrays
	using OffsetArrays
end;

# ╔═╡ 3a3e056b-6d79-4241-a9ce-7984303b63b3
html"""
<h1> <center> Term Paper 1 </center> </h1>
This is a submission for Modelling Complex Systems (IDC621) for the year 2024-25 Monsoon Semester by Rishi Vora (MS21113).
"""

# ╔═╡ 8dd7b882-125d-4db3-a685-a6144c47c7d7
md"""
# Introduction
Firstly we look at the sandpile model as described by [^BTW1987], and demonstrate the powerlaw for avalanche size distribution. Then we look at more optimised ways to achieve the toppling behavior of the sandpile. Last but not the least, we use these optimised methods and look at a special case of sandpile on infinite square grid where we start with origin carring a huge number of grains of sand, but all other vertices are zero.
"""

# ╔═╡ 6b4c206e-9de8-4b4f-9e70-35c9868a99e7
md"""
Before anything else, we import some packages that we will be needing along the way
"""

# ╔═╡ fdaa1cdd-0e42-4c36-a5a8-779dd7b0ac3e
PlutoUI.TableOfContents(include_definitions=false)

# ╔═╡ 45d3cac0-a7ae-43f3-a5b5-a99fb0001d78
md"""
# The original Sandpile Model

In the model, a sandpile grid is introduced; it is an $N$ by $N$ grid, wherein each grid cell can have $0$ to $3$ sand particles. At each iteration, a single grain of sand is added to the system by dropping it on a random cell in the sandpile grid. Once a cell stockpiles $4$ particles of sand, the grains are then distributed (toppled over) to the neighboring cells, with each neighbor gaining a grain of sand. This toppling over of grains from one cell to the neighboring cells can lead the entire system to criticality causing avalanches resulting to some grains leaving the system when the toppling over happens at the grid's edge. With the same internal mechanism (dropping of a grain of sand) governing the sandpile, the resulting avalanche sizes can have varying largeness.
"""

# ╔═╡ 79ff688c-896d-4893-9985-70c765004cfd
md"""
## Functions
"""

# ╔═╡ 70a2316a-4b71-4df1-81dc-d58cfb9e282e
md"""
To work with the sandpile model, here we define a function that initializes a square grid of size `grid_size` where each cell contains anywhere from `0` to `3` grains of sand. It also pads the grid with a large negative value $(-2^{16})$ which acts as a sink.
"""

# ╔═╡ 25d77e4b-6f79-4513-afd0-9aed29cf6015
function InitializeRandomGrid(grid_size)
	grid = rand(0:3, (grid_size+2, grid_size+2))
	pad!(grid, -(2^16), 1)

	return grid
end

# ╔═╡ 44c0c2e7-6430-4233-8f43-a2a63f7d7bfe
md"""
This function drops sand one grain at a time at random positions till the `grid` gets unstable (**in place**). It is used to destabilize the `grid` and create avalanches.
"""

# ╔═╡ 8d42d66f-7a3e-4ceb-8074-1a11b9be8572
function DropSand!(grid)
	 while !any(x -> x >= 4, grid)
        site = rand(CartesianIndices(grid))
        grid[site] += 1
    end
end

# ╔═╡ 06339bd6-9274-4a6c-9bf5-34d50a58b2df
md"""
This function stabilizes the given `grid` using the given `neighbor`hood (which is normally Von Neumann neighborhood) and returns the stabilized `grid`.
"""

# ╔═╡ 186ea2b6-929b-43dd-8353-5602cc525f96
function Stabilize(grid, neighbors)
	while any(x -> x >= 4, grid)
	    for i in CartesianIndices(grid)
	        if grid[i] >= 4
				grid[i] -= 4
				current_neighbors = i .+ neighbors
				grid[current_neighbors] .+= 1
			end
	    end
	end

	return grid
end

# ╔═╡ 44d55ea2-4258-4a15-a04e-2101e0300172
md"""
This function stabilizes the given `grid` **in place** using the given `neighbor`hood. It also counts the time steps taken to stabilize the grid and the domain of the avalanche, and returns it as `counter` and `affected_sites`.
"""

# ╔═╡ 65cdab40-205f-4d94-8b99-5576bf67ca27
function Stabilize!(grid, neighbors)
	counter = 0
	affected_sites = Set{CartesianIndex}()
	
	while any(x -> x >= 4, grid)
	    for i in CartesianIndices(grid)
	        if grid[i] >= 4
				grid[i] -= 4
				current_neighbors = i .+ neighbors
				grid[current_neighbors] .+= 1
				
				counter += 1
				push!(affected_sites, i, current_neighbors...)
			end
	    end
	end

	return counter, affected_sites
end

# ╔═╡ 7bdb78d1-63ab-4ee6-85ab-3ee4d36e6e60
md"""
This function plots the data thus generated on a log-log plot and fits it to a powerlaw.
"""

# ╔═╡ b5c829ea-09d6-460e-af54-e321fc052430
function PlotPowerlaw(data, threshold)
	hist_data = countmap(data; alg=:dict)
	fit_data = Dict{Float64, Int64}()
	
	for val in filter(x -> x >= threshold, unique(values(hist_data)))
	    push!(fit_data, mean(keys(filter((k,v)::Pair -> v == val, hist_data))) => Int(val))
	end
	
	Plots.scatter(log10.(keys(hist_data)), log10.(values(hist_data)), label="Avalanches")
	
	fit = EasyFit.fitlinear(log10.(keys(fit_data)), log10.(values(fit_data)))
	Plots.plot!(fit.x, fit.y, label = "α = $(-round(fit.a, digits = 2))")
end

# ╔═╡ 81922a45-2537-423e-a1ae-b62c69dd4fba
md"""
Now we define the two common neighborhoods.
"""

# ╔═╡ 30b7e534-16a3-44e8-9902-6982cc7cc468
neighbors_vn = CartesianIndex.([(0,-1), (-1,0), (1,0), (0,1)])

# ╔═╡ 58c1b23b-db97-4288-84d0-cb6b692e8d65
md"""
## Simulation

Here we simulate `10000` avalanches on a grid of size `100` and plot the powerlaw of distribution of `topplings` and `avalanche_sizes`.
"""

# ╔═╡ 70e3bca6-a1aa-4654-a6cf-95cf236ec7fd
begin
	Random.seed!(1234)
	grid_size = 100
	topplings = Int[]
	avalanche_sizes = Int[]
	iterations_a = 10000
end;

# ╔═╡ 4a882b4c-6392-4aa6-ac5c-ee4776686b87
grid_random = InitializeRandomGrid(grid_size);

# ╔═╡ 5bf236e3-51f7-4b48-8d77-60cd5e3f21d2
for iter in 1:iterations_a
	DropSand!(grid_random)
	counter, affected_sites = Stabilize!(grid_random, neighbors_vn)
	push!(topplings, counter)
	push!(avalanche_sizes, length(affected_sites))
end

# ╔═╡ 8701c031-4551-4752-9570-28e196a183d5
md"""
## Powerlaw
As per [^Bak1996], we should get $\alpha \approx 1.1$ for `topplings`, which is what we actually got.
"""

# ╔═╡ 229123be-d06c-4b5e-8101-6376a13643fe
PlotPowerlaw(topplings, 10)

# ╔═╡ 02bd9f1c-5312-4645-9e7c-3a8117adc7ef
PlotPowerlaw(avalanche_sizes, 10)

# ╔═╡ 802f2026-c265-4cf9-9f62-d2d82bde9a5d
md"""
!!! note "Note"
	We are discarding values in `topplings` and `avalanche_sizes` that have lesser than `10` counts, to discard the tail data.
"""

# ╔═╡ 0b7b02da-7381-4a10-a7fa-33758d0241a7
md"""
# Sandpile on infinite square grid
"""

# ╔═╡ 584fbfb7-50af-4da7-96c2-f1ccc8b6c12a
md"""
This is a popular variant of the sandpile model. Here we put a large number of grains of sand at the center of the grid and then stabilize it. The grid size should ideally be infinite (so that no grain goes into the sink) but for simulation purposes, we take it to be $\sqrt{\frac{N}{2 \pi}} + 4$ where $N$ is the number of grains of sand in the middle (as per [^PG]), which is a good enough estimate.

Beautiful fractal like patterns should emerge in the stabilized grid.
"""

# ╔═╡ 3cc557d0-f2de-4f98-9e8d-534130870f45
begin
	pow = 14
	print("This will put 2^$pow chips at the center")
end

# ╔═╡ f1ffac9f-a0a9-4bc5-a119-d133b94390e2
function InitializeStackedGrid(pow)
	grid_size = ceil(Int, 2 * sqrt(2^pow / 2π)) + 4
	grid = fill(0, (grid_size, grid_size))
	grid[grid_size ÷ 2, grid_size ÷ 2] = 2^pow
	
	return grid
end

# ╔═╡ 810a6990-7874-4c72-8e15-81bfd38f227a
function PlotSandGrid(grid)
	figure = (; font="CMU Serif")
	fig, ax, pltobj = CairoMakie.heatmap(grid;
	    colormap=Makie.Categorical(cgrad(:sunset, rev=true)))
	cbar = Colorbar(fig[1, 2], pltobj)
	hidedecorations!(ax)
	colsize!(fig.layout, 1, Aspect(1, 1.0))

	return fig
end

# ╔═╡ 9a591608-fe34-49ff-980c-2d4d8b0f3812
md"""
## Optimising grid stabilization
"""

# ╔═╡ a277ac43-a7a1-44dd-bffc-f4b036e68072
md"""
### 1. The original way
"""

# ╔═╡ 6ed694cf-4a7f-421e-8c18-9d2eda322fbc
md"""
This is the original way to stabiize the grid.
"""

# ╔═╡ 0308e9b7-4c60-4b9a-a33f-d4cb27f41914
function StabilizeNorm(grid, neighbors)
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

# ╔═╡ 2f950378-a726-454c-8e9a-2ecfd64da226
begin
	grid_normal = InitializeStackedGrid(pow)
	counter_normal = StabilizeNorm(grid_normal, neighbors_vn)[2]
	display(counter_normal)
end

# ╔═╡ 6a3b1c56-4510-4738-8b42-d7bd3b9cce8d
md"""
So the normal way takes **$(counter_normal)** iterations to stabilize $(2^pow) grains of sand.
"""

# ╔═╡ 3922261f-4eac-46f8-b16f-ddd70054887f
md"""
Now we realise that for large number of grains of sand, the process of going to each cell and toppling sand $4$ grains at a time is not very efficient. So lets look at some more efficient ways to achieve stable configurations.
"""

# ╔═╡ 04380f48-fd47-479b-aed2-ddcc8d5cc3d4
md"""
### 2. Fire chips

Deepak Dhar [^Dhar1990] discovered that BTW sandpile model [^BTW1987] follows abelian dynamics i.e. order of topping of grains does not matter. This realization paved way to stabilize the grid more efficiently.

One such method is: if a cell (lets say $z(x,y)$) contains $4n + k$ chips $(n, k \in \mathcal{Z})$ (I will use "chips" and "grains of sand" interchangeably), then instead of toppling $4$ chips at a time, we do:

$$\begin{align}
z(x, y) & \to z(x, y) - 4n \\
z(x \pm 1, y) & \to z(x \pm 1, y) + n \\
z(x, y \pm 1) & \to z(x, y \pm 1) + n \\
\end{align}$$

This is what we call **firing chips** and it will reduce the number of iterations it takes to stabilize the `grid`.
"""

# ╔═╡ 13c12e8a-8e32-44b3-93e3-e4e7752dacd4
function StabilizeFire(grid, neighbors)
	counter = 0

	t = @elapsed while any(x -> x >= 4, grid)
	    for i in CartesianIndices(grid)
	        if grid[i] >= 4
	            grid[i .+ neighbors] .+= grid[i] ÷ 4
	            grid[i] %= 4
	        end
	    end
		
		counter += 1
	end

	return grid, counter, t
end

# ╔═╡ 85e59be3-1773-476d-bfe5-b72dad01cfb7
begin
	grid_fire = InitializeStackedGrid(pow)
	counter_fire = StabilizeFire(grid_fire, neighbors_vn)[2]
	display(counter_fire)
end

# ╔═╡ 213b3eb2-185f-492e-8072-5ba9af10894a
md"""
This only takes **$counter_fire** iterations to stabilize the same amount of chips!
"""

# ╔═╡ 5abd65cb-9b40-45bd-a272-88d320740458
md"""
### 3. Convolution

This firing of chips can also be representated as convolution over the `grid` with the kernel

$$\begin{bmatrix}
0 & 0.25 & 0 \\
0.25 & 0 & 0.25 \\
0 & 0.25 & 0
\end{bmatrix}$$

for Von Neumann neighborhood.
"""

# ╔═╡ 2b5335f4-1112-4b94-92bf-cae91ad80209
function Convolve(grid, kernel)

	arr_to_conv = 4 .* (grid .÷ 4)
	arr_convd = round.(Int, imfilter(arr_to_conv, kernel, Fill(0, kernel)))
	grid_new = (grid .% 4) + arr_convd

	return grid_new
end

# ╔═╡ 59cfb8f0-2ad2-429d-94b5-1e89a44c63c3
function StabilizeConv(grid, neighbors)
	counter = 0
	kernel = OffsetArrays.Origin(-1, -1)(fill(0.0, (3,3)))
	kernel[neighbors] .= 1/4
	
	t = @elapsed while any(x -> x >= 4, grid)
		grid = Convolve(grid, kernel)
		counter += 1
	end

	return grid, counter, t
end

# ╔═╡ b7730aca-5e14-4373-9107-6858cb9743ad
begin
	grid_conv = InitializeStackedGrid(pow);
	counter_conv = StabilizeConv(grid_conv, neighbors_vn)[2]
	display(counter_conv)
end

# ╔═╡ 9bc17ea6-4030-4d07-b582-e4c895e48891
md"""
This method takes **$counter_conv** iterations to stabilize the same amount of chips.
"""

# ╔═╡ ac5690b8-f0c1-45ba-9e1a-3b739fbb3a72
md"""
### 4. Pull method

There is also an alternate and rather ingenious way. Instead of pushing $>=4$ chips, pull from the neighbors. The algorithm is as follows:

```
for each i in sandpiles {
    if input[i] < 4 {
        output[i] = input[i]
    } else {
        output[i] = input[i] - 4
    }
    for each j in neighbors {
        if input[j] >= 4 {
            output[i] = output[i] + 1
        }
    }
}
```

Advantage of this is that since it does update any other cells other than the one it it currently looking at, it can be easily parallelized!
"""

# ╔═╡ 11bf9cb3-43c5-447d-aef6-477e8876c36e
function Pull(grid, neighbors)
	output = similar(grid)

    @Threads.threads for i in CartesianIndices(grid)
        neighbor_elements = grid[i .+ neighbors]  
        output[i] = (grid[i] % 4) + sum(neighbor_elements .÷ 4)
    end

    return output
end

# ╔═╡ 9c4d051e-2d65-451f-8c21-e973fb0efda9
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

# ╔═╡ d2abb4ad-ca9d-4d0f-85bf-fd51562718c9
begin
	grid_pull_init = InitializeStackedGrid(pow)
	counter_pull = StabilizePull(grid_pull_init, neighbors_vn)[2]
	display(counter_pull)
end

# ╔═╡ 8a571e94-84e4-4a1b-8594-0f01bf43bd5c
md"""
This method takes **$counter_pull** iterations, which is same as the convolution method.
"""

# ╔═╡ 2443d261-c5a9-47a7-a462-f1a9259818ac
md"""
### Comparing all four methods

Now lets see how these methods compete in terms of time taken to stabilize the grid.
"""

# ╔═╡ 58824293-e9a6-46dc-9be8-72cdbb6999f2
function Benchmark(stabilize, neighbors, pow)
	grid_benchmark = InitializeStackedGrid(pow)
	t = stabilize(grid_benchmark, neighbors)[3]
	
	return t
end

# ╔═╡ 7266fc60-f640-46b7-9caf-88624616db27
begin
	powers = 1:17
	times = Dict("Norm" => Float64[], "Fire" => Float64[], "Conv" => Float64[], "Pull" => Float64[])
end;

# ╔═╡ c3301ad4-7e2a-478b-b765-11ccd5d5a955
for pow in powers[1:16]
	push!(times["Norm"], Benchmark(StabilizeNorm, neighbors_vn, pow))
	push!(times["Pull"], Benchmark(StabilizePull, neighbors_vn, pow))
end

# ╔═╡ cc4b8a11-8b6c-4a78-b4ac-0a433e4d5c9e
for pow in powers
	push!(times["Conv"], Benchmark(StabilizeConv, neighbors_vn, pow))
	push!(times["Fire"], Benchmark(StabilizeFire, neighbors_vn, pow))
end

# ╔═╡ f3c2d06b-be59-4f7e-8541-b37449861f72
md"""
As seen, I have plotted the time taken by normal and pull method till 2^17 grains of sand (going further would have taken a lot of time)
"""

# ╔═╡ 11015e81-b6df-4b9e-8228-934088d8df4d
begin
	Plots.plot(powers[1:16], times["Norm"][1:16], label = "Norm", xlims=[0,18])
	Plots.plot!(powers[1:16], times["Pull"][1:16], label = "Pull", xlims=[0,18])
	Plots.plot!(powers, times["Fire"], label = "Fire", xlims=[0,18])
	Plots.plot!(powers, times["Conv"], label = "Conv", xlims=[0,18])
	Plots.vline!([16], linestyle=:dash, label = "2^17")

	xaxis!("Number of chips (in powers of 2)")
	yaxis!("t (in s)")
end

# ╔═╡ 9b4c31b0-bc02-4fa3-8546-98ca32f6356a
md"""
As we can see, on logarithmic time scale, the time difference is decreasing. So at even higher chip counts, convolution may take over as the fastest method.
"""

# ╔═╡ f1b2570a-e597-4907-af12-1da1f556d8d6
begin
	Plots.plot(powers[9:end], times["Fire"][9:end], label = "Fire", yscale=:log10, legend=:left)
	Plots.plot!(powers[9:end], times["Conv"][9:end], label = "Conv", yscale=:log10)
end

# ╔═╡ 21b7ef58-3464-434c-b73f-ebfc48401d28
md"""
## Simulation

Now that we know that firing chips is the most efficient method for us, lets use that to stabilize grid with large number of chips at the center and look at the output!
"""

# ╔═╡ bbdb6c21-3c0b-4bf1-91f4-3deae2771276
begin
	pow_vis = 18
	grid_vis_init = InitializeStackedGrid(pow_vis)
	grid_vis = StabilizeFire(grid_vis_init, neighbors_vn)[1]
end;

# ╔═╡ 1623c95c-8d64-4360-85b1-b5e4dbf948f3
md"""
Here we have put 2^$pow_vis chips. As we can see, fractal like patterns emerge. Also, the output has axial symmetry.
"""

# ╔═╡ 2a01cf7e-02dc-4992-ac19-85fea97e804e
PlotSandGrid(grid_vis)

# ╔═╡ c7e441fb-16be-480c-bccf-c9e01c85e09b
md"""
## Identity element

All the possible stable configurations of a $N$ by $N$ grid form a set. This set contains a special element called the **identity element** that, when added to any element of this set, gives back the element.

An algorithm to compute this identity element is given in [^Identity] which is `f(S - f(S))` where `f` is the stabilize function and `S` is the $N$ by $N$ matrix with filled with $6$s.
"""

# ╔═╡ 77abbdb3-cfb9-4d96-981b-7383306307f1
function IdentityElement(grid_size, neighbors)	
	a = fill(6, (grid_size, grid_size))
	# pad!(a, -(2^17), 1)
	b = fill(6, (grid_size, grid_size))
	# pad!(b, -(2^16), 1)
	 
	grid = StabilizeConv(a - StabilizeConv(b, neighbors)[1], neighbors)[1]

	return grid
end

# ╔═╡ d4a0c176-caea-4dc4-b199-4898fab02c99
md"""
Here we have used the convolution method to stabilize the grid since our stacks aren't big.
"""

# ╔═╡ 55e25104-8e36-479f-bc26-c2dd9291f629
begin
	grid_size_identity = 100
	grid_identity = IdentityElement(grid_size_identity, neighbors_vn)
end;

# ╔═╡ 1eb8955d-569c-44e0-817e-47c007b21ae0
PlotSandGrid(grid_identity)

# ╔═╡ 523f9e20-5d69-46a7-907d-903e7621324a
md"""
# References
[^BTW1987]: Per Bak, Chao Tang and Kurt Weisenfeld. “Self-Organized Criticality: An Explanation of 1/f Noise” Physical Review Letters, 59 (1987). [https://doi.org/10.1103/PhysRevLett.59.381](https://doi.org/10.1103/PhysRevLett.59.381)

[^Bak1996]: Per Bak, How Nature Works: The Science of Self-organized Criticality. New York, NY, USA: Copernicus, 1996. [https://doi.org/10.1007/978-1-4757-5426-1](https://doi.org/10.1007/978-1-4757-5426-1)

[^PG]: [https://physicspython.wordpress.com/2019/05/11/abelian-sandpile-a-c-project-part-3/](https://physicspython.wordpress.com/2019/05/11/abelian-sandpile-a-c-project-part-3/)

[^Dhar1990]: Dhar (1990). "Self-organized Critical State of Sandpile Automaton Models". Physical Review Letters. 64 (14) [https://doi.org/10.1103/PhysRevLett.64.1613](https://doi.org/10.1103/PhysRevLett.64.1613)

[^Identity]: [https://people.reed.edu/~davidp/divisors_and_sandpiles/](https://people.reed.edu/~davidp/divisors_and_sandpiles/)
"""

# ╔═╡ Cell order:
# ╟─3a3e056b-6d79-4241-a9ce-7984303b63b3
# ╟─5e49e92a-8c4a-4eb4-9275-ae3eeb7fbb90
# ╟─8dd7b882-125d-4db3-a685-a6144c47c7d7
# ╟─6b4c206e-9de8-4b4f-9e70-35c9868a99e7
# ╠═3caf3cb2-8295-11ef-05f1-1f8bd52bb4a1
# ╟─fdaa1cdd-0e42-4c36-a5a8-779dd7b0ac3e
# ╟─45d3cac0-a7ae-43f3-a5b5-a99fb0001d78
# ╟─79ff688c-896d-4893-9985-70c765004cfd
# ╟─70a2316a-4b71-4df1-81dc-d58cfb9e282e
# ╠═25d77e4b-6f79-4513-afd0-9aed29cf6015
# ╟─44c0c2e7-6430-4233-8f43-a2a63f7d7bfe
# ╠═8d42d66f-7a3e-4ceb-8074-1a11b9be8572
# ╟─06339bd6-9274-4a6c-9bf5-34d50a58b2df
# ╠═186ea2b6-929b-43dd-8353-5602cc525f96
# ╟─44d55ea2-4258-4a15-a04e-2101e0300172
# ╠═65cdab40-205f-4d94-8b99-5576bf67ca27
# ╟─7bdb78d1-63ab-4ee6-85ab-3ee4d36e6e60
# ╠═b5c829ea-09d6-460e-af54-e321fc052430
# ╟─81922a45-2537-423e-a1ae-b62c69dd4fba
# ╠═30b7e534-16a3-44e8-9902-6982cc7cc468
# ╟─58c1b23b-db97-4288-84d0-cb6b692e8d65
# ╠═70e3bca6-a1aa-4654-a6cf-95cf236ec7fd
# ╠═4a882b4c-6392-4aa6-ac5c-ee4776686b87
# ╠═5bf236e3-51f7-4b48-8d77-60cd5e3f21d2
# ╟─8701c031-4551-4752-9570-28e196a183d5
# ╠═229123be-d06c-4b5e-8101-6376a13643fe
# ╠═02bd9f1c-5312-4645-9e7c-3a8117adc7ef
# ╟─802f2026-c265-4cf9-9f62-d2d82bde9a5d
# ╟─0b7b02da-7381-4a10-a7fa-33758d0241a7
# ╟─584fbfb7-50af-4da7-96c2-f1ccc8b6c12a
# ╠═3cc557d0-f2de-4f98-9e8d-534130870f45
# ╠═f1ffac9f-a0a9-4bc5-a119-d133b94390e2
# ╠═810a6990-7874-4c72-8e15-81bfd38f227a
# ╟─9a591608-fe34-49ff-980c-2d4d8b0f3812
# ╟─a277ac43-a7a1-44dd-bffc-f4b036e68072
# ╟─6ed694cf-4a7f-421e-8c18-9d2eda322fbc
# ╠═0308e9b7-4c60-4b9a-a33f-d4cb27f41914
# ╠═2f950378-a726-454c-8e9a-2ecfd64da226
# ╟─6a3b1c56-4510-4738-8b42-d7bd3b9cce8d
# ╟─3922261f-4eac-46f8-b16f-ddd70054887f
# ╟─04380f48-fd47-479b-aed2-ddcc8d5cc3d4
# ╠═13c12e8a-8e32-44b3-93e3-e4e7752dacd4
# ╠═85e59be3-1773-476d-bfe5-b72dad01cfb7
# ╟─213b3eb2-185f-492e-8072-5ba9af10894a
# ╟─5abd65cb-9b40-45bd-a272-88d320740458
# ╠═2b5335f4-1112-4b94-92bf-cae91ad80209
# ╠═59cfb8f0-2ad2-429d-94b5-1e89a44c63c3
# ╠═b7730aca-5e14-4373-9107-6858cb9743ad
# ╟─9bc17ea6-4030-4d07-b582-e4c895e48891
# ╟─ac5690b8-f0c1-45ba-9e1a-3b739fbb3a72
# ╠═11bf9cb3-43c5-447d-aef6-477e8876c36e
# ╠═9c4d051e-2d65-451f-8c21-e973fb0efda9
# ╠═d2abb4ad-ca9d-4d0f-85bf-fd51562718c9
# ╟─8a571e94-84e4-4a1b-8594-0f01bf43bd5c
# ╟─2443d261-c5a9-47a7-a462-f1a9259818ac
# ╠═58824293-e9a6-46dc-9be8-72cdbb6999f2
# ╠═7266fc60-f640-46b7-9caf-88624616db27
# ╠═c3301ad4-7e2a-478b-b765-11ccd5d5a955
# ╠═cc4b8a11-8b6c-4a78-b4ac-0a433e4d5c9e
# ╟─f3c2d06b-be59-4f7e-8541-b37449861f72
# ╠═11015e81-b6df-4b9e-8228-934088d8df4d
# ╟─9b4c31b0-bc02-4fa3-8546-98ca32f6356a
# ╠═f1b2570a-e597-4907-af12-1da1f556d8d6
# ╟─21b7ef58-3464-434c-b73f-ebfc48401d28
# ╠═bbdb6c21-3c0b-4bf1-91f4-3deae2771276
# ╟─1623c95c-8d64-4360-85b1-b5e4dbf948f3
# ╠═2a01cf7e-02dc-4992-ac19-85fea97e804e
# ╟─c7e441fb-16be-480c-bccf-c9e01c85e09b
# ╠═77abbdb3-cfb9-4d96-981b-7383306307f1
# ╟─d4a0c176-caea-4dc4-b199-4898fab02c99
# ╠═55e25104-8e36-479f-bc26-c2dd9291f629
# ╠═1eb8955d-569c-44e0-817e-47c007b21ae0
# ╟─523f9e20-5d69-46a7-907d-903e7621324a
