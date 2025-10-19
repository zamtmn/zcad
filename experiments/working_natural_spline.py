#!/usr/bin/env python3
"""
Working natural spline implementation using scipy as reference
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

# Use scipy to get the correct answer
spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')
spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='natural')

print("=" * 70)
print("SCIPY NATURAL SPLINE (REFERENCE)")
print("=" * 70)
print()

print("Control points (X):")
for i, cx in enumerate(spl_x.c):
    print(f"  CP[{i}]: X={cx:.6f}")
print()

print("Control points (Y):")
for i, cy in enumerate(spl_y.c):
    print(f"  CP[{i}]: Y={cy:.6f}")
print()

print("Knot vector:")
print(spl_x.t)
print()

# Now let's use scipy's BSpline class to manually construct the same spline
# This will help us understand what scipy is doing

# The key is to use scipy's internal collocation matrix builder
from scipy.interpolate._bsplines import _not_a_knot, _make_interp_spline_legacyknots

#print("Scipy source code approach:")
#print("scipy uses _make_interp_spline which internally calls _not_a_knot or natural BC setup")
#print()

# Let's try using scipy's lower-level functions
# Actually, let's just verify our knot vector and param calculation are correct

m = len(params) - 1
n = m + 2
numControlPoints = n + 1

print(f"m = {m}, n = {n}, numControlPoints = {numControlPoints}")
print()

# Manual knot vector (same as scipy)
knots_manual = np.concatenate([
    np.zeros(degree + 1),
    params[1:m],
    np.ones(degree + 1)
])

print("Manual knot vector:")
print(knots_manual)
print()

print("Scipy knot vector:")
print(spl_x.t)
print()

print("Match:", np.allclose(knots_manual, spl_x.t))
print()

# The key question: How does scipy implement natural boundary conditions?
# Let's examine the actual implementation by looking at the control points

# For natural splines, scipy adds rows for second derivative = 0
# But HOW does it compute the second derivative coefficients?

# Let me try to reverse-engineer by evaluating the spline's second derivative at boundaries
t_start = params[0]
t_end = params[m]

print(f"Evaluating second derivative at t_start={t_start} and t_end={t_end}:")
print()

# Scipy's BSpline class can compute derivatives
deriv2_start_x = spl_x(t_start, nu=2)
deriv2_end_x = spl_x(t_end, nu=2)

print(f"S''_x({t_start}) = {deriv2_start_x:.9f} (should be ≈ 0)")
print(f"S''_x({t_end}) = {deriv2_end_x:.9f} (should be ≈ 0)")
print()

# Now let's try to figure out how scipy sets up the linear system
# by looking at what equations it solves

print("=" * 70)
print("UNDERSTANDING SCIPY'S APPROACH")
print("=" * 70)
print()

# Scipy uses a collocation matrix approach
# For 'natural' BC with degree k=3:
# - We have m+1 data points
# - We want n+1 = m+3 control points (2 extra for boundary conditions)
# - This requires m+1 interpolation equations + 2 boundary equations

# The boundary equations for natural splines are:
# S''(t_0) = 0  and  S''(t_m) = 0

# For a B-spline, S''(t) = sum_{i=0}^{n} c_i * N''_{i,k}(t)

# So the boundary equations become:
# sum_{i=0}^{n} c_i * N''_{i,k}(t_0) = 0
# sum_{i=0}^{n} c_i * N''_{i,k}(t_m) = 0

# The question is: how to compute N''_{i,k}(t)?

# For B-splines, the derivative formula is:
# N'_{i,k}(t) = k/(u_{i+k} - u_i) * N_{i,k-1}(t) - k/(u_{i+k+1} - u_{i+1}) * N_{i+1,k-1}(t)

# And the second derivative is:
# N''_{i,k}(t) = d/dt[N'_{i,k}(t)]

print("The correct implementation requires computing analytical derivatives")
print("of B-spline basis functions, not finite differences.")
print()

print("This is implemented in scipy.interpolate._bsplines module")
print("using the recursive derivative formula for B-splines.")
print()

print("=" * 70)
print("CONCLUSION")
print("=" * 70)
print()
print("The Pascal implementation has a bug:")
print("1. It uses finite differences to approximate second derivatives")
print("2. This is numerically unstable, especially at boundaries")
print("3. The correct approach is to use the analytical derivative formula")
print()
print("To fix this, we need to:")
print("1. Implement the analytical first derivative of B-spline basis")
print("2. Apply it twice to get the second derivative")
print("3. Use these values in the boundary condition rows")
print()

# Let me try to implement the analytical derivative
def bspline_basis_derivative(i, k, t, knots, deriv=1):
    """
    Compute the derivative of B-spline basis function using recursive formula

    N'_{i,k}(t) = k/(u_{i+k} - u_i) * N_{i,k-1}(t) - k/(u_{i+k+1} - u_{i+1}) * N_{i+1,k-1}(t)
    """
    if deriv == 0:
        # Base case: just evaluate the basis function
        return BSpline.basis_element(knots[i:i+k+2], extrapolate=False)(t) or 0.0

    if k == 0:
        # Derivative of a step function is 0 (or undefined)
        return 0.0

    # Recursive formula
    denom1 = knots[i+k] - knots[i]
    denom2 = knots[i+k+1] - knots[i+1]

    term1 = 0.0
    if abs(denom1) > 1e-10:
        term1 = k / denom1 * bspline_basis_derivative(i, k-1, t, knots, deriv-1)

    term2 = 0.0
    if abs(denom2) > 1e-10:
        term2 = k / denom2 * bspline_basis_derivative(i+1, k-1, t, knots, deriv-1)

    return term1 - term2

print("Testing analytical second derivative:")
print()

for i in range(numControlPoints):
    d2 = bspline_basis_derivative(i, degree, t_start, spl_x.t, deriv=2)
    print(f"  N''_{i},{degree}({t_start}) = {d2:.6f}")

print()

# Build the collocation matrix using analytical derivatives
A = np.zeros((numControlPoints, numControlPoints))
b_x = np.zeros(numControlPoints)

# Interpolation rows
for k in range(len(params)):
    b_x[k] = x[k]
    for i in range(numControlPoints):
        A[k, i] = bspline_basis_derivative(i, degree, params[k], spl_x.t, deriv=0)

# Natural BC rows
for i in range(numControlPoints):
    A[len(params), i] = bspline_basis_derivative(i, degree, t_start, spl_x.t, deriv=2)
b_x[len(params)] = 0.0

for i in range(numControlPoints):
    A[len(params)+1, i] = bspline_basis_derivative(i, degree, t_end, spl_x.t, deriv=2)
b_x[len(params)+1] = 0.0

print("=" * 70)
print("SOLVING WITH ANALYTICAL DERIVATIVES")
print("=" * 70)
print()

print("Matrix condition number:", np.linalg.cond(A))
print()

try:
    c_x = np.linalg.solve(A, b_x)

    print("Manual control points (X):")
    for i, cx in enumerate(c_x):
        print(f"  CP[{i}]: X={cx:.6f}")
    print()

    print("Scipy control points (X):")
    for i, cx in enumerate(spl_x.c):
        print(f"  CP[{i}]: X={cx:.6f}")
    print()

    print("Difference:")
    for i in range(numControlPoints):
        diff = abs(c_x[i] - spl_x.c[i])
        print(f"  CP[{i}]: {diff:.9f}")
    print()

    max_diff = np.max(np.abs(c_x - spl_x.c))
    print(f"Maximum difference: {max_diff:.9f}")

    if max_diff < 0.001:
        print("\n✓ SUCCESS! Analytical derivative approach works!")
    else:
        print("\n✗ Still not matching")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
