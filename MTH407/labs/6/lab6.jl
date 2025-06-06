### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# ╔═╡ 78fb4c86-9b3e-4f16-b4aa-232ba390cf20
begin
	using Random
	using PlutoUI
end

# ╔═╡ 2772971b-0ec8-41f2-a6f1-1d28d25a06dd
html"""
<style>
	pluto-output {
		font-size: 15px !important;
	}

	pluto-input .cm-editor .cm-content, pluto-input .cm-editor .cm-scroller {
		font-size: 15px;
	}
</style>
"""

# ╔═╡ fc38b587-7506-4e10-82cd-e39c1f581a37
md"# Assignment 6 - Max-heaps and Priority Queues"

# ╔═╡ 17d65250-b9da-4dbe-93a2-28169d3f6e63
PlutoUI.TableOfContents(include_definitions=true)

# ╔═╡ ea7de471-efb2-4cfd-8821-5a49146507e0
md"Some useful functions:"

# ╔═╡ 9c78d3b3-b7ab-48f2-aab5-9e52275bee60
parent(p::Int) = floor(Int, p/2)

# ╔═╡ 6e210230-2384-45f8-9d57-5895b302b58e
children(p::Int) = 2p, 2p+1

# ╔═╡ faa5cb92-90d2-4c9b-aa5d-956bf0b40241
md"## Max-Heaps"

# ╔═╡ 2cf4f2f4-32f5-4323-8ca3-668c957893d1
Heap = Vector{Int}

# ╔═╡ a144442e-f0be-4d41-8c4e-ad1cfa9b32f9
h::Heap = rand(1:20, 8)

# ╔═╡ c0918466-b99a-46fb-b7cb-852406c6022b
md"- First we construct a max-heap out of an unsorted array using `heapify`"

# ╔═╡ 22c6a0bb-e72a-409a-8988-5ba7383e4cf0
h

# ╔═╡ 351babec-10b3-49da-a8a4-5ce64b43d42f
md"- Then we fix broken heap using `siftup` and `siftdown`"

# ╔═╡ 90030027-a48d-4a95-8638-c50a9b0d71a8
function siftup!(t::Heap, p::Int)
	γ = parent(p)
	
	if γ ≥ 1 && t[γ] < t[p]
		t[γ], t[p] = t[p], t[γ]
		
		return siftup!(t, γ)
	end
end

# ╔═╡ 09bebb72-076c-4ecb-9876-955dfd89d795
Base.push!(h, 16) # Breaking at heap at a leaf node

# ╔═╡ 43f02b28-a41c-4fca-bb46-099e653871c5
h

# ╔═╡ f070081b-748a-4389-a169-08fe92500d00
function siftdown!(t::Heap, p::Int)
	n = length(t)
	q = copy(p)
	λ, ρ = children(p)

	if λ ≤ n && t[λ] > t[q]
		q = λ
	end

	if ρ ≤ n && t[ρ] > t[q]
		q = ρ
	end

	if p != q
		t[p], t[q] = t[q], t[p]

		return siftdown!(t, q)
	end
end

# ╔═╡ fe4166d4-a5a9-4adb-9722-fafa511f6f5b
Base.insert!(h, 1, 3)

# ╔═╡ 3f233016-4b99-4212-9014-c393d97c2364
md"- Now we implement `push` method for the heap to adds an element to the last of the heap and fixes it"

# ╔═╡ 8186813d-7dae-442f-b23b-bf865cf97101
h

# ╔═╡ a404ae8d-ff8d-493a-9053-0b64dc274868
h

# ╔═╡ b3633594-a4ad-47ce-b97f-7c6d04514d80
md"- `change` method will overwrite element at position `p` with value `b`"

# ╔═╡ 4076b528-e0a2-4dd8-a7dd-7324dff3a7be
h

# ╔═╡ 1d2f96ef-7ab9-4556-86bd-533051827803
h

# ╔═╡ 052caae7-1451-478c-a1b1-b74e0df0f682
md"# Priority Queue"

# ╔═╡ 1feb92be-9705-425f-b88a-abaa5800fa63
md"Some useful functions:"

# ╔═╡ 9b427b4f-00f4-4e02-85eb-da70b4f0a1b9
function _check_priority(priority)
	if priority < 1
		error("$priority is invalid priority! Should be more than 0.")
	end
end

