# Issue #310: Character Spacing Not Scaling Proportionally with TTF Font Height

## Problem Description

When increasing TTF font height in GDI rendering, the inter-character spacing does not scale proportionally, causing visual distortions. The user suspects incorrect transformation logic.

## Current Implementation Analysis

### Font Creation (uzgldrawergdi.pas:610-611)

```pascal
lfcp.lfHeight:=deffonth;  // Fixed at 100
lfcp.lfWidth:=0;           // Auto-calculated by GDI
```

The font is created with:
- **Fixed height**: `deffonth = 100` pixels
- **Auto width**: `lfWidth = 0` means GDI calculates character widths automatically for height=100

### Scaling Calculation (uzgldrawergdi.pas:665-681)

```pascal
txtSy:=PSymbolsParam^.NeededFontHeight/(rc.DrawingContext.zoom)/(deffonth);

// Apply compensating correction for TTF fonts
if (PGDBfont(PSymbolsParam.pfont)^.font is TZETFFFontImpl) then begin
  with TZETFFFontImpl(PGDBfont(PSymbolsParam.pfont)^.font).TTFImpl do begin
    if (Ascent + Descent) <> 0 then begin
      txtSy := txtSy * (CapHeight * CapHeight) / ((Ascent + Descent) * (Ascent + Descent));
    end;
  end;
end;

txtSx:=txtSy*PSymbolsParam^.sx;
```

### Transformation Application (uzgldrawergdi.pas:722-744)

```pascal
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
// ... compose with oblique, rotate, translate
SetWorldTransform_(DC, _transminusM);
ExtTextOut(DC, 0, 0, 0, @r, @s[1], length(s), nil);
```

## Root Cause Analysis

### Issue #1: Complex Compensation Chain

The current code has a complex chain of compensations:

1. **In uzefontfileformatttf.pas** (PR #295):
   ```pascal
   NeededFontHeight := height * (CapHeight / (Ascent+Descent))
   ```

2. **In uzgldrawergdi.pas** line 675:
   ```pascal
   txtSy *= (CapHeight / (Ascent+Descent))^2
   ```

**Result**:
```
txtSy = height * (CapHeight/(Ascent+Descent))^3 / zoom / deffonth
```

This cubic relationship is likely causing non-proportional scaling.

### Issue #2: GDI Character Spacing with WorldTransform

When using WorldTransform with ExtTextOut:
- ✅ **Glyph shapes** are transformed correctly
- ⚠️ **Character advance widths** are transformed by the horizontal scale factor `txtSx`

The problem: GDI calculates character advance widths for the BASE font (height=100, width=0), then applies the WorldTransform. However, there's a mismatch:

1. Font created at height=100
2. GDI calculates advance width `w_base` for height=100
3. WorldTransform scales by `txtSx` and `txtSy`
4. Final advance width: `w_final = w_base * txtSx`
5. Final glyph height: `h_final = 100 * txtSy`

**The Issue**: The advance width is scaled by `txtSx`, but if the font metrics compensation (the `(CapHeight/(Ascent+Descent))^2` factor) affects `txtSy` more than `txtSx`, the ratio between character spacing and glyph height changes.

### Mathematical Analysis

For a font with specific metrics (e.g., CapHeight=700, Ascent=900, Descent=200):
- Ratio = 700 / 1100 ≈ 0.636
- Compensation factor = Ratio^2 ≈ 0.405

When `NeededFontHeight` changes:
- `txtSy` is scaled by 0.405 (gets much smaller)
- `txtSx = txtSy * sx`, so it also gets smaller by the same factor
- But the proportions might still be off if the wrong formula is used upstream

## Solution Options

### Option 1: Remove the Cubic Compensation (Recommended)

The issue is that we're compensating for a wrong formula that was already fixed in PR #295. The comment says "the fix was reverted" but PR #295 actually changed the formula to use the inverted ratio. So we might be double-compensating.

**Action**: Check if the `(CapHeight/(Ascent+Descent))^2` compensation in uzgldrawergdi.pas:675 is still needed after PR #295.

### Option 2: Use lfHeight Based on Actual Size

Instead of using a fixed `lfHeight=100` and scaling via WorldTransform, create the font at the actual size:

```pascal
realFontHeight := round(txtSy * deffonth);
lfcp.lfHeight := realFontHeight;
lfcp.lfWidth := 0;  // GDI will calculate width for the REAL height

// Then use minimal scaling in WorldTransform
_scaleM := CreateScaleMatrix(CreateVertex(PSymbolsParam^.sx, 1.0, 1));
```

This way, GDI calculates character widths for the actual font size, ensuring proper proportions.

### Option 3: Set lfWidth Explicitly

```pascal
lfcp.lfHeight := deffonth;
lfcp.lfWidth := round(deffonth * 0.5);  // Typical aspect ratio for fonts

// Then scale via WorldTransform
_scaleM := CreateScaleMatrix(CreateVertex(txtSx, txtSy, 1));
```

This gives GDI a base width to work with, which might improve consistency.

## Recommended Fix

Based on the analysis, I recommend **investigating and likely removing the squared compensation** (lines 668-678 in uzgldrawergdi.pas).

The logic should be:
1. PR #295 already fixed the formula in uzefontfileformatttf.pas to use the correct ratio
2. We should NOT apply additional compensation in the drawer
3. This will make `txtSy` proportional to `NeededFontHeight`, ensuring character spacing scales correctly

## Testing Plan

1. Test with different NeededFontHeight values (e.g., 10, 50, 100, 200)
2. Verify that character spacing remains proportional to glyph height
3. Check that the text matches the DXF specification for text height
4. Test with various TTF fonts with different metrics
