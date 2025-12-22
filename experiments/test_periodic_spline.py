#!/usr/bin/env python3
"""
Test periodic spline interpolation for issue #260
"""

import numpy as np
from scipy.interpolate import splprep, splev

# Test data from issue #260
degree = 3
on_curve_points = np.array([
    [1583.2136549257, 417.836639195, 0],
    [2346.3909069169, 988.9560396917, 0],
    [1396.2099574179, 1772.3499076297, 0],
    [-392.9605538726, 1716.754213776, 0],
    [-41.2801529313, 2784.8206166348, 0],
    [1717.1218517754, 2954.1482170881, 0],
    [3449.4734564123, 2146.5858149265, 0],
])

# Expected control points from issue #260
expected_control_points = np.array([
    [1583.2137, 417.8366, 0],
    [1943.9619, 588.3078, 0],
    [2770.7705, 979.0151, 0],
    [1225.7225, 2260.4551, 0],
    [-771.0874, 1052.6822, 0],
    [-50.7662, 3342.0538, 0],
    [1877.21, 3020.2007, 0],
    [2911.8082, 2445.335, 0],
    [3449.4735, 2146.5858, 0],
])

print("="*80)
print("Testing periodic spline (periodic=1)")
print("="*80)

# Transpose for splprep
points_t = on_curve_points.T
tck, u = splprep(points_t, s=0, k=degree, per=1)
knots, control_coeffs, k = tck

print(f"Degree: {k}")
print(f"Number of control points: {len(control_coeffs[0])}")
print(f"Knot vector length: {len(knots)}")
print(f"\nKnot vector:")
print(knots)

print("\n" + "="*80)
print("Control points from periodic spline:")
print("="*80)
for i in range(len(control_coeffs[0])):
    print(f"CP {i}: ({control_coeffs[0][i]:.4f}, {control_coeffs[1][i]:.4f}, {control_coeffs[2][i]:.4f})")

print("\n" + "="*80)
print("Expected control points:")
print("="*80)
for i in range(len(expected_control_points)):
    print(f"CP {i}: ({expected_control_points[i][0]:.4f}, {expected_control_points[i][1]:.4f}, {expected_control_points[i][2]:.4f})")

print("\n" + "="*80)
print("Comparison:")
print("="*80)
if len(control_coeffs[0]) == len(expected_control_points):
    print("✓ Number of control points MATCHES!")
    print("\nDetailed comparison:")
    max_diff = 0
    for i in range(len(expected_control_points)):
        scipy_pt = np.array([control_coeffs[0][i], control_coeffs[1][i], control_coeffs[2][i]])
        expected_pt = expected_control_points[i]
        diff = np.linalg.norm(scipy_pt - expected_pt)
        max_diff = max(max_diff, diff)
        match = "✓" if diff < 1.0 else "✗"
        print(f"{match} CP {i}: diff={diff:.4f}")

    print(f"\nMaximum difference: {max_diff:.4f}")

    if max_diff < 1.0:
        print("\n✓✓✓ All control points match within tolerance!")
    else:
        print("\n✗✗✗ Control points do NOT match")
else:
    print(f"✗ Number mismatch: {len(control_coeffs[0])} vs {len(expected_control_points)}")

print("\n" + "="*80)
print("Verify spline passes through input points:")
print("="*80)
# Evaluate spline at original parameter values
u_new = np.linspace(0, 1, len(on_curve_points))
interpolated = splev(u_new, tck)
interpolated_points = np.array(interpolated).T

for i in range(len(on_curve_points)):
    orig = on_curve_points[i]
    interp = interpolated_points[i]
    diff = np.linalg.norm(orig - interp)
    match = "✓" if diff < 1.0 else "✗"
    print(f"{match} Point {i}: diff={diff:.4f}")
