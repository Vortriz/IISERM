### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 8745bf94-4e4f-448f-8224-644c833fdf36
# ╠═╡ show_logs = false
begin
    import Pkg

    # activate the shared project environment
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
end

# ╔═╡ 2b8f8d12-d2c9-4fcb-964d-56eda0b97876
using PlutoUI; PlutoUI.TableOfContents(include_definitions=false)

# ╔═╡ e5f1e0d0-b093-11ef-1d30-1db3a6b3937d
begin
	using Graphs
	using GraphPlot
	using Random; Random.seed!(1234)
	using Plots; gr()
	using PlutoPlotly
	using ColorSchemes
	using LaTeXStrings
	using OrdinaryDiffEq
	using StatsBase
	using DataFrames
	using CSV
	using ProgressLogging
	using Karnak
end;

# ╔═╡ d733e9bd-df71-4da2-ab09-84d15ce1c87c
html"""
<h1> <center> Term Paper 4 </center> </h1>
"""

# ╔═╡ 3117e441-bad7-4180-a61f-66509a870e18
md"""
This is a submission for Modelling Complex Systems (IDC621) for the year 2024-25 Monsoon Semester by Rishi Vora (MS21113).
"""

# ╔═╡ 651075cb-739a-4130-b690-89736e65a12a
md"""
Here we look at some basic networks, their properties, and how we can use them along with a Kuramoto-like dynamical system to study people's changing opinions!
"""

# ╔═╡ cabadd5b-1740-4a32-9c2a-52ddd946bbd9
md"""
First, we import some packages that we will be needing along the way.
"""

# ╔═╡ 13256ca2-98af-4140-ac79-6dedc9a12a07
md"""
# Networks
"""

# ╔═╡ d7314068-0d20-4869-b7d8-1dfa67e067c7
function DrawGraph(g; circular=false, directed=false)
	layout = circular ? shell : stress 
	ec = directed ? 5 : 0
	
	@drawsvg begin
	    background("black")
	    sethue("white")
	    drawgraph(g, layout=layout, vertexlabels=1:nv(g), edgecurvature=ec)
	end
end

# ╔═╡ a9dc0e6d-6178-4a6b-b80a-f8cd7f2abed9
md"""
## Erdős–Rényi graph
"""

# ╔═╡ 1699e822-128e-4ade-bdce-b06d7f5b1b8f
md"""
It's a random graph with low average path length and low clustering.
"""

# ╔═╡ 53cc3fae-568d-46dc-be05-d7ab46bc05bb
function ErdosRenyi(n, p)	
	g = SimpleGraph(n)
	
	for i in 1:n
	    for j in i+1:n
	        if rand() < p
	            add_edge!(g, i, j)
	        end
	    end
	end

	return g
end

# ╔═╡ 394b82a4-43f1-4915-ad2a-0708ffd04c5b
DrawGraph(ErdosRenyi(50, 0.2); circular=false)

# ╔═╡ 928322f3-fd8a-45a0-a886-25661ae5d0f1
md"""
## Ring graph
"""

# ╔═╡ f2e0e572-3e88-48b3-8c95-f3d7d11fe3fd
md"""
On the other hand, a ring lattice has high average path length and high clustering.
"""

# ╔═╡ 944b428f-b843-4b7f-8040-e9990cacaa5a
function create_ring_lattice(n, k)
    g = SimpleGraph(n)
	
    for i in 1:n
        for j in 1:(k ÷ 2)
            add_edge!(g, i, mod1(i + j, n))
            add_edge!(g, i, mod1(i - j, n))
        end
    end
    return g
end

# ╔═╡ 05004457-b8fc-4079-a410-770c1a076c8f
DrawGraph(create_ring_lattice(10, 4); circular=true)

# ╔═╡ 8809232c-9ead-4325-8e27-0782eac56049
md"""
## Small World graph
"""

# ╔═╡ 86490c00-bd1d-48ef-a7fd-5ad5e7d96b3c
md"""
Real world networks tend to have low average path length but high clustering. To achieve this, we use Watts and Strogatz's approach to create a small world network.
"""

# ╔═╡ e3c9eb98-9402-44a9-a925-465911bc7445
function rewire_edges!(g, n, k, p)
    for i in 1:n
        for j in 1:(k ÷ 2)
            if rand() < p
                rem_edge!(g, i, mod1(i + j, n))
                new_neighbor = rand(setdiff(1:n, neighbors(g, i) ∪ [i]))
                add_edge!(g, i, new_neighbor)
            end
        end
    end
