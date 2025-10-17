# Refactoring Issue #222: THierarchyBuilder.SortDeviceList

## Issue Summary
The sorting procedure `THierarchyBuilder.SortDeviceList` was overly complex with deeply nested comparison logic, making it difficult to extend with new sorting criteria in the future.

## Original Problem
The original implementation had a complex nested if-else structure in lines 307-351 of `uzvmchierarchy.pas`:

```pascal
// Old implementation (simplified view)
if deviceList[j].pathHD > deviceList[j + 1].pathHD then
  needSwap := True
else if deviceList[j].pathHD = deviceList[j + 1].pathHD then
begin
  if deviceList[j].Sort1 > deviceList[j + 1].Sort1 then
    needSwap := True
  else if deviceList[j].Sort1 = deviceList[j + 1].Sort1 then
  begin
    if deviceList[j].Sort2 > deviceList[j + 1].Sort2 then
      needSwap := True
    else if deviceList[j].Sort2 = deviceList[j + 1].Sort2 then
    begin
      if deviceList[j].Sort3 > deviceList[j + 1].Sort3 then
        needSwap := True;
    end;
  end;
end;
```

## Refactored Solution

### 1. Created a Type Definition for Comparison Functions
Added `TDeviceCompareFunc` type at line 30-32:
```pascal
TDeviceCompareFunc = function(const dev1, dev2: TVElectrDevStruct): Integer;
```

### 2. Implemented Individual Comparison Functions
Created separate functions for each sorting criterion (lines 319-365):
- `CompareByPathHD` - Compares devices by pathHD field (alphabetically)
- `CompareBySort1` - Compares devices by Sort1 field (numerically)
- `CompareBySort2` - Compares devices by Sort2 field (numerically)
- `CompareBySort3` - Compares devices by Sort3 field (numerically)

Each function returns:
- `-1` if dev1 < dev2
- `0` if dev1 = dev2
- `1` if dev1 > dev2

### 3. Created a Comparison Chain Function
Implemented `CompareDevices` function (lines 371-396) that chains all comparisons:
```pascal
function THierarchyBuilder.CompareDevices(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  Result := CompareByPathHD(dev1, dev2);
  if Result <> 0 then Exit;

  Result := CompareBySort1(dev1, dev2);
  if Result <> 0 then Exit;

  Result := CompareBySort2(dev1, dev2);
  if Result <> 0 then Exit;

  Result := CompareBySort3(dev1, dev2);
end;
```

### 4. Simplified the Main Sorting Procedure
The `SortDeviceList` procedure (lines 402-436) now uses a single comparison call:
```pascal
compareResult := CompareDevices(deviceList[j], deviceList[j + 1]);
if compareResult > 0 then
begin
  // swap elements
end;
```

## Benefits of Refactoring

1. **Modularity**: Each sorting criterion is isolated in its own function
2. **Readability**: The comparison logic is much clearer and easier to understand
3. **Maintainability**: Changes to individual comparison logic are localized
4. **Extensibility**: New sorting criteria can be added by:
   - Creating a new `CompareByXXX` function
   - Adding a call to that function in the `CompareDevices` chain
5. **Reusability**: Individual comparison functions can be reused elsewhere if needed
6. **Testability**: Each comparison function can be tested independently

## How to Add New Sorting Criteria

To add a new sorting criterion (e.g., by device type):

1. Add the comparison function:
```pascal
function THierarchyBuilder.CompareByDevType(const dev1, dev2: TVElectrDevStruct): Integer;
begin
  if dev1.devtype < dev2.devtype then
    Result := -1
  else if dev1.devtype > dev2.devtype then
    Result := 1
  else
    Result := 0;
end;
```

2. Add it to the comparison chain in `CompareDevices`:
```pascal
Result := CompareBySort3(dev1, dev2);
if Result <> 0 then Exit;

// Add new criterion here
Result := CompareByDevType(dev1, dev2);
```

3. Declare it in the class private section.

## Files Modified
- `cad_source/zcad/velec/connectmanager/core/uzvmchierarchy.pas`

## Testing Notes
The refactored code maintains the same sorting behavior as the original implementation. The sorting still uses bubble sort for stability and sorts by:
1. pathHD (alphabetically)
2. Sort1 (numerically ascending)
3. Sort2 (numerically ascending)
4. Sort3 (numerically ascending)

No functional changes were made, only structural improvements.
