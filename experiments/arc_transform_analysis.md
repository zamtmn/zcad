# Arc Transform Bug Analysis - Issue #515

## Problem
After transforming an arc (rotation, mirroring, scaling), the angles `StartAngle` and `EndAngle` were calculated incorrectly.

From testing data in issue #515 comments, after transformation:
- ✅ `P_insert_in_WCS` (center in world coordinates) updates correctly after PR #517
- ✅ `Local.p_insert` (center in local coordinates) updates correctly
- ✅ Radius `R` is recalculated properly
- ❌ Angles `StartAngle` and `EndAngle` are calculated incorrectly

### Example from testing:
**Before rotation 90° around (0,0,0):**
- Center WCS: (267.77, 146.22, 0)
- Center Local: (267.77, 146.22, 0)
- StartAngle: 306.36°
- EndAngle: 88.30°

**After 90° rotation - WRONG (before fix):**
- Center WCS: (-146.22, 267.77, 0) ✅ correct
- Center Local: (-413.99, 0, 0) ✅ correct
- StartAngle: 178.30° ❌ wrong
- EndAngle: 36.36° ❌ wrong

**After 90° rotation - EXPECTED (after fix):**
- Center WCS: (-146.22, 267.77, 0) ✅ correct
- Angles should be correctly transformed in local coordinate system ✅

## Root Cause
In `uzeentarc.pas:140-264`, the `transform` procedure calculated angles relative to the **global X axis** `_X_yzVertex = (1,0,0)` instead of the **local X axis** after transformation.

### Why this is a problem:
- Angles `StartAngle` and `EndAngle` are stored in the **local 2D coordinate system** (XY plane of local CS)
- After transformation, the local coordinate system rotates/scales with the object
- Transformed 3D points are in world coordinates
- To calculate correct angles, we need to transform these points back to local CS

## Previous Code Flow (WRONG)
1. `precalc()` - calculates q0, q1, q2 (start, mid, end points) in world coords
2. Check determinant to detect mirroring (swap start/end if needed)
3. Transform start/end/center points with t_matrix
4. Call `inherited` - updates objMatrix and Local.basis vectors
5. Calculate angles: `sav:=NormalizeVertex(VertexSub(sav,pins))` ← **BUG: uses pins instead of P_insert_in_WCS**
6. Calculate angles relative to **GLOBAL** X axis ← **BUG: should use LOCAL X axis**

## Solution
Calculate angles relative to the **LOCAL** X axis after transformation:

1. Transform the points with the matrix (world coordinates)
2. Call `inherited` to update objMatrix and local basis vectors
3. **Create inverse matrix from local basis to convert world coords to local coords**
4. **Transform the points from world space to local space**
5. Calculate angles in the local 2D XY plane

## Implementation (Fixed Code)

```pascal
procedure GDBObjARC.transform;
var
  sav,eav,pins:gdbvertex;
  m:DMatrix4D;
  sav_local,eav_local:gdbvertex;
begin
  { ... diagnostic output ... }

  precalc;
  if t_matrix.mtr[0].v[0]*t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[2]<eps then begin
    sav:=q2;
    eav:=q0;
  end else begin
    sav:=q0;
    eav:=q2;
  end;

  pins:=P_insert_in_WCS;
  sav:=VectorTransform3D(sav,t_matrix);
  eav:=VectorTransform3D(eav,t_matrix);
  pins:=VectorTransform3D(pins,t_matrix);
  inherited;  { Updates objmatrix, Local.basis, and P_insert_in_WCS }

  { NEW CODE: Transform points from world space to local space }
  m:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);
  MatrixInvert(m);

  { Subtract center and transform to local CS }
  sav_local:=VectorTransform3D(VertexSub(sav,P_insert_in_WCS),m);
  eav_local:=VectorTransform3D(VertexSub(eav,P_insert_in_WCS),m);

  { Normalize vectors }
  sav_local:=NormalizeVertex(sav_local);
  eav_local:=NormalizeVertex(eav_local);

  { Calculate angles in local coordinate system }
  StartAngle:=TwoVectorAngle(_X_yzVertex,sav_local);
  if sav_local.y<eps then
    StartAngle:=2*pi-StartAngle;

  EndAngle:=TwoVectorAngle(_X_yzVertex,eav_local);
  if eav_local.y<eps then
    EndAngle:=2*pi-EndAngle;

  { ... diagnostic output ... }
end;
```

## Key Changes

1. **Added variables**: `m:DMatrix4D`, `sav_local`, `eav_local`
2. **Transform to local CS**: Create inverse matrix from local basis and transform points
3. **Use P_insert_in_WCS**: Always use the correct center after transformation
4. **Calculate in local space**: Angles are now relative to local X axis

## Files Changed

- `cad_source/zengine/core/entities/uzeentarc.pas:140-233`

## Impact

This fix affects all arc transformation operations:
- Rotation
- Mirroring
- Scaling
- Any combined transformations

Arc angles now correctly remain in the local coordinate system after any transformation.

## Status

✅ Fixed in commit 826ff752a
✅ PR #518 created and updated
✅ Ready for testing
