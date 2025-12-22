#!/usr/bin/env python3
"""
Analysis of issue #275 - ConvertOnCurvePointsToControlPointsArray bug
"""

import numpy as np
from scipy import interpolate
import math

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

degree = 3
num_points = len(on_curve_points)
print(f"Number of on-curve points: {num_points}")
print(f"Number of expected control points: {len(expected_control_points)}")
print(f"Degree: {degree}")
print()

# Compute chord length parameterization
def compute_chord_params(points):
    """Compute parameter values using chord length"""
    n = len(points)
    params = np.zeros(n)

    for i in range(1, n):
        dist = math.sqrt(
            (points[i][0] - points[i-1][0])**2 +
            (points[i][1] - points[i-1][1])**2 +
            (points[i][2] - points[i-1][2])**2
        )
        params[i] = params[i-1] + dist

    # Normalize to [0, 1]
    if params[-1] > 0:
        params = params / params[-1]

    return params

params = compute_chord_params(on_curve_points)
print("Parameter values (chord length):")
for i, p in enumerate(params):
    print(f"  t[{i}] = {p:.6f}")
print()

# Generate knot vector using averaging method (Algorithm A9.1)
# For m+1 data points, n=m control points, degree p
# Knot vector has n+p+2 elements
m = num_points - 1  # m = 6
n = m               # n = 6 (same as m for standard interpolation)
p = degree          # p = 3

num_knots = n + p + 2  # 6 + 3 + 2 = 11
knots = np.zeros(num_knots)

# Clamped: first p+1 knots are 0
for i in range(p + 1):
    knots[i] = 0.0

# Internal knots: average p consecutive parameter values
# u_{j+p} = (1/p) * sum_{i=j}^{j+p-1} t_i for j = 1, 2, ..., n-p
for j in range(1, n - p + 1):
    knots[j + p] = sum(params[j:j+p]) / p

# Clamped: last p+1 knots are 1
for i in range(n + 1, n + p + 2):
    knots[i] = 1.0

print(f"Knot vector (length={len(knots)}):")
print(f"  {knots}")
print()

# Try using scipy to interpolate
print("Testing with scipy.interpolate.make_interp_spline:")
print("  Using bc_type='not-a-knot' (standard interpolation):")

x = np.array([p[0] for p in on_curve_points])
y = np.array([p[1] for p in on_curve_points])

try:
    # Standard interpolation (not-a-knot)
    spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='not-a-knot')
    spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='not-a-knot')

    print(f"    Control points (X): {spl_x.c}")
    print(f"    Control points (Y): {spl_y.c}")
    print(f"    Knots: {spl_x.t}")
    print()
except Exception as e:
    print(f"    Error: {e}")
    print()

print("  Using bc_type='clamped' (clamped boundary conditions):")
try:
    # Clamped interpolation
    spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='clamped')
    spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='clamped')

    print(f"    Control points (X): {spl_x.c}")
    print(f"    Control points (Y): {spl_y.c}")
    print(f"    Knots: {spl_x.t}")
    print()
except Exception as e:
    print(f"    Error: {e}")
    print()

print("  Using bc_type='natural' (natural boundary conditions):")
try:
    # Natural interpolation
    spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')
    spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='natural')

    print(f"    Number of control points: {len(spl_x.c)}")
    print(f"    Control points (X): {spl_x.c}")
    print(f"    Control points (Y): {spl_y.c}")
    print(f"    Knots: {spl_x.t}")
    print()
except Exception as e:
    print(f"    Error: {e}")
    print()

print("\nConclusion:")
print("The 'other program' likely uses Algorithm A9.1 from The NURBS Book")
print("which is STANDARD B-spline curve interpolation, not natural splines.")
print(f"It produces {num_points} control points from {num_points} data points.")
