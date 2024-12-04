### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ e5f1e0d0-b093-11ef-1d30-1db3a6b3937d
begin
	using Graphs
	using GraphPlot
	using Random; Random.seed!(1234)
	using Plots; gr()
	using ColorSchemes
	using LaTeXStrings
	using OrdinaryDiffEq
	using StatsBase
	using DataFrames
end;

# ╔═╡ 1d8508ef-7925-4e7c-aaf6-f723ca7c2adb
begin
	g = cycle_graph(10)
	nodelabel = 1:nv(g)
end

# ╔═╡ de1debfd-7428-4a8f-be4b-16b51051c0fd
gplot(g, nodelabel=nodelabel)

# ╔═╡ b771c495-16ff-4d78-9cd8-b6261ca39003
function Social!(dθ, θ, p, t)
	ρ = p.ρ
	φ = p.φ
	λ = p.λ
	A = p.A

	@. dθ = ρ * sin(φ - θ) + (λ / $vec($sum(A, dims=1))) * $vec($sum(A * sin(θ - θ'), dims=1))
end

# ╔═╡ 4d7b5942-919a-4d61-9da4-87420210e081
function SolSocial(ρ, φ, λ, A, θ₀, t, step_size)
	tspan = (0.0, Float64(t))
	p = (ρ = ρ, φ = φ, λ = λ, A = A)
	
	prob = ODEProblem(Social!, θ₀, tspan, p)
	sol = solve(prob, RK4(), saveat=step_size)
	
	return sol
end

# ╔═╡ f0d423d1-0005-4a6e-bcaf-b9c51e91961a
function SolKuramoto(K, ω, A, θ₀, t, step_size)
	tspan = (0.0, Float64(t))
	p = (K = K, ω = ω, A = A)
	
	prob = ODEProblem(Kuramoto!, θ₀, tspan, p)
	sol = solve(prob, RK4(), saveat=step_size)
	
	return sol
end

# ╔═╡ e6f6194d-eefb-4438-928d-fcd08b2f3075
function GetPhaseData(sol, iter)
	θs = sol[iter]
	centroid = mean(exp.(im * θs)) |> (c -> (angle(c), abs(c)))

	return θs, centroid
end

# ╔═╡ dffce9ba-5afa-4b4e-9c4a-07c910be4c6e
begin
	evR_N = 75
	evR_ω = randn(evR_N) * 1.5
	evR_A = adjacency_matrix(cycle_graph(evR_N))
	evR_θ₀ = rand(Float64, evR_N) * 2π
	evR_t = 30
	evR_step_size = 0.1

	# evR_plot = plot(xlabel="t", ylabel="r", leg=false)
	r_inf = []

	evR_K = range(start=0, stop=10, step=0.1)

	for K in evR_K
		coherences = []
		evR_kuramoto_sol = SolKuramoto(K, evR_ω, evR_A, evR_θ₀, evR_t, evR_step_size)

		for t in 1:length(evR_kuramoto_sol)
			phases, centroid = GetPhaseData(evR_kuramoto_sol, t)
			push!(coherences, centroid[2])
		end

		# plot!(0:evR_step_size:evR_t, coherences, line_z=K, c=:viridis)
		push!(r_inf, mean(coherences[length(coherences)÷2:end]))
	end

	# evR_plot
end

# ╔═╡ 0b5e0b38-cc2f-4839-9779-ec9ba5967098
evR_A

# ╔═╡ cf10f075-ff07-45a9-af03-0e72fc26d6cc
begin
	plot(evR_K, r_inf, marker=(:circle,3), xlabel=L"K", ylabel=L"r_\infty", label="")

	Kc = evR_K[argmax(abs.(diff(r_inf)))]
	vline!([Kc], label=L"K_{c}")
end

# ╔═╡ cd8be9ed-9b62-490c-8a7c-c398ffa6341c
function Kuramoto!(dθ, θ, p, t)
	K = p.K
	ω = p.ω
	A = p.A

	@. dθ = ω + (K / $vec($sum(A, dims=1))) * $vec($sum(A * sin(θ - θ'), dims=1))
end

# ╔═╡ 7b1851e8-b708-48c6-b77f-c75dfa064efd
# ╠═╡ disabled = true
#=╠═╡
function Kuramoto!(dθ, θ, p, t)
	K = p.K
	ω = p.ω
	A = p.A

	for i in 1:size(A)[1]
		dθ[i] = ω[i] + (K / sum(A[:, i])) * sum(A[i, :] .* sin.(θ .- θ[i]))
	end
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═e5f1e0d0-b093-11ef-1d30-1db3a6b3937d
# ╠═1d8508ef-7925-4e7c-aaf6-f723ca7c2adb
# ╠═de1debfd-7428-4a8f-be4b-16b51051c0fd
# ╠═b771c495-16ff-4d78-9cd8-b6261ca39003
# ╠═4d7b5942-919a-4d61-9da4-87420210e081
# ╠═cd8be9ed-9b62-490c-8a7c-c398ffa6341c
# ╠═7b1851e8-b708-48c6-b77f-c75dfa064efd
# ╠═f0d423d1-0005-4a6e-bcaf-b9c51e91961a
# ╠═e6f6194d-eefb-4438-928d-fcd08b2f3075
# ╠═0b5e0b38-cc2f-4839-9779-ec9ba5967098
# ╠═dffce9ba-5afa-4b4e-9c4a-07c910be4c6e
# ╠═cf10f075-ff07-45a9-af03-0e72fc26d6cc
