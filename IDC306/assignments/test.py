import numpy as np
import matplotlib.pyplot as plt

np.random.seed(0)
n_samples = 300
k = 4
cluster_std = 0.60
centers = np.array([[-2, 2], [2, 2], [2, -2], [-2, -2]])
X = np.vstack([center + cluster_std * np.random.randn(n_samples // k, 2) for center in centers])

# Manual k-means implementation
def kmeans(X, k, max_iters=100):
    # Initialize centroids randomly
    indices = np.random.choice(X.shape[0], k, replace=False)
    centroids = X[indices]
    for _ in range(max_iters):
        # Assign clusters based on nearest centroid
        distances = np.linalg.norm(X[:, np.newaxis] - centroids, axis=2)
        labels = np.argmin(distances, axis=1)
        # Update centroids
        new_centroids = []
        for j in range(k):
            points = X[labels == j]
            if len(points) == 0:
                # Reinitialize empty centroid randomly
                new_centroids.append(X[np.random.choice(X.shape[0])])
            else:
                new_centroids.append(points.mean(axis=0))
        new_centroids = np.vstack(new_centroids)
        # Check for convergence
        if np.allclose(centroids, new_centroids):
            break
        centroids = new_centroids
    return centroids, labels

# Perform k-means clustering
centroids, labels = kmeans(X, k)

# Plot the clustered data and centroids
plt.figure(figsize=(8, 6))
plt.scatter(X[:, 0], X[:, 1], c=labels, s=50, cmap='viridis', alpha=0.6)
plt.scatter(centroids[:, 0], centroids[:, 1], c='red', s=200, marker='X', label='Centroids')
plt.title(f"K-Means Clustering (k={k})")
plt.xlabel('Feature 1')
plt.ylabel('Feature 2')
plt.legend()
plt.show()
