#!/usr/bin/env python3
"""
Test B-spline interpolation with 4 points to reproduce the bug.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import splprep, splev, BSpline

def basis_function_cox_de_boor(i, p, u, knots):
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion.
    This is a direct translation of the Pascal code.
    """
    # Special case for clamped B-splines at the endpoint
    # For n+1 control points with degree p, the knot vector has n+p+2 elements
    # When u equals the last knot value, only the last basis function should be non-zero
    n = len(knots) - p - 2  # Number of control points minus 1
    if abs(u - knots[-1]) < 1e-10 and abs(knots[-1] - knots[-(p+1)]) < 1e-10:
        # At the last knot with multiplicity p+1
        if i == n:
            return 1.0
        else:
            return 0.0

    # Special case for degree 0
    if p == 0:
        if u >= knots[i] and u < knots[i+1]:
            return 1.0
        elif u == knots[i+1] and i == len(knots)-2:
            return 1.0
        else:
            return 0.0

    # Use triangular table
    N = [0.0] * (p + 1)

    # Initialize degree 0
    for j in range(p + 1):
        if u >= knots[i+j] and u < knots[i+j+1]:
            N[j] = 1.0
        elif u == knots[i+j+1] and (i+j) == len(knots)-2:
            N[j] = 1.0
        else:
            N[j] = 0.0

    # Build up to degree p
    for k in range(1, p + 1):
        # Handle left end
        if N[0] == 0.0:
            saved = 0.0
        else:
            uright = knots[i+k]
            uleft = knots[i]
            if abs(uright - uleft) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - uleft) / (uright - uleft)) * N[0]

        # Process middle terms
        for j in range(p - k + 1):
            uleft = knots[i+j+1]
            uright = knots[i+j+k+1]

            if N[j+1] == 0.0:
                N[j] = saved
                saved = 0.0
            else:
                if abs(uright - uleft) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((uright - u) / (uright - uleft)) * N[j+1]
                N[j] = saved + temp

                if abs(knots[i+j+k+1] - knots[i+j+1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / (knots[i+j+k+1] - knots[i+j+1])) * N[j+1]

    return N[0]

def compute_parameters_chord_length(points):
    """Compute parameter values using chord length parameterization."""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[n-1] = 1.0

    if n == 2:
        return params

    # Calculate cumulative chord lengths
    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize to [0,1]
    # FIX: normalize ALL intermediate points including the last one
    if total_length > 0.0001:
        for i in range(1, n):  # Changed from n-1 to n
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):  # Changed from n-1 to n
            params[i] = i / (n - 1)

    return params

