# Fix for vstDev Tree Indicators Issue #176

## Problem
The tree node expand/collapse indicators ("+"/"-") were missing in the `vstDev` component.

## Root Cause Analysis

### Previous Attempt (PR #177)
PR #177 added an empty column 0 and shifted all other columns to the right. While this was a step in the right direction, it didn't solve the issue because:

1. Column 0 was added but `Header.MainColumn` remained set to `-1`
2. When `MainColumn = -1`, VirtualStringTree doesn't know which column should display the tree structure
3. The tree indicators are drawn in the column specified by `MainColumn`

### The Real Issue
In Lazarus VirtualStringTree (TLazVirtualStringTree), the `Header.MainColumn` property determines which column displays the tree structure (indentation, tree lines, and +/- buttons).

From the LFM file (line 72):
```pascal
Header.MainColumn = -1
```

This setting means "no main column", which prevents the tree indicators from being displayed.

## Solution

Set `Header.MainColumn := 0` in the `InitializeVstDev` procedure to tell VirtualStringTree that column 0 should contain the tree structure.

### Code Change
In `velectrnav.pas`, in procedure `TVElectrNav.InitializeVstDev`, after line 319:

```pascal
vstDev.Header.AutoSizeIndex := -1;
vstDev.Header.MainColumn := 0; // Колонка 0 содержит индикаторы дерева (+/-)
```

## How It Works

1. **Column 0** is empty (width 30px) and serves as the tree structure column
2. **MainColumn = 0** tells VirtualStringTree to draw tree indicators in column 0
3. **toShowButtons** and **toShowTreeLines** options are already set (line 312)
4. All data columns (1-7) remain functional with their original behavior

## Testing Verification

To verify the fix works:
1. Build the project with the changes
2. Open the VElectrNav frame
3. Load devices using the "*" button (AllSelActionExecute)
4. Check that vstDev displays "+"/"-" indicators in column 0 for expandable nodes
5. Verify that clicking the indicators expands/collapses the tree nodes

## References
- Issue: #176
- Previous PR: #177
- Lazarus VirtualStringTree documentation on MainColumn property
