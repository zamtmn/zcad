{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit uzcmainwindow;
{$INCLUDE def.inc}

interface
uses
  {LCL}
       Laz2_DOM,AnchorDockPanel,AnchorDocking,AnchorDockOptionsDlg,ButtonPanel,AnchorDockStr,
       ActnList,LCLType,LCLProc,uzctranslations,toolwin,LMessages,LCLIntf,
       Forms, stdctrls, ExtCtrls, ComCtrls,Controls,Classes,SysUtils,LazUTF8,
       menus,graphics,dialogs,XMLPropStorage,Buttons,Themes,
       Types,UniqueInstanceBase,simpleipc,{$ifdef windows}windows,{$endif}
  {FPC}
       lineinfo,
  {ZCAD BASE}
       gzctnrvectortypes,uzcgui2color,uzcgui2linewidth,uzcgui2linetypes,uzemathutils,uzelongprocesssupport,
       {uzegluinterface,}uzgldrawergdi,uzcdrawing,UGDBOpenArrayOfPV,uzedrawingabstract,
       uzepalette,uzbpaths,uzglviewareadata,uzeentitiesprop,uzcinterface,
       UGDBOpenArrayOfByte,uzbmemman,uzbtypesbase,uzbtypes,
       uzegeometry,uzcsysvars,uzcstrconsts,uzbstrproc,UGDBNamedObjectsArray,uzclog,
       uzedimensionaltypes,varmandef, varman,UUnitManager,uzcsysinfo,uzcshared,strmy,uzestylestexts,uzestylesdim,
  {ZCAD SIMPLE PASCAL SCRIPT}
       languade,
  {ZCAD ENTITIES}
       uzbgeomtypes,uzeentity,UGDBSelectedObjArray,uzestyleslayers,uzedrawingsimple,
       uzeblockdef,uzcdrawings,uzcutils,uzestyleslinetypes,uzeconsts,uzeenttext,uzeentdimension,
  {ZCAD COMMANDS}
       uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  {GUI}
       uztoolbarsmanager,uzctextenteditor,{uzcoidecorations,}uzcfcommandline,uzctreenode,uzcflineweights,uzcctrllayercombobox,uzcctrlcontextmenu,
       uzcfcolors,uzcimagesmanager,uzcgui2textstyles,usupportgui,uzcgui2dimstyles,
  {}
       zcchangeundocommand,uzgldrawcontext,uzglviewareaabstract,uzcguimanager,uzcinterfacedata,
       uzcenitiesvariablesextender,uzglviewareageneral;
  {}
type
  TMyToolbar=class(TToolBar)
    public
    destructor Destroy; override;
  end;
  TComboFiller=procedure(cb:TCustomComboBox) of object;
  TFiletoMenuIteratorData=record
                                localpm:TMenuItem;
                                ImageIndex:Integer;
                          end;

  TmyAnchorDockSplitter = class(TAnchorDockSplitter)
  public
    constructor Create(TheOwner: TComponent); override;

                          end;
  PTDummyMyActionsArray=^TDummyMyActionsArray;
  TDummyMyActionsArray=Array [0..0] of TmyAction;
  TFileHistory=Array [0..9] of TmyAction;
  TOpenedDrawings=Array [0..9] of TmyAction;
  TCommandHistory=Array [0..9] of TmyAction;


  { TZCADMainWindow }

  TZCADMainWindow = class(TForm)
    AnchorDockPanel1:TAnchorDockPanel;
    CoolBarR: TCoolBar;
    CoolBarD: TCoolBar;
    CoolBarL: TCoolBar;
    CoolBarU: TCoolBar;
    ToolBarD: TToolBar;

    public
    MainPanel:TForm;
    //FToolBar:TToolButtonForm;
    PageControl:TmyPageControl;
    DHPanel:TPanel;
    HScrollBar,VScrollBar:TScrollBar;
    StandartActions:TmyActionList;
    SystemTimer: TTimer;
    toolbars:tstringlist;
    updatesbytton,updatescontrols:tlist;
    procedure ZcadException(Sender: TObject; E: Exception);
    //function findtoolbatdesk(tbn:string):string;
    //procedure CreateToolbarFromDesk(tb:TToolBar;tbname,tbdesk:string);
    function CreateCBox(CBName:GDBString;owner:TToolBar;DrawItem:TDrawItemEvent;Change,DropDown,CloseUp:TNotifyEvent;Filler:TComboFiller;w:integer;ts:GDBString):TComboBox;
    procedure CreateHTPB(tb:TToolBar);

    procedure ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure AfterConstruction; override;
    procedure setnormalfocus(Sender: TObject;GUIAction:TZMessageID);

    //procedure loadpanels(pf:GDBString);
    procedure CreateLayoutbox(tb:TToolBar);
    //procedure loadmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    //procedure loadpopupmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    //procedure createmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    //procedure setmainmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    //procedure loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);

    procedure ChangedDWGTabCtrl(Sender: TObject);
    procedure UpdateControls;

    procedure Say(word:gdbstring);

    procedure SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);

    function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
    procedure ShowAllCursors(ShowedForm:TForm);
    procedure RestoreCursors(ShowedForm:TForm);
    procedure CloseDWGPageInterf(Sender: TObject);
    function CloseDWGPage(Sender: TObject):integer;

    procedure PageControlMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure correctscrollbars;
    function wamd(Sender:TAbstractViewArea;Button:TMouseButton;Shift:TShiftState;X,Y:Integer;onmouseobject:GDBPointer;var NeedRedraw:Boolean):boolean;
    procedure wamm(Sender:TAbstractViewArea;Shift:TShiftState;X,Y:Integer);
    procedure wams(Sender:TAbstractViewArea;SelectedEntity:GDBPointer);
    procedure wakp(Sender:TAbstractViewArea;var Key: Word; Shift: TShiftState);
    function GetEntsDesc(ents:PGDBObjOpenArrayOfPV):GDBString;
    procedure waSetObjInsp(Sender:{TAbstractViewArea}tobject;GUIAction:TZMessageID);
    procedure WaShowCursor(Sender:TAbstractViewArea;var DC:TDrawContext);

    //onXxxxx handlers
    procedure _onCreate(Sender: TObject);

    //Long process support - draw progressbar. See uzelongprocesssupport unit
    procedure StartLongProcess(LPHandle:TLPSHandle;Total:TLPSCounter;processname:TLPName);
    procedure ProcessLongProcess(LPHandle:TLPSHandle;Current:TLPSCounter);
    procedure EndLongProcess(LPHandle:TLPSHandle;TotalLPTime:TDateTime);

    public
    FAppProps:TApplicationProperties;
    rt:GDBInteger;
    FileHistory:TFileHistory;
    OpenedDrawings:TOpenedDrawings;
    CommandsHistory:TCommandHistory;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    destructor Destroy;override;
    procedure CreateAnchorDockingInterface;

    procedure CreateInterfaceLists;
    procedure FillColorCombo(cb:TCustomComboBox);
    procedure FillLTCombo(cb:TCustomComboBox);
    procedure FillLWCombo(cb:TCustomComboBox);
    procedure InitSystemCalls;
    procedure LoadActions;
    procedure myKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ChangeCLineW(Sender:Tobject);
    procedure ChangeCColor(Sender:Tobject);
    procedure ChangeLType(Sender:Tobject);
    procedure DropDownColor(Sender:Tobject);
    procedure DropDownLType(Sender:Tobject);
    procedure DropUpLType(Sender:Tobject);
    procedure DropUpColor(Sender:Tobject);
    procedure ChangeLayout(Sender:Tobject);
    procedure idle(Sender: TObject; var Done: Boolean);virtual;
    procedure ReloadLayer(plt:PTGenericNamedObjectsArray);
    procedure GeneralTick(Sender: TObject);
    procedure ShowFastMenu(Sender: TObject);
    procedure asynccloseapp(Data: PtrInt);
    procedure processfilehistory(filename:string);
    procedure processcommandhistory(Command:string);
    function CreateZCADControl(aName: string;DoDisableAlign:boolean=false):TControl;
    procedure TBActionCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBButtonCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBLayerComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBColorComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBLTypeComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBLineWComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBTStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBDimStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
    procedure TBVariableCreateFunc(aNode: TDomNode; TB:TToolBar);
    function TBCreateZCADToolBar(aName,atype: string):TToolBar;
    procedure TTBRegisterInAPPFunc(aTBNode: TDomNode;aName,aType: string;Data:Pointer);
    procedure ZActionsReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    procedure ZAction2VariableReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    procedure ZMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZPopUpMenuReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuFileHistory(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuCommandsHistory(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuCommand(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuToolBars(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuDrawings(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuSampleFiles(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainMenuDebugFiles(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainCreateMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure ZMainSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure DockMasterCreateControl(Sender: TObject; aName: string; var
    AControl: TControl; DoDisableAutoSizing: boolean);

    function IsShortcut(var Message: TLMKey): boolean; override;
    function GetLayerProp(PLayer:Pointer;out lp:TLayerPropRecord):boolean;
    function GetLayersArray(out la:TLayerArray):boolean;
    function ClickOnLayerProp(PLayer:Pointer;NumProp:integer;out newlp:TLayerPropRecord):boolean;

    procedure setvisualprop;
    procedure addoneobject;

    procedure _scroll(Sender: TObject; ScrollCode: TScrollCode;
           var ScrollPos: Integer);
    procedure ShowCXMenu;
    procedure ShowFMenu;
    procedure MainMouseMove;
    function MainMouseDown(Sender:TAbstractViewArea):GDBBoolean;
    procedure MainMouseUp;
    procedure IPCMessage(Sender: TObject);
    {$ifdef windows}procedure SetTop;{$endif}
    procedure UpdateVisible(sender:TObject;GUIMode:TZMessageID);
               end;
//procedure UpdateVisible(GUIMode:TZMessageID);
function LoadLayout_com(Operands:pansichar):GDBInteger;
function _CloseDWGPage(ClosedDWG:PTZCADDrawing;lincedcontrol:TObject):Integer;

var
  ZCADMainWindow: TZCADMainWindow;
  LayerBox:TZCADLayerComboBox;
  LineWBox,ColorBox,LTypeBox,TStyleBox,DimStyleBox:TComboBox;
  LayoutBox:TComboBox;
  LPTime:Tdatetime;
  pname:GDBString;
  oldlongprocess:integer;
  OLDColor:integer;
  localpm:TFiletoMenuIteratorData;
  ProcessBar:TProgressBar;
  //StoreBackTraceStrFunc:TBackTraceStrFunc;//this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  function CloseApp:GDBInteger;
  function IsRealyQuit:GDBBoolean;

implementation
{$R *.lfm}

destructor TmyToolBar.Destroy;
var
  I: Integer;
  c:tcontrol;
begin
  for I := 0 to controlCount - 1 do
    begin
      c:=controls[I];
      if assigned(ZCADMainWindow.updatescontrols)  then
        ZCADMainWindow.updatescontrols.Remove(c);
      if assigned(ZCADMainWindow.updatesbytton)  then
        ZCADMainWindow.updatesbytton.Remove(c);
    end;
  inherited Destroy;
end;

constructor TmyAnchorDockSplitter.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  self.MinSize:=1;
end;

procedure setlayerstate(PLayer:PGDBLayerProp;out lp:TLayerPropRecord);
begin
     lp._On:=player^._on;
     lp.Freze:=false;
     lp.Lock:=player^._lock;
     lp.Name:=Tria_AnsiToUtf8(player.Name);
     lp.PLayer:=player;;
end;
{$ifdef windows}
procedure TZCADMainWindow.SetTop;
var
  hWnd, hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: Boolean;
begin
  if GetActiveWindow=Application.MainForm.Handle then Exit;
     Application.Restore;
     hWnd := {Application.Handle}Application.MainForm.Handle;
     SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
     SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     hCurWnd := GetForegroundWindow;
     AResult := SetForegroundWindow(hWnd);{в вин7 почемуто это подвисает AResult := False;
     while not AResult do
     begin
        dwThreadID := GetCurrentThreadId;
        dwCurThreadID := GetWindowThreadProcessId(hCurWnd,nil);
        AttachThreadInput(dwThreadID, dwCurThreadID, True);
        AResult := SetForegroundWindow(hWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, False);
     end;}
     SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(OldTimeOut), 0);
end;
{$endif}
procedure TZCADMainWindow.IPCMessage(Sender: TObject);
var
   msgstring,ts:string;
begin
     msgstring:=TSimpleIPCServer(Sender).StringMessage;
     {$ifndef windows}application.BringToFront;{$endif}
     {$ifdef windows}settop;{$endif}
     application.processmessages;
     //{ifdef windows}msgstring:=Tria_AnsiToUtf8(msgstring);{endif}
     repeat
           GetPartOfPath(ts,msgstring,'|');
           if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then
           begin
                commandmanager.executecommandtotalend;
                commandmanager.executecommand('Load('+ts+')',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
           end;
     until msgstring='';
end;

procedure TZCADMainWindow.setvisualprop;
const IntEmpty=-1000;
      IntDifferent=-10001;
      PEmpty=pointer(0);
      PDifferent=pointer(1);
var lw:GDBInteger;
    color:GDBInteger;
    layer:pgdblayerprop;
    ltype:PGDBLtypeProp;
    tstyle:PGDBTextStyle;
    dimstyle:PGDBDimStyle;
    pv:PSelectedObjDesc;
    ir:itrec;
begin

  if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
  then
      begin
           if assigned(LinewBox) then
           if sysvar.dwg.DWG_CLinew^<0 then LineWbox.ItemIndex:=(sysvar.dwg.DWG_CLinew^+3)
                                       else LinewBox.ItemIndex:=((sysvar.dwg.DWG_CLinew^ div 10)+3);
           {if assigned(LayerBox) then
           LayerBox.ItemIndex:=getsortedindex(SysVar.dwg.DWG_CLayer^);}
           IVars.CColor:=sysvar.dwg.DWG_CColor^;
           IVars.CLWeight:=sysvar.dwg.DWG_CLinew^;
           ivars.CLayer:={drawings.GetCurrentDWG.LayerTable.getDataMutable}(sysvar.dwg.DWG_CLayer^);
           ivars.CLType:={drawings.GetCurrentDWG.LTypeStyleTable.getDataMutable}(sysvar.dwg.DWG_CLType^);
           ivars.CTStyle:=sysvar.dwg.DWG_CTStyle^;
           ivars.CDimStyle:=sysvar.dwg.DWG_CDimStyle^;
      end
  else
      begin
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
           if pv^.objaddr<>nil then
           begin
                //if pv^.Selected
                //then
                    begin
                         if lw=IntEmpty then lw:=pv^.objaddr^.vp.LineWeight
                                      else if lw<> pv^.objaddr^.vp.LineWeight then lw:=IntDifferent;
                         if layer=PEmpty then layer:=pv^.objaddr^.vp.layer
                                      else if layer<> pv^.objaddr^.vp.layer then layer:=PDifferent;
                         if color=IntEmpty then color:=pv^.objaddr^.vp.color
                                        else if color<> pv^.objaddr^.vp.color then color:=IntDifferent;
                         if ltype=PEmpty then ltype:=pv^.objaddr^.vp.LineType
                                        else if ltype<> pv^.objaddr^.vp.LineType then ltype:=PDifferent;
                         if (pv^.objaddr^.GetObjType=GDBMTextID)or(pv^.objaddr^.GetObjType=GDBTextID) then
                         begin
                         if tstyle=PEmpty then tstyle:=PGDBObjText(pv^.objaddr)^.TXTStyleIndex
                                           else if tstyle<> PGDBObjText(pv^.objaddr)^.TXTStyleIndex then tstyle:=PDifferent;
                         end;
                         if (pv^.objaddr^.GetObjType=GDBAlignedDimensionID)or(pv^.objaddr^.GetObjType=GDBRotatedDimensionID)or(pv^.objaddr^.GetObjType=GDBDiametricDimensionID) then
                         begin
                         if dimstyle=PEmpty then dimstyle:=PGDBObjDimension(pv^.objaddr)^.PDimStyle
                                            else if dimstyle<>PGDBObjDimension(pv^.objaddr)^.PDimStyle then dimstyle:=PDifferent;
                         end;
                    end;
                if (layer=PDifferent)and(lw=IntDifferent)and(color=IntDifferent)and(ltype=PDifferent)and(tstyle=PDifferent)and(dimstyle=PDifferent) then system.Break;
           end;
           pv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
           until pv=nil;
           if lw<>IntEmpty then
           if lw=IntDifferent then
                               ivars.CLWeight:=ClDifferent
                           else
                               begin
                                    ivars.CLWeight:=lw
                               end;
           if layer<>PEmpty then
           if layer=PDifferent then
                                  ivars.CLayer:=nil
                               else
                               begin
                                    ivars.CLayer:=layer;
                               end;
           if color<>IntEmpty then
           if color=IntDifferent then
                                  ivars.CColor:=ClDifferent
                           else
                               begin
                                    ivars.CColor:=color;
                               end;
           if ltype<>PEmpty then
           if ltype=PDifferent then
                                  ivars.CLType:=nil
                           else
                               begin
                                    ivars.CLType:=ltype;
                               end;
           if tstyle<>PEmpty then
           if tstyle=PDifferent then
                                  ivars.CTStyle:=nil
                           else
                               begin
                                    ivars.CTStyle:=tstyle;
                               end;
           if dimstyle<>PEmpty then
           if dimstyle=PDifferent then
                                  ivars.CDimStyle:=nil
                           else
                               begin
                                    ivars.CDimStyle:=dimstyle;
                               end;
      end;
      UpdateControls;
end;
procedure TZCADMainWindow.addoneobject;
var lw:GDBInteger;
begin
  exit;
  lw:=PGDBObjEntity(drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineWeight;
  if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=1
  then
      begin
           if assigned(LinewBox)then
           begin
           if lw<0 then
                       begin
                            LinewBox.ItemIndex:=(lw+3)
                       end
                   else LinewBox.ItemIndex:=((lw div 10)+3);
           end;
           ivars.CColor:=PGDBObjEntity(drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.color;
           ivars.CLType:=PGDBObjEntity(drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineType;
      end
  else
      begin
           if lw<0 then lw:=lw+3
                   else lw:=(lw div 10)+3;
           if assigned(LinewBox)then
           if LinewBox.ItemIndex<>lw then LinewBox.ItemIndex:=(LinewBox.Items.Count-1);

           if ivars.CColor<>PGDBObjEntity(drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.color then
              ivars.CColor:=ClDifferent;
           if ivars.CLType<>PGDBObjEntity(drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineType then
              ivars.CLType:=nil;
      end;
end;

function TZCADMainWindow.ClickOnLayerProp(PLayer:Pointer;NumProp:integer;out newlp:TLayerPropRecord):boolean;
var
   cdwg:PTSimpleDrawing;
   tcl:PGDBLayerProp;
begin
     CDWG:=drawings.GetCurrentDWG;
     result:=false;
     case numprop of
                    0:begin
                           PGDBLayerProp(PLayer)^._on:=not(PGDBLayerProp(PLayer)^._on);
                           if PLayer=cdwg^.GetCurrentLayer then
                           if not PGDBLayerProp(PLayer)^._on then
                                                                 MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);

                      end;
                    {1:;}
                    2:PGDBLayerProp(PLayer)^._lock:=not(PGDBLayerProp(PLayer)^._lock);
                    3:begin
                           cdwg:=drawings.GetCurrentDWG;
                           if cdwg<>nil then
                           begin
                                if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0 then
                                begin
                                          if assigned(sysvar.dwg.DWG_CLayer) then
                                          if sysvar.dwg.DWG_CLayer^<>Player then
                                          begin
                                               with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,sysvar.dwg.DWG_CLayer^)^ do
                                               begin
                                                    sysvar.dwg.DWG_CLayer^:=Player;
                                                    ComitFromObj;
                                               end;
                                          end;
                                          if not PGDBLayerProp(PLayer)^._on then
                                                                            MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
                                          setvisualprop;
                                end
                                else
                                begin
                                       tcl:=SysVar.dwg.DWG_CLayer^;
                                       SysVar.dwg.DWG_CLayer^:=Player;
                                       commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                                       SysVar.dwg.DWG_CLayer^:=tcl;
                                       setvisualprop;
                                end;
                           result:=true;
                           end;
                      end;
     end;
     setlayerstate(PLayer,newlp);
     if not result then
                       begin
                         ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
                         //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
                         zcRedrawCurrentDrawing;
                       end;
end;

function TZCADMainWindow.GetLayersArray(out la:TLayerArray):boolean;
var
   cdwg:PTSimpleDrawing;
   pcl:PGDBLayerProp;
   ir:itrec;
   counter:integer;
begin
     result:=false;
     cdwg:=drawings.GetCurrentDWG;
     if cdwg<>nil then
     begin
         if assigned(cdwg^.wa.getviewcontrol) then
         begin
              setlength(la,cdwg^.LayerTable.Count);
              counter:=0;
              pcl:=cdwg^.LayerTable.beginiterate(ir);
              if pcl<>nil then
              repeat
                    setlayerstate(pcl,la[counter]);
                    inc(counter);
                    pcl:=cdwg^.LayerTable.iterate(ir);
              until pcl=nil;
              setlength(la,counter);
              if counter>0 then
                               result:=true;
         end;
     end;
end;
function TZCADMainWindow.GetLayerProp(PLayer:Pointer;out lp:TLayerPropRecord):boolean;
var
   cdwg:PTSimpleDrawing;
begin
     if player=nil then
                       begin
                            result:=false;
                            cdwg:=drawings.GetCurrentDWG;
                            if cdwg<>nil then
                            begin
                                 if assigned(cdwg^.wa) then
                                 begin
                                      if IVars.CLayer<>nil then
                                      begin
                                           setlayerstate(IVars.CLayer,lp);
                                           result:=true;
                                      end
                                      else
                                          lp.Name:=rsDifferent;
                                end;
                            end;

                       end
                   else
                       begin
                            result:=true;
                            setlayerstate(PLayer,lp);
                       end;

end;
function FindIndex(taa:PTDummyMyActionsArray;l,h:integer;ca:string):integer;
var
    i:integer;
begin
  result:=h-1;
  for i:=l to h do
  begin
       if assigned(taa[i]) then
       if taa[i].Caption=ca then
       begin
            result:=i-1;
            system.break;
       end;
  end;
end;
procedure ScrollArray(taa:PTDummyMyActionsArray;l,h:integer);
var
    j,i:integer;
begin
  for i:=h downto l do
  begin
       j:=i+1;
       if (assigned(taa[j]))and(assigned(taa[i]))then
       taa[j].SetCommand(taa[i].caption,taa[i].Command,taa[i].options);
  end;
end;
procedure CheckArray(taa:PTDummyMyActionsArray;l,h:integer);
var
    i:integer;
begin
  for i:=l to h do
  begin
       if assigned(taa[i]) then
       if taa[i].command='' then
                                taa[i].visible:=false
                            else
                                taa[i].visible:=true;
  end;
end;
procedure SetArrayTop(taa:PTDummyMyActionsArray;_Caption,_Command,_Options:string);
begin
     if assigned(taa[0]) then
     if _Caption<>''then
                          taa[0].SetCommand(_Caption,_Command,_Options)
                      else
                          taa[0].SetCommand(rsEmpty,'','');
end;
procedure TZCADMainWindow.processfilehistory(filename:string);
var i,j,k:integer;
    pstr,pstrnext:PGDBString;
begin
     k:=FindIndex(@FileHistory,low(filehistory),high(filehistory),filename);
     if k<0 then exit;

     ScrollArray(@FileHistory,0,k);

     for i:=k downto 0 do
     begin
          j:=i+1;
          pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
          pstrnext:=SavedUnit.FindValue('PATH_File'+inttostr(j));
          if (assigned(pstr))and(assigned(pstrnext))then
                                                        pstrnext^:=pstr^;
     end;
     pstr:=SavedUnit.FindValue('PATH_File0');
     if (assigned(pstr))then
                             pstr^:=filename;

     SetArrayTop(@FileHistory,FileName,'Load',FileName);
     CheckArray(@FileHistory,low(filehistory),high(filehistory));
end;
procedure  TZCADMainWindow.processcommandhistory(Command:string);
var
   k:integer;
begin
     k:=FindIndex(@CommandsHistory,low(Commandshistory),high(Commandshistory),Command);
     if k<0 then exit;

     ScrollArray(@CommandsHistory,0,k);
     SetArrayTop(@CommandsHistory,Command,Command,'');
     CheckArray(@CommandsHistory,low(Commandshistory),high(Commandshistory));
end;
function IsRealyQuit:GDBBoolean;
var
   pint:PGDBInteger;
   mem:GDBOpenArrayOfByte;
   i:integer;
   GVA:TGeneralViewArea;
begin
     result:=false;
     if ZCADMainWindow.PageControl<>nil then
     begin
          for i:=0 to ZCADMainWindow.PageControl.PageCount-1 do
          begin
               GVA:=TGeneralViewArea(FindComponentByType(TTabSheet(ZCADMainWindow.PageControl.Pages[i]),TGeneralViewArea));
               if {poglwnd}GVA<>nil then
                                   begin
                                        if {poglwnd.wa}GVA.PDWG.GetChangeStampt then
                                                                            begin
                                                                                 result:=true;
                                                                                 system.break;
                                                                            end;
                                   end;
          end;

     end;
     begin
     if not result then
                       begin
                       if drawings.GetCurrentDWG<>nil then
                                                     i:=ZCADMainWindow.messagebox(@rsQuitQuery[1],@rsQuitCaption[1],MB_YESNO or MB_ICONQUESTION)
                                                 else
                                                     i:=IDYES;
                       end
                   else
                       i:=IDYES;
     if i=IDYES then
     begin
          result:=true;

          if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
          if sysvar.SYS.SYS_IsHistoryLineCreated^ then
          begin
               pint:=SavedUnit.FindValue('DMenuX');
               if assigned(pint)then
                                    pint^:=commandmanager.DMenu.Left;
               pint:=SavedUnit.FindValue('DMenuY');
               if assigned(pint)then
                                    pint^:=commandmanager.DMenu.Top;

          pint:=SavedUnit.FindValue('VIEW_CommandLineH');
          if assigned(pint)then
                               pint^:=Cline.Height;
          pint:=SavedUnit.FindValue('VIEW_ObjInspV');
          if assigned(pint)then
                               if assigned(GetOIWidthProc)then
                               pint^:=GetOIWidthProc;
          pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
          if assigned(pint)then
                               if assigned(GetNameColWidthProc)then
                               pint^:=GetNameColWidthProc;

     if assigned(InfoForm) then
                         StoreBoundsToSavedUnit('TEdWND_',InfoForm.BoundsRect);

          mem.init({$IFDEF DEBUGBUILD}'{71D987B4-8C57-4C62-8C12-CFC24A0A9C9A}',{$ENDIF}1024);
          SavedUnit^.SavePasToMem(mem);
          mem.SaveToFile(expandpath(ProgramPath+'rtl'+PathDelim+'savedvar.pas'));
          mem.done;
          end;

          ZCMsgCallBackInterface.TextMessage('   Вот и всё бля...............',TMWOHistoryOut);


     end
     else
         result:=false;
     end;
end;

function CloseApp:GDBInteger;
begin
     result:=0;
     if IsRealyQuit then
     begin
          if ZCADMainWindow.PageControl<>nil then
          begin
               while ZCADMainWindow.PageControl.ActivePage<>nil do
               begin
                    if ZCADMainWindow.CloseDWGPage(ZCADMainWindow.PageControl.ActivePage)=IDCANCEL then
                                                                                             exit;
               end;
          end;
          if assigned(FreEditorProc)then
                                        FreEditorProc;
          if assigned(ReturnToDefaultProc)then
                                           ReturnToDefaultProc(drawings.GetUnitsFormat);
          application.terminate;
     end;
end;
procedure TZCADMainWindow.asynccloseapp(Data: PtrInt);
begin
      CloseApp;
end;
procedure TZCADMainWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     CloseAction:=caNone;
     if not commandmanager.EndGetPoint(TGPCloseApp) then
                                           Application.QueueAsyncCall(asynccloseapp, 0);
end;

function ShowAnchorDockOptions(ADockMaster: TAnchorDockMaster): TModalResult;
var
  Dlg: TForm;
  OptsFrame: TAnchorDockOptionsFrame;
  BtnPanel: TButtonPanel;
begin
  Dlg:=TForm.Create(nil);
  try
    Dlg.DisableAutoSizing;
    Dlg.Position:=poScreenCenter;
    Dlg.AutoSize:=true;
    Dlg.Caption:=adrsGeneralDockingOptions;

    OptsFrame:=TAnchorDockOptionsFrame.Create(Dlg);
    OptsFrame.Align:=alClient;
    OptsFrame.Parent:=Dlg;
    OptsFrame.Master:=ADockMaster;

    BtnPanel:=TButtonPanel.Create(Dlg);
    BtnPanel.ShowButtons:=[pbOK, pbCancel];
    BtnPanel.OKButton.OnClick:=OptsFrame.OkClick;
    BtnPanel.Parent:=Dlg;
    Dlg.EnableAutoSizing;
    Result:=ZCMsgCallBackInterface.DOShowModal(Dlg);
  finally
    Dlg.Free;
  end;
end;
function _CloseDWGPage(ClosedDWG:PTZCADDrawing;lincedcontrol:TObject):Integer;
var
   viewcontrol:TCADControl;
   s:string;
   TAWA:TAbstractViewArea;
begin
  if ClosedDWG<>nil then
  begin
       result:=IDYES;
       if ClosedDWG.Changed then
                                 begin
                                      repeat
                                      s:=format(rsCloseDWGQuery,[ClosedDWG.FileName]);
                                      result:=ZCADMainWindow.MessageBox(@s[1],@rsWarningCaption[1],MB_YESNOCANCEL);
                                      if result=IDCANCEL then exit;
                                      if result=IDNO then system.break;
                                      if result=IDYES then
                                      begin
                                           result:=dwgQSave_com(ClosedDWG);
                                      end;
                                      until result<>cmd_error;
                                      result:=IDYES;
                                 end;
       commandmanager.ChangeModeAndEnd(TGPCloseDWG);
       viewcontrol:=ClosedDWG.wa.getviewcontrol;
       if drawings.GetCurrentDWG=pointer(ClosedDwg) then
                                                   drawings.freedwgvars;
       drawings.RemoveData(ClosedDWG);
       drawings.pack;

       viewcontrol.free;

       lincedcontrol.Free;
       tobject(viewcontrol):=ZCADMainWindow.PageControl.ActivePage;

       if viewcontrol<>nil then
       begin
            TAWA:=TAbstractViewArea(FindComponentByType(viewcontrol,TAbstractViewArea));
            drawings.CurrentDWG:=pointer(TAWA.PDWG);
            TAWA.GDBActivate;
       end
       else
           drawings.freedwgvars;
       if assigned(FreEditorProc)then
                                     FreEditorProc;
       if assigned(ReturnToDefaultProc)then
                                           ReturnToDefaultProc(drawings.GetUnitsFormat);
       ZCMsgCallBackInterface.TextMessage('Закрыто',TMWOQuickly);
       ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
       //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
  end;
end;
procedure TZCADMainWindow.CloseDWGPageInterf(Sender: TObject);
begin
     CloseDWGPage(Sender);
end;

function TZCADMainWindow.CloseDWGPage(Sender: TObject):integer;
var
   wa:TGeneralViewArea;
   ClosedDWG:PTZCADDrawing;
   //i:integer;
begin
  Closeddwg:=nil;
  wa:=TGeneralViewArea(FindComponentByType(TTabSheet(sender),TGeneralViewArea));
  if wa<>nil then
                      Closeddwg:=PTZCADDrawing(wa.PDWG);
  result:=_CloseDWGPage(ClosedDWG,Sender);

end;
procedure TZCADMainWindow.PageControlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
begin
  I:=(Sender as TPageControl).IndexOfPageAt{TabIndexAtClientPos}(classes.Point(X,Y));
  if i>-1 then
  if ssMiddle in Shift then
  if (Sender is TPageControl) then
                                  CloseDWGPage((Sender as TPageControl).Pages[I]);
end;
procedure TZCADMainWindow.ShowFastMenu(Sender: TObject);
begin
     ShowFMenu;
end;
procedure TZCADMainWindow.DockMasterCreateControl(Sender: TObject; aName: string; var
  AControl: TControl; DoDisableAutoSizing: boolean);
  procedure CreateForm(Caption: string; NewBounds: TRect);
  begin
       begin
           AControl:=tform.create(Application);
           AControl.Name:=aname;
           Acontrol.Caption:=caption;
           Acontrol.BoundsRect:=NewBounds;
       end;
  end;

begin
  // first check if the form already exists
  // the LCL Screen has a list of all existing forms.
  // Note: Remember that the LCL allows as form names only standard
  // pascal identifiers and compares them case insensitive
  AControl:=Screen.FindForm(aName);
  if acontrol=nil then
                      begin
                           acontrol:=DockMaster.FindControl(aname);
                      end;
  if AControl<>nil then begin
    // if it already exists, just disable autosizing if requested
    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
    exit;
  end;
  aControl:=CreateZCADControl(aName,true);
  if assigned(aControl)then
  if not DoDisableAutoSizing then
                               Acontrol.EnableAutoSizing;
end;

procedure LoadLayoutFromFile(Filename: string);
var
  XMLConfig: TXMLConfigStorage;
begin
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create(Filename,True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed

      {if assigned(ZCADMainWindow.updatesbytton) then
        ZCADMainWindow.updatesbytton.Clear;
      if assigned(ZCADMainWindow.updatescontrols) then
        ZCADMainWindow.updatescontrols.Clear;}

      DockMaster.LoadLayoutFromConfig(XMLConfig,false);
      DockMaster.LoadSettingsFromConfig(XMLConfig);
      ToolBarsManager.RestoreToolBarsFromConfig(ZCADMainWindow,XMLConfig);
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
end;
function LoadLayout_com(Operands:pansichar):GDBInteger;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
  s:string;
begin
  if Operands='' then
                     filename:=sysvar.PATH.LayoutFile^
                 else
                     begin
                     s:=Operands;
                     filename:={utf8tosys}(ProgramPath+'components/'+s);
                     end;
  if not fileexists(filename) then
                              filename:={utf8tosys}(ProgramPath+'components/defaultlayout.xml');
  LoadLayoutFromFile(Filename);
  exit;
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create(Filename,True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed
      DockMaster.LoadLayoutFromConfig(XMLConfig,true);
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
                            ZCMsgCallBackInterface.TextMessage(rsLayoutLoad+' '+Filename+':'#13+E.Message,TMWOShowError);
      //MessageDlg('Error',
      //  'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
      //  [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;
procedure TZCADMainWindow.setnormalfocus(Sender: TObject;GUIAction:TZMessageID);
begin
  if GUIAction=ZMsgID_GUIActionSetNormalFocus then
    begin
      if assigned(cmdedit) then
      if cmdedit.Enabled then
      if cmdedit.{IsControlVisible}IsVisible then
      if cmdedit.CanFocus then
      begin
           cmdedit.SetFocus;
      end;
    end;
end;
procedure TZCADMainWindow.InitSystemCalls;
var tm:tmethod;
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
  AddOneObjectProc:=self.addoneobject;
  SetVisuaProplProc:=self.setvisualprop;
  ZCMsgCallBackInterface.RegisterHandler_GUIAction(self.UpdateVisible);
  //UpdateVisibleProc:=UpdateVisible;
  ProcessFilehistoryProc:=self.processfilehistory;
  ZCMsgCallBackInterface.RegisterHandler_BeforeShowModal(ShowAllCursors);
  ZCMsgCallBackInterface.RegisterHandler_AfterShowModal(RestoreCursors);
  commandmanager.OnCommandRun:=processcommandhistory;
  AppCloseProc:=asynccloseapp;
  ZCMsgCallBackInterface.RegisterHandler_GUIAction(self.setnormalfocus);
  //uzcinterface.SetNormalFocus:=self.setnormalfocus;
  ZCMsgCallBackInterface.RegisterHandler_GUIAction(self.waSetObjInsp);
  {tm.Code:=pointer(self.waSetObjInsp);
  tm.Data:=@self;;
  tmethod(waSetObjInspProc):=tm;}
end;

procedure TZCADMainWindow.LoadActions;
var
   i:integer;
begin
  ToolBarsManager.LoadActions(ProgramPath+'menu/actionscontent.xml');
  ToolBarsManager.LoadActions(ProgramPath+'menu/elactionscontent.xml');
  StandartActions.OnUpdate:=ActionUpdate;

  for i:=low(FileHistory) to high(FileHistory) do
  begin
       FileHistory[i]:=TmyAction.Create(self);
  end;
  for i:=low(OpenedDrawings) to high(OpenedDrawings) do
  begin
       OpenedDrawings[i]:=TmyAction.Create(self);
       OpenedDrawings[i].visible:=false;
  end;
  for i:=low(CommandsHistory) to high(CommandsHistory) do
  begin
       CommandsHistory[i]:=TmyAction.Create(self);
       CommandsHistory[i].visible:=false;
  end;
end;

procedure TZCADMainWindow.CreateInterfaceLists;
begin
  updatesbytton:=tlist.Create;
  updatescontrols:=tlist.Create;
end;

procedure TZCADMainWindow.FillColorCombo(cb:TCustomComboBox);
var
   i:integer;
   ts:string;
begin
  cb.items.AddObject(rsByBlock, TObject(ClByBlock));
  cb.items.AddObject(rsByLayer, TObject(ClByLayer));
  for i := 1 to 7 do
  begin
       ts:=palette[i].name;
       cb.items.AddObject(ts, TObject(i));
  end;
  cb.items.AddObject(rsSelectColor, TObject(ClSelColor));
end;

procedure TZCADMainWindow.FillLTCombo(cb:TCustomComboBox);
begin
  cb.items.AddObject(rsByBlock, TObject(0));
end;

procedure TZCADMainWindow.FillLWCombo(cb:TCustomComboBox);
var
   i:integer;
begin
  cb.items.AddObject(rsByLayer, TObject(LnWtByLayer));
  cb.items.AddObject(rsByBlock, TObject(LnWtByBlock));
  cb.items.AddObject(rsdefault, TObject(LnWtByLwDefault));
  for i := low(lwarray) to high(lwarray) do
  begin
  s:=GetLWNameFromN(i);
       cb.items.AddObject(s, TObject(lwarray[i]));
  end;
end;
procedure TZCADMainWindow.CreateAnchorDockingInterface;
var
  action: tmyaction;
begin
  {Настройка DragManager чтоб срабатывал попозже}
  DragManager.DragImmediate:=false;
  DragManager.DragThreshold:=32;

  {Наполняем статусную строку}
  ToolBarD.ButtonHeight:=sysvar.INTF.INTF_DefaultControlHeight^;
  CreateHTPB(ToolBarD);//поле отображения координат progressbar
  ToolBarsManager.AddContentToToolbar(ToolBarD,'Status');//переносим туда то что есть на тулбаре 'Status'

  {Запрещаем влючать-выключать тулбар 'Status', он показывается всегда}
  action:=tmyaction(StandartActions.ActionByName(ToolBarNameToActionName('Status')));
  if assigned(action) then
    begin
      action.Enabled:=false;
      action.Checked:=true;
      action.pfoundcommand:=nil;
      action.command:='';
      action.options:='';
    end;

  {Создаем на ToolBarD переключатель рабочих пространств}
  if assigned(LayoutBox) then
    ZCMsgCallBackInterface.TextMessage(format(rsReCreating,['LAYOUTBOX']),TMWOShowError);
  CreateLayoutbox(ToolBarD);
  LayoutBox.Parent:=ToolBarD;
  LayoutBox.AutoSize:=false;
  LayoutBox.Width:=200;
  LayoutBox.Align:=alRight;


  {Наcтраиваем докинг}
  DockMaster.SplitterClass:=TmyAnchorDockSplitter;
  DockMaster.ManagerClass:=TAnchorDockManager;
  DockMaster.OnCreateControl:=DockMasterCreateControl;
  {Делаем AnchorDockPanel1 докабельной}
  DockMaster.MakeDockPanel(AnchorDockPanel1,admrpChild);
  DockMaster.OnShowOptions:=ShowAnchorDockOptions;
  {Грузим раскладку окон}
  if not sysparam.noloadlayout then
    LoadLayout_com(EmptyCommandOperands);

  if sysparam.noloadlayout then
  begin
       DockMaster.ShowControl('CommandLine', true);
       DockMaster.ShowControl('ObjectInspector', true);
       DockMaster.ShowControl('PageControl', true);
  end;
end;

procedure myDumpAddr(Addr: Pointer;var f:system.text);
//var
  //func,source:shortstring;
  //line:longint;
  //FoundLine:boolean;
begin
    //BackTraceStrFunc:=StoreBackTraceStrFunc;//this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  try
    WriteLn(f,BackTraceStrFunc(Addr));
  except
    writeLn(f,SysBackTraceStr(Addr));
  end;
end;


procedure MyDumpExceptionBackTrace(var f:system.text);
var
  FrameCount: integer;
  Frames: PPointer;
  FrameNumber:Integer;
begin
  WriteLn(f,'Stack trace:');
  myDumpAddr(ExceptAddr,f);
  FrameCount:=ExceptFrameCount;
  Frames:=ExceptFrames;
  for FrameNumber := 0 to FrameCount-1 do
    myDumpAddr(Frames[FrameNumber],f);
end;

procedure TZCADMainWindow.ZcadException(Sender: TObject; E: Exception);
var
  f:system.text;
  crashreportfilename,errmsg:shortstring;
  //ST:TSystemTime;
  //i:integer;
begin
     crashreportfilename:=TempPath+'zcadcrashreport.txt';
     system.Assign(f,crashreportfilename);
     if FileExists(crashreportfilename) then
                                            system.Append(f)
                                        else
                                            system.Rewrite(f);
     WriteLn(f,'');WriteLn(f,'ZCAD crashed((');WriteLn(f,'');
     myDumpExceptionBackTrace(f);
     system.close(f);

     system.Assign(f,crashreportfilename);
     system.Append(f);
     WriteLn(f);
     WriteLn(f,'Latest log:');
     programlog.WriteLatestToFile(f);
     WriteLn(f,'Log end.');
     system.close(f);

     system.Assign(f,crashreportfilename);
     system.Append(f);
     WriteLn(f);
     WriteLn(f,'Build and runtime info:');
     Write(f,'  ZCAD ');WriteLn(f,sysvar.SYS.SYS_Version^);
     Write(f,'  Build with ');Write(f,sysvar.SYS.SSY_CompileInfo.SYS_Compiler);Write(f,' v');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerVer);
     Write(f,'  Target CPU: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU);
     Write(f,'  Target OS: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS);
     Write(f,'  Compile date: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileDate);
     Write(f,'  Compile time: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileTime);
     Write(f,'  LCL version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_LCLVersion);
     Write(f,'  Environment version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion);
     Write(f,'  Program  path: ');WriteLn(f,ProgramPath);
     Write(f,'  Temporary  path: ');WriteLn(f,TempPath);
     WriteLn(f,'end.');
     system.close(f);

     errmsg:=DateTimeToStr(Now);
     system.Assign(f,crashreportfilename);
     system.Append(f);
     WriteLn(f);
     WriteLn(f,'Date:');
     WriteLn(f,errmsg);
     WriteLn(f,'______________________________________________________________________________________');
     system.close(f);
     errmsg:='ZCAD raised exception class "'+E.Message+'"'#13#10#13#10'A crash report generated (stack trace and latest log).'#13#10'Please send "'
             +crashreportfilename+'" file at zamtmn@yandex.ru'#13#10#13#10'Attempt to continue running?';
     if MessageDlg(errmsg,mtError,[mbYes, mbAbort],0)=mrAbort then
                                                                  halt(0);
end;
function TZCADMainWindow.CreateZCADControl(aName: string;DoDisableAlign:boolean=false):TControl;
var
  //pint:PGDBInteger;
  TB:TToolBar;
  tbdesk:string;
  ta:TmyAction;
  //TempForm:TForm;
  PFID:PTFormInfoData;
begin
  ta:=tmyaction(self.StandartActions.ActionByName('ACN_Show_'+aname));
  if ta<>nil then
                 ta.Checked:=true;
  if ZCADGUIManager.GetZCADFormInfo(aname,PFID) then
  begin
       aname:=aname;
       if assigned(PFID^.CreateProc)then
                                       result:=PFID^.CreateProc
                                   else
                                       begin
                                       result:=Tform(PFID^.FormClass.NewInstance);
                                       tobject(PFID.PInstanceVariable^):=result;
                                       end;
       if DoDisableAlign then
                             if result is TWinControl then
                                                          TWinControl(result).DisableAlign;
       if result is TCustomForm then
       begin
         if PFID^.DesignTimeForm then
                                    TCustomForm(result).Create(Application)
                                 else
                                    TCustomForm(result).CreateNew(Application);
       end;
       //tobject(PFID.PInstanceVariable^):=result;
       result.Caption:=PFID.FormCaption;
       result.Name:=aname;
       if @PFID.SetupProc<>nil then
                                  PFID.SetupProc(result);
  end
  else
  begin
    //tbdesk:=self.findtoolbatdesk(aName);
    //if tbdesk=''then
      ZCMsgCallBackInterface.TextMessage(format(rsFormNotFound,[aName]),TMWOShowError);
    result:=nil;
  end;
end;


procedure ZCADMainPanelSetupProc(Form:TControl);
begin
  Tform(Form).BorderWidth:=0;

  ZCADMainWindow.DHPanel:=TPanel.Create(Tform(Form));
  ZCADMainWindow.DHPanel.Align:=albottom;
  ZCADMainWindow.DHPanel.BevelInner:=bvNone;
  ZCADMainWindow.DHPanel.BevelOuter:=bvNone;
  ZCADMainWindow.DHPanel.BevelWidth:=1;
  ZCADMainWindow.DHPanel.AutoSize:=true;
  ZCADMainWindow.DHPanel.Parent:=ZCADMainWindow.MainPanel;

  ZCADMainWindow.VScrollBar:=TScrollBar.create(ZCADMainWindow.MainPanel);
  ZCADMainWindow.VScrollBar.Align:=alright;
  ZCADMainWindow.VScrollBar.kind:=sbVertical;
  ZCADMainWindow.VScrollBar.OnScroll:=ZCADMainWindow._scroll;
  ZCADMainWindow.VScrollBar.Enabled:=false;
  ZCADMainWindow.VScrollBar.Parent:=ZCADMainWindow.MainPanel;

  with TMySpeedButton.Create(ZCADMainWindow.DHPanel) do
  begin
       Align:=alRight;
       Parent:=ZCADMainWindow.DHPanel;
       width:=ZCADMainWindow.VScrollBar.Width;
       onclick:=ZCADMainWindow.ShowFastMenu;
  end;

  ZCADMainWindow.HScrollBar:=TScrollBar.create(ZCADMainWindow.DHPanel);
  ZCADMainWindow.HScrollBar.Align:=alClient;
  ZCADMainWindow.HScrollBar.kind:=sbHorizontal;
  ZCADMainWindow.HScrollBar.OnScroll:=ZCADMainWindow._scroll;
  ZCADMainWindow.HScrollBar.Enabled:=false;
  ZCADMainWindow.HScrollBar.Parent:=ZCADMainWindow.DHPanel;

  ZCADMainWindow.PageControl:=TmyPageControl.Create(ZCADMainWindow.MainPanel);
  ZCADMainWindow.PageControl.Constraints.MinHeight:=32;
  ZCADMainWindow.PageControl.Parent:=ZCADMainWindow.MainPanel;
  ZCADMainWindow.PageControl.Align:=alClient;
  ZCADMainWindow.PageControl.OnChange:=ZCADMainWindow.ChangedDWGTabCtrl;
  ZCADMainWindow.PageControl.BorderWidth:=0;
  if assigned(SysVar.INTF.INTF_DwgTabsPosition) then
  begin
       case SysVar.INTF.INTF_DwgTabsPosition^ of
                                                TATop:ZCADMainWindow.PageControl.TabPosition:=tpTop;
                                                TABottom:ZCADMainWindow.PageControl.TabPosition:=tpBottom;
                                                TALeft:ZCADMainWindow.PageControl.TabPosition:=tpLeft;
                                                TARight:ZCADMainWindow.PageControl.TabPosition:=tpRight;
       end;
  end;
  if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then
  begin
       if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
                                                      ZCADMainWindow.PageControl.Options:=ZCADMainWindow.PageControl.Options+[nboShowCloseButtons]
                                                  else
                                                      ZCADMainWindow.PageControl.Options:=ZCADMainWindow.PageControl.Options-[nboShowCloseButtons]
  end
  else
      ZCADMainWindow.PageControl.Options:=[nboShowCloseButtons];
  ZCADMainWindow.PageControl.OnCloseTabClicked:=ZCADMainWindow.CloseDWGPageInterf;
  ZCADMainWindow.PageControl.OnMouseDown:=ZCADMainWindow.PageControlMouseDown;
  ZCADMainWindow.PageControl.ShowTabs:=SysVar.INTF.INTF_ShowDwgTabs^;
end;
procedure TZCADMainWindow.TBActionCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _action:TZAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');
  _action:=TZAction(StandartActions.ActionByName(ActionName));
  with TToolButton.Create(tb) do
  begin
    Action:=_action;
    ShowCaption:=false;
    ShowHint:=true;
    if assigned(_action) then
      Caption:=_action.imgstr;
    Parent:=tb;
    Visible:=true;
  end;
end;

procedure TZCADMainWindow.TBButtonCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _action:TZAction;
  command,img,_hint:string;
  CreatedButton:TmyCommandToolButton;
begin
  command:=getAttrValue(aNode,'Command','');
  img:=getAttrValue(aNode,'Img','');
  _hint:=getAttrValue(aNode,'Hint','');

  CreatedButton:=TmyCommandToolButton.Create(tb);
  CreatedButton.FCommand:=command;
   if _hint<>'' then
   begin
     _hint:=InterfaceTranslate('hint_panel~'+command,hint);
     CreatedButton.hint:=_hint;
     CreatedButton.ShowHint:=true;
   end;
  SetImage(tb,CreatedButton,img,true,'button_command~'+command);
  CreatedButton.Parent:=tb;
end;
procedure TZCADMainWindow.TTBRegisterInAPPFunc(aTBNode: TDomNode;aName,aType: string;Data:Pointer);
var
    pm1:TMenuItem;
    action:tmyaction;
begin
  action:=TmyAction.Create(self);
  action.Name:=ToolBarNameToActionName(aName);
  action.Caption:=aName;
  action.command:='ShowToolBar';
  action.options:=aName;
  action.DisableIfNoHandler:=false;
  self.StandartActions.AddMyAction(action);
  action.pfoundcommand:=commandmanager.FindCommand('ShowToolBar');
  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=action;
  TMenuItem(Data).Add(pm1);
end;

procedure TZCADMainWindow.ZActionsReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
var
  action:tmyaction;
  actioncommand,actionshortcut:string;
begin
  action:=TmyAction.Create(self);
  action.Name:=uppercase(getAttrValue(aNode,'Name',''));
  action.Caption:=getAttrValue(aNode,'Caption','');
  action.Caption:=InterfaceTranslate(action.Name+'~caption',action.Caption);
  action.Hint:=getAttrValue(aNode,'Hint','');
  if action.Hint<>'' then
                         action.Hint:=InterfaceTranslate(action.Name+'~hint',action.Hint)
                     else
                         action.Hint:=action.Caption;
  actionshortcut:=getAttrValue(aNode,'ShortCut','');
  if actionshortcut<>'' then
                          action.ShortCut:=TextToShortCut(actionshortcut);
  actioncommand:=getAttrValue(aNode,'Command','');
  ParseCommand(actioncommand,action.command,action.options);
  action.Category:=getAttrValue(aNode,'Category',CategoryOverrider);
  action.DisableIfNoHandler:=false;
  action.ActionList:=actlist;
  TmyActionList(actlist).SetImage(getAttrValue(aNode,'Img',''),action.Name+'~textimage',TZAction(action));
  action.pfoundcommand:=commandmanager.FindCommand(uppercase(action.command));
end;
procedure TZCADMainWindow.ZAction2VariableReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
var
  va:TmyVariableAction;
  actionvariable,actionshortcut:string;
  mask:DWord;
begin
  va:=TmyVariableAction.create(self);
  va.Name:=uppercase(getAttrValue(aNode,'Name',''));
  va.Caption:=getAttrValue(aNode,'Caption','');
  va.Caption:=InterfaceTranslate(va.Name+'~caption',va.Caption);
  va.Hint:=getAttrValue(aNode,'Hint','');
  if va.Hint<>'' then
                     va.Hint:=InterfaceTranslate(va.Name+'~hint',va.Hint)
                 else
                     va.Hint:=va.Caption;
  actionshortcut:=getAttrValue(aNode,'ShortCut','');
  if actionshortcut<>'' then
                            va.ShortCut:=TextToShortCut(actionshortcut);
  actionvariable:=getAttrValue(aNode,'Variable','');
  mask:=getAttrValue(aNode,'Mask',0);

  va.AssignToVar(actionvariable,mask);

  TmyActionList(actlist).SetImage(getAttrValue(aNode,'Img',''),va.Name+'~textimage',TZAction(va));

  va.AutoCheck:=true;
  va.Enabled:=true;
  va.ActionList:=actlist;
end;
procedure TZCADMainWindow.TBLayerComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);

  LayerBox:=TZCADLayerComboBox.Create(tb);
  LayerBox.ImageList:=ImagesManager.IconList;

  LayerBox.Index_Lock:=ImagesManager.GetImageIndex('lock');
  LayerBox.Index_UnLock:=ImagesManager.GetImageIndex('unlock');
  LayerBox.Index_Freze:=ImagesManager.GetImageIndex('freze');;
  LayerBox.Index_UnFreze:=ImagesManager.GetImageIndex('unfreze');
  LayerBox.Index_ON:=ImagesManager.GetImageIndex('on');
  LayerBox.Index_OFF:=ImagesManager.GetImageIndex('off');

  LayerBox.fGetLayerProp:=self.GetLayerProp;
  LayerBox.fGetLayersArray:=self.GetLayersArray;
  LayerBox.fClickOnLayerProp:=self.ClickOnLayerProp;

  LayerBox.Width:=_Width;

  if _hint<>''then
  begin
       _hint:=InterfaceTranslate('hint_panel~LAYERCOMBOBOX',_hint);
       LayerBox.hint:=(_hint);
       LayerBox.ShowHint:=true;
  end;
  LayerBox.AutoSize:=false;
  LayerBox.Parent:=tb;
  LayerBox.Height:=10;
  updatescontrols.Add(LayerBox);
end;
procedure TZCADMainWindow.TBColorComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  ColorBox:=CreateCBox('ColorComboBox',tb,TSupportColorCombo.ColorBoxDrawItem,ChangeCColor,DropDownColor,DropUpColor,FillColorCombo,_Width,_hint);
end;
procedure TZCADMainWindow.TBLTypeComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LTypeBox:=CreateCBox('LTypeComboBox',tb,TSupportLineTypeCombo.LTypeBoxDrawItem,ChangeLType,DropDownLType,DropUpLType,FillLTCombo,_Width,_hint);
end;
procedure TZCADMainWindow.TBLineWComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  LineWBox:=CreateCBox('LineWComboBox',tb,TSupportLineWidthCombo.LineWBoxDrawIVarsItem,ChangeCLineW,DropDownColor,DropUpColor,FillLWCombo,_Width,_hint);
end;
procedure TZCADMainWindow.TBTStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  TStyleBox:=CreateCBox('TStyleComboBox',tb,TSupportTStyleCombo.DrawItemTStyle,TSupportTStyleCombo.ChangeLType,TSupportTStyleCombo.DropDownTStyle,TSupportTStyleCombo.CloseUpTStyle,TSupportTStyleCombo.FillLTStyle,_Width,_hint);
end;
procedure TZCADMainWindow.TBDimStyleComboBoxCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _hint:string;
  _Width:integer;
begin
  _hint:=getAttrValue(aNode,'Hint','');
  _Width:=getAttrValue(aNode,'Width',100);
  DimStyleBox:=CreateCBox('DimStyleComboBox',tb,TSupportDimStyleCombo.DrawItemTStyle,TSupportDimStyleCombo.ChangeLType,TSupportDimStyleCombo.DropDownTStyle,TSupportDimStyleCombo.CloseUpTStyle,TSupportDimStyleCombo.FillLTStyle,_Width,_hint);
end;

function TZCADMainWindow.TBCreateZCADToolBar(aName,atype: string):TToolBar;
begin
  result:=TmyToolBar.Create(self);
  ToolBarsManager.SetupDefaultToolBar(aName,atype, result);
end;

procedure TZCADMainWindow.TBVariableCreateFunc(aNode: TDomNode; TB:TToolBar);
var
  _varname,_img,_hint,_shortcut:string;
  _mask:integer;
  b:TmyVariableToolButton;
  shortcut:TShortCut;
  baction:TmyButtonAction;
begin
  _varname:=getAttrValue(aNode,'VarName','');
  _img:=getAttrValue(aNode,'Img','');
  _hint:=getAttrValue(aNode,'Hint','');
  _shortcut:=getAttrValue(aNode,'ShortCut','');
  _mask:=getAttrValue(aNode,'Mask',0);

  b:=TmyVariableToolButton.Create(tb);
  b.Style:=tbsCheck;
  TmyVariableToolButton(b).AssignToVar(_varname,_mask);
  if _hint<>''then
  begin
    _hint:=InterfaceTranslate('hint_panel~'+_varname,_hint);
    b.hint:=(_hint);
    b.ShowHint:=true;
  end;
  SetImage(tb,b,_img,false,'button_variable~'+_varname);
  //AddToBar(tb,b);
  b.Parent:=tb;
  updatesbytton.Add(b);
  if _shortcut<>'' then
  begin
    shortcut:=TextToShortCut(_shortcut);
    if shortcut>0 then
    begin
      baction:=TmyButtonAction.Create(StandartActions);
      baction.button:=b;
      baction.ShortCut:=shortcut;
      StandartActions.AddMyAction(baction);
    end;
  end;
end;


procedure TZCADMainWindow._onCreate(Sender: TObject);
begin
  {
  //this unneed after fpc rev 31026 see http://bugs.freepascal.org/view.php?id=13518
  StoreBackTraceStrFunc:=BackTraceStrFunc;
  BackTraceStrFunc:=@SysBackTraceStr;
  }
  {$if FPC_FULlVERSION>=30002}
  AllowReuseOfLineInfoData:=false;
  {$endif}
  ZCADGUIManager.RegisterZCADFormInfo('PageControl',rsDrawingWindowWndName,Tform,types.rect(200,200,600,500),ZCADMainPanelSetupProc,nil,@ZCADMainWindow.MainPanel);
  FAppProps := TApplicationProperties.Create(Self);
  FAppProps.OnException := ZcadException;
  FAppProps.CaptureExceptions := True;

  UniqueInstanceBase.FIPCServer.OnMessage:=IPCMessage;
   sysvar.INTF.INTF_DefaultControlHeight^:=sysparam.defaultheight;

  //DecorateSysTypes;
  self.onclose:=self.FormClose;
  self.onkeydown:=self.mykeypress;
  self.KeyPreview:=true;
  application.OnIdle:=self.idle;
  SystemTimer:=TTimer.Create(self);
  SystemTimer.Interval:=1000;
  SystemTimer.Enabled:=true;
  SystemTimer.OnTimer:=self.generaltick;

  InitSystemCalls;

  ImagesManager.ScanDir(ProgramPath+'images/');
  ImagesManager.LoadAliasesDir(ProgramPath+'images/navigator.ima');

  StandartActions:=TmyActionList.Create(self);
  if not assigned(StandartActions.Images) then
                             StandartActions.Images:=TImageList.Create(StandartActions);
  StandartActions.brocenicon:=StandartActions.LoadImage(ProgramPath+
  'menu/BMP/noimage.bmp');


  ToolBarsManager:=TToolBarsManager.create(self,StandartActions,sysvar.INTF.INTF_DefaultControlHeight^);
  ToolBarsManager.RegisterTBItemCreateFunc('Separator',ToolBarsManager.CreateDefaultSeparator);
  ToolBarsManager.RegisterTBItemCreateFunc('Action',TBActionCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('Button',TBButtonCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LayerComboBox',TBLayerComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('ColorComboBox',TBColorComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LTypeComboBox',TBLTypeComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('LineWComboBox',TBLineWComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('TStyleComboBox',TBTStyleComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('DimStyleComboBox',TBDimStyleComboBoxCreateFunc);
  ToolBarsManager.RegisterTBItemCreateFunc('Variable',TBVariableCreateFunc);

  ToolBarsManager.RegisterActionCreateFunc('Group',ToolBarsManager.DefaultActionsGroupReader);
  ToolBarsManager.RegisterActionCreateFunc('ZAction',ZActionsReader);
  ToolBarsManager.RegisterActionCreateFunc('ZAction2Variable',ZAction2VariableReader);

  ToolBarsManager.RegisterTBCreateFunc('ToolBar',TBCreateZCADToolBar);
  ToolBarsManager.LoadToolBarsContent(ProgramPath+'menu/toolbarscontent.xml');

  LoadActions;
  toolbars:=tstringlist.Create;
  toolbars.Sorted:=true;
  CreateInterfaceLists;

  ToolBarsManager.RegisterMenuCreateFunc('MainMenuItem',ZMainMenuItemReader);
  ToolBarsManager.RegisterMenuCreateFunc('PopUpMenu',ZPopUpMenuReader);
  ToolBarsManager.RegisterMenuCreateFunc('Action',ToolBarsManager.CreateDefaultMenuAction);
  ToolBarsManager.RegisterMenuCreateFunc('Separator',ToolBarsManager.CreateDefaultMenuSeparator);
  ToolBarsManager.RegisterMenuCreateFunc('FileHistory',ZMainMenuFileHistory);
  ToolBarsManager.RegisterMenuCreateFunc('LastCommands',ZMainMenuCommandsHistory);
  ToolBarsManager.RegisterMenuCreateFunc('Command',ZMainMenuCommand);
  ToolBarsManager.RegisterMenuCreateFunc('Toolbars',ZMainMenuToolBars);
  ToolBarsManager.RegisterMenuCreateFunc('Drawings',ZMainMenuDrawings);
  ToolBarsManager.RegisterMenuCreateFunc('SampleFiles',ZMainMenuSampleFiles);
  ToolBarsManager.RegisterMenuCreateFunc('DebugFiles',ZMainMenuDebugFiles);
  ToolBarsManager.RegisterMenuCreateFunc('CreateMenu',ZMainCreateMenu);
  ToolBarsManager.RegisterMenuCreateFunc('SetMainMenu',ZMainSetMenu);

  ToolBarsManager.LoadMenus(ProgramPath+'menu/menuscontent.xml');

  CreateAnchorDockingInterface;
end;

procedure TZCADMainWindow.ZMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
 var
  CreatedMenuItem:TMenuItem;
  line:string;
  TBSubNode:TDomNode;
  mcf:TMenuCreateFunc;
begin
    CreatedMenuItem:=TMenuItem.Create(application);
    line:=getAttrValue(aNode,'Name','');
    if RootMenuItem=nil then
      CreatedMenuItem.Name:=MenuNameModifier+line;
    line:=InterfaceTranslate('menu~'+line,line);
    CreatedMenuItem.Caption:=line;
    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        ToolBarsManager.TryRunMenuCreateFunc(TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    if assigned(RootMenuItem) then
    begin
      if RootMenuItem is TMenuItem then
        RootMenuItem.Add(CreatedMenuItem)
      else
        TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
    end;
end;


procedure TZCADMainWindow.ZPopUpMenuReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
 var
  CreatedMenuItem:TPopupMenu;
  line:string;
  TBSubNode:TDomNode;
  mcf:TMenuCreateFunc;
begin
    CreatedMenuItem:=TmyPopupMenu.Create(application);
    line:=getAttrValue(aNode,'Name','');
    CreatedMenuItem.Name:=MenuNameModifier+line;
    CreatedMenuItem.Images := actlist.Images;

    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        ToolBarsManager.TryRunMenuCreateFunc(TBSubNode.NodeName,TBSubNode,actlist,tmenuitem(CreatedMenuItem));
        TBSubNode:=TBSubNode.NextSibling;
      end;
    cxmenumgr.RegisterLCLMenu(CreatedMenuItem);
end;

procedure TZCADMainWindow.ZMainMenuFileHistory(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
 i:integer;
 pstr:pstring;
 line:string;
 CreatedMenuItem:TMenuItem;
begin
  for i:=low(FileHistory) to high(FileHistory) do
  begin
       pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
       if assigned(pstr)then
                            line:=pstr^
                        else
                            line:='';
       if line<>''then
                              begin
                              FileHistory[i].SetCommand(line,'Load',line);
                              FileHistory[i].visible:=true;
                              end
                        else
                            begin
                            FileHistory[i].SetCommand(line,'',line);
                            FileHistory[i].visible:=false
                            end;
       CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
       CreatedMenuItem.Action:=FileHistory[i];
       RootMenuItem.Add(CreatedMenuItem);
  end;
end;

procedure TZCADMainWindow.ZMainMenuCommandsHistory(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
 i:integer;
 pstr:pstring;
 line:string;
 CreatedMenuItem:TMenuItem;
begin
  for i:=low(CommandsHistory) to high(CommandsHistory) do
  begin
       CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
       CreatedMenuItem.Action:=CommandsHistory[i];
       if RootMenuItem is TMenuItem then
                              RootMenuItem.Add(CreatedMenuItem)
                          else
                              TMyPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
  end;
end;

procedure TZCADMainWindow.ZMainMenuCommand(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  CreatedMenuItem:TmyMenuItem;
  actioncommand,actionshortcut:string;
  captionstr,comstr:string;
begin
  captionstr:=getAttrValue(aNode,'Caption','');
  comstr:=getAttrValue(aNode,'Command','');
  CreatedMenuItem:=TmyMenuItem.Create(RootMenuItem,InterfaceTranslate('menucommand~'+comstr,captionstr),comstr);
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
end;

procedure TZCADMainWindow.ZMainMenuToolBars(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  ToolBarsManager.EnumerateToolBars(TTBRegisterInAPPFunc,RootMenuItem);
end;

procedure TZCADMainWindow.ZMainMenuDrawings(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  i:integer;
  CreatedMenuItem:TMenuItem;
begin
  for i:=low(OpenedDrawings) to high(OpenedDrawings) do
  begin
    CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
    CreatedMenuItem.Action:=OpenedDrawings[i];
    RootMenuItem.Add(CreatedMenuItem);
  end;
end;

procedure bugfileiterator(filename:GDBString);
var
    myitem:TmyMenuItem;
begin
  myitem:=TmyMenuItem.Create(localpm.localpm,'**'+extractfilename(filename),'Load('+filename+')');
  localpm.localpm.SubMenuImages:=ImagesManager.IconList;
  myitem.ImageIndex:=localpm.ImageIndex;
  localpm.localpm.Add(myitem);
end;

procedure TZCADMainWindow.ZMainMenuSampleFiles(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  i:integer;
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex('Dxf');
  FromDirIterator(expandpath('*/sample'),'*.dxf','',@bugfileiterator,nil);
  FromDirIterator(expandpath('*/sample'),'*.dwg','',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;

procedure TZCADMainWindow.ZMainMenuDebugFiles(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  i:integer;
begin
  localpm.localpm:=RootMenuItem;
  localpm.ImageIndex:=ImagesManager.GetImageIndex('Dxf');
  FromDirIterator(expandpath('*../errors/'),'*.dxf','',@bugfileiterator,nil);
  localpm.localpm:=nil;
  localpm.ImageIndex:=-1;
end;

procedure TZCADMainWindow.ZMainCreateMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  ppopupmenu:TMenuItem;
  ts:GDBString;
  menuname:string;
  createdmenu:TMenu;
  TBSubNode:TDomNode;
begin

  createdmenu:=TMainMenu.Create(self);
  createdmenu.Images:=actlist.Images;
  createdmenu.Name:=MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''));

  if assigned(aNode) then
    TBSubNode:=aNode.FirstChild;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      ppopupmenu:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(TBSubNode.NodeName)));

      if ppopupmenu<>nil then
                                begin
                                     createdmenu.items.Add(ppopupmenu);
                                end
                            else
                                ZCMsgCallBackInterface.TextMessage(format(rsMenuNotFounf,[ts]),TMWOShowError);

      TBSubNode:=TBSubNode.NextSibling;
    end;
end;

procedure TZCADMainWindow.ZMainSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  self.Menu:=TMainMenu(self.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''))));
end;

procedure TZCADMainWindow.AfterConstruction;

begin
    name:='MainForm';
    OnCreate:=_onCreate;
    inherited;
end;
procedure TZCADMainWindow.SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);
var
    bmp:Graphics.TBitmap;
begin
     if length(img)>1 then
     begin
          if img[1]<>'#' then
                              begin
                              img:={SysToUTF8}(ProgramPath)+'menu/BMP/'+img;
                              bmp:=Graphics.TBitmap.create;
                              bmp.LoadFromFile(img);
                              bmp.Transparent:=true;
                              if not assigned(ppanel.Images) then
                                                                 ppanel.Images:=standartactions.Images;
                              b.ImageIndex:=
                              ppanel.Images.Add(bmp,nil);
                              freeandnil(bmp);
                              //-----------b^.SetImageFromFile(img)
                              end
                          else
                              begin
                              b.caption:=(system.copy(img,2,length(img)-1));
                              b.caption:=InterfaceTranslate(identifer,b.caption);
                              if autosize then
                               if utf8length(img)>3 then
                                                    b.Font.size:=11-utf8length(img);
                              end;
     end;
                              b.Height:=ppanel.ButtonHeight;
                              b.Width:=ppanel.ButtonWidth;
end;
procedure AddToBar(tb:TToolBar;b:TControl);
begin
     if tb.ClientHeight<tb.ClientWidth then
                                                   begin
                                                        //b.Left:=100;
                                                        //b.align:=alLeft
                                                   end
                                               else
                                                   begin
                                                        //b.top:=100;
                                                        //b.align:=alTop;
                                                   end;
    b.Parent:=tb;
end;
function TZCADMainWindow.CreateCBox(CBName:GDBString;owner:TToolBar;DrawItem:TDrawItemEvent;Change,DropDown,CloseUp:TNotifyEvent;Filler:TComboFiller;w:integer;ts:GDBString):TComboBox;
begin
  result:=TComboBox.Create(owner);
  result.Style:=csOwnerDrawFixed;
  SetComboSize(result,sysvar.INTF.INTF_DefaultControlHeight^-6,true);
  result.Clear;
  result.readonly:=true;
  result.DropDownCount:=50;
  if w<>0 then
              result.Width:=w;
  if ts<>''then
  begin
       ts:=InterfaceTranslate('combo~'+CBName,ts);
       result.hint:=(ts);
       result.ShowHint:=true;
  end;

  result.OnDrawItem:=DrawItem;
  result.OnChange:=Change;
  result.OnDropDown:=DropDown;
  result.OnCloseUp:=CloseUp;
  //result.OnMouseLeave:=setnormalfocus;

  if assigned(Filler)then
                         Filler(result);
  result.ItemIndex:=0;

  AddToBar(owner,result);
  updatescontrols.Add(result);
end;
procedure addfiletoLayoutbox(filename:GDBString);
var
    s:string;
begin
     s:=ExtractFileName(filename);
     LayoutBox.AddItem(copy(s,1,length(s)-4),nil);
end;
procedure TZCADMainWindow.CreateLayoutbox(tb:TToolBar);
var
    s:string;
begin
  LayoutBox:=TComboBox.Create(tb);
  LayoutBox.Style:=csDropDownList;
  LayoutBox.Sorted:=true;
  FromDirIterator(ProgramPath+'components/','*.xml','',addfiletoLayoutbox,nil);
  LayoutBox.OnChange:=ChangeLayout;

  s:=extractfilename(sysvar.PATH.LayoutFile^);
  LayoutBox.ItemIndex:=LayoutBox.Items.IndexOf(copy(s,1,length(s)-4));

end;
procedure TZCADMainWindow.ChangeLayout(Sender:Tobject);
var
    s:string;
begin
  s:=ProgramPath+'components/'+LayoutBox.text+'.xml';
  LoadLayoutFromFile(s);
end;

procedure TZCADMainWindow.UpdateControls;
var
    i:integer;
begin
     if assigned(updatesbytton) then
     for i:=0 to updatesbytton.Count-1 do
     begin
          TmyVariableToolButton(updatesbytton[i]).AssignToVar(TmyVariableToolButton(updatesbytton[i]).FVariable,TmyVariableToolButton(updatesbytton[i]).FMask);
     end;
     if assigned(updatescontrols) then
     for i:=0 to updatescontrols.Count-1 do
     begin
          TControl(updatescontrols[i]).Invalidate;
     end;
end;

procedure  TZCADMainWindow.ChangedDWGTabCtrl(Sender: TObject);
var
   ogl:TAbstractViewArea;
begin
     tcomponent(OGL):=FindComponentByType(TPageControl(sender).ActivePage,TAbstractViewArea);
     if assigned(OGL) then
                          OGL.GDBActivate;
     OGL.param.firstdraw:=true;
     OGL.draworinvalidate;
     ReturnToDefaultProc(drawings.GetUnitsFormat);
end;

destructor TZCADMainWindow.Destroy;
begin
    if DockMaster<>nil then
    DockMaster.CloseAll;
    freeandnil(toolbars);
    freeandnil(updatesbytton);
    freeandnil(updatescontrols);
    inherited;
end;
procedure TZCADMainWindow.ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
var
   _disabled:boolean;
   ctrl:TControl;
   ti:integer;
   POGLWndParam:POGLWndtype;
   PSimpleDrawing:PTSimpleDrawing;
begin
     if AAction is TmyAction then
     begin
     Handled:=true;


          if uppercase(TmyAction(AAction).command)='SHOWPAGE' then
          if uppercase(TmyAction(AAction).options)<>'' then
          begin
               if assigned(ZCADMainWindow)then
               if assigned(ZCADMainWindow.PageControl)then
               if ZCADMainWindow.PageControl.ActivePageIndex=strtoint(TmyAction(AAction).options) then
                                                                               TmyAction(AAction).Checked:=true
                                                                           else
                                                                               TmyAction(AAction).Checked:=false;
               exit;
          end;

          if uppercase(TmyAction(AAction).command)='SHOW' then
          if uppercase(TmyAction(AAction).options)<>'' then
          begin
               ctrl:=DockMaster.FindControl(TmyAction(AAction).options);
               if ctrl=nil then
                               begin
                                    if toolbars.Find(TmyAction(AAction).options,ti) then
                                    TmyAction(AAction).Enabled:=false
                               end
                           else
                               begin
                                    TmyAction(AAction).Enabled:=true;
                                    TmyAction(AAction).Checked:=ctrl.IsVisible;
                               end;
               exit;
          end;


     _disabled:=false;
     PSimpleDrawing:=drawings.GetCurrentDWG;
     POGLWndParam:=nil;
     if PSimpleDrawing<>nil then
     if PSimpleDrawing.wa<>nil then
                                POGLWndParam:=@PSimpleDrawing.wa.param;
     if assigned(TmyAction(AAction).pfoundcommand) then
     begin
     if ((GetCommandContext(PSimpleDrawing,POGLWndParam) xor TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)and TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)<>0
          then
              _disabled:=true;


     TmyAction(AAction).Enabled:=not _disabled;
     end;

     end
else if AAction is TmyVariableAction then
     begin
          Handled:=true;
          TmyVariableAction(AAction).AssignToVar(TmyVariableAction(AAction).FVariable,TmyVariableAction(AAction).FMask);
     end;
end;

function TZCADMainWindow.IsShortcut(var Message: TLMKey): boolean;
var
   OldFunction:TIsShortcutFunc;
begin
   TMethod(OldFunction).code:=@TForm.IsShortcut;
   TMethod(OldFunction).Data:=self;
   result:=IsZShortcut(Message,Screen.ActiveControl,cmdedit,OldFunction);
end;

procedure TZCADMainWindow.myKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);
var
   tempkey:word;
   comtext:string;
begin
     if assigned(GetPeditorProc) then
     if GetPeditorProc<>nil then
      begin
           if key=VK_ESCAPE then
                                begin
                                     if assigned(FreEditorProc) then
                                                                    FreEditorProc;
                                     key:=0;
                                     exit;
                                end;
      end;
     if ((ActiveControl<>cmdedit)and(ActiveControl<>HistoryLine)and(ActiveControl<>LayerBox)and(ActiveControl<>LineWBox))then
     begin
     if (ActiveControl is tedit)or (ActiveControl is tmemo)or (ActiveControl is TComboBox)then
                                                                                              exit;
     if assigned(GetPeditorProc) then
     if (GetPeditorProc)<>nil then
     if (ActiveControl=TPropEditor(GetPeditorProc).geteditor) then
                                                            exit;
     end;
     if ((ActiveControl=LayerBox)or(ActiveControl=LineWBox))then
                                                                 begin
                                                                 ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
                                                                 //self.setnormalfocus(nil);
                                                                 end;
     tempkey:=key;

     comtext:='';
     if assigned(cmdedit) then
                              comtext:=cmdedit.text;
     if comtext='' then
     begin
     if assigned(drawings.GetCurrentDWG) then
     if assigned(drawings.GetCurrentDWG.wa.getviewcontrol)then
                    drawings.GetCurrentDWG.wa.myKeyPress(tempkey,shift);
     end
     else
         if key=VK_ESCAPE then
                              cmdedit.text:='';
     if tempkey<>0 then
     begin
        if (tempkey=VK_TAB)and(shift=[ssctrl,ssShift]) then
                                 begin
                                      if assigned(PageControl)then
                                         if PageControl.PageCount>1 then
                                         begin
                                              commandmanager.executecommandsilent('PrevDrawing',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                                              tempkey:=00;
                                         end;
                                 end
        else if (tempkey=VK_TAB)and(shift=[ssctrl]) then
                                 begin
                                      if assigned(PageControl)then
                                         if PageControl.PageCount>1 then
                                         begin
                                              commandmanager.executecommandsilent('NextDrawing',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                                              tempkey:=00;
                                         end;
                                 end
     end;
     if assigned(cmdedit) then
     if tempkey<>0 then
     begin
         tempkey:=key;
         if cmdedit.text='' then
         begin

         end;
     end;
     if tempkey=0 then
                      key:=0;
end;

procedure TZCADMainWindow.CreateHTPB(tb:TToolBar);
begin
  ProcessBar:=TProgressBar.create(tb);
  ProcessBar.Hide;
  ProcessBar.Align:=alLeft;
  ProcessBar.Width:=400;
  ProcessBar.Height:=10;
  ProcessBar.min:=0;
  ProcessBar.max:=0;
  ProcessBar.step:=10000;
  ProcessBar.position:=0;
  ProcessBar.Smooth:=true;
  ProcessBar.Parent:=tb;

  HintText:=TLabel.Create(tb);
  HintText.Align:=alLeft;
  HintText.AutoSize:=false;
  HintText.Width:=400;
  HintText.Height:=10;
  HintText.Layout:=tlCenter;
  HintText.Alignment:=taCenter;
  HintText.Parent:=tb;
end;
procedure TZCADMainWindow.idle(Sender: TObject; var Done: Boolean);
var
   pdwg:PTSimpleDrawing;
   rc:TDrawContext;
begin
     {IFDEF linux}
     UniqueInstanceBase.FIPCServer.PeekMessage(0,true);
     {endif}
     done:=true;
     sysvar.debug.languadedeb.UpdatePO:=_UpdatePO;
     sysvar.debug.languadedeb.NotEnlishWord:=_NotEnlishWord;
     sysvar.debug.languadedeb.DebugWord:=_DebugWord;
     pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg.wa<>nil) then
     begin
     if pdwg.wa.getviewcontrol<>nil then
     begin
              if  pdwg.pcamera.DRAWNOTEND then
                                              begin
                                                   rc:=pdwg.CreateDrawingRC;
                                              pdwg.wa.finishdraw(rc);
                                              done:=false;
                                              end
                                          else
                                              begin
                                                   pdwg.wa.idle(Sender,Done);
                                              end
     end
     end
     else
         SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     if pdwg<>nil then
     if not pdwg^.GetChangeStampt then
                                      SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     if (SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and(commandmanager.pcommandrunning=nil) then
     if (pdwg)<>nil then
     if (pdwg.wa.param.SelDesc.Selectedobjcount=0) then
     begin
          commandmanager.executecommandsilent('QSave(QS)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     end;
     date:=sysutils.date;
     if rt<>SysVar.SYS.SYS_RunTime^ then
                                        begin
                                             if assigned(UpdateObjInspProc)then
                                                                               UpdateObjInspProc;
                                        end;
     rt:=SysVar.SYS.SYS_RunTime^;
     if historychanged then
                           begin
                                historychanged:=false;
                                HistoryLine.SelStart:=utflen;
                                HistoryLine.SelLength:=2;
                           end;
end;
procedure AddToComboIfNeed(cb:tcombobox;name:string;obj:TObject);
var
   i:integer;
begin
     for i:=0 to cb.Items.Count-1 do
       if cb.Items.Objects[i]=obj then
                                      exit;
     cb.items.InsertObject(cb.items.Count-1,name,obj);
end;
procedure TZCADMainWindow.DropDownColor(Sender:Tobject);
begin
     OldColor:=tcombobox(Sender).ItemIndex;
     tcombobox(Sender).ItemIndex:=-1;
end;
procedure TZCADMainWindow.DropUpLType(Sender:Tobject);
begin
     tcombobox(Sender).ItemIndex:=0;
end;

procedure TZCADMainWindow.DropDownLType(Sender:Tobject);
var
   i:integer;
begin
     if drawings.GetCurrentDWG=nil then exit;
     SetcomboItemsCount(tcombobox(Sender),drawings.GetCurrentDWG.LTypeStyleTable.Count+1);
     for i:=0 to drawings.GetCurrentDWG.LTypeStyleTable.Count-1 do
     begin
          tcombobox(Sender).Items.Objects[i]:=tobject(drawings.GetCurrentDWG.LTypeStyleTable.getDataMutable(i));
     end;
     tcombobox(Sender).Items.Objects[drawings.GetCurrentDWG.LTypeStyleTable.Count]:=LTEditor;
end;
procedure TZCADMainWindow.DropUpColor(Sender:Tobject);
begin
     if tcombobox(Sender).ItemIndex=-1 then
                                           tcombobox(Sender).ItemIndex:=OldColor;
end;
procedure TZCADMainWindow.ChangeLType(Sender:Tobject);
var
   {LTIndex,}index:Integer;
   CLTSave,plt:PGDBLtypeProp;
begin
     index:=tcombobox(Sender).ItemIndex;
     plt:=PGDBLtypeProp(tcombobox(Sender).items.Objects[index]);
     //LTIndex:=drawings.GetCurrentDWG.LTypeStyleTable.GetIndexByPointer(plt);
     if plt=nil then
                         exit;
     if plt=lteditor then
                         begin
                              commandmanager.ExecuteCommand('LineTypes',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         end
     else
     begin
     if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
     end
     else
     begin
          CLTSave:=SysVar.dwg.DWG_CLType^;
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
          commandmanager.ExecuteCommand('SelObjChangeLTypeToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CLType^:=CLTSave;
     end;
     end;
     setvisualprop;
     //setnormalfocus(nil);
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
end;

procedure  TZCADMainWindow.ChangeCColor(Sender:Tobject);
var
   ColorIndex,CColorSave,index:Integer;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     ColorIndex:=integer(tcombobox(Sender).items.Objects[index]);
     if ColorIndex=ClSelColor then
                           begin
                               if not assigned(ColorSelectForm)then
                               Application.CreateForm(TColorSelectForm, ColorSelectForm);
                               ShowAllCursors(ColorSelectForm);
                               mr:=ColorSelectForm.run(SysVar.dwg.DWG_CColor^,true){showmodal};
                               if mr=mrOk then
                                              begin
                                              ColorIndex:=ColorSelectForm.ColorInfex;
                                              if assigned(Sender)then
                                              begin
                                              AddToComboIfNeed(tcombobox(Sender),palette[ColorIndex].name,TObject(ColorIndex));
                                              tcombobox(Sender).ItemIndex:=tcombobox(Sender).Items.Count-2;
                                              end;
                                              end
                                          else
                                              begin
                                                   tcombobox(Sender).ItemIndex:=OldColor;
                                                   ColorIndex:=-1;
                                              end;
                               RestoreCursors(ColorSelectForm);
                               freeandnil(ColorSelectForm);
                           end;
     if colorindex<0 then
                         exit;
     if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CColor^:=ColorIndex;
     end
     else
     begin
          CColorSave:=SysVar.dwg.DWG_CColor^;
          SysVar.dwg.DWG_CColor^:=ColorIndex;
          commandmanager.ExecuteCommand('SelObjChangeColorToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CColor^:=CColorSave;
     end;
     setvisualprop;
     //setnormalfocus(nil);
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
end;

procedure  TZCADMainWindow.ChangeCLineW(Sender:Tobject);
var tcl,index:GDBInteger;
begin
  index:=tcombobox(Sender).ItemIndex;
  index:=integer(tcombobox(Sender).items.Objects[index]);
  if drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
  then
  begin
      SysVar.dwg.DWG_CLinew^:=index;
  end
  else
  begin
           begin
                tcl:=SysVar.dwg.DWG_CLinew^;
                SysVar.dwg.DWG_CLinew^:=index;
                commandmanager.ExecuteCommand('SelObjChangeLWToCurrent',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                SysVar.dwg.DWG_CLinew^:=tcl;
           end;
  end;
  setvisualprop;
  //setnormalfocus(nil);
  ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
end;

procedure TZCADMainWindow.GeneralTick(Sender: TObject);
begin
     if sysvar.SYS.SYS_RunTime<>nil then
     begin
          inc(sysvar.SYS.SYS_RunTime^);
          if SysVar.SAVE.SAVE_Auto_On^ then
                                           dec(sysvar.SAVE.SAVE_Auto_Current_Interval^);
     end;
end;
procedure TZCADMainWindow.StartLongProcess(LPHandle:TLPSHandle;Total:TLPSCounter;processname:TLPName);
begin
     LPTime:=now;
     pname:=processname;
     if (assigned(ProcessBar)and assigned(HintText)) then
     begin
  ProcessBar.max:=total;
  ProcessBar.min:=0;
  ProcessBar.position:=0;
  HintText.Hide;
  ProcessBar.Show;
  oldlongprocess:=0;
     end;
end;
procedure TZCADMainWindow.ProcessLongProcess(LPHandle:TLPSHandle;Current:TLPSCounter);
var
    pos:integer;
begin
     if (assigned(ProcessBar)and assigned(HintText)) then
     begin
          pos:=round(clientwidth*(single(current)/single(ProcessBar.max)));
          if pos>oldlongprocess then
          begin
               ProcessBar.position:=current;
               oldlongprocess:=pos+20;
               ProcessBar.repaint;
          end;
     end;
end;
function TZCADMainWindow.MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
begin
     ShowAllCursors(nil);
     result:=application.MessageBox(Text, Caption,Flags);
     RestoreCursors(nil);
end;
procedure TZCADMainWindow.ShowAllCursors;
begin
     if drawings.GetCurrentDWG<>nil then
     if drawings.GetCurrentDWG.wa<>nil then
     drawings.GetCurrentDWG.wa.showmousecursor;
end;

procedure TZCADMainWindow.RestoreCursors;
begin
     if drawings.GetCurrentDWG<>nil then
     if drawings.GetCurrentDWG.wa<>nil then
     drawings.GetCurrentDWG.wa.hidemousecursor;
end;

procedure TZCADMainWindow.Say(word:gdbstring);
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
          if assigned(HintText)then
          begin
          HintText.caption:=word;
          HintText.repaint;
          end;
     end;
end;
procedure TZCADMainWindow.EndLongProcess;
var
   Time:Tdatetime;
   ts:GDBSTRING;
begin
     if (assigned(ProcessBar)and assigned(HintText)) then
     begin
          ProcessBar.Hide;
          HintText.Show;
          ProcessBar.min:=0;
          ProcessBar.max:=0;
          ProcessBar.position:=0;
     end;
    application.ProcessMessages;
    time:=(now-LPTime)*10e4;
    str(time:3:2,ts);
    if pname='' then
                     ZCMsgCallBackInterface.TextMessage(format(rscompiledtimemsg,[ts]),TMWOHistoryOut)
                 else
                     ZCMsgCallBackInterface.TextMessage(format(rsprocesstimemsg,[pname,ts]),TMWOHistoryOut);
    pname:='';
end;
procedure TZCADMainWindow.ReloadLayer(plt:PTGenericNamedObjectsArray);
begin
  (*
  {layerbox.ClearText;}
  //layerbox.ItemsClear;
  //layerbox.Sorted:=true;
  plp:=plt^.beginiterate(ir);
  if plp<>nil then
  repeat
       s:=plp^.GetFullName;
       //(OnOff,Freze,Lock:boolean;ItemName:utf8string;lo:pointer)
       //layerbox.AddItem(plp^._on,false,plp^._lock,s,pointer(plp));//      sdfg
       //layerbox.Items.Add(s);
       plp:=plt^.iterate(ir);
  until plp=nil;
  //layerbox.Items.;
  //layerbox.Sorted:=false;
  //layerbox.Items.Add(S_Different);
  //layerbox.Additem(false,false,false,rsDifferent,nil);
  //layerbox.ItemIndex:=(SysVar.dwg.DWG_CLayer^);
  //layerbox.Sorted:=true;
  *)
end;

procedure TZCADMainWindow.MainMouseMove;
begin
     cxmenumgr.reset;
end;
function TZCADMainWindow.MainMouseDown(Sender:TAbstractViewArea):GDBBoolean;
begin
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
     if @SetCurrentDWGProc<>nil then
                                     SetCurrentDWGProc(Sender.PDWG);
     if (cxmenumgr.ismenupopup)or(ActivePopupMenu<>nil) then
                                                            result:=true
                                                        else
                                                            result:=false;
end;
procedure TZCADMainWindow.MainMouseUp;
begin
     if assigned(GetCurrentObjProc) then
     if GetCurrentObjProc=@sysvar then
     If assigned(UpdateObjInspProc)then
                                      UpdateObjInspProc;
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
end;
procedure TZCADMainWindow.ShowCXMenu;
var
  menu:TmyPopupMenu;
begin
  menu:=nil;
                                  if drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount>0 then
                                                                          menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'SELECTEDENTSCXMENU'))
                                                                      else
                                                                          menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'NONSELECTEDENTSCXMENU'));
                                  if menu<>nil then
                                  begin
                                       menu.PopUp;
                                  end;
end;
procedure TZCADMainWindow.ShowFMenu;
var
  menu:TmyPopupMenu;
begin
    menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'FASTMENU'));
    if menu<>nil then
    begin
         menu.PopUp;
    end;
end;


procedure TZCADMainWindow._scroll(Sender: TObject; ScrollCode: TScrollCode;var ScrollPos: Integer);
var
   pdwg:PTSimpleDrawing;
   nevpos:gdbvertex;
begin
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
  if pdwg.wa.getviewcontrol<>nil then begin
     nevpos:=PDWG.Getpcamera^.prop.point;
     if sender=HScrollBar then
     begin
          nevpos.x:=-ScrollPos;
     end
else if sender=VScrollBar then
     begin
          nevpos.y:=-(VScrollBar.Min+VScrollBar.Max{$IFNDEF LINUX}-VScrollBar.PageSize{$ENDIF}-ScrollPos);
     end;
     pdwg.wa.SetCameraPosZoom(nevpos,PDWG.Getpcamera^.prop.zoom,true);
     pdwg.wa.draworinvalidate;
  end;
end;
procedure TZCADMainWindow.wamm(Sender:TAbstractViewArea;Shift:TShiftState;X,Y:Integer);
var
  f:TzeUnitsFormat;
  htext,htext2:string;
begin
  if Sender.param.SelDesc.OnMouseObject<>nil then
                                                         begin
                                                              if PGDBObjEntity(Sender.param.SelDesc.OnMouseObject)^.vp.Layer._lock
                                                                then
                                                                    Sender.getviewcontrol.Cursor:=crNoDrop
                                                                else
                                                                    begin
                                                                         {if assigned(sysvarRDRemoveSystemCursorFromWorkArea)
                                                                         then}
                                                                             RemoveCursorIfNeed(Sender.getviewcontrol,sysvarRDRemoveSystemCursorFromWorkArea)
                                                                         {else
                                                                             RemoveCursorIfNeed(getviewcontrol,true)}
                                                                    end;
                                                         end
                                                     else
                                                         if not Sender.param.scrollmode then
                                                                                     begin
                                                                                          {if assigned(sysvarRDRemoveSystemCursorFromWorkArea)
                                                                                          then}
                                                                                              RemoveCursorIfNeed(Sender.getviewcontrol,sysvarRDRemoveSystemCursorFromWorkArea)
                                                                                          {else
                                                                                              RemoveCursorIfNeed(getviewcontrol,true)}
                                                                                     end;
  exclude(shift,ssLeft);
     if (Sender.param.md.mode and (MGet3DPoint or MGet3DPointWoOp)) <> 0 then
     commandmanager.sendmousecoordwop(sender,MouseButton2ZKey(shift));

     f:=Sender.pdwg^.GetUnitsFormat;
       htext:=sysutils.Format('%s, %s, %s',[zeDimensionToString(Sender.param.md.mouse3dcoord.x,f),zeDimensionToString(Sender.param.md.mouse3dcoord.y,f),zeDimensionToString(Sender.param.md.mouse3dcoord.z,f)]);
       if Sender.param.polarlinetrace = 1 then
       begin
            htext2:=sysutils.Format('L=%s',[zeDimensionToString(Sender.param.ontrackarray.otrackarray[Sender.param.pointnum].tmouse,f)]);
            htext:=sysutils.Format('%s (%s)',[htext,htext2]);
            Sender.getviewcontrol.Hint:=htext2;

            Application.ActivateHint(Sender.getviewcontrol.ClientToScreen(classes.Point(Sender.param.md.mouse.x,Sender.param.md.mouse.y)));
       end;
       ZCMsgCallBackInterface.TextMessage(htext,TMWOQuickly);
end;

function TZCADMainWindow.wamd(Sender:TAbstractViewArea;Button:TMouseButton;Shift:TShiftState;X,Y:Integer;onmouseobject:GDBPointer;var NeedRedraw:Boolean):boolean;
var
  key:GDBByte;
  //needredraw:boolean;
  FreeClick:boolean;
function ProcessControlpoint:boolean;
begin
   begin
    key := MouseButton2ZKey(shift);
    result:=false;
    if Sender.param.gluetocp then
    begin
      Sender.PDWG.GetSelObjArray.selectcurrentcontrolpoint(key,Sender.param.md.mouseglue.x,Sender.param.md.mouseglue.y,Sender.param.height);
      //needredraw:=true;
      result:=true;
      if (key and MZW_SHIFT) = 0 then
      begin
        Sender.param.startgluepoint:=Sender.param.nearesttcontrolpoint.pcontrolpoint;
        commandmanager.ExecuteCommandSilent('OnDrawingEd',Sender.pdwg,@Sender.param);
        //wa.param.lastpoint:=wa.param.nearesttcontrolpoint.pcontrolpoint^.worldcoord;
        //sendmousecoord{wop}(key);  bnmbnm
        if commandmanager.pcommandrunning <> nil then
        begin
          if key=MZW_LBUTTON then
                                 Sender.param.lastpoint:=Sender.param.nearesttcontrolpoint.pcontrolpoint^.worldcoord;
          commandmanager.pcommandrunning^.MouseMoveCallback(Sender.param.nearesttcontrolpoint.pcontrolpoint^.worldcoord,
                                                            Sender.param.md.mouseglue, key,nil)
        end;
      end;
    end;
  end;
end;
function ProcessEntSelect:boolean;
//var
//    RelSelectedObjects:Integer;
begin
  result:=false;
  key := MouseButton2ZKey(shift);
  begin
    sender.getonmouseobjectbytree(sender.PDWG.GetCurrentROOT.ObjArray.ObjTree,sysvarDWGEditInSubEntry);
    //getonmouseobject(@drawings.GetCurrentROOT.ObjArray);
    if (key and MZW_CONTROL)<>0 then
    begin
         commandmanager.ExecuteCommandSilent('SelectOnMouseObjects',sender.pdwg,@sender.param);
         result:=true;
    end
    else
    begin
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
    if sender.param.SelDesc.OnMouseObject <> nil then
    begin
         result:=true;
         if (key and MZW_SHIFT)=0
         then
             begin
                  //if assigned(sysvar.DSGN.DSGN_SelNew)then
                  if sysvarDSGNSelNew then
                  begin
                        sender.pdwg.GetCurrentROOT.ObjArray.DeSelect(sender.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
                        sender.param.SelDesc.LastSelectedObject := nil;
                        //wa.param.SelDesc.OnMouseObject := nil;
                        sender.param.seldesc.Selectedobjcount:=0;
                        sender.PDWG^.GetSelObjArray.Free;
                  end;
                  sender.param.SelDesc.LastSelectedObject := sender.param.SelDesc.OnMouseObject;
                  if assigned(sender.OnWaMouseSelect)then
                    sender.OnWaMouseSelect(sender,sender.param.SelDesc.LastSelectedObject);
             end
         else
             begin
                  PGDBObjEntity(sender.param.SelDesc.OnMouseObject)^.DeSelect(sender.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
                  sender.param.SelDesc.LastSelectedObject := nil;
                  //addoneobject;
                  sender.SetObjInsp;
                  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
                  //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
             end;
             //wa.param.SelDesc.LastSelectedObject := wa.param.SelDesc.OnMouseObject;
             if commandmanager.pcommandrunning<>nil then
             if commandmanager.pcommandrunning.IData.GetPointMode=TGPWaitEnt then
             if sender.param.SelDesc.LastSelectedObject<>nil then
             begin
               commandmanager.pcommandrunning^.IData.GetPointMode:=TGPEnt;
             end;
         NeedRedraw:=true;
    end

    else if ((sender.param.md.mode and MGetSelectionFrame) <> 0) and ((key and MZW_LBUTTON)<>0) then
    begin
      result:=true;
    { TODO : Добавить возможность выбора объектов без секрамки во время выполнения команды }
      commandmanager.ExecuteCommandSilent('SelectFrame',sender.pdwg,@sender.param);
      commandmanager.sendmousecoord(sender,MZW_LBUTTON);
    end;
  end;
  end;
end;

begin
  FreeClick:=true;
  key := MouseButton2ZKey(shift);
 if ssDouble in shift then
                          begin
                               if mbMiddle=button then
                                 begin
                                      {$IFNDEF DELPHI}
                                      if ssShift in shift then
                                                              Application.QueueAsyncCall(sender.asynczoomsel, 0)
                                                          else
                                                              Application.QueueAsyncCall(sender.asynczoomall, 0);
                                      {$ENDIF}
                                      exit(true);
                                 end;
                          end;
  if ssDouble in shift then
                           begin
                                if mbLeft=button then
                                  begin
                                       if assigned(OnMouseObject) then
                                         if (PGDBObjEntity(OnMouseObject).GetObjType=GDBtextID)
                                         or (PGDBObjEntity(OnMouseObject).GetObjType=GDBMTextID) then
                                           begin
                                                 RunTextEditor(OnMouseObject,Sender.PDWG^);
                                           end;
                                       exit(true);
                                  end;

                           end;


  if (ssLeft in shift) then
    begin
      if (sender.param.md.mode and MGetControlpoint) <> 0 then
                                                       FreeClick:=not ProcessControlpoint;

        if FreeClick and((sender.param.md.mode and MGetSelectObject) <> 0) then
        FreeClick:=not ProcessEntSelect;
    end;
    begin
      if FreeClick and((sender.param.md.mode and (MGet3DPoint or MGet3DPointWoOP)) <> 0) then
      begin
        commandmanager.sendmousecoordwop(sender,key);
      end;
    end;
    If assigned(UpdateObjInspProc)then
    UpdateObjInspProc;

  result:=false;
end;
function SelectRelatedObjects(PDWG:PTAbstractDrawing;param:POGLWndtype;pent:PGDBObjEntity):GDBInteger;
var
   pvname,pvname2:pvardesk;
   ir:itrec;
   pobj:PGDBObjEntity;
   pentvarext:PTVariablesExtender;
begin
     result:=0;
     if pent=nil then
                     exit;
     if assigned(sysvar.DSGN.DSGN_SelSameName)then
     if sysvar.DSGN.DSGN_SelSameName^ then
     begin
          if (pent^.GetObjType=GDBDeviceID)or(pent^.GetObjType=GDBCableID)or(pent^.GetObjType=GDBNetID)then
          begin
               pentvarext:=pent^.GetExtension(typeof(TVariablesExtender));
               pvname:=pentvarext^.entityunit.FindVariable('NMO_Name');
               if pvname<>nil then
               begin
                   pobj:=pdwg.GetCurrentROOT.ObjArray.beginiterate(ir);
                   if pobj<>nil then
                   repeat
                         if (pobj<>pent)and((pobj^.GetObjType=GDBDeviceID)or(pobj^.GetObjType=GDBCableID)or(pobj^.GetObjType=GDBNetID)) then
                         begin
                              pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
                              pvname2:=pentvarext^.entityunit.FindVariable('NMO_Name');
                              if pvname2<>nil then
                              if pgdbstring(pvname2^.data.Instance)^=pgdbstring(pvname^.data.Instance)^ then
                              begin
                                   if pobj^.select(param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector)then
                                                                                                          inc(result);
                              end;
                         end;
                         pobj:=pdwg.GetCurrentROOT.ObjArray.iterate(ir);
                   until pobj=nil;
               end;
          end;
     end;
end;
procedure TZCADMainWindow.wakp(Sender:TAbstractViewArea;var Key: Word; Shift: TShiftState);
begin
     if Key=VK_ESCAPE then
     begin
       if assigned(ReStoreGDBObjInspProc)then
       begin
       if not ReStoreGDBObjInspProc then
       begin
       Sender.ClearOntrackpoint;
       if commandmanager.pcommandrunning=nil then
         begin
         Sender.PDWG.GetCurrentROOT.ObjArray.DeSelect(Sender.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
         Sender.param.SelDesc.LastSelectedObject := nil;
         Sender.param.SelDesc.OnMouseObject := nil;
         Sender.param.seldesc.Selectedobjcount:=0;
         Sender.param.firstdraw := TRUE;
         Sender.PDWG.GetSelObjArray.Free;
         Sender.CalcOptimalMatrix;
         Sender.paint;
         if assigned(SetVisuaProplProc) then SetVisuaProplProc;
         Sender.setobjinsp;
         end
       else
         begin
              commandmanager.pcommandrunning.CommandCancel;
              commandmanager.executecommandend;
         end;
       end;
       end;
       Key:=0;
     end
     else if (Key = VK_RETURN)or(Key = VK_SPACE) then
           begin
                commandmanager.executelastcommad(Sender.pdwg,@Sender.param);
                Key:=00;
           end
     else if (Key=VK_V)and(shift=[ssctrl]) then
                         begin
                              commandmanager.executecommand('PasteClip',Sender.pdwg,@Sender.param);
                              key:=00;
                         end
end;
procedure TZCADMainWindow.wams(Sender:TAbstractViewArea;SelectedEntity:GDBPointer);
var
    RelSelectedObjects:Integer;
begin
  RelSelectedObjects:=SelectRelatedObjects(Sender.PDWG,@Sender.param,Sender.param.SelDesc.LastSelectedObject);
  if RelSelectedObjects>0 then
                              ZCMsgCallBackInterface.TextMessage(format(rsAdditionalSelected,[RelSelectedObjects]),TMWOHistoryOut);
  if (commandmanager.pcommandrunning=nil)or(commandmanager.pcommandrunning^.IData.GetPointMode<>TGPWaitEnt) then
  begin
  if PGDBObjEntity(Sender.param.SelDesc.OnMouseObject)^.select(Sender.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector) then
    begin
          if assigned(addoneobjectproc) then addoneobjectproc;
          Sender.SetObjInsp;
          ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
          //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
    end;
  end;
end;
function TZCADMainWindow.GetEntsDesc(ents:PGDBObjOpenArrayOfPV):GDBString;
var
  i: GDBInteger;
  pp:PGDBObjEntity;
  ir:itrec;
  //inr:TINRect;
  line:GDBString;
  pvd:pvardesk;
  pentvarext:PTVariablesExtender;
begin
     result:='';
     i:=0;
     pp:=ents.beginiterate(ir);
     if pp<>nil then
                    begin
                         repeat
                         pvd:=nil;
                         pentvarext:=pp^.GetExtension(typeof(TVariablesExtender));
                         if pentvarext<>nil then
                         pvd:=pentvarext^.entityunit.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         begin
                                         if i=20 then
                                         begin
                                              result:=result+#13#10+'...';
                                              exit;
                                         end;
                                         line:=pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
                                         line:=line+' Name='+pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                         if result='' then
                                                          result:=line
                                                      else
                                                          result:=result+#13#10+line;
                                         inc(i);
                                         end;
                               pp:=ents.iterate(ir);
                         until pp=nil;
                    end;
end;
procedure TZCADMainWindow.WaShowCursor(Sender:TAbstractViewArea;var DC:TDrawContext);
begin
     if sender.param.lastonmouseobject<>nil then
                                           begin
                                             PGDBObjEntity(sender.param.lastonmouseobject)^.RenderFeedBack(sender.pdwg.GetPcamera^.POSCOUNT,sender.pdwg^.GetPcamera^, sender.pdwg^.myGluProject2,dc);
                                             pGDBObjEntity(sender.param.lastonmouseobject)^.higlight(dc);
                                           end;
end;
procedure TZCADMainWindow.waSetObjInsp;
var
    tn:GDBString;
    ptype:PUserTypeDescriptor;
    objcount:integer;
    sender_wa:TAbstractViewArea;
begin
  if sender is (TAbstractViewArea) then
    sender_wa:=sender as TAbstractViewArea
  else
    exit;
  if sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_AlwaysUseMultiSelectWrapper^then
                                                                                      objcount:=0
                                                                                  else
                                                                                      objcount:=1;
  if sender_wa.param.SelDesc.Selectedobjcount>objcount then
    begin
       if drawings.GetCurrentDWG.SelObjArray.Count>0 then
                                                    commandmanager.ExecuteCommandSilent('MultiSelect2ObjIbsp',sender_wa.pdwg,@sender_wa.param)
                                                else
                                                    If assigned(ReturnToDefaultProc)then
                                                                                        ReturnToDefaultProc(drawings.GetUnitsFormat);
    end
  else
  begin
  if assigned(SysVar.DWG.DWG_SelectedObjToInsp)then
  if (sender_wa.param.SelDesc.LastSelectedObject <> nil)and(SysVar.DWG.DWG_SelectedObjToInsp^)and(sender_wa.param.SelDesc.Selectedobjcount>0) then
  begin
       tn:=PGDBObjEntity(sender_wa.param.SelDesc.LastSelectedObject)^.GetObjTypeName;
       ptype:=SysUnit.TypeName2PTD(tn);
       if ptype<>nil then
       begin
            If assigned(SetGDBObjInspProc)then
            SetGDBObjInspProc(drawings.GetUndoStack,drawings.GetUnitsFormat,ptype,sender_wa.param.SelDesc.LastSelectedObject,sender_wa.pdwg);
       end;
  end
  else
  begin
    If assigned(ReturnToDefaultProc)then
    ReturnToDefaultProc(drawings.GetUnitsFormat);
  end;
  end
end;

procedure TZCADMainWindow.correctscrollbars;
var
   pdwg:PTSimpleDrawing;
   BB:TBoundingBox;
   size,min,max,position:integer;
begin
  if (ZCADMainWindow.HScrollBar<>nil)and(ZCADMainWindow.VScrollBar<>nil) then
  if (ZCADMainWindow.HScrollBar.Focused)or(ZCADMainWindow.VScrollBar.Focused)then
    ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIActionSetNormalFocus);
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
  if pdwg.wa<>nil then begin
  bb:=pdwg.GetCurrentROOT.vp.BoundingBox;
  size:=round(pdwg.wa.getviewcontrol.ClientWidth*pdwg.GetPcamera^.prop.zoom);
  position:=round(-pdwg.GetPcamera^.prop.point.x);
  min:=round(bb.LBN.x+size/2);
  max:=round(bb.RTF.x+{$IFDEF LINUX}-{$ENDIF}size/2);
  if max<min then max:=min;
  ZCADMainWindow.HScrollBar.SetParams(position,min,max,size);

  size:=round(pdwg.wa.getviewcontrol.ClientHeight*pdwg.GetPcamera^.prop.zoom);
  min:=round(bb.LBN.y+size/2);
  max:=round(bb.RTF.y+{$IFDEF LINUX}-{$ENDIF}size/2);
  if max<min then max:=min;
  position:=round((bb.LBN.y+bb.RTF.y+pdwg.GetPcamera^.prop.point.y));
  ZCADMainWindow.VScrollBar.SetParams(position,min,max,size);
  end;
end;
procedure TZCADMainWindow.updatevisible(sender:TObject;GUIMode:TZMessageID);
var
   GVA:TGeneralViewArea;
   name:gdbstring;
   i,k:Integer;
   pdwg:PTSimpleDrawing;
begin
  if GUIMode<>ZMsgID_GUIActionRedraw then
    exit;

   pdwg:=drawings.GetCurrentDWG;
   if assigned(ZCADMainWindow)then
   begin
   ZCADMainWindow.UpdateControls;
   ZCADMainWindow.correctscrollbars;
   k:=0;
  if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
  begin
  ZCADMainWindow.setvisualprop;
  ZCADMainWindow.Caption:='ZCad v'+sysvar.SYS.SYS_Version^+' - ['+drawings.GetCurrentDWG.GetFileName+']';

  if assigned(LayerBox) then
  LayerBox.enabled:=true;
  if assigned(LineWBox) then
  LineWBox.enabled:=true;
  if assigned(ColorBox) then
  ColorBox.enabled:=true;
  if assigned(LTypeBox) then
  LTypeBox.enabled:=true;
  if assigned(TStyleBox) then
  TStyleBox.enabled:=true;
  if assigned(DimStyleBox) then
  DimStyleBox.enabled:=true;


  if assigned(ZCADMainWindow.PageControl) then
  if assigned(SysVar.INTF.INTF_ShowDwgTabs) then
  if sysvar.INTF.INTF_ShowDwgTabs^ then
                                       ZCADMainWindow.PageControl.ShowTabs:=true
                                   else
                                       ZCADMainWindow.PageControl.ShowTabs:=false;
  if assigned(SysVar.INTF.INTF_DwgTabsPosition) then
  begin
       case SysVar.INTF.INTF_DwgTabsPosition^ of
                                                TATop:ZCADMainWindow.PageControl.TabPosition:=tpTop;
                                                TABottom:ZCADMainWindow.PageControl.TabPosition:=tpBottom;
                                                TALeft:ZCADMainWindow.PageControl.TabPosition:=tpLeft;
                                                TARight:ZCADMainWindow.PageControl.TabPosition:=tpRight;
       end;
  end;
  if assigned(ZCADMainWindow.PageControl) then
  if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then
  begin
       if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
                                                      ZCADMainWindow.PageControl.Options:=ZCADMainWindow.PageControl.Options+[nboShowCloseButtons]
                                                  else
                                                      ZCADMainWindow.PageControl.Options:=ZCADMainWindow.PageControl.Options-[nboShowCloseButtons];
  end;

  if assigned(ZCADMainWindow.HScrollBar) then
  begin
  ZCADMainWindow.HScrollBar.enabled:=true;
  ZCADMainWindow.correctscrollbars;
  if assigned(sysvar.INTF.INTF_ShowScrollBars) then
  if sysvar.INTF.INTF_ShowScrollBars^ then
                                       ZCADMainWindow.HScrollBar.Show
                                   else
                                       ZCADMainWindow.HScrollBar.Hide;
  end;

  if assigned(ZCADMainWindow.VScrollBar) then
  begin
  ZCADMainWindow.VScrollBar.enabled:=true;
  if assigned(sysvar.INTF.INTF_ShowScrollBars) then
  if sysvar.INTF.INTF_ShowScrollBars^ then
                                       ZCADMainWindow.VScrollBar.Show
                                   else
                                       ZCADMainWindow.VScrollBar.Hide;
  end;
  for i:=0 to ZCADMainWindow.PageControl.PageCount-1 do
    begin
         GVA:=TGeneralViewArea(FindComponentByType(ZCADMainWindow.PageControl.Pages[i],TGeneralViewArea));
           if assigned(GVA) then
            if GVA.PDWG<>nil then
            begin
                name:=extractfilename(PTZCADDrawing(GVA.PDWG)^.FileName);
                if @PTZCADDrawing(GVA.PDWG).mainObjRoot=(PTZCADDrawing(GVA.PDWG).pObjRoot) then
                                                                     ZCADMainWindow.PageControl.Pages[i].caption:=(name)
                                                                 else
                                                                     ZCADMainWindow.PageControl.Pages[i].caption:='BEdit('+name+':'+Tria_AnsiToUtf8(PGDBObjBlockdef(PTZCADDrawing(GVA.PDWG).pObjRoot).Name)+')';

                if k<=high(ZCADMainWindow.OpenedDrawings) then
                begin
                ZCADMainWindow.OpenedDrawings[k].Caption:=ZCADMainWindow.PageControl.Pages[i].caption;
                ZCADMainWindow.OpenedDrawings[k].visible:=true;
                ZCADMainWindow.OpenedDrawings[k].command:='ShowPage';
                ZCADMainWindow.OpenedDrawings[k].options:=inttostr(i);
                inc(k);
                end;
                end;

            end;
  for i:=k to high(ZCADMainWindow.OpenedDrawings) do
  begin
       ZCADMainWindow.OpenedDrawings[i].visible:=false;
  end;
  end
  else
      begin
           for i:=low(ZCADMainWindow.OpenedDrawings) to high(ZCADMainWindow.OpenedDrawings) do
             begin
                         ZCADMainWindow.OpenedDrawings[i].Caption:='';
                         ZCADMainWindow.OpenedDrawings[i].visible:=false;
                         ZCADMainWindow.OpenedDrawings[i].command:='';
             end;
           ZCADMainWindow.Caption:=('ZCad v'+sysvar.SYS.SYS_Version^);
           {if assigned(LayerBox)then
           LayerBox.enabled:=false;
           if assigned(LineWBox)then
           LineWBox.enabled:=false;
           if assigned(ColorBox) then
           ColorBox.enabled:=false;
           if assigned(TStyleBox) then
           TStyleBox.enabled:=false;
           if assigned(DimStyleBox) then
           DimStyleBox.enabled:=false;
           if assigned(LTypeBox) then
           LTypeBox.enabled:=false;}
           if assigned(ZCADMainWindow.HScrollBar) then
           begin
           ZCADMainWindow.HScrollBar.enabled:=false;
           if assigned(sysvar.INTF.INTF_ShowScrollBars) then
           if sysvar.INTF.INTF_ShowScrollBars^ then

                                       ZCADMainWindow.HScrollBar.Show
                                   else
                                       ZCADMainWindow.HScrollBar.Hide;

           end;
           if assigned(ZCADMainWindow.VScrollBar) then
           begin
           ZCADMainWindow.VScrollBar.enabled:=false;
           if assigned(sysvar.INTF.INTF_ShowScrollBars) then
           if sysvar.INTF.INTF_ShowScrollBars^ then
                                       ZCADMainWindow.VScrollBar.Show
                                   else
                                       ZCADMainWindow.VScrollBar.Hide;
           end;
      end;
  end;
  end;
function DockingOptions_com(Operands:pansichar):GDBInteger;
begin
     ShowAnchorDockOptions(DockMaster);
     result:=cmd_ok;
end;
function RaiseException_com(Operands:pansichar):GDBInteger;
begin
     raise EExternal.Create('Exception test');
     result:=cmd_ok;
end;
initialization
begin
  CreateCommandFastObjectPlugin(pointer($100),'GetAV',0,0);
  CreateCommandFastObjectPlugin(@RaiseException_com,'RaiseException',0,0);
  CreateCommandFastObjectPlugin(@DockingOptions_com,'DockingOptions',0,0);
end
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

