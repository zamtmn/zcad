#!/usr/bin/env python3
"""
Test if the expected output represents de Boor points instead of control points
Or maybe it's using a composite Bezier curve representation
"""

import numpy as np
from scipy.interpolate import BSpline, make_interp_spline

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
print("Hypothesis: Composite Bezier curves")
print("="*80)
print("\nIdea: 7 points might be split into 2 cubic Bezier segments")
print("Each cubic Bezier has 4 control points")
print("Shared endpoint: 2 segments = 4 + 4 - 1 = 7 points... but we have 9 CPs")
print("\nOr: 3 quadratic Bezier segments?")
print("Each quadratic has 3 CPs, shared endpoints: 3 + 3 + 3 - 2 = 7... still not 9")
print("\nActually, for C1/C2 continuity, we might need extra points")

print("\n" + "="*80)
print("Let me check: What if it's using scipy's make_interp_spline?")
print("="*80)

# Try scipy's built-in interpolation with different settings
from scipy.interpolate import make_interp_spline

print("\nTrying make_interp_spline with k=3 (cubic):")
points_t = on_curve_points.T

# Standard interpolation
spl = make_interp_spline(np.linspace(0, 1, len(on_curve_points)), on_curve_points, k=3)
print(f"Control points shape: {spl.c.shape}")
print(f"Number of control points: {spl.c.shape[0]}")
print(f"Knots: {spl.t}")

if spl.c.shape[0] == 9:
    print("\n✓ Got 9 control points!")
    print("\nControl points from make_interp_spline:")
    for i in range(spl.c.shape[0]):
        print(f"CP {i}: ({spl.c[i,0]:.4f}, {spl.c[i,1]:.4f}, {spl.c[i,2]:.4f})")

    print("\nExpected control points:")
    for i in range(len(expected_control_points)):
        print(f"CP {i}: ({expected_control_points[i,0]:.4f}, {expected_control_points[i,1]:.4f}, {expected_control_points[i,2]:.4f})")

    print("\nComparison:")
    for i in range(min(spl.c.shape[0], len(expected_control_points))):
        computed = spl.c[i]
        expected = expected_control_points[i]
        diff = np.linalg.norm(computed - expected)
        match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
        print(f"{match} CP {i}: diff={diff:.4f}")

else:
    print(f"\n✗ Got {spl.c.shape[0]} control points, expected 9")

# Try with bc_type parameter for boundary conditions
print("\n" + "="*80)
print("Trying different boundary conditions:")
print("="*80)

for bc_type in ['not-a-knot', 'clamped', 'natural', ((2, 0.0), (2, 0.0))]:
    try:
        spl2 = make_interp_spline(np.linspace(0, 1, len(on_curve_points)), on_curve_points, k=3, bc_type=bc_type)
        print(f"{str(bc_type):20s}: {spl2.c.shape[0]} control points, knots={len(spl2.t)}")

        if spl2.c.shape[0] == 9:
            print("  ^^^ This gives 9 control points!")
            print("  Control points:")
            for i in range(spl2.c.shape[0]):
                print(f"  CP {i}: ({spl2.c[i,0]:.4f}, {spl2.c[i,1]:.4f}, {spl2.c[i,2]:.4f})")

            print("  Comparison with expected:")
            max_diff = 0
            for i in range(9):
                computed = spl2.c[i]
                expected = expected_control_points[i]
                diff = np.linalg.norm(computed - expected)
                max_diff = max(max_diff, diff)
                match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
                print(f"  {match} CP {i}: diff={diff:.4f}")

            if max_diff < 1.0:
                print("\n  ✓✓✓ PERFECT MATCH FOUND!")
                print(f"  Boundary condition: {bc_type}")
                print(f"  Knot vector: {spl2.t}")
    except Exception as e:
        print(f"{str(bc_type):20s}: Error - {str(e)[:60]}")

# Check scipy version
import scipy
print(f"\n\nUsing scipy version: {scipy.__version__}")
