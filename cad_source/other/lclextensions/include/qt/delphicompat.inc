
{
  Qt Interface
  
  Initial implementation by Zeljan Rikalo

  SetTimer/KillTimer implementation by Luiz Americo
}

function CF_UNICODETEXT: TClipboardFormat;
begin
  //todo
  Result := TClipboardFormat(0);
end;

{$define HAS_GETBKCOLOR}
{$define HAS_GETCURRENTOBJECT}
{$define HAS_INVERTRECT}
{$define HAS_GETTEXTEXTENTEXPOINT}
{$define HAS_GETDOUBLECLICKTIME}
{$define HAS_GETTEXTALIGN}
{$define HAS_GETWINDOWDC}
{$define HAS_OFFSETRGN}
{$define HAS_REDRAWWINDOW}
{$define HAS_SCROLLWINDOW}
{$define HAS_SETBRUSHORGEX}


{$i ../generic/stubs.inc}
{$i ../generic/independentfunctions.inc}
{$i ../generic/unicodefunctions.inc}

function GetBkColor(DC:HDC):COLORREF;
var
  Color: PQColor;
begin
  if QtWidgetSet.IsValidDC(DC) then
  begin
    Color := TQtDeviceContext(DC).BackgroundBrush.getColor;
    TQColorToColorRef(Color^, Result);
  end else
    Result := CLR_INVALID;
end;

function BitBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC; XSrc,
  YSrc: Integer; Rop: DWORD): Boolean;
begin
  Result := StretchBlt(DestDC, X, Y, Width, Height, SrcDC, XSrc, YSrc, Width,
    Height, ROP);
end;

function GetCurrentObject(hdc: HDC; uObjectType: UINT): HGDIOBJ;
begin
  Result := 0;
  if QtWidgetSet.IsValidDC(hdc) then
  with TQtDeviceContext(hdc) do
  begin      {TODO: FIXME}
    case uObjectType of
      OBJ_BITMAP: Result := HGDIOBJ(vImage);
      OBJ_BRUSH: Result := HGDIOBJ(vBrush);
      OBJ_FONT: Result := HGDIOBJ(vFont);
      OBJ_PEN: Result := HGDIOBJ(vPen);
    end;
  end;
end;

function GetDoubleClickTime: UINT;
begin
  Result := QApplication_doubleClickInterval;
end;

function GetTextExtentExPoint(DC: HDC; Str: PChar;
  Count, MaxWidth: Integer; MaxCount, PartialWidths: PInteger;
  var Size: TSize): BOOL;
begin
  Result := QtWidgetSet.GetTextExtentExPoint(DC, Str, Count, MaxWidth, MaxCount, PartialWidths, Size);
end;

function GetTextAlign(hDC:HDC): LongWord;
var
  QtDC: TQtDeviceContext;
  QtFontMetrics: QFontMetricsH;
  QtFont: QFontH;
