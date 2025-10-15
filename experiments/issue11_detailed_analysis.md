# Issue #11: Detailed Analysis of Block Visibility Problem

## Problem Statement

According to veb86's comment on 2025-10-15:
- "Now blocks are not visible at all"
- **Main clarification**: If a block is on a turned-off layer, but contains primitives on a VISIBLE layer, then the block should be visible and selectable

## Previous Fix (PR #156)

The fix changed `GDBObjComplex.CalcActualVisible` to ignore the block's layer and only use child primitives' visibility:

```pascal
function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  oldValue:TActuality;
begin
  oldValue:=Visible;
  Visible:=0;  // Start invisible
  if ConstObjArray.CalcActualVisible(Actuality) then
    Visible:=Actuality.visibleactualy;
  Result:=oldValue<>Visible;
end;
```

This **removed** the call to `inherited` which would have checked the block's own layer state.

## Why This Might Not Be Working

### Hypothesis 1: Layer "0" Inheritance
In CAD systems, primitives on layer "0" inside a block definition typically inherit the block insert's layer. If:
1. Block insert is on layer "DEFPOINTS" (off)
2. Primitives inside are on layer "0"
3. When primitives calculate their visibility, they might check the block's layer (DEFPOINTS=off)
4. Result: Primitives are not visible, so block is not visible

### Hypothesis 2: The Fix Is Correct But Test Case Is Different
Maybe the fix IS correct, but veb86 is testing a different scenario than expected.

## CAD Layer Inheritance Rules

In AutoCAD and similar systems:
- **Layer "0"**: Primitives on layer 0 inside a block take on the block insert's layer properties
- **Other layers**: Primitives on other layers maintain their own layer properties
- **DEFPOINTS**: Special layer, typically not printed but usually visible

## Requirements Clarification

From veb86's clarification, the expected behavior is:

| Block Layer | Primitive Layer | Primitive Layer State | Expected Block Visibility |
|-------------|-----------------|----------------------|---------------------------|
| OFF         | Other (not 0)   | ON                   | VISIBLE ✓                 |
| ON          | Other (not 0)   | OFF                  | NOT VISIBLE ✓             |
| OFF         | 0               | N/A (inherits block) | ?                         |

## Questions to Investigate

1. How do primitives on layer "0" calculate their visibility when inside a block?
2. Is there special handling for DEFPOINTS layer visibility?
3. Does the visibility calculation happen before or after layer inheritance is resolved?

## Potential Solutions

### Option A: Current Fix Is Correct
The current fix might be correct, but veb86's test case might involve layer "0" which needs special handling.

### Option B: Need to Check Both Conditions
Maybe we need to check BOTH:
1. If block layer is ON AND primitives are visible → visible
2. If block layer is OFF but primitives are visible → visible
3. If primitives are NOT visible → not visible regardless of block layer

This would be: `Result := primitives_visible` (which is what we have)

### Option C: Need Special Handling for Layer Inheritance
We might need to temporarily set the effective layer for primitives on layer "0" before calculating visibility.

## Next Steps

1. Search for layer "0" handling in visibility code
2. Search for how primitives inherit properties from blocks
3. Check if there's a "resolve layer" step before visibility calculation
4. Look for test cases or DXF files that show the expected behavior
