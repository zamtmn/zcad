# Issue #229 Analysis

## Problem Description

### Issue Link
https://github.com/veb86/zcadvelecAI/issues/229

### Requirements

**Part 1** (Already implemented):
- Extract filtered list from FDevicesList based on condition: `(filterPath = '') or (device.pathHD = filterPath)`
- Implement as separate function/procedure
- Use filtered list to avoid processing unnecessary data

**Part 2** (Main problem to fix):
Incorrect condition for Level 2 group creation at line 324:
```pascal
if isNewLevel2Group or not DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
```

### Current Behavior (WRONG)

Level 2 group is created for EVERY device that differs from the previous one, even if it's a single device.

Example:
```
├── ВРУ-Гр.1 (Level 1)
│   ├── DeviceA (Level 2) <- Created even though there's only one DeviceA
│   │   └── DeviceA (гр.1)
│   ├── DeviceB (Level 2) <- Created even though there's only one DeviceB
│   │   └── DeviceB (гр.1)
│   └── DeviceC (Level 2) <- Created even though there's only one DeviceC
│       └── DeviceC (гр.1)
```

### Expected Behavior (CORRECT)

Level 2 group should ONLY be created when there are 2+ devices with matching attributes:

Criteria for creating Level 2 group:
```pascal
Result := (dev1.basename = dev2.basename) and
          (dev1.realname = dev2.realname) and
          (Abs(dev1.power - dev2.power) < EPSILON) and
          (dev1.voltage = dev2.voltage) and
          (Abs(dev1.cosfi - dev2.cosfi) < EPSILON) and
          (dev1.phase = dev2.phase);
```

Algorithm:
1. Look at current device
2. Check if NEXT device exists and has same attributes
3. If YES -> Create Level 2 group and add both devices
4. If NO -> Add current device directly to Level 1 (no Level 2 container)

Example with correct behavior:
```
├── ВРУ-Гр.1 (Level 1)
│   ├── LampA (Level 2) <- Created because 3 LampA devices exist
│   │   ├── LampA (гр.1)
│   │   ├── LampA (гр.1)
│   │   └── LampA (гр.1)
│   ├── Socket (гр.1) <- NO Level 2, added directly (only 1 Socket)
│   └── LampB (Level 2) <- Created because 2 LampB devices exist
│       ├── LampB (гр.1)
│       └── LampB (гр.1)
```

## Solution Approach

Need to implement lookahead logic:
1. Before processing each device, check if next device has same attributes
2. If current and next match, enter "grouping mode"
3. In grouping mode:
   - Create Level 2 node (if not already created for this group)
   - Add all matching devices to Level 2
   - Exit grouping mode when next device doesn't match
4. If current device doesn't match next, add directly to Level 1

## Algorithm Pseudocode

```pascal
for i := 0 to filteredDevices.Size - 1 do
begin
  device := filteredDevices[i];

  // Check Level 1 (feedernum)
  if feedernum changed then
    create new Level 1 node

  // Check if we should create Level 2 group
  hasNextDevice := (i + 1 < filteredDevices.Size)

  if hasNextDevice then
  begin
    nextDevice := filteredDevices[i + 1];

    // Both current and next are in same Level 1 group?
    if (groupDev.feedernum = nextGroupDev.feedernum) and
       DevicesHaveSameAttributes(device, nextDevice) then
    begin
      // Create Level 2 group if not in grouping mode
      if not inLevel2Group or not DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
      begin
        Level2Node := CreateDeviceGroupNode(Level1Node, device);
        inLevel2Group := true;
      end;
      CreateDeviceNode(Level2Node, device);
      lastDeviceInLevel2 := device;
    end
    else
    begin
      // No match with next -> add directly to Level 1
      CreateDeviceNode(Level1Node, device);
      inLevel2Group := false;
    end;
  end
  else
  begin
    // Last device - check if in grouping mode
    if inLevel2Group and DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
      CreateDeviceNode(Level2Node, device)
    else
      CreateDeviceNode(Level1Node, device);
  end;
end;
```

## Key Changes Required

1. Add lookahead: Check next device before deciding on Level 2 creation
2. Track grouping state: `inLevel2Group` boolean flag
3. Conditional device addition:
   - If in Level 2 group -> add to Level2Node
   - If not in group -> add directly to Level1Node
4. Handle edge cases:
   - Last device in list
   - Change of feedernum resets grouping mode
