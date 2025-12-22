#!/usr/bin/env python3
"""
Test B-spline approximation with specific number of control points for issue #260
"""

import numpy as np
from scipy.interpolate import splprep, splev, BSpline
from scipy.linalg import lstsq

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

print("="*80)
print("Testing different smoothing parameters")
print("="*80)

# Try with smoothing to get more control points
points_t = on_curve_points.T

for s_value in [0, 0.1, 1, 10, 100, 1000]:
    try:
        tck, u = splprep(points_t, s=s_value, k=degree)
        knots, control_coeffs, k = tck
        print(f"s={s_value:6.1f}: {len(control_coeffs[0])} control points")
    except Exception as e:
        print(f"s={s_value:6.1f}: Error - {e}")

print("\n" + "="*80)
print("Observation: Standard interpolation only gives 7 control points")
print("="*80)

# Let me check if there's a pattern in the expected control points
print("\nAnalyzing expected control points:")
print("First CP:", expected_control_points[0], "vs first input:", on_curve_points[0])
print("Last CP:", expected_control_points[-1], "vs last input:", on_curve_points[-1])
print("\nFirst and last match exactly!")

# Check if middle points follow a pattern
print("\n" + "="*80)
print("Hypothesis: Maybe it's using OPEN uniform knot vector?")
print("="*80)
print("Open uniform: repeats first/last knot (degree+1) times")
print("For 9 control points, degree 3:")
print("Knot vector length should be: n + p + 2 = 8 + 3 + 2 = 13")
print("Format: [0,0,0,0, k1,k2,k3,k4,k5, 1,1,1,1]")

# Try to understand the knot vector from expected output
# For 9 control points with degree 3, we need 5 internal knots
n = 8  # n+1 = 9 control points
p = 3
num_internal = n - p  # = 5 internal knots

print(f"\nInternal knots needed: {num_internal}")
print("This would give knot vector:")
uniform_internal = np.linspace(0, 1, num_internal + 2)[1:-1]
knot_vec = np.concatenate([
    np.zeros(p + 1),
    uniform_internal,
    np.ones(p + 1)
])
print(f"Uniform: {knot_vec}")

# Let me try another approach - curve fitting with specified number of control points
print("\n" + "="*80)
print("Trying task='lsq' with specified number of control points")
print("="*80)

for task in [-1, 0, 1]:
    for t_param in [None, 9]:
        if t_param is None and task == -1:
            continue
        try:
            if t_param is None:
                tck, u = splprep(points_t, s=0, k=degree, task=task)
            else:
                tck, u = splprep(points_t, s=0, k=degree, task=task, t=t_param)
            knots, control_coeffs, k = tck
            print(f"task={task}, t={t_param}: {len(control_coeffs[0])} control points")
        except Exception as e:
            print(f"task={task}, t={t_param}: Error - {str(e)[:60]}")

print("\n" + "="*80)
print("Next approach: Manually construct the interpolation with 9 CPs")
print("="*80)

# Try manual approach: use least squares with 9 control points
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

# Try using BSpline basis directly
from scipy.interpolate import BSpline

# Chord length parameterization
params = compute_chord_params(on_curve_points)
print(f"Parameters: {params}")

# Create knot vector for 9 control points, degree 3
n_cp = 9
knot_vector = np.concatenate([
    np.zeros(degree + 1),
    np.linspace(0, 1, n_cp - degree + 1)[1:-1],
    np.ones(degree + 1)
])

print(f"\nKnot vector ({len(knot_vector)} elements):")
print(knot_vector)

print("\n" + "="*80)
print("Computing basis functions at parameter values")
print("="*80)

# Build design matrix
m = len(on_curve_points)  # number of data points
A = np.zeros((m, n_cp))

for i, u in enumerate(params):
    for j in range(n_cp):
        # Compute B_j,p(u) using scipy's BSpline
        c = np.zeros(n_cp)
        c[j] = 1.0
        spl = BSpline(knot_vector, c, degree)
        A[i, j] = spl(u)

print(f"Design matrix shape: {A.shape}")
print(f"Rank: {np.linalg.matrix_rank(A)}")

# Solve least squares for each dimension
control_x, _, _, _ = lstsq(A, on_curve_points[:, 0])
control_y, _, _, _ = lstsq(A, on_curve_points[:, 1])
control_z, _, _, _ = lstsq(A, on_curve_points[:, 2])

print("\n" + "="*80)
print("Computed control points:")
print("="*80)

computed_cps = np.column_stack([control_x, control_y, control_z])
for i, cp in enumerate(computed_cps):
    print(f"CP {i}: ({cp[0]:.4f}, {cp[1]:.4f}, {cp[2]:.4f})")

print("\n" + "="*80)
print("Comparison with expected:")
print("="*80)

max_diff = 0
for i in range(len(expected_control_points)):
    computed = computed_cps[i]
    expected = expected_control_points[i]
    diff = np.linalg.norm(computed - expected)
    max_diff = max(max_diff, diff)
    match = "✓" if diff < 1.0 else "✗"
    print(f"{match} CP {i}: diff={diff:.4f}")

print(f"\nMaximum difference: {max_diff:.4f}")

if max_diff < 10.0:
    print("\n✓ Close match! This might be the right algorithm.")
else:
    print("\n✗ Still not matching. Need to investigate further.")

# Verify interpolation
print("\n" + "="*80)
print("Verify curve passes through data points:")
print("="*80)

for i, (u, pt) in enumerate(zip(params, on_curve_points)):
    # Evaluate spline at u
    spl_x = BSpline(knot_vector, control_x, degree)
    spl_y = BSpline(knot_vector, control_y, degree)
    spl_z = BSpline(knot_vector, control_z, degree)

    eval_pt = np.array([spl_x(u), spl_y(u), spl_z(u)])
    diff = np.linalg.norm(eval_pt - pt)
    match = "✓" if diff < 1.0 else "✗"
    print(f"{match} Point {i}: diff={diff:.4f}")
