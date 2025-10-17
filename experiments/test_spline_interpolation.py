#!/usr/bin/env python3
"""
Test B-spline global interpolation algorithm to diagnose the (0,0,0) issue.

The problem: When the user clicks 4 points and presses Enter, the spline's
last point moves to (0,0,0) instead of staying at the 4th point.

This script tests the algorithm to find the root cause.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import splprep, splev

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

def generate_knot_vector_averaging(n, p, params):
    """Generate knot vector using averaging method for global interpolation.

    Args:
        n: number of data points minus 1 (n = numPoints - 1)
        p: degree of the B-spline
        params: parameter values [0, 1]

    Returns:
        knot vector of length n+p+2 = numPoints+p+1
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped knot vector: repeat 0 (p+1) times at start
    knots[:p+1] = 0.0

    # Internal knots: average p consecutive parameter values
    # Formula: knots[j] = (params[j-p] + ... + params[j-1]) / p
    for j in range(p+1, n+1):
        knots[j] = np.sum(params[j-p:j]) / p

    # Clamped knot vector: repeat 1 (p+1) times at end
    knots[n+1:] = 1.0

    return knots

def cox_de_boor(i, p, u, knots):
    """Cox-de Boor recursion formula for B-spline basis function."""
    # Special case for degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif u == knots[i+1] and i == len(knots) - 2:
            return 1.0
        else:
            return 0.0

    # Recursive formula
    # N_{i,p}(u) = ((u - t_i) / (t_{i+p} - t_i)) * N_{i,p-1}(u) +
    #              ((t_{i+p+1} - u) / (t_{i+p+1} - t_{i+1})) * N_{i+1,p-1}(u)

    left_denom = knots[i+p] - knots[i]
    right_denom = knots[i+p+1] - knots[i+1]

    left_term = 0.0
    if abs(left_denom) > 1e-10:
        left_term = ((u - knots[i]) / left_denom) * cox_de_boor(i, p-1, u, knots)

    right_term = 0.0
    if abs(right_denom) > 1e-10:
        right_term = ((knots[i+p+1] - u) / right_denom) * cox_de_boor(i+1, p-1, u, knots)

    return left_term + right_term

def build_basis_matrix(num_points, degree, params, knots):
    """Build the basis function matrix for interpolation."""
    N = np.zeros((num_points, num_points))
    for i in range(num_points):
        for j in range(num_points):
            N[i, j] = cox_de_boor(j, degree, params[i], knots)
    return N

def global_interpolation(data_points, degree=3):
    """
    Compute control points for B-spline that interpolates through data_points.

    Args:
        data_points: numpy array of shape (n, 2) or (n, 3)
        degree: degree of the B-spline

    Returns:
        control_points: numpy array of same shape as data_points
        knots: knot vector
        params: parameter values
    """
    num_points = len(data_points)

    # Edge cases
    if num_points < 2:
        return data_points, None, None

    if degree >= num_points or degree < 1:
        return data_points, None, None

    if degree == 1:
        return data_points, None, None

    # Compute parameter values
    params = chord_length_parameterization(data_points)

    # Generate knot vector
    n = num_points - 1
    knots = generate_knot_vector_averaging(n, degree, params)

    # Build basis matrix
    N = build_basis_matrix(num_points, degree, params, knots)

    # Solve for control points for each dimension
    control_points = np.zeros_like(data_points)
    for dim in range(data_points.shape[1]):
        control_points[:, dim] = np.linalg.solve(N, data_points[:, dim])

    return control_points, knots, params

