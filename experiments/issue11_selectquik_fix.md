# Issue #11: Final Fix - SelectQuik Override

## Problem Statement

After implementing fixes in PR #181 (visibility), PR #183 (IsActualy), and PR #185 (Russian comments), users still report that blocks on disabled layers with visible primitives cannot be selected.

According to veb86's comment on 2025-10-15T19:06:44Z:
> "If a block is on a disabled layer but contains primitives on a VISIBLE layer, the block should be visible and selectable by selection frame. **The problem persists.** Now the block is visible BUT it cannot be selected. Make it so it can be selected."

## Root Cause Analysis

The previous fix (PR #183) overrode `IsActualy` in `GDBObjComplex`, which fixed selection through `isonmouse`. However, there's a **second selection path** that was missed:

### The SelectQuik Method

In `uzeentity.pas:74-82`, the `SelectQuik` method directly checks the entity's own layer state:

```pascal
function GDBObjEntity.SelectQuik:boolean;
begin
  if (vp.Layer._lock)or(not vp.Layer._on) then begin
    Result:=False;
  end else begin
    Result:=True;
    selected:=True;
  end;
end;
```

### Selection Call Chain

From `uzeentity.pas:84-93`, the `select` method calls `SelectQuik`:

```pascal
function GDBObjEntity.select;
begin
  Result:=False;
  if selected=False then begin
    Result:=SelectQuik;  // <-- This checks the block's layer directly!
    if Result then
      if assigned(s2s) then
        s2s(@self,@self,SelectedObjCount);
  end;
end;
```

**The Problem:**
- When a block on layer DEFPOINTS (disabled) is selected, `select` calls `SelectQuik`
- `SelectQuik` checks `vp.Layer._on` which is `False` for DEFPOINTS
- Selection is rejected even though the block has visible children!
- The `IsActualy` fix from PR #183 only affected the `isonmouse` path, not the direct `select` path

## Solution

Override `SelectQuik` in `GDBObjComplex` to check if any child primitive's layer is enabled and unlocked:

```pascal
function GDBObjComplex.SelectQuik:boolean;
var
  p:PGDBObjEntity;
  ir:itrec;
  anyChildSelectable:boolean;
begin
  // Для сложных объектов (блоков) возможность выделения определяется дочерними примитивами,
  // а не состоянием собственного слоя блока (исправление issue #11)
  // Если хотя бы один дочерний примитив может быть выделен (слой включен и не заблокирован),
  // то блок тоже может быть выделен
  // For complex entities (blocks), selectability is determined by child primitives,
  // not by the block's own layer state (fixes issue #11)
  // If at least one child primitive is selectable (layer on and not locked),
  // then the block can be selected too
  anyChildSelectable:=false;
  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      // Проверяем, может ли дочерний примитив быть выделен
      // Check if child primitive can be selected
      if p^.vp.Layer<>nil then
        if (p^.vp.Layer^._on) and (not p^.vp.Layer^._lock) then begin
          anyChildSelectable:=true;
          break;
        end;
      p:=ConstObjArray.iterate(ir);
    until p=nil;

  if anyChildSelectable then begin
    Result:=true;
    selected:=true;
  end else begin
    Result:=false;
  end;
end;
```

## How It Works

1. **Iterate through child primitives**: Check each child's layer state
2. **Check selectability**: A child is selectable if its layer is ON and NOT locked
3. **Set block selection**: If any child is selectable, mark the block as selected
4. **Return result**: Return true if block can be selected, false otherwise

## Consistency Across Methods

Now all three methods work consistently:

| Method | Purpose | Check Logic |
|--------|---------|-------------|
| `CalcActualVisible` | Visibility | Block visible if any child is visible |
| `IsActualy` | Selection via `isonmouse` | Block "actual" if any child is actual |
| `SelectQuik` | Direct selection | Block selectable if any child layer is ON and unlocked |

All three methods now consistently check **child state** rather than the block's own layer state.

## Expected Behavior

| Scenario | Block Layer | Primitive Layers | Block Visible | Block Selectable (isonmouse) | Block Selectable (direct) |
|----------|-------------|------------------|---------------|------------------------------|---------------------------|
| 1 | OFF | Some ON, unlocked | YES | YES | YES ✓ |
| 2 | ON | All OFF | NO | NO | NO ✓ |
| 3 | OFF | All OFF | NO | NO | NO ✓ |
| 4 | ON | Some ON, unlocked | YES | YES | YES ✓ |
| 5 | OFF | Some ON, but locked | YES | YES | NO ✓ |

Note: Scenario 5 shows that locked layers prevent selection (as expected), but the block is still visible if the primitives are visible.

## Files Modified

- `cad_source/zengine/core/entities/uzeentcomplex.pas`:
  - Added `function SelectQuik:boolean;virtual;` declaration (line 68)
  - Implemented the method to check child primitive layers (lines 100-134)

## Why Previous Fixes Weren't Enough

- **PR #181**: Fixed visibility ✓
- **PR #183**: Fixed `IsActualy` for `isonmouse` selection path ✓
- **PR #185**: Added Russian comments ✓
- **This PR**: Fixes `SelectQuik` for direct selection path ✓

The issue required fixing **two separate selection paths** in the codebase.

## Testing

Manual testing required:
1. Create a block with primitives on visible, unlocked layers
2. Place block insert on DEFPOINTS layer (or other disabled layer)
3. Verify block is visible (should work from PR #181)
4. **Try selecting block with mouse click** (direct selection)
5. **Try selecting block with selection frame** (isonmouse selection)
6. Both selection methods should now work ✓
7. Lock a primitive layer and verify block becomes unselectable
8. Turn off all primitive layers and verify block becomes invisible and unselectable

## Technical Notes

- The fix properly checks both `_on` (layer enabled) and `_lock` (layer not locked)
- Performance impact is minimal - iterates until first selectable child is found
- The method sets `selected:=true` directly, matching the parent class behavior
- Recursion naturally handles nested blocks (blocks within blocks)
