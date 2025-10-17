# Issue #229 Solution - Level 2 Grouping Fix

## Problem Summary

**Issue:** https://github.com/veb86/zcadvelecAI/issues/229

The original implementation created Level 2 groups for EVERY device, even single devices. This resulted in unnecessary nesting and poor user experience.

### Before Fix (Wrong Behavior)
```
├── ВРУ-Гр.1 (Level 1)
│   ├── DeviceA (Level 2) <- Unnecessary container for single device
│   │   └── DeviceA (гр.1)
│   ├── DeviceB (Level 2) <- Unnecessary container for single device
│   │   └── DeviceB (гр.1)
│   └── DeviceC (Level 2) <- Unnecessary container for single device
│       └── DeviceC (гр.1)
```

### After Fix (Correct Behavior)
```
├── ВРУ-Гр.1 (Level 1)
│   ├── LampA (Level 2) <- Container created only for multiple matching devices
│   │   ├── LampA (гр.1)
│   │   ├── LampA (гр.1)
│   │   └── LampA (гр.1)
│   ├── Socket (гр.1) <- Single device added directly to Level 1
│   └── LampB (Level 2) <- Container created for 2+ matching devices
│       ├── LampB (гр.1)
│       └── LampB (гр.1)
```

## Solution Approach

### Key Changes

1. **Lookahead Logic**: Check the next device before deciding whether to create Level 2 group
2. **Grouping State Tracking**: Use `inLevel2Group` flag to track whether we're currently grouping
3. **Conditional Device Placement**:
   - If device matches next device → Create/use Level 2 group
   - If device doesn't match next but matches previous → Add to existing Level 2 group
   - If device is standalone → Add directly to Level 1

### Algorithm

```pascal
for each device in filteredDevices:
  1. Check if we need new Level 1 node (feedernum changed)

  2. Look ahead to next device:
     a. If next device exists and matches current:
        - Create Level 2 group (if not already in one or attributes changed)
        - Add current device to Level 2
        - Set inLevel2Group = true

     b. If next device doesn't match but we're in a group:
        - Check if current matches last device in group
        - If yes: add to Level 2 (last device of group)
        - If no: add directly to Level 1
        - Set inLevel2Group = false

     c. If no next device (last in list):
        - If in group and matches: add to Level 2
        - Otherwise: add directly to Level 1
```

## Implementation Details

### Modified Variables

**Removed:**
- `isNewLevel2Group` - No longer needed with new logic

**Added:**
- `inLevel2Group: boolean` - Tracks whether we're in grouping mode
- `hasNextDevice: boolean` - Cache for bounds check
- `nextDevice: TVElectrDevStruct` - Next device for lookahead
- `nextGroupDev: TVElectrDevStruct` - Group info for next device

### Key Code Sections

#### 1. Level 1 Group Creation (lines 316-323)
```pascal
if isFirstDevice or (groupDev.feedernum <> lastFeederNum) then
begin
  Level1Node := CreateGroupNode(groupDev);
  lastFeederNum := groupDev.feedernum;
  isFirstDevice := False;
  inLevel2Group := False; // Reset grouping on Level 1 change
end;
```

#### 2. Lookahead Check (lines 325-339)
```pascal
hasNextDevice := (i + 1 < filteredDevices.Size);

if hasNextDevice then
begin
  nextDevice := filteredDevices[i + 1];

  // Determine groupDev for next device
  if (ProcessStrings(filterPath, nextDevice.fullpathHD) = 0) then
    nextGroupDev := nextDevice
  else
    nextGroupDev := groupDev;
```

#### 3. Matching Device Logic (lines 343-358)
```pascal
if (groupDev.feedernum = nextGroupDev.feedernum) and
   DevicesHaveSameAttributes(device, nextDevice) then
begin
  // Create Level 2 if needed
  if not inLevel2Group or not DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
  begin
    Level2Node := CreateDeviceGroupNode(Level1Node, device);
    inLevel2Group := True;
  end;

  CreateDeviceNode(Level2Node, device);
  lastDeviceInLevel2 := device;
end
```