# ╔═╡ ddddbc3b-89ea-4cb6-9121-904f21b8c913
md"We define a `QueueElement` as tuple containing `object` of type `String` and `priority` of type `Int`"

# ╔═╡ c6b7a317-7aeb-498b-9d6a-99102f34577c
struct QueueElement
	object::String
	priority::Int
end

# ╔═╡ 022a28f6-b80b-45e5-a6ee-7d9dbff43c4e
md"and a `PriorityQueue` as a `Vector` of `QueueElement`s"

# ╔═╡ 97c3ca06-5d8f-4446-bf33-c3aa12f1a7dc
PriorityQueue = Vector{QueueElement}

# ╔═╡ 157bad3b-8f07-4324-b529-36db8188fd51
function _check_isunique(pq::PriorityQueue, obj)
	if obj in [elem.object for elem in pq]
		error("'$obj' already exists in the priority queue!")
	end
end

# ╔═╡ 9f2d6ecb-7620-45c0-8f5f-9a6e477884df
function _check_objexists(pq::PriorityQueue, obj)
	if !(obj in [elem.object for elem in pq])
		error("'$obj' does not exist in the priority queue!")
	end
end

# ╔═╡ c9d080ab-044f-4ba2-b09f-5cb3ae2b57f6
pq::PriorityQueue = []

# ╔═╡ cf85a0bc-2e54-48df-afe2-d6b33656fb18
for _ in 1:8
	Base.push!(pq, QueueElement(randstring(3), rand(1:9)))
end

# ╔═╡ 8459b45d-738e-4b7b-a1b0-b97115add8ec
pq

# ╔═╡ bb7c4a45-a3d8-41a3-9930-75d63a6fd312
function siftup!(pq::PriorityQueue, p)
	γ = parent(p)
	
	if γ ≥ 1 && pq[γ].priority ≤ pq[p].priority
		pq[γ], pq[p] = pq[p], pq[γ]
		
		return siftup!(pq, γ)
	end
end

# ╔═╡ 8faf20a0-f6d8-4618-bb6c-178dbb065f5f
siftup!(h, 9)

# ╔═╡ 5d34ad2f-1027-4894-a3bd-3ffb2196da22
function push!(t::Heap, a::Int)
	Base.push!(t, a)
	n = length(t)

	siftup!(t, n)
end

# ╔═╡ 66ef1606-756b-47f2-88b0-049f9da04844
push!(h, 9)

# ╔═╡ 8125bd1e-c695-40c0-b60f-7cee201c89a6
function insert!(pq::PriorityQueue, elem::QueueElement)
	_check_isunique(pq, elem.object)
	_check_priority(elem.priority)
		
	Base.push!(pq, elem)
	n = length(pq)

	siftup!(pq, n)
end

# ╔═╡ 7f9d3b59-1710-42f1-983d-0f244be4e638
insert!(pq, QueueElement(randstring(3), rand(1:9)))

# ╔═╡ 4024f14b-06ea-4889-8c7e-80f56fee02ac
pq

# ╔═╡ 6d0f446a-c6b0-4a16-a5eb-0cce75b4a0d4
function enqueue!(pq::PriorityQueue, obj::String)
	_check_isunique(pq, obj)
	priority_last = pq[end].priority

	if priority_last == 1
		issued_priority = 1
	else
		issued_priority = priority_last - 1
	end
	
	insert!(pq, QueueElement(obj, issued_priority))
end

# ╔═╡ a2ebe816-caf9-40e0-8cc6-94dd9d602849
enqueue!(pq, "neww")

# ╔═╡ b11e21ce-60b0-44c6-b867-72c2b642ff7a
pq

# ╔═╡ 82ed3303-423c-46ea-b2ce-903ecbd7f630
function maximum(pq::PriorityQueue)
	return pq[1].object
end

# ╔═╡ 2d6d0cd1-2a27-4978-96e4-5e0ad5be097f
maximum(pq)

# ╔═╡ e66125ff-c32a-469f-b687-00a0abf2dd66
function siftdown!(pq::PriorityQueue, p)
	n = length(pq)
	q = copy(p)
	λ, ρ = children(p)

	if λ ≤ n && pq[λ].priority ≥ pq[q].priority
		q = λ
	end

	if ρ ≤ n && pq[ρ].priority ≥ pq[q].priority
		q = ρ
	end

	if p != q
		pq[p], pq[q] = pq[q], pq[p]

		return siftdown!(pq, q)
	end
