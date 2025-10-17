#!/usr/bin/env python3
"""
Test script for issue #253: NURBS spline interpolation through specified points.

The issue: Spline passes through only p1, p2, and p7, not all 7 points.

Key mathematical formula (from "The NURBS Book" by Piegl & Tiller):
For interpolating m+1 data points with degree p:
    n = m + p - 1
where:
    - n+1 = number of control points needed
    - m+1 = number of data/fit points
    - p = degree of the spline

Example:
    - 7 fit points (m+1=7, so m=6)
    - degree 3 (p=3)
    - control points needed: n+1 = (6+3-1)+1 = 9

Algorithm (from "The NURBS Book", Algorithm A9.1):
1. Parameterize data points using chord length method
2. Generate knot vector using averaging method
3. Build and solve linear system N*P = D
"""

import numpy as np
from scipy.interpolate import BSpline, splev
import matplotlib.pyplot as plt


def chord_length_parameterization(points):
    """
    Compute parameter values using chord length method.

    Formula: t_k = t_{k-1} + |Q_k - Q_{k-1}| / d
    where d = sum of all chord lengths
    """
    n = len(points)
    if n < 2:
        return np.array([0.0])

    params = np.zeros(n)
    params[0] = 0.0

    # Calculate cumulative chord lengths
    for i in range(1, n):
        chord = np.linalg.norm(points[i] - points[i-1])
        params[i] = params[i-1] + chord

    # Normalize to [0, 1]
    total_length = params[-1]
    if total_length > 1e-10:
        params = params / total_length
    else:
        params = np.linspace(0, 1, n)

    params[0] = 0.0
    params[-1] = 1.0

    return params


def generate_knot_vector_averaging(m, p, params):
    """
    Generate knot vector using averaging method for global interpolation.

    Based on "The NURBS Book" by Piegl & Tiller, Chapter 9.2.1

    For STANDARD B-spline interpolation:
    - m+1 data points (indexed 0 to m)
    - degree p
    - n = m (same number of control points as data points)
    - knot vector has m+1 elements: m = n+p+1

    Args:
        m: number of data points minus 1 (index of last data point)
        p: degree of B-spline
        params: parameter values from chord length parameterization

    Returns:
        knot vector
    """
    # For STANDARD interpolation: n = m (same number of control points as data points)
    n = m

    # Knot vector length: m+1 where m = n+p+1
    # So: length = n+p+1+1 = n+p+2
    num_knots = n + p + 2
    knots = np.zeros(num_knots)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: averaging method
    # Formula: u_{j+p} = (1/p) * sum_{i=j}^{j+p-1} t_i
    # for j = 1, 2, ..., n-p
    for j in range(1, n - p + 1):
        knot_sum = 0.0
        for i in range(j, j + p):
            knot_sum += params[i]
        knots[j + p] = knot_sum / p

    # Clamped: repeat 1 (p+1) times at end
    for i in range(n + 1, num_knots):
        knots[i] = 1.0

    return knots


def cox_de_boor(i, p, u, knots):
    """
    Evaluate B-spline basis function N_{i,p}(u) using Cox-de Boor recursion.

    Formula:
        N_{i,0}(u) = 1 if u_i <= u < u_{i+1}, else 0
        N_{i,p}(u) = ((u - u_i) / (u_{i+p} - u_i)) * N_{i,p-1}(u) +
                     ((u_{i+p+1} - u) / (u_{i+p+1} - u_{i+1})) * N_{i+1,p-1}(u)
    """
    # Base case: degree 0
    if p == 0:
        if knots[i] <= u < knots[i + 1]:
            return 1.0
        # Special case: last point
        elif abs(u - knots[i + 1]) < 1e-10 and abs(knots[i + 1] - 1.0) < 1e-10:
            return 1.0
        else:
            return 0.0

    # Recursive case
    left_coeff = 0.0
    denom = knots[i + p] - knots[i]
    if abs(denom) > 1e-10:
        left_coeff = (u - knots[i]) / denom * cox_de_boor(i, p - 1, u, knots)

    right_coeff = 0.0
    denom = knots[i + p + 1] - knots[i + 1]
    if abs(denom) > 1e-10:
        right_coeff = (knots[i + p + 1] - u) / denom * cox_de_boor(i + 1, p - 1, u, knots)

    return left_coeff + right_coeff


