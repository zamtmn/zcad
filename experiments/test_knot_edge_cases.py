#!/usr/bin/env python3
"""
Test knot generation with different n and p values to find where old method fails.
"""

import numpy as np

def generate_knot_vector_OLD(n, p, params):
    """OLD implementation."""
    m = n + p + 1
    knots = np.zeros(m + 1)

    for i in range(p + 1):
        knots[i] = 0.0

    for j in range(p+1, n+1):
        sum_val = 0.0
        for i in range(j-p, j):
            sum_val += params[i]
        knots[j] = sum_val / p

    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def generate_knot_vector_NEW(n, p, params):
    """NEW implementation."""
    m = n + p + 1
    knots = np.zeros(m + 1)

    for i in range(p + 1):
        knots[i] = 0.0

    for j in range(1, n-p+1):
        sum_val = 0.0
        for i in range(j, j+p):
            sum_val += params[i]
        knots[p+j] = sum_val / p

    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def test_case(num_points, degree):
    """Test a specific case."""
    n = num_points - 1
    p = degree
    params = np.linspace(0, 1, num_points)

    print(f"\n{'='*60}")
    print(f"Test: {num_points} points, degree {degree}")
    print(f"n={n}, p={p}")
    print(f"{'='*60}")

    try:
        knots_old = generate_knot_vector_OLD(n, p, params)
        print(f"OLD: {knots_old}")
    except Exception as e:
        print(f"OLD: ERROR - {e}")
        knots_old = None

    try:
        knots_new = generate_knot_vector_NEW(n, p, params)
        print(f"NEW: {knots_new}")
    except Exception as e:
        print(f"NEW: ERROR - {e}")
        knots_new = None

    if knots_old is not None and knots_new is not None:
        if np.allclose(knots_old, knots_new):
            print("RESULT: SAME ✓")
        else:
            print("RESULT: DIFFERENT ✗")
            print(f"Max difference: {np.max(np.abs(knots_old - knots_new))}")

if __name__ == "__main__":
    print("Testing knot generation with various n and p values")

    # Test various cases
    test_case(4, 3)   # 4 points, degree 3
    test_case(5, 3)   # 5 points, degree 3
    test_case(6, 3)   # 6 points, degree 3
    test_case(7, 3)   # 7 points, degree 3
    test_case(8, 3)   # 8 points, degree 3
    test_case(5, 2)   # 5 points, degree 2
    test_case(10, 3)  # 10 points, degree 3
