# Debug Analysis for Arc Transform Issue #73

## Problem Summary
When an arc is rotated or mirrored, its center point (P_insert_in_WCS) does not get transformed correctly. The center stays at its original position instead of being transformed along with the rest of the arc.

## Current Code Flow

### Transform Method (uzeentarc.pas:139-203)
1. `precalc()` - calculates q0, q1, q2 (start, mid, end points)
2. Transform sav, eav, pins with t_matrix
3. `inherited` - calls parent transform
   - GDBObjWithMatrix.transform: `ObjMatrix := MatrixMultiply(ObjMatrix, t_matrix)`
   - GDBObjWithLocalCS.transform: calls `ReCalcFromObjMatrix`

### ReCalcFromObjMatrix (uzeentarc.pas:251-269)
```pascal
procedure GDBObjARC.ReCalcFromObjMatrix;
var
  ox,oy:gdbvertex;
  m:DMatrix4D;
begin
  inherited;

  ox:=GetXfFromZ(Local.basis.oz);
  oy:=NormalizeVertex(VectorDot(Local.basis.oz,Local.basis.ox));

  Local.basis.ox:=ox;
  Local.basis.oy:=oy;

  m:=CreateMatrixFromBasis(ox,oy,Local.basis.oz);

  Local.P_insert:=VectorTransform3D(PGDBVertex(@objmatrix.mtr[3])^,m);  // BUG HERE!
  self.R:=PGDBVertex(@objmatrix.mtr[0])^.x/local.basis.OX.x;
end;
```

## Root Cause

The bug is on line 267:
```pascal
Local.P_insert:=VectorTransform3D(PGDBVertex(@objmatrix.mtr[3])^,m);
```

This line extracts the translation from objmatrix (which is in world coordinates) and transforms it by the basis matrix `m`. However:

1. `PGDBVertex(@objmatrix.mtr[3])^` is the translation part of objmatrix, which represents a position in WORLD coordinates.
2. `m` is created as `CreateMatrixFromBasis(ox,oy,Local.basis.oz)`, which is a matrix that transforms FROM local TO world coordinates.
3. To convert from world coordinates to local coordinates, we need the INVERSE of `m`.

So the line should be:
```pascal
MatrixInvert(m);
Local.P_insert:=VectorTransform3D(PGDBVertex(@objmatrix.mtr[3])^,m);
```

## Verification

Let's trace through a rotation example:
- Original center: (152, 155) in world space
- After rotation around (150, 150) by 25°: should be (149.6995, 155.3768)

Without the fix:
1. objMatrix is multiplied by t_matrix, so mtr[3] gets the transformed translation
2. But ReCalcFromObjMatrix transforms it by the basis matrix instead of its inverse
3. This produces an incorrect Local.p_insert
4. When CalcObjMatrix is called again, it reconstructs objMatrix from the incorrect Local.p_insert
5. P_insert_in_WCS ends up being wrong

With the fix:
1. objMatrix is multiplied by t_matrix
2. ReCalcFromObjMatrix correctly extracts the world position from mtr[3] and converts it to local coordinates using the inverse basis matrix
3. Local.p_insert is now correct
4. Future CalcObjMatrix calls will produce the correct objMatrix and P_insert_in_WCS

## Solution

Add `MatrixInvert(m);` before line 267 in ReCalcFromObjMatrix.
