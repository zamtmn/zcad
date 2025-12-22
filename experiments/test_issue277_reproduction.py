#!/usr/bin/env python3
"""
Reproduce issue #277 - Y coordinates are wrong while X coordinates are correct
"""

import numpy as np
from scipy import interpolate
import math

# Input data from issue #277
on_curve_points = [
    (1583.213655, 417.836639, 0.000000),
    (2346.390907, 988.956040, 0.000000),
    (1396.209957, 1772.349908, 0.000000),
    (-392.960554, 1716.754214, 0.000000),
    (-41.280153, 2784.820617, 0.000000),
    (1717.121852, 2954.148217, 0.000000),
    (3449.473456, 2146.585815, 0.000000),
]

# Expected control points from issue
expected_control_points = [
    (1583.213700, 417.836600, 0.000000),
    (1943.961900, 588.307800, 0.000000),
    (2770.770500, 979.015100, 0.000000),
    (1225.722500, 2260.455100, 0.000000),
    (-771.087400, 1052.682200, 0.000000),
    (-50.766200, 3342.053800, 0.000000),
    (1877.210000, 3020.200700, 0.000000),
    (2911.808200, 2445.335000, 0.000000),
    (3449.473500, 2146.585800, 0.000000),
]

# Actual output from issue (WRONG Y-coordinates):
actual_control_points = [
    (1583.213623, 989.777649, 0.000000),
    (1943.961914, 1370.677612, 0.000000),
    (2770.770752, 2245.555176, 0.000000),
    (1225.722412, 2470.688721, 0.000000),
    (-771.087402, 2533.185547, 0.000000),
    (-50.765949, 4972.652832, 0.000000),
    (1877.209229, 32.646339, 0.000000),
    (2911.807617, 0.000008, 0.000000),
    (3449.473389, 0.000000, 0.000000),
]

degree = 3

# Compute chord length parameters
def compute_chord_params(points):
    n = len(points)
    params = np.zeros(n)

    for i in range(1, n):
        dist = math.sqrt(
            (points[i][0] - points[i-1][0])**2 +
            (points[i][1] - points[i-1][1])**2 +
            (points[i][2] - points[i-1][2])**2
        )
        params[i] = params[i-1] + dist

    if params[-1] > 0:
        params = params / params[-1]

    return params

params = compute_chord_params(on_curve_points)

x = np.array([p[0] for p in on_curve_points])
y = np.array([p[1] for p in on_curve_points])
z = np.array([p[2] for p in on_curve_points])

# Use natural spline
spl_x = interpolate.make_interp_spline(params, x, k=degree, bc_type='natural')
spl_y = interpolate.make_interp_spline(params, y, k=degree, bc_type='natural')
spl_z = interpolate.make_interp_spline(params, z, k=degree, bc_type='natural')

print("=" * 80)
print("ISSUE #277 ANALYSIS")
print("=" * 80)
print()

print("Parameter values (chord length):")
for i, p in enumerate(params):
    print(f"  params[{i}] = {p:.6f}")
print()

print("Knot vector from scipy:")
print(spl_x.t)
print()

print("CONTROL POINTS COMPARISON:")
print(f"{'Idx':<4} {'Expected X':<15} {'Actual X':<15} {'Scipy X':<15} {'Diff Exp-Scipy X':<18}")
print("-" * 85)

for i in range(len(expected_control_points)):
    exp_x = expected_control_points[i][0]
    act_x = actual_control_points[i][0]
    sci_x = spl_x.c[i]
    diff_exp_sci_x = abs(exp_x - sci_x)

    print(f"{i:<4} {exp_x:<15.6f} {act_x:<15.6f} {sci_x:<15.6f} {diff_exp_sci_x:<18.6f}")

print()
print()

print(f"{'Idx':<4} {'Expected Y':<15} {'Actual Y':<15} {'Scipy Y':<15} {'Diff Exp-Scipy Y':<18}")
print("-" * 85)

for i in range(len(expected_control_points)):
    exp_y = expected_control_points[i][1]
    act_y = actual_control_points[i][1]
    sci_y = spl_y.c[i]
    diff_exp_sci_y = abs(exp_y - sci_y)

    print(f"{i:<4} {exp_y:<15.6f} {act_y:<15.6f} {sci_y:<15.6f} {diff_exp_sci_y:<18.6f}")

print()
print()

# Check if scipy matches expected
max_diff_x = max(abs(expected_control_points[i][0] - spl_x.c[i]) for i in range(len(expected_control_points)))
max_diff_y = max(abs(expected_control_points[i][1] - spl_y.c[i]) for i in range(len(expected_control_points)))

print(f"Maximum difference X (Expected vs Scipy): {max_diff_x:.9f}")
print(f"Maximum difference Y (Expected vs Scipy): {max_diff_y:.9f}")
print()

if max_diff_x < 0.001 and max_diff_y < 0.001:
    print("✓ Scipy natural spline matches expected output!")
else:
    print("✗ Scipy does NOT match expected output")
    print()
    print("Investigating the discrepancy...")

print()
print("=" * 80)
print("OBSERVATION:")
print("=" * 80)
print()
print("From the actual output (from issue #277):")
print("- X coordinates: CORRECT (match expected)")
print("- Y coordinates: WRONG (completely different pattern)")
print()
print("This is suspicious because the same algorithm should process both X and Y.")
print("Let's check if there's a pattern in the Y-coordinate errors...")
print()

# Analyze the pattern
print("Analyzing Y-coordinate actual values:")
for i in range(len(actual_control_points)):
    act_y = actual_control_points[i][1]
    exp_y = expected_control_points[i][1]
    print(f"  CP[{i}]: Actual={act_y:12.6f}, Expected={exp_y:12.6f}, Diff={act_y - exp_y:12.6f}")

print()
print("Notice that:")
print("- CP[0]: Actual Y = 989.777649 vs Expected Y = 417.836600")
print("- The first expected Y (417.836600) matches the first on-curve point Y")
print("- But actual Y (989.777649) is close to the SECOND on-curve point Y (988.956040)")
print()
print("Could there be an off-by-one error in how boundary conditions are applied?")
