# Issue #279 Root Cause Analysis

## Problem Summary

User reports that after PR #281 was merged, **both** SHX and TTF fonts display incorrectly, whereas before only SHX fonts had issues.

## Font Rendering Paths

### SHX Fonts
- `IsCanSystemDraw()` returns **false** (uzefontshx.pas:39)
- Does NOT use GDI system rendering
- Uses inherited triangle-based rendering (ZGL)
- The code in `TLLGDISymbol.drawSymbol` at lines 531-536 causes immediate exit via `inherited` call
- **Therefore: The matrix transformation code in lines 613-621 is NEVER executed for SHX fonts**

### TTF Fonts
- `IsCanSystemDraw()` returns **true** (uzefontfileformatttf.pas:267)
- DOES use GDI system rendering
- Uses the matrix transformation code in lines 613-621
- Uses `ExtTextOut` call at line 630

## Code Evolution

### Original Code (before PR #280, commit 8bc396504)
```pascal
// Lines 614-618 (old numbering)
{$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM:=MatrixMultiply(_transminusM,_transminusM2);{$ENDIF}
_transminusM:=MatrixMultiply(_transminusM,_scaleM);
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);
_transminusM:=MatrixMultiply(_transminusM,_rotateM);
_transminusM:=MatrixMultiply(_transminusM,_transplusM);

// Line 627
ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC,x,y{+round(gdiDrawYOffset)},{Options: Longint}0,@r,@s[1],-1,nil);
```

Creates matrix: `M = T(-x,-y) * Scale * Oblique * Rotate * T(x,y)`
Draws text at position: `(x,y)`

### PR #280 Changes (commit 5d554a864)
- Changed `ExtTextOut(x,y,...)` to `ExtTextOut(0,0,...)`
- Kept same matrix order
- **Result**: No change (didn't fix the issue)

### PR #281 Changes (commit 37ff938f8)
- Reversed matrix multiplication order
- Kept `ExtTextOut(0,0,...)`
- **Result**: Broke TTF fonts (which were working before)

## Critical Insight

**The user's original report was misleading!**

Looking at the code logic:
1. SHX fonts (`IsCanSystemDraw=false`) **never execute** the matrix transformation code
2. Only TTF fonts (`IsCanSystemDraw=true`) execute this code path
3. Therefore, the original issue #279 stating "all text symbols cluster near 0,0,0" could only have affected TTF fonts

**Hypothesis**: The original code was actually **correct** for TTF fonts! The issue reported might have been:
- A misunderstanding about which fonts were affected
- A different issue not related to this code
- An issue with the viewport/camera transformation, not the symbol transformation

## Solution

Since:
1. SHX fonts don't use this code path at all (they use triangle rendering)
2. TTF fonts worked with the original code
3. PR #281 broke TTF fonts by reversing the matrix order

**The correct fix is to REVERT to the original code:**
- Use the original matrix order: `T(-x,-y) * Scale * Oblique * Rotate * T(x,y)`
- Use the original ExtTextOut coordinates: `ExtTextOut(x,y,...)`

This will restore TTF font rendering to its original working state.
