#!/usr/bin/env python3
"""
Implement natural cubic B-spline from scratch to understand the algorithm
Then we can translate it to Pascal
"""

import numpy as np
from scipy.interpolate import BSpline, make_interp_spline
from scipy.linalg import solve

# Test data
on_curve_points = np.array([
    [1583.2136549257, 417.836639195, 0],
    [2346.3909069169, 988.9560396917, 0],
    [1396.2099574179, 1772.3499076297, 0],
    [-392.9605538726, 1716.754213776, 0],
    [-41.2801529313, 2784.8206166348, 0],
    [1717.1218517754, 2954.1482170881, 0],
    [3449.4734564123, 2146.5858149265, 0],
])

expected_control_points = np.array([
    [1583.2137, 417.8366, 0],
    [1943.9619, 588.3078, 0],
    [2770.7705, 979.0151, 0],
    [1225.7225, 2260.4551, 0],
    [-771.0874, 1052.6822, 0],
    [-50.7662, 3342.0538, 0],
    [1877.21, 3020.2007, 0],
    [2911.8082, 2445.335, 0],
    [3449.4735, 2146.5858, 0],
])

def compute_chord_params(points):
    n = len(points)
    params = np.zeros(n)
    total_length = 0
    for i in range(1, n):
        chord = np.linalg.norm(points[i] - points[i-1])
        total_length += chord
        params[i] = params[i-1] + chord
    if total_length > 0:
        params = params / total_length
    return params

# Step 1: Chord length parameters
params = compute_chord_params(on_curve_points)
print("Parameters:", params)

# Step 2: Knot vector
# For 7 data points with degree 3, natural spline uses 9 control points
# Knot vector: [0,0,0,0, params[1], ..., params[m-1], 1,1,1,1]
degree = 3
n_data = len(on_curve_points)
n_cp = n_data + 2  # 9 control points for 7 data points

knots = np.concatenate([
    np.zeros(degree + 1),
    params[1:-1],  # Internal knots from params[1] to params[5]
    np.ones(degree + 1)
])

print(f"\nKnot vector ({len(knots)} elements):")
print(knots)

# Step 3: Build augmented system with natural boundary conditions
# We have 7 interpolation constraints + 2 natural boundary conditions = 9 equations for 9 unknowns

# First, build the interpolation matrix
A_interp = np.zeros((n_data, n_cp))

for i, u in enumerate(params):
    for j in range(n_cp):
        c = np.zeros(n_cp)
        c[j] = 1.0
        spl = BSpline(knots, c, degree)
        A_interp[i, j] = spl(u)

print(f"\nInterpolation matrix shape: {A_interp.shape}")
print(f"Rank: {np.linalg.matrix_rank(A_interp)}")

# Natural boundary conditions: second derivative = 0 at start and end
# For cubic B-spline, second derivative at parameter u is:
# C''(u) = sum_i P_i * N''_i,3(u)

# We need to compute second derivatives of basis functions
def basis_deriv2(j, degree, u, knots):
    """Compute second derivative of basis function using finite differences"""
    h = 1e-6
    c = np.zeros(len(knots) - degree - 1)
    c[j] = 1.0
    spl = BSpline(knots, c, degree)

    # Central difference for second derivative
    if u < h:
        u_eval = h
    elif u > 1 - h:
        u_eval = 1 - h
    else:
        u_eval = u

    f_plus = spl(min(u_eval + h, 1.0))
    f_center = spl(u_eval)
    f_minus = spl(max(u_eval - h, 0.0))

    deriv2 = (f_plus - 2 * f_center + f_minus) / (h * h)
    return deriv2

# Build boundary condition rows
bc_start = np.zeros(n_cp)
bc_end = np.zeros(n_cp)

for j in range(n_cp):
    bc_start[j] = basis_deriv2(j, degree, params[0], knots)
    bc_end[j] = basis_deriv2(j, degree, params[-1], knots)

print(f"\nBoundary condition at start: {bc_start}")
print(f"Boundary condition at end: {bc_end}")

# Augmented system
A_full = np.vstack([A_interp, bc_start[np.newaxis, :], bc_end[np.newaxis, :]])
print(f"\nAugmented matrix shape: {A_full.shape}")
print(f"Rank: {np.linalg.matrix_rank(A_full)}")

# Solve for each dimension
results = []
for dim in range(3):
    D = on_curve_points[:, dim]
    b_full = np.concatenate([D, [0.0, 0.0]])  # Interpolation + natural BC (deriv2 = 0)

    x = solve(A_full, b_full)
    results.append(x)

print("\n" + "="*80)
print("Computed control points (with natural BC):")
print("="*80)

for i in range(n_cp):
    print(f"CP {i}: ({results[0][i]:.4f}, {results[1][i]:.4f}, {results[2][i]:.4f})")

print("\n" + "="*80)
print("Expected control points:")
print("="*80)

for i in range(n_cp):
    print(f"CP {i}: ({expected_control_points[i,0]:.4f}, {expected_control_points[i,1]:.4f}, {expected_control_points[i,2]:.4f})")

print("\n" + "="*80)
print("Comparison:")
print("="*80)

max_diff = 0
for i in range(n_cp):
    computed = np.array([results[0][i], results[1][i], results[2][i]])
    expected = expected_control_points[i]
    diff = np.linalg.norm(computed - expected)
    max_diff = max(max_diff, diff)
    match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
    print(f"{match} CP {i}: diff={diff:.4f}")

print(f"\nMaximum difference: {max_diff:.4f}")

if max_diff < 1.0:
    print("\n✓✓✓ SUCCESS! This is the correct algorithm!")
    print("\nAlgorithm summary for Pascal implementation:")
    print("1. Compute chord-length parameters")
    print("2. Create knot vector: [0,0,0,0, params[1..m-1], 1,1,1,1]")
    print("3. Build (m+1) × (n+1) interpolation matrix using basis functions")
    print("4. Add 2 rows for natural BC: second derivative = 0 at endpoints")
    print("5. Solve the (m+3) × (m+3) system")
else:
    print("\n✗ Not quite right, need to investigate further")

# Verify interpolation
print("\n" + "="*80)
print("Verify curve passes through data points:")
print("="*80)

for i, u in enumerate(params):
    spl_x = BSpline(knots, results[0], degree)
    spl_y = BSpline(knots, results[1], degree)
    spl_z = BSpline(knots, results[2], degree)

    eval_pt = np.array([spl_x(u), spl_y(u), spl_z(u)])
    diff = np.linalg.norm(eval_pt - on_curve_points[i])
    match = "✓" if diff < 0.01 else "~" if diff < 1.0 else "✗"
    print(f"{match} Point {i}: diff={diff:.6f}")
