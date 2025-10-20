# Issue #290: Root Cause Analysis

## Problem Description
TTF font rendering in GDI shows incorrect font display parameters. When text height is changed, characters overlap and stick together.

**Test case:**
- Font: ARIALUNI.TTF (Arial Unicode MS)
- Height: 3.0
- Text: Unicode Bengali characters (from test.dxf)

## Code Analysis

### Current Implementation (uzgldrawergdi.pas:641-723)

```pascal
// Convert Unicode codepoint to UTF-8
cnvStr[0]:=lo(word(SymCode));
cnvStr[1]:=hi(word(SymCode));
s:=UTF16ToUTF8(@cnvStr,1);  // Converts UTF-16 to UTF-8

// Later...
ExtTextOut(DC, 0, 0, 0, @r, @s[1], -1, nil);
```

## Root Cause

### Issue 1: ExtTextOut with UTF-8 on Windows

`ExtTextOut` on Windows has two versions:
- `ExtTextOutA` - expects ANSI string
- `ExtTextOutW` - expects UTF-16 (Unicode) string

The code currently uses `ExtTextOut` (which resolves to `ExtTextOutA` in non-Unicode builds) with:
1. UTF-8 encoded string (`s`)
2. Character count of `-1` (null-terminated)

**Problem:** When ExtTextOutA encounters UTF-8 multi-byte sequences with `-1` count, it treats each byte as a separate ANSI character, causing:
- Incorrect character interpretation
- Wrong advance width calculations
- Character overlap

### Issue 2: Character Count Parameter

The parameter `-1` tells Windows to use null-terminated string length. For UTF-8:
- A single Unicode character can be 1-4 bytes
- Bengali characters (like in test file) are typically 3 bytes in UTF-8
- Windows counts **bytes**, not **characters**

**Example:**
- Unicode: U+0995 (Bengali Ka)
- UTF-8: E0 A4 95 (3 bytes)
- With `-1`: Windows sees 3 characters instead of 1
- Result: Advance width calculated for 3 chars → overlap

## Solution

### Option 1: Use ExtTextOutW with UTF-16 (RECOMMENDED)

```pascal
{$IFDEF WINDOWS}
  // Use UTF-16 directly for Windows
  ExtTextOutW(DC, 0, 0, 0, @r, @cnvStr[0], 1, nil);
{$ELSE}
  // For non-Windows, use current UTF-8 approach with proper length
  s:=UTF16ToUTF8(@cnvStr,1);
  ExtTextOut(DC, 0, 0, 0, @r, @s[1], length(s), nil);
{$ENDIF}
```

**Pros:**
- ✅ Direct UTF-16 → no conversion
- ✅ Correct character count (always 1)
- ✅ Windows native Unicode support
- ✅ Proper advance width calculation

**Cons:**
- Platform-specific code

### Option 2: Fix UTF-8 Length

```pascal
s:=UTF16ToUTF8(@cnvStr,1);
ExtTextOut(DC, 0, 0, 0, @r, @s[1], length(s), nil);
```

**Pros:**
- ✅ Minimal change
- ✅ Cross-platform

**Cons:**
- ⚠️ Still relies on ANSI version with UTF-8 (may have other issues)
- ⚠️ Windows may not handle UTF-8 correctly in ExtTextOutA

## Recommendation

Use **Option 1** for Windows builds to ensure proper Unicode handling and correct character advance widths.

## Related Issues

This is related to the FIX #290 comment in PR #291, which mentioned the problem but only added documentation without implementing the actual fix.
