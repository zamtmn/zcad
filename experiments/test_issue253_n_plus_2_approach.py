#!/usr/bin/env python3
"""
Test script for issue #253
Testing the n+2 control points approach for NURBS interpolation

According to the user's comment:
- 7 fit points should produce 9 control points (7 + 2 = 9)
- The current implementation produces 7 control points (wrong)
- The correct implementation should use tangent constraints at endpoints
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import Tuple

def basis_function(i: int, p: int, u: float, knots: np.ndarray) -> float:
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion formula
    Direct translation of the Pascal code in uzccommand_spline.pas
    """
    # Special case for clamped B-splines at the endpoint
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        if i == num_ctrl_pts:
            return 1.0
        else:
            return 0.0

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
            uright = knots[i + k]
            uleft = knots[i]
            if abs(uright - uleft) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - uleft) / (uright - uleft)) * basis_values[0]

        # Process middle terms
        for j in range(p - k + 1):
            uleft = knots[i + j + 1]
            uright = knots[i + j + k + 1]

            if basis_values[j + 1] == 0.0:
                basis_values[j] = saved
                saved = 0.0
            else:
                if abs(uright - uleft) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((uright - u) / (uright - uleft)) * basis_values[j + 1]
                basis_values[j] = saved + temp

                if abs(knots[i + j + k + 1] - knots[i + j + 1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i + j + 1]) / (knots[i + j + k + 1] - knots[i + j + 1])) * basis_values[j + 1]

    return basis_values[0]

def compute_parameters(points: np.ndarray) -> np.ndarray:
    """Generate parameter values using chord length parameterization"""
    n = len(points)
    params = np.zeros(n)

    if n < 2:
        return params

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

def generate_knot_vector_for_n_plus_2(num_fit_points: int, p: int) -> np.ndarray:
    """
    Generate knot vector for n+2 control points
    For n fit points, we have n+2 control points
    For n+2 control points with degree p, we need (n+2) + p + 1 knots
    """
    num_ctrl = num_fit_points + 2  # Number of control points
    n = num_ctrl - 1  # Last index of control points (0 to n)
    m = n + p + 1  # Last knot index
    num_knots = m + 1  # Total: m+1 knots
    knots = np.zeros(num_knots)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Interior knots: uniform spacing
    # Number of interior knots = total - start - end = (m+1) - (p+1) - (p+1) = m + 1 - 2*p - 2 = n - p
    num_interior = n - p
    if num_interior > 0:
        for j in range(1, num_interior + 1):
            knots[p + j] = j / (num_interior + 1.0)

    # Clamped: repeat 1 (p+1) times at end
    # Start from index (p+1) + num_interior = p + 1 + (n - p) = n + 1
    for i in range(n + 1, num_knots):
        knots[i] = 1.0

    return knots

