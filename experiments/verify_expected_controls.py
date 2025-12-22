#!/usr/bin/env python3
"""
Verify that the EXPECTED control points from issue #253
actually produce a curve that passes through the 7 fit points
"""

import numpy as np

def basis_function(i, p, u, knots):
    """Compute B-spline basis function N_{i,p}(u)"""
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    basis_values = np.zeros(p + 1)

    for j in range(p + 1):
        if knots[i+j] <= u < knots[i+j+1]:
            basis_values[j] = 1.0
        elif abs(u - knots[i+j+1]) < 1e-10 and i+j+1 == len(knots)-1:
            basis_values[j] = 1.0

    for k in range(1, p + 1):
        if basis_values[0] == 0.0:
            saved = 0.0
        else:
            u_right = knots[i+k]
            u_left = knots[i]
            if abs(u_right - u_left) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - u_left) / (u_right - u_left)) * basis_values[0]

        for j in range(p - k + 1):
            u_left = knots[i+j+1]
            u_right = knots[i+j+k+1]

            if basis_values[j+1] == 0.0:
                basis_values[j] = saved
                saved = 0.0
            else:
                if abs(u_right - u_left) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((u_right - u) / (u_right - u_left)) * basis_values[j+1]
                basis_values[j] = saved + temp

                if abs(knots[i+j+k+1] - knots[i+j+1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / (knots[i+j+k+1] - knots[i+j+1])) * basis_values[j+1]

    return basis_values[0]

def evaluate_nurbs(control_points, knots, degree, u):
    """Evaluate NURBS curve at parameter u"""
    point = np.zeros(3)

    for i in range(len(control_points)):
        basis = basis_function(i, degree, u, knots)
        point += basis * control_points[i]

    return point

def compute_parameters(points):
    """Compute parameter values using chord length parameterization"""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[-1] = 1.0

    if n == 2:
        return params

    total_length = 0.0
    for i in range(n - 1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    if total_length > 0.0001:
        params = params / total_length
    else:
        params = np.linspace(0, 1, n)

    return params

def generate_knot_vector(n, p, params):
    """Generate knot vector using averaging method"""
    m = n + p + 1
    num_knots = m + 1
    knots = np.zeros(num_knots)

    for i in range(p + 1):
        knots[i] = 0.0

    for j in range(1, n - p + 1):
        knots[j + p] = np.mean(params[j:j+p])

    for i in range(n + 1, num_knots):
        knots[i] = 1.0

    return knots

# Fit points from issue
fit_points = np.array([
    [1583.2136549257, 417.836639195, 0],
    [2346.3909069169, 988.9560396917, 0],
    [1396.2099574179, 1772.3499076297, 0],
    [-392.9605538726, 1716.754213776, 0],
    [-41.2801529313, 2784.8206166348, 0],
    [1717.1218517754, 2954.1482170881, 0],
    [3449.4734564123, 2146.5858149265, 0]
])

# Expected control points from issue
expected_control_points = np.array([
    [1583.2137, 417.8366, 0],
    [1943.9619, 588.3078, 0],
    [2770.7705, 979.0151, 0],
    [1225.7225, 2260.4551, 0],
    [-771.0874, 1052.6822, 0],
    [-50.7662, 3342.0538, 0],
    [1877.21, 3020.2007, 0],
    [2911.8082, 2445.335, 0],
    [3449.4735, 2146.5858, 0]
])

degree = 3
n = len(expected_control_points) - 1  # n = 8

# Generate parameters and knot vector
params = compute_parameters(fit_points)
knots = generate_knot_vector(n, degree, params)

print("=" * 70)
print("Verifying EXPECTED control points from Issue #253")
print("=" * 70)
print()
print(f"Fit points: {len(fit_points)}")
print(f"Control points: {len(expected_control_points)}")
print(f"Degree: {degree}")
print()
print("Parameters (chord length):", params)
print("Knot vector:", knots)
print()
print("=" * 70)
print("Evaluating curve at fit point parameters:")
print("=" * 70)
print()

max_error = 0.0

for i, (fp, param) in enumerate(zip(fit_points, params)):
    curve_point = evaluate_nurbs(expected_control_points, knots, degree, param)
    error = np.linalg.norm(curve_point - fp)
    max_error = max(max_error, error)
    status = "✅" if error < 1.0 else "❌"

    print(f"p{i+1}: param={param:.6f}")
    print(f"    Expected: ({fp[0]:.4f}, {fp[1]:.4f}, {fp[2]:.4f})")
    print(f"    Got:      ({curve_point[0]:.4f}, {curve_point[1]:.4f}, {curve_point[2]:.4f})")
    print(f"    Error: {error:.4f} {status}")
    print()

print("=" * 70)
print(f"Maximum interpolation error: {max_error:.4f}")
print(f"Status: {'✅ PASS - Curve passes through all fit points!' if max_error < 1.0 else '❌ FAIL - Curve does NOT pass through fit points'}")
print("=" * 70)
