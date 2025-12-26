### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 97dd8fba-73d1-4d15-801b-da8790dfb79c
# ╠═╡ show_logs = false
#=╠═╡
begin
    import Pkg

    # activate the shared project environment
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end
  ╠═╡ =#

# ╔═╡ 59f5a12c-ac52-4f1b-8b4d-bfd6a57ab756
begin
	using OrdinaryDiffEq
	using StatsBase
	using Random; Random.seed!(1234)
	using Plots; gr()
	using ColorSchemes
	using LaTeXStrings
	using ProgressLogging
end;

# ╔═╡ 65fc2624-178c-4ad3-906b-9e31c9eb116d
using PlutoUI; PlutoUI.TableOfContents(include_definitions=false)

# ╔═╡ d3824a70-96d0-11ef-2a8a-e1a569f6bbd0
html"""
<h1> <center> Term Paper 2 </center> </h1>
This is a submission for Modelling Complex Systems (IDC621) for the year 2024-25 Monsoon Semester by Rishi Vora (MS21113).
"""

# ╔═╡ d7f79e9d-9166-4c40-a6fb-892d086432b4
md"""
Here we look at basic Kuramoto Model and how does the order parameter `r` evolve for different values of `K`. We also look at Kuramoto oscillators arranged on a two-dimensional periodic lattice!
"""

# ╔═╡ 84eae310-306a-4c17-a3c2-2724aceb510e
md"""
First, we import some packages that we will be needing along the way
"""

# ╔═╡ 9b65802a-476a-46a5-9a4e-6343e57f3862
md"""
# Simple Kuramoto Model
"""

# ╔═╡ 8fee5328-d177-4133-8c21-ae6c70209729
md"""
Here we define the differential equation that governs the model

$$\dot{\theta_{i}} = \omega_{i} + \frac{K}{N} \sum_{j=1}^{N} \sin(\theta_{j} - \theta_{i}) \qquad i=1, \ldots, N.$$

This can be written in terms of order parameters as

$$\dot{\theta_{i}} = \omega_{i} + K r \sin(\Psi - \theta_{i}) \qquad i=1, \ldots, N$$

where $\Psi$ is the average phase and $r$ is the phase coherence given by

$$re^{i \Psi} = \frac{1}{N} \sum_{j=i}^{N} e^{i \theta_{j}}$$
"""

# ╔═╡ fe6b75f3-6750-49da-85a2-6b8e2dc0d72f
function Kuramoto!(dθ, θ, p, t)
	N = p.N
	K = p.K
	ω = p.ω

	centroid = mean(exp.(im * θ)) |> (c -> (angle(c), abs(c)))
	dθ .= ω + (K * centroid[2] * sin.(centroid[1] .- θ))
end

# ╔═╡ 67e2777c-ab14-4a46-b818-2c3326a6d415
md"""
Now we solve the differential equation using RK4 as suggested here [^Nature]
"""

# ╔═╡ 3a6b512a-8982-4ae2-b23e-acf7e0062d80
function SolKuramoto(N, K, ω, θ₀, t, step_size)
	tspan = (0.0, Float64(t))
	p = (N = N, K = K, ω = ω)
	
	prob = ODEProblem(Kuramoto!, θ₀, tspan, p)
	sol = solve(prob, RK4(), saveat=step_size)
	
	return sol
end

# ╔═╡ bc1dab07-28d8-4073-858d-804e82e51b07
function GetPhaseData(sol, iter)
	θs = sol[iter]
	centroid = mean(exp.(im * θs)) |> (c -> (angle(c), abs(c)))

	return θs, centroid
end

# ╔═╡ 7e98fd17-0eb5-49a4-a89a-f9e0ecd29709
function PlotOscillators(sol)
	N = size(sol)[1]
	
	@gif for t in 1:length(sol)
		phases, centroid = GetPhaseData(sol, t)
		
		plot((range(0, 2pi, 100), 1),
			linewidth=2, linecolor=:gray, proj=:polar,
			leg=false, grid=false, showaxis=false,
			ylims=(0, 1.1))
		
		scatter!([(θ, 1) for θ in phases], zcolor=1:N)
		plot!([(0, 0), centroid], marker=:circle, markersize=[0, 8], markercolor=:orange, line=:solid, linecolor=:orange)
	end
end

# ╔═╡ 635e6e00-5587-436b-9e6d-d28a3bf685f3
md"""
## Visual representation of phase locking
"""

# ╔═╡ 574c3819-3aa4-40da-ac81-8ab946678671
begin
	N = 10
	K = 5
	ω = randn(N) * 2
	θ₀ = rand(Float64, N) * 2π
	t = 6
	step_size = 0.02
	kuramoto_sol = SolKuramoto(N, K, ω, θ₀, t, step_size)
end;

