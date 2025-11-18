{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzcMainForm;
{$INCLUDE zengineconfig.inc}

interface

uses
  {LCL}
  Math,
  AnchorDockPanel,AnchorDocking,
  ActnList,LCLType,LCLProc,uzcTranslations,LMessages,LCLIntf,
  Forms,StdCtrls,ExtCtrls,ComCtrls,Controls,Classes,SysUtils,LazUTF8,
  Menus,Graphics,Themes,
  Types,UniqueInstanceBase,simpleipc,Laz2_XMLCfg,LCLVersion,
  {ZCAD BASE}
  uzcsysparams,gzctnrVectorTypes,uzemathutils,uzelongprocesssupport,
  uzgldrawergdi,uzcdrawing,UGDBOpenArrayOfPV,uzedrawingabstract,
  uzepalette,uzbpaths,uzglviewareadata,uzeentitiesprop,uzcinterface,
  uzctnrVectorBytes,uzbtypes,
  uzegeometry,uzcsysvars,uzcstrconsts,uzbstrproc,uzcLog,uzbLogTypes,uzbLog,
  uzedimensionaltypes,varmandef,varman,UUnitManager,uzcsysinfo,strmy,
  uzestylestexts,uzestylesdim,
  uzbexceptionscl,uzbexceptionsgui,
  {ZCAD ENTITIES}
  uzegeometrytypes,uzeentity,UGDBSelectedObjArray,uzestyleslayers,uzedrawingsimple,
  uzeblockdef,uzcdrawings,uzestyleslinetypes,uzeconsts,uzeenttext,uzeentdimension,
  {ZCAD COMMANDS}
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzccommand_loadlayout,
  {GUI}
  uzcuitypes,
  uzcmenucontextcheckfuncs,uzctbextmenus,uzmenusdefaults,uzmenusmanager,
  uztoolbarsmanager,uzctextenteditor,uzcfcommandline,uzctreenode,uzcctrlcontextmenu,
  uzcimagesmanager,usupportgui,uzcuidialogs,
  uzcActionsManager,
  uzcFileStructure,

  //это разделять нельзя, иначе загрузятся невыровенные рекорды
  {$INCLUDE allgeneratedfiles.inc}uzcregother,
  uzcguiDarkStyleSetup,uMetaDarkStyle,
  uzgldrawcontext,uzglviewareaabstract,uzcguimanager,uzcinterfacedata,
  uzcenitiesvariablesextender,uzglviewareageneral,UniqueInstanceRaw,
  uzmacros,uzcviewareacxmenu,uzccommand_quit,uzeMouseTimer,
  uzccommand_multiselect2objinsp{$IfDef LINUX},BaseUnix{$EndIf};

resourcestring
  rsClosed='Closed';

type
  TZInfoProgress=class(TPanel)
  strict private
    ProcessBarCounter:integer;
    ProcessBar:TProgressBar;
    HintText:TLabel;
    LastHintText:string;
    NextLongProcessPos:integer;
  public
    constructor CreateOnTB(tb:TToolBar);

    procedure SetText(AText:string;Force:boolean=False);
    procedure SetText2;

    procedure ShowProcessBar(Total:integer);
    procedure ProcessProcessBar(Current:integer);
    procedure EndProcessBar;

    procedure SwithToProcessBar;
    procedure SwithToHintText;
  end;

  { TzcMainForm }

  TzcMainForm=class(TForm)
  private
    InfoProgress:TZInfoProgress;
    SystemTimer:TTimer;
    toolbars:TStringList;
    MainPanel:TForm;
    DHPanel:TPanel;
    HScrollBar,VScrollBar:TScrollBar;
    MouseTimer:TMouseTimer;
    fNeedUpdateMainMenu:boolean;

  published
    DockPanel:TAnchorDockPanel;
    CoolBarR:TCoolBar;
    CoolBarD:TCoolBar;
    CoolBarL:TCoolBar;
    CoolBarU:TCoolBar;
    ToolBarD:TToolBar;

    procedure DrawStausBar(Sender:TObject);
    //onXxxxx handlers
    procedure _onCreate(Sender:TObject);
  public
    PageControl:TmyPageControl;

    procedure ZcadException(Sender:TObject;E:Exception);
    procedure CreateHTPB(tb:TToolBar);//надо убрать
    procedure ActionUpdate(AAction:TBasicAction;var Handled:boolean);
    procedure ChangedDWGTabByClick(Sender:TObject);
    procedure ChangedDWGTab(Sender:TObject);
    procedure UpdateControls;
    procedure EnableControls(enbl:boolean);
    procedure ShowAllCursors(ShowedForm:TForm);
    procedure RestoreCursors(ShowedForm:TForm);
    procedure CloseDWGPageInterf(Sender:TObject);

    procedure PageControlMouseDown(Sender:TObject;Button:TMouseButton;
      Shift:TShiftState;X,Y:integer);
    procedure correctscrollbars;
    function wamd(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer;onmouseobject:Pointer;
      var NeedRedraw:boolean):boolean;
    function wamu(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer;onmouseobject:Pointer;
      var NeedRedraw:boolean):boolean;
    procedure wamm(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer);
    procedure wams(Sender:TAbstractViewArea;SelectedEntity:Pointer);
    procedure wakp(Sender:TAbstractViewArea;var Key:word;Shift:TShiftState);
    function GetEntsDesc(ents:PGDBObjOpenArrayOfPV):string;
    procedure waSetObjInsp(Sender:{TAbstractViewArea}TObject;GUIAction:TzcMessageID);
    procedure WaShowCursor(Sender:TAbstractViewArea;var DC:TDrawContext);

    //Long process support - draw progressbar. See uzelongprocesssupport unit
    procedure StartLongProcess(LPHandle:TLPSHandle;Total:TLPSCounter;
      processname:TLPName;Options:TLPOpt);
    procedure ProcessLongProcess(LPHandle:TLPSHandle;Current:TLPSCounter;
      Options:TLPOpt);
    procedure EndLongProcess(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt);
  public
    SuppressedShortcuts:TXMLConfig;
    RunTime:integer;
    procedure FormClose(Sender:TObject;var CloseAction:TCloseAction);
    destructor Destroy;override;
    procedure CreateAnchorDockingInterface;

    procedure CreateInterfaceLists;
    procedure InitSystemCalls;
    procedure LoadActions;
    procedure myKeyDown(Sender:TObject;var Key:word;Shift:TShiftState);

    procedure idle(Sender:TObject;var Done:boolean);virtual;
    procedure GeneralTick(Sender:TObject);
    procedure ShowFastMenu(Sender:TObject);
    procedure asynccloseapp(Data:PtrInt);
    procedure processfilehistory(filename:string);
    procedure processcommandhistory(Command:string);
    function CreateZCADControl(aName:string;
      DoDisableAutoSizing:boolean=False):TControl;

    procedure DockMasterCreateControl(Sender:TObject;aName:string;
      var AControl:TControl;
      DoDisableAutoSizing:boolean);

    function IsShortcut(var Message:TLMKey):boolean;override;

    procedure setvisualprop(Sender:TObject;GUIAction:TzcMessageID);

    procedure _scroll(Sender:TObject;ScrollCode:TScrollCode;
      var ScrollPos:integer);
    procedure ShowCXMenu;
    procedure ShowFMenu;
    procedure MainMouseMove;
    function MainMouseDown(Sender:TAbstractViewArea):boolean;
    procedure MainMouseUp;
    procedure IPCMessage(Sender:TObject);
    {$ifdef windows}procedure SetTop;{$endif}
    procedure AsyncFree(Data:PtrInt);
    procedure UpdateVisible(Sender:TObject;GUIMode:TzcMessageID);
    procedure AsyncUpdateVisible(Sender:PtrInt);
    procedure DoUpdateMainMenu;
    procedure NeedUpdateMainMenu;
    function GetFocusPriority:TControlWithPriority;

    procedure StartEntityDrag(StartX,StartY,X,Y:integer);

    procedure SwithToProcessBar;
    procedure SwithToHintText;

    procedure DropFiles(Sender:TObject;const FileNames:array of string);
  end;

var
  zcMainForm:TzcMainForm;

function IsRealyQuit:boolean;
procedure RunCmdFile(const filename:string;pdata:pointer);

implementation

{$R *.lfm}

var
  LMD:TModuleDesk;

procedure TzcMainForm.SwithToProcessBar;
begin
  InfoProgress.SwithToProcessBar;
end;

procedure TzcMainForm.SwithToHintText;
begin
  InfoProgress.SwithToHintText;
end;

procedure TzcMainForm.DropFiles(Sender:TObject;const FileNames:array of string);
var
  filename,ts:string;
  i:integer;
begin
  for i:=Low(FileNames) to High(FileNames) do begin
    filename:=FileNames[i];

    GetPartOfPath(ts,filename,'|');
    if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then begin
      commandmanager.executecommandtotalend;
      commandmanager.executecommand('Load('+ts+')',drawings.GetCurrentDWG,
        drawings.GetCurrentOGLWParam);
    end;
  end;
end;

constructor TZInfoProgress.CreateOnTB(tb:TToolBar);
begin
  inherited Create(tb);

  ProcessBarCounter:=0;

  Align:=alLeft;
  Width:=400;
  Height:=tb.ButtonHeight;
  BorderStyle:=bsNone;
  BevelOuter:=bvNone;

  ProcessBar:=TProgressBar.Create(tb);
  ProcessBar.Hide;
  ProcessBar.Align:=alClient;
  ProcessBar.Width:=400;
  ProcessBar.Height:=tb.ButtonHeight;
  ProcessBar.min:=0;
  ProcessBar.max:=0;
  ProcessBar.step:=10000;
  ProcessBar.position:=0;
  ProcessBar.Smooth:=True;
  ProcessBar.Parent:=self;

  HintText:=TLabel.Create(tb);
  HintText.Align:=alClient;
  HintText.AutoSize:=False;
  HintText.Width:=400;
  HintText.Height:=tb.ButtonHeight;
  HintText.Layout:=tlCenter;
  HintText.Alignment:=taCenter;
  HintText.Parent:=self;

  Parent:=tb;
end;

procedure TZInfoProgress.SetText(AText:string;Force:boolean=False);
begin
  LastHintText:=AText;
end;

procedure TZInfoProgress.SetText2;
begin
  if LastHintText<>'' then begin
    if assigned(HintText) then
      HintText.Caption:=LastHintText;
    LastHintText:='';
  end;
end;

procedure TZInfoProgress.SwithToProcessBar;
begin
  Inc(ProcessBarCounter);
  if ProcessBarCounter=1 then begin
    HintText.Hide;
    ProcessBar.Show;
  end;
end;

procedure TZInfoProgress.SwithToHintText;
begin
  Dec(ProcessBarCounter);
  if ProcessBarCounter=0 then begin
    ProcessBar.Hide;
    HintText.Show;
  end;
end;

procedure TZInfoProgress.ShowProcessBar(Total:integer);
begin
  ProcessBar.max:=total;
  ProcessBar.min:=0;
  ProcessBar.position:=0;

  SwithToProcessBar;

  NextLongProcessPos:=0;
end;

procedure TZInfoProgress.ProcessProcessBar(Current:integer);
var
  LongProcessPos:integer;
begin
  LongProcessPos:=round(clientwidth*(single(current)/single(ProcessBar.max)));
  if LongProcessPos>NextLongProcessPos then begin
    ProcessBar.position:=Current;
    NextLongProcessPos:=LongProcessPos+20;
    ProcessBar.repaint;
  end;
end;

procedure TZInfoProgress.EndProcessBar;
begin
  SwithToHintText;
  ProcessBar.min:=0;
  ProcessBar.max:=0;
  ProcessBar.position:=0;
end;

procedure StatusLineTextOut(s:string);
begin
  zcMainForm.InfoProgress.SetText(s);
end;

procedure TzcMainForm.StartEntityDrag(StartX,StartY,X,Y:integer);
begin
  if commandmanager.CurrCmd.pcommandrunning=nil then begin
    //drawings.GetCurrentDWG^.wa.WaMouseMove(nil,[ssRight],StartX,StartY);
    Application.QueueAsyncCall(drawings.GetCurrentDWG^.wa.asyncsendmouse,
      (StartX and $ffff)or((StartY and $ffff) shl 16));
    commandmanager.executecommandsilent('MoveEntsByMouse',drawings.GetCurrentDWG,
      drawings.GetCurrentOGLWParam);
  end;
end;

{$ifdef windows}
procedure TzcMainForm.SetTop;
var
  hWnd{,hCurWnd, dwThreadID, dwCurThreadID}:THandle;
  OldTimeOut:DWORD;
  //AResult: Boolean;
begin
  if GetActiveWindow=Application.MainForm.Handle then Exit;
     Application.Restore;
     hWnd := {Application.Handle}Application.MainForm.Handle;
     SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
     SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     {hCurWnd := }GetForegroundWindow;
     {AResult := }SetForegroundWindow(hWnd);{в вин7 почемуто это подвисает AResult := False;
     while not AResult do
     begin
        dwThreadID := GetCurrentThreadId;
        dwCurThreadID := GetWindowThreadProcessId(hCurWnd,nil);
        AttachThreadInput(dwThreadID, dwCurThreadID, True);
        AResult := SetForegroundWindow(hWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, False);
     end;}
     SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
end;
{$endif}

procedure TzcMainForm.IPCMessage(Sender:TObject);
var
  msgstring,ts:string;
begin
  msgstring:=TSimpleIPCServer(Sender).StringMessage;
  {$ifndef windows}
  application.BringToFront;
  {$else}
  settop;
  {$endif}
  application.ProcessMessages;
  msgstring:=StringReplace(msgstring,#13,'',[rfReplaceAll]);
  repeat
    GetPartOfPath(ts,msgstring,'|');
    if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then begin
      commandmanager.executecommandtotalend;
      commandmanager.executecommand('Load('+ts+')',drawings.GetCurrentDWG,
        drawings.GetCurrentOGLWParam);
    end;
  until msgstring='';
end;

procedure TzcMainForm.setvisualprop(Sender:TObject;GUIAction:TzcMessageID);
var
  lw:integer;
  color:integer;
  layer:pgdblayerprop;
  ltype:PGDBLtypeProp;
  tstyle:PGDBTextStyle;
  dimstyle:PGDBDimStyle;
  pv:PSelectedObjDesc;
  ir:itrec;
begin
  if GUIAction<>zcMsgUIActionRebuild then
    exit;
  if drawings.GetCurrentDWG=nil then begin
    IVars.CColor:=IntEmpty;
    IVars.CLWeight:=IntEmpty;
    IVars.CLayer:=PEmpty;
    IVars.CLType:=PEmpty;
    IVars.CTStyle:=PEmpty;
    IVars.CDimStyle:=PEmpty;
    exit;
  end;
  if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0 then begin
    IVars.CColor:=sysvar.dwg.DWG_CColor^;
    IVars.CLWeight:=sysvar.dwg.DWG_CLinew^;
    IVars.CLayer:=sysvar.dwg.DWG_CLayer^;
    IVars.CLType:=sysvar.dwg.DWG_CLType^;
    IVars.CTStyle:=sysvar.dwg.DWG_CTStyle^;
    IVars.CDimStyle:=sysvar.dwg.DWG_CDimStyle^;
  end else begin
    //se:=param.seldesc.Selectedobjcount;
    lw:=IntEmpty;
    layer:=PEmpty;
    color:=IntEmpty;
    ltype:=PEmpty;
    tstyle:=PEmpty;
    dimstyle:=PEmpty;
    pv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
    //pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.objaddr<>nil then begin
          //if pv^.Selected
          //then
          begin
            if lw=IntEmpty then
              lw:=pv^.objaddr^.vp.LineWeight
            else if lw<>pv^.objaddr^.vp.LineWeight then
              lw:=IntDifferent;
            if layer=PEmpty then
              layer:=pv^.objaddr^.vp.layer
            else if layer<>pv^.objaddr^.vp.layer then
              layer:=PDifferent;
            if color=IntEmpty then
              color:=pv^.objaddr^.vp.color
            else if color<>pv^.objaddr^.vp.color then
              color:=IntDifferent;
            if ltype=PEmpty then
              ltype:=pv^.objaddr^.vp.LineType
            else if ltype<>pv^.objaddr^.vp.LineType then
              ltype:=PDifferent;
            if (pv^.objaddr^.GetObjType=GDBMTextID)or
              (pv^.objaddr^.GetObjType=GDBTextID) then begin
              if tstyle=PEmpty then
                tstyle:=PGDBObjText(pv^.objaddr)^.TXTStyle
              else if tstyle<>
                PGDBObjText(pv^.objaddr)^.TXTStyle then
                tstyle:=PDifferent;
            end;
            if (pv^.objaddr^.GetObjType=GDBAlignedDimensionID)or
              (pv^.objaddr^.GetObjType=GDBRotatedDimensionID)or
              (pv^.objaddr^.GetObjType=GDBDiametricDimensionID) then begin
              if dimstyle=PEmpty then
                dimstyle:=PGDBObjDimension(pv^.objaddr)^.PDimStyle
              else if dimstyle<>
                PGDBObjDimension(pv^.objaddr)^.PDimStyle then
                dimstyle:=PDifferent;
            end;
          end;
          if (layer=PDifferent)and(lw=IntDifferent)and
            (color=IntDifferent)and(ltype=PDifferent)and(tstyle=PDifferent)and
            (dimstyle=PDifferent) then
            system.Break;
        end;
        pv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
      until pv=nil;
    if lw<>IntEmpty then
      if lw=IntDifferent then
        ivars.CLWeight:=ClDifferent
      else begin
        ivars.CLWeight:=lw;
      end;
    if layer<>PEmpty then
      if layer=PDifferent then
        ivars.CLayer:=nil
      else begin
        ivars.CLayer:=layer;
      end;
    if color<>IntEmpty then
      if color=IntDifferent then
        ivars.CColor:=ClDifferent
      else begin
        ivars.CColor:=color;
      end;
    if ltype<>PEmpty then
      if ltype=PDifferent then
        ivars.CLType:=nil
      else begin
        ivars.CLType:=ltype;
      end;
    if tstyle<>PEmpty then begin
      if tstyle=PDifferent then
        ivars.CTStyle:=nil
      else
        ivars.CTStyle:=tstyle;
    end else
      ivars.CTStyle:=sysvar.dwg.DWG_CTStyle^;
    if dimstyle<>PEmpty then begin
      if dimstyle=PDifferent then
        ivars.CDimStyle:=nil
      else
        ivars.CDimStyle:=dimstyle;
    end else
      ivars.CDimStyle:=sysvar.dwg.DWG_CDimStyle^;
  end;
  UpdateControls;
end;

function FindIndex(taa:PTDummyMyActionsArray;l,h:integer;ca:string):integer;
var
  i:integer;
begin
  Result:=h-1;
  for i:=l to h do begin
    if assigned(taa[i]) then
      if taa[i].Caption=ca then begin
        Result:=i-1;
        system.break;
      end;
  end;
end;

procedure ScrollArray(taa:PTDummyMyActionsArray;l,h:integer);
var
  j,i:integer;
begin
  for i:=h downto l do begin
    j:=i+1;
    if (assigned(taa[j]))and(assigned(taa[i])) then
      taa[j].SetCommand(taa[i].Caption,taa[i].Command,taa[i].options);
  end;
end;

procedure CheckArray(taa:PTDummyMyActionsArray;l,h:integer);
var
  i:integer;
begin
  for i:=l to h do begin
    if assigned(taa[i]) then
      if taa[i].command='' then
        taa[i].Visible:=False
      else
        taa[i].Visible:=True;
  end;
end;

procedure SetArrayTop(taa:PTDummyMyActionsArray;_Caption,_Command,_Options:string);
begin
  if assigned(taa[0]) then
    if _Caption<>'' then
      taa[0].SetCommand(_Caption,_Command,_Options)
    else
      taa[0].SetCommand(rsEmpty,'','');
end;

procedure TzcMainForm.processfilehistory(filename:string);
var
  i,j,k:integer;
  pstr,pstrnext:PString;
begin
  k:=FindIndex(@FileHistory,low(filehistory),high(filehistory),filename);
  if k<0 then
    exit;

  ScrollArray(@FileHistory,0,k);

  for i:=k downto 0 do begin
    j:=i+1;
    pstr:=SavedUnit.FindValue('PATH_File'+IntToStr(i)).Data.Addr.Instance;
    pstrnext:=SavedUnit.FindValue('PATH_File'+IntToStr(j)).Data.Addr.Instance;
    if (assigned(pstr))and(assigned(pstrnext)) then
      pstrnext^:=pstr^;
  end;
  pstr:=SavedUnit.FindValue('PATH_File0').Data.Addr.Instance;
  if (assigned(pstr)) then
    pstr^:=filename;

  SetArrayTop(@FileHistory,FileName,'Load',FileName);
  CheckArray(@FileHistory,low(filehistory),high(filehistory));
end;

procedure TzcMainForm.processcommandhistory(Command:string);
var
  k:integer;
begin
  k:=FindIndex(@CommandsHistory,low(Commandshistory),high(Commandshistory),Command);
  if k<0 then
    exit;

  ScrollArray(@CommandsHistory,0,k);
  SetArrayTop(@CommandsHistory,Command,Command,'');
  CheckArray(@CommandsHistory,low(Commandshistory),high(Commandshistory));
end;

function IsRealyQuit:boolean;
var
  pint:PInteger;
  //mem:TZctnrVectorBytes;
  i:integer;
  dr:TZCMsgDialogResult;
  GVA:TGeneralViewArea;
begin
  Result:=False;
  if zcMainForm.PageControl<>nil then begin
    for i:=0 to zcMainForm.PageControl.PageCount-1 do begin
      GVA:=TGeneralViewArea(FindComponentByType(
        TTabSheet(zcMainForm.PageControl.Pages[i]),TGeneralViewArea));
      if {poglwnd}GVA<>nil then begin
        if {poglwnd.wa}GVA.PDWG.GetChangeStampt then
        begin
          Result:=
            True;
          system.break;
        end;
      end;
    end;

  end;
  begin
    if not Result then begin
      if drawings.GetCurrentDWG<>nil then
        //i:=zcMainForm.messagebox(@rsQuitQuery[1],@rsQuitCaption[1],MB_YESNO or MB_ICONQUESTION)
        dr:=
          zcMsgDlg(rsQuitQuery,zcdiQuestion,[zccbYes,zccbNo],False,nil,rsQuitCaption)
      else
        dr.ModalResult:=ZCmrYes;
    end else
      dr.ModalResult:=ZCmrYes;
    if dr.ModalResult=ZCmrYes then begin
      Result:=True;

          {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
          if sysvar.SYS.SYS_IsHistoryLineCreated^ then}
      begin
        pint:=SavedUnit.FindValue('DMenuX').Data.Addr.Instance;
        if assigned(pint) then
          pint^:=commandmanager.DMenu.Left;
        pint:=SavedUnit.FindValue('DMenuY').Data.Addr.Instance;
        if assigned(pint) then
          pint^:=commandmanager.DMenu.Top;

        pint:=SavedUnit.FindValue('VIEW_ObjInspSubV').Data.Addr.Instance;
        if assigned(pint) then
          if assigned(GetNameColWidthProc) then
            pint^:=GetNameColWidthProc;
        pint:=SavedUnit.FindValue('VIEW_ObjInspV').Data.Addr.Instance;
        if assigned(pint) then
          if assigned(GetOIWidthProc) then
            pint^:=GetOIWidthProc;

        if assigned(InfoForm) then
          StoreBoundsToSavedUnit('TEdWND_',InfoForm.BoundsRect);

          (*mem.init(1024);
          SavedUnit^.SavePasToMem(mem);
          mem.SaveToFile(expandpath(DataPath+'rtl'+PathDelim+'savedvar.pas'));
          mem.done;*)
      end;
    end else
      Result:=False;
  end;
end;

procedure TzcMainForm.asynccloseapp(Data:PtrInt);
begin
  CommandManager.executecommandtotalend;
  CloseApp;
end;

procedure TzcMainForm.FormClose(Sender:TObject;var CloseAction:TCloseAction);
begin
  CloseAction:=caNone;
  if not commandmanager.EndGetPoint(TGPMCloseApp) then
    Application.QueueAsyncCall(asynccloseapp,0);
end;

procedure TzcMainForm.CloseDWGPageInterf(Sender:TObject);
begin
  CloseDWGPage(Sender,False,nil);
end;

procedure TzcMainForm.PageControlMouseDown(Sender:TObject;
  Button:TMouseButton;Shift:TShiftState;X,Y:integer);
var
  i:integer;
begin
  I:=(Sender as TPageControl).IndexOfPageAt(Classes.Point(X,Y));
  if i>-1 then
    if ssMiddle in Shift then
      if (Sender is TPageControl) then begin
        CommandManager.executecommandtotalend;
        CloseDWGPage((Sender as TPageControl).Pages[I],False,nil);
      end;
end;

procedure TzcMainForm.ShowFastMenu(Sender:TObject);
begin
  ShowFMenu;
end;

procedure TzcMainForm.DockMasterCreateControl(Sender:TObject;
  aName:string;var AControl:TControl;DoDisableAutoSizing:boolean);
begin
  // first check if the form already exists
  // the LCL Screen has a list of all existing forms.
  // Note: Remember that the LCL allows as form names only standard
  // pascal identifiers and compares them case insensitive
  AControl:=Screen.FindForm(aName);
  if acontrol=nil then begin
    acontrol:=DockMaster.FindControl(aname);
  end;
  if AControl<>nil then begin
    // if it already exists, just disable autosizing if requested
    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
    exit;
  end;
  aControl:=CreateZCADControl(aName,DoDisableAutoSizing);
  {if assigned(aControl)then
  if not DoDisableAutoSizing then
                               Acontrol.EnableAutoSizing;}
end;

procedure TzcMainForm.InitSystemCalls;
begin
  //ShowAllCursorsProc:=self.ShowAllCursors;
  //RestoreAllCursorsProc:=self.RestoreCursors;
  //StartLongProcessProc:=self.StartLongProcess;
  lps.AddOnLPStartHandler(StartLongProcess);
  //ProcessLongProcessproc:=self.ProcessLongProcess;
  lps.AddOnLPProgressHandler(ProcessLongProcess);
  //EndLongProcessProc:=EndLongProcess;
  lps.AddOnLPEndHandler(EndLongProcess);
  //messageboxproc:=self.MessageBox;

  zcUI.RegisterHandler_StatusLineTextOut(StatusLineTextOut);

  zcUI.RegisterHandler_GUIAction(self.setvisualprop);
  //SetVisuaProplProc:=self.setvisualprop;
  zcUI.RegisterHandler_GUIAction(self.UpdateVisible);
  //UpdateVisibleProc:=UpdateVisible;
  ProcessFilehistoryProc:=self.processfilehistory;
  zcUI.RegisterHandler_BeforeShowModal(ShowAllCursors);
  zcUI.RegisterHandler_AfterShowModal(RestoreCursors);
  commandmanager.OnCommandRun:=processcommandhistory;
  AppCloseProc:=asynccloseapp;
  zcUI.RegisterHandler_GUIAction(self.waSetObjInsp);
  zcUI.RegisterHandler_GetFocusedControl(self.GetFocusPriority);
  {tm.Code:=pointer(self.waSetObjInsp);
  tm.Data:=@self;;
  tmethod(waSetObjInspProc):=tm;}
end;

procedure TzcMainForm.LoadActions;
var
  i:integer;
begin
  //ToolBarsManager.LoadActions(DataPath+'menu/actionscontent.xml');
  //ToolBarsManager.LoadActions(DataPath+'menu/electrotechactionscontent.xml');
  //ToolBarsManager.LoadActions(DataPath+'menu/velecactionscontent.xml');
  StandartActions.OnUpdate:=ActionUpdate;

  for i:=low(FileHistory) to high(FileHistory) do begin
    FileHistory[i]:=TmyAction.Create(self);
  end;
  for i:=low(OpenedDrawings) to high(OpenedDrawings) do begin
    OpenedDrawings[i]:=TmyAction.Create(self);
    OpenedDrawings[i].Visible:=False;
  end;
  for i:=low(CommandsHistory) to high(CommandsHistory) do begin
    CommandsHistory[i]:=TmyAction.Create(self);
    CommandsHistory[i].Visible:=False;
  end;
end;

procedure TzcMainForm.CreateInterfaceLists;
begin
  updatesbytton:=TList.Create;
  updatescontrols:=TList.Create;
  enabledcontrols:=TList.Create;
end;

procedure TzcMainForm.CreateAnchorDockingInterface;
var
  action:tmyaction;
begin
  with programlog.Enter('TZCADMainWindow.CreateAnchorDockingInterface',LM_Debug,LMD) do
  begin
    try
      {Настройка DragManager чтоб срабатывал попозже}
      DragManager.DragImmediate:=False;
      DragManager.DragThreshold:=32;

      {Наполняем статусную строку}
      ToolBarD.Images:=ImagesManager.IconList;
      ToolBarD.ButtonHeight:=sysvar.INTF.INTF_DefaultControlHeight^;
      CreateHTPB(ToolBarD);//поле отображения координат progressbar
      ToolBarsManager.AddContentToToolbar(ToolBarD,'Status');
      //переносим туда то что есть на тулбаре 'Status'

      {Запрещаем влючать-выключать тулбар 'Status', он показывается всегда}
      action:=tmyaction(StandartActions.ActionByName(ToolBarNameToActionName('Status')));
      if assigned(action) then begin
        action.Enabled:=False;
        action.Checked:=True;
        action.pfoundcommand:=nil;
        action.command:='';
        action.options:='';
      end;

      {Создаем на ToolBarD переключатель рабочих пространств}
  {if assigned(LayoutBox) then
    zcUI.TextMessage(format(rsReCreating,['LAYOUTBOX']),TMWOShowError);
  CreateLayoutbox(ToolBarD);
  LayoutBox.Parent:=ToolBarD;
  LayoutBox.AutoSize:=false;
  LayoutBox.Width:=200;
  LayoutBox.Align:=alRight;}


      {Наcтраиваем докинг}
      {$IF lcl_fullversion>2001200}
      DockMaster.FloatingWindowsOnTop:=True;
      DockMaster.MainDockForm:=Self;
      {$ENDIF}
      DockMaster.ManagerClass:=TAnchorDockManager;
      DockMaster.OnCreateControl:=DockMasterCreateControl;
      {Делаем DockPanel докабельной}
      DockMaster.MakeDockPanel(DockPanel,admrpChild);
      HardcodedButtonSize:=21;
      {Грузим раскладку окон}
      if not ZCSysParams.saved.noloadlayout then
        LoadLayout_com(TZCADCommandContext.CreateRec,EmptyCommandOperands);

      if ZCSysParams.saved.noloadlayout then begin
        DockMaster.ShowControl('CommandLine',True);
        DockMaster.ShowControl('ObjectInspector',True);
        DockMaster.ShowControl('PageControl',True);
      end;
    finally
      programlog.leave(IfEntered);
    end;
  end;
end;

procedure TzcMainForm.ZcadException(Sender:TObject;E:Exception);
var
  crashreportfilename,errmsg:string;
begin
  ProcessException(Sender,RaiseList);

  crashreportfilename:=GetCrashReportFilename;
  errmsg:=programname+' raised exception class "'+E.Message+
    '"'#13#10#13#10'A crash report generated (stack trace and latest log).'#13#10'Please send "'+crashreportfilename+
    '" file at zamtmn@yandex.ru'#13#10#13#10'Attempt to continue running?';

  if zcMsgDlg(errmsg,zcdiError,[zccbYes,zccbCancel]).ModalResult=ZCmrCancel then
    halt(0);
end;

function TzcMainForm.CreateZCADControl(aName:string;
  DoDisableAutoSizing:boolean=False):TControl;
var
  ta:TmyAction;
  PFID:PTFormInfoData;
begin
  ta:=tmyaction(StandartActions.ActionByName('ACN_Show_'+aname));
  if ta<>nil then
    ta.Checked:=True;
  if pos(ToolPaletteNamePrefix,uppercase(aname))=1 then begin
    Result:=ToolBarsManager.CreateToolPalette(aName,DoDisableAutoSizing);
  end else if ZCADGUIManager.GetZCADFormInfo(aname,PFID) then begin
    //    aname:=aname;
    if assigned(PFID^.CreateProc) then
      Result:=PFID^.CreateProc(aname)
    else begin
      Result:=TForm(PFID^.FormClass.NewInstance);
      TObject(PFID.PInstanceVariable^):=Result;
    end;
    if DoDisableAutoSizing then
      if Result is TWinControl then
        TWinControl(Result).DisableAutoSizing;
    if Result is TCustomForm then begin
      if PFID^.DesignTimeForm then
        TCustomForm(Result).Create(Application)
      else
        TCustomForm(Result).CreateNew(Application);
    end;
    //tobject(PFID.PInstanceVariable^):=result;
    Result.Caption:=PFID.FormCaption;
    Result.Name:=aname;
    if @PFID.SetupProc<>nil then
      PFID.SetupProc(Result);
  end else begin
    //tbdesk:=self.findtoolbatdesk(aName);
    //if tbdesk=''then
    zcUI.TextMessage(format(rsFormNotFound,[aName]),TMWOShowError);
    Result:=nil;
  end;
end;


procedure ZCADMainPanelSetupProc(Form:TControl);
begin
  TForm(Form).BorderWidth:=0;

  zcMainForm.DHPanel:=TPanel.Create(TForm(Form));
  zcMainForm.DHPanel.Align:=albottom;
  zcMainForm.DHPanel.BevelInner:=bvNone;
  zcMainForm.DHPanel.BevelOuter:=bvNone;
  zcMainForm.DHPanel.BevelWidth:=1;
  zcMainForm.DHPanel.AutoSize:=True;
  zcMainForm.DHPanel.Parent:=zcMainForm.MainPanel;

  zcMainForm.VScrollBar:=TScrollBar.Create(zcMainForm.MainPanel);
  zcMainForm.VScrollBar.Align:=alright;
  zcMainForm.VScrollBar.kind:=sbVertical;
  zcMainForm.VScrollBar.OnScroll:=zcMainForm._scroll;
  zcMainForm.VScrollBar.Enabled:=False;
  zcMainForm.VScrollBar.Parent:=zcMainForm.MainPanel;

  with TMySpeedButton.Create(zcMainForm.DHPanel) do begin
    Align:=alRight;
    Parent:=zcMainForm.DHPanel;
    Width:=zcMainForm.VScrollBar.Width;
    onclick:=zcMainForm.ShowFastMenu;
  end;

  zcMainForm.HScrollBar:=TScrollBar.Create(zcMainForm.DHPanel);
  zcMainForm.HScrollBar.Align:=alClient;
  zcMainForm.HScrollBar.kind:=sbHorizontal;
  zcMainForm.HScrollBar.OnScroll:=zcMainForm._scroll;
  zcMainForm.HScrollBar.Enabled:=False;
  zcMainForm.HScrollBar.Parent:=zcMainForm.DHPanel;

  InitializeViewAreaCXMenu(zcMainForm,StandartActions);
  zcMainForm.PageControl:=TmyPageControl.Create(zcMainForm.MainPanel);
  zcMainForm.PageControl.Constraints.MinHeight:=32;
  zcMainForm.PageControl.Parent:=zcMainForm.MainPanel;
  zcMainForm.PageControl.Align:=alClient;
  zcMainForm.PageControl.OnChange:=zcMainForm.ChangedDWGTabByClick;
  zcMainForm.PageControl.BorderWidth:=0;
  if assigned(SysVar.INTF.INTF_DwgTabsPosition) then begin
    case SysVar.INTF.INTF_DwgTabsPosition^ of
      TATop:
        zcMainForm.PageControl.TabPosition:=tpTop;
      TABottom:
        zcMainForm.PageControl.TabPosition:=tpBottom;
      TALeft:
        zcMainForm.PageControl.TabPosition:=tpLeft;
      TARight:
        zcMainForm.PageControl.TabPosition:=tpRight;
    end;
  end;

  if assigned(SysVar.INTF.INTF_ThemedUpToolbars) then
    zcMainForm.CoolBarU.Themed:=SysVar.INTF.INTF_ThemedUpToolbars^;
  if assigned(SysVar.INTF.INTF_ThemedRightToolbars) then
    zcMainForm.CoolBarR.Themed:=SysVar.INTF.INTF_ThemedRightToolbars^;
  if assigned(SysVar.INTF.INTF_ThemedDownToolbars) then
    zcMainForm.CoolBarD.Themed:=SysVar.INTF.INTF_ThemedDownToolbars^;
  if assigned(SysVar.INTF.INTF_ThemedLeftToolbars) then
    zcMainForm.CoolBarL.Themed:=SysVar.INTF.INTF_ThemedLeftToolbars^;

  if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then begin
    if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
      zcMainForm.PageControl.Options:=
        zcMainForm.PageControl.Options+[nboShowCloseButtons]
    else
      zcMainForm.PageControl.Options:=
        zcMainForm.PageControl.Options-[nboShowCloseButtons];
  end else
    zcMainForm.PageControl.Options:=[nboShowCloseButtons];
  zcMainForm.PageControl.OnCloseTabClicked:=zcMainForm.CloseDWGPageInterf;
  zcMainForm.PageControl.OnMouseDown:=zcMainForm.PageControlMouseDown;
  zcMainForm.PageControl.ShowTabs:=SysVar.INTF.INTF_ShowDwgTabs^;

  zcMainForm.AllowDropFiles:=True;
  zcMainForm.OnDropFiles:=zcMainForm.DropFiles;
end;

procedure SetupFIPCServer;
begin
  if assigned(UniqueInstanceBase.FIPCServer) then
    UniqueInstanceBase.FIPCServer.OnMessage:=zcMainForm.IPCMessage;
end;

function CreateOrRunFIPCServer:boolean;
var
  Client:TSimpleIPCClient;
begin
  Result:=False;

  Client:=TSimpleIPCClient.Create(nil);
  with Client do
  try
    ServerId:=GetServerId(zcaduniqueinstanceid);
    Result:=Client.ServerRunning;
  finally
    Free;
  end;

  if Result then
    exit;

  if not assigned(UniqueInstanceBase.FIPCServer) then
    Result:=InstanceRunning(zcaduniqueinstanceid,True,True);
  if not UniqueInstanceBase.FIPCServer.Active then
    UniqueInstanceBase.FIPCServer.StartServer;
  SetupFIPCServer;
end;

procedure RunCmdFile(const filename:string;pdata:pointer);
begin
  commandmanager.executefile(filename,drawings.GetCurrentDWG,nil);
end;

procedure TzcMainForm._onCreate(Sender:TObject);
begin
  with programlog.Enter('TZCADMainWindow._onCreate',LM_Debug,LMD) do begin
    try
      ZCADGUIManager.RegisterZCADFormInfo('PageControl',rsDrawingWindowWndName,
        TForm,types.rect(200,200,600,500),ZCADMainPanelSetupProc,nil,@zcMainForm.MainPanel);

      TZGuiExceptionsHandler.InstallHandler(ZcadException);

      SuppressedShortcuts:=TXMLConfig.Create(nil);
      SuppressedShortcuts.Filename:=
        ConcatPaths([GetRoCfgsPath,CFScomponentsDir,CFSsuppressedshortcutsxmlFile]);

      if ZCSysParams.saved.UniqueInstance then
        CreateOrRunFIPCServer;
      if sysvar.INTF.INTF_DefaultControlHeight<>nil then
        sysvar.INTF.INTF_DefaultControlHeight^:=ZCSysParams.notsaved.defaultheight;

      //DecorateSysTypes;
      self.onclose:=self.FormClose;
      self.OnKeyDown:=self.myKeyDown;
      self.KeyPreview:=True;
      application.OnIdle:=self.idle;
      SystemTimer:=TTimer.Create(self);
      SystemTimer.Interval:=1000;
      SystemTimer.Enabled:=True;
      SystemTimer.OnTimer:=self.generaltick;

      InitSystemCalls;

      ImagesManager.ScanDir(ConcatPaths([expandpath('$(DistribPath)'),CFSimagesDir]));
      ImagesManager.LoadAliasesDir(
        ConcatPaths([expandpath('$(DistribPath)'),CFSimagesDir,CFSnavigatorimaFile]));

      //StandartActions:=TActionList.Create(self);
      InsertComponent(StandartActions);

      if not assigned(StandartActions.Images) then
        StandartActions.Images:=
          {TImageList.Create(StandartActions)}ImagesManager.IconList;
      brocenicon:=ImagesManager.DefaultImageIndex;


      ToolBarsManager.setup(self,StandartActions,sysvar.INTF.INTF_DefaultControlHeight^);
      MenusManager.setup(self,StandartActions);
      RegisterGeneralContextCheckFunc('True',@GMCCFTrue);
      RegisterGeneralContextCheckFunc('False',@GMCCFFalse);
      RegisterGeneralContextCheckFunc('CtrlPressed',@GMCCFCtrlPressed);
      RegisterGeneralContextCheckFunc('ShiftPressed',@GMCCFShiftPressed);
      RegisterGeneralContextCheckFunc('AltPressed',@GMCCFAltPressed);
      RegisterGeneralContextCheckFunc('ActiveDrawing',@GMCCFActiveDrawing);
      RegisterGeneralContextCheckFunc('DebugUI',@GMCCFDebugUI);

      LoadActions;
      toolbars:=TStringList.Create;
      toolbars.Sorted:=True;
      CreateInterfaceLists;

      FromDirsIterator(sysvar.PATH.Preload_Paths^,'*.cmd0','stage0.cmd0',RunCmdFile,nil);

      CreateAnchorDockingInterface;
      zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
      MouseTimer:=TMouseTimer.Create;
      SetupFIPCServer;
      fNeedUpdateMainMenu:=True;
      DoUpdateMainMenu;
    finally
      programlog.leave(IfEntered);
    end;
  end;
end;

procedure TzcMainForm.UpdateControls;
var
  i:integer;
begin
  if assigned(updatesbytton) then
    for i:=0 to updatesbytton.Count-1 do begin
      TmyVariableToolButton(updatesbytton[i]).AssignToVar(
        TmyVariableToolButton(updatesbytton[i]).FVariable,TmyVariableToolButton(
        updatesbytton[i]).FMask);
    end;
  if assigned(updatescontrols) then
    for i:=0 to updatescontrols.Count-1 do begin
      TControl(updatescontrols[i]).Invalidate;
    end;
end;

procedure TzcMainForm.EnableControls(enbl:boolean);
var
  i:integer;
begin
  if assigned(enabledcontrols) then
    for i:=0 to enabledcontrols.Count-1 do
      if TObject(enabledcontrols[i]) is TControl then
        (TObject(enabledcontrols[i]) as TControl).Enabled:=enbl;
end;

procedure TzcMainForm.ChangedDWGTab(Sender:TObject);
var
  ogl:TAbstractViewArea;
begin
  TComponent(OGL):=FindComponentByType(TPageControl(Sender).ActivePage,
    TAbstractViewArea);
  if assigned(OGL) then
    OGL.GDBActivate;
  OGL.param.firstdraw:=True;
  OGL.draworinvalidate;
  zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
end;

procedure TzcMainForm.ChangedDWGTabByClick(Sender:TObject);
begin
  commandmanager.executecommandend;
  ChangedDWGTab(Sender);
end;

destructor TzcMainForm.Destroy;
begin
  with programlog.Enter('TZCADMainWindow.Destroy',LM_Debug,LMD) do begin
    RemoveComponent(StandartActions);
    if DockMaster<>nil then
      DockMaster.CloseAll;
    FreeAndNil(toolbars);
    FreeAndNil(updatesbytton);
    FreeAndNil(updatescontrols);
    FreeAndNil(enabledcontrols);
    FreeAndNil(SuppressedShortcuts);
    inherited;
    programlog.leave(IfEntered);
  end;
  MouseTimer.Destroy;
end;

procedure TzcMainForm.ActionUpdate(AAction:TBasicAction;var Handled:boolean);
var
  _disabled:boolean;
  ctrl:TControl;
  ti:integer;
  POGLWndParam:POGLWndtype;
  PSimpleDrawing:PTSimpleDrawing;
begin
  with programlog.Enter('TZCADMainWindow.ActionUpdate',LM_Debug,LMD) do begin
    try
      if AAction is TmyAction then begin
        Handled:=True;
        if uppercase(TmyAction(AAction).command)='SHOWPAGE' then
          if uppercase(TmyAction(AAction).options)<>'' then begin
            if assigned(zcMainForm) then
              if assigned(zcMainForm.PageControl) then
                if zcMainForm.PageControl.ActivePageIndex=StrToInt(
                  TmyAction(AAction).options) then
                  TmyAction(AAction).Checked:=True
                else
                  TmyAction(AAction).Checked:=False;
            //programlog.leave(IfEntered);
            exit;
          end;

        if uppercase(TmyAction(AAction).command)='SHOW' then
          if uppercase(TmyAction(AAction).options)<>'' then begin
            ctrl:=DockMaster.FindControl(TmyAction(AAction).options);
            if ctrl=nil then begin
              if toolbars.Find(TmyAction(AAction).options,ti) then
                TmyAction(AAction).Enabled:=False;
            end else begin
              TmyAction(AAction).Enabled:=True;
              TmyAction(AAction).Checked:=ctrl.IsVisible;
            end;
            //programlog.leave(IfEntered);
            exit;
          end;

        _disabled:=False;
        PSimpleDrawing:=drawings.GetCurrentDWG;
        POGLWndParam:=nil;
        if PSimpleDrawing<>nil then
          if PSimpleDrawing.wa<>nil then
            POGLWndParam:=@PSimpleDrawing.wa.param;
        if assigned(TmyAction(AAction).pfoundcommand) then begin
          if ((GetCommandContext(PSimpleDrawing,POGLWndParam) xor
            TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)  and
            TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)<>0 then
            _disabled:=True;
          TmyAction(AAction).Enabled:=not _disabled;
        end;
      end else if AAction is TmyVariableAction then begin
        Handled:=True;
        TmyVariableAction(AAction).AssignToVar(TmyVariableAction(
          AAction).FVariable,TmyVariableAction(AAction).FMask);
      end;
    finally
      programlog.leave(IfEntered);
    end;
  end;
end;

function TzcMainForm.IsShortcut(var Message:TLMKey):boolean;
var
  OldFunction:TIsShortcutFunc;
begin
  if Message.CharCode<>17 then begin
    Message.CharCode:=Message.CharCode+1;
    Message.CharCode:=Message.CharCode-1;
  end;
  with programlog.Enter('TZCADMainWindow.IsShortcut',LM_Debug,LMD) do begin
    TMethod(OldFunction).code:=@TForm.IsShortcut;
    TMethod(OldFunction).Data:=self;
    Result:=CommandManager.ProcessCommandShortcuts(LMKey2ShortCut(Message));
    if not Result then
      Result:=IsZShortcut(Message,Screen.ActiveControl,zcUI.GetPriorityFocus,
        OldFunction,SuppressedShortcuts);
    programlog.leave(IfEntered);
  end;
end;

procedure TzcMainForm.myKeyDown(Sender:TObject;var Key:word;Shift:TShiftState);
var
  tempkey:word;
  comtext:string;
  needinput:boolean;
begin
  with programlog.Enter('TZCADMainWindow.myKeyDown',LM_Debug,LMD) do begin
    try
      zcUI.Do_KeyDown(Sender,Key,Shift);
      if key=0 then begin
        //programlog.leave(IfEntered);
        exit;
      end;

      if ((ActiveControl<>cmdedit)and
        (ActiveControl<>HistoryLine){and(ActiveControl<>LayerBox)and(ActiveControl<>LineWBox)}) then
      begin
        if (ActiveControl is TCustomEdit)or (ActiveControl is TCustomMemo)or
          (ActiveControl is TCustomComboBox) then begin
          //programlog.leave(IfEntered);
          exit;
        end;
     {if assigned(GetPeditorProc) then
     if (GetPeditorProc)<>nil then
     if (ActiveControl=TPropEditor(GetPeditorProc).geteditor) then
                                                            exit;}
      end;
    { if ((ActiveControl=LayerBox)or(ActiveControl=LineWBox))then
                                                                 begin
                                                                 zcUI.Do_SetNormalFocus;
                                                                 end;}
      tempkey:=key;

      comtext:='';
      needinput:=False;
      if commandmanager.CurrCmd.pcommandrunning<>nil then
        if (commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode=TGPMWaitInput)and
          (key<>VK_ESCAPE) then
          needinput:=True;
      if assigned(cmdedit) then
        comtext:=cmdedit.Text;
      if (comtext='') and (not needinput) then begin
        if assigned(drawings.GetCurrentDWG) then
          if assigned(drawings.GetCurrentDWG.wa) then
            if assigned(drawings.GetCurrentDWG.wa.getviewcontrol) then
              drawings.GetCurrentDWG.wa.myKeyPress(tempkey,shift);
      end else if key=VK_ESCAPE then
        cmdedit.Text:='';
      if tempkey<>0 then begin
        if (tempkey=VK_TAB)and(shift=[ssctrl,ssShift]) then begin
          if assigned(PageControl) then
            if PageControl.PageCount>1 then begin
              commandmanager.executecommandsilent(
                'DWGPrev',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
              tempkey:=00;
            end;
        end else if (tempkey=VK_TAB)and(shift=[ssctrl]) then begin
          if assigned(PageControl) then
            if PageControl.PageCount>1 then begin
              commandmanager.executecommandsilent(
                'DWGNext',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
              tempkey:=0;
            end;
        end;
      end;
      if assigned(cmdedit) then
        if tempkey<>0 then begin
          tempkey:=key;
          if cmdedit.Text='' then begin
          end;
        end;
      if tempkey=0 then
        key:=0;
    finally
      programlog.leave(IfEntered);
    end;
  end;
end;

procedure TzcMainForm.CreateHTPB(tb:TToolBar);
begin
  InfoProgress:=TZInfoProgress.CreateOnTB(tb);
end;

procedure TzcMainForm.idle(Sender:TObject;var Done:boolean);
var
  pdwg:PTSimpleDrawing;
  rc:TDrawContext;
begin
  with programlog.Enter('TZCADMainWindow.idle',LM_Debug,LMD) do begin
    try

      InfoProgress.SetText2;

      DoUpdateMainMenu;

      {IFDEF linux}
      if assigned(UniqueInstanceBase.FIPCServer) then
        if UniqueInstanceBase.FIPCServer.active then
          UniqueInstanceBase.FIPCServer.PeekMessage(0,True);
      {endif}
      done:=True;
      sysvar.debug.languadedeb.UpdatePO:=_UpdatePO;
      sysvar.debug.languadedeb.NotEnlishWord:=_NotEnlishWord;
      sysvar.debug.languadedeb.DebugWord:=_DebugWord;
      pdwg:=drawings.GetCurrentDWG;
      if (pdwg<>nil)and(pdwg.wa<>nil) then begin
        if pdwg.wa.getviewcontrol<>nil then begin
          if pdwg.pcamera.DRAWNOTEND then begin
            rc:=pdwg.CreateDrawingRC;
            pdwg.wa.finishdraw(rc);
            done:=False;
          end else begin
            pdwg.wa.idle(Sender,Done);
          end;
        end;
      end else
        SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
      if pdwg<>nil then
        if not pdwg^.GetChangeStampt then
          SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
      if (SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and
        (commandmanager.CurrCmd.pcommandrunning=nil) then
        if (pdwg)<>nil then
          if (pdwg.wa.param.SelDesc.Selectedobjcount=0) then begin
            commandmanager.executecommandsilent(
              'QSave(QS)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
            SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
          end;
      date:=SysUtils.date;
      if RunTime<>SysVar.SYS.SYS_RunTime^ then begin
        zcUI.Do_GUIaction(self,zcMsgUITimerTick);
      {if assigned(UpdateObjInspProc)then
         UpdateObjInspProc;}
      end;
      RunTime:=SysVar.SYS.SYS_RunTime^;
      if ZCStatekInterface.CheckAndResetState(ZCSGUIChanged) then
        zcUI.Do_SetNormalFocus;
    {if historychanged then begin
      historychanged:=false;
      HistoryLine.SelStart:=utflen;
      HistoryLine.SelLength:=2;
      HistoryLine.ClearSelection;
    end;}
    finally
      programlog.leave(IfEntered);
    end;
  end;
end;

procedure AddToComboIfNeed(cb:tcombobox;Name:string;obj:TObject);
var
  i:integer;
begin
  for i:=0 to cb.Items.Count-1 do
    if cb.Items.Objects[i]=obj then
      exit;
  cb.items.InsertObject(cb.items.Count-1,Name,obj);
end;

procedure TzcMainForm.GeneralTick(Sender:TObject);
begin
  if sysvar.SYS.SYS_RunTime<>nil then begin
    Inc(sysvar.SYS.SYS_RunTime^);
    if SysVar.SAVE.SAVE_Auto_On^ then
      Dec(sysvar.SAVE.SAVE_Auto_Current_Interval^);
  end;
end;

procedure TzcMainForm.StartLongProcess(LPHandle:TLPSHandle;Total:TLPSCounter;
  processname:TLPName;Options:TLPOpt);
begin
  if (Options and LPSONoProgressBar)=0 then
    InfoProgress.ShowProcessBar(Total);
end;

procedure TzcMainForm.ProcessLongProcess(LPHandle:TLPSHandle;
  Current:TLPSCounter;Options:TLPOpt);
begin
  if (Options and LPSONoProgressBar)=0 then
    InfoProgress.ProcessProcessBar(Current);
end;

procedure TzcMainForm.ShowAllCursors;
begin
  if drawings.GetCurrentDWG<>nil then
    if drawings.GetCurrentDWG.wa<>nil then
      drawings.GetCurrentDWG.wa.showmousecursor;
end;

procedure TzcMainForm.RestoreCursors;
begin
  if drawings.GetCurrentDWG<>nil then
    if drawings.GetCurrentDWG.wa<>nil then
      drawings.GetCurrentDWG.wa.hidemousecursor;
end;

procedure TzcMainForm.EndLongProcess;
var
  TimeStr,LPName:string;
begin
  if (Options and LPSONoProgressBar)=0 then
    InfoProgress.EndProcessBar;

  str(TotalLPTime*10e4:3:2,TimeStr);
  LPName:=lps.getLPName(LPHandle);

  if (not lps.hasOptions(LPHandle,LPSOSilent))and(not CommandManager.isBusy)and
    ((Options and LPSOSilent)=0) then begin
    if (LPName='') then
      zcUI.TextMessage(format(rscompiledtimemsg,[TimeStr]),[TMWOToConsole])
    else
      zcUI.TextMessage(format(rsprocesstimemsg,[LPName,TimeStr]),[TMWOToConsole]);
  end;
end;

procedure TzcMainForm.MainMouseMove;
begin
  cxmenumgr.reset;
end;

function TzcMainForm.MainMouseDown(Sender:TAbstractViewArea):boolean;
begin
  zcUI.Do_SetNormalFocus;
  //if @SetCurrentDWGProc<>nil then
  SetCurrentDWG{Proc}(Sender.PDWG);
  if (cxmenumgr.ismenupopup)or(ActivePopupMenu<>nil) then
    Result:=True
  else
    Result:=False;
end;

procedure TzcMainForm.MainMouseUp;
begin
  //if assigned(GetCurrentObjProc) then
  //if GetCurrentObjProc=@sysvar then
     {If assigned(UpdateObjInspProc)then
                                      UpdateObjInspProc;}
  //zcUI.Do_GUIaction(self,zcMsgUIActionRedraw);
  zcUI.Do_SetNormalFocus;
end;

procedure TzcMainForm.ShowCXMenu;
var
  menu:TPopupMenu;
begin
  menu:=nil;
  menu:=ViewAreaContextMenuManager.GetPopupMenu('VIEWAREACXMENU',
    CreateViewAreaContext(drawings.GetCurrentDWG.wa),ViewAreaMacros);
  if menu<>nil then begin
    menu.PopUp;
  end;
end;

procedure TzcMainForm.ShowFMenu;
var
  menu:TPopupMenu;
begin
  menu:=MenusManager.GetPopupMenu('FASTMENU',nil);
  if menu<>nil then begin
    menu.PopUp;
  end;
end;


procedure TzcMainForm._scroll(Sender:TObject;ScrollCode:TScrollCode;
  var ScrollPos:integer);
var
  pdwg:PTSimpleDrawing;
  nevpos:TzePoint3d;
begin
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
    if pdwg.wa.getviewcontrol<>nil then begin
      nevpos:=PDWG.Getpcamera^.prop.point;
      if Sender=HScrollBar then begin
        nevpos.x:=-ScrollPos;
      end else if Sender=VScrollBar then begin
        nevpos.y:=-(VScrollBar.Min+VScrollBar.Max{$IFNDEF LINUX}-
          VScrollBar.PageSize{$ENDIF}-ScrollPos);
      end;
      pdwg.wa.SetCameraPosZoom(nevpos,PDWG.Getpcamera^.prop.zoom,True);
      pdwg.wa.draworinvalidate;
    end;
end;

procedure TzcMainForm.wamm(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer);
var
  f:TzeUnitsFormat;
  htext,htext2:string;
begin
  MouseTimer.Touch(Point(X,Y),[TMouseTimer.TReason.RMMove]);
  if Sender.param.SelDesc.OnMouseObject<>nil then begin
    if
    PGDBObjEntity(Sender.param.SelDesc.OnMouseObject)^.vp.Layer._lock
    then
      Sender.
        getviewcontrol.Cursor:=crNoDrop
    else begin
      {if assigned(SysVarDISPRemoveSystemCursorFromWorkArea)
      then}
      RemoveCursorIfNeed(
        Sender.getviewcontrol,(SysVarDISPRemoveSystemCursorFromWorkArea)and
        ((Sender.param.md.mode and not(MNone or MMoveCamera or MRotateCamera))<>0));
      {else
        RemoveCursorIfNeed(getviewcontrol,true)}
    end;
  end
  else if not Sender.param.scrollmode then begin
    {if assigned(SysVarDISPRemoveSystemCursorFromWorkArea)
    then}
    RemoveCursorIfNeed(
      Sender.getviewcontrol,(SysVarDISPRemoveSystemCursorFromWorkArea)and
      ((Sender.param.md.mode and not(MNone or MMoveCamera or MRotateCamera))<>0));
    {else
        RemoveCursorIfNeed(getviewcontrol,true)}
  end;
  //exclude(shift,ssLeft);
  ZC:=ZC and (not MZW_LBUTTON);
  if (Sender.param.md.mode and (MGet3DPoint or MGet3DPointWoOp))<>0 then
    commandmanager.sendmousecoordwop(Sender,{MouseBS2ZKey(shift)}ZC);

  f:=Sender.pdwg^.GetUnitsFormat;
  htext:=SysUtils.Format('%s, %s, %s',[zeDimensionToString(
    Sender.param.md.mouse3dcoord.x,f),zeDimensionToString(
    Sender.param.md.mouse3dcoord.y,f),zeDimensionToString(
    Sender.param.md.mouse3dcoord.z,f)]);
  if Sender.param.polarlinetrace=1 then begin
    htext2:=SysUtils.Format(
      'L=%s',[zeDimensionToString(Sender.param.ontrackarray.otrackarray[
      Sender.param.pointnum].tmouse,f)]);
    htext:=SysUtils.Format('%s (%s)',[htext,htext2]);
    Sender.getviewcontrol.Hint:=htext2;

    Application.ActivateHint(Sender.getviewcontrol.ClientToScreen(
      Classes.Point(Sender.param.md.mouse.x,Sender.param.md.mouse.y)));
  end;
  zcUI.TextMessage(htext,TMWOQuickly);
end;

function TzcMainForm.wamu(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer;
  onmouseobject:Pointer;var NeedRedraw:boolean):boolean;
begin
  Result:=False;
  MouseTimer.Touch(Point(X,Y),[TMouseTimer.TReason.RMUp]);
end;

function TzcMainForm.wamd(Sender:TAbstractViewArea;ZC:TZKeys;X,Y:integer;
  onmouseobject:Pointer;var NeedRedraw:boolean):boolean;
var
  //key:Byte;
  FreeClick:boolean;
  mp:TPoint;

  function ProcessControlpoint:boolean;
  begin
    begin
      //key := MouseBS2ZKey(shift);
      Result:=False;
      if Sender.param.gluetocp then begin
        Sender.PDWG.GetSelObjArray.selectcurrentcontrolpoint(
          zc,Sender.param.md.mouseglue.x,Sender.param.md.mouseglue.y,Sender.param.Height);
        Result:=True;
        if (zc and MZW_SHIFT)=0 then begin
          Sender.param.startgluepoint:=Sender.param.nearesttcontrolpoint.pcontrolpoint;
          commandmanager.ExecuteCommandSilent('OnDrawingEd',Sender.pdwg,@Sender.param);
          if commandmanager.CurrCmd.pcommandrunning<>nil then begin
            if (zc and MZW_LBUTTON)<>0{zc=MZW_LBUTTON} then
              Sender.param.lastpoint:=
                Sender.param.nearesttcontrolpoint.pcontrolpoint^.worldcoord;
            commandmanager.CurrCmd.pcommandrunning^.MouseMoveCallback(
              CommandManager.CurrCmd.Context,
              Sender.param.nearesttcontrolpoint.pcontrolpoint^.worldcoord,
              Sender.param.md.mouseglue,
              zc,nil);
          end;
        end;
      end;
    end;
  end;

  function ProcessEntSelect:boolean;
    //var
    //    RelSelectedObjects:Integer;
  begin
    Result:=False;
    //key := MouseBS2ZKey(shift);
    begin
      Sender.getonmouseobjectbytree(Sender.PDWG.GetCurrentROOT.ObjArray.ObjTree,
        sysvarDWGEditInSubEntry);
      //getonmouseobject(@drawings.GetCurrentROOT.ObjArray);
      if ((zc and MZW_CONTROL)<>0)and((zc and MZW_RBUTTON)<>0) then begin
        commandmanager.ExecuteCommandSilent('SelectOnMouseObjects',
          Sender.pdwg,@Sender.param);
        Result:=True;
      end else if (zc and MZW_LBUTTON)<>0 then begin
    {//Выделение всех объектов под мышью
    if drawings.GetCurrentDWG.OnMouseObj.Count >0 then
    begin
         pobj:=drawings.GetCurrentDWG.OnMouseObj.beginiterate(ir);
         if pobj<>nil then
         repeat
               pobj^.select;
               wa.param.SelDesc.LastSelectedObject := pobj;
               pobj:=drawings.GetCurrentDWG.OnMouseObj.iterate(ir);
         until pobj=nil;
      addoneobject;
      SetObjInsp;
    end}

        //Выделение одного объекта под мышью
        if Sender.param.SelDesc.OnMouseObject<>nil then begin
          Result:=True;
          if (zc and MZW_SHIFT)=0 then begin
            if (not PGDBObjEntity(Sender.param.SelDesc.OnMouseObject).Selected)and
              (sysvarDSGNSelNew)and((zc and MZW_CONTROL)=0) then begin
              Sender.pdwg.GetCurrentROOT.ObjArray.DeSelect(
                Sender.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.DeSelector);
              Sender.param.SelDesc.LastSelectedObject:=nil;
              Sender.param.seldesc.Selectedobjcount:=0;
              Sender.PDWG^.GetSelObjArray.Free;
            end;
            Sender.param.SelDesc.LastSelectedObject:=Sender.param.SelDesc.OnMouseObject;
            if assigned(Sender.OnWaMouseSelect) then
              Sender.OnWaMouseSelect(Sender,Sender.param.SelDesc.LastSelectedObject);
          end else begin
            PGDBObjEntity(Sender.param.SelDesc.OnMouseObject)^.DeSelect(
              Sender.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
            Sender.param.SelDesc.LastSelectedObject:=nil;
            zcUI.Do_GUIaction(Sender,zcMsgUIActionSelectionChanged);
            zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
          end;
          if commandmanager.CurrCmd.pcommandrunning<>nil then
            if commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode=TGPMWaitEnt then
              if Sender.param.SelDesc.LastSelectedObject<>nil then
                commandmanager.CurrCmd.pcommandrunning^.IData.GetPointMode:=TGPMEnt;
          NeedRedraw:=True;
        end else if ((Sender.param.md.mode and MGetSelectionFrame)<>0) and
          ((zc and MZW_LBUTTON)<>0) then begin
          Result:=True;
          { TODO : Добавить возможность выбора объектов без секрамки во время выполнения команды }
          commandmanager.ExecuteCommandSilent('SelectFrame',Sender.pdwg,@Sender.param);
          commandmanager.sendmousecoord(Sender,MZW_LBUTTON);
        end;
      end;
    end;
  end;

begin
  mp:=Point(X,Y);
  MouseTimer.Touch(mp,[TMouseTimer.TReason.RMDown]);
  zcUI.Do_GUIaction(nil,zcMsgUIStoreAndFreeEditorProc);
  //key := MouseBS2ZKey(shift);
  if (MZW_DOUBLE and zc)<>0 {ssDouble in shift} then begin
    if (MZW_MBUTTON and zc)<>0{mbMiddle=button} then begin
      if (MZW_SHIFT and zc)<>0{ssShift in shift} then
        Application.QueueAsyncCall(Sender.asynczoomsel,0)
      else
        Application.QueueAsyncCall(Sender.asynczoomall,0);
      exit(True);
    end;
    if (MZW_LBUTTON and zc)<>0{mbLeft=button} then begin
      if assigned(OnMouseObject) then
        if (PGDBObjEntity(OnMouseObject).GetObjType=GDBtextID)  or
          (PGDBObjEntity(OnMouseObject).GetObjType=GDBMTextID) then begin
          RunTextEditor(OnMouseObject,Sender.PDWG^);
        end;
      exit(True);
    end;
  end;

  FreeClick:=True;

  if (MZW_LBUTTON and zc)<>0 then begin
    if (Sender.param.md.mode and MGetControlpoint)<>0 then
      FreeClick:=not ProcessControlpoint;
  end;

  if ((MZW_LBUTTON or MZW_RBUTTON) and zc)<>0 then begin
    if FreeClick and((Sender.param.md.mode and MGetSelectObject)<>0) then
      FreeClick:=not ProcessEntSelect;
  end;


  if FreeClick and((Sender.param.md.mode and (MGet3DPoint or MGet3DPointWoOP))<>0) then
    commandmanager.sendmousecoordwop(Sender,zc)
  else if onmouseobject<>nil then
    if ((MZW_LBUTTON and zc)<>0)and((MZW_SHIFT and zc)=0) then
      MouseTimer.&Set(mp,sysvarDSGNEntityMoveStartOffset,
        [RMDown,RMUp,RReSet,RLeave],StartEntityDrag,sysvarDSGNEntityMoveStartTimerInterval);

  //zcUI.Do_GUIaction(self,zcMsgUIActionRedraw);

  Result:=False;
end;

function SelectRelatedObjects(PDWG:PTAbstractDrawing;param:POGLWndtype;
  pent:PGDBObjEntity):integer;
var
  pvname,pvname2:pvardesk;
  ir:itrec;
  pobj:PGDBObjEntity;
  pentvarext:TVariablesExtender;
begin
  Result:=0;
  if pent=nil then
    exit;
  if assigned(sysvar.DSGN.DSGN_SelSameName) then
    if sysvar.DSGN.DSGN_SelSameName^ then begin
      if (pent^.GetObjType=GDBDeviceID)or(pent^.GetObjType=GDBCableID)or
        (pent^.GetObjType=GDBNetID) then begin
        pentvarext:=pent^.GetExtension<TVariablesExtender>;
        pvname:=pentvarext.entityunit.FindVariable('NMO_Name');
        if pvname<>nil then begin
          pobj:=pdwg.GetCurrentROOT.ObjArray.beginiterate(ir);
          if pobj<>nil then
            repeat
              if (pobj<>pent)and((pobj^.GetObjType=GDBDeviceID)or
                (pobj^.GetObjType=GDBCableID)or(pobj^.GetObjType=GDBNetID)) then begin
                pentvarext:=pobj^.GetExtension<TVariablesExtender>;
                pvname2:=pentvarext.entityunit.FindVariable('NMO_Name');
                if pvname2<>nil then
                  if pString(pvname2^.Data.Addr.Instance)^=
                    pString(pvname^.Data.Addr.Instance)^ then begin
                    if pobj^.select(
                      param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.Selector) then
                      Inc(
                        Result);
                  end;
              end;
              pobj:=pdwg.GetCurrentROOT.ObjArray.iterate(ir);
            until pobj=nil;
        end;
      end;
    end;
end;

procedure TzcMainForm.wakp(Sender:TAbstractViewArea;var Key:word;Shift:TShiftState);
var
  waitinput:boolean;
begin
  waitinput:=commandmanager.CurrCmd.pcommandrunning<>nil;
  if waitinput then
    waitinput:=commandmanager.CurrCmd.pcommandrunning.IData.GetPointMode in
      SomethingWait;
  if waitinput then
    waitinput:=IPEmpty in commandmanager.CurrCmd.pcommandrunning.IData.InputMode;

  if Key=VK_ESCAPE then begin
    //if assigned(ReStoreGDBObjInspProc)then
    //begin
    //if not ReStoreGDBObjInspProc then
    //begin
    Sender.ClearOntrackpoint;
    if commandmanager.CurrCmd.pcommandrunning=nil then begin
      //Sender.PDWG.GetCurrentROOT.ObjArray.DeSelect(Sender.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.DeSelector);
      Sender.SetMouseMode(cDefaultMouseMode);
      Sender.PDWG.DeSelectAll;
      Sender.param.SelDesc.LastSelectedObject:=nil;
      Sender.param.SelDesc.OnMouseObject:=nil;
      Sender.param.seldesc.Selectedobjcount:=0;
      Sender.param.firstdraw:=True;
      Sender.PDWG.GetSelObjArray.Free;
      Sender.CalcOptimalMatrix;
      Sender.paint;
      //if assigned(SetVisuaProplProc) then SetVisuaProplProc;
      zcUI.Do_GUIaction(self,zcMsgUIActionRebuild);
      zcUI.Do_GUIaction(Sender,zcMsgUIActionSelectionChanged);
      //Sender.setobjinsp;
    end else begin
      commandmanager.CurrCmd.pcommandrunning.CommandCancel(
        CommandManager.CurrCmd.Context);
      commandmanager.executecommandend;
    end;
    //end;
    //end;
    Key:=0;
  end else if ((Key=VK_RETURN)or(Key=VK_SPACE))and(not waitinput) then begin
    commandmanager.executelastcommad(Sender.pdwg,@Sender.param);
    Key:=00;
  end else if (Key=VK_V)and(shift=[ssctrl]) then begin
    commandmanager.executecommand(
      'PasteClip',Sender.pdwg,@Sender.param);
    key:=00;
  end;
end;

procedure TzcMainForm.wams(Sender:TAbstractViewArea;SelectedEntity:Pointer);
var
  RelSelectedObjects:integer;
begin
  RelSelectedObjects:=SelectRelatedObjects(Sender.PDWG,@Sender.param,
    Sender.param.SelDesc.LastSelectedObject);
  if RelSelectedObjects>0 then
    zcUI.TextMessage(
      format(rsAdditionalSelected,[RelSelectedObjects]),TMWOHistoryOut);
  if (commandmanager.CurrCmd.pcommandrunning=nil)or
    (commandmanager.CurrCmd.pcommandrunning^.IData.GetPointMode<>TGPMWaitEnt) then begin
    if PGDBObjEntity(Sender.param.SelDesc.OnMouseObject)^.select(
      Sender.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.Selector) then begin
      zcUI.Do_GUIaction(Sender,zcMsgUIActionSelectionChanged);
      zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
      //if assigned(updatevisibleproc) then updatevisibleproc(zcMsgUIActionRedraw);
    end;
  end;
end;

function TzcMainForm.GetEntsDesc(ents:PGDBObjOpenArrayOfPV):string;
var
  i:integer;
  pp:PGDBObjEntity;
  ir:itrec;
  //inr:TINRect;
  line:string;
  pvd:pvardesk;
  pentvarext:TVariablesExtender;
begin
  Result:='';
  i:=0;
  pp:=ents.beginiterate(ir);
  if pp<>nil then begin
    repeat
      pvd:=nil;
      pentvarext:=pp^.GetExtension<TVariablesExtender>;
      if pentvarext<>nil then
        pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
      if pvd<>nil then begin
        if i=20 then begin
          Result:=Result+#13#10+'...';
          exit;
        end;
        line:=
          pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
        line:=
          line+' Name='+pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
        if Result='' then
          Result:=line
        else
          Result:=Result+#13#10+line;
        Inc(i);
      end;
      pp:=ents.iterate(ir);
    until pp=nil;
  end;
end;

procedure TzcMainForm.WaShowCursor(Sender:TAbstractViewArea;var DC:TDrawContext);
begin
  if Sender.param.lastonmouseobject<>nil then begin
    //PGDBObjEntity(sender.param.lastonmouseobject)^.RenderFeedBack(sender.pdwg.GetPcamera^.POSCOUNT,sender.pdwg^.GetPcamera^, sender.pdwg^.myGluProject2,dc);
    pGDBObjEntity(
      Sender.param.lastonmouseobject)^.higlight(dc);
  end;
end;

procedure TzcMainForm.waSetObjInsp;
var
  tn:string;
  ptype:PUserTypeDescriptor;
  objcount:integer;
  sender_wa:TAbstractViewArea;
begin
  if (Sender is (TAbstractViewArea))and(zcMsgUIActionSelectionChanged=GUIAction) then
    sender_wa:=Sender as TAbstractViewArea
  else
    exit;
  if sysvar.DWG.DWG_AlwaysUseMultiSelectWrapper^ then
    objcount:=0
  else
    objcount:=1;
  if sender_wa.param.SelDesc.Selectedobjcount>objcount then begin
    if drawings.GetCurrentDWG.SelObjArray.Count>0 then begin
      //commandmanager.ExecuteCommandSilent('MultiSelect2ObjIbsp',sender_wa.pdwg,@sender_wa.param)
      MultiSelect2ObjIbsp_com(TZCADCommandContext.CreateRec,'');
    end else
      zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  end else begin
    if assigned(SysVar.DWG.DWG_SelectedObjToInsp) then
      if (sender_wa.param.SelDesc.LastSelectedObject<>nil)and
        (SysVar.DWG.DWG_SelectedObjToInsp^)and(sender_wa.param.SelDesc.Selectedobjcount>0) then
      begin
        tn:=PGDBObjEntity(sender_wa.param.SelDesc.LastSelectedObject)^.GetObjTypeName;
        ptype:=SysUnit.TypeName2PTD(tn);
        if ptype<>nil then begin
          zcUI.Do_PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,
            ptype,sender_wa.param.SelDesc.LastSelectedObject,sender_wa.pdwg);
        end;
      end else begin
        zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
      end;
  end;
end;

procedure TzcMainForm.correctscrollbars;
var
  pdwg:PTSimpleDrawing;
  BB:TBoundingBox;
  size,min,max,position:integer;
begin
  if (zcMainForm.HScrollBar<>nil)and(zcMainForm.VScrollBar<>nil) then
    if (zcMainForm.HScrollBar.Focused)or(zcMainForm.VScrollBar.Focused) then
      zcUI.Do_SetNormalFocus;
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
    if pdwg.wa<>nil then
      if pdwg.wa.getviewcontrol<>nil then begin
        bb:=pdwg.GetCurrentROOT.vp.BoundingBox;
        size:=round(pdwg.wa.getviewcontrol.ClientWidth*pdwg.GetPcamera^.prop.zoom);
        position:=round(-pdwg.GetPcamera^.prop.point.x);
        min:=round(bb.LBN.x+size/2);
        max:=round(bb.RTF.x+{$IFNDEF LCLWIN32}-{$ENDIF}size/2);
        if max<min then
          max:=min;
        zcMainForm.HScrollBar.SetParams(position,min,max,size);

        size:=round(pdwg.wa.getviewcontrol.ClientHeight*pdwg.GetPcamera^.prop.zoom);
        min:=round(bb.LBN.y+size/2);
        max:=round(bb.RTF.y+{$IFNDEF LCLWIN32}-{$ENDIF}size/2);
        if max<min then
          max:=min;
        position:=round((bb.LBN.y+bb.RTF.y+pdwg.GetPcamera^.prop.point.y));
        zcMainForm.VScrollBar.SetParams(position,min,max,size);
      end;
end;

procedure TzcMainForm.DrawStausBar(Sender:TObject);
var
  det:TThemedElementDetails;
  rect:trect;
begin
  if ThemeServices.ThemesEnabled then begin
    rect:=TToolBar(Sender).ClientRect;
    {det:=ThemeServices.GetElementDetails(tsStatusRoot);
    ThemeServices.DrawElement(TToolBar(Sender).Canvas.Handle,det,rect);}
    det:=ThemeServices.GetElementDetails(tsGripper);
    rect.Left:=rect.Right-24;
    ThemeServices.DrawElement(TToolBar(Sender).Canvas.Handle,det,rect);
  end;
end;

function TzcMainForm.GetFocusPriority:TControlWithPriority;
begin
  Result.priority:=UnPriority;
  Result.control:=nil;

  if assigned(PageControl) then
    if PageControl.Enabled then
      if PageControl.IsVisible then
        if PageControl.CanFocus then begin
          Result.priority:=DrawingsFocusPriority;
          Result.control:=PageControl;
        end;
end;

procedure TzcMainForm.AsyncFree(Data:PtrInt);
begin
  if (commandmanager.CurrCmd.pcommandrunning=nil)and(not LPS.isProcessed) then
    TObject(Data).Free
  else
    Application.QueueAsyncCall(AsyncFree,Data);
end;

function IsDifferentMenuitem(oldmenuitem,newmenuitem:TMenuItem):boolean;
var
  i:integer;
begin
  if oldmenuitem.Action<>newmenuitem.Action then
    exit(True);
  if oldmenuitem.Caption<>newmenuitem.Caption then
    exit(True);
  if @oldmenuitem.OnClick<>@newmenuitem.OnClick then
    exit(True);
  if oldmenuitem.Count<>newmenuitem.Count then
    exit(True);
  for i:=0 to oldmenuitem.Count-1 do begin
    Result:=IsDifferentMenuitem(oldmenuitem.Items[i],newmenuitem.Items[i]);
    if Result then
      exit(True);
  end;
  Result:=False;
end;

function IsDifferentMenu(oldmenu,newmenu:TMainMenu):boolean;
var
  i:integer;
begin
  if (oldmenu=nil)or(newmenu=nil) then
    exit(True);
  if oldmenu.Items.Count=newmenu.Items.Count then begin
    for i:=0 to oldmenu.Items.Count-1 do begin
      Result:=IsDifferentMenuitem(oldmenu.Items[i],newmenu.Items[i]);
      if Result then
        exit(True);
    end;
    Result:=False;
  end else
    Result:=True;
end;

procedure TzcMainForm.NeedUpdateMainMenu;
begin
  fNeedUpdateMainMenu:=True;
end;

procedure TzcMainForm.DoUpdateMainMenu;
var
  oldmenu,newmenu:TMainMenu;
begin
  if fNeedUpdateMainMenu then begin
    fNeedUpdateMainMenu:=False;
    oldmenu:=self.Menu;
    if assigned(oldmenu) then
      oldmenu.Name:='';
    newmenu:=TMainMenu(MenusManager.GetMainMenu('MAINMENU',application));
    if IsDifferentMenu(oldmenu,newmenu) then begin
      BeginFormUpdate;
      self.Menu:=newmenu;

      MetaDarkFormChanged(self);

      if assigned(oldmenu) then
        Application.QueueAsyncCall(AsyncFree,PtrInt(oldmenu));
      EndFormUpdate;
    end else
      FreeAndNil(newmenu);
  end;
end;

procedure TzcMainForm.AsyncUpdateVisible(Sender:PtrInt);
var
  GVA:TGeneralViewArea;
  Name:string;
  i,k:integer;
  pdwg:PTSimpleDrawing;
  FIPCServerRunning:boolean;
  //otherinstancerunning:boolean;
  //oldmenu,newmenu:TMainMenu;
begin

  NeedUpdateMainMenu;

  if assigned(UniqueInstanceBase.FIPCServer) then
    FIPCServerRunning:=UniqueInstanceBase.FIPCServer.Active
  else
    FIPCServerRunning:=False;

  if (FIPCServerRunning xor ZCSysParams.saved.UniqueInstance) then
    case ZCSysParams.saved.UniqueInstance of
      False:begin
        UniqueInstanceBase.FIPCServer.StopServer;
      end;
      True:begin
        if CreateOrRunFIPCServer then begin
          ZCSysParams.saved.UniqueInstance:=False;
          zcUI.TextMessage('Other unique instance found',TMWOShowError);
        end;
      end;
    end;

  if commandmanager.SilentCounter=0 then
    zcUI.Do_GUIMode(zcMsgUICMDLineCheck);

  pdwg:=drawings.GetCurrentDWG;
  if assigned(zcMainForm) then begin
    zcMainForm.UpdateControls;
    zcMainForm.correctscrollbars;
    k:=0;
    if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then begin
      zcUI.Do_GUIaction(self,zcMsgUIActionRebuild);
      zcMainForm.Caption:=programname+' v'+ZCSysParams.notsaved.ver.ShortVersionString+
        ' - ['+drawings.GetCurrentDWG.GetFileName+']';
      EnableControls(True);
      if assigned(zcMainForm.PageControl) then
        if assigned(SysVar.INTF.INTF_ShowDwgTabs) then
          if sysvar.INTF.INTF_ShowDwgTabs^ then
            zcMainForm.PageControl.ShowTabs:=True
          else
            zcMainForm.PageControl.ShowTabs:=False;
      if assigned(SysVar.INTF.INTF_DwgTabsPosition) then begin
        case SysVar.INTF.INTF_DwgTabsPosition^ of
          TATop:zcMainForm.PageControl.TabPosition:=tpTop;
          TABottom:zcMainForm.PageControl.TabPosition:=tpBottom;
          TALeft:zcMainForm.PageControl.TabPosition:=tpLeft;
          TARight:zcMainForm.PageControl.TabPosition:=tpRight;
        end;
      end;
      if assigned(SysVar.INTF.INTF_ThemedUpToolbars) then
        zcMainForm.CoolBarU.Themed:=SysVar.INTF.INTF_ThemedUpToolbars^;
      if assigned(SysVar.INTF.INTF_ThemedRightToolbars) then
        zcMainForm.CoolBarR.Themed:=SysVar.INTF.INTF_ThemedRightToolbars^;
      if assigned(SysVar.INTF.INTF_ThemedDownToolbars) then
        zcMainForm.CoolBarD.Themed:=SysVar.INTF.INTF_ThemedDownToolbars^;
      if assigned(SysVar.INTF.INTF_ThemedLeftToolbars) then
        zcMainForm.CoolBarL.Themed:=SysVar.INTF.INTF_ThemedLeftToolbars^;
      if assigned(zcMainForm.PageControl) then
        if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then begin
          if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
            zcMainForm.PageControl.Options:=
              zcMainForm.PageControl.Options+[nboShowCloseButtons]
          else
            zcMainForm.PageControl.Options:=
              zcMainForm.PageControl.Options-[nboShowCloseButtons];
        end;
      if assigned(zcMainForm.HScrollBar) then begin
        zcMainForm.HScrollBar.Enabled:=True;
        zcMainForm.correctscrollbars;
        if assigned(sysvar.INTF.INTF_ShowScrollBars) then
          if sysvar.INTF.INTF_ShowScrollBars^ then
            zcMainForm.HScrollBar.Show
          else
            zcMainForm.HScrollBar.Hide;
      end;
      if assigned(zcMainForm.VScrollBar) then begin
        zcMainForm.VScrollBar.Enabled:=True;
        if assigned(sysvar.INTF.INTF_ShowScrollBars) then
          if sysvar.INTF.INTF_ShowScrollBars^ then
            zcMainForm.VScrollBar.Show
          else
            zcMainForm.VScrollBar.Hide;
      end;
      for i:=0 to zcMainForm.PageControl.PageCount-1 do begin
        GVA:=TGeneralViewArea(FindComponentByType(
          zcMainForm.PageControl.Pages[i],TGeneralViewArea));
        if assigned(GVA) then
          if GVA.PDWG<>nil then begin
            Name:=extractfilename(PTZCADDrawing(GVA.PDWG)^.FileName);
            if @PTZCADDrawing(GVA.PDWG).mainObjRoot=
              (PTZCADDrawing(GVA.PDWG).pObjRoot) then
              zcMainForm.PageControl.Pages[i].Caption:=(Name)
            else
              zcMainForm.PageControl.Pages[i].Caption:=
                format(rsOtherInsideDrawing,[Name,'BlockDefs',PGDBObjBlockdef(
                PTZCADDrawing(GVA.PDWG).pObjRoot).Name]);
            if k<=high(OpenedDrawings) then begin
              OpenedDrawings[k].Caption:=zcMainForm.PageControl.Pages[i].Caption;
              OpenedDrawings[k].Visible:=True;
              OpenedDrawings[k].command:='ShowPage';
              OpenedDrawings[k].options:=IntToStr(i);
              Inc(k);
            end;
          end;
      end;
      for i:=k to high(OpenedDrawings) do begin
        OpenedDrawings[i].Visible:=False;
      end;
    end else begin
      for i:=low(OpenedDrawings) to high(OpenedDrawings) do begin
        OpenedDrawings[i].Caption:='';
        OpenedDrawings[i].Visible:=False;
        OpenedDrawings[i].command:='';
      end;
      zcMainForm.Caption:=(programname+' v'+ZCSysParams.notsaved.ver.ShortVersionString);
      EnableControls(False);
      if assigned(zcMainForm.HScrollBar) then begin
        zcMainForm.HScrollBar.Enabled:=False;
        if assigned(sysvar.INTF.INTF_ShowScrollBars) then
          if sysvar.INTF.INTF_ShowScrollBars^ then

            zcMainForm.HScrollBar.Show
          else
            zcMainForm.HScrollBar.Hide;
      end;
      if assigned(zcMainForm.VScrollBar) then begin
        zcMainForm.VScrollBar.Enabled:=False;
        if assigned(sysvar.INTF.INTF_ShowScrollBars) then
          if sysvar.INTF.INTF_ShowScrollBars^ then
            zcMainForm.VScrollBar.Show
          else
            zcMainForm.VScrollBar.Hide;
      end;
    end;
  end;
end;

procedure TzcMainForm.updatevisible(Sender:TObject;GUIMode:TzcMessageID);
begin
  if GUIMode<>zcMsgUIActionRedraw then
    exit;
  Application.QueueAsyncCall(AsyncUpdateVisible,PtrInt(Sender));
end;

{$IfDef LINUX}
procedure DoShutdown(Sig: Longint; Info: PSigInfo; Context: PSigContext); cdecl;
begin
  ProgramLog.LogOutFormatStr('Got signal: "%d"',[Sig],LM_Necessarily);
  CloseApp;
end;
procedure RegisterSignalHandler;
var
  RecNew, RecOld: sigactionrec;
begin
  RecOld:= Default(sigactionrec);
  RecNew:= Default(sigactionrec);
  RecNew.sa_handler:= @DoShutdown;
  FPSigaction(SIGTERM, @RecNew, @RecOld);
  FPSigaction(SIGINT, @RecNew, @RecOld);
end;
{$EndIf}

initialization
  begin
    LMD:=programlog.RegisterModule('zcad\gui\uzcmainwindow-gui');
    {$IfDef LINUX}
  RegisterSignalHandler;
    {$EndIf}
  end

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
