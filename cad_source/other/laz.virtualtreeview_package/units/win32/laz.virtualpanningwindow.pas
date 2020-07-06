unit laz.VirtualPanningWindow;

{Adapted from VirtualTrees by Luiz Américo to work in LCL/Lazarus}

{$mode objfpc}{$H+}

interface

uses
  Windows, Graphics, Classes, SysUtils;
  
type
  { TVirtualPanningWindow }

  TVirtualPanningWindow = class
  private
    FHandle: THandle;
    FImage: TBitmap;
    procedure HandlePaintMessage;
  public
    procedure Start(OwnerHandle: THandle; const Position: TPoint);
    procedure Stop;
    procedure Show(ClipRegion: HRGN);
    property Image: TBitmap read FImage;
    property Handle: THandle read FHandle;
  end;

implementation

{$ifdef DEBUG_VTV}
uses
  laz.VTLogger;
{$endif}

function {%H-}PanningWindowProc(Window: HWnd; Msg: UInt;WPara: WParam; LPara: LParam): LResult; stdcall;
var
  PanningObject: TVirtualPanningWindow;
begin
  if Msg = WM_PAINT then
  begin
    PanningObject:=TVirtualPanningWindow(GetWindowLongPtrW(Window,GWL_USERDATA));
    if Assigned(PanningObject) then
      PanningObject.HandlePaintMessage;
  end
  else
    DefWindowProc(Window,Msg,WPara,LPara);
end;

var
  PanningWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @PanningWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'VTPanningWindow'
  );

{ TVirtualPanningWindow }

procedure TVirtualPanningWindow.HandlePaintMessage;
var
  PS: PaintStruct;
begin
  BeginPaint(FHandle, {%H-}PS);
  BitBlt(PS.hdc,0,0,FImage.Width,FImage.Height,FImage.Canvas.Handle,0,0,SRCCOPY);
  EndPaint(FHandle, PS);
end;


procedure TVirtualPanningWindow.Start(OwnerHandle: THandle; const Position: TPoint);
var
  TempClass: TWndClass;
  lSize: TSize;
begin
  // Register the helper window class.
  if not GetClassInfo(HInstance, PanningWindowClass.lpszClassName, {%H-}TempClass) then
  begin
    PanningWindowClass.hInstance := HInstance;
    Windows.RegisterClass(PanningWindowClass);
  end;

  // Create the helper window and show it at the given position without activating it.
  lSize.CX := MulDiv(32, ScreenInfo.PixelsPerInchX, 96);
  lSize.CY := MulDiv(32, ScreenInfo.PixelsPerInchY, 96);
  with Position do
    FHandle := CreateWindowEx(WS_EX_TOOLWINDOW, PanningWindowClass.lpszClassName,
      nil, WS_POPUP, X - lSize.CX div 2, Y - lSize.CY div 2, lSize.CX, lSize.CY,
      OwnerHandle, 0, HInstance, nil);
  //todo use SetWindowLongPtr later
  SetWindowLong(FHandle,GWL_USERDATA,PtrInt(Self));
  
  FImage := TBitmap.Create;
end;

procedure TVirtualPanningWindow.Stop;
begin
  // Destroy the helper window.
  DestroyWindow(FHandle);
  FImage.Free;
  FImage := nil;
end;

procedure TVirtualPanningWindow.Show(ClipRegion: HRGN);
begin
  {$ifdef DEBUG_VTV}Logger.SendBitmap([lcPanning],'Panning Image',FImage);{$endif}
  //todo: move SetWindowRgn to DelphiCompat
  SetWindowRgn(FHandle, ClipRegion, False);
  ShowWindow(FHandle, SW_SHOWNOACTIVATE);
end;

end.

