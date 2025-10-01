# Arc Transform Bug Analysis

## Problem
After rotating an arc by 90 degrees, the angles are calculated incorrectly.

### Example:
**Before rotation (around 0,0,0):**
- Center: (10, 5, 0)
- Radius: 7.5
- Start angle: 10°
- End angle: 150°

**After 90° rotation - Current (WRONG):**
- Center: (-14.28..., ~0, 0)
- Start angle: 240°
- End angle: 100°

**After 90° rotation - Expected (CORRECT):**
- Center: (-5, 10, 0)
- Start angle: 100°
- End angle: 240°

## Root Cause
In `uzeentarc.pas:140-167`, the `transform` procedure calculates angles relative to the **global X axis** `_X_yzVertex = (1,0,0)` instead of the **local X axis** `Local.basis.ox` after transformation.

## Current Code Flow
1. `precalc()` - calculates q0, q1, q2 (start, mid, end points) in world coords
2. Check determinant (incorrectly) to detect mirroring
3. Transform start/end/center points
4. Call `inherited` - updates objMatrix and Local.basis vectors
5. Calculate angles relative to **GLOBAL** X axis ← **BUG HERE**

## Solution
Calculate angles relative to the **LOCAL** X axis after transformation by:
1. Transforming the points with the matrix
2. Calling `inherited` to update objMatrix and local basis
3. Projecting transformed vectors into the local coordinate system
4. Calculating angles in the local 2D space using atan2

## Implementation
The angles should be calculated as:
1. Convert sav/eav from world space to local space
2. Use atan2 to get proper signed angles in the local XY plane
