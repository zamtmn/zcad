# Manual Trace of BasisFunction for 4 Points, Degree 3

## Setup
- 4 data points: n = 3
- Degree: p = 3
- Knot vector: [0, 0, 0, 0, 1, 1, 1, 1] (indices 0-7)
- Parameters: [0.0, u1, u2, 1.0] where 0 < u1 < u2 < 1

## Problem: Evaluating at u = 1.0 (last parameter)

We need the basis matrix row for i=3 (last row), where params[3] = 1.0

### Expected Basis Values at u=1.0:
- N_0,3(1.0) = 0 (first basis function is zero at the end)
- N_1,3(1.0) = 0
- N_2,3(1.0) = 0
- N_3,3(1.0) = 1 (last basis function is one at the end)

### Actual Evaluation using the Pascal Code

#### For N_3,3(1.0):
- i = 3, p = 3, u = 1.0
- knots = [0,0,0,0,1,1,1,1]

**Degree 0 initialization (lines 117-124):**
```
for j:=0 to p do begin  // j = 0 to 3
  if (u>=knots[i+j]) and (u<knots[i+j+1]) then
    N[j]:=1.0
  else if (u=knots[i+j+1]) and (i+j=Length(knots)-2) then
    N[j]:=1.0
  else
    N[j]:=0.0;
end;
```

Let's evaluate each j:

**j=0:**
- Condition 1: (1.0 >= knots[3]) and (1.0 < knots[4]) = (1.0 >= 0) and (1.0 < 1) = True and False = **False**
- Condition 2: (1.0 = knots[4]) and (3+0 = 8-2) = (1.0 = 1) and (3 = 6) = True and False = **False**
- Result: N[0] = 0.0 ✓

**j=1:**
- Condition 1: (1.0 >= knots[4]) and (1.0 < knots[5]) = (1.0 >= 1) and (1.0 < 1) = True and False = **False**
- Condition 2: (1.0 = knots[5]) and (3+1 = 8-2) = (1.0 = 1) and (4 = 6) = True and False = **False**
- Result: N[1] = 0.0 ✓

**j=2:**
- Condition 1: (1.0 >= knots[5]) and (1.0 < knots[6]) = (1.0 >= 1) and (1.0 < 1) = True and False = **False**
- Condition 2: (1.0 = knots[6]) and (3+2 = 8-2) = (1.0 = 1) and (5 = 6) = True and False = **False**
- Result: N[2] = 0.0 ✓

**j=3:**
- Condition 1: (1.0 >= knots[6]) and (1.0 < knots[7]) = (1.0 >= 1) and (1.0 < 1) = True and False = **False**
- Condition 2: (1.0 = knots[7]) and (3+3 = 8-2) = (1.0 = 1) and (6 = 6) = True and **True** = **True**
- Result: N[3] = 1.0 ✓

So N = [0, 0, 0, 1] after degree 0 initialization - this is correct!

**Now build up to degree 3 (lines 127-161):**

The recursion will gradually reduce the array from 4 elements to 1 element.

After degree 0: N = [0, 0, 0, 1]
After degree 1: N should become [0, 0, 1]
After degree 2: N should become [0, 1]
After degree 3: N should become [1]

So N_3,3(1.0) should return N[0] = 1.0 ✓

### BUT WAIT! Let's check N_2,3(1.0):

#### For N_2,3(1.0):
- i = 2, p = 3, u = 1.0
- knots = [0,0,0,0,1,1,1,1]

**Degree 0 initialization:**

**j=0:** knots[i+j] = knots[2] = 0, knots[i+j+1] = knots[3] = 0
- Condition 1: (1.0 >= 0) and (1.0 < 0) = **False**
- Condition 2: (1.0 = 0) and ... = **False**
- Result: N[0] = 0.0

**j=1:** knots[i+j] = knots[3] = 0, knots[i+j+1] = knots[4] = 1
- Condition 1: (1.0 >= 0) and (1.0 < 1) = **False**
- Condition 2: (1.0 = 1) and (2+1 = 6) = True and False = **False**
- Result: N[1] = 0.0

**j=2:** knots[i+j] = knots[4] = 1, knots[i+j+1] = knots[5] = 1
- Condition 1: (1.0 >= 1) and (1.0 < 1) = **False**
- Condition 2: (1.0 = 1) and (2+2 = 6) = True and False = **False**
- Result: N[2] = 0.0

**j=3:** knots[i+j] = knots[5] = 1, knots[i+j+1] = knots[6] = 1
- Condition 1: (1.0 >= 1) and (1.0 < 1) = **False**
- Condition 2: (1.0 = 1) and (2+3 = 6) = True and False = **False**
- Result: N[3] = 0.0

