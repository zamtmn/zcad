# Issue #11: Block Visibility Analysis

## Problem Statement

Block visibility on the defpoints layer (and other layers) is not working correctly.

### Expected Behavior

1. **If block is on a disabled layer BUT has visible primitives inside:**
   - Block SHOULD be visible
   - Block SHOULD be selectable with selection frame

2. **If block is on an enabled layer BUT all primitives inside are on disabled layers:**
   - Block SHOULD NOT be visible
   - Block SHOULD NOT be selectable with selection frame

### Current Implementation

Located in `cad_source/zengine/core/entities/uzeentcomplex.pas:76-83`:

```pascal
function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  q:boolean;
begin
  Result:=inherited;  // Checks if the block's own layer is on
  q:=ConstObjArray.CalcActualVisible(Actuality);  // Checks if any primitives are visible
  Result:=Result or q;  // ORs them together
end;
```

### Problem Analysis

The current code ORs the block's layer visibility with the primitives' visibility. This means:

- If block layer is ON → block is visible regardless of primitive visibility (WRONG)
- If block layer is OFF but primitives are visible → block becomes visible (CORRECT)

### Solution

Block visibility should be determined **only** by the visibility of primitives inside, **not** by the block's own layer state.

Change the logic to:
```pascal
function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  oldValue:TActuality;
begin
  oldValue:=Visible;
  // For complex entities (blocks), visibility is determined solely by child entities
  Visible:=0;  // Start with invisible
  if ConstObjArray.CalcActualVisible(Actuality) then
    Visible:=Actuality.visibleactualy;
  Result:=oldValue<>Visible;
end;
```

### Files to Modify

- `cad_source/zengine/core/entities/uzeentcomplex.pas` - Update `CalcActualVisible` method

### Testing Approach

Since this is a CAD application, testing would require:
1. Creating a block with primitives
2. Testing visibility with different layer states
3. Testing selectability with selection frame

However, this requires a GUI and the full application running, which may not be possible in this environment.
