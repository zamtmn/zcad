#!/usr/bin/env python3
"""
Analyze the knot vector bug in the Pascal implementation
"""

import math

# Input data from issue #275
on_curve_points = [
    (1583.213655, 417.836639, 0.000000),
    (2346.390907, 988.956040, 0.000000),
    (1396.209957, 1772.349908, 0.000000),
    (-392.960554, 1716.754214, 0.000000),
    (-41.280153, 2784.820617, 0.000000),
    (1717.121852, 2954.148217, 0.000000),
    (3449.473456, 2146.585815, 0.000000),
]

expected_knots = [0.000000, 0.000000, 0.000000, 0.000000, 0.108603, 0.248909,
                  0.452854, 0.580969, 0.782236, 1.000000, 1.000000, 1.000000, 1.000000]

degree = 3
numPoints = len(on_curve_points)
m = numPoints - 1  # m = 6
n = m + 2  # n = 8 for natural spline (m+3 control points)
numControlPoints = n + 1  # 9 control points

print("=" * 60)
print("ANALYZING KNOT VECTOR GENERATION BUG")
print("=" * 60)
print()
print(f"Number of on-curve points (m+1): {numPoints}")
print(f"Number of control points (n+1): {numControlPoints}")
print(f"Degree (p): {degree}")
print(f"m = {m}")
print(f"n = {n}")
print()

# Compute chord length parameters
def compute_chord_params(points):
    n = len(points)
    params = [0.0] * n

    for i in range(1, n):
        dist = math.sqrt(
            (points[i][0] - points[i-1][0])**2 +
            (points[i][1] - points[i-1][1])**2 +
            (points[i][2] - points[i-1][2])**2
        )
        params[i] = params[i-1] + dist

    # Normalize
    if params[-1] > 0:
        params = [p / params[-1] for p in params]

    return params

params = compute_chord_params(on_curve_points)
print("Parameter values (chord length):")
for i, p in enumerate(params):
    print(f"  params[{i}] = {p:.6f}")
print()

# WRONG approach (current Pascal implementation):
print("WRONG APPROACH (current Pascal code lines 384-402):")
print("-" * 60)
print("The code does:")
print(f"  numKnots = n + ADegree + 2 = {n} + {degree} + 2 = {n + degree + 2}")
print()
print("  // Clamped: first p+1 knots are 0")
print("  for i := 0 to ADegree do")
print("    knots[i] := 0.0;")
print()
print("  // Internal knots: place at parameter values (skip first and last)")
print("  for i := 1 to numPoints-2 do")
print("    knots[ADegree+i] := params[i];")
print()
print("  // Clamped: last p+1 knots are 1")
print(f"  for i := numKnots-ADegree-1 to numKnots-1 do")
print("    knots[i] := 1.0;")
print()

wrong_knots = [0.0] * (n + degree + 2)
# First p+1 are 0
for i in range(degree + 1):
    wrong_knots[i] = 0.0

# Internal knots: params[1] to params[m-1]
for i in range(1, numPoints - 1):
    wrong_knots[degree + i] = params[i]

# Last p+1 are 1
numKnots_wrong = len(wrong_knots)
for i in range(numKnots_wrong - degree - 1, numKnots_wrong):
    wrong_knots[i] = 1.0

print("Generated knot vector (WRONG):")
for i, k in enumerate(wrong_knots):
    print(f"  knots[{i}] = {k:.6f}")
print()
print(f"Total knots: {len(wrong_knots)}")
print()

# CORRECT approach (natural spline with clamped ends):
print("CORRECT APPROACH (natural spline with clamped boundary):")
print("-" * 60)
print("For natural cubic spline with clamped ends:")
print(f"  m+1 = {numPoints} data points")
print(f"  n+1 = m+3 = {numControlPoints} control points")
print(f"  Knot vector length = n+p+2 = {n}+{degree}+2 = {n+degree+2}")
print()
print("The knot vector should be:")
print("  [0, 0, 0, 0, params[1], params[2], ..., params[m-1], 1, 1, 1, 1]")
print()
print("This is:")
print("  - First p+1 = 4 knots are 0")
print("  - Middle m-1 = 5 knots are params[1] through params[5]")
print("  - Last p+1 = 4 knots are 1")
print()

correct_knots = []

# First p+1 knots are 0
for i in range(degree + 1):
    correct_knots.append(0.0)

# Middle knots: params[1] through params[m-1]
for i in range(1, m):
    correct_knots.append(params[i])

# Last p+1 knots are 1
for i in range(degree + 1):
    correct_knots.append(1.0)

print("Generated knot vector (CORRECT):")
for i, k in enumerate(correct_knots):
    print(f"  knots[{i}] = {k:.6f}")
print()
print(f"Total knots: {len(correct_knots)}")
print()

print("Comparison with expected knots:")
print(f"{'Index':<6} {'Expected':<15} {'Correct':<15} {'Diff':<12}")
print("-" * 50)
for i in range(len(expected_knots)):
    exp_k = expected_knots[i]
    cor_k = correct_knots[i]
    diff = abs(exp_k - cor_k)
    print(f"{i:<6} {exp_k:<15.6f} {cor_k:<15.6f} {diff:<12.9f}")

print()
print("=" * 60)
print("BUG FOUND!")
print("=" * 60)
print()
print("The current Pascal code at lines 396-398:")
print("  for i := 1 to numPoints-2 do")
print("    knots[ADegree+i] := params[i];")
print()
print(f"This places params[1..{numPoints-2}] at knots[{degree}+1..{degree}+{numPoints-2}]")
print(f"Which is knots[{degree+1}..{degree+numPoints-2}]")
print()
print("But it should place params[1..m-1] at knots[p+1..p+m-1]")
print(f"Which is knots[{degree+1}..{degree+m-1}] = knots[{degree+1}..{degree+m-1}]")
print()
print("THE FIX:")
print("  Change line 397 from:")
print("    for i := 1 to numPoints-2 do")
print("  to:")
print(f"    for i := 1 to m-1 do  // or: for i := 1 to {m-1} do")
print("  And line 398 from:")
print("    knots[ADegree+i] := params[i];")
print("  to:")
print("    knots[ADegree+i] := params[i];  // This part is correct")