def generate_knot_vector_averaging(n, p, params):
    """
    Generate knot vector using averaging method.
    n = number of data points - 1
    p = degree
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameter values
    for j in range(p + 1, n + 1):
        sum_params = 0.0
        for i in range(j - p, j):
            sum_params += params[i]
        knots[j] = sum_params / p

    # Clamped: repeat 1 (p+1) times at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def test_4_points_degree_3():
    """Test with 4 points and degree 3 (the failing case)."""
    print("=" * 70)
    print("Testing 4 points with degree 3 (cubic)")
    print("=" * 70)

    # Define 4 test points matching roughly the user's screenshot
    # Points form a wave pattern
    points = np.array([
        [0.0, 0.0, 0.0],    # Point 1 (bottom-left)
        [1.0, 2.0, 0.0],    # Point 2 (top-middle)
        [2.0, 0.5, 0.0],    # Point 3 (middle-right)
        [3.0, 1.5, 0.0],    # Point 4 (top-right)
    ])

    n = len(points) - 1  # n = 3
    p = 3  # degree = 3

    print(f"\nInput points:\n{points}")

    # Step 1: Compute parameters
    params = compute_parameters_chord_length(points)
    print(f"\nParameters (chord length):\n{params}")

    # Step 2: Generate knot vector
    knots = generate_knot_vector_averaging(n, p, params)
    print(f"\nKnot vector (length={len(knots)}):\n{knots}")

    # Step 3: Build basis matrix
    num_points = len(points)
    basis_matrix = np.zeros((num_points, num_points))

    print(f"\nBuilding {num_points}x{num_points} basis matrix...")
    for i in range(num_points):
        u = params[i]
        print(f"\nRow {i}: u = {u:.6f}")
        for j in range(num_points):
            N = basis_function_cox_de_boor(j, p, u, knots)
            basis_matrix[i, j] = N
            print(f"  N_{j},{p}({u:.6f}) = {N:.6f}")

    print(f"\nBasis matrix:\n{basis_matrix}")
    print(f"\nBasis matrix condition number: {np.linalg.cond(basis_matrix):.2e}")

    # Check if matrix is singular
    det = np.linalg.det(basis_matrix)
    print(f"Basis matrix determinant: {det:.6e}")

    if abs(det) < 1e-10:
        print("\n❌ PROBLEM: Matrix is singular or nearly singular!")
        print("This will cause the solver to fail or give incorrect results.")

    # Step 4: Solve for control points
    try:
        control_points = np.zeros_like(points)
        for coord_idx in range(3):  # x, y, z
            data_coords = points[:, coord_idx]
            control_coords = np.linalg.solve(basis_matrix, data_coords)
            control_points[:, coord_idx] = control_coords

        print(f"\nComputed control points:\n{control_points}")

        # Verify: evaluate spline at parameter values
        print("\n" + "=" * 70)
        print("VERIFICATION: Evaluate spline at parameter values")
        print("=" * 70)

        for i in range(num_points):
            u = params[i]
            spline_point = np.zeros(3)
            for j in range(num_points):
                N = basis_function_cox_de_boor(j, p, u, knots)
                spline_point += N * control_points[j]

            error = np.linalg.norm(spline_point - points[i])
            print(f"\nPoint {i}: param={u:.6f}")
            print(f"  Expected: {points[i]}")
            print(f"  Got:      {spline_point}")
            print(f"  Error:    {error:.6e}")

            if error > 1e-3:
                print(f"  ❌ ERROR TOO LARGE!")

        # Visualize
        plt.figure(figsize=(12, 6))

        # Plot in 2D (x-y plane)
        plt.subplot(1, 2, 1)
        plt.plot(points[:, 0], points[:, 1], 'ro-', label='Data points', markersize=10)
        plt.plot(control_points[:, 0], control_points[:, 1], 'bs--', label='Control points', markersize=8)

        # Evaluate spline at many points for smooth curve
        u_vals = np.linspace(0, 1, 100)
        spline_curve = np.zeros((len(u_vals), 3))
        for idx, u in enumerate(u_vals):
            for j in range(num_points):
                N = basis_function_cox_de_boor(j, p, u, knots)
                spline_curve[idx] += N * control_points[j]

        plt.plot(spline_curve[:, 0], spline_curve[:, 1], 'b-', label='B-spline', linewidth=2)
        plt.grid(True)
        plt.legend()
        plt.title('B-spline Interpolation (X-Y view)')
        plt.xlabel('X')
        plt.ylabel('Y')
        plt.axis('equal')

        # Plot basis functions
        plt.subplot(1, 2, 2)
        for j in range(num_points):
            basis_vals = [basis_function_cox_de_boor(j, p, u, knots) for u in u_vals]
            plt.plot(u_vals, basis_vals, label=f'N_{j},{p}(u)')
        plt.grid(True)
        plt.legend()
        plt.title(f'Basis Functions (degree {p})')
        plt.xlabel('u')
        plt.ylabel('N(u)')

        plt.tight_layout()
        plt.savefig('/tmp/gh-issue-solver-1760686830122/experiments/issue-204/bspline_test_4points.png', dpi=150)
        print(f"\nPlot saved to experiments/issue-204/bspline_test_4points.png")

    except np.linalg.LinAlgError as e:
        print(f"\n❌ LINEAR ALGEBRA ERROR: {e}")
        print("The system could not be solved!")

if __name__ == "__main__":
    test_4_points_degree_3()
