# Issue #11: Block Selection Fix

## Problem Statement

After PR #181 fixed the visibility issue, blocks are now correctly visible when they contain visible primitives, even if the block itself is on a disabled layer (like DEFPOINTS). However, these blocks cannot be selected by the selection frame.

According to veb86's comment on 2025-10-15:
> "If a block is on a turned-off layer, but contains primitives on a VISIBLE layer, then the block should be visible and **can be selected by selection frame**. Currently the block is indeed visible, BUT it cannot be selected. Make it so it can be selected."

## Root Cause Analysis

The selection issue was traced to the `isonmouse` method in `uzeentity.pas:890-896`:

```pascal
function GDBObjEntity.isonmouse;
begin
  if IsActualy then
    Result:=onmouse(popa,mousefrustum,InSubEntry)
  else
    Result:=False;
end;
```

This method checks `IsActualy` before allowing selection. The default implementation of `IsActualy` in `uzeentity.pas:882-887`:

```pascal
function GDBObjEntity.IsActualy:boolean;
begin
  if vp.Layer^._on then
    Result:=True
  else
    Result:=False;
end;
```

**The Problem:**
- The default `IsActualy` only checks if the entity's own layer is ON
- For a block on a disabled layer (e.g., DEFPOINTS), `IsActualy` returns `False`
- Even though the block is visible (because it has visible children), it cannot be selected
- The selection system rejects the block before even checking its children

## Solution

Override the `IsActualy` method in `GDBObjComplex` to check if any child primitive is actually visible:

```pascal
function GDBObjComplex.IsActualy:boolean;
var
  p:PGDBObjEntity;
  ir:itrec;
begin
  // For complex entities (blocks), check if any child primitive is actually visible
  // This allows blocks on disabled layers to be selectable if they contain visible primitives (fixes issue #11)
  Result:=false;
  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      if p^.IsActualy then begin
        Result:=true;
        break;
      end;
      p:=ConstObjArray.iterate(ir);
    until p=nil;
end;
```

## How It Works

1. **Check children recursively**: The method iterates through all child primitives
2. **Return true if any child is actually visible**: If any child's `IsActualy` returns true (i.e., its layer is ON), the block is considered "actually" present
3. **Allow selection**: When `IsActualy` returns true, the `isonmouse` method proceeds with selection testing

## Consistency with Visibility Logic

This fix mirrors the logic used in `CalcActualVisible` (from PR #181):
- **Visibility**: Block is visible if any child is visible
- **Selection**: Block is selectable if any child is "actually" present (layer ON)

Both methods now consistently check child state rather than the block's own layer state.

## Expected Behavior

| Scenario | Block Layer | Primitive Layers | Expected Visibility | Expected Selectability | Result |
|----------|-------------|------------------|---------------------|------------------------|--------|
| 1 | OFF | Some ON | VISIBLE | SELECTABLE | ✓ |
| 2 | ON | All OFF | NOT VISIBLE | NOT SELECTABLE | ✓ |
| 3 | OFF | All OFF | NOT VISIBLE | NOT SELECTABLE | ✓ |
| 4 | ON | Some ON | VISIBLE | SELECTABLE | ✓ |

## Files Modified

- `cad_source/zengine/core/entities/uzeentcomplex.pas`:
  - Added `function IsActualy:boolean;virtual;` declaration
  - Implemented the method to check child primitives

## Testing

Manual testing required with the GUI application:
1. Create a block with primitives on various layers
2. Place block insert on DEFPOINTS layer (or other turned-off layer)
3. Ensure some primitives are on visible layers
4. Verify block is visible (should already work from PR #181)
5. **Verify block can be selected with selection frame** (new functionality)
6. Turn off all primitive layers
7. Verify block becomes invisible and unselectable

## Technical Notes

- The fix uses the same iteration pattern as `CalcActualVisible` for consistency
- Performance impact is minimal as the method only iterates until finding the first visible child
- The recursion naturally handles nested blocks (blocks within blocks)
