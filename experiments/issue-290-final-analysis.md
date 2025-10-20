# Issue #290: Final Analysis - TTF Font Size Problem

## Problem Description

After PR #292 fixed the UTF-8 character width calculation, a size issue remains: fonts appear approximately 2.5 times smaller than expected.

## Root Cause Analysis

### Current Font Creation Process

1. **Font created in uzgldrawergdi.pas:610**:
   ```pascal
   lfcp.lfHeight:=deffonth;  // deffonth = 100
   lfcp.lfWidth:=0;
   ```

2. **Needed height calculated in uzefontfileformatttf.pas:262**:
   ```pascal
   SymsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr.mtr[1])^)*
     ((TTFImplementation.Ascent+TTFImplementation.Descent)/
      (TTFImplementation.CapHeight));
   ```

3. **Scale factor calculated in uzgldrawergdi.pas:652**:
   ```pascal
   txtSy:=PSymbolsParam^.NeededFontHeight/(rc.DrawingContext.zoom)/(deffonth);
   ```

### The Problem

In Windows GDI, when `lfHeight` is positive, it specifies the **font cell height** (also called em square or character height including ascent, descent, and internal leading).

However, the calculation in step 2 above tries to adjust for font metrics by multiplying by `(Ascent+Descent)/CapHeight`. This adjustment is correct for vector rendering but creates a mismatch when using GDI system fonts.

### Why 2.5x?

The factor of 2.5 likely comes from the ratio:
- DXF TEXTSIZE = 2.5 (from test.dxf line 84)
- Or: Font metrics ratio (Ascent+Descent)/CapHeight ≈ 2.5 for many fonts

## Investigation Steps

### Step 1: Check Font Metrics

We need to understand the actual font metrics for ARIALUNI.TTF:
- What is `TTFImplementation.CapHeight`?
- What is `TTFImplementation.Ascent + TTFImplementation.Descent`?
- What is their ratio?

### Step 2: Compare with Expected Rendering

The test case has:
- TEXT height (code 40) = 3.0 in DXF units
- STYLE height (code 42) = 2.5
- Expected: Characters should render at height 3.0 in world coordinates

### Step 3: Verify Scale Calculation

The scale calculation should satisfy:
```
final_pixel_height = lfHeight * txtSy
                   = deffonth * (NeededFontHeight / zoom / deffonth)
                   = NeededFontHeight / zoom
```

This looks correct mathematically, BUT: `NeededFontHeight` includes the `(Ascent+Descent)/CapHeight` adjustment which may be causing the problem.

## Possible Solutions

### Option 1: Remove Font Metrics Adjustment in SetupSymbolLineParams

In `uzefontfileformatttf.pas:262`, remove or modify the font metrics adjustment:

```pascal
procedure TZETFFFontImpl.SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);
begin
  if SymsParam.IsCanSystemDraw then begin
    // OLD (current):
    // SymsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr.mtr[1])^)*
    //   ((TTFImplementation.Ascent+TTFImplementation.Descent)/
    //    (TTFImplementation.CapHeight));

    // NEW (proposed):
    SymsParam.NeededFontHeight:=oneVertexlength(PGDBVertex(@matr.mtr[1])^);
  end
end;
```

**Rationale**: When using GDI system rendering, the font metrics adjustment should be handled by GDI itself, not by our code.

### Option 2: Adjust deffonth Constant

Change `deffonth` from 100 to a value that compensates for the font metrics ratio:

```pascal
const
  deffonth={19}100;  // Try different values based on font metrics
```

**Rationale**: The commented value {19} suggests this was considered before.

### Option 3: Use GetTextMetrics to Calculate Actual Font Height

After creating the font, query its actual metrics:

```pascal
lfcp.lfHeight:=deffonth;
PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle:=CreateFontIndirect(lfcp);
SelectObject(TZGLGDIDrawer(drawer).OffScreedDC,PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle);

// NEW: Get actual font metrics
var tm: TEXTMETRIC;
GetTextMetrics(TZGLGDIDrawer(drawer).OffScreedDC, tm);
actual_height := tm.tmHeight;  // Use this instead of deffonth for txtSy calculation
```

**Rationale**: This ensures we use the actual rendered font height, not assumed values.

## Recommended Solution

**Start with Option 1** - remove the font metrics adjustment in `SetupSymbolLineParams` for system-drawn fonts. This is the cleanest solution because:

1. GDI handles font metrics internally
2. The adjustment was meant for vector-rendered fonts (OpenGL/triangles), not system fonts
3. It's a minimal, targeted change

If that doesn't work, proceed to Option 3 to use actual measured font metrics.

## Testing Plan

1. Apply fix
2. Load test.dxf
3. Verify text height matches expected 3.0 units
4. Test with different zoom levels
5. Test with different fonts (ARIAL.TTF, ARIALUNI.TTF)
6. Verify no regression in SHX font rendering
