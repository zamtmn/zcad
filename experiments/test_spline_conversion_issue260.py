#!/usr/bin/env python3
"""
Test script for issue #260 - B-spline conversion
Compare different B-spline interpolation algorithms to understand
why we need 9 control points for 7 input points.
"""

import numpy as np
from scipy.interpolate import splprep, splev, BSpline
import matplotlib.pyplot as plt

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
print("Issue #260: B-spline Conversion Analysis")
print("="*80)
print(f"\nInput: {len(on_curve_points)} points on curve (degree {degree})")
print(f"Expected output: {len(expected_control_points)} control points")
print(f"Difference: {len(expected_control_points) - len(on_curve_points)} extra control points")

print("\n" + "="*80)
print("Method 1: Standard Global Interpolation (current implementation)")
print("="*80)
print("This produces n+1 = m+1 control points for m+1 data points")
print(f"Expected: {len(on_curve_points)} control points")
print("Result: Does NOT match issue requirements (7 != 9)")

print("\n" + "="*80)
print("Method 2: scipy.interpolate.splprep with default settings")
print("="*80)
# Transpose for splprep (expects [x_coords, y_coords, z_coords])
points_t = on_curve_points.T
tck, u = splprep(points_t, s=0, k=degree)
knots, control_coeffs, k = tck

print(f"Degree: {k}")
print(f"Number of control points: {len(control_coeffs[0])}")
print(f"Knot vector length: {len(knots)}")
print(f"Knot vector: {knots}")

print("\nControl points from splprep:")
for i in range(len(control_coeffs[0])):
    print(f"CP {i}: ({control_coeffs[0][i]:.4f}, {control_coeffs[1][i]:.4f}, {control_coeffs[2][i]:.4f})")

print("\n" + "="*80)
print("Method 3: Analyzing expected control points")
print("="*80)
print("Observation:")
print("- First control point matches first data point")
print("- Last control point matches last data point")
print("- 7 data points + 2 extra = 9 control points")
print("\nThis suggests: Approximation with extra control points for better fit")
print("Or: Different parameterization/knot vector strategy")

print("\n" + "="*80)
print("Knot Vector Analysis")
print("="*80)
n = len(expected_control_points) - 1  # n = 8 (9 control points, indexed 0-8)
p = degree  # p = 3
expected_knot_length = n + p + 2  # = 8 + 3 + 2 = 13

print(f"For {n+1} control points with degree {p}:")
print(f"Expected knot vector length: {expected_knot_length}")
print(f"scipy knot vector length: {len(knots)}")

# Check if expected control points match scipy output
print("\n" + "="*80)
print("Comparison with expected output")
print("="*80)
if len(control_coeffs[0]) == len(expected_control_points):
    print("Number of control points MATCHES!")
    print("\nComparing values:")
    max_diff = 0
    for i in range(len(expected_control_points)):
        scipy_pt = np.array([control_coeffs[0][i], control_coeffs[1][i], control_coeffs[2][i]])
        expected_pt = expected_control_points[i]
        diff = np.linalg.norm(scipy_pt - expected_pt)
        max_diff = max(max_diff, diff)
        print(f"CP {i}: scipy=({scipy_pt[0]:.4f}, {scipy_pt[1]:.4f}, {scipy_pt[2]:.4f}), "
              f"expected=({expected_pt[0]:.4f}, {expected_pt[1]:.4f}, {expected_pt[2]:.4f}), "
              f"diff={diff:.4f}")
    print(f"\nMaximum difference: {max_diff:.4f}")
else:
    print(f"Number of control points DOES NOT MATCH: {len(control_coeffs[0])} vs {len(expected_control_points)}")

print("\n" + "="*80)
print("Testing different parameterizations")
print("="*80)

# Try different parameterization methods
for per in [0, 1]:
    print(f"\nTesting with periodic={per}:")
    try:
        tck2, u2 = splprep(points_t, s=0, k=degree, per=per)
        knots2, coeffs2, k2 = tck2
        print(f"  Control points: {len(coeffs2[0])}")
        print(f"  Knots: {len(knots2)}")
    except Exception as e:
        print(f"  Error: {e}")

print("\n" + "="*80)
print("Conclusion")
print("="*80)
print("The expected output (9 control points) suggests either:")
print("1. A specific knot vector strategy (clamped with extra knots)")
print("2. Different algorithm than standard global interpolation")
print("3. Approximation method with controlled number of control points")
print("\nNext step: Check if scipy splprep output matches expected values")