# ╔═╡ 49a3bb48-b02a-418a-ae49-752153aa139f
md"""
Now that we have the functions, first we look at phase locking of these coupled oscillators. We see, at decent enough value of `K=`$(K) (with normally distributed `ω`), after some time, the oscillators lock into a nearly same `ω`.
"""

# ╔═╡ 3a916829-a12a-4894-8550-176a380f8121
# ╠═╡ show_logs = false
PlotOscillators(kuramoto_sol)

# ╔═╡ 1f261750-fdb1-42a4-a29a-174e242666d7
md"""
## Evolution of `r`
"""

# ╔═╡ dd412d35-e46f-4cde-9a43-8b98af45ee72
md"""
Now we sweep through different values of `K` to see how the `r` evolves for each `K`. As we can see, there is a clear jump in $r_{\infty}$ values near a specific `K`.
"""

# ╔═╡ 419b9efc-3163-4024-b3fa-9bf755e6b871
begin
	evR_N = 20000
	evR_ω = randn(evR_N) * 1.5
	evR_θ₀ = rand(Float64, evR_N) * 2π
	evR_t = 30
	evR_step_size = 0.1

	evR_plot = plot(xlabel="t", ylabel="r", leg=false)
	r_inf = []

	evR_K = range(start=0, stop=10, step=0.1)

	for K in evR_K
		coherences = []
		evR_kuramoto_sol = SolKuramoto(evR_N, K, evR_ω, evR_θ₀, evR_t, evR_step_size)

		for t in 1:length(evR_kuramoto_sol)
			phases, centroid = GetPhaseData(evR_kuramoto_sol, t)
			push!(coherences, centroid[2])
		end

		plot!(0:evR_step_size:evR_t, coherences, line_z=K, c=:viridis)
		push!(r_inf, mean(coherences[length(coherences)÷2:end]))
	end

	evR_plot
end

# ╔═╡ 29880e68-3b33-49e5-b1b6-1ddda008b07f
md"""
## Threshold `K`
"""

# ╔═╡ 627caa70-d53b-4728-9fcb-ca038ba3a7e2
begin
	plot(evR_K, r_inf, marker=(:circle,3), xlabel=L"K", ylabel=L"r_\infty", label="")

	Kc = evR_K[argmax(abs.(diff(r_inf)))]
	vline!([Kc], label=L"K_{c}")
end

# ╔═╡ f1ea051e-7334-49a4-9211-939834252e68
md"""
To see it more clearly, here we plot $r_{\infty}$ vs $K$. As apparent, the threshold is roughly at `K=`$(Kc)
"""

# ╔═╡ ca8abef2-b7db-4f96-b454-745d92722c65
md"""
# Coupled oscillators on 2D periodic lattice
"""

# ╔═╡ e2f46ad8-aa19-4d98-bb49-0a133b08f2ad
md"""
The coupling here is not mean field, rather we have chosen nearest neighbor coupling.
"""

# ╔═╡ e6f6c80b-10ec-456c-8165-4bcef1de8923
function NNKuramoto!(dθ, θ, p, t)
	neighbors = p.neighbors
	K = p.K
	ω = p.ω
	ϕ = p.ϕ

	dθ .= ω + K * mean([sin.(circshift(θ, neighbor) - θ + ϕ) for neighbor in neighbors])
end

# ╔═╡ 23b0bdb7-6e0b-4f2c-a3dd-2c1d6299b729
function NNKuramotoPlot(sol)
	h = heatmap(axis=false, grid=false, aspect_ratio=:equal, clims=(0,2π), colorbar_title="Phase")

	NN_phases = [mod.(sol[t], 2π) for t in 1:length(sol)]
	
	@gif for t in 1:length(sol)
		heatmap!(NN_phases[t], c=:vikO)
	end
end

# ╔═╡ cf595007-7a1f-4db2-9bf8-521bb9bdb83b
begin
	NN_N = 100 # 100x100 lattice
	NN_dims = (NN_N, NN_N)
	NN_K = 5 # Coupling strength
	NN_ω = randn(NN_dims) * 2
	NN_θ₀ = rand(Float64, NN_dims) * 2π
	NN_t = 20
	NN_step_size = 0.1

	# neighbors_vn = [(-1,0), (0,-1), (0, 1), (1,0)]
	neighbors_moore = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1, -1), (1,0), (1, 1)]
end;

# ╔═╡ 51d6854b-fbfb-46ab-820d-4bc33c42430e
function NNSolKuramoto(neighbors, K, ω, θ₀, t, step_size, ϕ=fill(0, NN_dims))
	tspan = (0.0, Float64(t))
	ϕ = ϕ
	p = (neighbors = neighbors, K = K, ω = ω, ϕ = ϕ)
	
	prob = ODEProblem(NNKuramoto!, θ₀, tspan, p)
	sol = solve(prob, RK4(), saveat=step_size)
	
	return sol