end

# ╔═╡ 763270fa-4949-4afe-9430-66de82202376
function SmallWorld(n, k, p)
	g = create_ring_lattice(n, k)
    rewire_edges!(g, n, k, p)

	return g
end

# ╔═╡ 4b7bb235-9b09-4739-986f-8d70b27e99cc
DrawGraph(SmallWorld(100, 8, 0.01))

# ╔═╡ 1415ed34-7251-4517-b70d-70b9d55e0722
md"""
### Analysis
"""

# ╔═╡ c0826837-08f7-48d9-adaa-bb5cd9fad24d
function L(g)
    dists = floyd_warshall_shortest_paths(g).dists
	
    return mean(filter(!isinf, dists))
end

# ╔═╡ a3a0d35c-8935-4e28-b98c-368c1b40bd7a
function C(g)
    return mean(local_clustering_coefficient(g, v) for v in vertices(g))
end

# ╔═╡ 20b15b8f-9bbe-4cae-9256-b2b5115a5435
md"""
Upon analyzing how the average path length and clustering change for different rewiring probability, we see that there is small range of `p` where the average path length is low and the clustering is high. This is ideal for small world networks.
"""

# ╔═╡ ead4b719-048a-404d-9bf2-dd29e164cf3f
begin
	n = 1800
	k = 4
	ps = logrange(0.0001, 1, 12)
	
	g0 = create_ring_lattice(n, k)
	L0 = L(g0)
	C0 = C(g0)
	
	Lps = []
	Cps = []
	
	for p in ps
		g = SmallWorld(n, k, p)
	    push!(Lps, L(g))
	    push!(Cps, C(g))
	end
	
	Lps_normalized = Lps ./ L0
	Cps_normalized = Cps ./ C0
	
	Plots.scatter(ps, Lps_normalized, label="L(p)/L(0)", xlabel="p", ylabel="Normalized L and C", xscale=:log10, legend=:topright)
	Plots.scatter!(ps, Cps_normalized, label="C(p)/C(0)")
end

# ╔═╡ eb63178d-9899-41e2-82cc-437658d53ebb
md"""
# Public opinion dynamics
"""

# ╔═╡ 1f856f24-1c6a-4b62-b32a-b99549cf4279
md"""
Now we will use these networks to see how the people holding exteme opinion can be influenced by their surroundings.
"""

# ╔═╡ 21e0d2cf-bbcd-4489-b486-898e227bb120
md"""
Particularly, here we consider the aspect of how opinion formation may invest multiple topics and the presence of correlations between opinion on these topics may affect the consensus of the population as a whole.
"""

# ╔═╡ 9f571a99-8e34-407b-aa81-4783fdf490d5
md"""
This model and the mean-field approach is based on the Social Compass model [^SC].
"""

# ╔═╡ c76b6b70-a2ef-468e-b43d-c98a3a778ee8
md"""
We start by defining a representation of opinions in polar space. Let us consider $N$ individuals, each agent $i$ holding opinions $(x_i, y_i)$ toward two distinct topics $X$ and $Y$, respectively, that are assumed to be normalized in the interval $x_i, y_i \in [−1,1]$. The combined opinion of each individual with respect to the two topics can be represented in polar coordinates by its conviction $\rho_i = \sqrt{x_i^2 + y_i^2}$ and its orientation $\varphi_i = \arctan⁡(y_i/x_i)$, with $\varphi_i \in [-\pi, \pi]$.
"""

# ╔═╡ 4ee1277b-4d9f-48cd-9416-4c32c8b17941
md"""
For instance, two agents $i$ and $j$ holding extreme and opposite opinions, $x_i = y_i = 1$, $x_j = y_j = -1$, will be represented in the polar plane with the same, maximum conviction $\rho_i = \rho_j = \sqrt{2}$ and opposite orientations $\varphi_i = \pi/4$ and $\varphi_j = -3\pi/4$. 
"""