def evaluate_bspline(control_points, knots, degree, num_samples=100):
    """Evaluate B-spline at num_samples points."""
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
    """Test with 4 points as described by the user."""
    # User clicks 4 red circles (starting from bottom)
    # These are the interpolation points - the spline should pass through them
    data_points = np.array([
        [0, 0],      # Point 1 (bottom)
        [100, 50],   # Point 2
        [200, 100],  # Point 3
        [300, 50]    # Point 4 (should stay here, not move to 0,0)
    ])

    print("=" * 70)
    print("Test: B-spline interpolation with 4 points")
    print("=" * 70)
    print(f"\nData points (interpolation points - spline should pass through):")
    for i, pt in enumerate(data_points):
        print(f"  Point {i+1}: {pt}")

    degree = 3

    # Compute control points
    control_points, knots, params = global_interpolation(data_points, degree)

    print(f"\nDegree: {degree}")
    print(f"\nChord-length parameters:")
    print(f"  {params}")

    print(f"\nKnot vector (length={len(knots)}):")
    print(f"  {knots}")

    print(f"\nControl points (computed to ensure interpolation):")
    for i, pt in enumerate(control_points):
        print(f"  CP {i+1}: {pt}")

    # Evaluate the spline at the original parameters to verify interpolation
    print(f"\n" + "=" * 70)
    print("Verification: Evaluate spline at original parameter values")
    print("=" * 70)

    for i, (u, data_pt) in enumerate(zip(params, data_points)):
        curve_pt = np.zeros(2)
        for j in range(len(control_points)):
            basis = cox_de_boor(j, degree, u, knots)
            curve_pt += basis * control_points[j]

        error = np.linalg.norm(curve_pt - data_pt)
        print(f"  u={u:.6f}: curve={curve_pt}, data={data_pt}, error={error:.2e}")

    # Check if last point is at (0, 0) - this is the bug!
    last_ctrl_pt = control_points[-1]
    print(f"\n" + "=" * 70)
    print("BUG CHECK: Is last control point at (0, 0)?")
    print("=" * 70)
    print(f"  Last control point: {last_ctrl_pt}")
    if np.allclose(last_ctrl_pt, [0, 0]):
        print("  ❌ BUG DETECTED: Last control point is at (0, 0)!")
    else:
        print("  ✓ OK: Last control point is not at (0, 0)")

    # Evaluate at u=1.0 to check the endpoint
    u_end = 1.0
    curve_pt_end = np.zeros(2)
    for j in range(len(control_points)):
        basis = cox_de_boor(j, degree, u_end, knots)
        curve_pt_end += basis * control_points[j]

    print(f"\n  Curve at u=1.0: {curve_pt_end}")
    print(f"  Expected (last data point): {data_points[-1]}")
    print(f"  Error: {np.linalg.norm(curve_pt_end - data_points[-1]):.2e}")

    # Plot
    curve = evaluate_bspline(control_points, knots, degree, num_samples=200)

    plt.figure(figsize=(12, 6))

    # Data points (blue circles) - where user clicked
    plt.plot(data_points[:, 0], data_points[:, 1], 'bo', markersize=10,
             label='Data points (user clicks)', zorder=3)

    # Control points (green x)
    plt.plot(control_points[:, 0], control_points[:, 1], 'gx', markersize=8,
             label='Control points (computed)', zorder=2)

    # Control polygon (green dashed line)
    plt.plot(control_points[:, 0], control_points[:, 1], 'g--', alpha=0.5,
             linewidth=1, label='Control polygon')

    # B-spline curve (red line)
    plt.plot(curve[:, 0], curve[:, 1], 'r-', linewidth=2,
             label='B-spline curve', zorder=1)

    # Highlight last point
    plt.plot(data_points[-1, 0], data_points[-1, 1], 'bs', markersize=15,
             fillstyle='none', linewidth=2, label='Last point (should not move)')

    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.axis('equal')
    plt.title('B-spline Global Interpolation Test')
    plt.xlabel('X')
    plt.ylabel('Y')

    # Save plot
    plt.savefig('experiments/spline_test_4points.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Plot saved to: experiments/spline_test_4points.png")

    # Compare with scipy
    print(f"\n" + "=" * 70)
    print("Comparison with scipy.interpolate (reference implementation)")
    print("=" * 70)

    try:
        # scipy's splprep returns (tck, u) where tck = (t, c, k)
        # t = knot vector, c = control points, k = degree
        tck, u_scipy = splprep([data_points[:, 0], data_points[:, 1]], s=0, k=degree)
        t_scipy, c_scipy, k_scipy = tck

        print(f"Scipy knots (length={len(t_scipy)}):")
        print(f"  {t_scipy}")
        print(f"\nScipy control points:")
        for i in range(len(c_scipy[0])):
            print(f"  CP {i+1}: [{c_scipy[0][i]:.6f}, {c_scipy[1][i]:.6f}]")

        # Evaluate scipy spline at endpoints
        curve_scipy = splev(np.linspace(0, 1, 200), tck)

        print(f"\nScipy curve at start: [{curve_scipy[0][0]:.6f}, {curve_scipy[1][0]:.6f}]")
        print(f"Scipy curve at end: [{curve_scipy[0][-1]:.6f}, {curve_scipy[1][-1]:.6f}]")

    except Exception as e:
        print(f"Scipy comparison failed: {e}")

if __name__ == '__main__':
    test_4_points()
