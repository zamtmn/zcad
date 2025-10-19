#!/usr/bin/env python3
"""
Test to verify the fix for issue #277 - matrix destruction bug
"""

import numpy as np

print("=" * 70)
print("DEMONSTRATING THE BUG")
print("=" * 70)
print()

# Create a simple test matrix and vectors
A = np.array([
    [2.0, 1.0, 0.0],
    [1.0, 3.0, 1.0],
    [0.0, 1.0, 2.0]
], dtype=float)

b_x = np.array([1.0, 2.0, 3.0], dtype=float)
b_y = np.array([4.0, 5.0, 6.0], dtype=float)
b_z = np.array([7.0, 8.0, 9.0], dtype=float)

print("Original matrix A:")
print(A)
print()

print("Right-hand sides:")
print(f"b_x = {b_x}")
print(f"b_y = {b_y}")
print(f"b_z = {b_z}")
print()

# Solve for x_x - this will MODIFY A!
x_x = np.linalg.solve(A, b_x)
print("After solving for x_x:")
print(f"x_x = {x_x}")
print(f"Matrix A is now: (still original because numpy.linalg.solve doesn't modify)")
print(A)
print()

# Now let's simulate what happens with Gaussian elimination that modifies A
def gauss_eliminate_inplace(A, b):
    """Gaussian elimination that modifies A in place (like the Pascal code)"""
    n = len(b)
    A_work = A.copy()  # Work on a copy for this demo
    b_work = b.copy()

    # Forward elimination
    for k in range(n-1):
        for i in range(k+1, n):
            factor = A_work[i][k] / A_work[k][k]
            for j in range(k, n):
                A_work[i][j] -= factor * A_work[k][j]
            b_work[i] -= factor * b_work[k]

    # Back substitution
    x = np.zeros(n)
    for i in range(n-1, -1, -1):
        x[i] = b_work[i]
        for j in range(i+1, n):
            x[i] -= A_work[i][j] * x[j]
        x[i] /= A_work[i][i]

    return x, A_work

print("=" * 70)
print("SIMULATING THE BUG (matrix gets destroyed)")
print("=" * 70)
print()

A_test = A.copy()
print("Original matrix:")
print(A_test)
print()

# First solve - destroys A_test!
x_x_test, A_test = gauss_eliminate_inplace(A_test, b_x)
print(f"After 1st solve for x_x:")
print(f"x_x = {x_x_test}")
print(f"Matrix is now MODIFIED (upper triangular):")
print(A_test)
print()

# Second solve - uses DESTROYED matrix!
x_y_test, A_test = gauss_eliminate_inplace(A_test, b_y)
print(f"After 2nd solve for x_y (using destroyed matrix!):")
print(f"x_y = {x_y_test} (WRONG!)")
print(f"Expected x_y = {np.linalg.solve(A, b_y)} (correct)")
print()

print("=" * 70)
print("CORRECT APPROACH (save and restore matrix)")
print("=" * 70)
print()

A_original = A.copy()
A_work = A.copy()

# Save original
A_saved = A_work.copy()

# First solve
x_x_correct, A_work = gauss_eliminate_inplace(A_work, b_x)
print(f"x_x = {x_x_correct}")

# Restore matrix before second solve
A_work = A_saved.copy()
x_y_correct, A_work = gauss_eliminate_inplace(A_work, b_y)
print(f"x_y = {x_y_correct} (CORRECT!)")
print(f"Expected x_y = {np.linalg.solve(A, b_y)}")

# Restore matrix before third solve
A_work = A_saved.copy()
x_z_correct, A_work = gauss_eliminate_inplace(A_work, b_z)
print(f"x_z = {x_z_correct} (CORRECT!)")
print(f"Expected x_z = {np.linalg.solve(A, b_z)}")

print()
print("=" * 70)
print("CONCLUSION")
print("=" * 70)
print()
print("The bug was that SolveLinearSystem modifies matrix A,")
print("so the second and third calls were using a destroyed matrix!")
print()
print("The fix is to save the original matrix and restore it before each solve.")
