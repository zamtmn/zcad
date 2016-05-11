{ Version 050531. Copyright © Alexey A.Chernobaev, 2000-5 }

unit VWinUtil;

interface

{$I VCheck.inc}

uses
  Windows, Messages, SysUtils, ActiveX, ShellAPI,
  ExtSys, VFileSys, VComUtil, VOleStrm,
  {$IFNDEF V_WIDESTRING_PLUS}VectStr,{$ENDIF}
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF};

{ Kernel }

function LoadKernel32: THandle;

type
  TIsWow64Process = function (hProcess: THandle; out Wow64Process: BOOL): BOOL; stdcall;

function CheckGetCopyFileExW: Boolean;

var
  _CopyFileExW: function (lpExistingFileName, lpNewFileName: PWideChar;
    lpProgressRoutine: TFNProgressRoutine; lpData: Pointer; pbCancel: PBool;
    dwCopyFlags: DWORD): BOOL; stdcall = nil;

{ Windows User Interface }

function GetWorkArea: TRect;
function SetWindowTopMost(Wnd: HWND; OnTop, Activate: Boolean): Boolean;
function EscPressed: Boolean;
procedure KillMessage(Wnd: HWnd; Msg: Integer);

{ GDI }

function GetTextSize(Font: HFONT; const S: String): TSize;
function GetTextSizeW(Font: HFONT; const W: WideString): TSize;
function ShortenStringW(DC: HDC; const W: WideString; Limit: Integer;
  pWidth: PInteger{$IFDEF V_DEFAULTS} = nil{$ENDIF}): WideString;
function DrawTextCenteredW(DC: HDC; R: TRect; const PW: PWideChar; Count: Integer): Boolean;

{ Registry }

const
  HKCR = 'HKEY_CLASSES_ROOT\';
  HKCU = 'HKEY_CURRENT_USER\';
  HKLM = 'HKEY_LOCAL_MACHINE\';
  HKUS = 'HKEY_USERS\';

