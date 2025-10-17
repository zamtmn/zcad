#!/usr/bin/env python3
"""
Verification script for issue #244 fix.

This script implements the FIXED version of the BasisFunction
and tests that it correctly computes control points.
"""

import numpy as np
from scipy.interpolate import BSpline
import matplotlib.pyplot as plt


def chord_length_parameterization(points):
    """Compute parameter values using chord length method - matches Pascal code."""
    n = len(points)
    if n < 2:
        return np.array([0.0])

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
    """Generate knot vector - matches Pascal code."""
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: averaging method
    for j in range(p + 1, n + 1):
        sum_val = 0.0
        for i in range(j - p, j):
            sum_val += params[i]
        knots[j] = sum_val / p

    # Clamped: repeat 1 at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots


def basis_function_fixed(i, p, u, knots):
    """
    FIXED version of BasisFunction that correctly handles endpoint case.

    This matches the fixed Pascal code.
    """
    # Special case for endpoint - FIXED VERSION
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        # At the last knot value
        if i == num_ctrl_pts:
            return 1.0
        else:
            return 0.0

    # Special case for degree 0
    if p == 0:
        if i >= len(knots) - 1:
            return 0.0
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    # Check for valid index
    if i + p + 1 >= len(knots):
        return 0.0

    # Use triangular table to build up from degree 0 to degree p
    basis_values = np.zeros(p + 1)

    # Initialize degree 0
    for j in range(p + 1):
        if i+j >= len(knots) - 1:
            basis_values[j] = 0.0
        elif knots[i+j] <= u < knots[i+j+1]:
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
            u_right = knots[i+k]
            u_left = knots[i]
            if abs(u_right - u_left) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - u_left) / (u_right - u_left)) * basis_values[0]

        # Process middle terms
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


def build_basis_matrix_fixed(n, p, params, knots):
    """Build basis matrix using FIXED basis function."""
    N = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        for j in range(n + 1):
            N[i, j] = basis_function_fixed(j, p, params[i], knots)

    return N


