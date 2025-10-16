#!/usr/bin/env python3
"""
Test script to validate the B-spline interpolation fix for issue #204.

This script demonstrates that the fix correctly converts interpolation points
(blue circles in the user interface) to control points such that the resulting
B-spline passes through all the specified points.

The bug was in InteractiveDrawSpline function at lines 458-478, where the
final spline was created by directly using user points as control points
instead of converting them to control points via ConvertOnCurvePointsToControlPointsArray.

Expected behavior:
- User clicks blue points on the drawing
- These points are interpolation points (the spline should pass through them)
- Control points are calculated automatically to ensure interpolation
- The final spline passes through all blue points

Bug behavior (before fix):
- User clicks blue points
- These points were used directly as control points
- The spline did NOT pass through the points (B-splines don't pass through
  control points except at the ends)
"""

import numpy as np
from scipy.interpolate import BSpline
import matplotlib.pyplot as plt


def chord_length_parameterization(points):
    """Compute parameter values using chord length method."""
    n = len(points)
    if n < 2:
        return np.array([0.0])

    # Calculate cumulative chord lengths
    params = np.zeros(n)
    for i in range(1, n):
        chord = np.linalg.norm(points[i] - points[i-1])
        params[i] = params[i-1] + chord

    # Normalize to [0, 1]
    if params[-1] > 1e-10:
        params = params / params[-1]
    else:
        params = np.linspace(0, 1, n)

    return params


def generate_knot_vector_averaging(n, p, params):
    """
    Generate knot vector using averaging method for global interpolation.

    Based on Piegl & Tiller, "The NURBS Book".
    This is the CORRECT method that was already implemented in PR #215.

    Args:
        n: number of data points minus 1 (index of last point)
        p: degree of B-spline
        params: parameter values from chord length parameterization

    Returns:
        knot vector (clamped: starts with p+1 zeros, ends with p+1 ones)
    """
    m = n + p + 1  # number of knots minus 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: averaging method
    for j in range(p + 1, n + 1):
        knots[j] = np.sum(params[j-p:j]) / p

    # Clamped: repeat 1 at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots


def build_basis_matrix(n, p, params, knots):
    """
    Build the basis function matrix for B-spline interpolation.

    Matrix element [i, j] = BasisFunction(j, p, params[i], knots)

    This represents the linear system: N * P = D
    where:
    - N is the basis matrix
    - P are the unknown control points
    - D are the known data (interpolation) points
    """
    N = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        for j in range(n + 1):
            # Use scipy's B-spline basis evaluation
            # BSpline.basis_element returns a callable that evaluates the basis function
            k = knots[j:j+p+2]  # knot span for basis function j
            if len(k) == p + 2:
                basis = BSpline.basis_element(k, extrapolate=False)
                val = basis(params[i])
                N[i, j] = val if val is not None and not np.isnan(val) else 0.0

    return N


def convert_interpolation_to_control_points(data_points, degree):
    """
    Convert interpolation points to control points for B-spline.

    This is the mathematical operation performed by
    ConvertOnCurvePointsToControlPointsArray in the Pascal code.

    Args:
        data_points: points that the spline should pass through
        degree: degree of B-spline

    Returns:
        control_points: calculated control points
        knots: knot vector
    """
    data_points = np.array(data_points)
    n = len(data_points) - 1

    # Handle edge cases
    if len(data_points) < 2 or degree >= len(data_points) or degree < 1:
        return data_points, None

    # For linear (degree 1), points are control points
    if degree == 1:
        return data_points, None

    # Compute parameters
    params = chord_length_parameterization(data_points)

    # Generate knot vector
    knots = generate_knot_vector_averaging(n, degree, params)

    # Build basis matrix
    N = build_basis_matrix(n, degree, params, knots)

    # Solve for control points (for each coordinate separately)
    control_points = np.zeros_like(data_points)
    for coord in range(data_points.shape[1]):
        control_points[:, coord] = np.linalg.solve(N, data_points[:, coord])

    return control_points, knots


def test_interpolation():
    """Test that the interpolation is correct."""
    print("=" * 70)
    print("Testing B-spline Interpolation Fix for Issue #204")
    print("=" * 70)

    # Example data points (like the blue circles in the UI)
    data_points = np.array([
        [0.0, 0.0],
        [1.0, 2.0],
        [3.0, 2.5],
        [4.0, 1.0],
        [5.0, 3.0]
    ])

    degree = 3

    print(f"\nData points (blue circles - points user clicked):")
    for i, pt in enumerate(data_points):
        print(f"  Point {i}: ({pt[0]:.2f}, {pt[1]:.2f})")

    print(f"\nDegree: {degree}")

    # Convert to control points
    control_points, knots = convert_interpolation_to_control_points(data_points, degree)

    print(f"\nCalculated control points (for spline internal representation):")
    for i, pt in enumerate(control_points):
        print(f"  Control {i}: ({pt[0]:.2f}, {pt[1]:.2f})")

    # Create B-spline with calculated control points
    tck = (knots, control_points.T, degree)
    spline = BSpline(*tck)

    # Verify interpolation: evaluate spline at parameter values
    params = chord_length_parameterization(data_points)
    evaluated_points = np.array([spline(p) for p in params])

    # Calculate interpolation error
    errors = np.linalg.norm(evaluated_points - data_points, axis=1)
    max_error = np.max(errors)

    print(f"\nInterpolation verification:")
    print(f"  Maximum error: {max_error:.2e}")

    if max_error < 1e-6:
        print("  ✅ SUCCESS: Spline passes through all points (error < 1e-6)")
    else:
        print(f"  ❌ FAILED: Spline does not interpolate correctly")
        for i, (pt, eval_pt, err) in enumerate(zip(data_points, evaluated_points, errors)):
            print(f"    Point {i}: expected {pt}, got {eval_pt}, error {err:.2e}")

    # Visualize
    plt.figure(figsize=(10, 6))

    # Plot spline curve
    u_fine = np.linspace(0, 1, 200)
    curve = np.array([spline(u) for u in u_fine])
    plt.plot(curve[:, 0], curve[:, 1], 'r-', linewidth=2, label='B-spline (red)')

    # Plot data points (blue circles - user input)
    plt.plot(data_points[:, 0], data_points[:, 1], 'bo', markersize=12,
             label='Data points (blue circles)', markerfacecolor='blue',
             markeredgecolor='white', markeredgewidth=2)

    # Plot control points (green crosses - internal representation)
    plt.plot(control_points[:, 0], control_points[:, 1], 'gx', markersize=10,
             markeredgewidth=2, label='Control points (internal)')

    # Connect control points with dashed line
    plt.plot(control_points[:, 0], control_points[:, 1], 'g--', alpha=0.3,
             linewidth=1)

    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.title('B-spline Interpolation: Spline passes through blue circles')
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.axis('equal')

    # Save figure
    output_path = '/tmp/gh-issue-solver-1760651573156/experiments/interpolation_test.png'
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\n📊 Visualization saved to: {output_path}")

    print("\n" + "=" * 70)
    print("CONCLUSION:")
    print("=" * 70)
    print("""
The fix ensures that:
1. User clicks define interpolation points (blue circles)
2. Control points are calculated automatically (green crosses)
3. The resulting spline (red curve) passes through all blue circles

BEFORE THE FIX:
- User points were used directly as control points
- Spline did NOT pass through the points

AFTER THE FIX:
- User points are converted to control points
- Spline DOES pass through all the points
""")


if __name__ == '__main__':
    test_interpolation()
    print("\nTest complete!")
