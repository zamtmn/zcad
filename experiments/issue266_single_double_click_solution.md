# Issue #266: Single and Double Click Detection for vstDev

## Problem Description

**Issue:** https://github.com/veb86/zcadvelecAI/issues/266

The requirement is to add the following functionality to the TLazVirtualStringTree component (vstDev):

1. **Single left mouse click** on a record containing a device → show message "один щелчок" (single click)
2. **Double left mouse click** on a record containing a device → show message "двойной щелчок" (double click)
3. **Parent nodes (containers)** should react to clicks as usual (expand/collapse), no messages needed

### The Challenge

As noted by the issue owner in the comments:
> "При двойном нажатии левой кнопкой мыши по записи содержащей устройство. Должно открытся сообщение 'двойной щелчок'. Этого не происходит, всегда перехватываетс первый щелчок"

Translation: "The problem is that on double-click, the first click is always intercepted, so the double-click message doesn't appear."

This is a classic problem with GUI event handling: **a double-click always triggers a single-click event first**. Without special handling, the single-click action executes before the double-click can be detected.

## Solution: Timer-Based Click Delay

The solution uses a **delayed execution pattern** with a timer:

1. When a single click occurs, **start a timer** (300ms) instead of immediately showing the message
2. If a double-click occurs **before the timer fires**, stop the timer and execute the double-click action
3. If the timer fires (no double-click occurred), execute the single-click action

### Implementation Details

#### 1. Added Private Fields (lines 59-62)

```pascal
// Для различения одинарного и двойного щелчка
FClickTimer: TTimer; // Таймер для задержки обработки одинарного щелчка
FPendingClickNode: PVirtualNode; // Нода, ожидающая обработки одинарного щелчка
FPendingClickColumn: TColumnIndex; // Колонка, ожидающая обработки одинарного щелчка
```

#### 2. Timer Initialization in Constructor (lines 118-124)

```pascal
// Инициализация таймера для различения одинарного и двойного щелчка
FClickTimer := TTimer.Create(Self);
FClickTimer.Enabled := False;
FClickTimer.Interval := 300; // 300 мс задержка для различения кликов
FClickTimer.OnTimer := @ClickTimerExecute;
FPendingClickNode := nil;
FPendingClickColumn := -1;
```

**Why 300ms?** This is a standard Windows double-click interval. It's long enough to detect double-clicks but short enough that users won't notice the delay in single-click actions.

#### 3. Modified vstDevClick Handler (lines 522-561)

```pascal
procedure TVElectrNav.vstDevClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PGridNodeData;
  HitInfo: THitInfo;
  P: TPoint;
begin
  P := vstDev.ScreenToClient(Mouse.CursorPos);
  vstDev.GetHitTestInfoAt(P.X, P.Y, True, HitInfo);

  if not Assigned(HitInfo.HitNode) then Exit;

  Node := HitInfo.HitNode;
  NodeData := vstDev.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  // Handle existing button columns (10 and 11)
  if HitInfo.HitColumn = 11 then
    ShowMessage('devname: ' + NodeData^.DevName)
  else if HitInfo.HitColumn = 10 then
    ShowMessage('Редактировать: ' + NodeData^.HDName)
  else
  begin
    // For device nodes (nodes without children), delay showing "один щелчок" message
    // to allow double-click detection
    // Parent nodes (containers) continue to work as usual (expand/collapse)
    if not vstDev.HasChildren[Node] then
    begin
      // Stop any pending click timer
      FClickTimer.Enabled := False;

      // Save click information for delayed processing
      FPendingClickNode := Node;
      FPendingClickColumn := HitInfo.HitColumn;

      // Start timer to execute single-click action after delay
      FClickTimer.Enabled := True;
    end;
  end;
end;
```

**Key points:**
- Button columns (10 and 11) still respond immediately to single clicks
- Only device nodes (leaf nodes without children) use delayed processing
- Parent nodes (containers) continue normal expand/collapse behavior

#### 4. Modified vstDevDblClick Handler (lines 563-586)

