### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 461d4452-e6df-46ed-a73d-9a8088c8a1c5
function cmp(a, b)
    return a <= b
	# l = maximum(ndigits, [a, b])
	# a = reverse(digits(a, pad=l))
	# b = reverse(digits(b, pad=l))

	# for i in 1:l
	# 	aᵢ, bᵢ = a[i], b[i]
	# 	if aᵢ < bᵢ || aᵢ == bᵢ
	# 		return true
	# 	elseif aᵢ == bᵢ
	# 		continue
	# 	elseif aᵢ > bᵢ
	# 		return false
	# 	end
	# end
end

# ╔═╡ c4b1f8a0-ead2-11ef-21d5-614e3a8f6d46
function bubblepass(a)
    c = 0
    k = length(a)
    
    for i in 1:k-1
        if cmp(a[i], a[i+1]) == false
            c+=1
            a[i], a[i+1] = a[i+1], a[i]
        end
    end

    return c, a
end

# ╔═╡ fa55d24d-9552-470c-9f32-4be2f189f8a5
function bubblesort(a)
    c = 1
    while c > 0
        c, a = bubblepass(a)
    end

    return a
end

# ╔═╡ bb59896c-e859-4d45-b4a2-fc5e2ded0858
a = rand(1:100, 10)

# ╔═╡ 67c37b65-5038-4a7f-9fd1-d8804a78d5aa
bubblesort(a)

# ╔═╡ ffe32b44-73d1-4164-8e76-f20b260549a2
function insert(a, b)
	k = length(a)
	push!(a, b)
	j = copy(k)

	while j >= 1 && cmp(a[j], a[j+1]) == false
		a[j], a[j+1] = a[j+1], a[j]
		j-=1
	end

	return a
end

# ╔═╡ a927da9a-473f-4a05-bc15-4183a39cd411
function insertsort(a)
	k = length(a)

	for i in 2:k
		a′, aᵢ, a″ = a[1:i-1], a[i], a[i+1:end]
		a′ = insert(a′, aᵢ)
		a = vcat(a′, a″)
	end

	return a
end

# ╔═╡ 84a34ce5-717c-4475-89bc-6a2aeb30090d
insertsort(a)

# ╔═╡ c0832cc5-f756-42b4-bf6d-8cae85dbc6a0
function partition(a, p)
	k = length(a)
	λ, ρ = Int[], Int[]
	c = a[p]

	for i in 1:k
		if i == p
			continue
		end

		aᵢ = a[i]
		if cmp(aᵢ, c) == true
			push!(λ, aᵢ)
		else
			push!(ρ, aᵢ)
		end
	end

	return λ, ρ
end

# ╔═╡ 1f9ffeee-49b3-41b9-a730-72c1aeeb7e6b
function quicksort(a)
	k = length(a)

	 if k <= 1
		 return a
	 end

	c = a[1]
	λ, ρ = partition(a, 1)
	λ, ρ = quicksort(λ), quicksort(ρ)

	return vcat(λ, c, ρ)
end

# ╔═╡ e38a0085-fea8-412c-94d3-3b994ca4adb9
quicksort(a)

# ╔═╡ 6e0089f0-9a67-43aa-bdd9-756890506b2a
function merge_alt(a, b)
	i, j = 1, 1
	p, q = length(a), length(b)
	c = Int[]

	while i <= p && j <= q
		aᵢ, bᵢ = a[i], b[i]
		
		if cmp(aᵢ, bᵢ) == true
			push!(c, aᵢ)
			i+=1
		else
			push!(c, bᵢ)
			j+=1
		end
	end

	if j > q
		return vcat(c, a[i:end])
	else
		return vcat(c, b[j:end])
	end
end

# ╔═╡ ef3f34b4-3b4d-4400-b870-2a4cc5c5dcda
function mergesort(a)
	k = length(a)

	if k <= 1
		return a
	end

	k₂ = k÷2
	b = a[1:k₂]
	c = a[k₂+1:end]

	return merge_alt(mergesort(b), mergesort(c))
end

# ╔═╡ 10665d89-1336-406e-9e97-33c55d00681f
mergesort(a)

# ╔═╡ Cell order:
# ╠═c4b1f8a0-ead2-11ef-21d5-614e3a8f6d46
# ╠═fa55d24d-9552-470c-9f32-4be2f189f8a5
# ╠═461d4452-e6df-46ed-a73d-9a8088c8a1c5
# ╠═bb59896c-e859-4d45-b4a2-fc5e2ded0858
# ╠═67c37b65-5038-4a7f-9fd1-d8804a78d5aa
# ╠═ffe32b44-73d1-4164-8e76-f20b260549a2
# ╠═a927da9a-473f-4a05-bc15-4183a39cd411
# ╠═84a34ce5-717c-4475-89bc-6a2aeb30090d
# ╠═c0832cc5-f756-42b4-bf6d-8cae85dbc6a0
# ╠═1f9ffeee-49b3-41b9-a730-72c1aeeb7e6b
# ╠═e38a0085-fea8-412c-94d3-3b994ca4adb9
# ╠═6e0089f0-9a67-43aa-bdd9-756890506b2a
# ╠═ef3f34b4-3b4d-4400-b870-2a4cc5c5dcda
# ╠═10665d89-1336-406e-9e97-33c55d00681f
