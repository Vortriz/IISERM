using Plots
using Statistics

function chialvo_map(x0, y0, a=1.0, b=0.3, iterations=1000)
    x = zeros(iterations)
    y = zeros(iterations)
    x[1] = x0
    y[1] = y0
    
    for i in 2:iterations
        x[i] = x[i-1]^2 * exp(y[i-1] - x[i-1]^2) + a
        y[i] = b * y[i-1] + x[i-1]^2
    end
    
    return x, y
end

function coupled_map_lattice(N::Int, T::Int, ε::Float64; 
                           a::Float64=1.0, b::Float64=0.3)
    """
    Simulate a coupled map lattice of N Chialvo maps for T time steps
    
    Parameters:
    - N: number of lattice sites
    - T: number of time steps
    - ε: coupling strength
    - a, b: Chialvo map parameters
    
    Returns:
    - Array of size (N, T) containing the x-coordinates of all maps
    - Array of size (N, T) containing the y-coordinates of all maps
    """
    # Initialize arrays
    x = zeros(N, T)
    y = zeros(N, T)
    
    # Set random initial conditions
    x[:, 1] = rand(N) * 0.2  # Small random initial conditions
    y[:, 1] = rand(N) * 0.2
    
    # Time evolution with diffusive coupling
    for t in 2:T
        for i in 1:N
            # Get neighbor indices with periodic boundary conditions
            left = i == 1 ? N : i-1
            right = i == N ? 1 : i+1
            
            # Calculate coupling term for x
            coupling_x = ε * (x[left, t-1] + x[right, t-1] - 2x[i, t-1])
            
            # Update using Chialvo map plus coupling
            x[i, t] = x[i, t-1]^2 * exp(y[i, t-1] - x[i, t-1]^2) + a + coupling_x
            y[i, t] = b * y[i, t-1] + x[i, t-1]^2
        end
    end
    
    return x, y
end

# Example usage and visualization
# 1. Single Chialvo map
x_single, y_single = chialvo_map(0.1, 0.1)

p1 = scatter(x_single, y_single, 
    label="Single Map",
    title="Single Chialvo Map",
    xlabel="x",
    ylabel="y",
    markersize=1,
    alpha=0.6
)

# 2. Coupled Map Lattice
N = 50    # Number of maps
T = 500   # Time steps
ε = 0.1   # Coupling strength

x_coupled, y_coupled = coupled_map_lattice(N, T, ε)

# Create space-time plot
p2 = heatmap(1:T, 1:N, x_coupled,
    title="Coupled Map Lattice Space-Time Plot",
    xlabel="Time",
    ylabel="Lattice Site",
    colorbar_title="x value",
    color=:viridis
)

# Display synchronization measure
function sync_measure(x)
    """Calculate synchronization measure as variance across lattice sites"""
    return [var(x[:, t]) for t in 1:size(x, 2)]
end

sync = sync_measure(x_coupled)
p3 = plot(sync,
    title="Synchronization Measure",
    xlabel="Time",
    ylabel="Variance across sites",
    label="Sync measure"
)

# Arrange all plots
plot(p1, p2, p3, layout=(3,1), size=(800,1000))

savefig("test.png")