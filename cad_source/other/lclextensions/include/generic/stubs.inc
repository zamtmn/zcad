
function BeginDeferWindowPos(nNumWindows:longint):THandle;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function CopyImage(hImage:THANDLE; uType:LongWord; cxDesired, cyDesired: LongInt; fuFlags:LongWord):THandle;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function DeferWindowPos(hWinPosInfo, hWnd, hWndInsertAfter:THandle; x, y, cx, cy:longint; uFlags:LongWord):THandle;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function EndDeferWindowPos(hWinPosInfo:THandle):Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GdiFlush: Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GetACP:LongWord;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

{$ifndef HAS_GETBKCOLOR}
function GetBkColor(DC:HDC):COLORREF;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

{$ifndef HAS_GETCURRENTOBJECT}
function GetCurrentObject(hdc: HDC; uObjectType: UINT): HGDIOBJ;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

function GetDCEx(hWnd:THandle; hrgnClip:HRGN; flags:DWORD):HDC;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GetKeyboardLayout(dwLayout:DWORD):THandle;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GetKeyboardState(lpKeyState: System.PByte):BOOLEAN;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GetLocaleInfo(Locale, LCType:LongWord; lpLCData:PChar; cchData:longint):longint;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function GetRandomRgn(DC: HDC; Rgn: HRGN; iNum: Integer): Integer; stdcall;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

{$ifndef HAS_GETTEXTEXTENTEXPOINT}
function GetTextExtentExPoint(DC: HDC; Str: PChar;
  Count, MaxWidth: Integer; MaxCount, PartialWidths: PInteger;
  var Size: TSize): BOOL;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

{$ifndef HAS_GETTEXTALIGN}
function GetTextAlign(hDC:HDC): LongWord;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

{$ifndef HAS_GETWINDOWDC}
function GetWindowDC(hWnd:THandle):HDC;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

function ImageList_DragShowNolock(fShow: Boolean): Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

{$ifndef HAS_INVERTRECT}
function InvertRect(DC: HDC; const lprc: TRect): Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

function MultiByteToWideChar(CodePage, dwFlags:DWORD; lpMultiByteStr:PChar; cchMultiByte:longint; lpWideCharStr:PWideChar;cchWideChar:longint):longint;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

{$ifndef HAS_OFFSETRGN}
function OffsetRgn(hrgn:HRGN; nxOffset, nYOffset:longint):longint;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

function ScrollDC(DC:HDC; dx:longint; dy:longint; var lprcScroll:TRECT; var lprcClip:TRECT;hrgnUpdate:HRGN; lprcUpdate:PRECT):Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

{$ifndef HAS_SCROLLWINDOW}
function ScrollWindow(hWnd:THandle; XAmount, YAmount:longint;lpRect:PRECT; lpClipRect:PRECT):Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

{$ifndef HAS_SETBRUSHORGEX}
function SetBrushOrgEx(DC:HDC; nXOrg, nYOrg:longint; lppt:PPOINT):Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;
{$endif}

function SubtractRect(var lprcDst: TRect; const lprcSrc1, lprcSrc2: TRect): BOOLEAN;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function ToAscii(uVirtKey, uScanCode:LongWord; lpKeyState: System.PByte; lpChar: System.PWord; uFlags:LongWord):longint;
begin
  Result := 0;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end;

function UpdateWindow(Handle: HWND): Boolean;
begin
  Result := False;
  {$ifdef DEBUG_DELPHICOMPAT} Logger.SendCallStack('Dummy WinAPI Implementation'); {$endif}
end; 

