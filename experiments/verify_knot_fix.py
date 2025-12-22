#!/usr/bin/env python3
"""
Verify that the knot vector generation fix is correct.
Compare old (buggy) vs new (fixed) knot generation.
"""

import numpy as np

def generate_knot_vector_OLD_BUGGY(n, p, params):
    """
    OLD BUGGY Pascal implementation:
    for j:=p+1 to n do begin
      sum:=0.0;
      for i:=j-p to j-1 do
        sum:=sum+params[i];
      knots[j]:=sum/p;
    end;
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped knot vector: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: BUGGY VERSION
    for j in range(p+1, n+1):  # j from p+1 to n
        sum_val = 0.0
        for i in range(j-p, j):  # i from j-p to j-1
            sum_val += params[i]
        knots[j] = sum_val / p

    # Clamped knot vector: repeat 1 (p+1) times at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def generate_knot_vector_NEW_FIXED(n, p, params):
    """
    NEW FIXED Pascal implementation:
    for j:=1 to n-p do begin
      sum:=0.0;
      for i:=j to j+p-1 do
        sum:=sum+params[i];
      knots[p+j]:=sum/p;
    end;
    """
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped knot vector: repeat 0 (p+1) times at start
    for i in range(p + 1):
        knots[i] = 0.0

    # Internal knots: FIXED VERSION
    for j in range(1, n-p+1):  # j from 1 to n-p
        sum_val = 0.0
        for i in range(j, j+p):  # i from j to j+p-1
            sum_val += params[i]
        knots[p+j] = sum_val / p

    # Clamped knot vector: repeat 1 (p+1) times at end
    for i in range(n + 1, m + 1):
        knots[i] = 1.0

    return knots

def test_knot_generation():
    """Test knot generation with 7 points, degree 3."""
    # 7 points = n+1, so n=6
    n = 6
    p = 3

    # Sample parameter values (from our previous test)
    params = np.array([0.0, 0.24650848, 0.29485277, 0.49418139, 0.63091969, 0.84712193, 1.0])

    print("="*70)
    print("Testing Knot Vector Generation")
    print("="*70)
    print(f"n = {n} (number of control points - 1)")
    print(f"p = {p} (degree)")
    print(f"Number of parameters = {len(params)}")
    print(f"params = {params}")
    print()

    # Generate with old buggy method
    print("OLD BUGGY METHOD:")
    print("  Loop: for j in range(p+1, n+1):  # j from 4 to 6")
    print("    for i in range(j-p, j):  # average params[j-3:j]")
    knots_old = generate_knot_vector_OLD_BUGGY(n, p, params)
    print(f"  knots = {knots_old}")
    print()

    # Generate with new fixed method
    print("NEW FIXED METHOD (Piegl & Tiller):")
    print("  Loop: for j in range(1, n-p+1):  # j from 1 to 3")
    print("    for i in range(j, j+p):  # average params[j:j+3]")
    knots_new = generate_knot_vector_NEW_FIXED(n, p, params)
    print(f"  knots = {knots_new}")
    print()

    # Show details of knot calculation
    print("DETAILED KNOT CALCULATION (NEW FIXED):")
    print("  Clamped start: knots[0..3] = 0.0")
    for j in range(1, n-p+1):
        param_indices = list(range(j, j+p))
        param_values = [params[i] for i in param_indices]
        knot_idx = p + j
        knot_value = sum(param_values) / p
        print(f"  j={j}: knots[{knot_idx}] = avg(params[{param_indices}]) = avg({[f'{v:.4f}' for v in param_values]}) = {knot_value:.6f}")
    print(f"  Clamped end: knots[{n+1}..{n+p+1}] = 1.0")
    print()

    # Compare
    print("COMPARISON:")
    print("  Index  | Old (Buggy) | New (Fixed) | Difference")
    print("  " + "-"*55)
    for i in range(len(knots_old)):
        diff = abs(knots_old[i] - knots_new[i])
        status = "✗ DIFFERS" if diff > 1e-10 else "✓ SAME"
        print(f"  {i:5d}  | {knots_old[i]:11.6f} | {knots_new[i]:11.6f} | {diff:11.2e} {status}")

    print()
    print("="*70)
    print("CONCLUSION:")
    if np.allclose(knots_old, knots_new):
        print("  WARNING: Old and new methods produce SAME results!")
        print("  This means the bug might be elsewhere.")
    else:
        print("  ✓ Old and new methods produce DIFFERENT results.")
        print("  The fix changes the knot vector, which should fix interpolation.")
    print("="*70)

if __name__ == "__main__":
    test_knot_generation()