# ╔═╡ 0570844f-11ee-492a-acd9-bca3b362dbde
md"""
For each individual $i$, we focus on the time evolution of their orientation, represented by $\theta_i (t)$, provided their initial orientation $\theta_i (0) = \varphi_i$ and that their conviction $\rho_i$ will not change over time. We rely on only two key assumptions: (i) agents exert a certain degree of social influence on their peers and (ii) each agent $i$ has a tendency to maintain their initial opinion $\varphi_i$ proportional to their conviction $\rho_i$ (i.e., agents with high conviction are more stubborn). We operationalize this simple theoretical framework in the following set of $n$ ordinary differential equations

$$\dot{\theta}_i(t)=\rho_i\sin[\varphi_i-\theta_i(t)]+\frac\lambda n\sum_{j=1}^n\sin[\theta_j(t)-\theta_i(t)]$$
"""

# ╔═╡ b771c495-16ff-4d78-9cd8-b6261ca39003
function Social!(dθ, θ, p, t)
	ρ = p.ρ
	φ = p.φ
	λ = p.λ
	A = p.A

	@. dθ = ρ * sin(φ - θ) + (λ / $replace($vec($sum(A, dims=1)), 0 => Inf)) * $vec($sum(A * sin(θ - θ'), dims=1))
end

# ╔═╡ 4d7b5942-919a-4d61-9da4-87420210e081
function SolSocial(ρ, φ, λ, A, θ₀, t, step_size)
	tspan = (0.0, Float64(t))
	p = (ρ = ρ, φ = φ, λ = λ, A = A)
	
	prob = ODEProblem(Social!, θ₀, tspan, p)
	sol = solve(prob, RK4(), saveat=step_size)
	
	return sol
end

# ╔═╡ e6f6194d-eefb-4438-928d-fcd08b2f3075
function GetPhaseData(sol, iter)
	θs = sol[iter]
	centroid = mean(exp.(im * θs)) |> (c -> (angle(c), abs(c)))

	return θs, centroid
end

# ╔═╡ 429ef3bf-dde3-4a42-8923-8820b61cf50f
function PlotOrderParameter(data, g)
	evR_ρ = data.ρ
	evR_φ = data.φ
	evR_A = adjacency_matrix(g)
	evR_θ₀ = data.φ
	evR_t = 20
	evR_step_size = 0.1

	r_inf = []

	evR_λ = range(start=0, stop=12, step=0.1)

	@progress for λ in evR_λ
		coherences = []
		evR_social_sol = SolSocial(evR_ρ, evR_φ, λ, evR_A, evR_θ₀, evR_t, evR_step_size)

		for t in 1:length(evR_social_sol)
			phases, centroid = GetPhaseData(evR_social_sol, t)
			push!(coherences, centroid[2])
		end
		
		push!(r_inf, mean(coherences[length(coherences)÷2+1:end]))
	end
	
	Plots.plot(evR_λ, r_inf, marker=(:circle,3), xlabel=L"\lambda", ylabel=L"r_\infty", label="")

	λc = evR_λ[argmax(abs.(diff(r_inf)))]
	vline!([λc], label=L"\lambda_{c}")
end

# ╔═╡ 952da8e1-6d1b-4356-8fbd-009b28395a9c
md"""
Obtaining some useful data. (I can not share this data as is, due to ANES T&C. Although, it is easily obtainable on [ANES website](https://electionstudies.org/).)
"""

# ╔═╡ e08c69d1-5b7d-4ac0-a719-83a670925506
df = CSV.read("anes_timeseries_2016_rawdata.csv", DataFrame);

# ╔═╡ a036b785-fd43-428e-9e00-bca264da5133
begin
	polarizing_data = DataFrame(name=String[], id=String[], min=Int[], max=Int[])

	push!(polarizing_data, ("religion", "V161242", 1, 3))
	push!(polarizing_data, ("same_sex", "V161227x", 1, 6))
	push!(polarizing_data, ("obamacare", "V161114x", 1, 7))
	push!(polarizing_data, ("transgender", "V161228x", 1, 6))
	push!(polarizing_data, ("birthright", "V161194x", 1, 7))
	push!(polarizing_data, ("fight_isis", "V161213x", 1, 7))
	push!(polarizing_data, ("mexican_wall", "V161196x", 1, 1))
	push!(polarizing_data, ("climate_change", "161225x", 1, 7))

	pairs = [("religion", "same_sex"),
		("transgender", "religion"),
		("transgender", "same_sex"),
		("obamacare", "transgender"),
		("obamacare", "same_sex")]
	
	lin_map(x, min, max) = 2 * (x - min)/(max - min) - 1
	
	paired_data = []
	
	for (name1, name2) in pairs
	    id1 = polarizing_data[polarizing_data.name .== name1, :id][1]
	    id2 = polarizing_data[polarizing_data.name .== name2, :id][1]
	    min1 = polarizing_data[polarizing_data.name .== name1, :min][1]
	    max1 = polarizing_data[polarizing_data.name .== name1, :max][1]
	    min2 = polarizing_data[polarizing_data.name .== name2, :min][1]
	    max2 = polarizing_data[polarizing_data.name .== name2, :max][1]
	
	    new_df = filter(row -> row[id1] > 0 && row[id2] > 0, df[:, [id1, id2]])
	    
	    new_df[!, id1] = lin_map.(new_df[!, id1], min1, max1)
	    new_df[!, id2] = lin_map.(new_df[!, id2], min2, max2)
	
		x = new_df[!, id1]
		y = new_df[!, id2]
		@. new_df.ρ = sqrt(x^2 + y^2)
		@. new_df.φ = atan(x,y)

	    rename!(new_df, Dict(id1 => name1, id2 => name2))
		push!(paired_data, new_df)
	end
end

# ╔═╡ 3279bd34-8de4-4c18-844e-9ce3f889da49
md"""
The tags represent the following survey questions:

1. `religion`: Does religion provide you guidance in day-to-day living? 1 some, 2 quite a bit, 3 a great deal. ANES ID: V161242.
2. `same_sex`: Do you think business owners who provide wedding-related services should be allowed to refuse services to same-sex couples if same-sex marriage violates their religious beliefs? agree (1 strongly, 2 moderately, 3 a little), disagree (4 a little, 5 moderately, 6 strongly). ANES ID: V161227x.
3. `obamacare`: What do you think about 2010 health care law? favor (1 a great deal, 2 moderately, 3 a little), 4 neutral, oppose (5 a little, 6 moderately, 7 a great deal). ANES ID: V161114x.
4. `transgender`: Should transgender people have to use the bathrooms of the gender they were born as? agree (1 strongly, 2 moderately, 3 a little), disagree (4 a little, 5 moderately, 6 strongly). ANES ID: V161228x.
5. `birthright`: Should the U.S. Constitution be changed so that the children of unauthorized immigrants do not automatically get citizenship if they are born in this country? favor (1 a great deal, 2 moderately, 3 a little), 4 neutral, oppose (5 a little, 6 moderately, 7 a great deal). ANES ID: V161194x.
6. `fight_isis`: Should U.S. send ground troops to fight Islamic militants, such as ISIS, in Iraq and Syria? favor (1 a great deal, 2 moderately, 3 a little), 4 neutral, oppose (5 a little, 6 moderately, 7 a great deal). ANES ID: V161213x.
7. `mexican_wall`: What do you think about building a wall on the U.S. border with Mexico? favor (1 a great deal, 2 moderately, 3 a little), 4 neutral, oppose (5 a little, 6 moderately, 7 a great deal). ANES ID: V161196x.
8. `climate_change`: Is the federal government doing the right amount about rising temperatures? should be more (1 a great deal, 2 moderately, 3 a little), 4 right amount, should be less (5 a little, 6 moderately, 7 a great deal). ANES ID: V161225x
"""

# ╔═╡ c75b02ca-b92d-448c-a7ec-0f442db0ddf3
md"""
Pairs like `religion` and `same_sex` are highly polarized and correlated topics (as we can see in the below bimodal histogram). We can test if they undergo depolarization under various social networks.
"""

# ╔═╡ d3812cff-0d55-4230-aefa-642060e6a222
PlutoPlotly.plot(
    barpolar(
		theta=first(paired_data[3].φ, 700),
        marker_line_color="black",
        opacity=0.8,
		thetaunit = "radians",
    )
)

# ╔═╡ 9355f210-94f8-4eb3-a886-35393b145892
md"""
## Very small world
"""

# ╔═╡ b97951db-ff8e-45cb-bfbb-f35e1b1f4dd3
md"""
First we look at how the public opinion evolves when everyone is affected by everyone. This scenario is most likely in a small group of people. So it is wise to assume a mean field approach here.
"""

# ╔═╡ 9b4f95bf-ecc1-4c68-8d4d-cbdda689bb68
DrawGraph(complete_graph(10); circular=true)

# ╔═╡ 635660e4-7680-47aa-a148-2fd3236884a4
# ╠═╡ show_logs = false
let n = 10, data = first(paired_data[3], n), g_vsw = complete_graph(n)
	PlotOrderParameter(data, g_vsw)
end

# ╔═╡ e2ca8b3b-e365-4eb0-9c0a-e81365278e5c
md"""
## Restricted very small world
"""

# ╔═╡ 33ea2d13-ce4b-43ac-bc06-010ba3af0f8a
md"""
Although a highly unlikely scenario for real world, it is informative to see that a similarly sized ring lattice depolarizes slowly as compared to a fully connected network.
"""

# ╔═╡ ce4d0ef7-b05a-410d-9267-a96169b24741
DrawGraph(create_ring_lattice(10, 2))

# ╔═╡ 68cb6f1f-2090-4056-b166-16d9ebc27bfc
# ╠═╡ show_logs = false
let n = 10, data = first(paired_data[3], n), g_rvsw = create_ring_lattice(n, 2)
	PlotOrderParameter(data, g_rvsw)
end

# ╔═╡ 4f1baf7e-f33b-4386-82d0-09f7a0f357be
md"""
## Small World
"""

# ╔═╡ 73a56120-9004-462a-84ec-e8774d8e2b61
md"""
This is more representative of a real world social network.
"""

# ╔═╡ c5c23fb3-d523-4bff-a6ac-4513f72ff9d0
DrawGraph(SmallWorld(100, 8, 0.01))

# ╔═╡ 4b425d7d-1623-4d1a-b5ea-ba6f230b3203
md"""
As we can see, it shows rather interesting dynamics, as it fluctuates due to those random links and takes some time to settle down.
"""

# ╔═╡ 806fee10-d332-43cd-ac4e-c2aa44e5b2dd
# ╠═╡ show_logs = false
let n = 200, data = first(paired_data[3], n), g_sw = SmallWorld(n, 8, 0.01)
	PlotOrderParameter(data, g_sw)
end

# ╔═╡ 2def9ec1-7a48-4a49-b010-38f0ac509405
md"""
## Scale free network
"""

# ╔═╡ 5ce9ba9b-54a8-479c-9cd3-fd3915b2363f
md"""
We also look at scale-free network, which may depict online networks more acculately.
"""

# ╔═╡ 1d8508ef-7925-4e7c-aaf6-f723ca7c2adb
g_sf = reverse(barabasi_albert(50, 3, is_directed=true, seed=12))

# ╔═╡ aadfe648-5431-42ea-ba34-24992f6d8379
DrawGraph(g_sf)

# ╔═╡ 75f077ff-fecc-476d-a584-19472f5be870
md"""
As seen, due to high influence of some agents, the network stabilize quite quickly.
"""

# ╔═╡ 300a6637-cad9-413d-a728-07bdf1c5c4f8
# ╠═╡ show_logs = false
let n = 200, data = first(paired_data[3], n), g_sf = reverse(barabasi_albert(n, 3, is_directed=true, seed=12))
	PlotOrderParameter(data, g_sf)
end

# ╔═╡ 8fd9f295-31b3-458b-8846-05add886bda7
md"""
# Future Scope

A lot of tweaks can be made to this model such as:
- More interconncted topics can be used.
- Better representation of real world by considering more agents (nodes) and better networks.
- Using weighted and directed networks to show influence of popular agents (politicians, social media infulencers etc).
"""

# ╔═╡ e71c0ce6-5e8f-4144-a008-ae776f5c7072
md"""
# References
[^SC]: Ojer J, Starnini M, Pastor-Satorras R. Modeling Explosive Opinion Depolarization in Interdependent Topics. Physical Review Letters. 2023;130(20). doi:[https://doi.org/10.1103/physrevlett.130.207401](https://doi.org/10.1103/physrevlett.130.207401)
"""

# ╔═╡ Cell order:
# ╟─d733e9bd-df71-4da2-ab09-84d15ce1c87c
# ╟─3117e441-bad7-4180-a61f-66509a870e18
# ╟─8745bf94-4e4f-448f-8224-644c833fdf36
# ╟─2b8f8d12-d2c9-4fcb-964d-56eda0b97876
# ╟─651075cb-739a-4130-b690-89736e65a12a
# ╟─cabadd5b-1740-4a32-9c2a-52ddd946bbd9
# ╠═e5f1e0d0-b093-11ef-1d30-1db3a6b3937d
# ╟─13256ca2-98af-4140-ac79-6dedc9a12a07
# ╠═d7314068-0d20-4869-b7d8-1dfa67e067c7
# ╟─a9dc0e6d-6178-4a6b-b80a-f8cd7f2abed9
# ╟─1699e822-128e-4ade-bdce-b06d7f5b1b8f
# ╠═53cc3fae-568d-46dc-be05-d7ab46bc05bb
# ╠═394b82a4-43f1-4915-ad2a-0708ffd04c5b
# ╟─928322f3-fd8a-45a0-a886-25661ae5d0f1
# ╟─f2e0e572-3e88-48b3-8c95-f3d7d11fe3fd
# ╠═944b428f-b843-4b7f-8040-e9990cacaa5a
# ╠═05004457-b8fc-4079-a410-770c1a076c8f
# ╟─8809232c-9ead-4325-8e27-0782eac56049
# ╟─86490c00-bd1d-48ef-a7fd-5ad5e7d96b3c
# ╠═e3c9eb98-9402-44a9-a925-465911bc7445
# ╠═763270fa-4949-4afe-9430-66de82202376
# ╠═4b7bb235-9b09-4739-986f-8d70b27e99cc
# ╟─1415ed34-7251-4517-b70d-70b9d55e0722
# ╠═c0826837-08f7-48d9-adaa-bb5cd9fad24d
# ╠═a3a0d35c-8935-4e28-b98c-368c1b40bd7a
# ╟─20b15b8f-9bbe-4cae-9256-b2b5115a5435
# ╠═ead4b719-048a-404d-9bf2-dd29e164cf3f
# ╟─eb63178d-9899-41e2-82cc-437658d53ebb
# ╟─1f856f24-1c6a-4b62-b32a-b99549cf4279
# ╟─21e0d2cf-bbcd-4489-b486-898e227bb120
# ╟─9f571a99-8e34-407b-aa81-4783fdf490d5
# ╟─c76b6b70-a2ef-468e-b43d-c98a3a778ee8
# ╟─4ee1277b-4d9f-48cd-9416-4c32c8b17941
# ╟─0570844f-11ee-492a-acd9-bca3b362dbde
# ╠═b771c495-16ff-4d78-9cd8-b6261ca39003
# ╠═4d7b5942-919a-4d61-9da4-87420210e081
# ╠═e6f6194d-eefb-4438-928d-fcd08b2f3075
# ╠═429ef3bf-dde3-4a42-8923-8820b61cf50f
# ╟─952da8e1-6d1b-4356-8fbd-009b28395a9c
# ╠═e08c69d1-5b7d-4ac0-a719-83a670925506
# ╠═a036b785-fd43-428e-9e00-bca264da5133
# ╟─3279bd34-8de4-4c18-844e-9ce3f889da49
# ╟─c75b02ca-b92d-448c-a7ec-0f442db0ddf3
# ╠═d3812cff-0d55-4230-aefa-642060e6a222
# ╟─9355f210-94f8-4eb3-a886-35393b145892
# ╟─b97951db-ff8e-45cb-bfbb-f35e1b1f4dd3
# ╠═9b4f95bf-ecc1-4c68-8d4d-cbdda689bb68
# ╠═635660e4-7680-47aa-a148-2fd3236884a4
# ╟─e2ca8b3b-e365-4eb0-9c0a-e81365278e5c
# ╟─33ea2d13-ce4b-43ac-bc06-010ba3af0f8a
# ╠═ce4d0ef7-b05a-410d-9267-a96169b24741
# ╠═68cb6f1f-2090-4056-b166-16d9ebc27bfc
# ╟─4f1baf7e-f33b-4386-82d0-09f7a0f357be
# ╟─73a56120-9004-462a-84ec-e8774d8e2b61
# ╠═c5c23fb3-d523-4bff-a6ac-4513f72ff9d0
# ╟─4b425d7d-1623-4d1a-b5ea-ba6f230b3203
# ╠═806fee10-d332-43cd-ac4e-c2aa44e5b2dd
# ╟─2def9ec1-7a48-4a49-b010-38f0ac509405
# ╟─5ce9ba9b-54a8-479c-9cd3-fd3915b2363f
# ╠═1d8508ef-7925-4e7c-aaf6-f723ca7c2adb
# ╠═aadfe648-5431-42ea-ba34-24992f6d8379
# ╟─75f077ff-fecc-476d-a584-19472f5be870
# ╠═300a6637-cad9-413d-a728-07bdf1c5c4f8
# ╟─8fd9f295-31b3-458b-8846-05add886bda7
# ╟─e71c0ce6-5e8f-4144-a008-ae776f5c7072
