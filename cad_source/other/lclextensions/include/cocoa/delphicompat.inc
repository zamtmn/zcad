
{
  Carbon Interface

  Dummy implementation. Not tested. 
  Waiting for someone with a Mac to implement it
}

type
  TTimerList = class
  end;

var
  FTimerList: TTimerList;
  
function CF_UNICODETEXT: TClipboardFormat;
begin
  //todo
  Result := TClipboardFormat(0);
end;

{
  Only a few functions are necessary to compile VirtualTreeView:
  BitBlt
  GetCurrentObject
  Set/KillTimer (Look at Qt/Gtk implementation)
}

{$define HAS_GETCURRENTOBJECT}
{.$define HAS_MAPMODEFUNCTIONS}
{.$define HAS_GETTEXTEXTENTEXPOINT}
{.$define HAS_GETDOUBLECLICKTIME}
{.$define HAS_GETTEXTALIGN}
{.$define HAS_GETWINDOWDC}
{.$define HAS_INVERTRECT}
{.$define HAS_OFFSETRGN}
{.$define HAS_REDRAWWINDOW}
{.$define HAS_SCROLLWINDOW}
{.$define HAS_SETBRUSHORGEX}


{$i ../generic/stubs.inc}
{$i ../generic/independentfunctions.inc}
{$i ../generic/unicodefunctions.inc}


function BitBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC; XSrc,
  YSrc: Integer; Rop: DWORD): Boolean;
begin
  Result := StretchMaskBlt(DestDC, X, Y, Width, Height, SrcDC, XSrc, YSrc,
    Width, Height, 0, 0, 0, Rop);
end;

function GetCurrentObject(hdc: HDC; uObjectType: UINT): HGDIOBJ;
begin
  Result := LCLIntf.GetCurrentObject(hdc, uObjectType);
end;

function KillTimer(hWnd: THandle; nIDEvent: UINT_PTR):Boolean;
begin
  Result := LCLIntf.KillTimer(hWnd, nIDEvent);
end;

function SetTimer(hWnd: THandle; nIDEvent: UINT_PTR; uElapse: LongWord; lpTimerFunc: TTimerNotify): UINT_PTR;
begin
  Result := LCLIntf.SetTimer(hWnd, nIDEvent, uElapse, nil{lpTimerFunc});
end;