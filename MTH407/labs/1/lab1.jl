### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ f6327ba5-5c09-4db1-93b6-5e41226d0963
using BenchmarkTools

# ╔═╡ bb759148-2e51-4fde-aaed-0af7acc26bc4
base = 10

# ╔═╡ ef065b90-cf49-11ef-268d-b941dc928ae6
begin
	count_add_2 = 0
	
	function add_mac(a, b)
		c = a + b
		global count_add_2 += 1
	
		return (c % base, c ÷ base)
	end
end

# ╔═╡ 04e544f1-ab3d-4250-93fe-769f3d2a5c23
function mul_mac(a, b)
	c = a * b

	return (c % base, c ÷ base)
end

# ╔═╡ 0e4f6b62-f1b2-4c5b-ac1c-331f37b2c7d5
function add1(a, b, c; count_add)
	r₁, c₁ = add_mac(a[1], b[1])
	r₂, c₂ = add_mac(r₁, c)
	r₃, c₃ = add_mac(c₁, c₂)

	count_add += 3

	if length(b) == 1
		return r₂, r₃, count_add
	end
	
	return append!([r₂], add1(a[2:end], b[2:end], r₃; count_add))
end

# ╔═╡ 22f7afb2-4837-4f56-a96a-b07faeafbf02
function add(a, b)
	count_add = 0
	
	l = abs(length(a) - length(b))
	a, b = length(a) < length(b) ? (vcat(a, zeros(Int, l)), b) : (a, vcat(b, zeros(Int, l)))

	return add1(a, b, 0; count_add)
end

# ╔═╡ a04326eb-502a-4e85-994a-9ac9901cf3e3
begin
	@show count_add_2
end

# ╔═╡ 66cf6c2b-f947-46ea-bcc6-ec64245900ea
function mul1(a, b, c)
	r₁, c₁ = mul_mac(a, b[1])
	r₂, c₂ = add_mac(r₁, c)
	r₃, c₃ = add_mac(c₁, c₂)

	if length(b) == 1
		return r₂, r₃
	end

	return append!([r₂], mul1(a, b[2:end], r₃))
end

# ╔═╡ b164af30-205e-4430-a7bd-b3a3ded07fb8
function mul(a, b)
	r = mul1(a[1], b, 0)

	if length(a) == 1
		println("done?")
		return r
	end

	s = [0; mul(a[2:end], b)]

	println("h")

	return add(r, s)
end

# ╔═╡ dbf55a72-7453-4269-8da9-16f4f24bfa2f
# ╠═╡ disabled = true
#=╠═╡
@show count_mul
  ╠═╡ =#

# ╔═╡ 22a304db-3a7f-4bf2-b3c1-5b6a62c967ec
begin
	α, β = 12, 123
	a, b = digits(α), digits(β)
end;

# ╔═╡ a2f4c8c9-3f70-46f0-a526-541515456208
begin
	output_add = add(a, b)
	println("output - $(output_add[1:end-1])")
	println("add_mac calls - $(output_add[end])")
end

# ╔═╡ 285a6273-f5cc-4686-9913-8cd1dc1dbc80
mul(a, b)

# ╔═╡ 698496f5-faaf-40ed-9010-253ed7750554
begin
	x = 10
	reset(x)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"

[compat]
BenchmarkTools = "~1.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "2a7392fbc86bcb1608a6d4c3fafc922aa7051ef7"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "e38fbc49a620f5d0b660d7f543db1009fe0f8336"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

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

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"
"""

# ╔═╡ Cell order:
# ╠═bb759148-2e51-4fde-aaed-0af7acc26bc4
# ╠═ef065b90-cf49-11ef-268d-b941dc928ae6
# ╠═04e544f1-ab3d-4250-93fe-769f3d2a5c23
# ╠═0e4f6b62-f1b2-4c5b-ac1c-331f37b2c7d5
# ╠═22f7afb2-4837-4f56-a96a-b07faeafbf02
# ╠═a2f4c8c9-3f70-46f0-a526-541515456208
# ╠═a04326eb-502a-4e85-994a-9ac9901cf3e3
# ╠═66cf6c2b-f947-46ea-bcc6-ec64245900ea
# ╠═b164af30-205e-4430-a7bd-b3a3ded07fb8
# ╠═285a6273-f5cc-4686-9913-8cd1dc1dbc80
# ╠═dbf55a72-7453-4269-8da9-16f4f24bfa2f
# ╠═22a304db-3a7f-4bf2-b3c1-5b6a62c967ec
# ╠═698496f5-faaf-40ed-9010-253ed7750554
# ╠═f6327ba5-5c09-4db1-93b6-5e41226d0963
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
