import numpy as np
import matplotlib.pyplot as plt
from matplotlib import animation

class BoilingSimulation:
    def __init__(self, width=64, height=64, epsilon=0.5, alpha=10, delta=0.1, 
                 eta=0.1, t_critical=10, t_bottom=9.85, t_top=5):
        self.width = width
        self.height = height
        self.epsilon = epsilon
        self.alpha = alpha
        self.delta = delta
        self.eta = eta
        self.t_critical = t_critical
        self.t_bottom = t_bottom
        self.t_top = t_top
        
        # Initialize temperature field with slight random perturbation
        self.reset()
        
    def reset(self):
        """Reset the simulation state"""
        self.T = np.ones((self.height, self.width)) * (self.t_top + self.t_bottom) / 2
        self.T += np.random.uniform(-0.01, 0.01, (self.height, self.width))
        self.apply_boundary_conditions()
        
    def apply_boundary_conditions(self):
        """Apply boundary conditions"""
        # Fixed temperature at top and bottom
        self.T[0, :] = self.t_bottom
        self.T[-1, :] = self.t_top
        # Periodic boundary conditions on sides
        self.T[:, 0] = self.T[:, -2]
        self.T[:, -1] = self.T[:, 1]
        
    def diffusion_step(self):
        """Thermal diffusion process"""
        T_new = self.T.copy()
        for y in range(1, self.height-1):
            for x in range(1, self.width-1):
                laplacian = (self.T[y+1, x] + self.T[y-1, x] + 
                           self.T[y, x+1] + self.T[y, x-1] - 4*self.T[y, x])
                T_new[y, x] = self.T[y, x] + self.epsilon * laplacian
        return T_new
        
    def bubble_motion_step(self):
        """Creation and floating motion of bubbles"""
        T_new = self.T.copy()
        
        # Calculate density gradient
        for y in range(1, self.height-1):
            for x in range(1, self.width-1):
                if self.T[y, x] > self.t_critical:  # If cell is in gas phase
                    # Calculate buoyancy force
                    density_above = np.tanh(self.alpha * (self.T[y-1, x] - self.t_critical))
                    density_below = np.tanh(self.alpha * (self.T[y+1, x] - self.t_critical))
                    buoyancy = self.delta * (density_below - density_above)
                    
                    # Move bubble upward
                    if buoyancy > 0 and y > 1:
                        T_new[y-1, x] = self.T[y, x]
                        T_new[y, x] = self.T[y+1, x]
        
        return T_new
    
    def latent_heat_step(self):
        """Latent heat effect"""
        T_new = self.T.copy()
        
        for y in range(1, self.height-1):
            for x in range(1, self.width-1):
                # Check for phase transition
                if self.T[y, x] > self.t_critical and any(
                    neighbor < self.t_critical for neighbor in [
                        self.T[y+1, x], self.T[y-1, x],
                        self.T[y, x+1], self.T[y, x-1]
                    ]
                ):
                    # Apply latent heat effect to neighbors
                    T_new[y+1, x] -= self.eta
                    T_new[y-1, x] -= self.eta
                    T_new[y, x+1] -= self.eta
                    T_new[y, x-1] -= self.eta
        
        return T_new
    
    def step(self):
        """Perform one complete simulation step"""
        self.T = self.diffusion_step()
        self.apply_boundary_conditions()
        self.T = self.bubble_motion_step()
        self.apply_boundary_conditions()
        self.T = self.latent_heat_step()
        self.apply_boundary_conditions()
        
    def calculate_heat_flux(self):
        """Calculate heat flux at the bottom boundary"""
        return np.mean(np.abs(self.T[1, :] - self.T[0, :]))

def run_simulation(t_bottom_values):
    """Run simulation for different bottom temperatures and calculate heat flux"""
    sim = BoilingSimulation(width=64, height=64)
    heat_fluxes = []
    
    for t_bottom in t_bottom_values:
        sim.t_bottom = t_bottom
        sim.reset()
        
        # Run simulation until steady state
        for _ in range(100):
            sim.step()
            
        # Calculate average heat flux
        flux = 0
        for _ in range(20):
            sim.step()
            flux += sim.calculate_heat_flux()
        heat_fluxes.append(flux / 20)
        
    return heat_fluxes

def animate_boiling(sim, frames=200):
    """Create animation of the boiling simulation"""
    fig, ax = plt.subplots(figsize=(8, 8))
    
    def init():
        im = ax.imshow(sim.T, cmap='hot', vmin=sim.t_top, vmax=sim.t_bottom)
        plt.colorbar(im)
        return [im]
    
    def update(frame):
        sim.step()
        ax.clear()
        im = ax.imshow(sim.T, cmap='hot', vmin=sim.t_top, vmax=sim.t_bottom)
        ax.set_title(f'Frame {frame}')
        return [im]
    
    ani = animation.FuncAnimation(fig, update, frames=frames,
                                init_func=init, interval=50, blit=True)
    plt.show()
    return ani

if __name__ == "__main__":
    # Create simulation and animate
    sim = BoilingSimulation(width=64, height=64, t_bottom=9.85)
    animate_boiling(sim)
    
    # Generate boiling curve
    t_bottom_values = np.linspace(9.75, 10.0, 20)
    heat_fluxes = run_simulation(t_bottom_values)
    
    plt.figure(figsize=(10, 6))
    plt.plot(t_bottom_values, heat_fluxes, 'bo-')
    plt.xlabel('Bottom Temperature')
    plt.ylabel('Heat Flux')
    plt.title('Boiling Characteristic Curve')
    plt.grid(True)
    plt.show()