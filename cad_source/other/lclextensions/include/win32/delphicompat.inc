
{ This file is part of Delphi Compatibility Unit

  Copyright (C) 2007 Luiz Américo Pereira Câmara
  pascalive@bol.com.br

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

}

function BeginDeferWindowPos(nNumWindows: longint): THandle;
begin
  Result:=Windows.BeginDeferWindowPos(nNumWindows);
end;

function BitBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC; XSrc,
  YSrc: Integer; Rop: DWORD): Boolean;
begin
  Result := Windows.BitBlt(DestDC, X, Y, Width, Height, SrcDC, XSrc, YSrc, Rop);
end;

function CF_UNICODETEXT: TClipboardFormat;
begin
  Result:=Windows.CF_UNICODETEXT;
end;

function CopyImage(hImage: THANDLE; uType: LongWord; cxDesired,
  cyDesired: LongInt; fuFlags: LongWord): THandle;
begin
  Result := Windows.CopyImage(hImage,uType,cxDesired,cyDesired,fuFlags);
end;

function CreatePatternBrush(hbmp: HBITMAP): HBRUSH;
begin
  Result := Windows.CreatePatternBrush(hbmp);
end;

function DeferWindowPos(hWinPosInfo, hWnd, hWndInsertAfter: THandle;
  x, y, cx, cy: longint; uFlags: LongWord): THandle;
begin
  Result := Windows.DeferWindowPos(hWinPosInfo,hWnd,hWndInsertAfter,x,y,cx,cy,uFlags);
end;

function DrawFrameControl(DC: HDC; const Rect: TRect; uType, uState: LongWord): Boolean;
begin
  Result := Windows.DrawFrameControl(DC,Rect,uType,uState);
end;

function DrawTextW(hDC: HDC; lpString: PWideChar; nCount: Integer;
  var lpRect: TRect; uFormat: LongWord): Integer;
begin
  Result := Windows.DrawTextW(hDC,lpString,nCount,lpRect,uFormat);
end;
  
function EndDeferWindowPos(hWinPosInfo: THandle): Boolean;
begin
  Result:=Windows.EndDeferWindowPos(hWinPosInfo);
end;

function ExtTextOutW(DC: LCLType.HDC; X, Y: Integer; Options: LongInt; Rect: Types.PRect;
  Str: PWideChar; Count: LongInt; Dx: ObjPas.PInteger): Boolean;
begin
  Result := Windows.ExtTextOutW(DC, X, Y, Options, Rect,Str, Count, Dx);
end;

function GdiFlush: Boolean;
begin
  Result := Windows.GdiFlush;
end;

function GetACP: LongWord;
begin
  Result := Windows.GetACP;
end;

function GetBkColor(DC: HDC): LCLType.COLORREF;
begin
  Result := Windows.GetBkColor(DC);
end;

function GetCurrentObject(hdc: HDC; uObjectType: UINT): HGDIOBJ;
begin
  Result := Windows.GetCurrentObject(hdc, uObjectType);
end;

function GetDCEx(hWnd: THandle; hrgnClip: HRGN; flags: DWORD): HDC;
begin
  Result := Windows.GetDCEx(hWnd,hrgnClip,flags);
end;

function GetDoubleClickTime: UINT;
begin
  Result := Windows.GetDoubleClickTime;
end;

function GetKeyboardLayout(dwLayout: DWORD): THandle;
begin
  Result := Windows.GetKeyboardLayout(dwLayout);
end;

function GetKeyboardState(lpKeyState: PBYTE): BOOLEAN;
begin
  Result := Windows.GetKeyboardState(lpKeyState);
end;

function GetLocaleInfo(Locale, LCType: LongWord; lpLCData: PChar;
  cchData: longint): longint;
begin
  Result := Windows.GetLocaleInfo(Locale,LCType,lpLCData,cchData);
end;

{$if lcl_release < 29}
function GetMapMode(DC: HDC): LongInt;
begin
  Result := Windows.GetMapMode(DC);
end;
{$endif}

function GetRandomRgn(DC: HDC; Rgn: HRGN; iNum: Integer): Integer; stdcall; external 'GDI32.DLL';

function GetTextAlign(hDC: HDC): LongWord;
begin
  Result := Windows.GetTextAlign(hDC);
end;

function GetTextExtentExPoint(DC: LCLType.HDC; Str: PChar;
  Count, MaxWidth: Integer; MaxCount, PartialWidths: ObjPas.PInteger;
  var Size: TSize): BOOL;
begin
  Result := Windows.GetTextExtentExPoint(DC, Str, Count, MaxWidth, MaxCount, PartialWidths,  Size);
end;