def build_basis_matrix(m, p, params, knots):
    """
    Build the basis function matrix for B-spline interpolation.

    Matrix N: (m+1) x (m+1) - SQUARE matrix for standard interpolation
    Element N[k, i] = N_{i,p}(t_k)

    This represents the linear system: N * P = D
    where:
        - N is the basis matrix
        - P are the unknown control points
        - D are the known data (interpolation) points
    """
    # For standard interpolation: n = m (same number of control points as data points)
    n = m
    N = np.zeros((m + 1, n + 1))

    for k in range(m + 1):
        for i in range(n + 1):
            N[k, i] = cox_de_boor(i, p, params[k], knots)

    return N


def convert_fit_points_to_control_points(fit_points, degree):
    """
    Convert fit points (points on curve) to control points for B-spline.

    This implements the global curve interpolation algorithm from
    "The NURBS Book" by Piegl & Tiller, Algorithm A9.1.

    Args:
        fit_points: points that the spline should pass through (m+1 points)
        degree: degree of B-spline (p)

    Returns:
        control_points: calculated control points (n+1 points where n=m+p-1)
        knots: knot vector
    """
    fit_points = np.array(fit_points)
    m = len(fit_points) - 1  # Index of last fit point
    p = degree

    # Handle edge cases
    if len(fit_points) < 2:
        return fit_points, None

    if degree >= len(fit_points):
        return fit_points, None

    if degree < 1:
        return fit_points, None

    # For linear (degree 1), points are control points
    if degree == 1:
        return fit_points, None

    # Step 1: Compute parameters using chord length
    params = chord_length_parameterization(fit_points)

    print(f"  Parameters (t_k): {params}")

    # Step 2: Generate knot vector using averaging method
    knots = generate_knot_vector_averaging(m, p, params)

    print(f"  Knot vector: {knots}")
    print(f"  Knot vector length: {len(knots)} (should be {m + 1 + p + 1 + 1} = {m + p + 3})")

    # Step 3: Build basis matrix
    N = build_basis_matrix(m, p, params, knots)

    print(f"  Basis matrix shape: {N.shape} (should be {m + 1} x {m + p})")
    print(f"  Matrix condition number: {np.linalg.cond(N):.2e}")

    # Step 4: Solve for control points (for each coordinate separately)
    # For standard interpolation: n = m
    n = m
    control_points = np.zeros((n + 1, fit_points.shape[1]))

    for coord in range(fit_points.shape[1]):
        control_points[:, coord] = np.linalg.solve(N, fit_points[:, coord])

    return control_points, knots


def evaluate_bspline(control_points, knots, degree, u):
    """Evaluate B-spline at parameter u using control points and knots."""
    n = len(control_points) - 1
    point = np.zeros(control_points.shape[1])

    for i in range(n + 1):
        basis = cox_de_boor(i, degree, u, knots)
        point += basis * control_points[i]

    return point


