
function MapWindowPoints(hWndFrom, hWndTo: HWND; var lpPoints; cPoints: UINT): Integer;
var
  i: Integer;
  XOffset, YOffset: SmallInt;
  FromPoint, ToPoint: TPoint;
begin
  FromPoint := Point(0, 0);
  ToPoint := Point(0, 0);
  if hWndFrom <> 0 then
    ClientToScreen(hWndFrom, FromPoint);
  if hWndTo <> 0 then
    ClientToScreen(hWndTo, ToPoint);
  XOffset := (FromPoint.X - ToPoint.X);
  YOffset := (FromPoint.Y - ToPoint.Y);
  for i := 0 to cPoints - 1 do
  begin
    PPoint(@lpPoints)[i].x := XOffset + PPoint(@lpPoints)[i].x;
    PPoint(@lpPoints)[i].y := YOffset + PPoint(@lpPoints)[i].y;
  end;
  Result := MakeLong(XOffset, YOffset);
end;

{$ifndef HAS_GETDOUBLECLICKTIME}
function GetDoubleClickTime: UINT;
begin
  //todo: see if gtk has a value. Use Windows default for now
  Result := 500;
end;
{$endif}

{$ifndef HAS_REDRAWWINDOW}
function RedrawWindow(hWnd:THandle; lprcUpdate:PRECT; hrgnUpdate:HRGN; flags:LongWord):BOOLEAN;
begin
  //todo: see if there's a better way of doing this
  Result := LCLIntf.InvalidateRect(hWnd, lprcUpdate, (RDW_ERASE and flags) > 0);
end;
{$endif}
