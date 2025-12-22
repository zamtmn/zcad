# Bug Analysis for Issue #244

## Problem

The spline doesn't pass through the specified on-curve points (red circles). Instead, it produces incorrect control points.

## Root Cause

The `BasisFunction` in `uzccommand_spline.pas` has a bug in handling the endpoint case when `u = 1.0`.

### Evidence

When running the B-spline interpolation algorithm with 4 points:
- Knot vector: `[0, 0, 0, 0, 1, 1, 1, 1]`
- Parameter values: `[0.0, 0.38, 0.76, 1.0]`
- Degree: 3

The basis matrix should be:
```
[[1.00, 0.00, 0.00, 0.00],
 [0.24, 0.44, 0.27, 0.05],
 [0.01, 0.13, 0.42, 0.44],
 [0.00, 0.00, 0.00, 1.00]]  <-- Last row should have 1.00 in last column
```

But the actual matrix is:
```
[[1.00, 0.00, 0.00, 0.00],
 [0.24, 0.44, 0.27, 0.05],
 [0.01, 0.13, 0.42, 0.44],
 [0.00, 0.00, 0.00, 0.00]]  <-- BUG: All zeros!
```

This makes the matrix singular (determinant = 0), so the linear system cannot be solved.

## The Bug in BasisFunction

Looking at lines 67-78 in `uzccommand_spline.pas`:

```pascal
// Special case for clamped B-splines at the endpoint
// For n+1 control points with degree p, the knot vector has n+p+2 elements
// When u equals the last knot value (u=1.0 for normalized knots), only the last basis function should be non-zero
numCtrlPts:=Length(knots)-p-2;  // Number of control points minus 1
if (abs(u-knots[Length(knots)-1])<1e-10) and (abs(knots[Length(knots)-1]-knots[Length(knots)-p-1])<1e-10) then begin
  // At the last knot with multiplicity p+1
  if i=numCtrlPts then
    Result:=1.0
  else
    Result:=0.0;
  exit;
end;
```

### Problem 1: Wrong Condition

The condition checks:
```pascal
(abs(knots[Length(knots)-1]-knots[Length(knots)-p-1])<1e-10)
```

For our case with 4 points, degree 3:
- `Length(knots) = 8`
- `knots = [0, 0, 0, 0, 1, 1, 1, 1]`
- `knots[7] = 1.0` (last knot)
- `knots[7 - 3 - 1] = knots[3] = 0.0`

So it checks: `abs(1.0 - 0.0) < 1e-10` which is **FALSE**!

This means the special case handler NEVER ACTIVATES, so the function falls through to the general case.

### Problem 2: Degree 0 Edge Case

The degree 0 case (lines 80-90) has a condition:
```pascal
else if (u=knots[i+1]) and (i=Length(knots)-2) then
  // Special case: u is at the last knot
  Result:=1.0
```

For the last basis function (i=3):
- We check: `i = Length(knots)-2 = 8-2 = 6`
- But i=3, not 6!
- So this returns 0.0 instead of 1.0

## The Fix

We need to fix the special case handling for when `u = 1.0` (the last parameter value).

For a clamped B-spline with n+1 control points and degree p:
- Knot vector has n+p+2 elements
- Valid basis function indices: 0 to n
- At u=0: only N_{0,p}(0) = 1
- At u=1: only N_{n,p}(1) = 1

The correct check should be:
1. Check if u is at the maximum knot value (u ≈ knots[last])
2. Check if we're evaluating the last basis function (i = n = numPoints-1)
3. If both true, return 1.0
4. If u is at max but i < n, return 0.0

### Correct Implementation

Replace lines 67-78 with:

```pascal
// Special case for clamped B-splines at the endpoint
// When u equals the last knot value, only the last basis function should be non-zero
numCtrlPts:=Length(knots)-p-2;  // Number of control points minus 1
if abs(u-knots[Length(knots)-1])<1e-10 then begin
  // At the last knot value
  if i=numCtrlPts then
    Result:=1.0
  else
    Result:=0.0;
  exit;
end;
```

The key change: Remove the second condition that checked knot multiplicity. Just check if u is at the last knot value.

Similarly, for degree 0 case at lines 84-85, change:
```pascal
else if (abs(u-knots[i+1])<1e-10) and (i+1=Length(knots)-1) then
```

## Verification

After this fix, the basis matrix should be:
```
[[1.00, 0.00, 0.00, 0.00],
 [0.24, 0.44, 0.27, 0.05],
 [0.01, 0.13, 0.42, 0.44],
 [0.00, 0.00, 0.00, 1.00]]  <-- Correct!
```

Determinant ≠ 0, so the system can be solved, and the spline will pass through all points.