def estimate_end_tangents(points: np.ndarray, params: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Estimate end tangent vectors from fit points"""
    n = len(points)

    # Start tangent: use first two points
    delta = params[1] - params[0]
    if abs(delta) > 0.0001:
        start_tangent = (points[1] - points[0]) / delta
    else:
        start_tangent = points[1] - points[0]

    # End tangent: use last two points
    delta = params[n-1] - params[n-2]
    if abs(delta) > 0.0001:
        end_tangent = (points[n-1] - points[n-2]) / delta
    else:
        end_tangent = points[n-1] - points[n-2]

    return start_tangent, end_tangent

def convert_on_curve_points_n_plus_2(degree: int, fit_points: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Convert fit points to control points using n+2 approach
    For n fit points, generate n+2 control points
    """
    num_points = len(fit_points)

    # Compute parameters
    params = compute_parameters(fit_points)

    # Estimate end tangents
    start_tangent, end_tangent = estimate_end_tangents(fit_points, params)

    # Number of control points = numPoints + 2
    num_control_points = num_points + 2
    control_points = np.zeros((num_control_points, fit_points.shape[1]))

    # Set first endpoint control point: P[0] = D[0]
    control_points[0] = fit_points[0]

    # Set last endpoint control point: P[n+1] = D[n-1]
    control_points[num_control_points - 1] = fit_points[num_points - 1]

    # Compute alpha and beta for tangent control points
    alpha = (params[1] - params[0]) / 3.0
    beta = (params[num_points-1] - params[num_points-2]) / 3.0

    # Set tangent-based control points
    # P[1] = D[0] + alpha * T_start
    control_points[1] = fit_points[0] + alpha * start_tangent

    # P[n] = D[n-1] - beta * T_end
    control_points[num_control_points - 2] = fit_points[num_points - 1] - beta * end_tangent

    # Generate knot vector for n+2 control points
    knots = generate_knot_vector_for_n_plus_2(num_points, degree)

    # Solve for interior control points P[2] to P[n-1]
    # We have n fit points D[0..n-1]
    # We need to interpolate interior points D[1..n-2] (n-2 points)
    # Unknown control points are P[2..n-1] (n-2 points)
    num_interior_fit = num_points - 2  # D[1] through D[n-2]
    num_interior_ctrl = num_points - 2  # P[2] through P[n-1]

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        # Build system: A * P_interior = b
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        b = np.zeros((num_interior_fit, fit_points.shape[1]))

        for j in range(num_interior_fit):
            fit_idx = j + 1  # D[1], D[2], ..., D[n-2]
            u = params[fit_idx]

            # Contribution from known control points
            contrib = np.zeros(fit_points.shape[1])

            # P[0]
            basis = basis_function(0, degree, u, knots)
            contrib += basis * control_points[0]

            # P[1]
            basis = basis_function(1, degree, u, knots)
            contrib += basis * control_points[1]

            # P[num_control_points - 2]
            basis = basis_function(num_control_points - 2, degree, u, knots)
            contrib += basis * control_points[num_control_points - 2]

            # P[num_control_points - 1]
            basis = basis_function(num_control_points - 1, degree, u, knots)
            contrib += basis * control_points[num_control_points - 1]

            # Right-hand side
            b[j] = fit_points[fit_idx] - contrib

            # Coefficients for unknown control points P[2..num_control_points-3]
            for k in range(num_interior_ctrl):
                ctrl_idx = k + 2
                A[j, k] = basis_function(ctrl_idx, degree, u, knots)

        # Solve linear system for each dimension
        try:
            x = np.linalg.solve(A, b)

            # Store results
            for k in range(num_interior_ctrl):
                control_points[k + 2] = x[k]
        except np.linalg.LinAlgError as e:
            print(f"ERROR: Failed to solve linear system: {e}")
            print(f"Matrix A:\n{A}")

    return control_points, knots

def evaluate_bspline(control_points: np.ndarray, knots: np.ndarray, degree: int, u: float) -> np.ndarray:
    """Evaluate B-spline at parameter value u"""
    point = np.zeros(control_points.shape[1])
    n = len(control_points) - 1

    for i in range(n + 1):
        basis = basis_function(i, degree, u, knots)
        point += basis * control_points[i]

    return point

def test_issue_253():
    """Test with 7 fit points as mentioned in issue #253"""
    print("="*80)
    print("Testing NURBS spline interpolation for issue #253")
    print("Expected: 7 fit points -> 9 control points (n+2 approach)")
    print("="*80)

    # Test case: 7 fit points (similar to the user's example)
    fit_points = np.array([
        [1.0, 0.0],      # p1
        [2.0, -0.5],     # p2
        [3.0, 0.5],      # p3
        [2.5, 1.5],      # p4
        [1.5, 2.0],      # p5
        [2.5, 3.0],      # p6
        [4.0, 2.5],      # p7
    ])

    degree = 3

    print(f"\nFit points (points spline should pass through): {len(fit_points)} points")
    for i, p in enumerate(fit_points):
        print(f"  p{i+1}: ({p[0]:.2f}, {p[1]:.2f})")

    print(f"\nDegree: {degree}")

    # Convert to control points using n+2 approach
    control_points, knots = convert_on_curve_points_n_plus_2(degree, fit_points)

    print(f"\nControl points (computed): {len(control_points)} points")
    print(f"Expected: {len(fit_points) + 2} points")
    print(f"Match: {'YES ✓' if len(control_points) == len(fit_points) + 2 else 'NO ✗'}")

    for i, p in enumerate(control_points):
        print(f"  P{i}: ({p[0]:.6f}, {p[1]:.6f})")

    print(f"\nKnot vector: {len(knots)} knots")
    print(f"  {knots}")

    # Compute parameters for fit points
    params = compute_parameters(fit_points)
    print(f"\nParameter values for fit points:")
    for i, u in enumerate(params):
        print(f"  p{i+1}: u = {u:.6f}")

    # Verify that spline passes through fit points
    print(f"\n{'='*80}")
    print("Verification: Does spline pass through fit points?")
    print('='*80)
    max_error = 0.0

    for i, (fit_point, u) in enumerate(zip(fit_points, params)):
        spline_point = evaluate_bspline(control_points, knots, degree, u)
        error = np.linalg.norm(spline_point - fit_point)
        max_error = max(max_error, error)

        status = "✓ PASS" if error < 1e-6 else "✗ FAIL"
        print(f"  p{i+1}: error = {error:.2e} {status}")

    print(f"\nMaximum interpolation error: {max_error:.2e}")

    if max_error < 1e-6:
        print("✓ SUCCESS: Spline passes through all fit points!")
    else:
        print("✗ FAILURE: Spline does NOT pass through all fit points!")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

    # Left plot: Full view
    ax = ax1

    # Plot fit points (red circles)
    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=14,
            markerfacecolor='none', markeredgewidth=2.5, label='Fit points (red circles)', zorder=3)

    # Label fit points
    for i, p in enumerate(fit_points):
        ax.text(p[0] + 0.15, p[1] + 0.15, f'p{i+1}', fontsize=12, color='red', fontweight='bold')

    # Plot control points (blue squares)
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
            label=f'Control points (blue squares) - {len(control_points)} points', zorder=2)

    # Label control points
    for i, p in enumerate(control_points):
        ax.text(p[0] + 0.1, p[1] - 0.2, f'P{i}', fontsize=9, color='blue')

    # Plot control polygon (dashed line)
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)

    # Plot spline curve (green)
    u_values = np.linspace(0, 1, 300)
    spline_points = np.array([evaluate_bspline(control_points, knots, degree, u) for u in u_values])
    ax.plot(spline_points[:, 0], spline_points[:, 1], 'g-', linewidth=3,
            label='NURBS spline (green)', zorder=1)

    ax.grid(True, alpha=0.3)
    ax.axis('equal')
    ax.legend(fontsize=10, loc='upper left')
    ax.set_title(f'Issue #253: n+2 Approach ({len(fit_points)} fit pts → {len(control_points)} ctrl pts)',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')

    # Right plot: Zoomed view to check interpolation accuracy
    ax = ax2

    # For each fit point, show a zoomed view around it
    for i, (fit_point, u) in enumerate(zip(fit_points, params)):
        spline_point = evaluate_bspline(control_points, knots, degree, u)

        # Plot fit point
        ax.plot(fit_point[0], fit_point[1], 'ro', markersize=12,
               markerfacecolor='none', markeredgewidth=2, zorder=3)
        ax.text(fit_point[0] + 0.05, fit_point[1] + 0.05, f'p{i+1}',
               fontsize=10, color='red', fontweight='bold')

        # Plot evaluated spline point (should overlap)
        ax.plot(spline_point[0], spline_point[1], 'gx', markersize=8,
               markeredgewidth=2, zorder=4)

    # Plot full spline
    ax.plot(spline_points[:, 0], spline_points[:, 1], 'g-', linewidth=2, alpha=0.7)

    # Plot control points
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=6, alpha=0.5)
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.2, linewidth=1)

    ax.grid(True, alpha=0.3)
    ax.axis('equal')
    ax.set_title('Interpolation Verification (green X should overlap red O)',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')

    plt.tight_layout()
    plt.savefig('/tmp/gh-issue-solver-1760730074922/experiments/issue253_n_plus_2_test.png',
                dpi=150, bbox_inches='tight')
    print(f"\nPlot saved to: experiments/issue253_n_plus_2_test.png")

    return max_error < 1e-6

if __name__ == "__main__":
    success = test_issue_253()
    exit(0 if success else 1)
