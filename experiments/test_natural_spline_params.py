#!/usr/bin/env python3
"""
Test natural spline with different parameterizations
"""

import numpy as np
from scipy.interpolate import make_interp_spline

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

def compute_chord_params(points):
    """Compute chord length parameterization"""
    n = len(points)
    params = np.zeros(n)
    total_length = 0

    for i in range(1, n):
        chord = np.linalg.norm(points[i] - points[i-1])
        total_length += chord
        params[i] = params[i-1] + chord

    if total_length > 0:
        params = params / total_length

    return params

def compute_centripetal_params(points, alpha=0.5):
    """Compute centripetal parameterization"""
    n = len(points)
    params = np.zeros(n)
    total_length = 0

    for i in range(1, n):
        chord = np.linalg.norm(points[i] - points[i-1])
        total_length += chord ** alpha
        params[i] = params[i-1] + chord ** alpha

    if total_length > 0:
        params = params / total_length

    return params

print("="*80)
print("Testing different parameterizations with natural boundary condition")
print("="*80)

param_strategies = {
    "uniform": np.linspace(0, 1, len(on_curve_points)),
    "chord_length": compute_chord_params(on_curve_points),
    "centripetal_0.25": compute_centripetal_params(on_curve_points, 0.25),
    "centripetal_0.5": compute_centripetal_params(on_curve_points, 0.5),
    "centripetal_0.75": compute_centripetal_params(on_curve_points, 0.75),
}

best_match = None
best_error = float('inf')

for param_name, params in param_strategies.items():
    print(f"\n{'='*80}")
    print(f"Parameterization: {param_name}")
    print(f"{'='*80}")
    print(f"Parameters: {params}")

    # Create natural spline
    spl = make_interp_spline(params, on_curve_points, k=3, bc_type='natural')

    print(f"\nNumber of control points: {spl.c.shape[0]}")
    print(f"Knot vector: {spl.t}")

    if spl.c.shape[0] == 9:
        print("\nControl points:")
        max_diff = 0
        total_diff = 0

        for i in range(9):
            computed = spl.c[i]
            expected = expected_control_points[i]
            diff = np.linalg.norm(computed - expected)
            max_diff = max(max_diff, diff)
            total_diff += diff

            match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
            print(f"{match} CP {i}: ({computed[0]:8.4f}, {computed[1]:8.4f}) vs ({expected[0]:8.4f}, {expected[1]:8.4f}) diff={diff:7.4f}")

        avg_diff = total_diff / 9
        print(f"\nMax diff: {max_diff:.4f}, Avg diff: {avg_diff:.4f}")

        if max_diff < best_error:
            best_error = max_diff
            best_match = param_name
            best_spl = spl
            best_params = params

        if max_diff < 1.0:
            print("\n✓✓✓ EXCELLENT MATCH!")
        elif max_diff < 10.0:
            print("\n~ Good match, close!")

print("\n" + "="*80)
print("BEST RESULT:")
print("="*80)
print(f"Parameterization: {best_match}")
print(f"Maximum error: {best_error:.4f}")

if best_error < 100:
    print(f"\nParameters: {best_params}")
    print(f"Knot vector: {best_spl.t}")

    # Verify interpolation
    print("\nVerifying interpolation:")
    for i, (t, pt) in enumerate(zip(best_params, on_curve_points)):
        eval_pt = best_spl(t)
        diff = np.linalg.norm(eval_pt - pt)
        match = "✓" if diff < 0.01 else "~" if diff < 1.0 else "✗"
        print(f"{match} Point {i}: diff={diff:.6f}")

# Try more alpha values for centripetal
print("\n" + "="*80)
print("Fine-tuning centripetal alpha:")
print("="*80)

best_alpha = None
for alpha in np.linspace(0.1, 1.0, 20):
    params = compute_centripetal_params(on_curve_points, alpha)
    spl = make_interp_spline(params, on_curve_points, k=3, bc_type='natural')

    if spl.c.shape[0] == 9:
        max_diff = max([np.linalg.norm(spl.c[i] - expected_control_points[i]) for i in range(9)])

        if max_diff < best_error:
            best_error = max_diff
            best_alpha = alpha
            best_spl = spl
            best_params = params

        if max_diff < 50:
            print(f"alpha={alpha:.3f}: max_diff={max_diff:.4f}")

if best_alpha is not None:
    print(f"\nBest alpha: {best_alpha:.4f}")
    print(f"Best error: {best_error:.4f}")

    if best_error < 10:
        print("\nControl points with best alpha:")
        for i in range(9):
            computed = best_spl.c[i]
            expected = expected_control_points[i]
            diff = np.linalg.norm(computed - expected)
            match = "✓" if diff < 1.0 else "~" if diff < 10.0 else "✗"
            print(f"{match} CP {i}: ({computed[0]:8.4f}, {computed[1]:8.4f}) vs ({expected[0]:8.4f}, {expected[1]:8.4f}) diff={diff:7.4f}")
