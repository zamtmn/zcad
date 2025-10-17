#!/usr/bin/env python3
"""
Debug script for issue #244: Spline not passing through point p3.

The problem according to the latest comment:
- With 4 points (p1, p2, p3, p4), the spline doesn't pass through p3
- The algorithm should generate 6 control points for 4 fit points with degree 3
- But the spline is not interpolating all points correctly

This script will test the algorithm to find the root cause.
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

    Following the Pascal code implementation.
    """
    m = n + p + 2  # Last knot index
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Interior knots: uniform spacing
    # Number of interior knots: (n+2) - p - 1 = n - p + 1
    num_interior = n - p + 1
    if num_interior > 0:
        for i in range(1, num_interior + 1):
            knots[p + i] = i / (num_interior + 1.0)

    # Clamped: repeat 1 (p+1) times at end
    for i in range(m - p, m + 1):
        knots[i] = 1.0

    return knots

def cox_de_boor(i, p, u, knots):
    """Cox-de Boor recursion formula for B-spline basis function.

    Matching the Pascal implementation.
    """
    num_ctrl_pts = len(knots) - p - 2

    # Special case for endpoint
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

    # Recursive formula
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
    """Estimate end tangent vectors from fit points."""
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

def convert_on_curve_points_to_control_points(fit_points, degree=3):
    """
    Convert fit points to control points following the Pascal implementation.

    This should generate n+2 control points for n fit points.
    """
    n = len(fit_points)

    # Handle edge cases
    if n < 2:
        return fit_points, None

    if degree >= n or degree < 1:
        return fit_points, None

    if degree == 1:
        return fit_points, None

    if n == 2:
        return fit_points, None

    # Compute parameters
    params = chord_length_parameterization(fit_points)
    print(f"\nParameters: {params}")

    # Estimate end tangents
    start_tangent, end_tangent = estimate_end_tangents(fit_points, params)
    print(f"Start tangent: {start_tangent}")
    print(f"End tangent: {end_tangent}")

    # Scaling factors
    alpha = (params[1] - params[0]) / 3.0
    beta = (params[n-1] - params[n-2]) / 3.0
    print(f"Alpha: {alpha}, Beta: {beta}")

    # Number of control points = n + 2
    num_ctrl = n + 2
    control_points = np.zeros((num_ctrl, fit_points.shape[1]))

    # Set endpoint control points
    control_points[0] = fit_points[0]
    control_points[num_ctrl-1] = fit_points[n-1]

    # Set tangent control points
    control_points[1] = fit_points[0] + alpha * start_tangent
    control_points[num_ctrl-2] = fit_points[n-1] - beta * end_tangent

    print(f"\nEndpoint and tangent control points:")
    print(f"P[0] = {control_points[0]}")
    print(f"P[1] = {control_points[1]}")
    print(f"P[{num_ctrl-2}] = {control_points[num_ctrl-2]}")
    print(f"P[{num_ctrl-1}] = {control_points[num_ctrl-1]}")

    # Generate knot vector
    knots = generate_knot_vector_for_n_plus_2(n, degree)
    print(f"\nKnot vector (length={len(knots)}): {knots}")

    # Solve for interior control points
    # We need to fit interior fit points D[1..n-2] at params[1..n-2]
    num_interior_fit = n - 2  # D[1] through D[n-2]
    num_interior_ctrl = n - 2  # P[2] through P[n-1]

    print(f"\nNumber of interior fit points: {num_interior_fit}")
    print(f"Number of interior control points to solve: {num_interior_ctrl}")

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        # Build system: A * P_interior = b
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        b = np.zeros((num_interior_fit, fit_points.shape[1]))

        for j in range(num_interior_fit):
            fit_idx = j + 1  # D[1], D[2], ..., D[n-2]
            u = params[fit_idx]

            print(f"\nFit point D[{fit_idx}] = {fit_points[fit_idx]} at u={u}")

            # Contribution from known control points
            contrib = np.zeros(fit_points.shape[1])

            basis_0 = cox_de_boor(0, degree, u, knots)
            contrib += basis_0 * control_points[0]
            print(f"  N(0) = {basis_0:.6f}")

            basis_1 = cox_de_boor(1, degree, u, knots)
            contrib += basis_1 * control_points[1]
            print(f"  N(1) = {basis_1:.6f}")

            basis_n2 = cox_de_boor(num_ctrl-2, degree, u, knots)
            contrib += basis_n2 * control_points[num_ctrl-2]
            print(f"  N({num_ctrl-2}) = {basis_n2:.6f}")

            basis_n1 = cox_de_boor(num_ctrl-1, degree, u, knots)
            contrib += basis_n1 * control_points[num_ctrl-1]
            print(f"  N({num_ctrl-1}) = {basis_n1:.6f}")

            print(f"  Known contribution: {contrib}")

            # Right-hand side
            b[j] = fit_points[fit_idx] - contrib
            print(f"  RHS b[{j}] = {b[j]}")

            # Coefficients for unknown control points
            basis_values = []
            for k in range(num_interior_ctrl):
                ctrl_idx = k + 2
                basis = cox_de_boor(ctrl_idx, degree, u, knots)
                A[j, k] = basis
                basis_values.append(f"N({ctrl_idx})={basis:.6f}")
            print(f"  Unknown basis: {', '.join(basis_values)}")

        print(f"\n{'='*70}")
        print("System matrix A:")
        print(A)
        print(f"\nRight-hand side b:")
        print(b)
        print(f"\nMatrix rank: {np.linalg.matrix_rank(A)} (should be {min(num_interior_fit, num_interior_ctrl)})")
        print(f"Condition number: {np.linalg.cond(A):.2e}")

        # Solve linear system
        try:
            for dim in range(fit_points.shape[1]):
                control_points[2:num_ctrl-2, dim] = np.linalg.solve(A, b[:, dim])
            print("\n✓ Linear system solved successfully")
        except np.linalg.LinAlgError as e:
            print(f"\n✗ Linear system solve failed: {e}")
            return None, None

        print(f"\nSolved interior control points:")
        for k in range(num_interior_ctrl):
            print(f"P[{k+2}] = {control_points[k+2]}")

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

