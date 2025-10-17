#!/usr/bin/env python3
"""
Debug the basis matrix to understand why it's singular.
"""

import numpy as np

def chord_length_parameterization(points):
    """Compute parameter values using chord length method."""
    n = len(points)
    params = np.zeros(n)
    params[0] = 0.0
    params[n-1] = 1.0

    if n == 2:
        return params

    # Calculate total chord length
    total_length = 0.0
    for i in range(n-1):
        chord_length = np.linalg.norm(points[i+1] - points[i])
        total_length += chord_length
        params[i+1] = total_length

    # Normalize to [0,1]
    if total_length > 0.0001:
        for i in range(1, n):
            params[i] = params[i] / total_length
    else:
        for i in range(1, n):
            params[i] = i / (n-1)

    return params

def generate_knot_vector_averaging(n, p, params):
    """Generate knot vector using averaging method."""
    m = n + p + 1
    knots = np.zeros(m + 1)

    # Clamped: repeat 0 (p+1) times at start
    knots[:p+1] = 0.0

    # Internal knots: average p consecutive parameter values
    for j in range(p+1, n+1):
        knots[j] = np.sum(params[j-p:j]) / p

    # Clamped: repeat 1 (p+1) times at end
    knots[n+1:] = 1.0

    return knots

def cox_de_boor_stable(i, p, u, knots):
    """
    Stable iterative implementation of Cox-de Boor.
    Uses triangular computation scheme.
    """
    # Handle endpoint case
    num_ctrl = len(knots) - p - 2
    if abs(u - 1.0) < 1e-10:
        # At u=1, only the last basis function should be non-zero
        return 1.0 if i == num_ctrl else 0.0

    # Initialize degree 0
    N = np.zeros(p + 1)
    for j in range(p + 1):
        if i + j >= len(knots) - 1:
            N[j] = 0.0
        elif knots[i+j] <= u < knots[i+j+1]:
            N[j] = 1.0
        else:
            N[j] = 0.0

    # Build up to degree p
    for k in range(1, p + 1):
        # Handle left end
        if abs(N[0]) < 1e-15:
            saved = 0.0
        else:
            denom = knots[i+k] - knots[i]
            if abs(denom) < 1e-15:
                saved = 0.0
            else:
                saved = ((u - knots[i]) / denom) * N[0]

        # Process middle terms
        for j in range(p - k + 1):
            left = knots[i+j+1]
            right = knots[i+j+k+1]

            if abs(N[j+1]) < 1e-15:
                N[j] = saved
                saved = 0.0
            else:
                denom_right = right - left
                if abs(denom_right) < 1e-15:
                    temp = 0.0
                else:
                    temp = ((right - u) / denom_right) * N[j+1]

                N[j] = saved + temp

                denom_left = knots[i+j+k+1] - knots[i+j+1]
                if abs(denom_left) < 1e-15:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / denom_left) * N[j+1]

    return N[0]

def build_basis_matrix(num_points, degree, params, knots):
    """Build the basis function matrix for interpolation."""
    N = np.zeros((num_points, num_points))
    for i in range(num_points):
        for j in range(num_points):
            N[i, j] = cox_de_boor_stable(j, degree, params[i], knots)
    return N

# Test with 4 points
data_points = np.array([
    [0, 0],
    [100, 50],
    [200, 100],
    [300, 50]
])

degree = 3
num_points = 4

print("=" * 70)
print("Debugging B-spline basis matrix")
print("=" * 70)

# Compute parameters
params = chord_length_parameterization(data_points)
print(f"\nData points:")
for i, pt in enumerate(data_points):
    print(f"  Point {i}: {pt}")

print(f"\nChord-length parameters:")
for i, u in enumerate(params):
    print(f"  u[{i}] = {u:.6f}")

# Generate knot vector
n = num_points - 1
knots = generate_knot_vector_averaging(n, degree, params)
print(f"\nKnot vector (length={len(knots)}, should be {num_points}+{degree}+1={num_points+degree+1}):")
print(f"  {knots}")

# Check knot vector structure
print(f"\nKnot vector analysis:")
print(f"  First {degree+1} knots (should all be 0): {knots[:degree+1]}")
print(f"  Last {degree+1} knots (should all be 1): {knots[-(degree+1):]}")
print(f"  Internal knots: {knots[degree+1:-(degree+1)]}")

# Build basis matrix
print(f"\nBuilding basis matrix ({num_points}x{num_points})...")
N = build_basis_matrix(num_points, degree, params, knots)

print(f"\nBasis matrix N:")
print(N)

print(f"\nRow sums (should each equal 1 for partition of unity):")
for i, row_sum in enumerate(N.sum(axis=1)):
    print(f"  Row {i}: {row_sum:.6f}")

print(f"\nMatrix rank: {np.linalg.matrix_rank(N)}")
print(f"Matrix condition number: {np.linalg.cond(N):.2e}")

# Check if singular
det = np.linalg.det(N)
print(f"Matrix determinant: {det:.2e}")

if abs(det) < 1e-10:
    print("\n❌ Matrix is singular (determinant ≈ 0)")
    print("   This means the control points cannot be uniquely determined!")
else:
    print("\n✓ Matrix is not singular")

# Analyze basis functions
print(f"\n" + "=" * 70)
print("Analyzing basis functions at each parameter value")
print("=" * 70)

for i, u in enumerate(params):
    print(f"\nAt u[{i}] = {u:.6f}:")
    basis_vals = []
    for j in range(num_points):
        val = cox_de_boor_stable(j, degree, u, knots)
        basis_vals.append(val)
        print(f"  N_{j},{degree}(u) = {val:.6f}")
    print(f"  Sum = {sum(basis_vals):.6f}")

print(f"\n" + "=" * 70)
print("DIAGNOSIS")
print("=" * 70)

# The issue might be that params[i] equals knots[j] for some interior values
# causing division by zero or degeneracy
print("\nChecking for parameter/knot collisions:")
for i, u in enumerate(params):
    for j, k in enumerate(knots):
        if abs(u - k) < 1e-10 and j not in [0, len(knots)-1]:
            print(f"  ⚠ params[{i}] ≈ knots[{j}] = {k:.6f}")

# The averaging formula might be wrong
print("\nChecking averaging formula:")
print("For global interpolation with n+1=4 points, degree p=3:")
print("  Knot vector should have m+1 = n+p+2 = 4+3+1 = 8 elements")
print("  Actual length:", len(knots))

print("\n  Internal knots should be computed as:")
for j in range(degree+1, n+1):
    print(f"    knots[{j}] = sum(params[{j-degree}:{j}]) / {degree}")
    print(f"             = sum({params[j-degree:j]}) / {degree}")
    print(f"             = {np.sum(params[j-degree:j]) / degree:.6f}")
    print(f"    Actual value: {knots[j]:.6f}")
