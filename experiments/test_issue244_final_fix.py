#!/usr/bin/env python3
"""
Final test for issue #244: Spline not passing through all points.

ROOT CAUSE IDENTIFIED:
======================
The control points were computed correctly by ConvertOnCurvePointsToControlPointsArray,
BUT UpdateSplineFromPoints was discarding the knot vector used during computation
and generating a DIFFERENT knot vector using uniform spacing.

Since control points are computed to work with a SPECIFIC knot vector, using a
different knot vector causes the spline to NOT pass through the intended points.

THE FIX:
========
1. Modified ConvertOnCurvePointsToControlPointsArray to return the knot vector
   it used for computing control points (via output parameter AKnots)

2. Modified UpdateSplineFromPoints to USE the returned knot vector instead of
   generating a new one with uniform spacing

This ensures control points and knot vector are always consistent, guaranteeing
that the spline passes through all specified fit points.
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

def generate_uniform_knot_vector(num_ctrl_pts, degree):
    """Generate UNIFORM knot vector (the WRONG one that was being used)."""
    m = num_ctrl_pts + degree  # n + p where n = num_ctrl_pts - 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0
    for i in range(degree + 1):
        knots[i] = 0.0

    # UNIFORM interior knots (this is the bug!)
    num_interior = num_ctrl_pts - degree - 1
    for i in range(1, num_interior + 1):
        knots[degree + i] = i / (num_ctrl_pts - degree)

    # Clamped: repeat 1
    for i in range(num_ctrl_pts, m + 1):
        knots[i] = 1.0

    return knots

def generate_knot_vector_for_n_plus_2(num_fit_pts, degree):
    """Generate CORRECT knot vector for n+2 control points (used in interpolation)."""
    m = num_fit_pts + degree + 2  # Last knot index
    knots = np.zeros(m + 1)

    # Clamped: repeat 0
    for i in range(degree + 1):
        knots[i] = 0.0

    # Interior knots: uniform spacing for n+2 control points
    num_interior = num_fit_pts - degree + 1
    if num_interior > 0:
        for i in range(1, num_interior + 1):
            knots[degree + i] = i / (num_interior + 1.0)

    # Clamped: repeat 1
    for i in range(m - degree, m + 1):
        knots[i] = 1.0

    return knots

def cox_de_boor(i, p, u, knots):
    """Cox-de Boor recursion formula for B-spline basis function."""
    num_ctrl_pts = len(knots) - p - 2

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

def estimate_end_tangents(points, params):
    """Estimate tangent vectors at endpoints."""
    n = len(points)

    delta = params[1] - params[0]
    if abs(delta) > 0.0001:
        start_tangent = (points[1] - points[0]) / delta
    else:
        start_tangent = points[1] - points[0]

    delta = params[n-1] - params[n-2]
    if abs(delta) > 0.0001:
        end_tangent = (points[n-1] - points[n-2]) / delta
    else:
        end_tangent = points[n-1] - points[n-2]

    return start_tangent, end_tangent

def compute_control_points(fit_points, degree=3):
    """Compute control points using the correct algorithm."""
    n = len(fit_points)
    params = chord_length_parameterization(fit_points)
    start_tangent, end_tangent = estimate_end_tangents(fit_points, params)

    alpha = (params[1] - params[0]) / 3.0
    beta = (params[n-1] - params[n-2]) / 3.0

    num_ctrl = n + 2
    control_points = np.zeros((num_ctrl, fit_points.shape[1]))

    control_points[0] = fit_points[0]
    control_points[num_ctrl-1] = fit_points[n-1]
    control_points[1] = fit_points[0] + alpha * start_tangent
    control_points[num_ctrl-2] = fit_points[n-1] - beta * end_tangent

    knots = generate_knot_vector_for_n_plus_2(n, degree)

    num_interior_fit = n - 2
    num_interior_ctrl = n - 2

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        b = np.zeros((num_interior_fit, fit_points.shape[1]))

        for j in range(num_interior_fit):
            fit_idx = j + 1
            u = params[fit_idx]

            contrib = np.zeros(fit_points.shape[1])
            contrib += cox_de_boor(0, degree, u, knots) * control_points[0]
            contrib += cox_de_boor(1, degree, u, knots) * control_points[1]
            contrib += cox_de_boor(num_ctrl-2, degree, u, knots) * control_points[num_ctrl-2]
            contrib += cox_de_boor(num_ctrl-1, degree, u, knots) * control_points[num_ctrl-1]

            b[j] = fit_points[fit_idx] - contrib

            for k in range(num_interior_ctrl):
                ctrl_idx = k + 2
                A[j, k] = cox_de_boor(ctrl_idx, degree, u, knots)

        for dim in range(fit_points.shape[1]):
            control_points[2:num_ctrl-2, dim] = np.linalg.solve(A, b[:, dim])

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

def test_knot_vector_bug():
    """Demonstrate the bug and the fix."""
    fit_points = np.array([
        [100, 400],
        [300, 450],
        [500, 300],
        [600, 200]
    ])

    degree = 3

    print("="*80)
    print("ISSUE #244: Spline not passing through point p3")
    print("="*80)

    print(f"\nFit points (points the spline should pass through):")
    for i, pt in enumerate(fit_points):
        print(f"  p{i+1} = {pt}")

    # Compute control points (this generates 6 control points for 4 fit points)
    control_points, correct_knots = compute_control_points(fit_points, degree)

    print(f"\nControl points computed (n+2 = {len(control_points)}):")
    for i, pt in enumerate(control_points):
        print(f"  P[{i}] = {pt}")

    print(f"\nCORRECT knot vector (used during control point computation):")
    print(f"  {correct_knots}")
    print(f"  Length: {len(correct_knots)}")

    # Generate the WRONG knot vector (uniform spacing for 6 control points)
    wrong_knots = generate_uniform_knot_vector(len(control_points), degree)

    print(f"\nWRONG knot vector (uniform spacing, used in buggy code):")
    print(f"  {wrong_knots}")
    print(f"  Length: {len(wrong_knots)}")

    print(f"\n{'='*80}")
    print("VERIFICATION: Using CORRECT knot vector")
    print("="*80)

    params = chord_length_parameterization(fit_points)
    errors_correct = []

    for i, (u, fit_pt) in enumerate(zip(params, fit_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, correct_knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - fit_pt)
        errors_correct.append(error)
        status = "✓" if error < 1e-3 else "✗ FAIL"
        print(f"  {status} p{i+1} at u={u:.6f}: error={error:.2e}")

    print(f"\n{'='*80}")
    print("VERIFICATION: Using WRONG knot vector (THE BUG)")
    print("="*80)

    errors_wrong = []

    for i, (u, fit_pt) in enumerate(zip(params, fit_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, wrong_knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - fit_pt)
        errors_wrong.append(error)
        status = "✓" if error < 1e-3 else "✗ FAIL"
        print(f"  {status} p{i+1} at u={u:.6f}: error={error:.2e}")

    # Plot comparison
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # LEFT: Correct (with correct knots)
    ax = axes[0]
    curve_correct = evaluate_bspline(control_points, correct_knots, degree, 200)

    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=15,
            markerfacecolor='none', markeredgewidth=3, label='Fit points', zorder=4)
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
            label='Control points', zorder=3)
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)
    ax.plot(curve_correct[:, 0], curve_correct[:, 1], 'g-', linewidth=3,
            label='Spline (CORRECT)', zorder=2)

    for i, pt in enumerate(fit_points):
        ax.annotate(f'p{i+1}', pt, xytext=(10, 10), textcoords='offset points',
                   fontsize=12, color='red', fontweight='bold')

    ax.grid(True, alpha=0.3)
    ax.legend()
    ax.set_title('✓ CORRECT: Using matching knot vector\n(Spline passes through ALL points)',
                 fontsize=12, fontweight='bold', color='green')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.axis('equal')

    # RIGHT: Wrong (with uniform knots)
    ax = axes[1]
    curve_wrong = evaluate_bspline(control_points, wrong_knots, degree, 200)

    ax.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=15,
            markerfacecolor='none', markeredgewidth=3, label='Fit points', zorder=4)
    ax.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=10,
            label='Control points', zorder=3)
    ax.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)
    ax.plot(curve_wrong[:, 0], curve_wrong[:, 1], 'r-', linewidth=3,
            label='Spline (WRONG)', zorder=2)

    for i, pt in enumerate(fit_points):
        ax.annotate(f'p{i+1}', pt, xytext=(10, 10), textcoords='offset points',
                   fontsize=12, color='red', fontweight='bold')

    # Mark points with high error
    for i, err in enumerate(errors_wrong):
        if err >= 1e-3:
            ax.plot(fit_points[i, 0], fit_points[i, 1], 'rx', markersize=25,
                   markeredgewidth=4, zorder=5)

    ax.grid(True, alpha=0.3)
    ax.legend()
    ax.set_title('✗ BUG: Using different knot vector\n(Spline does NOT pass through points)',
                 fontsize=12, fontweight='bold', color='red')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.axis('equal')

    plt.suptitle('Issue #244: Knot Vector Mismatch Bug', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('experiments/issue244_knot_mismatch_bug.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Plot saved to: experiments/issue244_knot_mismatch_bug.png")

    print(f"\n{'='*80}")
    print("SUMMARY")
    print("="*80)
    print(f"Max error with CORRECT knots: {max(errors_correct):.2e}")
    print(f"Max error with WRONG knots:   {max(errors_wrong):.2e}")
    print()
    if max(errors_correct) < 1e-3:
        print("✓ With correct knots: ALL points interpolated!")
    else:
        print("✗ With correct knots: Interpolation FAILED!")

    if max(errors_wrong) < 1e-3:
        print("✓ With wrong knots: ALL points interpolated!")
    else:
        print("✗ With wrong knots: Interpolation FAILED!")

    print(f"\n{'='*80}")
    print("THE FIX")
    print("="*80)
    print("""
Modified ConvertOnCurvePointsToControlPointsArray to return the knot vector
via an output parameter (AKnots), and modified UpdateSplineFromPoints to
use that returned knot vector instead of generating a new one.

This ensures control points and knot vector are ALWAYS consistent, which
is essential for proper spline interpolation.
""")

if __name__ == '__main__':
    test_knot_vector_bug()
