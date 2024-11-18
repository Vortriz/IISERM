using Images, ImageFiltering, Statistics, Plots

# Density function representing phase transition
function ρ(T::Float64, params)
    return tanh(params.α * (T - params.Tc))
end
ρ(T::AbstractArray, params) = ρ.(T, Ref(params))

function simulate_boiling(; nx=64, ny=64, T_top=0.0, T_bottom=9.85, 
                         params=(ϵ=0.5, α=10.0, σ=0.1, η=0.1, Tc=10.0),
                         n_steps=100)
    # Initialize temperature field
    T = fill((T_top + T_bottom)/2, (ny, nx)) .+ 0.1 .* randn(ny, nx)
    
    # Fix boundary conditions
    T[1, :] .= T_top
    T[end, :] .= T_bottom
    
    # Storage for heat flux calculations
    heat_flux_history = zeros(n_steps)
    
    # Main simulation loop
    for step in 1:n_steps
        # 1. Thermal diffusion
        T_diff = similar(T)
        for i in 2:ny-1, j in 2:nx-1
            T_diff[i,j] = T[i,j] + (params.ϵ/4) * (
                T[i+1,j] + T[i-1,j] + T[i,j+1] + T[i,j-1] - 4*T[i,j]
            )
        end
        
        # 2. Bubble motion (using density gradient)
        T_bubble = similar(T)
        for i in 2:ny-1, j in 1:nx
            ρ_grad = ρ(T[i+1,j], params) - ρ(T[i-1,j], params)
            T_bubble[i,j] = T_diff[i,j] - (params.σ/2) * T_diff[i,j] * ρ_grad
        end
        
        # 3. Latent heat effect
        T_latent = copy(T_bubble)
        for i in 2:ny-1, j in 1:nx
            if T_bubble[i,j] < params.Tc && T[i,j] > params.Tc
                # Phase transition from gas to liquid
                for di in [-1,0,1], dj in [-1,0,1]
                    if abs(di) + abs(dj) == 1 && 1 <= i+di <= ny && 1 <= j+dj <= nx
                        T_latent[i+di,j+dj] += params.η
                    end
                end
            end
        end
        
        # Apply boundary conditions
        T_latent[1, :] .= T_top
        T_latent[end, :] .= T_bottom
        
        # Calculate heat flux
        heat_flux = mean(abs.(T_latent[2:end, :] - T_latent[1:end-1, :]))
        heat_flux_history[step] = heat_flux
        
        # Update temperature field
        T = T_latent
    end
    
    return T, heat_flux_history
end

# Function to create animation
function animate_boiling(; kwargs...)
    nx, ny = 64, 64
    n_frames = 100
    
    # Initialize animation
    anim = @animate for frame in 1:n_frames
        T, _ = simulate_boiling(nx=nx, ny=ny, n_steps=1; kwargs...)
        
        # Create heatmap
        heatmap(T, 
                aspect_ratio=:equal,
                c=:thermal,
                clim=(0, 10),
                title="Boiling Simulation (Frame $frame)",
                xlabel="X",
                ylabel="Y",
                colorbar_title="Temperature")
    end
    
    return gif(anim, "boiling_simulation.gif", fps=15)
end

# Function to analyze bubble statistics
function analyze_bubbles(T, Tc)
    # Identify bubbles (regions where T > Tc)
    bubble_mask = T .> Tc
    
    # Calculate bubble sizes using connected components
    labels = label_components(bubble_mask)
    sizes = component_lengths(labels)
    
    return sizes[sizes .> 0]  # Return non-zero bubble sizes
end

# Main simulation with different temperature regimes
function run_simulation_analysis()
    temperatures = [9.75, 9.85, 9.95]  # Conduction, nucleate, and film boiling
    results = []
    
    for T_bottom in temperatures
        println("Simulating T_bottom = $T_bottom")
        T, heat_flux = simulate_boiling(T_bottom=T_bottom, n_steps=200)
        
        # Analyze bubbles
        bubble_sizes = analyze_bubbles(T, 10.0)
        
        push!(results, (T=T, heat_flux=heat_flux, bubble_sizes=bubble_sizes))
    end
    
    return results
end

# Run basic simulation
T, heat_flux = simulate_boiling()

# Create animation
animate_boiling()

# Run full analysis across temperature regimes
results = run_simulation_analysis()