```pascal
procedure TVElectrNav.vstDevDblClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PGridNodeData;
  HitInfo: THitInfo;
  P: TPoint;
begin
  // Stop the single-click timer to prevent it from firing
  FClickTimer.Enabled := False;

  P := vstDev.ScreenToClient(Mouse.CursorPos);
  vstDev.GetHitTestInfoAt(P.X, P.Y, True, HitInfo);

  if not Assigned(HitInfo.HitNode) then Exit;

  Node := HitInfo.HitNode;
  NodeData := vstDev.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  // For device nodes (nodes without children), show "двойной щелчок" message
  // Parent nodes (containers) continue to work as usual
  if not vstDev.HasChildren[Node] then
    ShowMessage('двойной щелчок');
end;
```

**Crucial first step:** Stop the timer to prevent the single-click action from executing.

#### 5. Timer Event Handler (lines 640-657)

```pascal
// Обработчик таймера для выполнения отложенного одинарного щелчка
// Вызывается через 300мс после клика, если не произошел двойной щелчок
procedure TVElectrNav.ClickTimerExecute(Sender: TObject);
begin
  // Отключаем таймер
  FClickTimer.Enabled := False;

  // Проверяем, что нода для обработки еще установлена
  if Assigned(FPendingClickNode) then
  begin
    // Выполняем действие одинарного щелчка для устройства
    ShowMessage('один щелчок');

    // Очищаем состояние
    FPendingClickNode := nil;
    FPendingClickColumn := -1;
  end;
end;
```

This executes the delayed single-click action if no double-click occurred within the timer interval.

#### 6. Cleanup in Destructor (lines 721-739)

```pascal
destructor TVElectrNav.Destroy;
begin
  // Останавливаем и освобождаем таймер
  if Assigned(FClickTimer) then
  begin
    FClickTimer.Enabled := False;
    FClickTimer.Free;
  end;

  // Освобождаем popup menu
  if Assigned(FContainerPopupMenu) then
    FContainerPopupMenu.Free;

  // Освобождаем список устройств
  if Assigned(FDevicesList) then
    FDevicesList.Free;

  inherited Destroy;
end;
```

Proper cleanup prevents memory leaks and ensures the timer doesn't fire after the component is destroyed.

## How It Works: Sequence Diagram

### Single Click Scenario

```
User clicks device → vstDevClick → Start timer (300ms) → Timer fires → ShowMessage('один щелчок')
```

### Double Click Scenario

```
User clicks device → vstDevClick → Start timer (300ms)
User clicks again   → vstDevDblClick → Stop timer → ShowMessage('двойной щелчок')
                                       (timer never fires)
```

### Container Click Scenario

```
User clicks container → vstDevClick → VirtualStringTree's default behavior (expand/collapse)
                                     (no timer involved, HasChildren check prevents it)
```

## Testing Checklist

To verify the solution works correctly:

1. ✅ **Single click on device node** → Wait 300ms → Message "один щелчок" appears
2. ✅ **Double click on device node** → Message "двойной щелчок" appears immediately (after second click)
3. ✅ **Single click on container node** → Node expands/collapses normally, no message
4. ✅ **Double click on container node** → Node expands/collapses normally, no message
5. ✅ **Click on button columns (10 or 11)** → Immediate response, existing behavior unchanged

## Files Modified

| File | Description |
|------|-------------|
| `cad_source/zcad/velec/connectmanager/gui/velectrnav.pas` | Added timer-based click detection for vstDev |

## Related Issues

- Issue #266: https://github.com/veb86/zcadvelecAI/issues/266
- PR #303: https://github.com/veb86/zcadvelecAI/pull/303

## Technical Notes

### Why Not Use OnNodeDblClick?

`TLazVirtualStringTree` provides `OnNodeDblClick`, but it still has the same problem: `OnClick` fires first. The timer-based solution is the standard pattern for distinguishing single and double clicks in GUI applications.

### Alternative Approaches Considered

1. **Increase double-click speed requirement** - Not user-friendly
2. **Disable single-click handling** - Breaks requirements
3. **Use MouseDown/MouseUp events** - More complex, same problem
4. **Check GetDoubleClickTime API** - Could be used instead of hardcoded 300ms

### Platform Compatibility

This solution works on all platforms (Windows, Linux, macOS) because:
- TTimer is cross-platform in Lazarus/FPC
- The 300ms interval is conservative and works across different OS double-click settings

## Future Enhancements

If needed, the solution could be enhanced to:
- Make the timer interval configurable
- Use Windows GetDoubleClickTime() API for system-specific timing
- Add different actions for single vs. double-click (not just messages)
- Store the clicked NodeData for use in the timer handler
