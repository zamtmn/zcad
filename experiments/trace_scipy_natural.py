#!/usr/bin/env python3
"""
Detailed trace of scipy natural spline to understand the algorithm
"""

import numpy as np
from scipy import interpolate
from scipy.interpolate import BSpline
import math

# Input data
on_curve_points = [
    (1583.213655, 417.836639, 0.000000),
    (2346.390907, 988.956040, 0.000000),
    (1396.209957, 1772.349908, 0.000000),
    (-392.960554, 1716.754214, 0.000000),
    (-41.280153, 2784.820617, 0.000000),
    (1717.121852, 2954.148217, 0.000000),
    (3449.473456, 2146.585815, 0.000000),
]

degree = 3

# Compute chord length parameters
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

print("=" * 70)
print("TRACING SCIPY NATURAL SPLINE ALGORITHM")
print("=" * 70)
print()

# Create natural spline
spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')

print(f"Input: {len(x)} data points")
print(f"Output: {len(spl_x.c)} control points")
print(f"Degree: {degree}")
print()

print("Knot vector:")
print(spl_x.t)
print()

print("Control points (X):")
print(spl_x.c)
print()

# Manual implementation using basis functions
from scipy.interpolate import splev, BSpline

m = len(params) - 1  # m = 6
n = m + 2  # n = 8 for natural spline
numControlPoints = n + 1  # 9

print(f"m = {m}, n = {n}, numControlPoints = {numControlPoints}")
print()

# Build the knot vector (same as scipy)
knots = np.zeros(n + degree + 2)
for i in range(degree + 1):
    knots[i] = 0.0
for i in range(1, m):
    knots[degree + i] = params[i]
for i in range(degree + 1):
    knots[n + 1 + i] = 1.0

print("Knot vector (manual):")
print(knots)
print()

# Compute basis functions at each parameter
def basis_func(i, p, u, knots):
    """Compute N_i,p(u) using Cox-de Boor recursion"""
    return BSpline.basis_element(knots[i:i+p+2], extrapolate=False)(u)

print("=" * 70)
print("BUILDING THE MATRIX SYSTEM")
print("=" * 70)
print()

# Build interpolation matrix
numEq = len(params) + 2  # m+1 interpolation + 2 boundary conditions
A = np.zeros((numEq, numControlPoints))
b_x = np.zeros(numEq)

print(f"Matrix size: {numEq} x {numControlPoints}")
print()

# Interpolation constraints
for k in range(len(params)):
    b_x[k] = x[k]

    for i in range(numControlPoints):
        N = BSpline.basis_element(knots[i:i+degree+2], extrapolate=False)(params[k])
        if N is None:
            N = 0.0
        A[k, i] = N

    print(f"Row {k} (interpolation at t={params[k]:.6f}):")
    print(f"  b[{k}] = {b_x[k]:.6f}")
    print(f"  Basis values: {A[k, :]}")
    print()

# Natural boundary conditions: second derivative = 0
# For second derivative, we need to use the second derivative of basis functions

def basis_deriv2(i, p, u, knots):
    """Compute second derivative of N_i,p(u)"""
    # Use numerical differentiation
    h = 1e-6
    u_plus = min(u + h, 1.0)
    u_minus = max(u - h, 0.0)

    N_plus = BSpline.basis_element(knots[i:i+p+2], extrapolate=False)(u_plus)
    N_center = BSpline.basis_element(knots[i:i+p+2], extrapolate=False)(u)
    N_minus = BSpline.basis_element(knots[i:i+p+2], extrapolate=False)(u_minus)

    if N_plus is None:
        N_plus = 0.0
    if N_center is None:
        N_center = 0.0
    if N_minus is None:
        N_minus = 0.0

    return (N_plus - 2.0 * N_center + N_minus) / (h * h)

# Boundary condition at start (t=0)
print(f"Row {len(params)} (natural BC at t={params[0]:.6f}):")
for i in range(numControlPoints):
    A[len(params), i] = basis_deriv2(i, degree, params[0], knots)
b_x[len(params)] = 0.0
print(f"  b[{len(params)}] = {b_x[len(params)]:.6f}")
print(f"  Second derivative basis values: {A[len(params), :]}")
print()

# Boundary condition at end (t=1)
print(f"Row {len(params)+1} (natural BC at t={params[m]:.6f}):")
for i in range(numControlPoints):
    A[len(params)+1, i] = basis_deriv2(i, degree, params[m], knots)
b_x[len(params)+1] = 0.0
print(f"  b[{len(params)+1}] = {b_x[len(params)+1]:.6f}")
print(f"  Second derivative basis values: {A[len(params)+1, :]}")
print()

# Solve the system
print("=" * 70)
print("SOLVING THE SYSTEM")
print("=" * 70)
print()

control_x = np.linalg.solve(A, b_x)

print("Control points (X) from manual calculation:")
print(control_x)
print()

print("Control points (X) from scipy:")
print(spl_x.c)
print()

print("Difference:")
print(control_x - spl_x.c)
print()

max_diff = np.max(np.abs(control_x - spl_x.c))
print(f"Maximum difference: {max_diff:.9f}")

if max_diff < 0.001:
    print("\n✓ Manual calculation matches scipy!")
else:
    print("\n✗ Manual calculation does NOT match scipy")