#### 4. Non-Matching Device Logic (lines 359-376)
```pascal
else
begin
  // Check if part of previous group
  if inLevel2Group and DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
    CreateDeviceNode(Level2Node, device) // Last in group
  else
    CreateDeviceNode(Level1Node, device); // Standalone

  inLevel2Group := False; // Exit grouping mode
end
```

## Test Scenarios

### Scenario 1: All Devices Have Same Attributes
**Input:**
- Device1: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device2: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device3: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1

**Expected Result:**
```
├── ВРУ-Гр.1
    └── Lamp (Level 2)
        ├── Lamp (гр.1)
        ├── Lamp (гр.1)
        └── Lamp (гр.1)
```
✅ One Level 2 group created for all 3 matching devices

### Scenario 2: All Devices Are Different
**Input:**
- Device1: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device2: basename="Socket", realname="B", power=200, voltage=220, cosfi=0.85, phase="L2", feedernum=1
- Device3: basename="Heater", realname="C", power=300, voltage=220, cosfi=0.95, phase="L3", feedernum=1

**Expected Result:**
```
├── ВРУ-Гр.1
    ├── Lamp (гр.1)      <- No Level 2
    ├── Socket (гр.1)    <- No Level 2
    └── Heater (гр.1)    <- No Level 2
```
✅ No Level 2 groups created, all devices added directly to Level 1

### Scenario 3: Mixed - Some Matching, Some Not
**Input:**
- Device1: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device2: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device3: basename="Socket", realname="B", power=200, voltage=220, cosfi=0.85, phase="L2", feedernum=1
- Device4: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device5: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device6: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1

**Expected Result:**
```
├── ВРУ-Гр.1
    ├── Lamp (Level 2)    <- Group for Device1-2
    │   ├── Lamp (гр.1)
    │   └── Lamp (гр.1)
    ├── Socket (гр.1)     <- Standalone
    └── Lamp (Level 2)    <- Group for Device4-6
        ├── Lamp (гр.1)
        ├── Lamp (гр.1)
        └── Lamp (гр.1)
```
✅ Level 2 groups created only for matching devices, standalone device added directly

### Scenario 4: Multiple Level 1 Groups
**Input:**
- Device1: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device2: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device3: basename="Socket", realname="B", power=200, voltage=220, cosfi=0.85, phase="L2", feedernum=2
- Device4: basename="Socket", realname="B", power=200, voltage=220, cosfi=0.85, phase="L2", feedernum=2

**Expected Result:**
```
├── ВРУ-Гр.1
│   └── Lamp (Level 2)
│       ├── Lamp (гр.1)
│       └── Lamp (гр.1)
└── ВРУ-Гр.2
    └── Socket (Level 2)
        ├── Socket (гр.2)
        └── Socket (гр.2)
```
✅ Grouping correctly resets when Level 1 changes

### Scenario 5: Single Device at End
**Input:**
- Device1: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device2: basename="Lamp", realname="A", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
- Device3: basename="Socket", realname="B", power=200, voltage=220, cosfi=0.85, phase="L2", feedernum=1

**Expected Result:**
```
├── ВРУ-Гр.1
    ├── Lamp (Level 2)
    │   ├── Lamp (гр.1)
    │   └── Lamp (гр.1)
    └── Socket (гр.1)    <- Last device is standalone
```
✅ Last device correctly handled as standalone

## Benefits

1. **Cleaner UI**: No unnecessary nesting for single devices
2. **Better UX**: Users see grouping only where it matters
3. **Correct Semantics**: Level 2 groups represent actual grouping, not just containers
4. **Backward Compatible**: Doesn't break existing functionality
5. **Performance**: Same O(n) complexity with minimal lookahead overhead

## Files Modified

- `cad_source/zcad/velec/connectmanager/gui/uzvvstdevpopulator.pas` - Main implementation

## Notes

- The `GetFilteredDevicesList()` function was already implemented in a previous fix
- The `DevicesHaveSameAttributes()` comparison function remains unchanged
- All existing methods preserved for backward compatibility
