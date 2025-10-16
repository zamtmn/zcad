#!/usr/bin/env python3
"""
Test B-spline interpolation using scipy's implementation
"""

import numpy as np
from scipy.interpolate import splrep, BSpline
import matplotlib.pyplot as plt

def chord_length_param(points):
    """Compute chord length parameterization"""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0

    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    if total_length > 1e-6:
        params = params / total_length
    else:
        params = np.linspace(0, 1, n)

    return params

def test_scipy():
    """Test with scipy"""
    # 5 data points
    data_points = np.array([
        [0.0, 2.0],
        [2.0, 4.0],
        [4.0, 1.0],
        [5.0, 3.0],
        [6.0, 2.5]
    ])

    degree = 3

    # Use scipy's splrep for interpolation
    # splrep returns (knots, coefficients, degree)
    params = chord_length_param(data_points)

    print(f"Data points:\n{data_points}")
    print(f"Parameters: {params}")

    # Fit B-spline to data
    tck_x = splrep(params, data_points[:, 0], k=degree, s=0)  # s=0 means interpolation
    tck_y = splrep(params, data_points[:, 1], k=degree, s=0)

    print(f"\nX knots: {tck_x[0]}")
    print(f"X coefficients: {tck_x[1]}")
    print(f"Y knots: {tck_y[0]}")
    print(f"Y coefficients: {tck_y[1]}")

    # Verify interpolation
    print("\n" + "=" * 60)
    print("Verification:")
    print("=" * 60)

    bspline_x = BSpline(*tck_x)
    bspline_y = BSpline(*tck_y)

    max_error = 0.0
    for i, param in enumerate(params):
        x_eval = bspline_x(param)
        y_eval = bspline_y(param)
        point_eval = np.array([x_eval, y_eval])
        error = np.linalg.norm(point_eval - data_points[i])
        max_error = max(max_error, error)
        print(f"u={param:.4f}: expected {data_points[i]}, got {point_eval}, error={error:.6e}")

    print(f"\nMaximum error: {max_error:.6e}")

    # Plot
    plt.figure(figsize=(12, 6))

    # Evaluate curve at many points
    u_vals = np.linspace(0, 1, 200)
    curve_points = np.column_stack([bspline_x(u_vals), bspline_y(u_vals)])

    # Plot data points
    plt.plot(data_points[:, 0], data_points[:, 1], 'bo', markersize=10, label='Data points', zorder=3)

    # Plot control points
    control_points_x = tck_x[1][:len(data_points)]
    control_points_y = tck_y[1][:len(data_points)]
    plt.plot(control_points_x, control_points_y, 'go', markersize=6, label='Control points', zorder=2)
    plt.plot(control_points_x, control_points_y, 'g--', alpha=0.5, linewidth=1)

    # Plot curve
    plt.plot(curve_points[:, 0], curve_points[:, 1], 'r-', linewidth=2, label='Interpolated B-spline', zorder=1)

    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.axis('equal')
    plt.title('B-spline Interpolation with scipy')
    plt.xlabel('X')
    plt.ylabel('Y')

    plt.savefig('/tmp/gh-issue-solver-1760650543519/experiments/scipy_bspline_test.png', dpi=150, bbox_inches='tight')
    print(f"\nPlot saved")

    return max_error < 1e-6

if __name__ == "__main__":
    success = test_scipy()
    exit(0 if success else 1)
