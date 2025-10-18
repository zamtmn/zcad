#!/usr/bin/env python3
"""
Verify that scipy natural spline matches expected output
"""

import numpy as np
from scipy import interpolate

# Input data from issue #275
on_curve_points = [
    (1583.213655, 417.836639, 0.000000),
    (2346.390907, 988.956040, 0.000000),
    (1396.209957, 1772.349908, 0.000000),
    (-392.960554, 1716.754214, 0.000000),
    (-41.280153, 2784.820617, 0.000000),
    (1717.121852, 2954.148217, 0.000000),
    (3449.473456, 2146.585815, 0.000000),
]

# Expected control points from "another program"
expected_control_points = [
    (1583.213700, 417.836600, 0.000000),
    (1943.961900, 588.307800, 0.000000),
    (2770.770500, 979.015100, 0.000000),
    (1225.722500, 2260.455100, 0.000000),
    (-771.087400, 1052.682200, 0.000000),
    (-50.766200, 3342.053800, 0.000000),
    (1877.210000, 3020.200700, 0.000000),
    (2911.808200, 2445.335000, 0.000000),
    (3449.473500, 2146.585800, 0.000000),
]

# Expected knots from issue output
expected_knots = [0.000000, 0.000000, 0.000000, 0.000000, 0.108603, 0.248909,
                  0.452854, 0.580969, 0.782236, 1.000000, 1.000000, 1.000000, 1.000000]

degree = 3

# Compute chord length parameterization
import math
def compute_chord_params(points):
    n = len(points)
    params = np.zeros(n)

    for i in range(1, n):
        dist = math.sqrt(
            (points[i][0] - points[i-1][0])**2 +
            (points[i][1] - points[i-1][1])**2 +
            (points[i][2] - points[i-1][2])**2
        )
        params[i] = params[i-1] + dist

    if params[-1] > 0:
        params = params / params[-1]

    return params

params = compute_chord_params(on_curve_points)

x = np.array([p[0] for p in on_curve_points])
y = np.array([p[1] for p in on_curve_points])
z = np.array([p[2] for p in on_curve_points])

# Use natural spline
spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')
spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='natural')
spl_z = interpolate.make_interp_spline(params, z, k=degree, bc_type='natural')

print("=" * 60)
print("COMPARISON: Scipy natural spline vs Expected output")
print("=" * 60)
print()

print("Control Points Comparison:")
print(f"{'Index':<6} {'Expected X':<15} {'Scipy X':<15} {'Diff X':<12} | {'Expected Y':<15} {'Scipy Y':<15} {'Diff Y':<12}")
print("-" * 120)

for i in range(len(expected_control_points)):
    exp_x, exp_y, exp_z = expected_control_points[i]
    scipy_x = spl_x.c[i]
    scipy_y = spl_y.c[i]
    diff_x = abs(exp_x - scipy_x)
    diff_y = abs(exp_y - scipy_y)

    print(f"{i:<6} {exp_x:<15.6f} {scipy_x:<15.6f} {diff_x:<12.6f} | {exp_y:<15.6f} {scipy_y:<15.6f} {diff_y:<12.6f}")

print()
print("Knot Vector Comparison:")
print(f"{'Index':<6} {'Expected':<15} {'Scipy':<15} {'Diff':<12}")
print("-" * 50)

scipy_knots = spl_x.t
for i in range(len(expected_knots)):
    exp_k = expected_knots[i]
    scipy_k = scipy_knots[i]
    diff = abs(exp_k - scipy_k)

    print(f"{i:<6} {exp_k:<15.6f} {scipy_k:<15.6f} {diff:<12.9f}")

print()
print("=" * 60)
print("CONCLUSION:")
print("=" * 60)
max_diff_x = max(abs(expected_control_points[i][0] - spl_x.c[i]) for i in range(len(expected_control_points)))
max_diff_y = max(abs(expected_control_points[i][1] - spl_y.c[i]) for i in range(len(expected_control_points)))
max_diff_knots = max(abs(expected_knots[i] - scipy_knots[i]) for i in range(len(expected_knots)))

print(f"Maximum difference in X coordinates: {max_diff_x:.9f}")
print(f"Maximum difference in Y coordinates: {max_diff_y:.9f}")
print(f"Maximum difference in knot values: {max_diff_knots:.9f}")
print()

if max_diff_x < 0.001 and max_diff_y < 0.001 and max_diff_knots < 0.000001:
    print("✓ MATCH! The expected output uses natural spline interpolation")
    print("  with 'clamped' boundary conditions (bc_type='natural' in scipy)")
else:
    print("✗ NO MATCH - Further investigation needed")