function GetTextExtentExPointW(DC: LCLType.HDC; Str: PWideChar;
  Count, MaxWidth: Integer; MaxCount, PartialWidths: ObjPas.PInteger;
  var Size: Types.TSize): BOOL;
begin
  Result := Windows.GetTextExtentExPointW(DC, Str, Count, MaxWidth, MaxCount, PartialWidths,  Size);
end;

function GetTextExtentPoint32W(DC: HDC; Str: PWideChar; Count: Integer; out Size: TSize): Boolean;
begin
  Result := Windows.GetTextExtentPointW(DC, Str, Count, Size);
end;

function GetTextExtentPointW(DC: HDC; Str: PWideChar; Count: Integer; out Size: TSize): Boolean;
begin
  Result := Windows.GetTextExtentPointW(DC, Str, Count, Size);
end;

function GetWindowDC(hWnd: THandle): HDC;
begin
  Result := Windows.GetWindowDC(hWnd);
end;

function ImageList_DragShowNolock(fShow: Boolean): Boolean;
begin
  Result := CommCtrl.ImageList_DragShowNolock(fShow);
end;

function InvertRect(DC: HDC; const lprc: TRect): Boolean;
begin
  Result := Windows.InvertRect(DC, PRect(@lprc)^);
end;

function LPtoDP(DC: HDC; var Points; Count: Integer): BOOLEAN;
begin
  Result := Windows.LPToDP(DC,Points,Count);
end;

function MapWindowPoints(hWndFrom, hWndTo: HWND; var lpPoints; cPoints: UINT
  ): Integer;
begin
  Result:=Windows.MapWindowPoints(hWndFrom,hWndTo,lpPoints,cPoints);
end;

function MultiByteToWideChar(CodePage, dwFlags: DWORD; lpMultiByteStr: PChar;
  cchMultiByte: longint; lpWideCharStr: PWideChar; cchWideChar: longint
  ): longint;
begin
  Result := Windows.MultiByteToWideChar(CodePage,dwFlags,lpMultiByteStr,cchMultiByte,lpWideCharStr,cchWideChar);
end;

function OffsetRgn(hrgn: HRGN; nxOffset, nYOffset: longint): longint;
begin
  Result := Windows.OffsetRgn(hrgn,nxOffset,nYOffset);
end;

function RedrawWindow(hWnd: THandle; lprcUpdate: Types.PRECT; hrgnUpdate: HRGN;
  flags: LongWord): BOOLEAN;
begin
  Result := Windows.RedrawWindow(hWnd,lprcUpdate,hrgnUpdate,flags);
end;

function SetBrushOrgEx(DC: LCLType.HDC; nXOrg, nYOrg: longint; lppt: Types.PPoint): Boolean;
begin
  Result := Windows.SetBrushOrgEx(DC,nXOrg,nYOrg,lppt);
end;

{$if lcl_release < 29}
function SetMapMode(DC: HDC; fnMapMode: LongInt): LongInt;
begin
  Result := Windows.SetMapMode(DC, fnMapMode);
end;
{$endif}

function ScrollDC(DC: LCLType.HDC; dx: longint; dy: longint; var lprcScroll: Types.TRect;
  var lprcClip: Types.TRect; hrgnUpdate: LCLType.HRGN; lprcUpdate: Types.PRect): Boolean;
begin
  Result := Windows.ScrollDC(DC, dx, dy, lprcScroll, lprcClip, hrgnUpdate, lprcUpdate);
end;

function ScrollWindow(hWnd: THandle; XAmount, YAmount: longint; lpRect: Types.PRect;
  lpClipRect: Types.PRect): Boolean;
begin
  Result := Windows.ScrollWindow(hWnd,XAmount,YAmount,lpRect,lpClipRect);
end;

function SubtractRect(var lprcDst: TRect; const lprcSrc1, lprcSrc2: TRect
  ): BOOLEAN;
begin
  Result := Windows.SubtractRect(lprcDst,lprcSrc1,lprcSrc2);
end;

function TextOutW(DC: HDC; X,Y : Integer; Str : PWideChar; Count: Integer) : Boolean;
begin
  Result := Windows.TextOutW(DC,X,Y,Str,Count);
end;

function ToAscii(uVirtKey, uScanCode: LongWord; lpKeyState: PBYTE;
  lpChar: PWORD; uFlags: LongWord): longint;
begin
  Result := Windows.ToAscii(uVirtKey,uScanCode,lpKeyState,lpChar,uFlags);
end;

function UpdateWindow(Handle: HWND): Boolean;
begin
  Result := Windows.UpdateWindow(Handle);
end;