def test_4_points():
    """Test with 4 fit points - the problematic case."""
    # Example fit points (like in the user's images)
    fit_points = np.array([
        [100, 400],   # p1
        [300, 450],   # p2
        [500, 300],   # p3 - THIS POINT IS NOT INTERPOLATED
        [600, 200]    # p4
    ])

    degree = 3

    print("="*70)
    print("DEBUGGING ISSUE #244: Spline not passing through p3")
    print("="*70)
    print(f"\nFit points (should all be interpolated):")
    for i, pt in enumerate(fit_points):
        print(f"  p{i+1} = D[{i}] = {pt}")

    print(f"\nDegree: {degree}")
    print(f"Expected: {len(fit_points)+2} control points")

    # Compute control points
    control_points, knots = convert_on_curve_points_to_control_points(fit_points, degree)

    if control_points is None:
        print("\n✗ Failed to compute control points")
        return

    print(f"\n{'='*70}")
    print("FINAL CONTROL POINTS:")
    print("="*70)
    for i, pt in enumerate(control_points):
        print(f"P[{i}] = {pt}")

    # Verify interpolation
    print(f"\n{'='*70}")
    print("VERIFICATION: Does spline pass through fit points?")
    print("="*70)

    params = chord_length_parameterization(fit_points)
    max_error = 0.0
    errors = []

    for i, (u, fit_pt) in enumerate(zip(params, fit_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - fit_pt)
        errors.append(error)
        max_error = max(max_error, error)

        status = "✓" if error < 1e-3 else "✗ FAIL"
        print(f"  {status} p{i+1} at u={u:.6f}: expected={fit_pt}, curve={curve_pt}, error={error:.2e}")

    print(f"\nMaximum error: {max_error:.2e}")
    if max_error < 1e-3:
        print("✓✓✓ SUCCESS: All points interpolated correctly!")
    else:
        print("✗✗✗ FAILURE: Some points not interpolated!")
        for i, err in enumerate(errors):
            if err >= 1e-3:
                print(f"     Point p{i+1} error: {err:.2e}")

    # Plot
    curve = evaluate_bspline(control_points, knots, degree, num_samples=200)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

    # Main plot
    ax1.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=15,
             label='Fit points (red circles)', zorder=4, markerfacecolor='none',
             markeredgewidth=3)

    ax1.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
             label='Control points (blue squares)', zorder=3)

    ax1.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3,
             linewidth=1, label='Control polygon')

    ax1.plot(curve[:, 0], curve[:, 1], 'g-', linewidth=3,
             label='B-spline curve (green)', zorder=2)

    # Annotate fit points
    for i, pt in enumerate(fit_points):
        ax1.annotate(f'p{i+1}', pt, xytext=(10, 10), textcoords='offset points',
                    fontsize=12, color='red', fontweight='bold')

    # Annotate control points
    for i, pt in enumerate(control_points):
        ax1.annotate(f'P{i}', pt, xytext=(5, -15), textcoords='offset points',
                    fontsize=9, color='blue')

    # Highlight p3 if it has high error
    if errors[2] >= 1e-3:
        ax1.plot(fit_points[2, 0], fit_points[2, 1], 'rx', markersize=20,
                markeredgewidth=4, label='p3 NOT INTERPOLATED')

    ax1.grid(True, alpha=0.3)
    ax1.legend(loc='best')
    ax1.axis('equal')
    ax1.set_title('Spline Interpolation Test', fontsize=14, fontweight='bold')
    ax1.set_xlabel('X')
    ax1.set_ylabel('Y')

    # Error plot
    ax2.bar(range(1, len(errors)+1), errors, color=['green' if e < 1e-3 else 'red' for e in errors])
    ax2.axhline(y=1e-3, color='orange', linestyle='--', label='Threshold (1e-3)')
    ax2.set_xlabel('Point')
    ax2.set_ylabel('Interpolation Error')
    ax2.set_title('Interpolation Error per Point')
    ax2.set_yscale('log')
    ax2.legend()
    ax2.grid(True, alpha=0.3, axis='y')
    ax2.set_xticks(range(1, len(errors)+1))
    ax2.set_xticklabels([f'p{i}' for i in range(1, len(errors)+1)])

    plt.tight_layout()
    plt.savefig('experiments/issue244_debug.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Plot saved to: experiments/issue244_debug.png")

    plt.show()

if __name__ == '__main__':
    test_4_points()