def test_nurbs_interpolation():
    """Test NURBS interpolation with 7 fit points."""
    print("=" * 80)
    print("Testing NURBS Interpolation for Issue #253")
    print("=" * 80)

    # Test case: 7 fit points (like in the issue)
    fit_points = np.array([
        [0.0, 0.0],      # p1
        [1.0, 1.0],      # p2
        [2.0, 2.5],      # p3
        [2.5, 1.5],      # p4
        [2.0, 0.5],      # p5
        [3.0, 1.0],      # p6
        [4.0, 0.0],      # p7
    ])

    degree = 3

    print(f"\nInput:")
    print(f"  Number of fit points: {len(fit_points)}")
    print(f"  Degree: {degree}")

    print(f"\nFit points (points where spline should pass through):")
    for i, pt in enumerate(fit_points):
        print(f"  p{i+1}: ({pt[0]:.2f}, {pt[1]:.2f})")

    # Expected number of control points (STANDARD interpolation: same as fit points)
    m = len(fit_points) - 1
    n = m  # Standard interpolation
    expected_control_points = n + 1

    print(f"\nMathematical calculation (STANDARD B-spline interpolation):")
    print(f"  m = {m} (index of last fit point)")
    print(f"  p = {degree} (degree)")
    print(f"  n = m = {n} (for standard interpolation)")
    print(f"  Expected control points: n + 1 = {expected_control_points}")

    # Convert to control points
    print(f"\nConverting fit points to control points...")
    control_points, knots = convert_fit_points_to_control_points(fit_points, degree)

    print(f"\nOutput:")
    print(f"  Number of control points: {len(control_points)}")
    print(f"  Control points:")
    for i, pt in enumerate(control_points):
        print(f"    C{i}: ({pt[0]:.4f}, {pt[1]:.4f})")

    # Verify: check if control points count is correct
    if len(control_points) == expected_control_points:
        print(f"\n  ✅ Control points count is CORRECT: {len(control_points)} == {expected_control_points}")
    else:
        print(f"\n  ❌ Control points count is WRONG: {len(control_points)} != {expected_control_points}")

    # Verify interpolation: evaluate spline at parameter values
    print(f"\nVerifying interpolation (checking if spline passes through fit points):")
    params = chord_length_parameterization(fit_points)
    errors = []

    for i, (fit_pt, t) in enumerate(zip(fit_points, params)):
        evaluated_pt = evaluate_bspline(control_points, knots, degree, t)
        error = np.linalg.norm(evaluated_pt - fit_pt)
        errors.append(error)

        if error < 1e-6:
            status = "✅"
        else:
            status = "❌"

        print(f"  {status} p{i+1}: expected ({fit_pt[0]:.2f}, {fit_pt[1]:.2f}), "
              f"got ({evaluated_pt[0]:.4f}, {evaluated_pt[1]:.4f}), error={error:.2e}")

    max_error = max(errors)
    print(f"\n  Maximum interpolation error: {max_error:.2e}")

    if max_error < 1e-6:
        print("  ✅ SUCCESS: Spline passes through ALL fit points")
    else:
        print("  ❌ FAILED: Spline does NOT pass through all fit points")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

    # Left plot: Full view
    u_fine = np.linspace(0, 1, 200)
    curve = np.array([evaluate_bspline(control_points, knots, degree, u) for u in u_fine])

    ax1.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=2, label='NURBS spline (green)')
    ax1.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=10,
             label='Fit points (red circles)', markerfacecolor='red',
             markeredgecolor='white', markeredgewidth=2)

    # Add labels for fit points
    for i, pt in enumerate(fit_points):
        ax1.text(pt[0] + 0.1, pt[1] + 0.1, f'p{i+1}', fontsize=10, color='red')

    ax1.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=8,
             label='Control points (blue squares)', markerfacecolor='blue',
             markeredgecolor='white', markeredgewidth=1.5)
    ax1.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)

    ax1.grid(True, alpha=0.3)
    ax1.legend()
    ax1.set_title(f'NURBS Interpolation: {len(fit_points)} fit points → {len(control_points)} control points')
    ax1.set_xlabel('X')
    ax1.set_ylabel('Y')
    ax1.axis('equal')

    # Right plot: Zoomed in to show interpolation accuracy
    ax2.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=2, label='NURBS spline')
    ax2.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=12,
             label='Fit points', markerfacecolor='red', markeredgecolor='white', markeredgewidth=2)

    # Highlight the points that should be interpolated
    evaluated_points = np.array([evaluate_bspline(control_points, knots, degree, t) for t in params])
    for i, (fit_pt, eval_pt, error) in enumerate(zip(fit_points, evaluated_points, errors)):
        if error > 1e-6:
            # Draw a line showing the error
            ax2.plot([fit_pt[0], eval_pt[0]], [fit_pt[1], eval_pt[1]], 'r-', linewidth=2, alpha=0.5)
            ax2.text(fit_pt[0], fit_pt[1] - 0.2, f'ERROR: {error:.2e}', fontsize=8, color='red')

    ax2.grid(True, alpha=0.3)
    ax2.legend()
    ax2.set_title('Interpolation Accuracy (zoomed)')
    ax2.set_xlabel('X')
    ax2.set_ylabel('Y')
    ax2.axis('equal')

    # Save figure
    output_path = '/tmp/gh-issue-solver-1760731146942/experiments/test_issue253_nurbs.png'
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\n📊 Visualization saved to: {output_path}")

    print("\n" + "=" * 80)
    print("SUMMARY:")
    print("=" * 80)
    print(f"""
For {len(fit_points)} fit points with degree {degree}:
  - Expected control points: {expected_control_points} (formula: m + p = {m} + {degree} = {expected_control_points})
  - Actual control points: {len(control_points)}
  - Maximum error: {max_error:.2e}
  - Status: {"✅ PASS" if max_error < 1e-6 else "❌ FAIL"}

The correct formula from "The NURBS Book":
  For m+1 fit points with degree p: need n+1 control points where n = m + p - 1

  m+1 = {len(fit_points)} fit points → m = {m}
  n = m + p - 1 = {m} + {degree} - 1 = {n}
  n+1 = {n + 1} control points
""")


if __name__ == '__main__':
    test_nurbs_interpolation()
    print("\nTest complete!")
