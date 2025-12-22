#!/usr/bin/env python3
"""
Test script to reproduce the 7-point spline interpolation issue.
Based on the user's screenshot showing that the spline only passes through p1, p2, and p7.
"""

import numpy as np
import matplotlib.pyplot as plt

def basis_function(i, p, u, knots):
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion.
    This implements the exact same logic as the Pascal code.
    """
    # Special case for clamped B-splines at the endpoint
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    # Special case for degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    # Use triangular table to build up from degree 0 to degree p
    basis_values = np.zeros(p + 1)

    # Initialize degree 0
    for j in range(p + 1):
        if knots[i+j] <= u < knots[i+j+1]:
            basis_values[j] = 1.0
        elif abs(u - knots[i+j+1]) < 1e-10 and i+j+1 == len(knots)-1:
            basis_values[j] = 1.0
        else:
            basis_values[j] = 0.0

    # Build up to degree p
    for k in range(1, p + 1):
        # Handle left end
        if basis_values[0] == 0.0:
            saved = 0.0
        else:
            u_right = knots[i + k]
            u_left = knots[i]
            if abs(u_right - u_left) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - u_left) / (u_right - u_left)) * basis_values[0]

        # Process middle terms
        for j in range(p - k + 1):
            u_left = knots[i + j + 1]
            u_right = knots[i + j + k + 1]

            if basis_values[j + 1] == 0.0:
                basis_values[j] = saved
                saved = 0.0
            else:
                if abs(u_right - u_left) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((u_right - u) / (u_right - u_left)) * basis_values[j + 1]
                basis_values[j] = saved + temp

                if abs(knots[i + j + k + 1] - knots[i + j + 1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i + j + 1]) / (knots[i + j + k + 1] - knots[i + j + 1])) * basis_values[j + 1]

    return basis_values[0]

def compute_parameters(points):
    """
    Compute parameter values using chord length parameterization.
    """
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[n-1] = 1.0

    if n == 2:
        return params

    # Calculate total chord length
    total_length = 0.0
    for i in range(n - 1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize to [0,1]
    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n - 1)

    return params

def generate_knot_vector(n, p, params):
    """
    Generate knot vector using averaging method for global interpolation.
    Based on Piegl & Tiller "The NURBS Book".
    n: number of control points minus 1 (i.e., for n+1 control points)
    p: degree
    params: parameter values
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped knot vector: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameter values
    for j in range(1, n - p + 1):
        sum_val = 0.0
        for i in range(j, j + p):
            sum_val += params[i]
        knots[p + j] = sum_val / p

    # Clamped knot vector: repeat 1 (p+1) times at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def solve_linear_system(A, b):
    """
    Solve linear system using Gaussian elimination with partial pivoting.
    """
    n = len(b)
    A = A.copy()  # Don't modify original
    c = b.copy()

    # Forward elimination with partial pivoting
    for k in range(n - 1):
        # Find pivot
        max_row = k
        max_val = abs(A[k, k])
        for i in range(k + 1, n):
            if abs(A[i, k]) > max_val:
                max_val = abs(A[i, k])
                max_row = i

        # Swap rows if needed
        if max_row != k:
            A[[k, max_row]] = A[[max_row, k]]
            c[k], c[max_row] = c[max_row], c[k]

        # Eliminate column
        for i in range(k + 1, n):
            if abs(A[k, k]) > 1e-10:
                factor = A[i, k] / A[k, k]
                A[i, k:] -= factor * A[k, k:]
                c[i] -= factor * c[k]

    # Back substitution
    x = np.zeros(n)
    for i in range(n - 1, -1, -1):
        x[i] = c[i]
        for j in range(i + 1, n):
            x[i] -= A[i, j] * x[j]
        if abs(A[i, i]) > 1e-10:
            x[i] /= A[i, i]
        else:
            x[i] = 0

    return x