end

# ╔═╡ 5ea436e7-1807-408b-9692-42f9d11b0acd
# ╠═╡ show_logs = false
NNKuramotoPlot(NNSolKuramoto(neighbors_moore, NN_K, NN_ω, NN_θ₀, NN_t, NN_step_size))

# ╔═╡ 22d550d5-3d1a-416b-9d14-44cfc2b29f29
md"""
## With phase offset
"""

# ╔═╡ 06471683-81e6-4ed5-a6e1-139e1ccbbbfc
md"""
Now we introduce an offset of π/4.
"""

# ╔═╡ c155408d-c511-4115-b5ad-d3ff87f4abaa
begin
	NN_offset_N = 100
	NN_offset_dims = (NN_offset_N, NN_offset_N)
	NN_offset_K = 300
	NN_offset_ω = randn(NN_offset_dims) * 2
	NN_offset_θ₀ = rand(Float64, NN_offset_dims) * 2π
	NN_offset_t = 0.5
	NN_offset_step_size = 0.002
	offset = π/6
	NN_offset_ϕ = fill(offset, NN_offset_dims)
end;

# ╔═╡ d434a163-4737-4c89-837a-52b2f8c9b479
# ╠═╡ show_logs = false
NNKuramotoPlot(NNSolKuramoto(neighbors_moore, NN_offset_K, NN_offset_ω, NN_offset_θ₀, NN_offset_t, NN_offset_step_size, NN_offset_ϕ))

# ╔═╡ 7b12f4ae-2f4d-4b83-905d-66b36160afd1
md"""
# References
[^Nature]: Hu, X., Boccaletti, S., Huang, W. et al. Exact solution for first-order synchronization transition in a generalized Kuramoto model. Sci Rep 4, 7262 (2014). [https://doi.org/10.1038/srep07262](https://doi.org/10.1038/srep07262)
"""

# ╔═╡ Cell order:
# ╟─d3824a70-96d0-11ef-2a8a-e1a569f6bbd0
# ╟─97dd8fba-73d1-4d15-801b-da8790dfb79c
# ╟─d7f79e9d-9166-4c40-a6fb-892d086432b4
# ╟─84eae310-306a-4c17-a3c2-2724aceb510e
# ╠═59f5a12c-ac52-4f1b-8b4d-bfd6a57ab756
# ╟─65fc2624-178c-4ad3-906b-9e31c9eb116d
# ╟─9b65802a-476a-46a5-9a4e-6343e57f3862
# ╟─8fee5328-d177-4133-8c21-ae6c70209729
# ╠═fe6b75f3-6750-49da-85a2-6b8e2dc0d72f
# ╟─67e2777c-ab14-4a46-b818-2c3326a6d415
# ╠═3a6b512a-8982-4ae2-b23e-acf7e0062d80
# ╠═7e98fd17-0eb5-49a4-a89a-f9e0ecd29709
# ╠═bc1dab07-28d8-4073-858d-804e82e51b07
# ╟─635e6e00-5587-436b-9e6d-d28a3bf685f3
# ╟─49a3bb48-b02a-418a-ae49-752153aa139f
# ╠═574c3819-3aa4-40da-ac81-8ab946678671
# ╠═3a916829-a12a-4894-8550-176a380f8121
# ╟─1f261750-fdb1-42a4-a29a-174e242666d7
# ╟─dd412d35-e46f-4cde-9a43-8b98af45ee72
# ╠═419b9efc-3163-4024-b3fa-9bf755e6b871
# ╟─29880e68-3b33-49e5-b1b6-1ddda008b07f
# ╟─f1ea051e-7334-49a4-9211-939834252e68
# ╠═627caa70-d53b-4728-9fcb-ca038ba3a7e2
# ╟─ca8abef2-b7db-4f96-b454-745d92722c65
# ╟─e2f46ad8-aa19-4d98-bb49-0a133b08f2ad
# ╠═e6f6c80b-10ec-456c-8165-4bcef1de8923
# ╠═51d6854b-fbfb-46ab-820d-4bc33c42430e
# ╠═23b0bdb7-6e0b-4f2c-a3dd-2c1d6299b729
# ╠═cf595007-7a1f-4db2-9bf8-521bb9bdb83b
# ╠═5ea436e7-1807-408b-9692-42f9d11b0acd
# ╟─22d550d5-3d1a-416b-9d14-44cfc2b29f29
# ╟─06471683-81e6-4ed5-a6e1-139e1ccbbbfc
# ╠═c155408d-c511-4115-b5ad-d3ff87f4abaa
# ╠═d434a163-4737-4c89-837a-52b2f8c9b479
# ╟─7b12f4ae-2f4d-4b83-905d-66b36160afd1
