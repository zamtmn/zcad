#!/usr/bin/env python3
"""
Reverse engineer the knot vector by testing the expected control points
"""

import numpy as np
from scipy.interpolate import BSpline
from itertools import product

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

def test_knot_vector(knots, params):
    """Test if a knot vector with expected CPs passes through data points"""
    try:
        # Build splines for each dimension
        spl_x = BSpline(knots, expected_control_points[:, 0], degree)
        spl_y = BSpline(knots, expected_control_points[:, 1], degree)
        spl_z = BSpline(knots, expected_control_points[:, 2], degree)

        # Evaluate at parameter values
        max_error = 0
        errors = []
        for i, u in enumerate(params):
            eval_pt = np.array([spl_x(u), spl_y(u), spl_z(u)])
            error = np.linalg.norm(eval_pt - on_curve_points[i])
            errors.append(error)
            max_error = max(max_error, error)

        return max_error, errors
    except Exception as e:
        return float('inf'), []

print("="*80)
print("Reverse Engineering: Find the knot vector")
print("="*80)

n_cp = 9
p = degree
knot_length = n_cp + p + 1  # = 9 + 3 + 1 = 13

print(f"Number of control points: {n_cp}")
print(f"Degree: {p}")
print(f"Expected knot vector length: {knot_length}")

# Try different parameterizations
param_types = {
    "chord_length": compute_chord_params(on_curve_points),
    "uniform": np.linspace(0, 1, len(on_curve_points)),
    "centripetal": None  # TODO
}

print("\n" + "="*80)
print("Testing different parameterizations:")
print("="*80)

best_params = None
best_knots = None
best_error = float('inf')

for param_name, params in param_types.items():
    if params is None:
        continue

    print(f"\n{param_name}: {params}")

    # Try different knot vector strategies
    knot_strategies = []

    # 1. Uniform internal knots
    n_internal = knot_length - 2 * (p + 1)  # 13 - 8 = 5 internal knots
    internal_uniform = np.linspace(0, 1, n_internal + 2)[1:-1]
    knots_uniform = np.concatenate([
        np.zeros(p + 1),
        internal_uniform,
        np.ones(p + 1)
    ])
    knot_strategies.append(("uniform_internal", knots_uniform))

    # 2. Based on parameter distribution (averaging-like)
    # For each internal knot position, we can try averaging parameters
    # With 7 data points and 5 internal knots, try different averages

    # Strategy: Place knots at specific parameter fractions
    for fraction_multiplier in [1.0, 1.5, 2.0]:
        try:
            internal_knots = []
            step = (len(params) - 1) / (n_internal + 1)
            for i in range(1, n_internal + 1):
                idx = int(i * step * fraction_multiplier) % len(params)
                internal_knots.append(params[idx])
            internal_knots = sorted(internal_knots)

            # Normalize to [0, 1] range
            if len(internal_knots) > 0:
                min_val = min(internal_knots)
                max_val = max(internal_knots)
                if max_val > min_val:
                    internal_knots = [(k - min_val) / (max_val - min_val) * 0.8 + 0.1
                                      for k in internal_knots]

            knots_param = np.concatenate([
                np.zeros(p + 1),
                internal_knots[:n_internal],
                np.ones(p + 1)
            ])
            knot_strategies.append((f"param_based_{fraction_multiplier}", knots_param))
        except:
            pass

    # Test each strategy
    for strategy_name, knots in knot_strategies:
        if len(knots) != knot_length:
            continue

        max_error, errors = test_knot_vector(knots, params)

        if max_error < 1000:  # Only print reasonable results
            print(f"  {strategy_name}: max_error={max_error:.4f}")
            if max_error < best_error:
                best_error = max_error
                best_params = params
                best_knots = knots
                best_strategy = strategy_name
                best_param_name = param_name

print("\n" + "="*80)
print("Best result:")
print("="*80)
if best_knots is not None:
    print(f"Parameterization: {best_param_name}")
    print(f"Knot strategy: {best_strategy}")
    print(f"Maximum error: {best_error:.4f}")
    print(f"\nBest knot vector:")
    print(best_knots)
    print(f"\nBest parameters:")
    print(best_params)

    # Test in detail
    max_error, errors = test_knot_vector(best_knots, best_params)
    print(f"\nDetailed errors:")
    for i, err in enumerate(errors):
        match = "✓" if err < 1.0 else "~" if err < 10.0 else "✗"
        print(f"{match} Point {i}: error={err:.6f}")

else:
    print("No good solution found")

# Try one more thing: what if knots are placed uniformly in the valid range?
print("\n" + "="*80)
print("Trying more knot placements:")
print("="*80)

for spacing_type in ["lin"]:
    for start in [0.05, 0.1, 0.15]:
        for end in [0.85, 0.9, 0.95]:
            internal = np.linspace(start, end, n_internal)
            knots = np.concatenate([
                np.zeros(p + 1),
                internal,
                np.ones(p + 1)
            ])

            for param_name, params in param_types.items():
                if params is None:
                    continue

                max_error, errors = test_knot_vector(knots, params)
                if max_error < 10:
                    print(f"  {param_name}, knots=[0]*4, linspace({start},{end},{n_internal}), [1]*4: error={max_error:.4f}")

                    if max_error < best_error:
                        best_error = max_error
                        best_params = params
                        best_knots = knots
                        print(f"    ^^^ NEW BEST!")

print("\n" + "="*80)
print("FINAL BEST RESULT:")
print("="*80)
if best_knots is not None and best_error < 100:
    print(f"Maximum error: {best_error:.4f}")
    print(f"\nKnot vector:")
    print(best_knots)
    print(f"\nParameters:")
    print(best_params)

    # Detailed check
    max_error, errors = test_knot_vector(best_knots, best_params)
    print(f"\nDetailed verification:")
    for i, err in enumerate(errors):
        match = "✓" if err < 0.1 else "~" if err < 1.0 else "✗"
        print(f"{match} Point {i}: error={err:.6f}")

    if best_error < 0.01:
        print("\n✓✓✓ EXCELLENT! Found the knot vector and parameterization!")
    elif best_error < 1.0:
        print("\n✓✓ VERY GOOD! Close match found!")
    else:
        print("\n~ Reasonable match, may need refinement")
else:
    print("No satisfactory solution found with current strategies")
    print("\nThis suggests the algorithm might be:")
    print("1. Using a different parameterization method")
    print("2. Using a specific knot placement strategy")
    print("3. From a specific CAD software with proprietary algorithm")
