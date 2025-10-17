#!/usr/bin/env python3
"""
Test script for NURBS spline interpolation with n=m+p-1 formula
For 7 fit points with degree 3, we should get 9 control points
"""

import numpy as np
import matplotlib.pyplot as plt

def basis_function(i, p, u, knots):
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion
    """
    # Handle endpoint case
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    # Degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    # Use triangular table
    basis_values = np.zeros(p + 1)

    # Initialize degree 0
    for j in range(p + 1):
        if knots[i+j] <= u < knots[i+j+1]:
            basis_values[j] = 1.0
        elif abs(u - knots[i+j+1]) < 1e-10 and i+j+1 == len(knots)-1:
            basis_values[j] = 1.0

    # Build up to degree p
    for k in range(1, p + 1):
        # Left end
        if basis_values[0] == 0.0:
            saved = 0.0
        else:
            u_right = knots[i+k]
            u_left = knots[i]
            if abs(u_right - u_left) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - u_left) / (u_right - u_left)) * basis_values[0]

        # Middle terms
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
    """
    Compute parameter values using chord length parameterization
    """
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[-1] = 1.0

    if n == 2:
        return params

    # Calculate total chord length
    total_length = 0.0
    for i in range(n - 1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize
    if total_length > 0.0001:
        params = params / total_length
    else:
        params = np.linspace(0, 1, n)

    return params

def generate_knot_vector(n, p, params):
    """
    Generate knot vector using averaging method
    n: index of last control point (numControlPoints - 1)
    p: degree
    params: parameter values for fit points
    """
    m = n + p + 1
    num_knots = m + 1
    knots = np.zeros(num_knots)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameter values
    # Formula: u_{j+p} = (1/p) * sum_{i=j}^{j+p-1} t_i
    # for j = 1, 2, ..., n-p
    for j in range(1, n - p + 1):
        knots[j + p] = np.mean(params[j:j+p])

    # Clamped: repeat 1 (p+1) times at end
    for i in range(n + 1, num_knots):
        knots[i] = 1.0

    return knots

def interpolate_nurbs(fit_points, degree=3):
    """
    NURBS spline interpolation using n = m + p - 1 formula
    For m+1 fit points with degree p: n = m + p - 1, so n+1 = m + p control points
    """
    num_fit = len(fit_points)

    # Calculate number of control points
    m = num_fit - 1  # index of last fit point
    n = m + degree - 1  # index of last control point
    num_control = n + 1  # total control points

    print(f"Number of fit points: {num_fit}")
    print(f"m (index of last fit point): {m}")
    print(f"degree (p): {degree}")
    print(f"n = m + p - 1 = {m} + {degree} - 1 = {n}")
    print(f"Number of control points (n+1): {num_control}")

    # Step 1: Compute parameters
    params = compute_parameters(fit_points)
    print(f"Parameters: {params}")

    # Step 2: Generate knot vector
    knots = generate_knot_vector(n, degree, params)
    print(f"Knot vector (length {len(knots)}): {knots}")

    # Step 3: Build linear system with fixed endpoints
    # Control points: P0 (fixed), P1..P7 (solve), P8 (fixed)
    # For 7 fit points: 7 equations, 7 unknowns (P1..P7)

    control_points = np.zeros((num_control, 2))

    # Fix endpoints
    control_points[0] = fit_points[0]
    control_points[-1] = fit_points[-1]

    # Build system for interior control points
    # Number of interior control points = num_control - 2
    num_interior = num_control - 2
    A = np.zeros((num_fit, num_interior))
    b = np.zeros((num_fit, 2))

    for k in range(num_fit):
        # Right-hand side: fit point minus contributions from fixed endpoints
        b[k] = fit_points[k].copy()

        # Subtract contribution from P0
        basis = basis_function(0, degree, params[k], knots)
        b[k] -= basis * control_points[0]

        # Subtract contribution from P[num_control-1]
        basis = basis_function(num_control - 1, degree, params[k], knots)
        b[k] -= basis * control_points[-1]

        # Matrix for interior control points P1..P(num_control-2)
        for i in range(num_interior):
            j = i + 1  # Control point index (P1, P2, ..., P7 for 9 control points)
            A[k, i] = basis_function(j, degree, params[k], knots)

    print(f"\nBasis matrix A (shape {A.shape}):")
    print(A)
    print(f"\nRHS b (shape {b.shape}):")
    print(b)

    # Solve for interior control points
    try:
        interior_points = np.linalg.solve(A, b)
        control_points[1:-1] = interior_points
    except np.linalg.LinAlgError as e:
        print(f"Error solving linear system: {e}")
        print(f"Matrix condition number: {np.linalg.cond(A)}")
        return None, None

    return control_points, knots

def evaluate_nurbs(control_points, knots, degree, u):
    """
    Evaluate NURBS curve at parameter u
    """
    n = len(control_points) - 1
    point = np.zeros(2)

    for i in range(len(control_points)):
        basis = basis_function(i, degree, u, knots)
        point += basis * control_points[i]

    return point

# Test with 7 fit points
fit_points = np.array([
    [0.0, 0.0],   # p1
    [1.0, 1.0],   # p2
    [2.0, 2.5],   # p3
    [2.5, 1.5],   # p4
    [2.0, 0.5],   # p5
    [3.0, 1.0],   # p6
    [4.0, 0.0],   # p7
])

print("=" * 60)
print("NURBS Interpolation Test: n = m + p - 1 formula")
print("=" * 60)

control_points, knots = interpolate_nurbs(fit_points, degree=3)

if control_points is not None:
    print(f"\nControl points ({len(control_points)}):")
    for i, cp in enumerate(control_points):
        print(f"  P{i}: ({cp[0]:.4f}, {cp[1]:.4f})")

    # Verify interpolation
    print("\n" + "=" * 60)
    print("Verification: Evaluate curve at fit point parameters")
    print("=" * 60)

    params = compute_parameters(fit_points)
    max_error = 0.0

    for i, (fp, param) in enumerate(zip(fit_points, params)):
        curve_point = evaluate_nurbs(control_points, knots, 3, param)
        error = np.linalg.norm(curve_point - fp)
        max_error = max(max_error, error)
        status = "✅" if error < 1e-6 else "❌"
        print(f"{status} p{i+1}: expected ({fp[0]:.2f}, {fp[1]:.2f}), "
              f"got ({curve_point[0]:.4f}, {curve_point[1]:.4f}), error={error:.2e}")

    print(f"\nMaximum interpolation error: {max_error:.2e}")
    print(f"Status: {'✅ PASS' if max_error < 1e-6 else '❌ FAIL'}")

    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))

    # Evaluate curve
    u_vals = np.linspace(0, 1, 100)
    curve_points = np.array([evaluate_nurbs(control_points, knots, 3, u) for u in u_vals])

    # Plot curve
    ax.plot(curve_points[:, 0], curve_points[:, 1], 'g-', linewidth=2, label='NURBS curve')

    # Plot fit points
    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=10, label='Fit points', markerfacecolor='red')

    # Plot control points
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs-', markersize=8,
            label='Control points', alpha=0.5, markerfacecolor='blue')

    # Add labels
    for i, fp in enumerate(fit_points):
        ax.annotate(f'p{i+1}', fp, xytext=(5, 5), textcoords='offset points', fontsize=9)

    for i, cp in enumerate(control_points):
        ax.annotate(f'P{i}', cp, xytext=(5, -15), textcoords='offset points', fontsize=8, color='blue')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_title(f'NURBS Interpolation: {len(fit_points)} fit points → {len(control_points)} control points')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.axis('equal')

    plt.tight_layout()
    plt.savefig('/tmp/gh-issue-solver-1760733053436/experiments/test_issue253_9controls.png', dpi=150)
    print(f"\nPlot saved to: experiments/test_issue253_9controls.png")

    print("\n" + "=" * 60)
    print("Summary:")
    print(f"  Fit points: {len(fit_points)}")
    print(f"  Control points: {len(control_points)}")
    print(f"  Expected control points: {len(fit_points) + 3 - 1} (for degree 3)")
    print(f"  Max error: {max_error:.2e}")
    print("=" * 60)
