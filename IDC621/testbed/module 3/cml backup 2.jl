### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ d35ed268-e755-464f-92db-f1100b08fe3d
using PlutoUI; PlutoUI.TableOfContents(include_definitions=false)

# ╔═╡ 3157bc2d-5679-49ff-9836-51590da938b9
begin
	using Plots
	using PlutoPlotly
	using Random
	using ImageFiltering
	using LaTeXStrings
end

# ╔═╡ 3d81bf64-09e4-4b07-9e19-bcb75fec1d19
html"""
<h1> <center> Term Paper 3 </center> </h1>
"""

# ╔═╡ 0e05be53-c382-45f5-bc8f-8f75abb76bb8
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 1400px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""

# ╔═╡ 6fb83f35-f64a-4e38-bd75-ac37ee8cadab
md"""
This is a submission for Modelling Complex Systems (IDC621) for the year 2024-25 Monsoon Semester by Rishi Vora (MS21113).
"""

# ╔═╡ 3a2ba3d9-24c1-48b7-8637-8c2945f11a6c
md"""
Here we look at different 1D maps, their Bifurcation diagrams and Lyapunov exponents. Then we implement these maps for Coupled Map Lattices (CML) with various types of couplings and analyize the different types of spatiotemporal chaos exhibited by these CMLs.
"""

# ╔═╡ e3252705-821d-4386-9137-080573268f20
md"""
First, we import some packages that we will be needing along the way and do some plotting config
"""

# ╔═╡ 9ca3221d-21c4-4bcb-bfd7-0802c6f50ead
config = PlotConfig(
    toImageButtonOptions=attr(
        format="png",
        filename="custom_image",
        height=1500,
        width=2100,
        scale=1
    ).fields
);

# ╔═╡ 2f68e18d-912e-49d2-a197-626243828055
md"""
# 1D Non-linear Maps
"""

# ╔═╡ 17fc6cca-8692-4216-bb52-21ea553a0042
md"""
## Logistic map
"""

# ╔═╡ e1024d43-52f2-4ee1-afa4-05ea915bb201
function LM(params, x)
	r = params.r
	
	return @. r * x * (1 - x)
end

# ╔═╡ 6cf52866-43d9-4526-b590-0af1805d77c7
function LM_diff(params, x)
	r = params.r

	return @. r * (1 - 2x)
end

# ╔═╡ b03e33e5-8c57-4f59-a679-0312e96ba875
function EvolveLM(params; x₀=0.5, steps=50)
	evo = [x₀]
	
	for n in 1:steps
		push!(evo, LM(params, evo[n]))
	end

	return evo
end

# ╔═╡ 3bc40e3d-3e41-47a4-aa6a-b8456dacc729
function Plot_Bif_Lyp(map, map_diff, params)
	steps = 1000
	evo = [fill(1e-5, length(params[1]))]
	lyapunov = []
	
	for i in 1:steps
		push!(lyapunov, map_diff(params, last(evo)))
		push!(evo, map(params, last(evo)))
	end

	lyapunov = stack(lyapunov, dims=1)

	λ = (1/steps) * vec(reduce(+, log.(abs.(lyapunov[begin:end-1, :])), dims=1))

	p_bif = PlutoPlotly.plot(
		[PlutoPlotly.scattergl(
			x=collect(params[1]),
			y=evo[i],
			mode="markers",
			marker=attr(size=0.1, color=:black),
			hoverinfo="none",)
		for i in 901:1000],
		config=config,
		Layout(
			xaxis_title="parameter",
			yaxis_title="x*",
			showlegend=false
		)
	)

	p_lyp = PlutoPlotly.plot(
		[
			PlutoPlotly.scattergl(
				x=collect(params[1])[λ .>= 0],
				y=λ[λ .>= 0],
				mode="markers",
				marker=attr(size=1, color=:red),
				hoverinfo="none",),
			PlutoPlotly.scattergl(
				x=collect(params[1])[λ .< 0],
				y=λ[λ .< 0],
				mode="markers",
				marker=attr(size=1, color=:black),
				hoverinfo="none"),
		],
		config=config,
		Layout(
			xaxis_title="parameter",
			yaxis_title="λ",
			showlegend=false
		)
	)

	return p_bif, p_lyp
