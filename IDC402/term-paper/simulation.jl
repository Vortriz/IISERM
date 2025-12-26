### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 1a8a95c2-26cd-4c74-8cc5-b46a160da1b8
# ╠═╡ show_logs = false
# Do not modify or remove this cell!
begin
    import Pkg

    # activate the shared project environment
    Pkg.activate(joinpath(@__DIR__, ".julia", "project"))
    Pkg.instantiate()
end

# ╔═╡ 4d997074-1f5e-4763-970a-202c87f92e73
using PlutoUI; TableOfContents()

# ╔═╡ 6ba80e6f-7212-4b75-b82e-2a221be0b759
begin
	using OrdinaryDiffEq
	using CairoMakie
	using DataFrames
	using DataFramesMeta: @subset, @select, @byrow
	using IntervalArithmetic: in_interval
	using IntervalArithmetic.Symbols: ±
	using CoordinateTransformations: AffineMap
	using LinearAlgebra: svd
end

# ╔═╡ fab2b4f5-a38f-44c4-bff3-dc7acde60ee5
using DynamicalSystems

# ╔═╡ 10d38676-4e22-4b73-8218-929dd939fa9d
md"# Rossler System"

# ╔═╡ d7a8d1cb-029e-4bb2-998f-2d9d07b16911
function rossler!(du, u, p, t)
    a, b, c = p.a, p.b, p.c

    du[1] = -u[2] - u[3]
    du[2] = u[1] + a * u[2]
    du[3] = b + u[3] * (u[1] - c)
end

# ╔═╡ 6b15d229-be8b-4d93-9df0-b6f84165c480
function sol_rossler(u0, p; kwargs...)
    tspan = (0.0, 1000.0)
    prob = ODEProblem(rossler!, u0, tspan, p)
    sol = solve(prob, Tsit5(); kwargs...)

    return sol
end

# ╔═╡ 14f82e77-1580-4c19-9c23-4c7561b94468
begin
	p = (a=0.1, b=0.1, c=14) # Standard parameters for Rossler System
	u0 = [1.0, 0.0, 0.0]
	Δt = 1e-2 # Timestep for solving the differential equation
end

# ╔═╡ bac2a14d-884f-4dd2-a4ba-51d65d2e9a53
sol = sol_rossler(u0, p, saveat=Δt);

# ╔═╡ 66346450-c0e2-479a-8599-13ed7a43eb77
lines(sol, idxs=(1,2,3), axis=(type=Axis3,))

# ╔═╡ 4b8059df-9658-4d15-9a97-fb3f4fc90a29
soln = rename(DataFrame(sol), [:t, :x, :y, :z])

# ╔═╡ d5434602-5a1d-4212-8390-2199f2379329
md"# Delay Embedding"

# ╔═╡ 80252e75-a97c-4798-a021-c94a1947df18
τ = 100 # Delay (in time step units)

# ╔═╡ 4b313b2f-ac68-4667-93b4-18d3491e6df4
h(x) = x .+ 1e-6 * randn(length(x)) # The measurement function with some added noise

# ╔═╡ 0bfef40c-4130-4378-b351-b54de1b5aa39
begin
	v = empty(similar(soln))
	for (t,n1,n2,n3) in zip(sol.t, h(sol[1, :]), h(sol[1, 1+τ:end]), h(sol[1, 1+2τ:end]))
		push!(v, (t,n1,n2,n3))
	end
end

# ╔═╡ 84d54fbb-9987-48b5-9e6c-b03cb61fa906
v

# ╔═╡ 7648c9b5-8b28-4787-a197-56932ecd977b
md"Delay embedded Rossler Attractor by taking $h(x) = x + noise$"

# ╔═╡ 19386b8e-fc59-4295-b3e2-67248a47001f
md"# Lyapunov Comparision"

# ╔═╡ 714da486-18b2-46db-b9dc-e2b6073e52f2
function get_points_arr(df::DataFrame)
	begin
		arr = []
		for i in eachrow(@select df Not(:t))
			push!(arr, Point3f(collect(i)))
		end
	end

	return arr
end

# ╔═╡ a6a2a01d-51bb-4f8c-9a1c-cd0eb55fe524
lines(get_points_arr(v), axis=(type=Axis3, elevation=pi/2, azimuth=0))

# ╔═╡ a0f412f5-0a6e-426a-b95a-c85d263df3f5
function lyapunov(traj::DataFrame, initial::@NamedTuple{x::Int64, y::Int64}; kwargs...)
	steps = 600 # at Δt = 0.01
	traj_points = get_points_arr(traj)

	patch = @subset traj @byrow begin
		in_interval.(:x, initial.x ± 0.5)
		in_interval.(:y, initial.y ± 0.5)
	end

	patch_arr = get_points_arr(patch)

	evolved_patch = @subset traj @byrow :t in @. patch.t + steps * Δt
	evolved_patch_arr = get_points_arr(evolved_patch)

	fig = Figure()
	ax = Axis3(fig[1,1]; kwargs...)
	lines!(ax, traj_points, alpha=0.5)
	scatter!(ax, patch_arr, color=:red, markersize=3)
	scatter!(ax, evolved_patch_arr, color=:orange, markersize=3)

	transformation = AffineMap(patch_arr => evolved_patch_arr).linear
	λ = log(maximum(svd(transformation).S)) / (steps * Δt)

	return fig, λ
