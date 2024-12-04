using DataFrames
using CSV

df = CSV.read("anes_timeseries_2016/anes_timeseries_2016_rawdata.csv", DataFrame)
polarizing_data = DataFrame(name=String[], id=String[], min=Int[], max=Int[])

push!(polarizing_data, ("religion", "V161242", 1, 3))
push!(polarizing_data, ("same_sex", "V161227x", 1, 6))
push!(polarizing_data, ("obamacare", "V161114x", 1, 7))
push!(polarizing_data, ("transgender", "V161228x", 1, 6))
push!(polarizing_data, ("birthright", "V161194x", 1, 7))
push!(polarizing_data, ("fight_isis", "V161213x", 1, 7))
push!(polarizing_data, ("mexican_wall", "V161196x", 1, 1))
push!(polarizing_data, ("climate_change", "V161225x", 1, 7))

pairs = [("religion", "same_sex"), ("transgender", "religion"), ("transgender", "same_sex"), ("obamacare", "transgender"), ("obamacare", "same_sex")]
paired_data = []

lin_map(x, min, max) = 2 * (x - min)/(max - min) - 1

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

    rename!(filtered_df, Dict(id1 => name1, id2 => name2))

   push!(paired_data, new_df)
end

# for i in paired_data
#     println(size(i))
# end