# Fix for Arc Rotation and Mirroring in 3D Space

## Changes Made to `uzeentarc.pas`

### 1. Fixed Determinant Calculation (Lines 148-150)

**Before:**
```pascal
if t_matrix.mtr[0].v[0]*t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[2]<eps then
```

**After:**
```pascal
det:=t_matrix.mtr[0].v[0]*(t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[2]-t_matrix.mtr[1].v[2]*t_matrix.mtr[2].v[1])-
     t_matrix.mtr[0].v[1]*(t_matrix.mtr[1].v[0]*t_matrix.mtr[2].v[2]-t_matrix.mtr[1].v[2]*t_matrix.mtr[2].v[0])+
     t_matrix.mtr[0].v[2]*(t_matrix.mtr[1].v[0]*t_matrix.mtr[2].v[1]-t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[0]);

if det<0 then
```

**Why:** The original code was NOT calculating the determinant properly. It was just multiplying diagonal elements, which doesn't detect mirroring correctly. The proper 3x3 determinant formula is needed to detect when the transformation includes a reflection (mirroring).

### 2. Fixed Angle Calculation in Local Coordinate System (Lines 166-182)

**Before:**
```pascal
sav:=NormalizeVertex(VertexSub(sav,pins));
eav:=NormalizeVertex(VertexSub(eav,pins));

StartAngle:=TwoVectorAngle(_X_yzVertex,sav);
if sav.y<eps then
  StartAngle:=2*pi-StartAngle;

EndAngle:=TwoVectorAngle(_X_yzVertex,eav);
if eav.y<eps then
  EndAngle:=2*pi-EndAngle;
```

**After:**
```pascal
sav:=VertexSub(sav,pins);
eav:=VertexSub(eav,pins);

m:=objMatrix;
MatrixInvert(m);
m.mtr[3]:=NulVector4D;

local_sav:=VectorTransform3D(sav,m);
local_eav:=VectorTransform3D(eav,m);

StartAngle:=ArcTan2(local_sav.y,local_sav.x);
if StartAngle<0 then
  StartAngle:=StartAngle+2*pi;

EndAngle:=ArcTan2(local_eav.y,local_eav.x);
if EndAngle<0 then
  EndAngle:=EndAngle+2*pi;
```

**Why:**
- The original code calculated angles relative to the **global X axis** (`_X_yzVertex = (1,0,0)`)
- After transformation, the arc's local coordinate system has rotated, so angles must be calculated relative to the **local X axis**
- The fix transforms the world-space vectors back into the arc's local coordinate system
- Uses `ArcTan2` for proper signed angle calculation (handles all quadrants correctly)

## How It Works

1. **Precalculate Arc Points:** Calculate q0, q1, q2 (start, middle, end points) in world space
2. **Detect Mirroring:** Calculate proper determinant to detect if transformation includes reflection
3. **Transform Points:** Apply transformation matrix to start, end, and center points
4. **Update Object Matrix:** Call `inherited` to update objMatrix and local basis vectors
5. **Convert to Local Space:**
   - Create inverse of objMatrix (without translation)
   - Transform the arc vectors from world space to local space
6. **Calculate Angles:** Use ArcTan2 in local 2D space to get correct angles

## Mathematical Verification

For a 90° rotation around Z-axis:

**Rotation Matrix:**
```
[0 -1 0 0]
[1  0 0 0]
[0  0 1 0]
[0  0 0 1]
```

**Original Arc:**
- Center: (10, 5, 0)
- Start angle: 10° → Point at (10+7.5cos(10°), 5+7.5sin(10°)) = (17.39, 6.30)
- End angle: 150° → Point at (10+7.5cos(150°), 5+7.5sin(150°)) = (3.51, 8.75)

**After 90° Rotation:**
- Center: (-5, 10, 0) ✓
- Start point: (-6.30, 17.39) → Relative to center: (-1.30, 7.39) → Angle: atan2(7.39,-1.30) ≈ 100° ✓
- End point: (-8.75, 3.51) → Relative to center: (-3.75, -6.49) → Angle: atan2(-6.49,-3.75) ≈ 240° ✓

## Testing

To test this fix:
1. Create an arc with center (10, 5, 0), radius 7.5, angles 10° to 150°
2. Rotate 90° around origin (0, 0, 0)
3. Verify:
   - Center becomes (-5, 10, 0)
   - Start angle becomes 100°
   - End angle becomes 240°