After degree 0: N = [0, 0, 0, 0]

All zeros! The recursion will propagate zeros, so N_2,3(1.0) = 0 ✓

Hmm, so the basis function logic seems correct for i=2 and i=3 at u=1.0.

### Let me check N_0,3(1.0) and N_1,3(1.0):

These should definitely be zero at u=1.0, which they would be following the same logic.

## So the basis function evaluation seems correct!

The bug must be elsewhere. Let me think about other possibilities:

### Possibility 1: The parameters are wrong

If `ComputeParameters` computes params[3] = something other than 1.0, that would be a bug.

But looking at line 176:
```pascal
params[Length(points)-1]:=1.0;
```

This explicitly sets the last parameter to 1.0.

### Possibility 2: The knot vector is wrong

For 4 points (n=3), degree 3:
- Start knots: 0,0,0,0 (p+1 = 4 times)
- Internal knots: for j from p+1=4 to n=3...

Wait! That's the bug! The loop is:
```pascal
for j:=p+1 to n do begin
```

For p=3, n=3: `for j:=4 to 3` - **this loop doesn't execute!**

So there are no internal knots, which is correct for 4 points with degree 3.

End knots: 1,1,1,1 (from i=n+1=4 to m=7)

Knot vector = [0,0,0,0,1,1,1,1] ✓

### Possibility 3: Matrix is singular

With 4 points and degree 3, the basis matrix should be:
```
[N_0,3(0)   N_1,3(0)   N_2,3(0)   N_3,3(0)  ]   [1 0 0 0]
[N_0,3(u1)  N_1,3(u1)  N_2,3(u1)  N_3,3(u1) ] = [? ? ? ?]
[N_0,3(u2)  N_1,3(u2)  N_2,3(u2)  N_3,3(u2) ]   [? ? ? ?]
[N_0,3(1)   N_1,3(1)   N_2,3(1)   N_3,3(1)  ]   [0 0 0 1]
```

For a clamped B-spline, at u=0, only the first basis function is 1, and at u=1, only the last basis function is 1. So the matrix is diagonally dominant, which should be well-conditioned.

### Possibility 4: Linear solver has a bug

The Gaussian elimination solver could have numerical issues, especially if the matrix is ill-conditioned.

### Let me re-examine the special case handling more carefully

Actually, I realize I need to test this with actual values to see what's happening. But I think I found a potential issue:

The condition `(i+j=Length(knots)-2)` checks if we're at the second-to-last knot **index**.

For knots = [0,0,0,0,1,1,1,1] (length 8):
- Length(knots)-2 = 6
- The second-to-last element is knots[6] = 1

But this condition is checking the **basis function index**, not the knot value!

## EUREKA! I think I found it!

In the degree 0 initialization, we check:
```pascal
if (u=knots[i+j+1]) and (i+j=Length(knots)-2) then
```

This is checking if the **knot index** `i+j` equals `Length(knots)-2`.

But for B-spline interpolation with n+1 control points and degree p:
- Number of knots = n + p + 2
- Valid basis function indices: 0 to n

At u=1.0, we should have N_n,p(1.0) = 1.0, but for indices i < n, we need the special case to NOT trigger.

For 4 points (n=3):
- Length(knots) = 8
- Length(knots)-2 = 6

When evaluating N_3,3(1.0):
- i=3, j=3: i+j = 6 = Length(knots)-2 ✓ (triggers correctly)

When evaluating N_2,3(1.0):
- i=2, j=3: i+j = 5 ≠ 6 (doesn't trigger, correct)

Actually, this seems correct...

## Let me check with actual points from the screenshot

Looking at the problem image, the 4th point is to the right, but the spline curves down to the origin. This suggests that when solving for the control points, the last control point comes out as (0, 0, 0) or something close to it.

If the last row of the basis matrix is all zeros (or very small values), then the back-substitution would give a default value of 0 for the last control point!

Let me check if there's an issue with how basis functions are indexed...

## WAIT! I need to check the basis function indices!

For n+1 control points (n=3 for 4 points), the valid basis function indices are 0, 1, 2, 3.

In the loop at line 350:
```pascal
for j:=0 to numPoints-1 do
  BasisMatrix[i][j]:=BasisFunction(j,ADegree,params[i],knots);
```

For numPoints=4, this calls BasisFunction with j from 0 to 3, which is correct.

But the BasisFunction needs enough knots! For j=3, p=3, we need knots[3], knots[4], ..., knots[3+3+1] = knots[7].

Our knot vector has indices 0-7, so knots[7] exists. ✓

I'm running out of hypotheses. Let me wait for the Python test to complete to see the actual matrix values.
