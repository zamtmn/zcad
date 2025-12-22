#!/usr/bin/env python3
"""
Test script for issue #260 - Spline conversion from on-curve points to control points

This script verifies the ConvertOnCurvePointsToControlPointsArray function
using the test data provided in the issue.
"""

import numpy as np
from numpy.linalg import solve

def compute_chord_length_params(points):
    """Compute parameter values using chord length parameterization"""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[-1] = 1.0

    if n == 2:
        return params

    # Calculate total chord length
    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = params[i] + chord_length

    # Normalize to [0,1]
    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n - 1)

    return params

def generate_knot_vector(n, p, params):
    """
    Generate knot vector using averaging method for global interpolation
    Based on STANDARD B-spline interpolation algorithm (Piegl & Tiller, Algorithm A9.1)

    For m+1 data points with degree p, we have n=m control points
    Knot vector has n+p+2 elements
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped knot vector: repeat 0 (p+1) times at start
    knots[:p+1] = 0.0

    # Internal knots: average p consecutive parameter values
    for j in range(1, n-p+1):
        knots[j+p] = np.sum(params[j:j+p]) / p

    # Clamped knot vector: repeat 1 (p+1) times at end
    knots[n+1:] = 1.0

    return knots

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

def convert_on_curve_to_control_points(degree, on_curve_points):
    """
    Convert on-curve points to control points using B-spline global interpolation
    Based on "The NURBS Book" by Piegl & Tiller, Algorithm A9.1
    """
    num_points = len(on_curve_points)

    # For standard interpolation: n+1 = m+1 control points
    m = num_points - 1
    n = m
    num_control_points = n + 1

    # Step 1: Compute parameter values using chord length parameterization
    params = compute_chord_length_params(on_curve_points)

    # Step 2: Generate knot vector using averaging method
    knots = generate_knot_vector(n, degree, params)

    # Step 3: Build the interpolation matrix system
    A = np.zeros((num_points, num_control_points))

    for k in range(num_points):
        for i in range(num_control_points):
            A[k, i] = basis_function(i, degree, params[k], knots)

    # Solve the linear system for each coordinate
    control_points = np.zeros((num_control_points, 3))
    control_points[:, 0] = solve(A, on_curve_points[:, 0])
    control_points[:, 1] = solve(A, on_curve_points[:, 1])
    control_points[:, 2] = solve(A, on_curve_points[:, 2])

    return control_points, knots

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

    print("=" * 60)
    print("Test for issue #260 - Spline Conversion")
    print("=" * 60)
    print()

    print("On-curve points (input):")
    for i, p in enumerate(on_curve_points):
        print(f"  p{i+1}: ({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f})")
    print()

    # Convert on-curve points to control points
    control_points, knots = convert_on_curve_to_control_points(degree, on_curve_points)

    print(f"Computed control points (degree={degree}):")
    for i, p in enumerate(control_points):
        print(f"  CP{i}: ({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f})")
    print()

    print("Expected control points:")
    for i, p in enumerate(expected_control_points):
        print(f"  CP{i}: ({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f})")
    print()

    print("Knot vector:")
    print(f"  {knots}")
    print()

    # Compare results
    print("=" * 60)
    print("Comparison:")
    print("=" * 60)

    if len(control_points) != len(expected_control_points):
        print(f"ERROR: Number of control points mismatch!")
        print(f"  Computed: {len(control_points)}")
        print(f"  Expected: {len(expected_control_points)}")
        print()
    else:
        max_diff = 0.0
        for i in range(len(control_points)):
            diff = np.linalg.norm(control_points[i] - expected_control_points[i])
            max_diff = max(max_diff, diff)

            if diff > 0.1:
                print(f"CP{i}: MISMATCH (difference: {diff:.4f})")
                print(f"  Computed: ({control_points[i][0]:.4f}, {control_points[i][1]:.4f}, {control_points[i][2]:.4f})")
                print(f"  Expected: ({expected_control_points[i][0]:.4f}, {expected_control_points[i][1]:.4f}, {expected_control_points[i][2]:.4f})")
            else:
                print(f"CP{i}: OK (difference: {diff:.4f})")

        print()
        print(f"Maximum difference: {max_diff:.4f}")

        if max_diff < 0.1:
            print("\n✓ Results match the expected control points!")
        else:
            print("\n✗ Results DO NOT match the expected control points!")

if __name__ == "__main__":
    main()
