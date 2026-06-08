import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import os

os.makedirs('../figures', exist_ok=True)

# Generate synthetic data for the M47 tensor deformation manifold
u = np.linspace(0, 2 * np.pi, 100)
v = np.linspace(0, np.pi, 100)
U, V = np.meshgrid(u, v)

# Create a complex, "alien" looking topological manifold (e.g., a twisted torus / Klein bottle variant)
X = (3 + np.cos(V)) * np.cos(U) + 0.5 * np.cos(3*U) * np.sin(2*V)
Y = (3 + np.cos(V)) * np.sin(U) + 0.5 * np.sin(3*U) * np.sin(2*V)
Z = np.sin(V) + 0.5 * np.cos(5*U)

fig = plt.figure(figsize=(8, 6))
ax = fig.add_subplot(111, projection='3d')

# Plot the surface
surf = ax.plot_surface(X, Y, Z, cmap='plasma', edgecolor='none', alpha=0.8)

ax.set_title(r'Fractional Topology of the $M_{47}$ Tensor Deformation', fontsize=14)
ax.set_xlabel('$\mathcal{X}$ axis', fontsize=10)
ax.set_ylabel('$\mathcal{Y}$ axis', fontsize=10)
ax.set_zlabel('$\mathcal{Z}$ axis', fontsize=10)

# Remove grid and background for a cleaner "theoretical" look
ax.grid(False)
ax.xaxis.pane.fill = False
ax.yaxis.pane.fill = False
ax.zaxis.pane.fill = False

plt.tight_layout()
plt.savefig('../figures/tensor_manifold.pdf', format='pdf', bbox_inches='tight')
print('Generated ../figures/tensor_manifold.pdf')
