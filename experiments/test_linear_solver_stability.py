#!/usr/bin/env python3
"""
Test the stability of the linear solver with the actual matrix from 7-point interpolation.
"""

import numpy as np

# The actual basis function matrix from our 7-point test
A = np.array([
    [1.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00],
    [2.33586032e-02, 3.20162993e-01, 5.17014723e-01, 1.39463681e-01, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00],
    [3.09949994e-03, 1.86557571e-01, 5.71682086e-01, 2.38660843e-01, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00],
    [0.00000000e+00, 0.00000000e+00, 1.15089525e-01, 7.59372396e-01, 1.25360239e-01, 1.77840654e-04, 0.00000000e+00],
    [0.00000000e+00, 0.00000000e+00, 4.91826594e-04, 4.24079641e-01, 4.98770714e-01, 7.66578186e-02, 0.00000000e+00],
    [0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 3.02404404e-02, 2.62945882e-01, 5.37002211e-01, 1.69811467e-01],
    [0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 1.00000000e+00],
])

# Fit points
b_x = np.array([1.0, 3.5, 3.5, 1.5, 0.5, 2.5, 4.0])
b_y = np.array([2.0, 1.5, 1.0, 0.5, 1.5, 2.5, 2.0])

print("="*70)
print("LINEAR SOLVER STABILITY TEST")
print("="*70)

print(f"\nMatrix condition number: {np.linalg.cond(A):.2e}")
print(f"Matrix determinant: {np.linalg.det(A):.2e}")

# Solve using numpy
x_np = np.linalg.solve(A, b_x)
y_np = np.linalg.solve(A, b_y)

print(f"\nControl points (NumPy solver):")
for i in range(len(x_np)):
    print(f"  P{i}: ({x_np[i]:.6f}, {y_np[i]:.6f})")

# Solve using Gaussian elimination (mimicking Pascal)
def gaussian_elimination(A, b):
    """Gaussian elimination with partial pivoting - mimics Pascal code."""
    n = len(b)
    A = A.astype(float).copy()  # Work with floats
    c = b.astype(float).copy()

    # Forward elimination with partial pivoting
    for k in range(n - 1):
        # Find pivot
        max_row = k
        max_val = abs(A[k, k])
        for i in range(k + 1, n):
            if abs(A[i, k]) > max_val:
                max_val = abs(A[i, k])
                max_row = i

        # Swap rows if needed
        if max_row != k:
            A[[k, max_row]] = A[[max_row, k]]
            c[k], c[max_row] = c[max_row], c[k]

        # Eliminate column
        for i in range(k + 1, n):
            if abs(A[k, k]) > 1e-10:
                factor = A[i, k] / A[k, k]
                A[i, k:] -= factor * A[k, k:]
                c[i] -= factor * c[k]

    # Back substitution
    x = np.zeros(n)
    for i in range(n - 1, -1, -1):
        x[i] = c[i]
        for j in range(i + 1, n):
            x[i] -= A[i, j] * x[j]
        if abs(A[i, i]) > 1e-10:
            x[i] /= A[i, i]
        else:
            x[i] = 0

    return x

x_gauss = gaussian_elimination(A, b_x)
y_gauss = gaussian_elimination(A, b_y)

print(f"\nControl points (Gaussian elimination):")
for i in range(len(x_gauss)):
    print(f"  P{i}: ({x_gauss[i]:.6f}, {y_gauss[i]:.6f})")

# Compare
print(f"\nDifference between solvers:")
print(f"  Max diff in x: {np.max(np.abs(x_np - x_gauss)):.2e}")
print(f"  Max diff in y: {np.max(np.abs(y_np - y_gauss)):.2e}")

# Verify solution
residual_x = np.linalg.norm(A @ x_gauss - b_x)
residual_y = np.linalg.norm(A @ y_gauss - b_y)
print(f"\nResidual (Gaussian):")
print(f"  ||Ax - b_x||: {residual_x:.2e}")
print(f"  ||Ay - b_y||: {residual_y:.2e}")

# Test with single precision (like Pascal's "single")
A_single = A.astype(np.float32)
b_x_single = b_x.astype(np.float32)
b_y_single = b_y.astype(np.float32)

x_single = gaussian_elimination(A_single, b_x_single)
y_single = gaussian_elimination(A_single, b_y_single)

print(f"\nControl points (single precision):")
for i in range(len(x_single)):
    print(f"  P{i}: ({x_single[i]:.6f}, {y_single[i]:.6f})")

print(f"\nDifference (double vs single precision):")
print(f"  Max diff in x: {np.max(np.abs(x_gauss - x_single)):.2e}")
print(f"  Max diff in y: {np.max(np.abs(y_gauss - y_single)):.2e}")
