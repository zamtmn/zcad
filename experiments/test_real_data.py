#!/usr/bin/env python3
"""
Test NURBS interpolation with REAL data from issue #253
"""

import numpy as np
import sys

# Reuse functions from test_issue253_9controls_v2.py
sys.path.append('/tmp/gh-issue-solver-1760734786899/experiments')

def basis_function(i, p, u, knots):
    """Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion"""
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

def interpolate_nurbs(fit_points, degree=3):
    """NURBS spline interpolation using n = m + p - 1 formula"""
    num_fit = len(fit_points)

    m = num_fit - 1
    n = m + degree - 1
    num_control = n + 1

    # Step 1: Compute parameters
    params = compute_parameters(fit_points)

    # Step 2: Generate knot vector
    knots = generate_knot_vector(n, degree, params)

    # Step 3: Fix control points
    control_points = np.zeros((num_control, 3))  # 3D points

    control_points[0] = fit_points[0]
    control_points[-1] = fit_points[-1]

    # Fix P1 and P(n-1) using tangent estimates
    alpha = params[1] / 3.0
    control_points[1] = control_points[0] + alpha * (fit_points[1] - fit_points[0])

    beta = (1.0 - params[m-1]) / 3.0
    control_points[n-1] = control_points[n] - beta * (fit_points[m] - fit_points[m-1])

    # Step 4: Solve for interior control points P2..P(n-2)
    num_interior_fit = num_fit - 2
    num_interior_ctrl = num_control - 4

    A = np.zeros((num_interior_fit, num_interior_ctrl))
    b = np.zeros((num_interior_fit, 3))

    for k in range(num_interior_fit):
        fit_idx = k + 1

        b[k] = fit_points[fit_idx].copy()

        # Subtract contributions from fixed control points
        basis = basis_function(0, degree, params[fit_idx], knots)
        b[k] -= basis * control_points[0]

        basis = basis_function(1, degree, params[fit_idx], knots)
        b[k] -= basis * control_points[1]

        basis = basis_function(n-1, degree, params[fit_idx], knots)
        b[k] -= basis * control_points[n-1]

        basis = basis_function(n, degree, params[fit_idx], knots)
        b[k] -= basis * control_points[n]

        # Matrix for interior control points P2..P(n-2)
        for j in range(num_interior_ctrl):
            ctrl_idx = j + 2
            A[k, j] = basis_function(ctrl_idx, degree, params[fit_idx], knots)

    # Solve for interior control points
    interior_points = np.linalg.solve(A, b)
    control_points[2:n-1] = interior_points

    return control_points, knots, params

# REAL DATA from issue #253
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

print("=" * 70)
print("NURBS Interpolation Test with REAL DATA from Issue #253")
print("=" * 70)

control_points, knots, params = interpolate_nurbs(fit_points, degree=3)

print(f"\nComputed {len(control_points)} control points:")
print()

max_error = 0.0
for i in range(len(control_points)):
    cp = control_points[i]
    print(f"P{i}: ({cp[0]:.4f}, {cp[1]:.4f}, {cp[2]:.4f})")

    if i < len(expected_control_points):
        exp = expected_control_points[i]
        error = np.linalg.norm(cp - exp)
        max_error = max(max_error, error)
        status = "✅" if error < 1.0 else "❌"
        print(f"    Expected: ({exp[0]:.4f}, {exp[1]:.4f}, {exp[2]:.4f}) - Error: {error:.4f} {status}")

print()
print(f"Maximum error: {max_error:.4f}")
print(f"Status: {'✅ PASS' if max_error < 1.0 else '❌ FAIL'}")

print()
print("Parameters:", params)
print("Knot vector:", knots)
