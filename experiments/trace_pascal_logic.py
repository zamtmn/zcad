#!/usr/bin/env python3
"""
Trace through the exact logic of the Pascal code to understand
why 7 fit points might produce only 5 control points.
"""

import numpy as np

def trace_convert_on_curve_points(num_points, degree):
    """Trace through ConvertOnCurvePointsToControlPointsArray logic."""

    print(f"\n{'='*80}")
    print(f"TRACING: numPoints={num_points}, ADegree={degree}")
    print(f"{'='*80}")

    # Line 346-351: Handle edge cases
    if num_points < 2:
        print("EXIT: numPoints < 2 - return empty array")
        return 0
    print(f"✓ numPoints >= 2: Continue")

    # Line 354-360: For degree >= numPoints, or simple cases
    if degree >= num_points or degree < 1:
        print(f"EXIT: degree ({degree}) >= numPoints ({num_points}) or degree < 1")
        print(f"      Return {num_points} control points (same as fit points)")
        return num_points
    print(f"✓ degree ({degree}) < numPoints ({num_points}) and degree >= 1: Continue")

    # Line 363-369: For degree 1 (linear)
    if degree == 1:
        print(f"EXIT: degree == 1 (linear)")
        print(f"      Return {num_points} control points (same as fit points)")
        return num_points
    print(f"✓ degree ({degree}) != 1: Continue")

    # Line 372-378: Special case: only 2 points
    if num_points == 2:
        print(f"EXIT: numPoints == 2")
        print(f"      Return 2 control points")
        return 2
    print(f"✓ numPoints ({num_points}) > 2: Continue")

    # Line 380-400: CAD-style interpolation
    print(f"\n✓ Reached CAD-style interpolation section")
    print(f"  numControlPoints = numPoints + 2 = {num_points} + 2 = {num_points + 2}")

    num_control_points = num_points + 2

    print(f"\n  Set Result[0] = first fit point")
    print(f"  Set Result[{num_control_points-1}] = last fit point")
    print(f"  Set Result[1] = tangent control point at start")
    print(f"  Set Result[{num_control_points-2}] = tangent control point at end")

    num_interior_fit = num_points - 2
    num_interior_ctrl = num_points - 2

    print(f"\n  numInteriorFit = numPoints - 2 = {num_interior_fit}")
    print(f"  numInteriorCtrl = numPoints - 2 = {num_interior_ctrl}")

    if num_interior_fit > 0 and num_interior_ctrl > 0:
        print(f"\n  ✓ Solve linear system for {num_interior_ctrl} interior control points")
        print(f"    Result[2..{num_control_points-3}] = solve linear system")
    else:
        print(f"\n  ! No interior points to solve for")

    print(f"\n✓ RETURN: {num_control_points} control points")

    return num_control_points

# Test with various configurations
test_cases = [
    (4, 3),  # 4 fit points, degree 3
    (5, 3),  # 5 fit points, degree 3
    (7, 3),  # 7 fit points, degree 3 (the issue case)
    (7, 2),  # 7 fit points, degree 2
    (7, 4),  # 7 fit points, degree 4
    (7, 5),  # 7 fit points, degree 5
    (7, 6),  # 7 fit points, degree 6
    (7, 7),  # 7 fit points, degree 7 (edge case)
    (7, 8),  # 7 fit points, degree 8 (edge case)
]

print("="*80)
print("TESTING VARIOUS CONFIGURATIONS")
print("="*80)

for num_points, degree in test_cases:
    result = trace_convert_on_curve_points(num_points, degree)

print(f"\n{'='*80}")
print("SUMMARY")
print(f"{'='*80}")
print("\nFor the reported issue (7 fit points, degree 3):")
print("  Expected: 9 control points (7+2)")
print("  Current code should produce: 9 control points")
print("\nIf the user sees only 5 control points, possible reasons:")
print("  1. User is testing with an older version of the code")
print("  2. The degree parameter is not 3 (might be 5 or 6)")
print("  3. There's a bug in a different part of the code (not in ConvertOnCurvePointsToControlPointsArray)")
print("  4. The visualization is incorrect (not showing all control points)")