begin
  Result := 0;
  if not QtWidgetSet.IsValidDC(hdC) then
    Exit;
  QtDC := TQtDeviceContext(hDC);
  QtFont := QtDC.vFont.FHandle;
  QtFontMetrics := QFontMetrics_create(QtFont);
  try
  {TODO: FIXME we should save somehow text flags into QtDC
   cause we don't have any function which returns current flags !}
  finally
    QFontMetrics_destroy(QtFontMetrics);
  end;
end;

function GetWindowDC(hWnd:THandle): HDC;
begin
  Result := LCLIntf.GetDC(hWnd);
end;

function InvertRect(DC: HDC; const lprc: TRect): Boolean;
var
  DCOrigin: TQtPoint;
begin
  //todo: see the windows result when rect is invalid
  Result := QtWidgetSet.IsValidDC(DC) and (lprc.Bottom > lprc.Top)
    and (lprc.Right > lprc.Left);
  if Result then
  begin
    with lprc do
      Result := BitBlt(DC, Left, Top, Right - Left, Bottom-Top,
        DC, Left, Top, LongWord(QPainterCompositionMode_DestinationOver));
    {TODO: FIXME !}
  end;
end;

function OffsetRgn(hrgn:HRGN; nxOffset, nYOffset:longint):longint;
var
  Region: TQtRegion;
begin
  Region := TQtRegion(hrgn);
  QRegion_translate(Region.FHandle, nxOffset, nYOffset);
  Result := Region.GetRegionType;
end;

function RedrawWindow(hWnd:THandle; lprcUpdate:PRECT; hrgnUpdate:HRGN; flags:LongWord):BOOLEAN;
begin
  Result := QtWidgetSet.RedrawWindow(hWnd, lprcUpdate, hrgnUpdate, flags);
end;

function ScrollWindow(hWnd:THandle; XAmount, YAmount:longint;lpRect:PRECT; lpClipRect:PRECT): Boolean;
begin
  Result := False;
  if hWnd = 0 then
    Exit;
  QWidget_scroll(TQtWidget(hWnd).Widget, XAmount, YAmount, lpRect);
  Result := True;
end;

function SetBrushOrgEx(DC:HDC; nXOrg, nYOrg:longint; lppt:PPOINT):Boolean;
var
  QtDC: TQtDeviceContext;
begin
  Result := False;
  if not QtWidgetSet.IsValidDC(DC) then
    Exit;
  QtDC := TQtDeviceContext(DC);
  if lppt <> nil then
    QtDC.getBrushOrigin(lppt);
  QtDC.setBrushOrigin(nXorg, nYOrg);
  Result := True;
end;


type

  TTimerID = record
    hWnd: THandle;
    nIDEvent: UINT_PTR;
  end;

  { TQtTimerEx }

  TQtTimerEx = class(TQtObject)
  private
    FTimerHook: QTimer_hookH;
    FWidgetHook: QObject_hookH;
    FCallbackFunc: TTimerNotify;
    FID: UINT_PTR;
    FHandle: THandle;
    FControl: TWinControl;
  public
    constructor Create(hWnd: THandle; nIDEvent: UINT_PTR; TimerFunc: TTimerNotify);
    destructor Destroy; override;
    procedure AttachEvents; override;
    procedure DetachEvents; override;
    procedure signalWidgetDestroyed; cdecl;
    procedure signalTimeout; cdecl;
  public
    function EventFilter(Sender: QObjectH; Event: QEventH): Boolean; cdecl; override;
    procedure Start(Interval: Integer);
    procedure Stop;
  end;


  { TTimerList }

  TTimerList = class
  private
    FMap: TMap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Delete(hWnd: THandle; nIDEvent: UINT_PTR);
    function Find(hWnd: THandle; nIDEvent: UINT_PTR): TQtTimerEx;
    function Get(hWnd: THandle; nIDEvent: UINT_PTR; NotifyFunc: TTimerNotify): TQtTimerEx;
  end;

  TQtWidgetSetHack = Class(TWidgetSet)
  private
    App: QApplicationH;
  end;

var
  FTimerList: TTimerList;

{ TQtTimerEx }

constructor TQtTimerEx.Create(hWnd: THandle; nIDEvent: UINT_PTR; TimerFunc: TTimerNotify);
var
  AName: WideString;
begin
  inherited Create;
  FDeleteLater := True;
  FCallbackFunc := TimerFunc;
  FID := nIDEvent;
  FControl := FindControl(hWnd);
  FHandle := hWnd;
  if hWnd <> 0 then
  begin
    FWidgetHook := QObject_hook_create(TQtWidget(hWnd).TheObject);
    QObject_hook_hook_destroyed(FWidgetHook, @signalWidgetDestroyed);
  end;
  //very big ultra extreme hack to get the app from QtWidgetset
  TheObject := QTimer_create(TQtWidgetSetHack(QtWidgetSet).App);
  AName := 'tqttimerex';
  QObject_setObjectName(TheObject, @AName);

  AttachEvents;
end;

destructor TQtTimerEx.Destroy;
begin
  if FWidgetHook <> nil then
    QObject_hook_destroy(FWidgetHook);
  inherited Destroy;
end;

procedure TQtTimerEx.AttachEvents;
begin
  FTimerHook := QTimer_hook_create(QTimerH(TheObject));
  QTimer_hook_hook_timeout(FTimerHook, @signalTimeout);
  inherited AttachEvents;
end;

procedure TQtTimerEx.DetachEvents;
begin
  QTimer_stop(QTimerH(TheObject));
  if FTimerHook <> nil then
    QTimer_hook_destroy(FTimerHook);
  inherited DetachEvents;
end;

procedure TQtTimerEx.signalWidgetDestroyed; cdecl;
begin
  Stop;
  FTimerList.Delete(FHandle, FID);
  Destroy;
end;

procedure TQtTimerEx.signalTimeout; cdecl;
begin
  if Assigned(FCallbackFunc) then
    FCallbackFunc(FID)
  else if Assigned(FControl) then
  begin
    if ([csLoading, csDestroying] * FControl.ComponentState = []) and not
      (csDestroyingHandle in FControl.ControlState) then
    begin
      LCLSendTimerMsg(FControl, FID, 0);
    end;
  end
  else
  begin
    //orphan timer. Stop.
    //todo: better to remove from the list?
    Stop;
  end;
end;

function TQtTimerEx.EventFilter(Sender: QObjectH; Event: QEventH): Boolean; cdecl;
begin
  Result := False;
  QEvent_accept(Event);
end;

procedure TQtTimerEx.Start(Interval: Integer);
begin
  QTimer_start(QTimerH(TheObject), Interval);
end;

procedure TQtTimerEx.Stop;
begin
  QTimer_stop(QTimerH(TheObject));
end;
  
function KillTimer(hWnd: THandle; nIDEvent: UINT_PTR): Boolean;
var
  TimerObject: TQtTimerEx;
begin
  Result := True;
  TimerObject := FTimerList.Find(hWnd, nIDEvent);
  if TimerObject <> nil then
  begin
    // DebugLn('KillTimer HWnd: %d ID: %d TimerObject: %d',[hWnd, nIDEvent, PtrInt(TimerObject)]);
    TimerObject.Stop;
  end;
end;

function SetTimer(hWnd: THandle; nIDEvent: UINT_PTR; uElapse: LongWord; lpTimerFunc: TTimerNotify): UINT_PTR;
var
  TimerObject: TQtTimerEx;
begin
  TimerObject := FTimerList.Get(hWnd, nIDEvent, lpTimerFunc);
  try
    TimerObject.Start(uElapse);
    if hWnd = 0 then
      Result := PtrInt(TimerObject)
    else
      Result := nIdEvent;
  except
    Result := 0;
  end;
  //DebugLn('SetTimer HWnd: %d ID: %d TimerObject: %d',[hWnd, nIDEvent, PtrInt(TimerObject)]);
end;

function TTimerList.Get(hWnd: THandle; nIDEvent: UINT_PTR; NotifyFunc: TTimerNotify): TQtTimerEx;
var
  AID: TTimerID;
begin
  AID.hWnd := hWnd;
  AID.nIDEvent := nIDEvent;
  with FMap do
  begin
    if HasId(AID) then
    begin
      // DebugLn('Reset timer for HWnd: %d ID: %d AID: %d', [hWnd, ID, AID]);
      GetData(AID, Result);
      Result.FCallbackFunc := NotifyFunc;
    end
    else
    begin
      // DebugLn('Create timer for HWnd: %d ID: %d AID: %d', [hWnd, ID, AID]);
      Result := TQtTimerEx.Create(hWnd, nIDEvent, NotifyFunc);
      if hWnd = 0 then
      begin
        AID.nIDEvent := PtrUInt(Result);
        Result.FID := PtrUInt(Result);
      end;
      Add(AID, Result);
    end;
  end;
end;

constructor TTimerList.Create;
begin
  FMap := TMap.Create({$ifdef CPU64}itu16{$else}itu8{$endif}, SizeOf(TQtTimerEx));
end;

destructor TTimerList.Destroy;
var
  Iterator: TMapIterator;
  TimerObject: TQtTimerEx;
begin
  Iterator := TMapIterator.Create(FMap);
  with Iterator do
  begin
    while not EOM do
    begin
      GetData(TimerObject);
      TimerObject.Free;
      Next;
    end;
    Destroy;
  end;
  FMap.Destroy;
end;

procedure TTimerList.Delete(hWnd: THandle; nIDEvent: UINT_PTR);
var
  TimerID: TTimerID;
begin
  TimerID.hWnd := hWnd;
  TimerID.nIDEvent := nIDEvent;
  FMap.Delete(TimerID);
end;

function TTimerList.Find(hWnd: THandle; nIDEvent: UINT_PTR): TQtTimerEx;
var
  DataPtr: ^TQtTimerEx;
  TimerID: TTimerID;
begin
  Result := nil;
  TimerID.hWnd := hWnd;
  TimerID.nIDEvent := nIDEvent;
  // DebugLn('GetTimerObject for HWnd: %d ID: %d AID: %d', [hWnd, nIDEvent, TimerID]);
  DataPtr := FMap.GetDataPtr(TimerID);
  if DataPtr <> nil then
    Result := DataPtr^;
end;