end

# ╔═╡ 964a974a-bf1a-4b3d-a8c8-a76213d2c67f
md"""
First we see how the state evolves for varying `r`
"""

# ╔═╡ 60696284-2de9-416c-b7e8-c18a75bbd67f
# ╠═╡ show_logs = false
begin
	anim = @animate for r in 0.5:0.1:4
		params = (r = r,)
		Plots.plot(EvolveLM(params), marker=true, ylims=(0,1), xlabel="t", ylabel="x", legend=false)
	end

	gif(anim, fps=2)
end

# ╔═╡ c3837212-678e-4194-92e0-93acde3e055e
md"""
### Bifurcation Diagram
"""

# ╔═╡ d0694c51-923f-43be-9cca-695f1e82d937
begin
	bif_LM, lyp_LM = Plot_Bif_Lyp(LM, LM_diff, (r = range(start=2.8, stop=4, length=10000),))
end;

# ╔═╡ 7467accd-960c-46b3-bd9f-6ae49bff5e67
md"""
The Bifurcation diagram for logistic map is shown below
"""

# ╔═╡ 3063a04d-9804-4a40-9f52-25fb498e790e
bif_LM

# ╔═╡ 7a0c6b04-f1bc-4790-af55-0d8cd47df3b8
md"""
### Lyapunov Exponent
"""

# ╔═╡ a444ec38-0ce8-46bf-8c35-75c7a6784d24
md"""
And here is the Lyapunov exponent of logistic map for varying `r`. Points in red show chaotic regions ($\lambda > 0$)
"""

# ╔═╡ 99de15e7-4350-45d6-82bf-a1e30848658a
lyp_LM

# ╔═╡ 539a5976-d05e-4a76-b09e-1a62652af149
md"""
## $1 - ax^2$ map
"""

# ╔═╡ c97cc7d1-451e-4588-b3e8-f72af6c25d8d
function f(params, x)
	a = params.a
	
	return @. 1 - a * x^2
end

# ╔═╡ d12b8972-071a-4877-b60f-f7410a8d16f2
function f_diff(params, x)
	a = params.a
	
	return @. -2a * x
end

# ╔═╡ 37fff115-073e-4fa7-b716-7d4b6ca04e40
md"""
### Bifurcation Diagram
"""

# ╔═╡ 57b3e497-614e-4580-a3cc-dad6a3f6b9e1
begin
	bif_f, lyp_f = Plot_Bif_Lyp(f, f_diff, (a = range(start=0, stop=2, length=10000),))
end;

# ╔═╡ 9dfb0fed-1e88-490f-aa32-0c806feb719d
md"""
The Bifurcation diagram for $1-ax^2$ is shown below
"""

# ╔═╡ d7e392d2-d4a8-4ad1-926c-006dd964d543
bif_f

# ╔═╡ 22d9fd37-3537-487c-8ea7-022ccb8a6b73
md"""
### Lyapunov Exponent
"""

# ╔═╡ cdc3b0f2-9b1f-490c-a753-c179b414e521
md"""
And here is the Lyapunov exponent of $1-ax^2$ for varying `a`. Points in red show chaotic regions ($\lambda > 0$)
"""

# ╔═╡ 2f413af4-8ce9-49f7-a402-dd07854044a0
lyp_f

# ╔═╡ 486a3862-8748-4a26-970b-845b20d3e322
md"""
# CML
"""

# ╔═╡ 46f4ebee-8768-4296-a74f-44d8580a94a7
md"""
Now we look at various couplings using these maps
"""

# ╔═╡ 0176fe6f-52b6-4ec3-b6a8-363126185ebd
md"""
## Canonical CML
"""

