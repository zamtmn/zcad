#!/usr/bin/env python3
"""
Understand how scipy implements natural splines by examining the code
"""

import numpy as np
from scipy import interpolate

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

degree = 3

print("=" * 70)
print("UNDERSTANDING SCIPY'S NATURAL SPLINE IMPLEMENTATION")
print("=" * 70)
print()

# Create the spline
spl = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')

print(f"Number of data points: {len(params)}")
print(f"Number of control points: {len(spl.c)}")
print(f"Degree: {degree}")
print(f"Knot vector length: {len(spl.t)}")
print()

print("Parameters:")
print(params)
print()

print("Knot vector:")
print(spl.t)
print()

print("Control points:")
print(spl.c)
print()

# Let's look at scipy's approach - it uses _not_a_knot or _natural from _bspl.py
# The key is that natural boundary conditions mean:
# S''(x[0]) = 0 and S''(x[-1]) = 0

# For a cubic spline (k=3), the second derivative is a linear spline (k=1)
# At clamped boundaries, we need the second derivative to be zero

# Let me manually implement this using the scipy approach
print("=" * 70)
print("MANUAL IMPLEMENTATION USING SCIPY'S APPROACH")
print("=" * 70)
print()

# For natural splines with k=3:
# We have m+1 data points and want n+1 = m+3 control points
# This means we add 2 equations for the boundary conditions

m = len(params) - 1
n = m + 2
n_ctrl = n + 1

print(f"m = {m}, n = {n}, n_ctrl = {n_ctrl}")
print()

# Build knot vector: [0]*4 + internal_knots + [1]*4
# Internal knots are params[1] through params[m-1]
knots = np.concatenate([
    np.zeros(degree + 1),
    params[1:m],
    np.ones(degree + 1)
])

print(f"Knot vector (length={len(knots)}):")
print(knots)
print()

# Build the collocation matrix
from scipy.interpolate import BSpline

# First, let's use scipy's internal functions to build the matrix
# The key is using _collocate from _bspl.py

# For natural BC, scipy adds constraints on the second derivative
# Let's try to replicate this

A = np.zeros((n_ctrl, n_ctrl))
b = np.zeros(n_ctrl)

# Interpolation constraints (first m+1 rows)
for i in range(len(params)):
    b[i] = x[i]

    for j in range(n_ctrl):
        # Evaluate basis function N_j,k(params[i])
        N = BSpline.basis_element(knots[j:j+degree+2], extrapolate=False)(params[i])
        if N is not None:
            A[i, j] = N

print("Interpolation matrix (first 7 rows):")
print(A[:7, :])
print()

# Natural boundary conditions (last 2 rows)
# S''(t_0) = 0 and S''(t_m) = 0

# For a B-spline curve, the second derivative is:
# S''(t) = sum_{i=0}^{n} c_i * N''_{i,k}(t)

# We need to compute N''_{i,k}(t) for each basis function

def bspline_basis_deriv(i, k, t, knots, deriv=0):
    """
    Compute the derivative of a B-spline basis function.

    Using the recursive formula for derivatives:
    N'_{i,k}(t) = k/(u_{i+k} - u_i) * N_{i,k-1}(t) - k/(u_{i+k+1} - u_{i+1}) * N_{i+1,k-1}(t)
    """
    if deriv == 0:
        N = BSpline.basis_element(knots[i:i+k+2], extrapolate=False)(t)
        return N if N is not None else 0.0

    if k == 0:
        return 0.0

    # First term
    denom1 = knots[i+k] - knots[i]
    if abs(denom1) > 1e-10:
        term1 = k / denom1 * bspline_basis_deriv(i, k-1, t, knots, deriv-1)
    else:
        term1 = 0.0

    # Second term
    denom2 = knots[i+k+1] - knots[i+1]
    if abs(denom2) > 1e-10:
        term2 = k / denom2 * bspline_basis_deriv(i+1, k-1, t, knots, deriv-1)
    else:
        term2 = 0.0

    return term1 - term2

# Compute second derivatives at boundaries
t_start = params[0]
t_end = params[m]

print(f"Computing second derivatives at t_start={t_start} and t_end={t_end}")
print()

# Row for start boundary
for j in range(n_ctrl):
    N_deriv2 = bspline_basis_deriv(j, degree, t_start, knots, deriv=2)
    A[len(params), j] = N_deriv2

b[len(params)] = 0.0

print(f"Natural BC at start (row {len(params)}):")
print(A[len(params), :])
print()

# Row for end boundary
for j in range(n_ctrl):
    N_deriv2 = bspline_basis_deriv(j, degree, t_end, knots, deriv=2)
    A[len(params)+1, j] = N_deriv2

b[len(params)+1] = 0.0

print(f"Natural BC at end (row {len(params)+1}):")
print(A[len(params)+1, :])
print()

# Solve
try:
    c_manual = np.linalg.solve(A, b)
    print("Manual control points:")
    print(c_manual)
    print()

    print("Scipy control points:")
    print(spl.c)
    print()

    print("Difference:")
    print(np.abs(c_manual - spl.c))
    print()

    max_diff = np.max(np.abs(c_manual - spl.c))
    print(f"Maximum difference: {max_diff:.9f}")

    if max_diff < 0.001:
        print("\n✓ SUCCESS! Manual calculation matches scipy!")
    else:
        print("\n✗ Manual calculation does NOT match scipy")
except Exception as e:
    print(f"Error solving system: {e}")
