#!/usr/bin/env python3
"""
Test script to verify the correct spline interpolation algorithm for issue #244.

The problem: Need to compute control points such that a NURBS spline of degree 3
passes through n specified fit points, generating n+2 control points.

This follows CAD-style spline interpolation with end tangent constraints.
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

    # Calculate total chord length
    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize to [0,1]
    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n-1)

    return params

def generate_knot_vector_for_n_plus_2(n, p):
    """Generate knot vector for n+2 control points and degree p.

    Args:
        n: number of fit points
        p: degree

    Returns:
        Knot vector with (n+2) + p + 1 = n + p + 3 knots
    """
    m = n + p + 2  # Last knot index: (n+2-1) + p + 1 = n + p + 2
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times
    knots[:p+1] = 0.0

    # Interior knots: uniform spacing
    # We have (n+2) control points, so (n+2) - p - 1 = n - p + 1 interior knots
    num_interior = n - p + 1
    if num_interior > 0:
        for i in range(1, num_interior + 1):
            knots[p + i] = i / (num_interior + 1)

    # Clamped: repeat 1 (p+1) times
    knots[n + p + 2 - p:] = 1.0

    return knots

def cox_de_boor(i, p, u, knots):
    """Cox-de Boor recursion formula for B-spline basis function."""
    # Special case at endpoint
    if abs(u - knots[-1]) < 1e-10:
        num_ctrl = len(knots) - p - 2
        return 1.0 if i == num_ctrl else 0.0

    # Degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    # Recursive
    left_denom = knots[i+p] - knots[i]
    right_denom = knots[i+p+1] - knots[i+1]

    left_term = 0.0
    if abs(left_denom) > 1e-10:
        left_term = ((u - knots[i]) / left_denom) * cox_de_boor(i, p-1, u, knots)

    right_term = 0.0
    if abs(right_denom) > 1e-10:
        right_term = ((knots[i+p+1] - u) / right_denom) * cox_de_boor(i+1, p-1, u, knots)

    return left_term + right_term

def estimate_end_tangents(points, params):
    """Estimate tangent vectors at curve endpoints."""
    n = len(points)

    # Start tangent
    delta = params[1] - params[0]
    if abs(delta) > 0.0001:
        start_tangent = (points[1] - points[0]) / delta
    else:
        start_tangent = points[1] - points[0]

    # End tangent
    delta = params[n-1] - params[n-2]
    if abs(delta) > 0.0001:
        end_tangent = (points[n-1] - points[n-2]) / delta
    else:
        end_tangent = points[n-1] - points[n-2]

    return start_tangent, end_tangent

def interpolate_with_end_tangents(fit_points, degree=3):
    """
    Compute control points for spline interpolation with end tangent constraints.

    Generates n+2 control points for n fit points.

    Following Piegl & Tiller "NURBS Book" chapter 9.2.2:
    Global curve interpolation with end derivatives.
    """
    n = len(fit_points)

    if n < 2:
        return fit_points, None

    # Compute parameters
    params = chord_length_parameterization(fit_points)

    # Estimate tangents
    start_tangent, end_tangent = estimate_end_tangents(fit_points, params)

    # Scaling factors for tangent control points
    alpha = (params[1] - params[0]) / 3.0
    beta = (params[n-1] - params[n-2]) / 3.0

    # Generate knot vector for n+2 control points
    knots = generate_knot_vector_for_n_plus_2(n, degree)

    print(f"Fit points: {n}")
    print(f"Control points: {n+2}")
    print(f"Knot vector length: {len(knots)}")
    print(f"Knots: {knots}")

    # Build the interpolation system
    # We need to solve for n+2 control points P[0..n+1]
    #
    # Constraints:
    # 1. C(u0) = D[0]  -> P[0] + sum N_i(u0)*P[i] = D[0]
    # 2. C'(u0) = T_start  -> sum N'_i(u0)*P[i] = T_start
    # 3. C(u1) = D[1]
    # ...
    # n. C(u_{n-1}) = D[n-1]
    # n+1. C'(u_{n-1}) = T_end
    #
    # This gives us n equations for curve points + 2 for tangents = n+2 equations
    # for n+2 unknowns

    # For simplicity, we'll use the approach from the current implementation:
    # Set endpoints directly and tangent control points, then solve for interior

    num_ctrl = n + 2
    control_points = np.zeros((num_ctrl, fit_points.shape[1]))

    # Set endpoint control points
    control_points[0] = fit_points[0]
    control_points[num_ctrl-1] = fit_points[n-1]

    # Set tangent control points
    control_points[1] = fit_points[0] + alpha * start_tangent
    control_points[num_ctrl-2] = fit_points[n-1] - beta * end_tangent

    # For interior control points, we need to solve a system
    # The spline should pass through fit_points[1..n-2] at params[1..n-2]
    #
    # C(u_j) = sum_{i=0}^{n+1} N_i,p(u_j) * P_i = D_j
    #
    # We know P[0], P[1], P[n], P[n+1], so we solve for P[2..n-1]

    num_interior_fit = n - 2  # D[1] through D[n-2]
    num_interior_ctrl = n - 2  # P[2] through P[n-1]

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        # Build system: A * P_interior = b
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        b = np.zeros((num_interior_fit, fit_points.shape[1]))

        for j in range(num_interior_fit):
            fit_idx = j + 1  # D[1], D[2], ..., D[n-2]
            u = params[fit_idx]

            # Contribution from known control points
            contrib = np.zeros(fit_points.shape[1])
            contrib += cox_de_boor(0, degree, u, knots) * control_points[0]
            contrib += cox_de_boor(1, degree, u, knots) * control_points[1]
            contrib += cox_de_boor(num_ctrl-2, degree, u, knots) * control_points[num_ctrl-2]
            contrib += cox_de_boor(num_ctrl-1, degree, u, knots) * control_points[num_ctrl-1]

            # Right-hand side
            b[j] = fit_points[fit_idx] - contrib

            # Coefficients for unknown control points P[2..n-1]
            for k in range(num_interior_ctrl):
                ctrl_idx = k + 2  # P[2], P[3], ..., P[n-1]
                A[j, k] = cox_de_boor(ctrl_idx, degree, u, knots)

        print(f"\nSystem matrix A ({num_interior_fit} x {num_interior_ctrl}):")
        print(A)
        print(f"\nRank of A: {np.linalg.matrix_rank(A)}")
        print(f"Condition number: {np.linalg.cond(A):.2e}")

        # Solve for interior control points
        try:
            for dim in range(fit_points.shape[1]):
                control_points[2:num_ctrl-2, dim] = np.linalg.solve(A, b[:, dim])
        except np.linalg.LinAlgError as e:
            print(f"Warning: Linear system solve failed: {e}")
            print("Using fallback: placing control points at fit points")
            for k in range(num_interior_ctrl):
                control_points[k+2] = fit_points[k+1]

    return control_points, knots

def evaluate_bspline(control_points, knots, degree, num_samples=100):
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

def test_4_fit_points():
    """Test with 4 fit points, should generate 6 control points."""
    # Example from the issue: 4 fit points (red circles)
    fit_points = np.array([
        [100, 200],   # Bottom left
        [300, 250],   # Top middle
        [500, 100],   # Bottom right
        [600, 400]    # Top right
    ])

    degree = 3

    print("="*70)
    print("TEST: Spline interpolation with end tangent constraints")
    print("="*70)
    print(f"\nFit points (n={len(fit_points)}):")
    for i, pt in enumerate(fit_points):
        print(f"  D[{i}]: {pt}")

    # Compute control points
    control_points, knots = interpolate_with_end_tangents(fit_points, degree)

    print(f"\nControl points (n+2={len(control_points)}):")
    for i, pt in enumerate(control_points):
        print(f"  P[{i}]: {pt}")

    # Verify interpolation
    print(f"\n" + "="*70)
    print("VERIFICATION: Does spline pass through fit points?")
    print("="*70)

    params = chord_length_parameterization(fit_points)
    for i, (u, fit_pt) in enumerate(zip(params, fit_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - fit_pt)
        status = "✓" if error < 1e-3 else "✗"
        print(f"  {status} D[{i}] at u={u:.4f}: curve={curve_pt}, fit={fit_pt}, error={error:.2e}")

    # Plot
    curve = evaluate_bspline(control_points, knots, degree, num_samples=200)

    plt.figure(figsize=(14, 8))

    # Fit points (red circles)
    plt.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=12,
             label='Fit points (red circles)', zorder=4, markeredgewidth=2,
             markerfacecolor='none', linewidth=2)

    # Control points (blue squares)
    plt.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
             label='Control points (blue squares)', zorder=3)

    # Control polygon (dashed line)
    plt.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.4,
             linewidth=1, label='Control polygon')

    # B-spline curve (green)
    plt.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3,
             label='B-spline curve (green)', zorder=2)

    # Annotate points
    for i, pt in enumerate(fit_points):
        plt.annotate(f'D{i}', pt, xytext=(5, 5), textcoords='offset points',
                    fontsize=10, color='red', fontweight='bold')

    for i, pt in enumerate(control_points):
        plt.annotate(f'P{i}', pt, xytext=(5, -15), textcoords='offset points',
                    fontsize=9, color='blue')

    plt.grid(True, alpha=0.3)
    plt.legend(loc='best', fontsize=11)
    plt.axis('equal')
    plt.title(f'Spline Interpolation: {len(fit_points)} fit points → {len(control_points)} control points', fontsize=14)
    plt.xlabel('X', fontsize=12)
    plt.ylabel('Y', fontsize=12)

    plt.tight_layout()
    plt.savefig('/tmp/gh-issue-solver-1760723881535/experiments/issue244_solution.png', dpi=150)
    print(f"\n✓ Plot saved to: experiments/issue244_solution.png")

    return control_points, knots

if __name__ == '__main__':
    test_4_fit_points()