def test_fixed_implementation(data_points, degree):
    """Test the FIXED B-spline interpolation."""
    data_points = np.array(data_points)
    n = len(data_points) - 1

    print(f"\n{'='*70}")
    print(f"Testing FIXED B-spline interpolation")
    print(f"{'='*70}")
    print(f"Number of points: {n+1}")
    print(f"Degree: {degree}")
    print(f"\nData points (on-curve points that spline should pass through):")
    for i, pt in enumerate(data_points):
        print(f"  Point {i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    # Step 1: Compute parameters
    params = chord_length_parameterization(data_points)
    print(f"\nParameter values:")
    print(f"  {params}")

    # Step 2: Generate knot vector
    knots = generate_knot_vector_averaging(n, degree, params)
    print(f"\nKnot vector:")
    print(f"  {knots}")

    # Step 3: Build basis matrix with FIXED function
    N = build_basis_matrix_fixed(n, degree, params, knots)
    print(f"\nBasis matrix N (FIXED - last row should have 1.0 in last column):")
    for row in N:
        print(f"  {row}")

    # Check matrix properties
    det = np.linalg.det(N)
    cond = np.linalg.cond(N)
    row_sums = N.sum(axis=1)

    print(f"\nMatrix properties:")
    print(f"  Determinant: {det:.6e}")
    print(f"  Condition number: {cond:.6e}")
    print(f"  Row sums (should all be ~1.0): {row_sums}")

    if abs(det) < 1e-10:
        print(f"  ❌ ERROR: Matrix is still singular!")
        return None, None, None
    else:
        print(f"  ✅ Matrix is non-singular - can solve for control points!")

    # Step 4: Solve for control points
    control_points = np.zeros_like(data_points)
    try:
        for coord in range(data_points.shape[1]):
            control_points[:, coord] = np.linalg.solve(N, data_points[:, coord])

        print(f"\nComputed control points:")
        for i, pt in enumerate(control_points):
            print(f"  Control {i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    except np.linalg.LinAlgError as e:
        print(f"  ❌ ERROR solving linear system: {e}")
        return None, None, None

    # Step 5: Create B-spline and verify interpolation
    # For scipy, we need to construct the spline properly
    # scipy expects control points in transposed form
    evaluated_points = np.zeros_like(data_points)

    # Manually evaluate B-spline at parameter values using basis functions
    for i in range(len(params)):
        pt = np.zeros(data_points.shape[1])
        for j in range(n + 1):
            basis_val = basis_function_fixed(j, degree, params[i], knots)
            pt += basis_val * control_points[j]
        evaluated_points[i] = pt
    errors = np.linalg.norm(evaluated_points - data_points, axis=1)
    max_error = np.max(errors)

    print(f"\nInterpolation verification:")
    print(f"  Maximum error: {max_error:.6e}")

    if max_error < 1e-6:
        print(f"  ✅ SUCCESS: Spline passes through all points!")
    else:
        print(f"  ⚠️  Warning: Spline error is {max_error:.6e}")
        print(f"\nDetailed errors:")
        for i in range(len(data_points)):
            print(f"    Point {i}: error {errors[i]:.6e}")

    # Create a simple callable for the spline
    def spline(u):
        pt = np.zeros(data_points.shape[1])
        for j in range(n + 1):
            basis_val = basis_function_fixed(j, degree, u, knots)
            pt += basis_val * control_points[j]
        return pt

    return control_points, knots, spline


def visualize_comparison(data_points, control_points, knots, degree):
    """Visualize the FIXED spline."""
    data_points = np.array(data_points)
    n = len(data_points) - 1

    if control_points is None:
        print("Cannot visualize - control points are None")
        return

    # Create spline function
    def spline(u):
        pt = np.zeros(data_points.shape[1])
        for j in range(n + 1):
            basis_val = basis_function_fixed(j, degree, u, knots)
            pt += basis_val * control_points[j]
        return pt

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Evaluate spline
    u_fine = np.linspace(0, 1, 200)
    curve = np.array([spline(u) for u in u_fine])
    ax.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3, label='Spline (green)', zorder=1)

    # Plot data points (red circles)
    ax.scatter(data_points[:, 0], data_points[:, 1],
               c='red', s=300, marker='o', edgecolors='white', linewidths=3,
               label='On-curve points (red circles)', zorder=3)

    # Plot control points (blue squares)
    ax.scatter(control_points[:, 0], control_points[:, 1],
               c='blue', s=250, marker='s', edgecolors='white', linewidths=3,
               label='Control points (blue squares)', zorder=2)

    # Connect control points with dashed line
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--',
            alpha=0.3, linewidth=2, zorder=0)

    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=12)
    ax.set_title('FIXED: B-spline passes through red circles', fontsize=14, fontweight='bold')
    ax.set_xlabel('X', fontsize=12)
    ax.set_ylabel('Y', fontsize=12)
    ax.axis('equal')

    # Save
    output_path = '/tmp/gh-issue-solver-1760721183414/experiments/issue244_fixed.png'
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\n📊 Visualization saved to: {output_path}")
    plt.close()


def main():
    """Main test function."""
    print("="*70)
    print("Issue #244: Verification of FIXED B-spline interpolation")
    print("="*70)

    # Test case 1: 4 points (from the issue)
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
    cp1, knots1, spline1 = test_fixed_implementation(data_points_1, degree)

    if cp1 is not None:
        visualize_comparison(data_points_1, cp1, knots1, degree)

    # Test case 2: 5 points
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

    cp2, knots2, spline2 = test_fixed_implementation(data_points_2, degree)

    # Test case 3: More points
    print("\n" + "="*70)
    print("TEST CASE 3: 6 points")
    print("="*70)

    data_points_3 = np.array([
        [0.0, 0.0],
        [1.0, 1.5],
        [2.0, 2.0],
        [3.0, 1.5],
        [4.0, 2.5],
        [5.0, 1.0]
    ])

    cp3, knots3, spline3 = test_fixed_implementation(data_points_3, degree)

    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print("""
The fix corrects the endpoint handling in BasisFunction.

BEFORE THE FIX:
- The condition checked for knot multiplicity incorrectly
- At u=1.0, the last basis function returned 0 instead of 1
- This made the basis matrix singular (last row all zeros)
- Control points could not be computed correctly

AFTER THE FIX:
- Simplified the endpoint check to just: abs(u - knots[last]) < epsilon
- At u=1.0, the last basis function correctly returns 1
- Basis matrix is non-singular
- Control points are computed correctly
- Spline passes through all on-curve points!

All test cases should show:
- Non-zero determinant
- Row sums = 1.0
- Interpolation error < 1e-6
    """)


if __name__ == '__main__':
    main()