def convert_on_curve_points_to_control_points(degree, on_curve_points):
    """
    Convert fit points to control points using standard global interpolation.
    This implements the exact same algorithm as the Pascal code.
    """
    num_points = len(on_curve_points)

    # Handle edge cases
    if num_points < 2:
        return on_curve_points, np.array([])

    if degree >= num_points or degree < 1:
        return on_curve_points, np.array([])

    if degree == 1 or num_points == 2:
        return on_curve_points, np.array([])

    # Compute parameter values using chord length parameterization
    params = compute_parameters(on_curve_points)

    print(f"\n=== Parameters ===")
    print(f"params = {params}")

    # Number of control points = numPoints (same as number of fit points)
    num_control_points = num_points

    # Generate knot vector using averaging method
    # For n+1 control points (indexed 0 to n) with degree p:
    # Knot vector has m+1 elements where m = n + p + 1
    knots = generate_knot_vector(num_points - 1, degree, params)

    print(f"\n=== Knot Vector ===")
    print(f"num_control_points = {num_control_points}")
    print(f"degree = {degree}")
    print(f"knot vector length = {len(knots)}")
    print(f"knots = {knots}")

    # Set up linear system: N * P = D
    A = np.zeros((num_points, num_points))
    b_x = np.zeros(num_points)
    b_y = np.zeros(num_points)

    print(f"\n=== Basis Function Matrix ===")
    # Build the coefficient matrix N
    for i in range(num_points):
        u = params[i]

        # Evaluate all basis functions N_j,p(u_i) for j = 0 to numPoints-1
        basis_vals = []
        for j in range(num_points):
            A[i, j] = basis_function(j, degree, u, knots)
            basis_vals.append(A[i, j])

        print(f"u[{i}] = {u:.4f}: N = {[f'{v:.4f}' for v in basis_vals]}, sum = {sum(basis_vals):.6f}")

        # Right-hand side: fit points
        b_x[i] = on_curve_points[i, 0]
        b_y[i] = on_curve_points[i, 1]

    print(f"\n=== Matrix A (first 5x5) ===")
    print(A[:min(5, num_points), :min(5, num_points)])

    # Solve the linear system for each dimension
    x_x = solve_linear_system(A, b_x)
    x_y = solve_linear_system(A, b_y)

    # Store control points
    control_points = np.column_stack([x_x, x_y])

    return control_points, knots

def evaluate_spline(control_points, knots, degree, u):
    """
    Evaluate B-spline at parameter u.
    """
    point = np.zeros(2)
    n = len(control_points) - 1

    for i in range(len(control_points)):
        N = basis_function(i, degree, u, knots)
        point += N * control_points[i]

    return point

def test_7_points():
    """
    Test with 7 fit points as reported by the user.
    """
    # Create 7 fit points based on the screenshot
    # These are approximate positions from the user's "correct" screenshot
    fit_points = np.array([
        [1.0, 2.0],   # p1
        [3.5, 1.5],   # p2
        [3.5, 1.0],   # p3
        [1.5, 0.5],   # p4
        [0.5, 1.5],   # p5
        [2.5, 2.5],   # p6
        [4.0, 2.0],   # p7
    ])

    degree = 3

    print("=" * 60)
    print("Testing 7 Fit Points with Degree 3")
    print("=" * 60)

    # Convert to control points
    control_points, knots = convert_on_curve_points_to_control_points(degree, fit_points)

    print(f"\n=== Fit Points ===")
    for i, pt in enumerate(fit_points):
        print(f"p{i+1}: ({pt[0]:.2f}, {pt[1]:.2f})")

    print(f"\n=== Control Points ===")
    for i, pt in enumerate(control_points):
        print(f"P{i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    # Verify interpolation: evaluate spline at each parameter value
    params = compute_parameters(fit_points)
    print(f"\n=== Interpolation Verification ===")
    max_error = 0.0
    for i, u in enumerate(params):
        evaluated = evaluate_spline(control_points, knots, degree, u)
        error = np.linalg.norm(evaluated - fit_points[i])
        max_error = max(max_error, error)
        status = "✓ PASS" if error < 1e-6 else "✗ FAIL"
        print(f"p{i+1}: u={u:.4f}, evaluated=({evaluated[0]:.4f}, {evaluated[1]:.4f}), "
              f"expected=({fit_points[i,0]:.4f}, {fit_points[i,1]:.4f}), "
              f"error={error:.2e} {status}")

    print(f"\nMaximum interpolation error: {max_error:.2e}")

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Evaluate spline at many points for smooth curve
    u_vals = np.linspace(0, 1, 200)
    curve_points = np.array([evaluate_spline(control_points, knots, degree, u) for u in u_vals])

    # Plot spline curve
    ax.plot(curve_points[:, 0], curve_points[:, 1], 'g-', linewidth=2, label='NURBS Spline')

    # Plot fit points (red circles)
    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=12,
            markerfacecolor='none', markeredgewidth=2, label='Fit Points')
    for i, pt in enumerate(fit_points):
        ax.text(pt[0] + 0.1, pt[1] + 0.1, f'p{i+1}', fontsize=12, color='red')

    # Plot control points (blue squares)
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=8, label='Control Points')

    # Draw control polygon
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_title(f'7 Fit Points, Degree {degree} - Standard Global Interpolation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.axis('equal')

    plt.tight_layout()
    plt.savefig('/tmp/gh-issue-solver-1760728838022/experiments/test_7_points_debug.png', dpi=150)
    print(f"\nPlot saved to experiments/test_7_points_debug.png")

    return max_error < 1e-6

if __name__ == "__main__":
    success = test_7_points()
    print(f"\n{'='*60}")
    print(f"Test Result: {'PASS ✓' if success else 'FAIL ✗'}")
    print(f"{'='*60}")
