#!/usr/bin/env python3
"""
Test with 7 fit points to understand the actual problem in issue #244.

According to the latest comment, for 7 fit points, we should get 9 control points (7+2).
But the current implementation produces only 5 control points.

Let's test both:
1. Standard global interpolation (n fit points -> n control points)
2. CAD-style with tangent constraints (n fit points -> n+2 control points)
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
    For n+1 data points with degree p, generates n+p+2 knots.
    Based on Piegl & Tiller "The NURBS Book"
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: average p consecutive parameter values
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

def test_7_fit_points():
    """Test with 7 fit points as shown in the issue."""
    # Create 7 fit points that match the visual pattern in the issue
    fit_points = np.array([
        [0.0, 0.0],     # p1
        [1.0, 2.0],     # p2
        [3.0, 1.0],     # p3
        [2.0, 0.0],     # p4
        [1.5, -1.0],    # p5
        [3.5, -0.5],    # p6
        [4.0, 1.0]      # p7
    ])

    degree = 3

    print("="*80)
    print("TEST: 7 Fit Points with Standard Global Interpolation")
    print("="*80)

    print(f"\nFit points:")
    for i, pt in enumerate(fit_points):
        print(f"  p{i+1} = ({pt[0]:.2f}, {pt[1]:.2f})")

    # Standard global interpolation: n fit points -> n control points
    control_points, knots = standard_global_interpolation(fit_points, degree)

    print(f"\nControl points (should be {len(fit_points)} for standard interpolation):")
    print(f"  Actual count: {len(control_points)}")
    for i, pt in enumerate(control_points):
        print(f"  P[{i}] = ({pt[0]:.3f}, {pt[1]:.3f})")

    print(f"\nKnot vector:")
    print(f"  {knots}")
    print(f"  Length: {len(knots)} (should be {len(fit_points)} + {degree} + 1 = {len(fit_points) + degree + 1})")

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

    # Create visualization
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Evaluate spline
    curve = evaluate_bspline(control_points, knots, degree, 200)

    # Plot spline curve (green)
    ax.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3, label='NURBS Spline', zorder=2)

    # Plot control points (blue squares)
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
            label=f'Control Points ({len(control_points)})', zorder=3)
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)

    # Plot fit points (red circles)
    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=15,
            markerfacecolor='none', markeredgewidth=3,
            label=f'Fit Points ({len(fit_points)})', zorder=4)

    # Label fit points
    for i, pt in enumerate(fit_points):
        ax.annotate(f'p{i+1}', pt, xytext=(10, 10), textcoords='offset points',
                   fontsize=12, color='red', fontweight='bold')

    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=12)
    ax.set_title(f'Standard Global Interpolation: {len(fit_points)} Fit Points → {len(control_points)} Control Points\n' +
                 f'Max Error: {max_error:.2e}',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.axis('equal')

    plt.tight_layout()
    plt.savefig('experiments/test_7_points_standard.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Plot saved to: experiments/test_7_points_standard.png")

    if max_error < 1e-3:
        print("\n✓ SUCCESS: Spline passes through all fit points!")
    else:
        print("\n✗ FAIL: Spline does NOT pass through all fit points!")

if __name__ == '__main__':
    test_7_fit_points()
