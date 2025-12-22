#!/usr/bin/env python3
"""
Test different knot vector strategies for 9 control points with degree 3
Based on "The NURBS Book" algorithms
"""

import numpy as np
from scipy.interpolate import BSpline
from scipy.linalg import lstsq, solve

# Test data from issue #260
degree = 3
on_curve_points = np.array([
    [1583.2136549257, 417.836639195, 0],
    [2346.3909069169, 988.9560396917, 0],
    [1396.2099574179, 1772.3499076297, 0],
    [-392.9605538726, 1716.754213776, 0],
    [-41.2801529313, 2784.8206166348, 0],
    [1717.1218517754, 2954.1482170881, 0],
    [3449.4734564123, 2146.5858149265, 0],
])

# Expected control points from issue #260
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
    """Compute chord length parameterization"""
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

def generate_knot_vector_averaging(m, n, p, params):
    """
    Generate knot vector using averaging (Algorithm A9.1 from NURBS Book)
    m = number of data points - 1 (index of last data point)
    n = number of control points - 1 (index of last control point)
    p = degree
    params = parameter values for data points

    Returns knot vector of length n + p + 2
    """
    knots = np.zeros(n + p + 2)

    # Clamped: first p+1 knots are 0
    for i in range(p + 1):
        knots[i] = 0.0

    # Averaging for internal knots
    # For j = 1 to n-p:
    #   u_{j+p} = (1/p) * sum_{i=j}^{j+p-1} params[i]
    for j in range(1, n - p + 1):
        sum_val = 0.0
        for i in range(j, j + p):
            sum_val += params[i]
        knots[j + p] = sum_val / p

    # Clamped: last p+1 knots are 1
    for i in range(n + 1, n + p + 2):
        knots[i] = 1.0

    return knots

# Chord length parameterization
params = compute_chord_params(on_curve_points)
print("="*80)
print("Parameters (chord length):")
print("="*80)
print(params)

m = len(on_curve_points) - 1  # m = 6 (7 points, indexed 0-6)
n_cp = 9
n = n_cp - 1  # n = 8 (9 control points, indexed 0-8)
p = degree    # p = 3

print(f"\nm (last data point index) = {m}")
print(f"n (last control point index) = {n}")
print(f"p (degree) = {p}")
print(f"Expected knot vector length: n + p + 2 = {n + p + 2}")

# Generate knot vector
knot_vector = generate_knot_vector_averaging(m, n, p, params)

print("\n" + "="*80)
print("Knot vector using averaging:")
print("="*80)
print(knot_vector)

# Build design matrix
m_pts = len(on_curve_points)
A = np.zeros((m_pts, n_cp))

for i, u in enumerate(params):
    for j in range(n_cp):
        # Compute B_j,p(u) using scipy's BSpline
        c = np.zeros(n_cp)
        c[j] = 1.0
        spl = BSpline(knot_vector, c, p)
        A[i, j] = spl(u)

print(f"\nDesign matrix shape: {A.shape}")
print(f"Rank: {np.linalg.matrix_rank(A)}")

print("\n" + "="*80)
print("Design Matrix (basis functions at parameter values):")
print("="*80)
print("Rows: data points, Columns: control points")
print(A)

# This is an UNDERDETERMINED system (7 equations, 9 unknowns)
# We need additional constraints!

print("\n" + "="*80)
print("IMPORTANT: System is underdetermined!")
print("="*80)
print(f"Number of equations: {m_pts}")
print(f"Number of unknowns: {n_cp}")
print(f"System type: underdetermined (more unknowns than equations)")
print("\nWe need 2 additional constraints!")

# Common constraints for curve fitting:
# 1. End derivatives (natural spline conditions)
# 2. Smoothness conditions
# 3. Endpoint interpolation constraints are already included

# Let's try endpoint constraints: P[0] = D[0] and P[n] = D[m]
# This means first and last control points equal first and last data points

print("\n" + "="*80)
print("Adding endpoint constraints:")
print("="*80)
print(f"P[0] = D[0] (first control point = first data point)")
print(f"P[{n}] = D[{m}] (last control point = last data point)")

# Modified approach: solve with endpoint constraints
# Fix P[0] = D[0] and P[n] = D[m], solve for P[1]...P[n-1]

# For each dimension
results = []
for dim in range(3):
    # Extract dimension values
    D = on_curve_points[:, dim]

    # Modified system: remove first and last columns, adjust RHS
    A_reduced = A[:, 1:-1]  # Only middle control points
    b = D - A[:, 0] * on_curve_points[0, dim] - A[:, -1] * on_curve_points[-1, dim]

    # Solve least squares
    x_middle, residuals, rank, s = lstsq(A_reduced, b)

    # Reconstruct full solution
    x_full = np.zeros(n_cp)
    x_full[0] = on_curve_points[0, dim]
    x_full[1:-1] = x_middle
    x_full[-1] = on_curve_points[-1, dim]

    results.append(x_full)

control_x, control_y, control_z = results

print("\n" + "="*80)
print("Computed control points (with endpoint constraints):")
print("="*80)

computed_cps = np.column_stack([control_x, control_y, control_z])
for i, cp in enumerate(computed_cps):
    print(f"CP {i}: ({cp[0]:.4f}, {cp[1]:.4f}, {cp[2]:.4f})")

print("\n" + "="*80)
print("Expected control points:")
print("="*80)

for i, cp in enumerate(expected_control_points):
    print(f"CP {i}: ({cp[0]:.4f}, {cp[1]:.4f}, {cp[2]:.4f})")

print("\n" + "="*80)
print("Comparison:")
print("="*80)

max_diff = 0
for i in range(len(expected_control_points)):
    computed = computed_cps[i]
    expected = expected_control_points[i]
    diff = np.linalg.norm(computed - expected)
    max_diff = max(max_diff, diff)
    match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
    print(f"{match} CP {i}: diff={diff:.4f}")

print(f"\nMaximum difference: {max_diff:.4f}")

if max_diff < 1.0:
    print("\n✓✓✓ PERFECT MATCH!")
elif max_diff < 10.0:
    print("\n~ Close match, might be rounding or parameter differences")
else:
    print("\n✗ Still not matching")

# Verify interpolation
print("\n" + "="*80)
print("Verify curve passes through data points:")
print("="*80)

for i, (u, pt) in enumerate(zip(params, on_curve_points)):
    spl_x = BSpline(knot_vector, control_x, degree)
    spl_y = BSpline(knot_vector, control_y, degree)
    spl_z = BSpline(knot_vector, control_z, degree)

    eval_pt = np.array([spl_x(u), spl_y(u), spl_z(u)])
    diff = np.linalg.norm(eval_pt - pt)
    match = "✓" if diff < 0.01 else "~" if diff < 1.0 else "✗"
    print(f"{match} Point {i}: diff={diff:.6f}")
