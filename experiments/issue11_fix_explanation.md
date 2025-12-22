# Issue #11: Fix Explanation

## Problem

The previous fix (PR #156) had a bug that made blocks invisible in all cases.

## Root Cause

The bug was in how `CalcActualVisible` was being used. The function returns a **boolean indicating whether visibility changed**, not whether the entity **is visible**.

### Previous (Broken) Implementation

```pascal
function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  oldValue:TActuality;
begin
  oldValue:=Visible;
  Visible:=0;  // Start invisible
  if ConstObjArray.CalcActualVisible(Actuality) then  // BUG: This checks if visibility CHANGED
    Visible:=Actuality.visibleactualy;
  Result:=oldValue<>Visible;
end;
```

The problem:
- `ConstObjArray.CalcActualVisible(Actuality)` returns `true` if **any child's visibility changed**
- This does NOT tell us if any children ARE visible
- Result: Blocks would only be visible if a child's visibility changed on this frame

## Correct Implementation

```pascal
function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  oldValue:TActuality;
  p:PGDBObjEntity;
  ir:itrec;
  hasVisibleChild:boolean;
begin
  // For complex entities (blocks), visibility is determined solely by child entities
  // not by the block's own layer state (fixes issue #11)
  oldValue:=Visible;

  // Calculate visibility for all children
  ConstObjArray.CalcActualVisible(Actuality);

  // Check if any child is visible
  hasVisibleChild:=false;
  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      if p^.Visible=Actuality.visibleactualy then begin
        hasVisibleChild:=true;
        break;
      end;
      p:=ConstObjArray.iterate(ir);
    until p=nil;

  // Set block visibility based on children
  if hasVisibleChild then
    Visible:=Actuality.visibleactualy
  else
    Visible:=0;

  Result:=oldValue<>Visible;
end;
```

## How It Works

1. **Calculate children visibility**: Call `ConstObjArray.CalcActualVisible(Actuality)` to update all children's `Visible` field
2. **Check if any child is visible**: Iterate through children and check if any have `Visible==Actuality.visibleactualy`
3. **Set block visibility**: If any child is visible, make the block visible; otherwise invisible
4. **Return change status**: Return whether the block's visibility changed

## Expected Behavior

| Scenario | Block Layer | Primitive Layers | Expected | Result |
|----------|-------------|------------------|----------|--------|
| 1 | OFF | Some ON | VISIBLE | ✓ VISIBLE |
| 2 | ON | All OFF | NOT VISIBLE | ✓ NOT VISIBLE |
| 3 | OFF | All OFF | NOT VISIBLE | ✓ NOT VISIBLE |
| 4 | ON | Some ON | VISIBLE | ✓ VISIBLE |

The key insight is that **block visibility depends ONLY on primitive visibility**, completely ignoring the block's own layer state.

## Why This Matters

In CAD systems like AutoCAD:
- Blocks can be on layer "DEFPOINTS" (typically off for dimensions)
- Primitives inside blocks can be on other layers (visible)
- The block should be visible if it contains visible primitives
- This allows for complex layer management in technical drawings
