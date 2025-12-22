# Fix for Issue #25: Arc Rotation Bug

## Problem
Arc rotation and mirroring were not working correctly. The issue reported that after rotating an arc by 25° around point (1,1,1), the result was incorrect:

**Original Arc:**
- Center: (2, 5, 0)
- Radius: 10
- Start angle: 8°
- End angle: 94°

**Current (Incorrect) Result:**
- Center: (-3.515, 2.495, 2.636)
- Start angle: 339°
- End angle: 58°

**Expected Result:**
- Center: (-0.2158, 5.0478, 0)
- Start angle: 33°
- End angle: 119°

## Root Cause
Commit 285895a16 introduced a bug by reverting the correct fix from commit b3c6b2a15.

The problem was in the `transform` procedure in `uzeentarc.pas`:

**Incorrect code (commit 285895a16):**
```pascal
Local.p_insert:=VectorTransform3D(Local.p_insert,t_matrix);
Local.basis.ox:=VectorTransform3D(Local.basis.ox,t_matrix);
Local.basis.oy:=VectorTransform3D(Local.basis.oy,t_matrix);
Local.basis.oz:=VectorTransform3D(Local.basis.oz,t_matrix);

sav:=VectorTransform3D(sav,t_matrix);
eav:=VectorTransform3D(eav,t_matrix);
pins:=Local.p_insert;

CalcObjMatrix;
```

**Why this is wrong:**
1. Transforming `Local.p_insert` directly applies the full transformation matrix (including translation) to what might already be a transformed coordinate
2. Transforming basis vectors (ox, oy, oz) with a transformation matrix that includes translation is incorrect - basis vectors are directions and should only be rotated/scaled, not translated
3. Calling `CalcObjMatrix` instead of `inherited` bypasses the parent class's proper transformation handling

**Correct code (reverted to commit b3c6b2a15):**
```pascal
pins:=P_insert_in_WCS;
sav:=VectorTransform3D(sav,t_matrix);
eav:=VectorTransform3D(eav,t_matrix);
pins:=VectorTransform3D(pins,t_matrix);
inherited;
```

**Why this is correct:**
1. Gets the world-coordinate center position (`P_insert_in_WCS`) before transformation
2. Transforms all the arc points (start, end, center) with the transformation matrix
3. Calls `inherited` which properly delegates to the parent class's transform method
4. The parent class (`GDBObjWithLocalCS.transform`) correctly:
   - Applies the transformation matrix to `objMatrix`
   - Updates the local coordinate system basis vectors properly
   - Handles both rotation and translation components correctly

## Complete Transform Flow

The complete arc transformation now works as follows:

1. **Precalculate arc points** (line 147)
   - Calculate q0 (start point), q1 (mid point), q2 (end point) in world space

2. **Detect mirroring** (lines 148-158)
   - Calculate proper 3x3 determinant of transformation matrix
   - If det < 0 (mirrored), swap start and end points

3. **Transform geometry** (lines 160-164)
   - Get center position in world coordinates
   - Transform start, end, and center points
   - Call `inherited` to properly update objMatrix and local coordinate system

4. **Calculate new angles** (lines 166-182)
   - Convert transformed points to vectors relative to new center
   - Transform vectors from world space to local coordinate system using inverse objMatrix
   - Calculate angles using ArcTan2 in the local 2D plane
   - Normalize angles to [0, 2π) range

## Fix Applied
Reverted the changes from commit 285895a16 and restored the correct implementation from commit b3c6b2a15.

File: `cad_source/zengine/core/entities/uzeentarc.pas`, lines 160-164

## Testing
The fix ensures that:
- Arc center is transformed correctly
- Arc angles are recalculated relative to the local coordinate system after transformation
- Mirroring (negative determinant) correctly swaps start and end angles
- 3D rotations work correctly
- Rotation around arbitrary points works correctly

## References
- Original fix: commit b3c6b2a15 (Fixes #7)
- Breaking change: commit 285895a16 (claimed to fix #17 but actually broke #7)
- This fix: restores b3c6b2a15 to fix issue #25
