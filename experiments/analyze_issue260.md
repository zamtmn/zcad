# Analysis of Issue #260

## Problem Statement
The task is to create a command that runs `ConvertOnCurvePointsToControlPointsArray` function with specific test data.

## Test Data
- **Degree**: 3 (cubic B-spline)
- **On-curve points**: 7 points
- **Expected control points**: 9 points

## Current Implementation
The current implementation uses **Standard B-spline Global Interpolation** (Piegl & Tiller, Algorithm A9.1):
- For m+1 data points: generates n+1 = m+1 control points
- 7 on-curve points → 7 control points

## Issue
The expected output has 9 control points for 7 on-curve points. This suggests a different algorithm.

## Possible Explanations

### 1. Least-Squares Approximation
Algorithm A9.3 from "The NURBS Book" allows more control points than data points.
- Could generate n+1 = m+1+k control points where k is the number of additional points
- In this case: 7 + 2 = 9 control points

### 2. Cubic Bézier Curve Conversion
If the "other program" treats the input as a piecewise cubic Bézier curve:
- 7 points could represent a Bézier curve with specific structure
- Converted to B-spline, it might have 9 control points

### 3. Different Interpolation Strategy
Some CAD programs use different parameterization or knot vector generation strategies that result in additional control points.

## Investigation Needed
1. Verify the exact algorithm used by the "other program"
2. Check if the expected control points actually interpolate the on-curve points
3. Determine if this is interpolation or approximation

## Next Steps
- Create a test to verify if the expected control points actually pass through the on-curve points
- If they don't, then it's approximation, not interpolation
- Need to identify the specific algorithm to match the expected output
