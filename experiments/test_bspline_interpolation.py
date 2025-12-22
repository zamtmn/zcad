#!/usr/bin/env python3
"""
Test B-spline global interpolation algorithm
This script validates the correct implementation of B-spline interpolation
where the curve passes through all given data points.
"""

import numpy as np
import matplotlib.pyplot as plt

def basis_function(i, p, u, knots):
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion.

    Args:
        i: basis function index
        p: degree
        u: parameter value
        knots: knot vector

    Returns:
        Value of basis function at u
    """
    # Degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif u == knots[i+1] and u == knots[-1] and i == len(knots) - p - 2:
            # Special case: u is at the right endpoint of the knot vector
            # and this is the last basis function
            return 1.0
        else:
            return 0.0

    # Degree p > 0
    # First term
    if abs(knots[i+p] - knots[i]) < 1e-10:
        c1 = 0.0
    else:
        c1 = (u - knots[i]) / (knots[i+p] - knots[i]) * basis_function(i, p-1, u, knots)

    # Second term
    if abs(knots[i+p+1] - knots[i+1]) < 1e-10:
        c2 = 0.0
    else:
        c2 = (knots[i+p+1] - u) / (knots[i+p+1] - knots[i+1]) * basis_function(i+1, p-1, u, knots)

    return c1 + c2

def compute_parameters_chord_length(points):
    """
    Compute parameters using chord length parameterization.

    Args:
        points: array of data points (n x 2)

    Returns:
        array of parameters in [0,1]
    """
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0

    if n == 2:
        params[1] = 1.0
        return params

    # Calculate cumulative chord lengths
    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize to [0,1]
    if total_length > 1e-6:
        params = params / total_length
    else:
        # Fallback to uniform
        for i in range(n):
            params[i] = i / (n-1)

    return params

def generate_knot_vector_averaging(n, p, params):
    """
    Generate knot vector using the averaging method.

    Args:
        n: number of data points - 1 (so we have n+1 points)
        p: degree
        params: parameter values for data points

    Returns:
        knot vector of size m+1 where m = n + p + 1
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # First p+1 knots are 0
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameters
    # knots[j] = (params[j-p] + params[j-p+1] + ... + params[j-1]) / p
    for j in range(p + 1, n + 1):
        sum_val = 0.0
        for i in range(j - p, j):
            sum_val += params[i]
        knots[j] = sum_val / p

    # Last p+1 knots are 1
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def global_interpolation(data_points, degree):
    """
    Perform global B-spline interpolation.

    Args:
        data_points: array of data points (n x 2)
        degree: degree of B-spline

    Returns:
        control_points: array of control points
        knots: knot vector
        params: parameters
    """
    n = len(data_points) - 1  # n+1 points, so n is the index of last point

    # Step 1: Compute parameters using chord length
    params = compute_parameters_chord_length(data_points)
    print(f"Parameters: {params}")

    # Step 2: Generate knot vector using averaging method
    knots = generate_knot_vector_averaging(n, degree, params)
    print(f"Knot vector: {knots}")

    # Step 3: Build coefficient matrix N
    # N[i][j] = BasisFunction(j, degree, params[i])
    N = np.zeros((n + 1, n + 1))
    for i in range(n + 1):
        for j in range(n + 1):
            N[i][j] = basis_function(j, degree, params[i], knots)
        print(f"Row {i} (u={params[i]:.4f}): {N[i]}")

    print(f"\nBasis matrix N:\n{N}")
    print(f"Matrix condition number: {np.linalg.cond(N)}")

    # Step 4: Solve linear system N * P = D for each coordinate
    # where P are control points and D are data points
    control_points = np.zeros((n + 1, 2))

    for coord in range(2):
        D = data_points[:, coord]
        P = np.linalg.solve(N, D)
        control_points[:, coord] = P

    return control_points, knots, params

def evaluate_bspline(control_points, knots, degree, u):
    """
    Evaluate B-spline at parameter u.

    Args:
        control_points: array of control points
        knots: knot vector
        degree: degree of B-spline
        u: parameter value

    Returns:
        point on curve at u
    """
    n = len(control_points) - 1
    point = np.zeros(2)

    for i in range(n + 1):
        basis = basis_function(i, degree, u, knots)
        point += basis * control_points[i]

    return point

def test_simple_case():
    """
    Test with a simple case: 5 points forming a wave-like curve
    """
    # Define data points (similar to the screenshots)
    # Need at least degree + 2 points for global interpolation with internal knots
    data_points = np.array([
        [0.0, 2.0],
        [2.0, 4.0],
        [4.0, 1.0],
        [5.0, 3.0],
        [6.0, 2.5]
    ])

    degree = 3

    print("=" * 60)
    print(f"Testing B-spline interpolation with degree {degree}")
    print(f"Data points:\n{data_points}")
    print("=" * 60)

    # Perform interpolation
    control_points, knots, params = global_interpolation(data_points, degree)

    print(f"\nControl points:\n{control_points}")

    # Verify: evaluate curve at parameter values and check if they match data points
    print("\n" + "=" * 60)
    print("Verification: Evaluating curve at parameter values")
    print("=" * 60)

    max_error = 0.0
    for i, param in enumerate(params):
        point = evaluate_bspline(control_points, knots, degree, param)
        error = np.linalg.norm(point - data_points[i])
        max_error = max(max_error, error)
        print(f"u={param:.4f}: expected {data_points[i]}, got {point}, error={error:.6f}")

    print(f"\nMaximum interpolation error: {max_error:.6e}")

    if max_error < 1e-6:
        print("SUCCESS: Curve passes through all data points!")
    else:
        print("FAILURE: Curve does not pass through data points!")

    # Plot the results
    plt.figure(figsize=(12, 6))

    # Evaluate curve at many points for smooth visualization
    u_vals = np.linspace(0, 1, 200)
    curve_points = np.array([evaluate_bspline(control_points, knots, degree, u) for u in u_vals])

    # Plot data points (blue circles - points we want to pass through)
    plt.plot(data_points[:, 0], data_points[:, 1], 'bo', markersize=10, label='Data points (must pass through)', zorder=3)

    # Plot control points (small circles - computed)
    plt.plot(control_points[:, 0], control_points[:, 1], 'go', markersize=6, label='Control points', zorder=2)

    # Plot control polygon (dashed green line)
    plt.plot(control_points[:, 0], control_points[:, 1], 'g--', alpha=0.5, linewidth=1, label='Control polygon')

    # Plot interpolated curve (red line - should pass through data points)
    plt.plot(curve_points[:, 0], curve_points[:, 1], 'r-', linewidth=2, label='Interpolated B-spline', zorder=1)

    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.axis('equal')
    plt.title(f'B-spline Global Interpolation (degree {degree})')
    plt.xlabel('X')
    plt.ylabel('Y')

    plt.savefig('/tmp/gh-issue-solver-1760650543519/experiments/bspline_interpolation_test.png', dpi=150, bbox_inches='tight')
    print(f"\nPlot saved to experiments/bspline_interpolation_test.png")

    return max_error < 1e-6

if __name__ == "__main__":
    success = test_simple_case()
    exit(0 if success else 1)
