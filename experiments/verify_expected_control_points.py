#!/usr/bin/env python3
"""
Verify if the expected control points from issue #260 actually interpolate the on-curve points.
"""

import numpy as np

def basis_function(i, p, u, knots):
    """Compute basis function N_i,p(u) using Cox-de Boor recursion formula"""
    num_ctrl_pts = len(knots) - p - 2

    # Special case for clamped B-splines at the endpoint
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    # Special case for degree 0
    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    # Use triangular table to build up from degree 0 to degree p
    basis_values = np.zeros(p + 1)

    # Initialize degree 0
    for j in range(p + 1):
        if knots[i+j] <= u < knots[i+j+1]:
            basis_values[j] = 1.0
        elif abs(u - knots[i+j+1]) < 1e-10 and i+j+1 == len(knots)-1:
            basis_values[j] = 1.0
        else:
            basis_values[j] = 0.0

    # Build up to degree p
    for k in range(1, p + 1):
        # Handle left end
        if basis_values[0] == 0.0:
            saved = 0.0
        else:
            uright = knots[i+k]
            uleft = knots[i]
            if abs(uright - uleft) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - uleft) / (uright - uleft)) * basis_values[0]

        # Process middle terms
        for j in range(p - k + 1):
            uleft = knots[i+j+1]
            uright = knots[i+j+k+1]

            if basis_values[j+1] == 0.0:
                basis_values[j] = saved
                saved = 0.0
            else:
                if abs(uright - uleft) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((uright - u) / (uright - uleft)) * basis_values[j+1]
                basis_values[j] = saved + temp

                if abs(knots[i+j+k+1] - knots[i+j+1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / (knots[i+j+k+1] - knots[i+j+1])) * basis_values[j+1]

    return basis_values[0]

def evaluate_bspline(u, degree, control_points, knots):
    """Evaluate B-spline curve at parameter u"""
    n = len(control_points) - 1
    point = np.zeros(3)

    for i in range(n + 1):
        N = basis_function(i, degree, u, knots)
        point += N * control_points[i]

    return point

def compute_chord_length_params(points):
    """Compute parameter values using chord length parameterization"""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[-1] = 1.0

    if n == 2:
        return params

    # Calculate cumulative chord length
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        params[i+1] = params[i] + chord_length

    # Normalize to [0,1]
    total_length = params[-1]
    if total_length > 0.0001:
        params = params / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n - 1)

    return params

def main():
    # Test data from issue #260
    degree = 3

    # On-curve points (точки лежащие на сплайне)
    on_curve_points = np.array([
        [1583.2136549257, 417.836639195, 0],
        [2346.3909069169, 988.9560396917, 0],
        [1396.2099574179, 1772.3499076297, 0],
        [-392.9605538726, 1716.754213776, 0],
        [-41.2801529313, 2784.8206166348, 0],
        [1717.1218517754, 2954.1482170881, 0],
        [3449.4734564123, 2146.5858149265, 0]
    ])

    # Expected control points (from the other program)
    expected_control_points = np.array([
        [1583.2137, 417.8366, 0],
        [1943.9619, 588.3078, 0],
        [2770.7705, 979.0151, 0],
        [1225.7225, 2260.4551, 0],
        [-771.0874, 1052.6822, 0],
        [-50.7662, 3342.0538, 0],
        [1877.21, 3020.2007, 0],
        [2911.8082, 2445.335, 0],
        [3449.4735, 2146.5858, 0]
    ])

    # For 9 control points with degree 3, we need 9 + 3 + 1 = 13 knots
    # Try clamped uniform knot vector
    n = len(expected_control_points) - 1  # 8
    m = n + degree + 1  # 8 + 3 + 1 = 12 (last index of knot vector)

    # Standard clamped uniform knot vector
    knots = np.zeros(m + 1)
    knots[:degree+1] = 0.0

    # Internal knots
    num_internal = m - 2 * degree  # 12 - 6 = 6 internal segments
    for i in range(1, num_internal):
        knots[degree + i] = i / num_internal

    knots[n+1:] = 1.0

    print("=" * 60)
    print("Verification: Do expected control points interpolate?")
    print("=" * 60)
    print()

    print(f"Expected control points: {len(expected_control_points)}")
    print(f"On-curve points: {len(on_curve_points)}")
    print(f"Degree: {degree}")
    print(f"Knot vector ({len(knots)} knots): {knots}")
    print()

    # Compute parameters for on-curve points
    params = compute_chord_length_params(on_curve_points)

    print("Testing interpolation at on-curve point parameters:")
    print()

    max_error = 0.0
    for i, (param, on_curve_pt) in enumerate(zip(params, on_curve_points)):
        # Evaluate B-spline at this parameter
        evaluated_pt = evaluate_bspline(param, degree, expected_control_points, knots)

        # Compute error
        error = np.linalg.norm(evaluated_pt - on_curve_pt)
        max_error = max(max_error, error)

        print(f"Point {i+1} (u={param:.6f}):")
        print(f"  On-curve:  ({on_curve_pt[0]:10.4f}, {on_curve_pt[1]:10.4f}, {on_curve_pt[2]:6.4f})")
        print(f"  Evaluated: ({evaluated_pt[0]:10.4f}, {evaluated_pt[1]:10.4f}, {evaluated_pt[2]:6.4f})")
        print(f"  Error: {error:.6f}")

    print()
    print(f"Maximum error: {max_error:.6f}")
    print()

    if max_error < 1.0:
        print("✓ Expected control points DO interpolate the on-curve points!")
    else:
        print("✗ Expected control points DO NOT interpolate the on-curve points.")
        print("  This suggests approximation, not interpolation.")

if __name__ == "__main__":
    main()
