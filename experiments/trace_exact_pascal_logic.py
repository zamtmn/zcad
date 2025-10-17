#!/usr/bin/env python3
"""
Trace through EXACT Pascal logic step by step to find the bug.
This mimics the Pascal code line-by-line.
"""

import numpy as np

# EXACT Pascal implementation
def BasisFunction_Pascal(i, p, u, knots):
    """EXACT copy of Pascal BasisFunction."""
    # Line 70: numCtrlPts:=Length(knots)-p-2;
    numCtrlPts = len(knots) - p - 2  # Number of control points minus 1

    # Lines 71-78: Special case for endpoint
    if abs(u - knots[len(knots)-1]) < 1e-10:
        if i == numCtrlPts:
            return 1.0
        else:
            return 0.0

    # Lines 80-90: Special case for degree 0
    if p == 0:
        if (u >= knots[i]) and (u < knots[i+1]):
            return 1.0
        elif (abs(u - knots[i+1]) < 1e-10) and (i+1 == len(knots)-1):
            return 1.0
        else:
            return 0.0

    # Line 93: SetLength(BasisValues,p+1);
    BasisValues = np.zeros(p + 1)

    # Lines 95-103: Initialize degree 0
    for j in range(p + 1):
        if (u >= knots[i+j]) and (u < knots[i+j+1]):
            BasisValues[j] = 1.0
        elif (abs(u - knots[i+j+1]) < 1e-10) and (i+j+1 == len(knots)-1):
            BasisValues[j] = 1.0
        else:
            BasisValues[j] = 0.0

    # Lines 106-140: Build up to degree p
    for k in range(1, p + 1):
        # Lines 108-117: Handle left end
        if BasisValues[0] == 0.0:
            saved = 0.0
        else:
            uright = knots[i + k]
            uleft = knots[i]
            if abs(uright - uleft) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - uleft) / (uright - uleft)) * BasisValues[0]

        # Lines 120-139: Process middle terms
        for j in range(p - k + 1):
            uleft = knots[i + j + 1]
            uright = knots[i + j + k + 1]

            if BasisValues[j + 1] == 0.0:
                BasisValues[j] = saved
                saved = 0.0
            else:
                if abs(uright - uleft) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((uright - u) / (uright - uleft)) * BasisValues[j + 1]
                BasisValues[j] = saved + temp

                if abs(knots[i + j + k + 1] - knots[i + j + 1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i + j + 1]) / (knots[i + j + k + 1] - knots[i + j + 1])) * BasisValues[j + 1]

    # Line 142
    return BasisValues[0]

def trace_7_point_interpolation():
    """Trace 7-point interpolation step by step."""
    # 7 fit points (2D for simplicity)
    fit_points = np.array([
        [1.0, 2.0],   # p1
        [3.5, 1.5],   # p2
        [3.5, 1.0],   # p3
        [1.5, 0.5],   # p4
        [0.5, 1.5],   # p5
        [2.5, 2.5],   # p6
        [4.0, 2.0],   # p7
    ])

    degree = 3
    numPoints = len(fit_points)

    print("="*70)
    print("TRACING 7-POINT INTERPOLATION (EXACT PASCAL LOGIC)")
    print("="*70)

    # Line 280: numPoints:=Length(AOnCurvePoints);
    print(f"\nnumPoints = {numPoints}")

    # Lines 143-145: Compute parameters
    params = np.zeros(numPoints)
    params[0] = 0.0
    params[numPoints-1] = 1.0

    totalLength = 0.0
    for i in range(numPoints - 1):
        chordLength = np.linalg.norm(fit_points[i+1] - fit_points[i])
        totalLength += chordLength
        params[i+1] = totalLength

    for i in range(1, numPoints):
        params[i] = params[i] / totalLength

    print(f"\nparams = {params}")

    # Lines 326-330: Number of control points
    numControlPoints = numPoints
    print(f"numControlPoints = {numControlPoints}")

    # Lines 335-336: Generate knot vector
    n = numPoints - 1  # n = 6
    p = degree  # p = 3
    m = n + p + 1  # m = 10
    knots = np.zeros(m + 1)  # knots[0..10], total 11 elements

    # Lines 192-193: Clamped start
    for i in range(p + 1):
        knots[i] = 0.0

    # Lines 197-202: Internal knots
    for j in range(p+1, n+1):  # j from 4 to 6
        sum_val = 0.0
        for i in range(j-p, j):  # i from j-3 to j-1
            sum_val += params[i]
        knots[j] = sum_val / p

    # Lines 205-206: Clamped end
    for i in range(n+1, m+1):
        knots[i] = 1.0

    print(f"\nknots = {knots}")
    print(f"knot vector length = {len(knots)}")

    # Lines 356-369: Build coefficient matrix
    print(f"\n{'='*70}")
    print("BUILDING COEFFICIENT MATRIX")
    print(f"{'='*70}")

    A = np.zeros((numPoints, numPoints))
    for i in range(numPoints):
        u = params[i]
        print(f"\nRow {i}: u = {u:.6f}")

        for j in range(numPoints):
            A[i, j] = BasisFunction_Pascal(j, degree, u, knots)

        row_sum = np.sum(A[i, :])
        print(f"  Basis values: {A[i, :]}")
        print(f"  Sum = {row_sum:.10f}")

        if abs(row_sum - 1.0) > 1e-6:
            print(f"  ⚠️  WARNING: Partition of unity violated! Sum should be 1.0")

    # Check matrix condition
    print(f"\n{'='*70}")
    print("MATRIX ANALYSIS")
    print(f"{'='*70}")
    cond = np.linalg.cond(A)
    print(f"Condition number: {cond:.2e}")
    if cond > 1e10:
        print("⚠️  WARNING: Matrix is ill-conditioned!")

    # Solve for control points
    print(f"\n{'='*70}")
    print("SOLVING FOR CONTROL POINTS")
    print(f"{'='*70}")

    b_x = fit_points[:, 0]
    b_y = fit_points[:, 1]

    try:
        x_x = np.linalg.solve(A, b_x)
        x_y = np.linalg.solve(A, b_y)
        print("✓ System solved successfully")
    except np.linalg.LinAlgError as e:
        print(f"✗ ERROR: {e}")
        return

    control_points = np.column_stack([x_x, x_y])

    print(f"\nControl Points:")
    for i, pt in enumerate(control_points):
        print(f"  P{i}: ({pt[0]:.6f}, {pt[1]:.6f})")

    # Verify interpolation
    print(f"\n{'='*70}")
    print("INTERPOLATION VERIFICATION")
    print(f"{'='*70}")

    for i, u in enumerate(params):
        # Evaluate spline at u
        point = np.zeros(2)
        for j in range(numPoints):
            N = BasisFunction_Pascal(j, degree, u, knots)
            point += N * control_points[j]

        error = np.linalg.norm(point - fit_points[i])
        status = "✓ PASS" if error < 1e-6 else "✗ FAIL"
        print(f"p{i+1}: error = {error:.2e} {status}")

if __name__ == "__main__":
    trace_7_point_interpolation()
