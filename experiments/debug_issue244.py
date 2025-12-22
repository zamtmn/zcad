#!/usr/bin/env python3
"""
Debug script for issue #244: B-spline interpolation not working correctly.

The user reports that the spline doesn't pass through the specified points.
This script will test the algorithm and help identify the bug.
"""

import numpy as np
from scipy.interpolate import BSpline
import matplotlib.pyplot as plt


def chord_length_parameterization(points):
    """Compute parameter values using chord length method."""
    n = len(points)
    if n < 2:
        return np.array([0.0])

    # Set first and last
    params = np.zeros(n)
    params[0] = 0.0
    params[n-1] = 1.0

    if n == 2:
        return params

    # Calculate cumulative chord lengths
    total_length = 0.0
    for i in range(n-1):
        chord = np.linalg.norm(points[i+1] - points[i])
        total_length += chord
        params[i+1] = total_length

    # Normalize to [0, 1]
    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n - 1)

    return params


def generate_knot_vector_averaging(n, p, params):
    """
    Generate knot vector using averaging method for global interpolation.

    Args:
        n: number of data points minus 1 (index of last point)
        p: degree of B-spline
        params: parameter values from chord length parameterization

    Returns:
        knot vector (clamped: starts with p+1 zeros, ends with p+1 ones)
    """
    m = n + p + 1  # number of knots minus 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 at start (p+1 times)
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: averaging method
    # knots[j] = (params[j-p] + params[j-p+1] + ... + params[j-1]) / p
    for j in range(p + 1, n + 1):
        sum_val = 0.0
        for i in range(j - p, j):
            sum_val += params[i]
        knots[j] = sum_val / p

    # Clamped: repeat 1 at end (p+1 times)
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots


def cox_de_boor_basis(i, p, u, knots):
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion.

    This is a reference implementation to compare against the Pascal code.
    """
    # Base case: degree 0
    if p == 0:
        if i >= len(knots) - 1:
            return 0.0
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif np.isclose(u, knots[i+1]) and i == len(knots) - 2:
            return 1.0
        else:
            return 0.0

    # Check for valid index
    if i + p + 1 >= len(knots):
        return 0.0

    # Recursive case
    left_denom = knots[i+p] - knots[i]
    left_term = 0.0
    if abs(left_denom) > 1e-10:
        left_term = ((u - knots[i]) / left_denom) * cox_de_boor_basis(i, p-1, u, knots)

    right_denom = knots[i+p+1] - knots[i+1]
    right_term = 0.0
    if abs(right_denom) > 1e-10:
        right_term = ((knots[i+p+1] - u) / right_denom) * cox_de_boor_basis(i+1, p-1, u, knots)

    return left_term + right_term


def build_basis_matrix_custom(n, p, params, knots):
    """Build basis matrix using our custom Cox-de Boor implementation."""
    N = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        for j in range(n + 1):
            N[i, j] = cox_de_boor_basis(j, p, params[i], knots)

    return N


def test_b_spline_interpolation(data_points, degree):
    """
    Test B-spline interpolation with given points and degree.
    """
    data_points = np.array(data_points)
    n = len(data_points) - 1

    print(f"\n{'='*70}")
    print(f"Testing B-spline interpolation")
    print(f"{'='*70}")
    print(f"Number of points: {n+1}")
    print(f"Degree: {degree}")
    print(f"\nData points (red circles - points that should be on the spline):")
    for i, pt in enumerate(data_points):
        print(f"  Point {i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    # Step 1: Compute parameters
    params = chord_length_parameterization(data_points)
    print(f"\nParameter values (chord-length):")
    print(f"  {params}")

    # Step 2: Generate knot vector
    knots = generate_knot_vector_averaging(n, degree, params)
    print(f"\nKnot vector:")
    print(f"  {knots}")

    # Step 3: Build basis matrix
    N = build_basis_matrix_custom(n, degree, params, knots)
    print(f"\nBasis matrix N (should be non-singular):")
    for row in N:
        print(f"  {row}")

    # Check matrix properties
    det = np.linalg.det(N)
    cond = np.linalg.cond(N)
    row_sums = N.sum(axis=1)

    print(f"\nMatrix properties:")
    print(f"  Determinant: {det:.6e}")
    print(f"  Condition number: {cond:.6e}")
    print(f"  Row sums (should be ~1.0): {row_sums}")

    if abs(det) < 1e-10:
        print(f"  ⚠️  WARNING: Matrix is singular or near-singular!")
        return None, None, None

    # Step 4: Solve for control points
    control_points = np.zeros_like(data_points)
    try:
        for coord in range(data_points.shape[1]):
            control_points[:, coord] = np.linalg.solve(N, data_points[:, coord])

        print(f"\nComputed control points (blue squares):")
        for i, pt in enumerate(control_points):
            print(f"  Control {i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    except np.linalg.LinAlgError as e:
        print(f"  ❌ ERROR solving linear system: {e}")
        return None, None, None

    # Step 5: Create B-spline and verify interpolation
    tck = (knots, control_points.T, degree)
    spline = BSpline(*tck)

    # Evaluate at parameter values to check interpolation
    evaluated_points = np.array([spline(p) for p in params])
    errors = np.linalg.norm(evaluated_points - data_points, axis=1)
    max_error = np.max(errors)

    print(f"\nInterpolation verification:")
    print(f"  Maximum error: {max_error:.6e}")

    if max_error < 1e-6:
        print(f"  ✅ SUCCESS: Spline passes through all points!")
    else:
        print(f"  ❌ FAILED: Spline does NOT pass through points correctly")
        print(f"\nDetailed errors:")
        for i in range(len(data_points)):
            print(f"    Point {i}: expected {data_points[i]}, got {evaluated_points[i]}, error {errors[i]:.6e}")

    return control_points, knots, spline


def visualize_spline(data_points, control_points, knots, degree, title="B-spline"):
    """Visualize the B-spline with data points and control points."""
    data_points = np.array(data_points)

    if control_points is None:
        print("Cannot visualize - control points are None")
        return

    # Create spline
    tck = (knots, control_points.T, degree)
    spline = BSpline(*tck)

    # Plot
    plt.figure(figsize=(12, 8))

    # Evaluate spline
    u_fine = np.linspace(0, 1, 200)
    curve = np.array([spline(u) for u in u_fine])
    plt.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3, label='Spline (green)', zorder=1)

    # Plot data points (red circles)
    plt.scatter(data_points[:, 0], data_points[:, 1],
                c='red', s=200, marker='o', edgecolors='white', linewidths=2,
                label='On-curve points (red circles)', zorder=3)

    # Plot control points (blue squares)
    plt.scatter(control_points[:, 0], control_points[:, 1],
                c='blue', s=150, marker='s', edgecolors='white', linewidths=2,
                label='Control points (blue squares)', zorder=2)

    # Connect control points with dashed line
    plt.plot(control_points[:, 0], control_points[:, 1], 'b--',
             alpha=0.3, linewidth=1, zorder=0)

    plt.grid(True, alpha=0.3)
    plt.legend(fontsize=12)
    plt.title(title, fontsize=14, fontweight='bold')
    plt.xlabel('X', fontsize=12)
    plt.ylabel('Y', fontsize=12)
    plt.axis('equal')

    # Save
    output_path = '/tmp/gh-issue-solver-1760721183414/experiments/issue244_debug.png'
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\n📊 Visualization saved to: {output_path}")
    plt.close()


def main():
    """Main test function."""
    print("="*70)
    print("Issue #244: Debug B-spline interpolation")
    print("="*70)

    # Test case 1: Simple 4-point curve (similar to the images)
    print("\n" + "="*70)
    print("TEST CASE 1: 4 points forming a curve")
    print("="*70)

    data_points_1 = np.array([
        [0.0, 1.0],
        [1.0, 3.0],
        [3.0, 2.0],
        [4.0, 1.0]
    ])

    degree = 3
    cp1, knots1, spline1 = test_b_spline_interpolation(data_points_1, degree)

    if cp1 is not None:
        visualize_spline(data_points_1, cp1, knots1, degree,
                        "Test Case 1: 4 Points, Degree 3")

    # Test case 2: More complex curve with 5 points
    print("\n" + "="*70)
    print("TEST CASE 2: 5 points forming a wavy curve")
    print("="*70)

    data_points_2 = np.array([
        [0.0, 0.0],
        [1.0, 2.0],
        [2.0, 1.5],
        [3.0, 3.0],
        [4.0, 2.0]
    ])

    cp2, knots2, spline2 = test_b_spline_interpolation(data_points_2, degree)

    if cp2 is not None:
        visualize_spline(data_points_2, cp2, knots2, degree,
                        "Test Case 2: 5 Points, Degree 3")

    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print("""
This script tests the B-spline global interpolation algorithm.

The algorithm should:
1. Take on-curve points (red circles) as input
2. Compute control points (blue squares)
3. Create a spline (green curve) that passes through ALL red circles

If the algorithm is correct, the maximum interpolation error should be < 1e-6.

Look at the generated images to see if the spline passes through the red circles.
    """)


if __name__ == '__main__':
    main()
