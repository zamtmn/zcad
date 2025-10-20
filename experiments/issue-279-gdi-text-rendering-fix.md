# Issue #279: Fix for TLLGDISymbol.drawSymbol Text Positioning Bug

## Problem Description
When GDI rendering is enabled, all text symbols were gathering near coordinate 0,0,0 instead of being positioned at their correct locations.

## Root Cause Analysis

The bug was in `TLLGDISymbol.drawSymbol` method in `uzgldrawergdi.pas` at line 626.

### The Issue
The method constructs a world transformation matrix that includes:
1. Translation to origin: `-x, -y`
2. Scaling by text size
3. Oblique transformation (if needed)
4. Rotation transformation
5. Translation back to position: `+x, +y`

This transformation matrix is then applied to the Device Context using `SetWorldTransform_`.

**The bug**: After setting this world transformation, the code called:
```pascal
ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC, x, y, ...)
```

This caused **double transformation**:
- The world transform already translated the coordinate system to position (x,y)
- Then ExtTextOut was drawing at (x,y) within that transformed coordinate system
- Result: Text appeared at approximately (x + x*scale*rotation, y + y*scale*rotation)

When world coordinates near 0,0,0 were transformed to screen coordinates far from 0,0,0, this double transformation caused all text to cluster near screen position 0,0,0.

## The Fix

Changed line 626 from:
```pascal
ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC, x, y, ...)
```

To:
```pascal
ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC, 0, 0, ...)
```

Since the world transformation already includes the translation to (x,y), the drawing should occur at the origin (0,0) of the transformed coordinate system.

## Technical Details

### Coordinate Transformation Flow:
1. Line 572-575: Initialize point at (0,0,0) and transform by symbol matrix
2. Line 576: Translate point to screen coordinates
3. Line 577-578: Round to integer screen position (x,y)
4. Line 600-617: Build transformation matrix including translation to (x,y)
5. Line 622: Apply transformation to DC
6. Line 626: Draw text at (0,0) - the transformation handles positioning

### Matrix Composition (lines 600-617):
```
_transminusM = translate(-x,-y) * scale * oblique * rotate * translate(+x,+y)
```

This is a standard "transform around point" pattern where:
- First translate to origin
- Apply transformations (scale, shear, rotate)
- Translate back to desired position

The final matrix already contains all positioning information, so drawing primitives should use local coordinates (0,0).

## Files Modified
- `cad_source/zengine/zgl/gdi/uzgldrawergdi.pas` (line 626)
