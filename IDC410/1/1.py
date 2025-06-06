import matplotlib.pyplot as plt
import matplotlib.colors as colors
import numpy as np

ns, sigmas, itrs = np.genfromtxt('data-test2.txt')

fig = plt.figure()
ax = fig.add_subplot(projection='3d')
ax.scatter(ns, sigmas, itrs, c=itrs, cmap='rainbow', alpha=0.7)
ax.set_xlabel('n')
ax.set_ylabel('σ')
ax.set_zlabel('Iterations')

# xx = np.linspace(5, 100, 1000)
# yy = np.linspace(2, 0.1, 1000)
# xx, yy = np.meshgrid(xx, yy)

# ax.plot_surface(xx, 2-yy, 125000/(xx*yy), color='white', alpha=0.7)

ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')

plt.show()