end

# ╔═╡ 118b19a0-89ba-4c19-a967-5ea8de3f32d1
begin
	l1 = lyapunov(soln, (x=-10, y=-10); azimuth=0,  elevation=pi/2);
	l2 = lyapunov(v, (x=-14, y=-10); azimuth=0,  elevation=pi/4);
end;

# ╔═╡ 21fae30c-e594-4eff-97bc-fb16f939ca59
md"The red region represents the initial set points and the orange region represents the final set of points after evolving through 600 time steps. The Lyapunov explonent can be obtained by finding the largest eigenvalue of SVD of the transformation matrix between the initial and final state."

# ╔═╡ 3805614c-0d8f-4c56-85ee-c6c26aff5bbc
l1[1]

# ╔═╡ aede9268-6161-4387-8e35-55f708cbb855
println("Lyapunov exponent of the original system: $(l1[2])")

# ╔═╡ 571c55a9-6d3a-4019-9f78-a0fd89e2fa40
l2[1]

# ╔═╡ 7fc31b5f-15d9-44b7-bdd6-9f49f4efd1b4
println("Lyapunov exponent of the delay embedded system: $(l2[2])")

# ╔═╡ 580d82ae-feca-4a2f-a90b-2eca55628406
md"As we can see, the error is just $(round(abs(l1[2] - l2[2])*100/l1[2], digits=3))%"

# ╔═╡ 16fdb525-e8ef-4f75-ab41-78f4fce07b4d
md"> Citations are given in the [term paper](https://github.com/Vortriz/IDC402/blob/main/term-paper.pdf) itself"

# ╔═╡ dd814df1-5913-43f8-8eb6-a1cedf09d8bf
md"# Appendix"

# ╔═╡ 99a902b4-e78a-4a96-b7fd-220ba8d964ab
begin
	total_time = 100
	Ttr = 10
	diffeq = (; alg = Vern9())
	rossler_sys = CoupledODEs(rossler!, u0, p; diffeq)
end

# ╔═╡ 650416d3-6b00-4dc3-af23-eb82c4008ed0
DynamicalSystems.lyapunov(rossler_sys, total_time; Ttr, Δt)

# ╔═╡ Cell order:
# ╟─1a8a95c2-26cd-4c74-8cc5-b46a160da1b8
# ╟─4d997074-1f5e-4763-970a-202c87f92e73
# ╟─10d38676-4e22-4b73-8218-929dd939fa9d
# ╠═6ba80e6f-7212-4b75-b82e-2a221be0b759
# ╠═d7a8d1cb-029e-4bb2-998f-2d9d07b16911
# ╠═6b15d229-be8b-4d93-9df0-b6f84165c480
# ╠═14f82e77-1580-4c19-9c23-4c7561b94468
# ╠═bac2a14d-884f-4dd2-a4ba-51d65d2e9a53
# ╠═66346450-c0e2-479a-8599-13ed7a43eb77
# ╠═4b8059df-9658-4d15-9a97-fb3f4fc90a29
# ╟─d5434602-5a1d-4212-8390-2199f2379329
# ╠═80252e75-a97c-4798-a021-c94a1947df18
# ╠═4b313b2f-ac68-4667-93b4-18d3491e6df4
# ╠═0bfef40c-4130-4378-b351-b54de1b5aa39
# ╠═84d54fbb-9987-48b5-9e6c-b03cb61fa906
# ╟─7648c9b5-8b28-4787-a197-56932ecd977b
# ╠═a6a2a01d-51bb-4f8c-9a1c-cd0eb55fe524
# ╟─19386b8e-fc59-4295-b3e2-67248a47001f
# ╠═714da486-18b2-46db-b9dc-e2b6073e52f2
# ╠═a0f412f5-0a6e-426a-b95a-c85d263df3f5
# ╠═118b19a0-89ba-4c19-a967-5ea8de3f32d1
# ╟─21fae30c-e594-4eff-97bc-fb16f939ca59
# ╠═3805614c-0d8f-4c56-85ee-c6c26aff5bbc
# ╠═aede9268-6161-4387-8e35-55f708cbb855
# ╠═571c55a9-6d3a-4019-9f78-a0fd89e2fa40
# ╠═7fc31b5f-15d9-44b7-bdd6-9f49f4efd1b4
# ╟─580d82ae-feca-4a2f-a90b-2eca55628406
# ╟─16fdb525-e8ef-4f75-ab41-78f4fce07b4d
# ╟─dd814df1-5913-43f8-8eb6-a1cedf09d8bf
# ╠═fab2b4f5-a38f-44c4-bff3-dc7acde60ee5
# ╠═99a902b4-e78a-4a96-b7fd-220ba8d964ab
# ╠═650416d3-6b00-4dc3-af23-eb82c4008ed0