type
  TTimerID = record
    hWnd: THandle;
    nIDEvent: UINT_PTR;
  end;

  TTimerRecord = record
    Control: TControl;
    Notify: TTimerNotify;
  end;
  
  PTimerRecord = ^TTimerRecord;

  { TTimerList }

  TTimerList = class
  private
    FMap: TMap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(hWnd: THandle; nIDEvent: UINT_PTR; NotifyFunc: TTimerNotify; Control: TControl);
    function GetTimerInfo(hWnd: THandle; nIDEvent: UINT_PTR; out TimerInfo: TTimerRecord):Boolean;
    function GetTimerInfoPtr(hWnd: THandle; nIDEvent: UINT_PTR): PTimerRecord;
  end;

var
  FTimerList: TTimerList;
  
{ TTimerList }

constructor TTimerList.Create;
begin
  FMap := TMap.Create({$ifdef CPU64}itu16{$else}itu8{$endif}, SizeOf(TTimerRecord));
end;

destructor TTimerList.Destroy;
begin
  FMap.Destroy;
  inherited Destroy;
end;

procedure TTimerList.Add(hWnd: THandle; nIDEvent: UINT_PTR; NotifyFunc: TTimerNotify; Control: TControl);
var
  TimerID: TTimerID;
  TimerRec: TTimerRecord;
begin
  TimerRec.Notify := NotifyFunc;
  TimerRec.Control := Control;
  TimerID.hWnd := hWnd;
  TimerID.nIDEvent := nIDEvent;
  with FMap do
  begin
    if HasId(TimerID) then
      SetData(TimerID, TimerRec)
    else
      Add(TimerID, TimerRec);
  end;
end;

function TTimerList.GetTimerInfo(hWnd: THandle; nIDEvent: UINT_PTR;
  out TimerInfo: TTimerRecord): Boolean;
var
  TimerID: TTimerID;
begin
  TimerID.hWnd := hWnd;
  TimerID.nIDEvent := nIDEvent;
  Result := FMap.GetData(TimerID, TimerInfo);
end;

function TTimerList.GetTimerInfoPtr(hWnd: THandle; nIDEvent: UINT_PTR): PTimerRecord;
var
  TimerID: TTimerID;
begin
  TimerID.hWnd := hWnd;
  TimerID.nIDEvent := nIDEvent;
  Result := FMap.GetDataPtr(TimerID);
end;

//workaround to buggy fpc header
type
  TIMERPROC64 = procedure (hWnd: HWND; uMsg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall;

function SetTimer64(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT; lpTimerFunc: TIMERPROC64): UINT_PTR; stdcall external 'user32' name 'SetTimer';
function KillTimer64(hWnd: HWND; uIDEvent: UINT_PTR):WINBOOL;  stdcall external 'user32' name 'KillTimer';

procedure TimerCallBack(Handle: hWnd; Msg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall;
var
  TimerInfo: PTimerRecord;
begin
  //DebugLn('Executing Timer to Handle %d - ID: %d',[Handle, idEvent]);
  TimerInfo := FTimerList.GetTimerInfoPtr(Handle, idEvent);
  if TimerInfo <> nil then
  with TimerInfo^ do
  begin
    if Notify <> nil then
      Notify(idEvent)
    else
    begin
      if Control <> nil then
        LCLSendTimerMsg(Control,idEvent,0);
    end;
  end
  else
    DebugLn('Warning - No TimerInfo found for Hwnd: %d Id: %d',[Handle,idEvent]);
end;

function SetTimer(hWnd: THandle; nIDEvent: UINT_PTR; uElapse:LongWord; lpTimerFunc: TTimerNotify):UINT_PTR;
var
  WinInfo: PWin32WindowInfo;
begin
  if hWnd <> 0 then
  begin
    WinInfo := GetWin32WindowInfo(hWnd);
    FTimerList.Add(hWnd,nIDEvent,lpTimerFunc,WinInfo^.WinControl);
    Result := SetTimer64(hWnd,nIDEvent,uElapse,@TimerCallBack);
  end
  else
  begin
    //if handle is 0, the callback is mandatory otherwise we get a zombie timer
    if lpTimerFunc <> nil then
    begin
      Result := SetTimer64(hWnd,nIDEvent,uElapse,@TimerCallBack);
      FTimerList.Add(hWnd,Result,lpTimerFunc,nil);
    end
    else
      Result := 0;
  end;
  //DebugLn('SetTimer - Handle %d - ID: %d - Result: %d',[hWnd,nIDEvent,Result]);
end;

function KillTimer(hWnd: THandle; nIDEvent: UINT_PTR):Boolean;
begin
  Result := KillTimer64(hWnd,nIDEvent);
  //DebugLn('KillTimer - Handle %d - ID: %d',[hWnd,nIDEvent]);
end;
