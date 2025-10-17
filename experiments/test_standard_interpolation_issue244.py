#!/usr/bin/env python3
"""
Comprehensive test for issue #244: Standard Global NURBS Interpolation.

This test validates the NEW implementation that uses standard global interpolation:
- For n fit points, generates n control points (not n+2)
- Uses averaging method for knot vector generation
- Based on Piegl & Tiller "The NURBS Book" Chapter 9.2.1
"""

import numpy as np
import matplotlib.pyplot as plt

def chord_length_parameterization(points):
    """Compute parameter values using chord length method."""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[n-1] = 1.0

    if n == 2:
        return params

    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n-1)

    return params

def generate_knot_vector_averaging(n, p, params):
    """
    Generate knot vector using averaging method for STANDARD global interpolation.
    For n+1 data points (indexed 0 to n) with degree p, generates n+p+2 knots.
    Based on Piegl & Tiller "The NURBS Book" Chapter 9.2.1
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameter values
    # For j from 1 to n-p
    for j in range(1, n - p + 1):
        sum_val = 0.0
        for i in range(j, j + p):
            sum_val += params[i]
        knots[p + j] = sum_val / p

    # Clamped: repeat 1 (p+1) times at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def cox_de_boor(i, p, u, knots):
    """Cox-de Boor recursion formula for B-spline basis function."""
    num_ctrl_pts = len(knots) - p - 2

    # Special case: at endpoint, only last basis function is nonzero
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    left_denom = knots[i+p] - knots[i]
    right_denom = knots[i+p+1] - knots[i+1]

    left_term = 0.0
    if abs(left_denom) > 1e-10:
        left_term = ((u - knots[i]) / left_denom) * cox_de_boor(i, p-1, u, knots)

    right_term = 0.0
    if abs(right_denom) > 1e-10:
        right_term = ((knots[i+p+1] - u) / right_denom) * cox_de_boor(i+1, p-1, u, knots)

    return left_term + right_term

def standard_global_interpolation(fit_points, degree=3):
    """
    Standard NURBS global interpolation.
    For n+1 data points, produces n+1 control points.
    Based on Piegl & Tiller "The NURBS Book" Chapter 9.2
    """
    n = len(fit_points) - 1  # n+1 points, so n = last index

    # Step 1: Compute parameters
    params = chord_length_parameterization(fit_points)

    # Step 2: Compute knot vector
    knots = generate_knot_vector_averaging(n, degree, params)

    # Step 3: Set up linear system
    # D = N * P, where D are fit points, N is basis matrix, P are control points
    num_points = len(fit_points)
    A = np.zeros((num_points, num_points))

    for i in range(num_points):
        u = params[i]
        for j in range(num_points):
            A[i, j] = cox_de_boor(j, degree, u, knots)

    # Step 4: Solve for control points
    control_points = np.zeros((num_points, fit_points.shape[1]))
    for dim in range(fit_points.shape[1]):
        control_points[:, dim] = np.linalg.solve(A, fit_points[:, dim])

    return control_points, knots

def evaluate_bspline(control_points, knots, degree, num_samples=200):
    """Evaluate B-spline curve."""
    u_vals = np.linspace(0, 1, num_samples)
    curve_points = []

    for u in u_vals:
        point = np.zeros(control_points.shape[1])
        for i in range(len(control_points)):
            basis = cox_de_boor(i, degree, u, knots)
            point += basis * control_points[i]
        curve_points.append(point)

    return np.array(curve_points)

def test_case(name, fit_points, degree=3):
    """Test a single case."""
    print(f"\n{'='*80}")
    print(f"TEST: {name}")
    print(f"{'='*80}")

    print(f"\nFit points ({len(fit_points)}):")
    for i, pt in enumerate(fit_points):
        print(f"  p{i+1} = ({pt[0]:.2f}, {pt[1]:.2f})")

    # Standard global interpolation
    control_points, knots = standard_global_interpolation(fit_points, degree)

    print(f"\nControl points ({len(control_points)}):")
    for i, pt in enumerate(control_points):
        print(f"  P[{i}] = ({pt[0]:.3f}, {pt[1]:.3f})")

    print(f"\nKnot vector (length={len(knots)}):")
    print(f"  {knots}")

    # Verify interpolation
    print(f"\nVerification (spline should pass through all fit points):")
    params = chord_length_parameterization(fit_points)
    max_error = 0.0

    for i, (u, fit_pt) in enumerate(zip(params, fit_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - fit_pt)
        max_error = max(max_error, error)
        status = "✓" if error < 1e-3 else "✗ FAIL"
        print(f"  {status} p{i+1}: error = {error:.2e}")

    print(f"\nMaximum interpolation error: {max_error:.2e}")

    if max_error < 1e-3:
        print("✓ SUCCESS: Spline passes through all fit points!")
    else:
        print("✗ FAIL: Spline does NOT pass through all fit points!")

    return fit_points, control_points, knots, max_error

def main():
    """Run all tests."""
    print("="*80)
    print("COMPREHENSIVE TEST: Standard Global NURBS Interpolation")
    print("="*80)

    # Test Case 1: 4 points (original issue from earlier PRs)
    fit_points_4 = np.array([
        [0.0, 0.0],
        [2.0, -1.0],
        [3.5, 1.5],
        [1.0, 2.0]
    ])

    # Test Case 2: 7 points (the reported issue)
    fit_points_7 = np.array([
        [0.0, 0.0],
        [1.0, 2.0],
        [3.0, 1.0],
        [2.0, 0.0],
        [1.5, -1.0],
        [3.5, -0.5],
        [4.0, 1.0]
    ])

    # Test Case 3: 5 points
    fit_points_5 = np.array([
        [0.0, 0.0],
        [1.0, 1.0],
        [2.0, 0.5],
        [3.0, 1.5],
        [4.0, 1.0]
    ])

    test_cases = [
        ("4 Fit Points", fit_points_4),
        ("7 Fit Points (Issue #244)", fit_points_7),
        ("5 Fit Points", fit_points_5)
    ]

    results = []
    for name, fit_points in test_cases:
        result = test_case(name, fit_points)
        results.append((name, result))

    # Create visualization
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    for idx, (name, (fit_pts, ctrl_pts, knots, max_err)) in enumerate(results):
        ax = axes[idx]

        # Evaluate spline
        curve = evaluate_bspline(ctrl_pts, knots, 3, 200)

        # Plot spline curve (green)
        ax.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3, label='NURBS Spline', zorder=2)

        # Plot control points (blue squares)
        ax.plot(ctrl_pts[:, 0], ctrl_pts[:, 1], 'bs', markersize=10,
                label=f'Control Points ({len(ctrl_pts)})', zorder=3)
        ax.plot(ctrl_pts[:, 0], ctrl_pts[:, 1], 'b--', alpha=0.3, linewidth=1)

        # Plot fit points (red circles)
        ax.plot(fit_pts[:, 0], fit_pts[:, 1], 'ro', markersize=15,
                markerfacecolor='none', markeredgewidth=3,
                label=f'Fit Points ({len(fit_pts)})', zorder=4)

        # Label fit points
        for i, pt in enumerate(fit_pts):
            ax.annotate(f'p{i+1}', pt, xytext=(10, 10), textcoords='offset points',
                       fontsize=10, color='red', fontweight='bold')

        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=10)
        status = "✓" if max_err < 1e-3 else "✗"
        ax.set_title(f'{status} {name}\nMax Error: {max_err:.2e}',
                     fontsize=12, fontweight='bold')
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        ax.axis('equal')

    plt.suptitle('Standard Global NURBS Interpolation: n Fit Points → n Control Points',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('experiments/test_standard_interpolation_complete.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Visualization saved to: experiments/test_standard_interpolation_complete.png")

    # Summary
    print(f"\n{'='*80}")
    print("SUMMARY")
    print(f"{'='*80}")
    all_passed = all(result[3] < 1e-3 for _, result in results)
    if all_passed:
        print("✓ ALL TESTS PASSED: Standard global interpolation works correctly!")
        print(f"  All splines pass through their respective fit points.")
    else:
        print("✗ SOME TESTS FAILED")

    print(f"\nAlgorithm: Standard Global Interpolation")
    print(f"  - n fit points → n control points")
    print(f"  - Knot vector: averaging method")
    print(f"  - Based on: Piegl & Tiller 'The NURBS Book' Chapter 9.2.1")

if __name__ == '__main__':
    main()
