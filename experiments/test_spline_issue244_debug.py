#!/usr/bin/env python3
"""
Test script to reproduce and debug issue #244
The spline is not passing through all specified fit points (particularly p3)
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple

def basis_function(i: int, p: int, u: float, knots: np.ndarray) -> float:
    """
    Compute B-spline basis function N_{i,p}(u) using Cox-de Boor recursion formula
    This is a direct translation of the Pascal code in uzccommand_spline.pas
    """
    # Special case for clamped B-splines at the endpoint
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        # At the last knot value
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
    """Generate knot vector for n+2 control points (uniform internal knots)"""
    m = num_fit_points + p + 2  # Last knot index
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Interior knots: uniform spacing
    num_interior = num_fit_points - p + 1
    if num_interior > 0:
        for i in range(1, num_interior + 1):
            knots[p + i] = i / (num_interior + 1.0)

    # Clamped: repeat 1 (p+1) times at end
    for i in range(m - p, m + 1):
        knots[i] = 1.0

    return knots

def estimate_end_tangents(points: np.ndarray, params: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Estimate end tangent vectors from fit points"""
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

def convert_on_curve_points_to_control_points(degree: int, fit_points: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Convert fit points (points on curve) to control points
    Direct translation of the Pascal code
    """
    num_points = len(fit_points)

    # Handle edge cases
    if num_points < 2:
        return np.array([]), np.array([])

    if degree >= num_points or degree < 1:
        return fit_points.copy(), np.array([])

    if degree == 1 or num_points == 2:
        return fit_points.copy(), np.array([])

    # CAD-style interpolation with end tangent constraints
    params = compute_parameters(fit_points)
    start_tangent, end_tangent = estimate_end_tangents(fit_points, params)

    # Number of control points = numPoints + 2
    num_control_points = num_points + 2
    control_points = np.zeros((num_control_points, fit_points.shape[1]))

    # Set first endpoint control point
    control_points[0] = fit_points[0]

    # Set last endpoint control point
    control_points[num_control_points - 1] = fit_points[num_points - 1]

    # Compute alpha and beta
    if num_points > 1:
        alpha = (params[1] - params[0]) / 3.0
        beta = (params[num_points-1] - params[num_points-2]) / 3.0
    else:
        alpha = 0.1
        beta = 0.1

    # Set tangent-based control points
    control_points[1] = fit_points[0] + alpha * start_tangent
    control_points[num_control_points - 2] = fit_points[num_points - 1] - beta * end_tangent

    # Generate knot vector for n+2 control points
    knots = generate_knot_vector_for_n_plus_2(num_points, degree)

    # Solve for interior control points
    num_interior_fit = num_points - 2  # D[1] through D[numPoints-2]
    num_interior_ctrl = num_points - 2  # P[2] through P[numControlPoints-3]

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        # Build system: A * P_interior = b
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        b = np.zeros((num_interior_fit, fit_points.shape[1]))

        for j in range(num_interior_fit):
            fit_idx = j + 1  # D[1], D[2], ..., D[numPoints-2]
            u = params[fit_idx]

            # Contribution from known control points
            contrib = np.zeros(fit_points.shape[1])

            # P[0]
            basis = basis_function(0, degree, u, knots)
            contrib += basis * control_points[0]

            # P[1]
            basis = basis_function(1, degree, u, knots)
            contrib += basis * control_points[1]

            # P[numControlPoints-2]
            basis = basis_function(num_control_points - 2, degree, u, knots)
            contrib += basis * control_points[num_control_points - 2]

            # P[numControlPoints-1]
            basis = basis_function(num_control_points - 1, degree, u, knots)
            contrib += basis * control_points[num_control_points - 1]

            # Right-hand side
            b[j] = fit_points[fit_idx] - contrib

            # Coefficients for unknown control points P[2..numControlPoints-3]
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
            print(f"Matrix A determinant: {np.linalg.det(A)}")
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

def test_spline_interpolation():
    """Test the spline interpolation with 4 points as mentioned in issue #244"""
    print("="*80)
    print("Testing NURBS spline interpolation for issue #244")
    print("="*80)

    # Test case: 4 fit points (as shown in the issue screenshots)
    # These are approximate coordinates from the screenshot
    fit_points = np.array([
        [0.0, 0.0],      # p1 (bottom left, red circle)
        [2.0, -1.0],     # p2 (bottom right, red circle)
        [3.5, 1.5],      # p3 (top right, red circle) - THIS ONE FAILS
        [1.0, 2.0],      # p4 (top left, red circle)
    ])

    degree = 3

    print(f"\nFit points (red circles - points spline should pass through):")
    for i, p in enumerate(fit_points):
        print(f"  p{i+1}: ({p[0]:.2f}, {p[1]:.2f})")

    print(f"\nDegree: {degree}")

    # Convert to control points
    control_points, knots = convert_on_curve_points_to_control_points(degree, fit_points)

    print(f"\nControl points (blue squares - {len(control_points)} points):")
    for i, p in enumerate(control_points):
        print(f"  P{i}: ({p[0]:.6f}, {p[1]:.6f})")

    print(f"\nKnot vector ({len(knots)} knots):")
    print(f"  {knots}")

    # Compute parameters for fit points
    params = compute_parameters(fit_points)
    print(f"\nParameter values for fit points:")
    for i, u in enumerate(params):
        print(f"  p{i+1}: u = {u:.6f}")

    # Verify that spline passes through fit points
    print(f"\nVerification: Does spline pass through fit points?")
    print("="*80)
    max_error = 0.0

    for i, (fit_point, u) in enumerate(zip(fit_points, params)):
        spline_point = evaluate_bspline(control_points, knots, degree, u)
        error = np.linalg.norm(spline_point - fit_point)
        max_error = max(max_error, error)

        status = "✓ PASS" if error < 1e-6 else "✗ FAIL"
        print(f"  p{i+1}: error = {error:.2e} {status}")
        print(f"       Expected: ({fit_point[0]:.6f}, {fit_point[1]:.6f})")
        print(f"       Got:      ({spline_point[0]:.6f}, {spline_point[1]:.6f})")

    print(f"\nMaximum interpolation error: {max_error:.2e}")

    if max_error < 1e-6:
        print("✓ SUCCESS: Spline passes through all fit points!")
    else:
        print("✗ FAILURE: Spline does NOT pass through all fit points!")

    # Visualize
    plt.figure(figsize=(12, 8))

    # Plot fit points (red circles)
    plt.plot(fit_points[:, 0], fit_points[:, 1], 'ro', markersize=12,
             markerfacecolor='none', markeredgewidth=2, label='Fit points (red circles)', zorder=3)

    # Label fit points
    for i, p in enumerate(fit_points):
        plt.text(p[0] + 0.1, p[1] + 0.1, f'p{i+1}', fontsize=12, color='red')

    # Plot control points (blue squares)
    plt.plot(control_points[:, 0], control_points[:, 1], 'bs', markersize=8,
             label='Control points (blue squares)', zorder=2)

    # Label control points
    for i, p in enumerate(control_points):
        plt.text(p[0] + 0.1, p[1] - 0.2, f'P{i}', fontsize=10, color='blue')

    # Plot control polygon (dashed line)
    plt.plot(control_points[:, 0], control_points[:, 1], 'b--', alpha=0.3, linewidth=1)

    # Plot spline curve (green)
    u_values = np.linspace(0, 1, 200)
    spline_points = np.array([evaluate_bspline(control_points, knots, degree, u) for u in u_values])
    plt.plot(spline_points[:, 0], spline_points[:, 1], 'g-', linewidth=2,
             label='NURBS spline (green)', zorder=1)

    plt.grid(True, alpha=0.3)
    plt.axis('equal')
    plt.legend(fontsize=10)
    plt.title('NURBS Spline Interpolation - Issue #244', fontsize=14, fontweight='bold')
    plt.xlabel('X')
    plt.ylabel('Y')

    plt.tight_layout()
    plt.savefig('/tmp/gh-issue-solver-1760726112106/experiments/spline_issue244_test.png', dpi=150)
    print(f"\nPlot saved to: experiments/spline_issue244_test.png")

    # Print basis matrix at parameter values (for debugging)
    print(f"\n" + "="*80)
    print("Basis function matrix (for debugging):")
    print("="*80)
    n_ctrl = len(control_points)
    basis_matrix = np.zeros((len(params), n_ctrl))
    for i, u in enumerate(params):
        for j in range(n_ctrl):
            basis_matrix[i, j] = basis_function(j, degree, u, knots)

    print("Rows = parameter values, Columns = control points")
    print(basis_matrix)
    print(f"\nMatrix determinant (for interior unknowns): will compute below...")

    # Check the linear system specifically
    num_interior_fit = len(fit_points) - 2
    num_interior_ctrl = len(control_points) - 4  # We know P[0], P[1], P[n-2], P[n-1]

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        A = np.zeros((num_interior_fit, num_interior_ctrl))
        for j in range(num_interior_fit):
            fit_idx = j + 1
            u = params[fit_idx]
            for k in range(num_interior_ctrl):
                ctrl_idx = k + 2
                A[j, k] = basis_function(ctrl_idx, degree, u, knots)

        print(f"\nLinear system matrix A ({num_interior_fit} x {num_interior_ctrl}):")
        print(A)
        print(f"Determinant: {np.linalg.det(A):.6e}")
        print(f"Condition number: {np.linalg.cond(A):.6e}")

if __name__ == "__main__":
    test_spline_interpolation()
