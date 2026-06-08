import numpy as np
import matplotlib.pyplot as plt
import os

# Ensure the figures directory exists
os.makedirs('../figures', exist_ok=True)

# Generate synthetic data for Kawahara Lyapunov decay
t = np.linspace(0, 10, 500)
# V(t) = V(0) * exp(-gamma * t) with some synthetic oscillations
V_t = 100 * np.exp(-0.8 * t) * (1 + 0.1 * np.sin(5 * t))

plt.figure(figsize=(8, 5))
plt.plot(t, V_t, label=r'$\mathcal{V}(u(t))$', color='navy', linewidth=2)
plt.fill_between(t, 0, V_t, color='navy', alpha=0.1)
plt.axhline(0, color='black', linewidth=0.8, linestyle='--')

plt.title(r'Decay of the Alien Lyapunov Functional $\mathcal{V}(u)$', fontsize=14)
plt.xlabel('Time $t$', fontsize=12)
plt.ylabel('Energy $\mathcal{V}$', fontsize=12)
plt.grid(True, alpha=0.3)
plt.legend(fontsize=12)

plt.tight_layout()
plt.savefig('../figures/kawahara_decay.pdf')
print('Generated ../figures/kawahara_decay.pdf')