end

# ╔═╡ 86e430cb-8421-4f85-a267-bda69b15826d
function heapify!(t::Heap)
	n = length(t)

	for i in parent(n):-1:1
		siftdown!(t, i)
	end
end

# ╔═╡ 7bda0d18-0407-4422-aa63-2022b3ee9a2a
heapify!(h)

# ╔═╡ 5b3249be-5669-4a48-9afc-e4b8c3977281
siftdown!(h, 1)

# ╔═╡ cef900bd-01c4-45dd-9af3-409123e7a9d4
function pop!(t::Heap)
	a = t[1]
	t[1] = t[end]
	Base.pop!(t)
	siftdown!(t, 1)

	return a
end

# ╔═╡ 56e51849-75d5-489c-a49b-63e248dab005
pop!(h)

# ╔═╡ b636be4d-9772-441f-96fc-cb5d02396605
function change!(t::Heap, p::Int, b::Int)
	a = t[p]
	t[p] = b

	if t[p] > a
		siftup!(t, p)
	else
		siftdown!(t, p)
	end
end

# ╔═╡ 97fb0fe6-71dd-4fb8-a952-9a912c6ea66a
function extract!(t::Heap, p::Int)
	n = length(t)
	a = t[p]
	t[p] = t[end]
	Base.pop!(t)

	if p == n
		return a
	end

	if t[p] > a
		siftup!(t, p)
	else
		siftdown!(t, p)
	end

	return a
end

# ╔═╡ fe3dfa3e-9d71-4e4b-aa67-cd4731b8466c
function extract!(pq::PriorityQueue)
	a = pq[1]
	pq[1] = pq[end]
	Base.pop!(pq)
	siftdown!(pq, 1)

	return a.object
end

# ╔═╡ 5e0d01d7-648e-4a5b-beda-2ae208e64595
extract!(h, 8)

# ╔═╡ 7a3d54de-4e34-48f6-b4ce-6a4013f62d84
extract!(pq)

# ╔═╡ 816abd55-f594-4b0b-83fb-fcbab3d90284
pq

# ╔═╡ 59d1c3a2-7721-4014-91aa-e89524cc0c5a
function change!(pq::PriorityQueue, obj::String, new_priority::Int)
	_check_objexists(pq, obj)
	_check_priority(new_priority)

	p = findfirst(x -> x.object == obj, pq)
	old_priority = pq[p].priority
	pq[p] = QueueElement(obj, new_priority)

	γ = parent(p)
	λ, ρ = children(p)
	n = length(pq)

	if γ ≥ 1 && new_priority > pq[γ].priority
		siftup!(pq, p)
	elseif (λ ≤ n && new_priority < pq[λ].priority) || (ρ ≤ n && new_priority < max(pq[λ].priority, pq[ρ].priority))
		siftdown!(pq, p)
	end
end

# ╔═╡ 96d08a98-47b7-4aca-ba1e-0996b7527183
change!(h, 8, 9)

# ╔═╡ 2d3f2982-d6a9-4eb6-9a71-c42abe543e93
change!(pq, "neww", 10)