function RegCreate(Name: PChar; var Key: HKEY;
  AccessMask: REGSAM{$IFDEF V_DEFAULTS} = KEY_READ or KEY_WRITE{$ENDIF};
  pErrorCode: PDWORD{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
{ Name can start with 'HKEY_CLASSES_ROOT\' ('HKCR\'), 'HKEY_CURRENT_USER\'
  ('HKCU\'), 'HKEY_LOCAL_MACHINE\' ('HKLM\'), 'HKEY_USERS\' ('HKUS\') }
function RegCreateAndSetValue(KeyName, ValueName: PChar; Buf: Pointer; DataType,
  DataSize: DWORD; pErrorCode: PDWORD{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
function RegCreateAndSetString(KeyName, ValueName: PChar; const Value: String;
  pErrorCode: PDWORD{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
function RegOpen(Name: PChar; var Key: HKEY;
  AccessMask: REGSAM{$IFDEF V_DEFAULTS} = KEY_READ{$ENDIF};
  pErrorCode: PDWORD{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
function RegOpenRead(Name: PChar; var Key: HKEY;
  pErrorCode: PDWORD{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
function RegSetString(Key: HKEY; const Name: PChar; const Value: String): Boolean;
function RegQuery(Key: HKEY; const Name: PChar; Buf: Pointer;
  var Size: DWORD): Boolean;
function RegQueryW(Key: HKEY; const Name: PWideChar; Buf: Pointer;
  var Size: DWORD): Boolean;
function RegOpenAndQuery(KeyName, ValueName: PChar; Buf: Pointer;
  var Size: DWORD): Boolean;
function RegOpenAndQueryW(KeyName, ValueName: PWideChar; Buf: Pointer;
  var Size: DWORD): Boolean;
function RegOpenAndDelete(KeyName, ValueName: PChar): Boolean;
function RegOpenAndDeleteValues(KeyName: PChar; Values: array of PChar): Boolean;

function RegQueryString(const KeyName, ValueName: String;
  var Value: String): Boolean;
function RegQueryStringW(const KeyName, ValueName: WideString;
  var Value: WideString): Boolean;

{ System }

function ExpandEnvVars(const Value: String;
  pSuccess: PBoolean{$IFDEF V_DEFAULTS} = nil{$ENDIF}): String;
function ExpandEnvVarsW(const Value: WideString;
  pSuccess: PBoolean{$IFDEF V_DEFAULTS} = nil{$ENDIF}): WideString;

{ Clipboard }

procedure CopyDataToClipboard(uFormat: UINT; Data: Pointer; Size: Integer);
procedure CopyStringToClipboard(const S: String);
procedure CopyWideStringToClipboard(const W: WideString);
{ the clipboard must be opened with OpenClipboard }

function SetStringOnClipboard(hWnd: THandle; const S: String): Boolean;
{ empties the clipboard and copies data from S to it in CF_TEXT formats; hWnd is
  a handle being passed to OpenClipboard }
function SetWideStringOnClipboard(hWnd: THandle; const W: WideString): Boolean;
{ empties the clipboard and copies data from W to it in both CF_UNICODETEXT and
  CF_TEXT formats; hWnd is a handle being passed to OpenClipboard }

{ OLE }

function OpenStorageInFileForRead(const FileName: WideString; out stg: IStorage): Boolean;
function OpenStorageInStreamForRead(Stream: TVStream; out stg: IStorage): Boolean;
function CopyIStreamToVStream(stm: IStream; Stream: TVStream; MaxSize: ILong): ILong;
function OpenIStreamAndCopyToVStream(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer; Stream: TVStream): Boolean;
function GetStorageStreamSize(stg: IStorage; const StreamName: WideString): Largeint;
{ returns -1 if failed to open stream }
function OpenIStreamAndGetItAsString(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer): String;
function OpenIStreamAndGetItAsWideString(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer): WideString;
{ MaxSize: maximum size in bytes to read; returns empty string if failed to open
  stream }

{ Shell }

function ShellExec(const Operation: String; const FileName, Params: WideString): HINST;
function GetFileSmallIcon(const szNameOrExt: PChar): Integer;
function GetFileLargeIcon(const szNameOrExt: PChar): Integer;
function GetFileSmallIconW(const szNameOrExt: PWideChar): Integer;
function GetFileLargeIconW(const szNameOrExt: PWideChar): Integer;
function GetSystemSmallIcons: Integer;
function GetSystemLargeIcons: Integer;
function GetUnknownFileSmallIcon: Integer;
function GetUnknownFileLargeIcon: Integer;
function GetSpecialFolderPath(nFolder: Integer; Create: Boolean): String;
function GetSpecialFolderPathW(nFolder: Integer; Create: Boolean): WideString;
function GetPersonalPath: String;
function GetPersonalPathW: WideString;

function LoadShell32: THandle;

function CheckGetSHGetFileInfoW: Boolean;
function CheckGetShellExecuteExW: Boolean;
function CheckGetSHFileOperationW: Boolean;

var
  _SHGetFileInfoW: function (pszPath: PWideChar; dwFileAttributes: DWORD;
    var psfi: TSHFileInfoW; cbFileInfo, uFlags: UINT): DWORD; stdcall = nil;

  _ShellExecuteExW: function (lpExecInfo: PShellExecuteInfoW): BOOL; stdcall = nil;

  _SHFileOperationW: function (const lpFileOp: TSHFileOpStructW): Integer; stdcall = nil;

function ShellExecExW(const FileName: WideString;
  const Verb: String{$IFDEF V_DEFAULTS} = ''{$ENDIF};
  Handle: THandle{$IFDEF V_DEFAULTS} = 0{$ENDIF};
  Mask: ULONG{$IFDEF V_DEFAULTS} = 0{$ENDIF};
  ShowFlags: Integer{$IFDEF V_DEFAULTS} = SW_SHOWNORMAL{$ENDIF}): Boolean;

{ Themes Support }

const
  WM_THEMECHANGED = $031A;

var
  GetCurrentThemeName: function (pszThemeFileName: PWideChar;
    dwMaxNameChars: Integer; pszColorBuff: PWideChar; cchMaxColorChars: Integer;
    pszSizeBuff: PWideChar; cchMaxSizeChars: Integer): HRESULT; stdcall = nil;

function XPThemesActive: Boolean; // loads UXTHEME.DLL and gets GetCurrentThemeName

implementation

{$IFDEF INT64_EQ_COMP}{$IFDEF USE_STREAM64}
  {$DEFINE FLOAT_ILONG}
{$ENDIF}{$ENDIF}

{$IFNDEF V_D4}{$IFNDEF FLOAT_ILONG}
  {$DEFINE ROUND_LARGEINT}
{$ENDIF}{$ENDIF}

{$IFDEF V_D6}{$IFDEF V_WIN}{$IFDEF NOWARN}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}{$ENDIF}{$ENDIF}

{ Kernel}

var
  hKernel: THandle = 0;
  TriedToLoadKernel32: Boolean = False;

function LoadKernel32: THandle;
begin
  if not TriedToLoadKernel32 then begin
    TriedToLoadKernel32:=True;
    hKernel:=LoadLibrary('kernel32.dll');
  end;
  Result:=hKernel;
end;

function CheckGetCopyFileExW: Boolean;
begin
  Result:=Assigned(_CopyFileExW);
  if not Result and (Win32Platform = VER_PLATFORM_WIN32_NT) then begin
    LoadKernel32;
    if hKernel <> 0 then begin
      _CopyFileExW:=GetProcAddress(hKernel, 'CopyFileExW');
      Result:=Assigned(_CopyFileExW);
    end;
  end;
end;

{ Windows User Interface }

function GetWorkArea: TRect;
begin
  if not SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0) then begin
    Result.Left:=0;
    Result.Top:=0;
    Result.Right:=GetSystemMetrics(SM_CXSCREEN);
    Result.Bottom:=GetSystemMetrics(SM_CYSCREEN);
  end;
end;

function SetWindowTopMost(Wnd: HWND; OnTop, Activate: Boolean): Boolean;
var
  uFlags: DWORD;
  Order: HWND;
begin
  Order:=HWND_NOTOPMOST;
  if OnTop then Order:=HWND_TOPMOST;
  uFlags:=SWP_NOMOVE or SWP_NOSIZE;
  if not Activate then uFlags:=uFlags or SWP_NOACTIVATE;
  Result:=SetWindowPos(Wnd, Order, 0, 0, 0, 0, uFlags);
end;

function EscPressed: Boolean;
var
  Msg: TMsg;
begin
  Result:=PeekMessage(Msg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE) and
    (Msg.wParam = 27);
end;

procedure KillMessage(Wnd: HWnd; Msg: Integer);
// Delete the requested message from the queue, but throw back
// any WM_QUIT msgs that PeekMessage may also return
// Copied from DbGrids.pas
var
  M: TMsg;
begin
  M.Message:=0;
  if PeekMessage(M, Wnd, Msg, Msg, PM_REMOVE) and (M.Message = WM_QUIT) then
    PostQuitMessage(M.wparam);
end;

{$IFNDEF V_D4}
function GetTextExtentExPointW(DC: HDC; Str: PWideChar; Count, MaxWidth: Integer;
  MaxChars, Widths: PInteger; var Size: TSize): BOOL; stdcall; external gdi32;
{$ENDIF}

function GetTextSize(Font: HFONT; const S: String): TSize;
var
  DC: HDC;
  OldFont: HFONT;
begin
  DC:=GetDC(0);
  try
    Result.cx:=0;
    Result.cy:=0;
    OldFont:=SelectObject(DC, Font);
    GetTextExtentPoint32(DC, PChar(S), Length(S), Result);
    SelectObject(DC, OldFont);
  finally
    ReleaseDC(0, DC);
  end;
end;

function GetTextSizeW(Font: HFONT; const W: WideString): TSize;
var
  DC: HDC;
  OldFont: HFONT;
begin
  DC:=GetDC(0);
  try
    Result.cx:=0;
    Result.cy:=0;
    OldFont:=SelectObject(DC, Font);
    GetTextExtentPoint32W(DC, PWideChar(W), Length(W), Result);
    SelectObject(DC, OldFont);
  finally
    ReleaseDC(0, DC);
  end;
end;

function ShortenStringW(DC: HDC; const W: WideString; Limit: Integer;
  pWidth: PInteger): WideString;
label
  lExit;
const
  Ellipsis = #$2026;
var
  L, Width, NewLen: Integer;
  Sz, EllipsisSz: TSize;
begin
  L:=Length(W);
  Width:=0;
  Result:=W;
  if L = 0 then
    goto lExit;
  Win32Check(GetTextExtentPoint32W(DC, Pointer(W), L, Sz));
  if Sz.cx <= Limit then begin
    Width:=Sz.cx;
    goto lExit;
  end;
  Win32Check(GetTextExtentPoint32W(DC, Ellipsis, 1, EllipsisSz));
  Dec(Limit, EllipsisSz.cx);
  if Limit <= 0 then begin
    Result:='';
    goto lExit;
  end;
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Win32Check(GetTextExtentExPointW(DC, Pointer(W), L, Limit, @NewLen, nil, Sz));
    if pWidth <> nil then begin
      Win32Check(GetTextExtentPoint32W(DC, Pointer(W), NewLen, Sz));
      Width:=Sz.cx;
    end;
  end
  else begin
    NewLen:=L;
    repeat
      Dec(NewLen);
      if NewLen = 0 then
        Break;
      Win32Check(GetTextExtentPoint32W(DC, Pointer(W), NewLen, Sz));
      if Sz.cx <= Limit then begin
        Width:=Sz.cx;
        Break;
      end;
    until False;
  end;
  SetLength(Result, NewLen);
  {$IFDEF V_WIDESTRING_PLUS}
  Result:=Result + Ellipsis;
  {$ELSE}
  WideAppend(Result, Ellipsis);
  {$ENDIF}
  Inc(Width, EllipsisSz.cx);
lExit:
  if pWidth <> nil then
    pWidth^:=Width;
end;

function DrawTextCenteredW(DC: HDC; R: TRect; const PW: PWideChar; Count: Integer): Boolean;
var
  Extent: TSize;
begin
  if GetTextExtentPoint32W(DC, PW, Count, Extent) then begin
    TextOutW(DC,
      (R.Left + R.Right - Extent.cx) div 2,
      (R.Top + R.Bottom - Extent.cy) div 2, PW, Count);
    Result:=True;
  end
  else
    Result:=False;
end;

{ Registry }

function GetOpenKey(var Name: PChar): HKEY;

  function CheckHiveName(const HiveName: String; RetVal: DWORD): Boolean;
  begin
    if StrLComp(Name, @HiveName[1], Length(HiveName)) = 0 then begin
      Inc(Name, Length(HiveName));
      GetOpenKey:=RetVal;
      Result:=True;
    end
    else
      Result:=False;
  end;

begin
  if not (
    CheckHiveName(HKCU, HKEY_CURRENT_USER) or
    CheckHiveName('HKCU\', HKEY_CURRENT_USER) or

    CheckHiveName(HKCR, HKEY_CLASSES_ROOT) or
    CheckHiveName('HKCR\', HKEY_CLASSES_ROOT) or

    CheckHiveName(HKLM, HKEY_LOCAL_MACHINE) or
    CheckHiveName('HKLM\', HKEY_LOCAL_MACHINE) or

    CheckHiveName(HKUS, HKEY_USERS) or
    CheckHiveName('HKUS\', HKEY_USERS))
  then
    Result:=HKEY_CURRENT_USER;
end;

function GetOpenKeyW(var Name: PWideChar): HKEY;

  function CheckHiveName(const HiveName: WideString; RetVal: DWORD): Boolean;
  begin
    if MemEqual(Name^, PWideChar(@HiveName[1])^, 2 * Length(HiveName)) then begin
      Inc(Name, Length(HiveName));
      GetOpenKeyW:=RetVal;
      Result:=True;
    end
    else
      Result:=False;
  end;

begin
  if not (
    CheckHiveName(HKCU, HKEY_CURRENT_USER) or
    CheckHiveName('HKCU\', HKEY_CURRENT_USER) or

    CheckHiveName(HKCR, HKEY_CLASSES_ROOT) or
    CheckHiveName('HKCR\', HKEY_CLASSES_ROOT) or

    CheckHiveName(HKLM, HKEY_LOCAL_MACHINE) or
    CheckHiveName('HKLM\', HKEY_LOCAL_MACHINE) or

    CheckHiveName(HKUS, HKEY_USERS) or
    CheckHiveName('HKUS\', HKEY_USERS))
  then
    Result:=HKEY_CURRENT_USER;
end;

function RegCreate(Name: PChar; var Key: HKEY; AccessMask: REGSAM;
  pErrorCode: PDWORD): Boolean;
var
  Code, Dummy: DWORD;
begin
  Key:=GetOpenKey(Name);
  Code:=RegCreateKeyEx(Key, Name, 0, nil, REG_OPTION_NON_VOLATILE, AccessMask,
    nil, Key, @Dummy);
  if pErrorCode <> nil then
    pErrorCode^:=Code;
  Result:=Code = ERROR_SUCCESS;
end;

function RegCreateAndSetValue(KeyName, ValueName: PChar; Buf: Pointer; DataType,
  DataSize: DWORD; pErrorCode: PDWORD): Boolean;
var
  Key: HKEY;
  Code: DWORD;
begin
  Key:=GetOpenKey(KeyName);
  Result:=RegCreateKeyEx(Key, KeyName, 0, nil, REG_OPTION_NON_VOLATILE,
    KEY_WRITE, nil, Key, @Code) = ERROR_SUCCESS;
  if Result then
  try
    Code:=RegSetValueEx(Key, ValueName, 0, DataType, Buf, DataSize);
    if pErrorCode <> nil then
      pErrorCode^:=Code;
    Result:=Code = ERROR_SUCCESS;
  finally
    RegCloseKey(Key);
  end;
end;

function RegCreateAndSetString(KeyName, ValueName: PChar; const Value: String;
  pErrorCode: PDWORD): Boolean;
begin
  Result:=RegCreateAndSetValue(KeyName, ValueName, PChar(Value), REG_SZ,
    Length(Value) + 1, pErrorCode);
end;

function RegOpen(Name: PChar; var Key: HKEY; AccessMask: REGSAM;
  pErrorCode: PDWORD): Boolean;
var
  Code: DWORD;
begin
  Key:=GetOpenKey(Name);
  Code:=RegOpenKeyEx(Key, Name, 0, AccessMask, Key);
  if pErrorCode <> nil then
    pErrorCode^:=Code;
  Result:=Code = ERROR_SUCCESS;
end;

function RegOpenRead(Name: PChar; var Key: HKEY; pErrorCode: PDWORD): Boolean;
begin
  Result:=RegOpen(Name, Key, KEY_READ, pErrorCode);
end;

function RegSetString(Key: HKEY; const Name: PChar; const Value: String): Boolean;
begin
  Result:=RegSetValueEx(Key, Name, 0, REG_SZ, PChar(Value), Length(Value) + 1) =
    ERROR_SUCCESS;
end;

function RegQuery(Key: HKEY; const Name: PChar; Buf: Pointer;
  var Size: DWORD): Boolean;
var
  DataType: DWORD;
begin
  Result:=RegQueryValueEx(Key, Name, nil, @DataType, Buf, @Size) = ERROR_SUCCESS;
end;

function RegQueryW(Key: HKEY; const Name: PWideChar; Buf: Pointer;
  var Size: DWORD): Boolean;
var
  DataType: DWORD;
begin
  Result:=RegQueryValueExW(Key, Name, nil, @DataType, Buf, @Size) = ERROR_SUCCESS;
end;

function RegOpenAndQuery(KeyName, ValueName: PChar; Buf: Pointer;
  var Size: DWORD): Boolean;
var
  Key: HKEY;
  DataType: DWORD;
begin
  Key:=GetOpenKey(KeyName);
  Result:=RegOpenKeyEx(Key, KeyName, 0, KEY_READ, Key) = ERROR_SUCCESS;
  if Result then
  try
    Result:=RegQueryValueEx(Key, ValueName, nil, @DataType, Buf, @Size) =
      ERROR_SUCCESS;
  finally
    RegCloseKey(Key);
  end;
end;

function RegOpenAndQueryW(KeyName, ValueName: PWideChar; Buf: Pointer;
  var Size: DWORD): Boolean;
var
  Key: HKEY;
  DataType: DWORD;
begin
  Key:=GetOpenKeyW(KeyName);
  Result:=RegOpenKeyExW(Key, KeyName, 0, KEY_READ, Key) = ERROR_SUCCESS;
  if Result then
  try
    Result:=RegQueryValueExW(Key, ValueName, nil, @DataType, Buf, @Size) =
      ERROR_SUCCESS;
  finally
    RegCloseKey(Key);
  end;
end;

function RegOpenAndDelete(KeyName, ValueName: PChar): Boolean;
var
  Key: HKEY;
begin
  Result:=False;
  Key:=GetOpenKey(KeyName);
  if RegOpenKeyEx(Key, KeyName, 0, KEY_SET_VALUE, Key) = ERROR_SUCCESS then begin
    Result:=RegDeleteValue(Key, ValueName) = ERROR_SUCCESS;
    RegCloseKey(Key);
  end;
end;

function RegOpenAndDeleteValues(KeyName: PChar; Values: array of PChar): Boolean;
var
  I: Integer;
  Key: HKEY;
begin
  Result:=False;
  Key:=GetOpenKey(KeyName);
  if RegOpenKeyEx(Key, KeyName, 0, KEY_SET_VALUE, Key) = ERROR_SUCCESS then begin
    Result:=True;
    for I:=0 to High(Values) do
      if RegDeleteValue(Key, Values[I]) <> ERROR_SUCCESS then
        Result:=False;
    RegCloseKey(Key);
  end;
end;

function RegQueryString(const KeyName, ValueName: String;
  var Value: String): Boolean;
var
  Key: HKEY;
  Sz, DataType: DWORD;
  PKeyName: PChar;
begin
  PKeyName:=PChar(KeyName);
  Key:=GetOpenKey(PKeyName);
  Result:=RegOpenKeyEx(Key, PKeyName, 0, KEY_READ, Key) = ERROR_SUCCESS;
  if Result then
  try
    Result:=RegQueryValueEx(Key, PChar(ValueName), nil, @DataType, nil, @Sz) =
      ERROR_SUCCESS;
    if not Result then
      Exit;
    if ((DataType <> REG_SZ) and (DataType <> REG_EXPAND_SZ)) or (Sz = 0) then begin
      Result:=False;
      Exit;
    end;
    SetLength(Value, Sz);
    Result:=RegQueryValueEx(Key, PChar(ValueName), nil, @DataType,
      Pointer(Value), @Sz) = ERROR_SUCCESS;
    if not Result or (Sz = 0) then
      Exit;
    SetLength(Value, Sz - 1);
    if DataType = REG_EXPAND_SZ then
      Value:=ExpandEnvVars(Value);
  finally
    RegCloseKey(Key);
  end;
end;

function RegQueryStringW(const KeyName, ValueName: WideString;
  var Value: WideString): Boolean;
var
  Key: HKEY;
  Sz, DataType: DWORD;
  PKeyName: PWideChar;
  S: String;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    PKeyName:=PWideChar(KeyName);
    Key:=GetOpenKeyW(PKeyName);
    Result:=RegOpenKeyExW(Key, PKeyName, 0, KEY_READ, Key) = ERROR_SUCCESS;
    if Result then
    try
      Result:=RegQueryValueExW(Key, PWideChar(ValueName), nil, @DataType, nil,
        @Sz) = ERROR_SUCCESS;
      if not Result then
        Exit;
      if ((DataType <> REG_SZ) and (DataType <> REG_EXPAND_SZ)) or (Sz = 0) or
        Odd(Sz) then
      begin
        Result:=False;
        Exit;
      end;
      SetLength(Value, Sz div 2);
      Result:=RegQueryValueExW(Key, PWideChar(ValueName), nil, @DataType,
        Pointer(Value), @Sz) = ERROR_SUCCESS;
      if not Result or (Sz < 2) then
        Exit;
      SetLength(Value, Sz div 2 - 1);
      if DataType = REG_EXPAND_SZ then
        Value:=ExpandEnvVarsW(Value);
    finally
      RegCloseKey(Key);
    end;
  end
  else begin
    Result:=RegQueryString(KeyName, ValueName, S);
    Value:=S;
  end;
end;

{ System }

function ExpandEnvVars(const Value: String; pSuccess: PBoolean): String;
var
  Sz, Ret: DWORD;
begin
  Sz:=IntMax(Length(Value) * 4, MAX_PATH);
  SetLength(Result, Sz);
  Ret:=ExpandEnvironmentStrings(PChar(Value), Pointer(Result), Sz);
  if (Ret > 0) and (Ret <= Sz) then begin
    SetLength(Result, Ret - 1);
    if pSuccess <> nil then
      pSuccess^:=True;
  end
  else begin
    Result:='';
    if pSuccess <> nil then
      pSuccess^:=False;
  end;
end;

function ExpandEnvVarsW(const Value: WideString; pSuccess: PBoolean): WideString;
var
  Sz, Ret: DWORD;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Sz:=IntMax(Length(Value) * 4, MAX_PATH);
    SetLength(Result, Sz);
    Ret:=ExpandEnvironmentStringsW(PWideChar(Value), Pointer(Result), Sz);
    if (Ret > 0) and (Ret <= Sz) then begin
      SetLength(Result, Ret - 1);
      if pSuccess <> nil then
        pSuccess^:=True;
    end
    else begin
      Result:='';
      if pSuccess <> nil then
        pSuccess^:=False;
    end;
  end
  else
    Result:=ExpandEnvVars(Value);
end;

{ Clipboard }

procedure CopyDataToClipboard(uFormat: UINT; Data: Pointer; Size: Integer);
var
  hMem: HGLOBAL;
  P: Pointer;
begin
  if Data <> nil then begin
    hMem:=GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Size);
    Win32Check(hMem <> 0);
    try
      P:=GlobalLock(hMem);
      Win32Check(P <> nil);
      Move(Data^, P^, Size);
      GlobalUnlock(hMem);
      Win32Check(SetClipboardData(uFormat, hMem) <> 0);
    except
      GlobalFree(hMem);
      raise;
    end;
  end;
end;

procedure CopyStringToClipboard(const S: String);
begin
  CopyDataToClipboard(CF_TEXT, Pointer(S), Length(S) + 1);
end;

procedure CopyWideStringToClipboard(const W: WideString);
begin
  CopyDataToClipboard(CF_UNICODETEXT, Pointer(W), (Length(W) + 1) * 2);
end;

function SetStringOnClipboard(hWnd: THandle; const S: String): Boolean;
var
  L: Integer;
begin
  Result:=False;
  if OpenClipboard(hWnd) then
  try
    Win32Check(EmptyClipboard);
    L:=Length(S) + 1;
    CopyDataToClipboard(CF_TEXT, PChar(S), L);
    Result:=True;
  finally
    CloseClipboard;
  end;
end;

function SetWideStringOnClipboard(hWnd: THandle; const W: WideString): Boolean;
var
  L: Integer;
begin
  Result:=False;
  if OpenClipboard(hWnd) then
  try
    Win32Check(EmptyClipboard);
    L:=Length(W) + 1;
    CopyDataToClipboard(CF_UNICODETEXT, PWideChar(W), L * 2);
    CopyDataToClipboard(CF_TEXT, PChar(String(W)), L);
    Result:=True;
  finally
    CloseClipboard;
  end;
end;

{ OLE }

function OpenStorageInFileForRead(const FileName: WideString; out stg: IStorage): Boolean;
begin
  Result:=StgOpenStorage(PWideChar(FileName), nil, STGM_DIRECT or STGM_READ or
    STGM_SHARE_DENY_WRITE, nil, 0, stg) = S_OK;
end;

function OpenStorageInStreamForRead(Stream: TVStream; out stg: IStorage): Boolean;
begin
  Result:=StgOpenStorageOnILockBytes(TILockBytesAdapter.Create(Stream), nil,
    STGM_DIRECT or STGM_READ or STGM_SHARE_EXCLUSIVE, nil, 0, stg) = S_OK;
end;

type
  PLargeint = ^Largeint;

  IStreamCorrected = interface(IUnknown)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
      stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
      stdcall;
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; cbRead: PLargeint;
      cbWritten: PLargeint): HResult; stdcall;
  end;

function CopyIStreamToVStream(stm: IStream; Stream: TVStream; MaxSize: ILong): ILong;
var
  Written: Largeint;
  Adapter: TVStreamAdapter;
begin
  Adapter:=TVStreamAdapter.Create(Stream);
  try
    ComCheck(IStreamCorrected(stm).CopyTo(Adapter, MaxSize, nil, @Written));
  finally
    Adapter.Free;
  end;
  Result:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(Written);
end;

function OpenIStreamAndCopyToVStream(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer; Stream: TVStream): Boolean;
var
  stm: IStream;
  statstg: TStatStg;
begin
  Result:=False;
  if stg.OpenStream(PWideChar(StreamName), nil, STGM_DIRECT or STGM_READ or
    STGM_SHARE_EXCLUSIVE, 0, stm) = S_OK then
  begin
    ComCheck(stm.Stat(statstg, STATFLAG_NONAME));
    if MaxSize > statstg.cbSize then
      MaxSize:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(statstg.cbSize);
    CopyIStreamToVStream(stm, Stream, MaxSize);
    Result:=True;
  end;
end;

function GetStorageStreamSize(stg: IStorage; const StreamName: WideString): Largeint;
var
  stm: IStream;
  statstg: TStatStg;
begin
  Result:=-1;
  if stg.OpenStream(PWideChar(StreamName), nil, STGM_DIRECT or STGM_READ or
    STGM_SHARE_EXCLUSIVE, 0, stm) = S_OK then
  begin
    ComCheck(stm.Stat(statstg, STATFLAG_NONAME));
    Result:=statstg.cbSize;
  end;
end;

function OpenIStreamAndGetItAsString(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer): String;
var
  stm: IStream;
  statstg: TStatStg;
begin
  {$IFNDEF V_AUTOINITSTRINGS}
  Result:='';
  {$ENDIF}
  if (MaxSize > 0) and
    (stg.OpenStream(PWideChar(StreamName), nil, STGM_DIRECT or STGM_READ or
      STGM_SHARE_EXCLUSIVE, 0, stm) = S_OK) then
  begin
    ComCheck(stm.Stat(statstg, STATFLAG_NONAME));
    if MaxSize > statstg.cbSize then
      MaxSize:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(statstg.cbSize);
    SetLength(Result, MaxSize);
    ComCheck(stm.Read(Pointer(Result), MaxSize, @MaxSize));
    SetLength(Result, MaxSize);
  end;
end;

function OpenIStreamAndGetItAsWideString(stg: IStorage; const StreamName: WideString;
  MaxSize: Integer): WideString;
var
  stm: IStream;
  statstg: TStatStg;
begin
  {$IFNDEF V_AUTOINITSTRINGS}
  Result:='';
  {$ENDIF}
  if (MaxSize > 0) and
    (stg.OpenStream(PWideChar(StreamName), nil, STGM_DIRECT or STGM_READ or
      STGM_SHARE_EXCLUSIVE, 0, stm) = S_OK) then
  begin
    ComCheck(stm.Stat(statstg, STATFLAG_NONAME));
    if MaxSize > statstg.cbSize then
      MaxSize:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(statstg.cbSize);
    MaxSize:=MaxSize div 2;
    SetLength(Result, MaxSize);
    ComCheck(stm.Read(Pointer(Result), MaxSize * 2, @MaxSize));
    SetLength(Result, MaxSize div 2);
  end;
end;

{ Shell }

function ShellExec(const Operation: String; const FileName, Params: WideString): HINST;
var
  pOp: Pointer;
begin
  pOp:=nil;
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    if Operation <> '' then pOp:=Pointer(WideString(Operation));
    Result:=ShellExecuteW(0, pOp, PWideChar(FileName), PWideChar(Params), nil,
      SW_SHOW);
  end
  else begin
    if Operation <> '' then pOp:=Pointer(Operation);
    Result:=ShellExecute(0, pOp, PChar(String(FileName)), PChar(String(Params)),
      nil, SW_SHOW);
  end;
end;

function GetFileSmallIcon(const szNameOrExt: PChar): Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  Result:=-1;
  if Succeeded(SHGetFileInfo(szNameOrExt, 0, SHFileInfo, SizeOf(SHFileInfo),
    SHGFI_USEFILEATTRIBUTES or SHGFI_ICON or SHGFI_SMALLICON)) then
  begin // SHGFI_SYSICONINDEX doesn't work under Win9x!
    DestroyIcon(SHFileInfo.hIcon);
    Result:=SHFileInfo.iIcon;
  end;
end;

function GetFileLargeIcon(const szNameOrExt: PChar): Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  Result:=-1;
  if Succeeded(SHGetFileInfo(szNameOrExt, 0, SHFileInfo, SizeOf(SHFileInfo),
    SHGFI_USEFILEATTRIBUTES or SHGFI_ICON or SHGFI_LARGEICON)) then
  begin // SHGFI_SYSICONINDEX doesn't work under Win9x!
    DestroyIcon(SHFileInfo.hIcon);
    Result:=SHFileInfo.iIcon;
  end;
end;

function GetFileSmallIconW(const szNameOrExt: PWideChar): Integer;
var
  SHFileInfoW: TSHFileInfoW;
begin
  if CheckGetSHGetFileInfoW then
    if Succeeded(_SHGetFileInfoW(szNameOrExt, 0, SHFileInfoW, SizeOf(SHFileInfoW),
      SHGFI_USEFILEATTRIBUTES or SHGFI_SYSICONINDEX or SHGFI_SMALLICON))
    then
      Result:=SHFileInfoW.iIcon
    else
      Result:=-1
  else
    Result:=GetFileSmallIcon(PChar(String(WideString(szNameOrExt))));
end;

function GetFileLargeIconW(const szNameOrExt: PWideChar): Integer;
var
  SHFileInfoW: TSHFileInfoW;
begin
  if CheckGetSHGetFileInfoW then
    if Succeeded(_SHGetFileInfoW(szNameOrExt, 0, SHFileInfoW, SizeOf(SHFileInfoW),
      SHGFI_USEFILEATTRIBUTES or SHGFI_SYSICONINDEX or SHGFI_LARGEICON))
    then
      Result:=SHFileInfoW.iIcon
    else
      Result:=-1
  else
    Result:=GetFileLargeIcon(PChar(String(WideString(szNameOrExt))));
end;

function GetWinDrive: String;
var
  Buf: array [0..MAX_PATH] of AnsiChar;
begin
  Buf[0]:=#0;
  GetWindowsDirectory(Buf, MAX_PATH);
  Result:=ExtractFileDrive(LString(@Buf, SizeOf(Buf)));
  if Result = '' then Result:='C:';
  Result:=Result + '\';
end;

function GetSystemSmallIcons: Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  Result:=SHGetFileInfo(Pointer(GetWinDrive), 0, SHFileInfo, SizeOf(SHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
end;

function GetSystemLargeIcons: Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  Result:=SHGetFileInfo(Pointer(GetWinDrive), 0, SHFileInfo, SizeOf(SHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_LARGEICON);
end;

var
  iUnknownFileSmall: Integer = -1;
  iUnknownFileLarge: Integer = -1;

function GetUnknownFileSmallIcon: Integer;
begin
  Result:=iUnknownFileSmall;
  if Result < 0 then begin
    Result:=GetFileSmallIcon(':');
    iUnknownFileSmall:=Result;
  end;
end;

function GetUnknownFileLargeIcon: Integer;
begin
  Result:=iUnknownFileLarge;
  if Result < 0 then begin
    Result:=GetFileLargeIcon(':');
    iUnknownFileLarge:=Result;
  end;
end;

var
  SHGetSpecialFolderPathA: function (hwndOwner: HWND; lpszPath: PAnsiChar;
    nFolder: Integer; fCreate: BOOL): BOOL; stdcall = nil;
  SHGetSpecialFolderPathW: function (hwndOwner: HWND; lpszPath: PWideChar;
    nFolder: Integer; fCreate: BOOL): BOOL; stdcall = nil;

function GetSpecialFolderPath(nFolder: Integer; Create: Boolean): String;
var
  hDll: THandle;
  Buf: array [0..MAX_PATH] of AnsiChar;
begin
  {$IFNDEF V_AUTOINITSTRINGS}
  Result:='';
  {$ENDIF}
  if not Assigned(SHGetSpecialFolderPathA) then begin
    hDll:=LoadShell32;
    if hDll <> 0 then
      SHGetSpecialFolderPathA:=GetProcAddress(hDll, 'SHGetSpecialFolderPathA');
  end;
  if Assigned(SHGetSpecialFolderPathA) and
    SHGetSpecialFolderPathA(0, Buf, nFolder, Create)
  then
    Result:=IncludeTrailingPathDelimiter(LString(@Buf, SizeOf(Buf)));
end;

function GetSpecialFolderPathW(nFolder: Integer; Create: Boolean): WideString;
var
  hDll: THandle;
  Buf: array [0..MAX_PATH] of WideChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    {$IFNDEF V_AUTOINITSTRINGS}
    Result:='';
    {$ENDIF}
    if not Assigned(SHGetSpecialFolderPathW) then begin
      hDll:=LoadShell32;
      if hDll <> 0 then
        SHGetSpecialFolderPathW:=GetProcAddress(hDll, 'SHGetSpecialFolderPathW');
    end;
    if Assigned(SHGetSpecialFolderPathW) then begin
      if SHGetSpecialFolderPathW(0, Buf, nFolder, Create) then
        Result:=IncludePathDelimiterW(LWideString(@Buf, High(Buf) + 1));
      Exit;
    end;
  end;
  Result:=GetSpecialFolderPath(nFolder, Create);
end;

function GetPersonalPath: String;
begin
  Result:=GetSpecialFolderPath(5{CSIDL_PERSONAL}, False);
end;

function GetPersonalPathW: WideString;
begin
  Result:=GetSpecialFolderPathW(5{CSIDL_PERSONAL}, False);
end;

var
  hShell: THandle = 0;
  TriedToLoadShell32: Boolean = False;

function LoadShell32: THandle;
begin
  if not TriedToLoadShell32 then begin
    TriedToLoadShell32:=True;
    hShell:=LoadLibrary('shell32.dll');
  end;
  Result:=hShell;
end;

function CheckGetSHGetFileInfoW: Boolean;
begin
  Result:=Assigned(_SHGetFileInfoW);
  if not Result and (Win32Platform = VER_PLATFORM_WIN32_NT) then begin
    LoadShell32;
    if hShell <> 0 then begin
      _SHGetFileInfoW:=GetProcAddress(hShell, 'SHGetFileInfoW');
      Result:=Assigned(_SHGetFileInfoW);
    end;
  end;
end;

function CheckGetShellExecuteExW: Boolean;
begin
  Result:=Assigned(_ShellExecuteExW);
  if not Result and (Win32Platform = VER_PLATFORM_WIN32_NT) then begin
    LoadShell32;
    if hShell <> 0 then begin
      _ShellExecuteExW:=GetProcAddress(hShell, 'ShellExecuteExW');
      Result:=Assigned(_ShellExecuteExW);
    end;
  end;
end;

function CheckGetSHFileOperationW: Boolean;
begin
  Result:=Assigned(_SHFileOperationW);
  if not Result and (Win32Platform = VER_PLATFORM_WIN32_NT) then begin
    LoadShell32;
    if hShell <> 0 then begin
      _SHFileOperationW:=GetProcAddress(hShell, 'SHFileOperationW');
      Result:=Assigned(_SHFileOperationW);
    end;
  end;
end;

function ShellExecExW(const FileName: WideString; const Verb: String;
  Handle: THandle; Mask: ULONG; ShowFlags: Integer): Boolean;
var
  SEI: TShellExecuteInfoW;
begin
  SetNull(SEI, SizeOf(SEI));
  SEI.cbSize:=SizeOf(SEI); // SizeOf(TShellExecuteInfoA) = SizeOf(TShellExecuteInfoW)
  SEI.Wnd:=Handle;
  SEI.fMask:=Mask;
  SEI.nShow:=ShowFlags;
  if CheckGetShellExecuteExW then begin
    SEI.lpFile:=PWideChar(FileName);
    SEI.lpVerb:=PWideChar(WideString(Verb));
    Result:=_ShellExecuteExW(@SEI);
  end
  else begin
    TShellExecuteInfo(SEI).lpFile:=PChar(String(FileName));
    TShellExecuteInfo(SEI).lpVerb:=Pointer(Verb);
    Result:=ShellExecuteEx(Pointer(@SEI));
  end;
end;

{ Themes Support }

var
  hThemeLib: THandle = 0;
  IsThemeActive: function : BOOL; stdcall;

function XPThemesActive: Boolean;
begin
  if not Assigned(IsThemeActive) and (hThemeLib = 0) and
    (Win32Platform = VER_PLATFORM_WIN32_NT) and
    (((Win32MajorVersion = 5) and (Win32MinorVersion >= 1)) or
     (Win32MajorVersion > 5)) then
  begin
    hThemeLib:=LoadLibrary('uxtheme.dll');
    if hThemeLib <> 0 then begin
      IsThemeActive:=GetProcAddress(hThemeLib, 'IsThemeActive');
      GetCurrentThemeName:=GetProcAddress(hThemeLib, 'GetCurrentThemeName');
    end;
  end;
  if Assigned(IsThemeActive) then
    Result:=IsThemeActive
  else
    Result:=False;
end;

initialization
finalization
  if hShell <> 0 then
    FreeLibrary(hShell);
  if hKernel <> 0 then
    FreeLibrary(hKernel);
  if hThemeLib <> 0 then
    FreeLibrary(hThemeLib);
end.
