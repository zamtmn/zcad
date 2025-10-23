# Issue #325: Font Height Coefficient Calculation

## Problem Description

For correct TTF font display in the uzgldrawergdi module, in the TLLGDISymbol.drawSymbol procedure at line 596, instead of using `PSymbolsParam^.NeededFontHeight` directly, a coefficient should be calculated based on font metrics.

For Arial.ttf, this coefficient is approximately 1.556.

## Root Cause

When rendering TrueType fonts with Windows GDI, the font is created with a fixed height (`deffonth = 100`). However, the actual rendered height of the font characters (tmHeight from TEXTMETRIC) may differ from this value.

The coefficient corrects for this discrepancy by calculating the ratio between the requested font height and the actual rendered height.

## Solution

### Font Metrics Used

We use the Windows GDI `TEXTMETRIC` structure to get the actual font metrics:

```pascal
GetTextMetrics(TZGLGDIDrawer(drawer).OffScreedDC, tm);
fontHeightCoefficient := deffonth / tm.tmHeight;
```

### How It Works

1. Font is created with `lfHeight = deffonth` (100 pixels)
2. After font creation and selection, `GetTextMetrics` retrieves actual font metrics
3. `tm.tmHeight` contains the actual character height (ascent + descent)
4. The coefficient is calculated as: `deffonth / tm.tmHeight`

### Example for Arial.ttf

For Arial at size 100:
- `deffonth` = 100
- `tm.tmHeight` ≈ 64 (varies slightly by system)
- `fontHeightCoefficient` = 100 / 64 ≈ 1.5625

This matches the expected coefficient of ~1.556 mentioned in the issue.

### Applied Changes

The coefficient is now applied in the scale calculation at line 602:

**Before:**
```pascal
txtSy := PSymbolsParam^.NeededFontHeight / (rc.DrawingContext.zoom) / (deffonth);
```

**After:**
```pascal
txtSy := PSymbolsParam^.NeededFontHeight / (rc.DrawingContext.zoom) / (deffonth) * fontHeightCoefficient;
```

## Technical Details

### TEXTMETRIC Structure

Key fields from Windows GDI TEXTMETRIC:
- `tmHeight`: The height (ascent + descent) of characters
- `tmAscent`: Units above the baseline
- `tmDescent`: Units below the baseline

Relationship: `tmHeight = tmAscent + tmDescent`

### Why This Coefficient Is Needed

The coefficient compensates for the difference between:
1. The logical font height specified when creating the font (`lfHeight`)
2. The actual rendered character height (`tmHeight`)

This ensures that fonts are displayed at the correct size regardless of the specific font's internal metrics.

## Testing

To verify the coefficient for a specific font:
1. Create a font with `lfHeight = 100`
2. Get its TEXTMETRIC
3. Calculate `coefficient = 100 / tmHeight`
4. For Arial, this should yield approximately 1.556

## References

- Microsoft Docs: TEXTMETRIC structure
- Issue #325: https://github.com/veb86/zcadvelecAI/issues/325
- Related analysis: experiments/issue-290-final-analysis.md