# ╔═╡ 966af75d-9476-4b1c-a629-2f6ace9540b7
pq

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
PlutoUI = "~0.7.61"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.4"
manifest_format = "2.0"
project_hash = "b22d814036dee2e4f4bf496ad4df6a54a233298a"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "7e71a55b87222942f0f9337be62e26b1f103d3e4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.61"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "cbbebadbcc76c5ca1cc4b4f3b0614b3e603b5000"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─fc38b587-7506-4e10-82cd-e39c1f581a37
# ╟─2772971b-0ec8-41f2-a6f1-1d28d25a06dd
# ╟─17d65250-b9da-4dbe-93a2-28169d3f6e63
# ╟─78fb4c86-9b3e-4f16-b4aa-232ba390cf20
# ╟─ea7de471-efb2-4cfd-8821-5a49146507e0
# ╟─9c78d3b3-b7ab-48f2-aab5-9e52275bee60
# ╟─6e210230-2384-45f8-9d57-5895b302b58e
# ╟─faa5cb92-90d2-4c9b-aa5d-956bf0b40241
# ╠═2cf4f2f4-32f5-4323-8ca3-668c957893d1
# ╠═a144442e-f0be-4d41-8c4e-ad1cfa9b32f9
# ╟─c0918466-b99a-46fb-b7cb-852406c6022b
# ╠═86e430cb-8421-4f85-a267-bda69b15826d
# ╠═7bda0d18-0407-4422-aa63-2022b3ee9a2a
# ╠═22c6a0bb-e72a-409a-8988-5ba7383e4cf0
# ╟─351babec-10b3-49da-a8a4-5ce64b43d42f
# ╠═90030027-a48d-4a95-8638-c50a9b0d71a8
# ╠═09bebb72-076c-4ecb-9876-955dfd89d795
# ╠═8faf20a0-f6d8-4618-bb6c-178dbb065f5f
# ╠═43f02b28-a41c-4fca-bb46-099e653871c5
# ╠═f070081b-748a-4389-a169-08fe92500d00
# ╠═fe4166d4-a5a9-4adb-9722-fafa511f6f5b
# ╠═5b3249be-5669-4a48-9afc-e4b8c3977281
# ╟─3f233016-4b99-4212-9014-c393d97c2364
# ╠═5d34ad2f-1027-4894-a3bd-3ffb2196da22
# ╠═66ef1606-756b-47f2-88b0-049f9da04844
# ╠═8186813d-7dae-442f-b23b-bf865cf97101
# ╠═cef900bd-01c4-45dd-9af3-409123e7a9d4
# ╠═56e51849-75d5-489c-a49b-63e248dab005
# ╠═a404ae8d-ff8d-493a-9053-0b64dc274868
# ╟─b3633594-a4ad-47ce-b97f-7c6d04514d80
# ╠═b636be4d-9772-441f-96fc-cb5d02396605
# ╠═96d08a98-47b7-4aca-ba1e-0996b7527183
# ╠═4076b528-e0a2-4dd8-a7dd-7324dff3a7be
# ╠═97fb0fe6-71dd-4fb8-a952-9a912c6ea66a
# ╠═5e0d01d7-648e-4a5b-beda-2ae208e64595
# ╠═1d2f96ef-7ab9-4556-86bd-533051827803
# ╟─052caae7-1451-478c-a1b1-b74e0df0f682
# ╟─1feb92be-9705-425f-b88a-abaa5800fa63
# ╟─157bad3b-8f07-4324-b529-36db8188fd51
# ╟─9f2d6ecb-7620-45c0-8f5f-9a6e477884df
# ╟─9b427b4f-00f4-4e02-85eb-da70b4f0a1b9
# ╟─ddddbc3b-89ea-4cb6-9121-904f21b8c913
# ╠═c6b7a317-7aeb-498b-9d6a-99102f34577c
# ╟─022a28f6-b80b-45e5-a6ee-7d9dbff43c4e
# ╠═97c3ca06-5d8f-4446-bf33-c3aa12f1a7dc
# ╠═c9d080ab-044f-4ba2-b09f-5cb3ae2b57f6
# ╠═cf85a0bc-2e54-48df-afe2-d6b33656fb18
# ╠═8459b45d-738e-4b7b-a1b0-b97115add8ec
# ╠═bb7c4a45-a3d8-41a3-9930-75d63a6fd312
# ╠═8125bd1e-c695-40c0-b60f-7cee201c89a6
# ╠═7f9d3b59-1710-42f1-983d-0f244be4e638
# ╠═4024f14b-06ea-4889-8c7e-80f56fee02ac
# ╠═6d0f446a-c6b0-4a16-a5eb-0cce75b4a0d4
# ╠═a2ebe816-caf9-40e0-8cc6-94dd9d602849
# ╠═b11e21ce-60b0-44c6-b867-72c2b642ff7a
# ╠═82ed3303-423c-46ea-b2ce-903ecbd7f630
# ╠═2d6d0cd1-2a27-4978-96e4-5e0ad5be097f
# ╠═e66125ff-c32a-469f-b687-00a0abf2dd66
# ╠═fe3dfa3e-9d71-4e4b-aa67-cd4731b8466c
# ╠═7a3d54de-4e34-48f6-b4ce-6a4013f62d84
# ╠═816abd55-f594-4b0b-83fb-fcbab3d90284
# ╠═59d1c3a2-7721-4014-91aa-e89524cc0c5a
# ╠═2d3f2982-d6a9-4eb6-9a71-c42abe543e93
# ╠═966af75d-9476-4b1c-a629-2f6ace9540b7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