# ╔═╡ 208d0ab0-38bd-4488-ab54-038252595460
function CanonicalCML(ϵ, f, params, X)
	return (1 - ϵ) * f(params, X) +
			(ϵ/2) * (f(params, circshift(X, -1)) + f(params, circshift(X, 1)))
end

# ╔═╡ 17feef16-55cf-46a1-b764-f34c5189b9ae
function EvolveCanonicalCML(ϵ, f, params; N=100, T=100)
	evo = [rand(Float64, N)]

	for t in 1:T
		push!(evo, CanonicalCML(ϵ, f, params, evo[t]))
	end

	return evo
end

# ╔═╡ ecb4b90a-fc85-4938-a8ab-16b996224263
function PlotEvolution(CML; title="", color=:deep)
	Plots.heatmap(reduce(hcat, CML)', xlabel="sites", ylabel="t", xlims=(0, length(CML[1])), ylims=(1, length(CML)), c=color, title=title, size=(800,600))
end

# ╔═╡ 404d34db-430a-47f1-a1be-47c14f13f7d9
md"""
The canonical CML equation is given by

$$x_{n+1}(i) = (1 - \epsilon) f(x_{n} (i)) + \frac{\epsilon}{2}[f(x_{n} (i+1)) + f(x_{n} (i-1))]$$
"""

# ╔═╡ eab24856-1873-4fda-b0a9-8e96f365c1b9
md"""
### With logistic map
"""

# ╔═╡ 80ee5579-b8fe-409f-98a5-b3011d0e0b63
begin
	ϵ_LM = 0.5
	params_LM = (r = 3.4,)
end;

# ╔═╡ 2494e14d-8023-43ed-bab8-a74c65554e9d
PlotEvolution(EvolveCanonicalCML(ϵ_LM, LM, params_LM; N=100, T=100), title="ϵ=$ϵ_LM, r=$(params_LM.r)")

# ╔═╡ 1da8af15-0c89-4ded-a757-a236ce0e7855
md"""
### With $1 - ax^2$ map
"""

# ╔═╡ 79ae67d7-2251-448a-a52b-1e45b073ad8f
begin
	ϵ_f = 0.1
	params_f = (a = 1.5,)
end;

# ╔═╡ aa716ba7-93ab-4bc4-ac82-b4e58d519097
PlotEvolution(EvolveCanonicalCML(ϵ_f, f, params_f; N=100, T=100), title="ϵ=$ϵ_f, a=$(params_f.a)")

# ╔═╡ 7152e417-9b6e-4229-973a-6607c2a687d7
md"""
## Periodic CML with circular map
"""

# ╔═╡ c7d1bf4c-3431-4fbc-b6da-d51309c55e1f
function CM(params, Θ)
	ω = params.ω
	k = params.k
	
	return @. Θ + ω - (k/2π) * sin(2π*Θ)
end

# ╔═╡ 81b53605-3a91-45dd-aa68-bc9734131890
function PeriodicCML(ϵ, f, params, Θ)
	return mod.(
			(1 - ϵ) * f(params, Θ) +
				(ϵ/2) * (f(params, circshift(Θ, -1)) + f(params, circshift(Θ, 1)))
		, 1)
end

# ╔═╡ a4ec2342-d759-4f9a-99c1-dade31bd4c2f
function EvolvePeriodicCML(ϵ, f, params; N=100, T=100)
	evo = [rand(Float64, N)]

	for t in 1:T
		push!(evo, PeriodicCML(ϵ, f, params, evo[t]))
	end

	return evo
end

# ╔═╡ 8dca2d00-972b-40fd-b5c8-dbff8a9e6b68
md"""
The circular map is given by

$$f(\Theta) = \Theta + \omega - \frac{k}{2 \pi} \sin(2 \pi \Theta)$$

and the periodic CML equation is given by

$$\Theta_{n+1}(i) = (1 - \epsilon) f(\Theta_{n} (i)) + \frac{\epsilon}{2}[f(\Theta_{n} (i+1)) + f(\Theta_{n} (i-1))] \mod 1$$
"""

# ╔═╡ 687091e5-2984-403c-936d-6a6f886b9a46
begin
	ϵ_CM = 1
	params_CM = (ω = 0.505, k = 6.53)
end;

# ╔═╡ 8305a784-cd50-4926-a461-6a99f4eb4d78
PlotEvolution(EvolvePeriodicCML(ϵ_CM, CM, params_CM; N=100, T=200); title="ϵ=$ϵ_CM, ω=$(params_CM.ω), k=$(params_CM.k)", color=:vikO)

# ╔═╡ 4418d96d-ccd7-47e5-8032-810698276d6c
md"""
# Spatiotemporal Chaos
"""

# ╔═╡ 6aa08c0d-fd6d-4b6b-9ba8-73b297c39ef3
md"""
I have tried to classify various observed patterns to the best of my knowledge
"""

# ╔═╡ c98f92fd-7f34-49a6-a4c2-8d897b08a311
md"""
## Chaotic Brownian Motion of Defect

Used canonical CML with $1 - ax^2$ map
"""

# ╔═╡ 27d3dd18-0445-4220-a520-2b0e0f39e24b
let ϵ = 0.1, params = (a = 1.85,)
	PlotEvolution(EvolveCanonicalCML(ϵ, f, params; N=100, T=100), title="ϵ=$ϵ, $params")
end

# ╔═╡ 673218be-50f3-4555-83d6-026cef6201fc
md"""
## Frozen random patterns

Used canonical CML with $1 - ax^2$ map
"""

# ╔═╡ 5d64bf63-0df1-440a-9783-222f14bc20e1
PlotEvolution(EvolveCanonicalCML(ϵ_f, f, params_f; N=100, T=100), title="ϵ=$ϵ_f, a=$(params_f.a)")

# ╔═╡ 974ca6ba-1d95-4776-a602-74953fe7fa8e
md"""
## Pattern selection with suppression of chaos

Used canonical CML with $1 - ax^2$
"""

# ╔═╡ 91bf0447-700f-4aa5-a5b6-847193db83e4
let ϵ = 0.5, params = (a = 1.67,)
	PlotEvolution(EvolveCanonicalCML(ϵ, f, params; N=100, T=1000), title="ϵ=$ϵ, $params")
end

# ╔═╡ b1108e9d-47db-46f1-9139-8e21cc6863b6
md"""
## Chimera States

Used canonical CML with $1 - ax^2$
"""

# ╔═╡ de8ef17d-e9a9-48e1-95de-0041ba236554
let ϵ = 1.0007, params = (a = 0.95,)
	PlotEvolution(EvolveCanonicalCML(ϵ, f, params; N=100, T=300), title="ϵ=$ϵ, $params")
end

# ╔═╡ f6ef4f09-08d9-4b2d-8ca2-9b9c73a7a8ef
md"""
## Travelling Wave

Used canonical CML with $1 - ax^2$
"""

# ╔═╡ cc9ff0e4-c323-4754-b8e5-cfc476e8f51b
let ϵ = 0.5, params = (a = 1.67,)
	PlotEvolution(EvolveCanonicalCML(ϵ, f, params; N=100, T=50000), title="ϵ=$ϵ, $params")
end

# ╔═╡ f9bf3561-0f8a-4f0f-a1f0-665fea6509da
md"""
## Unclassified

Could not classify the following pattern
"""

# ╔═╡ 4360d9bc-5f7a-459a-b8b9-ab0c6372031d
md"""
Used periodic CML with circular map
"""

# ╔═╡ b2801ff1-da51-4696-af5c-38e018b111e6
let ϵ = 1, params = (ω = 0.51, k = 6.53)
	PlotEvolution(EvolvePeriodicCML(ϵ, CM, params; N=100, T=100), title="ϵ=$ϵ, $params")
end

# ╔═╡ 877a575c-a827-47fa-860b-ca5e7fa2293f


# ╔═╡ dd9b0ad2-f891-44e3-81f4-db280e29a432
md"""
# Simulation of Boling
"""

# ╔═╡ 8e5d3f88-79e3-40d9-b9cc-a4d2e5b14def
md"""
I attempted to simluate the model given in [^Yanagita]'s paper. For certain parameters, it can show the production of bubbles in boiling liquid, but due to lack to information on  those parameters, it did not produce bubbles. But still, it can demonstrate thermal diffusion in an exvironment where top and bottom temperatures are fixed
"""

# ╔═╡ fce042e3-ad0d-494c-8ed1-25061c4673f9
md"""
The non-linear map used is `tanh(x)`
"""

# ╔═╡ a64aaf0e-4839-4325-9bb5-e04a70c9d104
md"""
We have a lattice $T^t$ containing temperature of the medium. The CML evolves as follows:

$$T'_{x,y} = T_{x,y}^{t} + (\epsilon / 4) \{ T_{x+1,y}^{t} + T_{x,y+1}^{t} + T_{x-1,y}^{t} + T_{x,y-1}^{t} - 4 T_{x,y}^{t} \}$$

$$T_{x,y}^{\prime\prime}=T_{x,y}^{\prime}-(\sigma/2)T_{x,y}^{\prime}\{\rho(T_{x,y+1}^{\prime})-\rho(T_{x,y-1}^{\prime})\},$$

$$\begin{align}
 \mathrm{if}\quad T_{x,y}^{\prime\prime}>T_{c}\quad\mathrm{and}\quad T_{x,y}^{t}<T_{c}\quad\mathrm{then}\quad T_{n(x,y)}^{t+1}=T_{n(x,y)}^{\prime\prime}-\eta,\\
\mathrm{if}\quad T_{x,y}^{\prime\prime}<T_{c}\quad\mathrm{and}\quad T_{x,y}^{t}>T_{c}\quad\mathrm{then}\quad T_{n(x,y)}^{t+1}=T_{n(x,y)}^{\prime\prime}+\eta,
\end{align}$$
"""

# ╔═╡ c367fd1f-8a63-41e3-a49e-4c89cb810e3e
ρ(params, T) = @. tanh(params.α * (T - params.Tc))

# ╔═╡ 4d57806c-dc92-46f3-9a2b-5a42c7455b57
function Boiling(params, T, T_top, T_bottom)
	ϵ = params.ϵ
	σ = params.σ
	η = params.η
	Tc = params.Tc
	params_ρ = (α = params.α, Tc = params.Tc)
	n, m = size(T)
	
	neighbors = [(0,1), (1,0), (0,-1), (-1,0)]
	kernel = centered([0 1 0; 1 0 1; 0 1 0])

	T₁ = T + (ϵ/4) * (
		circshift(T, (0,1)) + circshift(T, (0,-1)) +
		[T; fill(T_bottom, (1, m))][begin+1:end, :] +
		[fill(T_top, (1, m)); T][begin:end-1, :]
		- 4T
	)

	# T_temp = [fill(T_top, (1, m)); T; fill(T_bottom, (1, m))]
	# T₁ = T + (ϵ/4) * (
	# 	sum([circshift(T_temp, (x,y)) for (x,y) in neighbors])[begin+1:end-1, :]
	# 	- 4T
	# )
	
	T₂ = T₁ - (σ/2) * T₁ * (ρ(params_ρ, [fill(T_top, (1, m)); T₁][begin+1:end, :]) - ρ(params_ρ, [fill(T_top, (1, m)); T₁][begin+1:end, :]))
	
	# T_temp = [fill(T_top, (1, m)); T₁; fill(T_bottom, (1, m))]
	# T₂ = T₁ - (σ/2) * T₁ * (ρ(params_ρ, circshift(T_temp, (1,0))) - ρ(params_ρ, circshift(T_temp, (-1,0))))[begin+1:end-1, :]

	Tf = T₂ + η * imfilter(padarray(padarray((@. T₂ < Tc && T > Tc) - (@. T₂ > Tc && T < Tc), Fill(0,(1,0))), Pad(:circular,0,1)), kernel)[begin+1:end-1, begin+1:end-1]

	return Tf
end

# ╔═╡ b3bc5f85-da1f-442f-ab00-b0d7d80e34de
begin
	params_boiling = (ϵ = 0.8, α = 2.5, σ = 0.1, η = 0.1, Tc = 10)
	T_top = 0
	T_bottom = 9.85
	T = fill((T_top + T_bottom)/2, (64,64)) + (rand(Float64, (64,64)) * 2 .- 1)
end;

# ╔═╡ 2f406d19-a319-4914-a2a6-806791685f26
begin
	b = Plots.heatmap(c=:thermal, clims=(0,10))
	anim_boiling = @animate for t in 1:200
		T = Boiling(params_boiling, T, T_top, T_bottom)
		heatmap!(T)
	end
end;

# ╔═╡ 4bc35fae-ad54-4017-88c2-f543cb479d1a
# ╠═╡ show_logs = false
gif(anim_boiling, fps=20)

# ╔═╡ 303cfadb-0e3f-4ba5-a464-6887c385c679
md"""
# References
[^Yanagita]: Tatsuo Yanagita. Phenomenology of boiling: A coupled map lattice model. Chaos An Interdisciplinary Journal of Nonlinear Science. 1992;2(3):343-350. [doi:https://doi.org/10.1063/1.165877](doi:https://doi.org/10.1063/1.165877)
"""

# ╔═╡ Cell order:
# ╟─3d81bf64-09e4-4b07-9e19-bcb75fec1d19
# ╟─d35ed268-e755-464f-92db-f1100b08fe3d
# ╟─0e05be53-c382-45f5-bc8f-8f75abb76bb8
# ╟─6fb83f35-f64a-4e38-bd75-ac37ee8cadab
# ╟─3a2ba3d9-24c1-48b7-8637-8c2945f11a6c
# ╟─e3252705-821d-4386-9137-080573268f20
# ╠═3157bc2d-5679-49ff-9836-51590da938b9
# ╠═9ca3221d-21c4-4bcb-bfd7-0802c6f50ead
# ╟─2f68e18d-912e-49d2-a197-626243828055
# ╟─17fc6cca-8692-4216-bb52-21ea553a0042
# ╠═e1024d43-52f2-4ee1-afa4-05ea915bb201
# ╠═6cf52866-43d9-4526-b590-0af1805d77c7
# ╠═b03e33e5-8c57-4f59-a679-0312e96ba875
# ╠═3bc40e3d-3e41-47a4-aa6a-b8456dacc729
# ╟─964a974a-bf1a-4b3d-a8c8-a76213d2c67f
# ╠═60696284-2de9-416c-b7e8-c18a75bbd67f
# ╟─c3837212-678e-4194-92e0-93acde3e055e
# ╠═d0694c51-923f-43be-9cca-695f1e82d937
# ╟─7467accd-960c-46b3-bd9f-6ae49bff5e67
# ╠═3063a04d-9804-4a40-9f52-25fb498e790e
# ╟─7a0c6b04-f1bc-4790-af55-0d8cd47df3b8
# ╟─a444ec38-0ce8-46bf-8c35-75c7a6784d24
# ╠═99de15e7-4350-45d6-82bf-a1e30848658a
# ╟─539a5976-d05e-4a76-b09e-1a62652af149
# ╠═c97cc7d1-451e-4588-b3e8-f72af6c25d8d
# ╠═d12b8972-071a-4877-b60f-f7410a8d16f2
# ╟─37fff115-073e-4fa7-b716-7d4b6ca04e40
# ╠═57b3e497-614e-4580-a3cc-dad6a3f6b9e1
# ╟─9dfb0fed-1e88-490f-aa32-0c806feb719d
# ╠═d7e392d2-d4a8-4ad1-926c-006dd964d543
# ╟─22d9fd37-3537-487c-8ea7-022ccb8a6b73
# ╟─cdc3b0f2-9b1f-490c-a753-c179b414e521
# ╠═2f413af4-8ce9-49f7-a402-dd07854044a0
# ╟─486a3862-8748-4a26-970b-845b20d3e322
# ╟─46f4ebee-8768-4296-a74f-44d8580a94a7
# ╟─0176fe6f-52b6-4ec3-b6a8-363126185ebd
# ╠═208d0ab0-38bd-4488-ab54-038252595460
# ╠═17feef16-55cf-46a1-b764-f34c5189b9ae
# ╠═ecb4b90a-fc85-4938-a8ab-16b996224263
# ╟─404d34db-430a-47f1-a1be-47c14f13f7d9
# ╟─eab24856-1873-4fda-b0a9-8e96f365c1b9
# ╠═80ee5579-b8fe-409f-98a5-b3011d0e0b63
# ╠═2494e14d-8023-43ed-bab8-a74c65554e9d
# ╟─1da8af15-0c89-4ded-a757-a236ce0e7855
# ╠═79ae67d7-2251-448a-a52b-1e45b073ad8f
# ╠═aa716ba7-93ab-4bc4-ac82-b4e58d519097
# ╟─7152e417-9b6e-4229-973a-6607c2a687d7
# ╠═c7d1bf4c-3431-4fbc-b6da-d51309c55e1f
# ╠═81b53605-3a91-45dd-aa68-bc9734131890
# ╠═a4ec2342-d759-4f9a-99c1-dade31bd4c2f
# ╟─8dca2d00-972b-40fd-b5c8-dbff8a9e6b68
# ╠═687091e5-2984-403c-936d-6a6f886b9a46
# ╠═8305a784-cd50-4926-a461-6a99f4eb4d78
# ╟─4418d96d-ccd7-47e5-8032-810698276d6c
# ╟─6aa08c0d-fd6d-4b6b-9ba8-73b297c39ef3
# ╟─c98f92fd-7f34-49a6-a4c2-8d897b08a311
# ╠═27d3dd18-0445-4220-a520-2b0e0f39e24b
# ╟─673218be-50f3-4555-83d6-026cef6201fc
# ╠═5d64bf63-0df1-440a-9783-222f14bc20e1
# ╟─974ca6ba-1d95-4776-a602-74953fe7fa8e
# ╠═91bf0447-700f-4aa5-a5b6-847193db83e4
# ╟─b1108e9d-47db-46f1-9139-8e21cc6863b6
# ╠═de8ef17d-e9a9-48e1-95de-0041ba236554
# ╟─f6ef4f09-08d9-4b2d-8ca2-9b9c73a7a8ef
# ╠═cc9ff0e4-c323-4754-b8e5-cfc476e8f51b
# ╟─f9bf3561-0f8a-4f0f-a1f0-665fea6509da
# ╟─4360d9bc-5f7a-459a-b8b9-ab0c6372031d
# ╠═b2801ff1-da51-4696-af5c-38e018b111e6
# ╠═877a575c-a827-47fa-860b-ca5e7fa2293f
# ╟─dd9b0ad2-f891-44e3-81f4-db280e29a432
# ╟─8e5d3f88-79e3-40d9-b9cc-a4d2e5b14def
# ╟─fce042e3-ad0d-494c-8ed1-25061c4673f9
# ╟─a64aaf0e-4839-4325-9bb5-e04a70c9d104
# ╠═c367fd1f-8a63-41e3-a49e-4c89cb810e3e
# ╠═4d57806c-dc92-46f3-9a2b-5a42c7455b57
# ╠═b3bc5f85-da1f-442f-ab00-b0d7d80e34de
# ╠═2f406d19-a319-4914-a2a6-806791685f26
# ╠═4bc35fae-ad54-4017-88c2-f543cb479d1a
# ╟─303cfadb-0e3f-4ba5-a464-6887c385c679
