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

unit mainwindow;
{$INCLUDE def.inc}

interface
uses
  {LCL}
       types,AnchorDocking,AnchorDockOptionsDlg,ButtonPanel,AnchorDockStr,
       ActnList,LCLType,LCLProc,intftranslations,toolwin,LMessages,LCLIntf,
       Forms, stdctrls, ExtCtrls, ComCtrls,Controls,Classes,SysUtils,FileUtil,
       menus,graphics,dialogs,XMLPropStorage,Buttons,Themes,
  {FPC}
       math,
  {ZCAD BASE}
       UGDBStringArray,oglwindowdef,gdbvisualprop,uzglgeometry,zcadinterface,plugins,UGDBOpenArrayOfByte,memman,gdbase,gdbasetypes,
       geometry,zcadsysvars,zcadstrconsts,strproc,UGDBNamedObjectsArray,log,
       varmandef, varman,UUnitManager,SysInfo,shared,strmy,UGDBTextStyleArray,ugdbdimstylearray,
  {ZCAD SIMPLE PASCAL SCRIPT}
       languade,UGDBOpenArrayOfUCommands,
  {ZCAD ENTITIES}
       GDBEntity,UGDBSelectedObjArray,UGDBLayerArray,ugdbsimpledrawing,
       GDBBlockDef,UGDBDescriptor,GDBManager,ugdbltypearray,gdbobjectsconstdef,GDBText,gdbdimension,
  {ZCAD COMMANDS}
       commandlinedef,commanddefinternal,commandline,
  {GUI}
       objinspdecorations,oswnd,cmdline,umytreenode,lineweightwnd,layercombobox,ucxmenumgr,oglwindow,
       colorwnd,imagesmanager,ltwnd,usuptstylecombo,usupportgui,usupdimstylecombo,
  {}
       gdbdrawcontext,uzglopengldrawer,uzglabstractdrawer;
  {}
type
  TComboFiller=procedure(cb:TCustomComboBox) of object;
  TInterfaceVars=record
                       CColor,CLWeight:GDBInteger;
                       CLayer:PGDBLayerProp;
                       CLType:PGDBLTypeProp;
                       CTStyle:PGDBTextStyle;
                       CDimStyle:PGDBDimStyle;
                 end;
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
  TDrawings=Array [0..9] of TmyAction;
  TCommandHistory=Array [0..9] of TmyAction;

  { MainForm }

  MainForm = class(TFreedForm)
    ToolBarU{,ToolBarR}:TToolBar;
    //ToolBarD: TToolBar;
    //ObjInsp,
    MainPanel:TForm{TPanel};
    FToolBar{,MainPanelU}:TToolButtonForm;
    //MainPanelD:TCLine;
    //SplitterV,SplitterH: TSplitter;

    PageControl:TmyPageControl;
    DHPanel:TPanel;
    HScrollBar,VScrollBar:TScrollBar;

    //MainMenu:TMenu;
    StandartActions:TmyActionList;

    SystemTimer: TTimer;

    toolbars:tstringlist;

    updatesbytton,updatescontrols:tlist;

    {procedure LayerBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                               State: TOwnerDrawState);}
    procedure LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                               State: TOwnerDrawState);
    procedure ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                   State: TOwnerDrawState);
    procedure ColorDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                   State: TOwnerDrawState);
    procedure LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                   State: TOwnerDrawState);
    function findtoolbatdesk(tbn:string):string;
    procedure CreateToolbarFromDesk(tb:TToolBar;tbname,tbdesk:string);
    function CreateCBox(owner:TToolBar;DrawItem:TDrawItemEvent;Change,DropDown,CloseUp:TNotifyEvent;Filler:TComboFiller;w:integer;ts:GDBString):TComboBox;
    procedure CreateHTPB(tb:TToolBar);

    procedure FormCreate(Sender: TObject);
    procedure ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure AfterConstruction; override;
    destructor Destroy;override;
    procedure setnormalfocus(Sender: TObject);

    procedure draw;

    procedure loadpanels(pf:GDBString);
    procedure CreateLayoutbox(tb:TToolBar);
    procedure loadmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    procedure loadpopupmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    procedure createmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    procedure setmainmenu(var f:GDBOpenArrayOfByte;var line:GDBString);
    procedure loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);

    procedure ChangedDWGTabCtrl(Sender: TObject);
    procedure UpdateControls;

    procedure StartLongProcess(total:integer;processname:GDBString);
    procedure ProcessLongProcess(current:integer);
    procedure EndLongProcess;
    procedure Say(word:gdbstring);

    procedure SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);

    function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
    procedure ShowAllCursors;
    procedure RestoreCursors;
    procedure CloseDWGPageInterf(Sender: TObject);
    function CloseDWGPage(Sender: TObject):integer;

    procedure PageControlMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure correctscrollbars;


    private
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    public
    rt:GDBInteger;
    FileHistory:TFileHistory;
    Drawings:TDrawings;
    CommandsHistory:TCommandHistory;
    procedure CreateAnchorDockingInterface;
    procedure CreateStandartInterface;
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
    procedure ReloadLayer(plt:PGDBNamedObjectsArray);
    procedure GeneralTick(Sender: TObject);
    procedure ShowFastMenu(Sender: TObject);
    procedure asynccloseapp(Data: PtrInt);
    procedure processfilehistory(filename:GDBString);
    procedure processcommandhistory(Command:GDBString);
    function CreateZCADControl(aName: string;DoDisableAlign:boolean=false):TControl;
    procedure DockMasterCreateControl(Sender: TObject; aName: string; var
    AControl: TControl; DoDisableAutoSizing: boolean);

    procedure GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                                   Raw: boolean = false;
                                   WithThemeSpace: boolean = true); override;

    function IsShortcut(var Message: TLMKey): boolean; override;
    function GetLayerProp(PLayer:Pointer;var lp:TLayerPropRecord):boolean;
    function GetLayersArray(var la:TLayerArray):boolean;
    function ClickOnLayerProp(PLayer:Pointer;NumProp:integer;var newlp:TLayerPropRecord):boolean;

    procedure setvisualprop;
    procedure addoneobject;

    procedure _scroll(Sender: TObject; ScrollCode: TScrollCode;
           var ScrollPos: Integer);
    procedure ShowCXMenu;
    procedure ShowFMenu;
    procedure MainMouseMove;
    function MainMouseDown:GDBBoolean;
               end;
  {TMyAnchorDockManager = class(TAnchorDockManager)
  public
    procedure ResetBounds(Force: Boolean); override;
  end;}
procedure UpdateVisible;
function getoglwndparam: GDBPointer; export;
function LoadLayout_com(Operands:pansichar):GDBInteger;
function _CloseDWGPage(ClosedDWG:PTDrawing;lincedcontrol:TObject):Integer;
procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);safecall;
procedure superdrawdraw(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:pointer);
{procedure startup;
procedure finalize;}
var
  IVars:TInterfaceVars;
  MainFormN: MainForm;
  //MainForm: MainForm;
  //uGeneralTimer:cardinal;
  //GeneralTime:GDBInteger;
  LayerBox:TZCADLayerComboBox;
  LineWBox,ColorBox,LTypeBox,TStyleBox,DimStyleBox:TComboBox;
  LayoutBox:TComboBox;
  LPTime:Tdatetime;
  pname:GDBString;
  oldlongprocess:integer;
  //tf:tform;
  OLDColor:integer;
  localpm:TFiletoMenuIteratorData;
  //DockMaster:  TAnchorDockMaster = nil;
const
     LTEditor:pointer=@LTypeBox;//пофиг что, используем только цифру
  function CloseApp:GDBInteger;
  function IsRealyQuit:GDBBoolean;
  procedure DrawColor(Canvas:TCanvas; Index: Integer; ARect: TRect);

implementation
uses generalviewarea,gdbcommandsinterface;

{procedure TMyAnchorDockManager.ResetBounds(Force: Boolean);
begin
     inherited;
     //OldSiteClientRect:=FSiteClientRect;
     //FSiteClientRect:=Site.ClientRect;
     //site:=site;
     //Site.ClientRect:=FSiteClientRect;
end;}
constructor TmyAnchorDockSplitter.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  self.MinSize:=1;
end;

procedure setlayerstate(PLayer:PGDBLayerProp;var lp:TLayerPropRecord);
begin
     lp._On:=player^._on;
     lp.Freze:=false;
     lp.Lock:=player^._lock;
     lp.Name:=Tria_AnsiToUtf8(player.Name);
     lp.PLayer:=player;;
end;
procedure MainForm.setvisualprop;
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
    //i,se:GDBInteger;
    pv:{pgdbobjEntity}PSelectedObjDesc;
        ir:itrec;
begin

  if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
  then
      begin
           if assigned(LinewBox) then
           if sysvar.dwg.DWG_CLinew^<0 then LineWbox.ItemIndex:=(sysvar.dwg.DWG_CLinew^+3)
                                       else LinewBox.ItemIndex:=((sysvar.dwg.DWG_CLinew^ div 10)+3);
           {if assigned(LayerBox) then
           LayerBox.ItemIndex:=getsortedindex(SysVar.dwg.DWG_CLayer^);}
           IVars.CColor:=sysvar.dwg.DWG_CColor^;
           IVars.CLWeight:=sysvar.dwg.DWG_CLinew^;
           ivars.CLayer:={gdb.GetCurrentDWG.LayerTable.getelement}(sysvar.dwg.DWG_CLayer^);
           ivars.CLType:={gdb.GetCurrentDWG.LTypeStyleTable.getelement}(sysvar.dwg.DWG_CLType^);
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
           pv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
           //pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
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
                         if (pv^.objaddr^.vp.ID=GDBMTextID)or(pv^.objaddr^.vp.ID=GDBTextID) then
                         begin
                         if tstyle=PEmpty then tstyle:=PGDBObjText(pv^.objaddr)^.TXTStyleIndex
                                           else if tstyle<> PGDBObjText(pv^.objaddr)^.TXTStyleIndex then tstyle:=PDifferent;
                         end;
                         if (pv^.objaddr^.vp.ID=GDBAlignedDimensionID)or(pv^.objaddr^.vp.ID=GDBRotatedDimensionID)or(pv^.objaddr^.vp.ID=GDBDiametricDimensionID) then
                         begin
                         if dimstyle=PEmpty then dimstyle:=PGDBObjDimension(pv^.objaddr)^.PDimStyle
                                            else if dimstyle<>PGDBObjDimension(pv^.objaddr)^.PDimStyle then dimstyle:=PDifferent;
                         end;
                    end;
                if (layer=PDifferent)and(lw=IntDifferent)and(color=IntDifferent)and(ltype=PDifferent)and(tstyle=PDifferent)and(dimstyle=PDifferent) then system.Break;
           end;
           pv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
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
procedure MainForm.addoneobject;
//const //pusto=-1000;
      //different=-10001;
var lw{,layer}:GDBInteger;
begin
  exit;
  lw:=PGDBObjEntity(gdb.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineWeight;
  //layer:=gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.layer);
  if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=1
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
           {if assigned(LayerBox)then
           LayerBox.ItemIndex:=getsortedindex((layer));//(layer);    xcvxcv}
           //gdb.GetCurrentDWG.OGLwindow1.SelectedObjectsPLayer:=PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.layer;
           ivars.CColor:=PGDBObjEntity(gdb.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.color;
           ivars.CLType:=PGDBObjEntity(gdb.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineType;

           {CColor
           CLWeight:GDBInteger;
           CLayer:PGDBLayerProp;
           CLType:PGDBLTypeProp;
           CTStyle:PGDBTextStyle;
           CDimStyle:PGDBDimStyle;}

      end
  else
      begin
           if assigned(LayerBox)then
           begin
                //if gdb.GetCurrentDWG.OGLwindow1.SelectedObjectsPLayer<>PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.layer then
                //   gdb.GetCurrentDWG.OGLwindow1.SelectedObjectsPLayer:=nil;
           end;
           //if LayerBox.ItemIndex<>getsortedindex((layer)) then LayerBox.ItemIndex:=(LayerBox.ItemsCount-1);
           if lw<0 then lw:=lw+3
                   else lw:=(lw div 10)+3;
           if assigned(LinewBox)then
           if LinewBox.ItemIndex<>lw then LinewBox.ItemIndex:=(LinewBox.Items.Count-1);

           if ivars.CColor<>PGDBObjEntity(gdb.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.color then
              ivars.CColor:=ClDifferent;
           if ivars.CLType<>PGDBObjEntity(gdb.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject)^.vp.LineType then
              ivars.CLType:=nil;
      end;
end;

function MainForm.ClickOnLayerProp(PLayer:Pointer;NumProp:integer;var newlp:TLayerPropRecord):boolean;
var
   cdwg:PTSimpleDrawing;
   tcl:{integer}PGDBLayerProp;
begin
     CDWG:=GDB.GetCurrentDWG;
     result:=false;
     case numprop of
                    0:begin
                           PGDBLayerProp(PLayer)^._on:=not(PGDBLayerProp(PLayer)^._on);
                           if PLayer=cdwg^.LayerTable.GetCurrentLayer then
                           if not PGDBLayerProp(PLayer)^._on then
                                                                 MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);

                      end;
                    {1:;}
                    2:PGDBLayerProp(PLayer)^._lock:=not(PGDBLayerProp(PLayer)^._lock);
                    3:begin
                           cdwg:=gdb.GetCurrentDWG;
                           if cdwg<>nil then
                           begin
                                if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0 then
                                begin
                                          if assigned(sysvar.dwg.DWG_CLayer) then
                                          if sysvar.dwg.DWG_CLayer^<>Player then
                                          begin
                                               with PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(sysvar.dwg.DWG_CLayer^)^ do
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
                                       SysVar.dwg.DWG_CLayer^:={cdwg^.LayerTable.GetIndexByPointer}(Player);
                                       commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                                       SysVar.dwg.DWG_CLayer^:=tcl;
                                       {gdb.GetCurrentDWG.OGLwindow1.}setvisualprop;
                                end;
                           result:=true;
                           end;
                      end;
     end;
     setlayerstate(PLayer,newlp);
     if not result then
                       begin
                            if assigned(UpdateVisibleProc) then UpdateVisibleProc;
                            if assigned(redrawoglwndproc) then redrawoglwndproc;
                       end;
end;

function MainForm.GetLayersArray(var la:TLayerArray):boolean;
var
   cdwg:PTSimpleDrawing;
   pcl:PGDBLayerProp;
   ir:itrec;
   counter:integer;
begin
     result:=false;
     cdwg:=gdb.GetCurrentDWG;
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
function MainForm.GetLayerProp(PLayer:Pointer;var lp:TLayerPropRecord):boolean;
var
   cdwg:PTSimpleDrawing;
   //pcl:PGDBLayerProp;
begin
     if player=nil then
                       begin
                            result:=false;
                            cdwg:=gdb.GetCurrentDWG;
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
                                 {pcl:=cdwg^.LayerTable.GetCurrentLayer;
                                 if cdwg^.OGLwindow1.param.seldesc.Selectedobjcount=0 then
                                 begin
                                 if pcl<>nil then
                                                 begin
                                                      setlayerstate(pcl,lp);
                                                      result:=true;
                                                 end;
                                 end
                                 else
                                     begin
                                          if IVars.CLayer<>nil then
                                          begin
                                               setlayerstate(IVars.CLayer,lp);
                                               result:=true;
                                          end;
                                     end;}
                                end;
                            end;

                       end
                   else
                       begin
                            result:=true;
                            setlayerstate(PLayer,lp);
                       end;

end;

function MainForm.findtoolbatdesk(tbn:string):string;
var i:integer;
    debs:string;
begin
     tbn:=uppercase(tbn)+':';
     for i:=0 to toolbars.Count-1 do
     begin
          debs:=uppercase(toolbars.Strings[i]);
          if pos(tbn,debs)=1 then
          begin
               result:=copy(toolbars.Strings[i],length(tbn)+1,length(toolbars.Strings[i])-length(tbn));
               exit;
          end;
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
procedure MainForm.processfilehistory(filename:GDBString);
var i,j,k:integer;
    pstr,pstrnext:PGDBString;
    //pvarfirst:pvardesk;
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
procedure  MainForm.processcommandhistory(Command:GDBString);
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
   poglwnd:TOGLWnd;
begin
     result:=false;
     if MainFormN.PageControl<>nil then
     begin
          for i:=0 to MainFormN.PageControl.PageCount-1 do
          begin
               TControl(poglwnd):=FindControlByType(TTabSheet(MainFormN.PageControl.Pages[i]),TOGLWnd);
               if poglwnd<>nil then
                                   begin
                                        if poglwnd.wa.PDWG.GetChangeStampt then
                                                                            begin
                                                                                 result:=true;
                                                                                 system.break;
                                                                            end;
                                   end;
          end;

     end;
     //if gdb.GetCurrentDWG<>nil then
     begin
     if not result then
                       begin
                       if gdb.GetCurrentDWG<>nil then
                                                     i:=MainFormN.messagebox(@rsQuitQuery[1],@rsQuitCaption[1],MB_YESNO or MB_ICONQUESTION)
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
          {if assigned(pint)then
                               pint^:=GDBobjinsp.Width;}
          pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
          if assigned(pint)then
                               if assigned(GetNameColWidthProc)then
                               pint^:=GetNameColWidthProc;

     if assigned(InfoForm) then
     begin
     pint:=SavedUnit.FindValue('TEdWND_Left');
     if assigned(pint)then
                          pint^:=InfoForm.Left;
     pint:=SavedUnit.FindValue('TEdWND_Top');
     if assigned(pint)then
                          pint^:=InfoForm.Top;
     pint:=SavedUnit.FindValue('TEdWND_Width');
     if assigned(pint)then
                          pint^:=InfoForm.Width;
     pint:=SavedUnit.FindValue('TEdWND_Height');
     if assigned(pint)then
                          pint^:=InfoForm.Height;

     end;

          mem.init({$IFDEF DEBUGBUILD}'{71D987B4-8C57-4C62-8C12-CFC24A0A9C9A}',{$ENDIF}1024);
          SavedUnit^.SavePasToMem(mem);
          mem.SaveToFile(sysparam.programpath+'rtl'+PathDelim+'savedvar.pas');
          mem.done;
          end;

          historyout('   Вот и всё бля...............');


     end
     else
         result:=false;
     end;
end;

function CloseApp:GDBInteger;
//var
   //pint:PGDBInteger;
   //mem:GDBOpenArrayOfByte;
begin
(*
     if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
     pint:=SavedUnit.FindValue('VIEW_CommandLineH');
     if assigned(pint)then
                          pint^:=Cline.Height;
     pint:=SavedUnit.FindValue('VIEW_ObjInspV');
     if assigned(pint)then
                          pint^:=GDBobjinsp.Width;
     pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
     if assigned(pint)then
                          pint^:=GDBobjinsp.namecol;

     mem.init({$IFDEF DEBUGBUILD}'{71D987B4-8C57-4C62-8C12-CFC24A0A9C9A}',{$ENDIF}1024);
     SavedUnit^.SavePasToMem(mem);
     mem.SaveToFile(sysparam.programpath+'rtl'+PathDelim+'savedvar.pas');
     mem.done;
     end;

     historyout('   Вот и всё бля...............');
*)
     result:=0;
     if IsRealyQuit then
     begin
          if MainFormN.PageControl<>nil then
          begin
               while MainFormN.PageControl.ActivePage<>nil do
               begin
                    //MainFormN.PageControl.ActivePage.Destroy;
                    if MainFormN.CloseDWGPage(MainFormN.PageControl.ActivePage)=IDCANCEL then
                                                                                             exit;
               end;
          end;
          application.terminate;
     end;
end;
{var
   poglwnd:toglwnd;
   ClosedDWG:PTDrawing;
   i:integer;
begin
  //application.ProcessMessages;
  Closeddwg:=nil;
  TControl(poglwnd):=FindControlByType(TTabSheet(sender),TOGLWnd);
  if poglwnd<>nil then
                      Closeddwg:=ptdrawing(poglwnd.PDWG);
  _CloseDWGPage(ClosedDWG,Sender);
end;}
procedure MainForm.asynccloseapp(Data: PtrInt);
begin
      CloseApp;
     //commandmanager.executecommand('Quit');
     //if IsRealyQuit then
     //                        application.terminate;
end;

procedure MainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     CloseAction:=caNone;
     if not commandmanager.EndGetPoint(TGPCloseApp) then
                                           Application.QueueAsyncCall(asynccloseapp, 0);
end;

procedure MainForm.draw;
begin
     update;
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
    BtnPanel.OKButton.OnClick:={@}OptsFrame.OkClick;
    BtnPanel.Parent:=Dlg;
    Dlg.EnableAutoSizing;
    Result:=DOShowModal(Dlg){.ShowModal};
  finally
    Dlg.Free;
  end;
end;
procedure MainForm.GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                               Raw: boolean = false;
                               WithThemeSpace: boolean = true);
begin
     inherited GetPreferredSize(PreferredWidth, PreferredHeight,Raw,WithThemeSpace);
     PreferredWidth:=0;
     PreferredHeight:=0;
end;
function _CloseDWGPage(ClosedDWG:PTDrawing;lincedcontrol:TObject):Integer;
var
   poglwnd:toglwnd;
   //i:integer;
   s:string;
begin
  if ClosedDWG<>nil then
  begin
       result:=IDYES;
       if ClosedDWG.Changed then
                                 begin
                                      repeat
                                      s:=format(rsCloseDWGQuery,[ClosedDWG.FileName]);
                                      result:=MainFormN.MessageBox(@s[1],@rsWarningCaption[1],{MB_YESNO}MB_YESNOCANCEL);
                                      if result=IDCANCEL then exit;
                                      if result=IDNO then system.break;
                                      if result=IDYES then
                                      begin
                                           result:=dwgQSave_com(ClosedDWG);
                                      end;
                                      until result<>cmd_error;
                                      result:=IDYES;
                                 end;
       //commandmanager.executecommandtotalend;
       commandmanager.ChangeModeAndEnd(TGPCloseDWG);
       poglwnd:=toglwnd(ClosedDWG.wa.getviewcontrol);
       gdb.eraseobj(ClosedDWG);
       gdb.pack;
       poglwnd.wa.PDWG:=nil;

       poglwnd.{GDBActivateGLContext}MakeCurrent;
       poglwnd.free;

       lincedcontrol.Free;
       tobject(poglwnd):=mainformn.PageControl.ActivePage;

       if poglwnd<>nil then
       begin
            tobject(poglwnd):=FindControlByType(poglwnd,TOGLWnd);
            gdb.CurrentDWG:=PTDrawing(poglwnd.wa.PDWG);
            poglwnd.GDBActivate;
       end
       else
           gdb.freedwgvars;
       shared.SBTextOut('Закрыто');
       if assigned(ReturnToDefaultProc)then
                                           ReturnToDefaultProc;
       if assigned(UpdateVisibleProc) then UpdateVisibleProc;
  end;
end;
procedure MainForm.CloseDWGPageInterf(Sender: TObject);
begin
     CloseDWGPage(Sender);
end;

function MainForm.CloseDWGPage(Sender: TObject):integer;
var
   poglwnd:toglwnd;
   ClosedDWG:PTDrawing;
   //i:integer;
begin
  //application.ProcessMessages;
  Closeddwg:=nil;
  TControl(poglwnd):=FindControlByType(TTabSheet(sender),TOGLWnd);
  if poglwnd<>nil then
                      Closeddwg:=ptdrawing(poglwnd.wa.PDWG);
  result:=_CloseDWGPage(ClosedDWG,Sender);
end;
procedure MainForm.PageControlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var //TS: TsTabSheet;
     i: integer;
begin
  I:=(Sender as TPageControl).TabIndexAtClientPos(Point(X,Y));
  if i>-1 then
  if ssMiddle in Shift then
  if (Sender is TPageControl) then
                                  CloseDWGPage((Sender as TPageControl).Pages[I]);
end;
procedure MainForm.ShowFastMenu(Sender: TObject);
begin
     ShowFMenu;
end;

function MainForm.CreateZCADControl(aName: string;DoDisableAlign:boolean=false):TControl;
var
  //i:integer;
  pint:PGDBInteger;
  TB:TToolBar;
  tbdesk:string;
  ta:TmyAction;
  TempForm:TForm;
begin
  ta:=tmyaction(self.StandartActions.ActionByName('ACN_Show_'+aname));
  if ta<>nil then
                 ta.Checked:=true;

// if the form does not yet exist, create it
if aName='PageControl' then
begin
MainPanel:=Tform{Tpanel}(Tform.NewInstance);
if DoDisableAlign then
MainPanel.DisableAlign;
MainPanel.CreateNew(Application);
MainPanel.SetBounds(200,200,600,500);
MainPanel.Caption:=rsDrawingWindowWndName;
MainPanel.BorderWidth:=0;

DHPanel:=TPanel.Create(MainPanel);
DHPanel.Align:=albottom;
DHPanel.BevelInner:=bvNone;
DHPanel.BevelOuter:=bvNone;
DHPanel.BevelWidth:=0;
DHPanel.AutoSize:=true;
DHPanel.Parent:=MainPanel;

VScrollBar:=TScrollBar.create(MainPanel);
VScrollBar.Align:=alright;
VScrollBar.kind:=sbVertical;
VScrollBar.OnScroll:=_scroll;
VScrollBar.Enabled:=false;
VScrollBar.Parent:=MainPanel;

with TMySpeedButton.Create(DHPanel) do
begin
     Align:=alRight;
     Parent:=DHPanel;
     width:=VScrollBar.Width;
     onclick:=ShowFastMenu;
end;

HScrollBar:=TScrollBar.create(DHPanel);
HScrollBar.Align:=alClient;
HScrollBar.kind:=sbHorizontal;
HScrollBar.OnScroll:=_scroll;
HScrollBar.Enabled:=false;
HScrollBar.Parent:=DHPanel;
//HScrollBar.Anchors:=[akRight];
//HScrollBar.AnchorSideRight.Control:=DHPanel;
//HScrollBar.AnchorSideRight.Side:=asrBottom;
//HScrollBar.BorderSpacing.Right:=HScrollBar.Height;

{with TSpeedButton.Create(DHPanel) do
begin
   Align:=alright;
   width:=HScrollBar.Height;
   height:=HScrollBar.Height;
   Parent:=DHPanel;
   action:=tmyaction(self.StandartActions.ActionByName('ACN_VIEWTOP'));
   caption:='';
end;}

PageControl:=TmyPageControl.Create(MainPanel{Application});
PageControl.Constraints.MinHeight:=32;
PageControl.Parent:=MainPanel;
PageControl.Align:=alClient;
PageControl.{OnPageChanged}OnChange:=ChangedDWGTabCtrl;
PageControl.BorderWidth:=0;
if assigned(SysVar.INTF.INTF_DwgTabsPosition) then
begin
     case SysVar.INTF.INTF_DwgTabsPosition^ of
                                              TATop:PageControl.TabPosition:=tpTop;
                                              TABottom:PageControl.TabPosition:=tpBottom;
                                              TALeft:PageControl.TabPosition:=tpLeft;
                                              TARight:PageControl.TabPosition:=tpRight;
     end;
end;
if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then
begin
     if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
                                                    PageControl.Options:=PageControl.Options+[nboShowCloseButtons]
                                                else
                                                    PageControl.Options:=PageControl.Options-[nboShowCloseButtons]
end
else
    PageControl.Options:=[nboShowCloseButtons];
PageControl.OnCloseTabClicked:=CloseDWGPageInterf;
PageControl.OnMouseDown:=PageControlMouseDown;
PageControl.ShowTabs:=SysVar.INTF.INTF_ShowDwgTabs^;
result:=MainPanel;
result.Name:=aname;
end
else if aName='CommandLine' then
begin
CLine:=TCLine(TCLine.NewInstance);
CLine.FormStyle:=fsStayOnTop;
if DoDisableAlign then
CLine.DisableAlign;
CLine.CreateNew(Application);
CLine.SetBounds(200,100,600,100);
CLine.Caption:=rsCommandLineWndName;
CLine.Align:=alBottom;
pint:=SavedUnit.FindValue('VIEW_CommandLineH');
result:=CLine;

result.Name:=aname;
end
else if aName='ObjectInspector' then
begin
  if assigned(CreateObjInspInstanceProc)then
  begin
  TempForm:=CreateObjInspInstanceProc;
  if DoDisableAlign then
  TempForm.DisableAlign;
  TempForm.CreateNew(Application);
  TempForm.Caption:=rsGDBObjInspWndName;
  TempForm.SetBounds(0,100,200,600);
  if assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  if assigned(SetCurrentObjDefaultProc)then
                                           SetCurrentObjDefaultProc;
  pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  if assigned(SetNameColWidthProc)then
                                     SetNameColWidthProc(TempForm.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
  if assigned(pint)then
                       if assigned(SetNameColWidthProc)then
                       SetNameColWidthProc(pint^);//TempForm.namecol:=pint^;
  result:=TempForm;

  result.Name:=aname;
  end;
end
else
begin
tbdesk:=self.findtoolbatdesk(aName);
if tbdesk=''then
          shared.ShowError(format(rsToolBarNotFound,[aName]));
FToolBar:=TToolButtonForm(TToolButtonForm.NewInstance);
if DoDisableAlign then
FToolBar.DisableAlign;
FToolBar.CreateNew(Application);
FToolBar.Caption:='';
FToolBar.SetBounds(100,64,500,26);

TB:=TToolBar.Create(application);
TB.ButtonHeight:=sysvar.INTF.INTF_ObjInspRowH^;
TB.Align:=alclient;
if aName<>'Status' then
TB.EdgeBorders:=[];
TB.ShowCaptions:=true;
TB.Parent:=ftoolbar;

if aName='ToolBarR' then
begin
//ToolBarR:=tb;
end;
if aName='ToolBarU' then
begin
//ToolBarU:=tb;
end;
if aName='Status' then
begin
//ToolBarD:=tb;
CreateHTPB(tb);
end;
CreateToolbarFromDesk(tb,aName,tbdesk);

result:=FToolBar;

result.Name:=aname;
FToolBar.Caption:='';
end;

end;

procedure MainForm.DockMasterCreateControl(Sender: TObject; aName: string; var
  AControl: TControl; DoDisableAutoSizing: boolean);
//var
  //i:integer;
  //pint:PGDBInteger;
  //TB:TToolBar;
  //tbdesk:string;
  //ta:TmyAction;
  //TempForm:TForm;
  procedure CreateForm(Caption: string; NewBounds: TRect);
  begin
       begin
           AControl:=tform.create(Application);
           AControl.Name:=aname;
           Acontrol.Caption:=caption;
           Acontrol.BoundsRect:=NewBounds;
       end;
    //AControl:=CreateSimpleForm(aName,Caption,NewBounds,DoDisableAutoSizing);
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
  if not DoDisableAutoSizing then
                               Acontrol.EnableAutoSizing;
end;

procedure LoadLayoutFromFile(Filename: string);
(*var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  //debugln(['TIDEAnchorDockMaster.LoadLayoutFromFile ',Filename]);
  sysvar.PATH.LayoutFile^:=Filename;
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.LoadLayoutFromConfig(Config,{true}false);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;*)
var
  XMLConfig: TXMLConfigStorage;
begin
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create(Filename,True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed
      DockMaster.LoadLayoutFromConfig(XMLConfig,false);
      DockMaster.LoadSettingsFromConfig(XMLConfig);
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
                     filename:={'defaultlayout.xml'}sysvar.PATH.LayoutFile^
                 else
                     begin
                     s:=Operands;
                     filename:=utf8tosys(sysparam.programpath+'components/'+{'defaultlayout.xml'}s);
                     end;
  if not fileexists(filename) then
                              filename:=utf8tosys(sysparam.programpath+'components/defaultlayout.xml');
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
                            shared.ShowError(rsLayoutLoad+' '+Filename+':'#13+E.Message);
      //MessageDlg('Error',
      //  'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
      //  [mbCancel],0);
    end;
  end;
  //result:=cmd_ok;
end;
procedure MainForm.setnormalfocus(Sender: TObject);
begin
     if assigned(cmdedit) then
     if cmdedit.Enabled then
     if cmdedit.{IsControlVisible}IsVisible then
     if cmdedit.CanFocus then
     begin
     {if (GetParentForm(cmdedit)=Self) then
                                          ActiveControl:=cmdedit
                                      else}
                                          cmdedit.SetFocus;
     end;
end;
procedure MainForm.InitSystemCalls;
begin
  ShowAllCursorsProc:=self.ShowAllCursors;
  RestoreAllCursorsProc:=self.RestoreCursors;
  StartLongProcessProc:=self.StartLongProcess;
  ProcessLongProcessproc:=self.ProcessLongProcess;
  EndLongProcessProc:=self.EndLongProcess;
  messageboxproc:=self.MessageBox;
  AddOneObjectProc:=self.addoneobject;
  SetVisuaProplProc:=self.setvisualprop;
  UpdateVisibleProc:=UpdateVisible;
  ProcessFilehistoryProc:=self.processfilehistory;
  CursorOn:=ShowAllCursors;
  CursorOff:=RestoreCursors;
  commandmanager.OnCommandRun:=processcommandhistory;
  AppCloseProc:=asynccloseapp;
  zcadinterface.SetNormalFocus:=self.setnormalfocus;
end;

procedure MainForm.LoadActions;
var
   i:integer;
begin
  StandartActions:=TmyActionList.Create(self);
  if not assigned(StandartActions.Images) then
                             StandartActions.Images:=TImageList.Create(StandartActions);
  StandartActions.brocenicon:=StandartActions.LoadImage(sysparam.programpath+
  'menu/BMP/noimage.bmp');
  StandartActions.LoadFromACNFile(sysparam.programpath+'menu/actions.acn');
  StandartActions.LoadFromACNFile(sysparam.programpath+'menu/electrotech.acn');
  StandartActions.OnUpdate:=ActionUpdate;

  for i:=low(FileHistory) to high(FileHistory) do
  begin
       FileHistory[i]:=TmyAction.Create(self);
  end;
  for i:=low(Drawings) to high(Drawings) do
  begin
       Drawings[i]:=TmyAction.Create(self);
       Drawings[i].visible:=false;
  end;
  for i:=low(CommandsHistory) to high(CommandsHistory) do
  begin
       CommandsHistory[i]:=TmyAction.Create(self);
       CommandsHistory[i].visible:=false;
  end;
end;

procedure MainForm.CreateInterfaceLists;
begin
  updatesbytton:=tlist.Create;
  updatescontrols:=tlist.Create;
end;

procedure MainForm.FillColorCombo(cb:TCustomComboBox);
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

procedure MainForm.FillLTCombo(cb:TCustomComboBox);
begin
  cb.items.AddObject(rsByBlock, TObject(0));
end;

procedure MainForm.FillLWCombo(cb:TCustomComboBox);
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

procedure MainForm.CreateAnchorDockingInterface;
var
  action: tmyaction;
begin
  self.SetBounds(0, 0, 800, 44);
  //DockMaster.HeaderStyle:=adhsLines;
  DockMaster.SplitterClass:=TmyAnchorDockSplitter;
  DockMaster.ManagerClass:={TMy}TAnchorDockManager;
  DockMaster.OnCreateControl:={@}DockMasterCreateControl;
  DockMaster.MakeDockSite(Self, [akTop, akBottom, akLeft, akRight], admrpChild
    {admrpNone}, {true}false);
  if DockManager is TAnchorDockManager then
  begin
    //aManager:=TAnchorDockManager(AForm.DockManager);
    //TAnchorDockManager(DockManager).PreferredSiteSizeAsSiteMinimum:={false}true;
    //DockMaster.HideHeaderCaptionFloatingControl:=false;
       DockMaster.OnShowOptions:={@}ShowAnchorDockOptions;
    //TAnchorDockManager(self.DockManager).PreferredSiteSizeAsSiteMinimum:=false;
    //TAnchorDockManager(self)
    //self.DockSite:=true;
    //DockMaster.ShowHeaderCaption:=false;
    //self.AutoSize:=false;
  end;
   if not sysparam.noloadlayout then
                                    LoadLayout_com('');

   //self.AutoSize:=false;
   //self.BorderStyle:=bsNone;

   //WindowState:=wsMaximized;

   {ToolBarD:=TToolBar.Create(self);
   ToolBarD.Height:=18;
   ToolBarD.Align:=alBottom;
   ToolBarD.AutoSize:=true;
   ToolBarD.ShowCaptions:=true;
   ToolBarD.EdgeBorders:=[ebTop];
   ToolBarD.Parent:=self;}

   //DockMaster.ShowControl('ToolBarD',true);

   //ToolBarD.Parent:=self;

   //DockMaster.ShowControl('ToolBarU',true);
  if sysparam.noloadlayout then
  begin
       DockMaster.ShowControl('CommandLine', true);
       DockMaster.ShowControl('ObjectInspector', true);
       DockMaster.ShowControl('PageControl', true);
  end;

   ToolBarU:=TToolBar.Create(self);
   ToolBarU.Align:={alTop}alClient;
   ToolBarU.AutoSize:=true;
   ToolBarU.ButtonHeight:=sysvar.INTF.INTF_ObjInspRowH^;
   ToolBarU.ShowCaptions:=true;
   ToolBarU.Parent:=self;
   ToolBarU.EdgeBorders:=[ebTop, ebBottom, ebLeft, ebRight];
   self.CreateToolbarFromDesk(ToolBarU, 'STANDART', self.findtoolbatdesk('STAND'
     +'ART'));
   action:=tmyaction(StandartActions.ActionByName('ACN_SHOW_STANDART'));
   if assigned(action) then
                           begin
                                action.Enabled:=false;
                                action.Checked:=true;
                                action.pfoundcommand:=nil;
                                action.command:='';
                                action.options:='';
                           end;


   //self.DisableAutoSizing;

   //DockMaster.ShowControl('ObjectInspector',true);
   {tf:= tform.Create(nil);
   tf.Name:='test';
   tf.show;}

   //TAnchorDockManager(self.DockManager).PreferredSiteSizeAsSiteMinimum:=true;
end;


procedure MainForm.CreateStandartInterface;
var
  //action: tmyaction;
  TempForm:TForm;
  //pint:PGDBInteger;
begin
  self.SetBounds(0,0,sysparam.screenx-100,sysparam.screeny-100);

  //self.DisableAlign;

  {ToolBarU:=TToolBar.Create(self);
  ToolBarU.Align:=alTop;
  ToolBarU.AutoSize:=true;
  ToolBarU.ShowCaptions:=true;
  ToolBarU.Parent:=self;
  ToolBarU.EdgeBorders:=[ebTop, ebBottom, ebLeft, ebRight];
  self.CreateToolbarFromDesk(ToolBarU, 'STANDART', self.findtoolbatdesk('STANDART'));
  action:=tmyaction(StandartActions.ActionByName('ACN_SHOW_STANDART'));
  if assigned(action) then
                          begin
                               action.Enabled:=false;
                               action.Checked:=true;
                               action.pfoundcommand:=nil;
                               action.command:='';
                               action.options:='';
                          end;}
  TempForm:=TForm(CreateZCADControl('Standart'));
  TempForm.BorderStyle:=bsnone;
  TempForm.Parent:=self;
  TempForm.Align:=alTop;
  TempForm.Show;

  TempForm:=TForm(CreateZCADControl('PageControl'));
  TempForm.BorderStyle:=bsnone;
  TempForm.Parent:=self;
  TempForm.Align:=alClient;
  TempForm.Show;

  TempForm:=TForm(CreateZCADControl('ObjectInspector'));
  TempForm.Parent:=self;
  TempForm.Align:=alLeft;
  TempForm.Show;

  TempForm:=TForm(CreateZCADControl('CommandLine'));
  TempForm.BorderStyle:=bsnone;
  TempForm.Parent:=self;
  TempForm.Align:=alBottom;
  TempForm.Show;

  TempForm:=TForm(CreateZCADControl('Draw'));
  TempForm.BorderStyle:=bsnone;
  TempForm.Parent:=self;
  TempForm.Align:=alRight;
  TempForm.Show;

  TempForm:=TForm(CreateZCADControl('Status'));
  TempForm.BorderStyle:=bsnone;
  TempForm.Parent:={self}CLine;
  TempForm.Align:=alBottom;
  TempForm.Show;

  //self.EnableAlign;
end;
procedure MainForm.FormCreate(Sender: TObject);
//var
  //i:integer;
  //pint:PGDBInteger;
  //bmp:TPortableNetworkGraphic;
begin
  DecorateSysTypes;
  self.onclose:=self.FormClose;
  self.onkeydown:=self.mykeypress;
  self.KeyPreview:=true;
  application.OnIdle:=self.idle;
  SystemTimer:=TTimer.Create(self);
  SystemTimer.Interval:=1000;
  SystemTimer.Enabled:=true;
  SystemTimer.OnTimer:=self.generaltick;

  InitSystemCalls;
  LoadIcons;
  LoadActions;
  toolbars:=tstringlist.Create;
  toolbars.Sorted:=true;
  CreateInterfaceLists;
  loadpanels(sysparam.programpath+'menu/mainmenu.mn');

  if sysparam.standartinterface then
                                    CreateStandartInterface
                                else
                                    CreateAnchorDockingInterface;
end;

procedure MainForm.AfterConstruction;

begin
    name:='MainForm';
    oncreate:=FormCreate;
    inherited;
end;
procedure MainForm.SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);
var
    bmp:TBitmap;
begin
     if length(img)>1 then
     begin
          if img[1]<>'#' then
                              begin
                              img:={SysToUTF8}(sysparam.programpath)+'menu/BMP/'+img;
                              bmp:=TBitmap.create;
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
{procedure MainForm.LayerBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
   plp:PGDBLayerProp;
   Dest: PChar;
   pdwg:PTDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  if pdwg=nil then
   exit;
  if pdwg.LayerTable.Count=0 then
   exit;
  canvas.Brush.Color := clBtnFace;
  canvas.FillRect(ARect);
    pointer(plp):=LayerBox.Items.Objects[Index];
    if plp=nil then
                   s:=rsDifferent
               else
                   begin
                   s:=LayerBox.Items.Strings[Index];;
                   if plp^._on then
                                   iconlist.Draw(LayerBox.Canvas,1,ARect.Top,4)
                               else
                                   iconlist.Draw(LayerBox.Canvas,1,ARect.Top,3);
                   if plp^._lock then
                                   iconlist.Draw(LayerBox.Canvas,17,ARect.Top,8)
                               else
                                   iconlist.Draw(LayerBox.Canvas,17,ARect.Top,7);
                   end;
    ARect.Left:=ARect.Left+36;
    DrawText(LayerBox.canvas.Handle,@s[1],length(s),arect,DT_LEFT or DT_VCENTER)
end;}
procedure superdrawdraw(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:pointer);
var
  midline:integer;
  geom:ZGLGeometry;
  ppoly,poldpoly:^TPOINT;
begin
  exit;
  geom.init;
  canvas.Line(round(poldpoly.x),round(midline-poldpoly.y),round(ppoly.x),round(midline-ppoly.y));
  poldpoly:=ppoly;
  canvas.Pen.Width:=1;
  geom.done;
  canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-5) div 2,s);
end;
procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);
var
  y:integer;
  midline:integer;
  oldw:Integer;
  n:double;
  geom:ZGLGeometry;
  vp:GDBObjVisualProp;
  p1,p2:Gdbvertex;
    p,pp,ppp:PGDBVertex;
    i:GDBInteger;
    Points: array of TPoint;
    ppoly,poldpoly:PGDBPolyVertex3D;
    ll: Integer;
const
      txtoffset=5;
begin
  if {(ll>0)and}(plt<>nil)and(plt.len>0) then
   begin
        if s<>'' then
                     ll:={ARect.Left+}canvas.TextExtent(s).cx+2*txtoffset
                 else
                     ll:=0;
        geom.init;
        p1:=createvertex(ARect.Left+ll,(ARect.Top+ARect.Bottom)/2,0);
        p2:=createvertex(ARect.Right-txtoffset,p1.y,0);
        vp.LineType:=plt;
        vp.LineTypeScale:=(p2.x-p1.x)*(1/plt.len/sysvar.DWG.DWG_LTScale^);
        if {(plt^.h=0)and}({(plt^.shapearray.Count=0)and}(plt^.Textarray.Count=0)) then
                        n:=4
                    else
                        n:=1.000001;
        if plt^.h*vp.LineTypeScale>(ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^/2 then
                                                                  n:={trunc}( 2+2*(plt^.h*vp.LineTypeScale)/((ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^));
        vp.LineTypeScale:=vp.LineTypeScale/n;
        //scale:=SysVar.dwg.DWG_LTScale^*vp.LineTypeScale;
        //num:=Length/(scale*vp.LineType.len)
        geom.DrawLineWithLT(p1,p2,vp);
        oldw:=canvas.Pen.Width;
        canvas.Pen.Style:=psSolid;
        canvas.Pen.EndCap:=pecFlat;
        y:=(ARect.Top+ARect.Bottom)div 2;
        midline:=ARect.Top+ARect.Bottom;
        //canvas.Line(ARect.Left,y,ARect.Left+ll,y);

        CanvasDrawer.midline:=midline;
        CanvasDrawer.canvas:=canvas;
        CanvasDrawer.PVertexBuffer:=@geom.Vertex3S;
        geom.DrawLLPrimitives(CanvasDrawer);
        (*
        if geom.Lines.count>0 then
        begin
        p:=geom.Lines.PArray;
        for i:=0 to (geom.Lines.count-1)div 2 do
        begin
           pp:=p;
           inc(p);
           canvas.Line(round(pp.x),round(midline-pp.y),round(p.x),round(midline-p.y));
           inc(p);
        end;
        end;

        if geom.Points.count>0 then
        begin
        p:=geom.Points.PArray;
        for i:=0 to (geom.Points.count-1) do
        begin
           Canvas.Pixels[round(p.x),round(midline-p.y)]:=canvas.Pen.Color;
           inc(p);
        end;
        end;
        *)


        if geom.Triangles.count>0 then
        begin
        canvas.Brush.Style:=bsSolid;
        canvas.Brush.Color:=canvas.Pen.Color;
        p:=geom.Triangles.PArray;
        for i:=0 to (geom.Triangles.count-1)div 3 do
        begin
           pp:=p;
           inc(p);
           ppp:=p;
           inc(p);
           setlength(points,3);
           points[0].x:=round(pp.x);
           points[0].y:=round(midline-pp.y);
           points[1].x:=round(ppp.x);
           points[1].y:=round(midline-ppp.y);
           points[2].x:=round(p.x);
           points[2].y:=round(midline-p.y);

           canvas.Polygon(Points);
           inc(p);
        end;
        end;

        if geom.SHX.count>1 then
        begin
        //oglsm.myglbegin(GL_LINES);
        ppoly:=geom.SHX.parray;
        poldpoly:=nil;
        for i:=0 to geom.SHX.count-1 do
        begin
                if ppoly^.count<>0 then
                                  begin
                                       if poldpoly<>nil then
                                        begin
                                          canvas.Line(round(poldpoly.coord.x),round(midline-poldpoly.coord.y),round(ppoly.coord.x),round(midline-ppoly.coord.y));
                                        end;
                                       poldpoly:=ppoly;
                                       //if ppoly^.count=-1 then
                                       //                       poldpoly:=nil
                                  end
                                  else
                                  begin
                                  if poldpoly<>nil then
                                                       begin
                                                       canvas.Line(round(poldpoly.coord.x),round(midline-poldpoly.coord.y),round(ppoly.coord.x),round(midline-ppoly.coord.y));
                                                       poldpoly:=nil;
                                                       end
                                                   else
                                                       poldpoly:=ppoly;
                                  end;
                                  //oglsm.myglvertex3dv(pointer(ppoly));
           //poldpoly:=ppoly;
           inc(ppoly);
        end;
        //oglsm.myglend;
        end;

        canvas.Pen.Width:=oldw;
        //ARect.Left:=ARect.Left+{ll+}txtoffset;
        geom.done;
   end;
  canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
  //DrawText(canvas.Handle,@s[1],length(s),arect,DT_LEFT or DT_SINGLELINE or DT_VCENTER)
end;

procedure MainForm.LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                               State: TOwnerDrawState);
var
   plt:PGDBLtypeProp;
   ll:integer;
begin
    if gdb.GetCurrentDWG=nil then
                                 exit;
    if gdb.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);
    if {(odComboBoxEdit in State)}not TComboBox(Control).DroppedDown then
                                      begin
                                           plt:=IVars.CLType;
                                      end
                                 else
                                     plt:=PGDBLtypeProp(tcombobox(Control).items.Objects[Index]);
   if plt=LTEditor then
                       begin
                       s:=rsSelectLT;
                       plt:=nil;
                       ll:=0;
                       end
else if plt<>nil then
                   begin
                        s:=Tria_AnsiToUtf8(plt^.Name);
                        ll:=30;
                   end
               else
                   begin
                       s:=rsDifferent;
                       if gdb.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
                       ll:=0;
                   end;

    ARect.Left:=ARect.Left+2;
    drawLT(TComboBox(Control).canvas,ARect,{ll,}s,plt);
end;

procedure MainForm.LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
   //plp:PGDBLayerProp;
   //Dest: PChar;
   {y,pw,}ll:integer;
begin
  //y:=(ARect.Top+ARect.Bottom)div 2;
  //TComboBox(Control).canvas.Rectangle(ARect.Left,y,ARect.Left+10,y+10);
  //TComboBox(Control).canvas.Line(ARect.Left,y,ARect.Left+ll,y);
    if gdb.GetCurrentDWG=nil then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);
    if {(odComboBoxEdit in State)}not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CLWeight;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
   s:=GetLWNameFromLW(index);
   if (index<4)or(index=ClDifferent) then
              ll:=0
          else
              ll:=30;
    ARect.Left:=ARect.Left+2;
    drawLW(TComboBox(Control).canvas,ARect,ll,(index) div 10,s);
end;
procedure DrawColor(Canvas:TCanvas; Index: Integer; ARect: TRect);
var
   s:string;
   textrect: TRect;
   y:integer;
const
     cellsize=11;
     textoffset=cellsize+5;
begin
  s:=GetColorNameFromIndex(index);
  ARect.Left:=ARect.Left+2;
  textrect:=ARect;
  if index<ClSelColor then
   begin
        textrect.Left:=textrect.Left+textoffset;
        canvas.TextRect(ARect,textrect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
        if index in [1..255] then
                       begin
                            canvas.Brush.Color:=RGBToColor(palette[index].RGB.r,palette[index].RGB.g,palette[index].RGB.b);
                       end
                   else
                       canvas.Brush.Color:=clWhite;
        y:=(ARect.Top+ARect.Bottom-cellsize)div 2;
        canvas.Rectangle(ARect.Left,y,ARect.Left+cellsize,y+cellsize);
        if index=7 then
                       begin
                            canvas.Brush.Color:=clBlack;
                            canvas.Polygon([point(ARect.Left,y),point(ARect.Left+cellsize-1,y),point(ARect.Left+cellsize-1,y+cellsize-1)]);
                        end
   end
  else
  begin
       canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
  end;
end;
procedure MainForm.ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
begin
    if (gdb.GetCurrentDWG=nil)or(sysvar.DWG.DWG_CColor=nil) then
    exit;
    begin
    ComboBoxDrawItem(Control,ARect,State);
    if {(odComboBoxEdit in State)}not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CColor;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
    DrawColor(TComboBox(Control).canvas,Index,ARect);
    end;
end;
procedure MainForm.ColorDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
begin
    begin
    ComboBoxDrawItem(Control,ARect,State);
    index:=integer(tcombobox(Control).items.Objects[Index]);
    DrawColor(TComboBox(Control).canvas,Index,ARect);
    end;
end;
function MainForm.CreateCBox(owner:TToolBar;DrawItem:TDrawItemEvent;Change,DropDown,CloseUp:TNotifyEvent;Filler:TComboFiller;w:integer;ts:GDBString):TComboBox;
begin
  result:=TComboBox.Create(owner);
  result.Style:=csOwnerDrawFixed;
  {result.AutoSize:=false;}
  SetComboSize(result);
  result.Clear;
  result.readonly:=true;
  result.DropDownCount:=50;
  //result.ItemHeight:=16;
  if w<>0 then
              result.Width:=w;
  if ts<>''then
  begin
       ts:=InterfaceTranslate('hint_panel~LINEWCOMBOBOX',ts);
       result.hint:=(ts);
       result.ShowHint:=true;
  end;

  result.OnDrawItem:=DrawItem;
  result.OnChange:=Change;
  result.OnDropDown:=DropDown;
  result.OnCloseUp:=CloseUp;
  result.OnMouseLeave:=setnormalfocus;

  if assigned(Filler)then
                         Filler(result);
  result.ItemIndex:=0;

  AddToBar(owner,result);
  updatescontrols.Add(result);
end;

procedure MainForm.CreateToolbarFromDesk(tb:TToolBar;tbname,tbdesk:string);
var
    f:GDBOpenArrayOfByte;
    line,ts,ts2,{bn,}bc,masks{,bh}:GDBString;
    mask:DWord;
    buttonpos:GDBInteger;
    b:TToolButton;
    i:longint;
    {y,xx,yy,}w,code:GDBInteger;
    //bmp:TBitmap;
    //te:tedit;
    action:tmyaction;
    baction:TmyButtonAction;
    shortcut:TShortCut;

  procedure ReadComboSubParam(out a,b:string;out c:integer);
  begin
    a := f.readstring(',','');
    b := f.readstring(';','');
    val(a,c,code);
    if code<>0 then
                  c:=0;
  end;

begin
     if not assigned(tb.Images) then
                                    tb.Images:=standartactions.Images;
     if tbdesk<>'' then
      begin
           f.init({$IFDEF DEBUGBUILD}'{BF3C3480-8736-4378-AA0E-D96EFFE4FC7A}',{$ENDIF}length(tbdesk));
           f.AddData(@tbdesk[1],length(tbdesk));

           repeat
           line := f.readstring(';','');
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='ACTION' then
                     begin
                          line := f.readstring(';','');
                          action:=tmyaction(self.StandartActions.ActionByName(line));
                          b:=TmyCommandToolButton.Create(tb);
                          b.Action:=action;
                          b.ShowCaption:=false;
                          b.ShowHint:=true;
                          b.Caption:=action.imgstr;
                          //b.AutoSize:=true;
                          AddToBar(tb,b);
                          b.Visible:=true;
                     end;
                     if uppercase(line)='BUTTON' then
                     begin
                          bc := f.readstring(',','');
                          line := f.readstring(';','');
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyCommandToolButton.Create(tb);
                          TmyCommandToolButton(b).FCommand:=bc;
                          //b.AutoSize:=true;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~'+bc,ts);
                          b.hint:=(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(tb,b,line,true,'button_command~'+bc);
                          AddToBar(tb,b);
                     end;
                     if uppercase(line)='VARIABLE' then
                     begin
                          bc := f.readstring(',','');
                          masks:='';
                          i:=pos('|', bc);
                          if i>0 then
                                     begin
                                          masks:=system.copy(bc,i+1,length(bc)-i);
                                          bc:=system.copy(bc,1,i-1);
                                     end;
                          if masks<>''then
                                         begin
                                              val(masks,mask,code);
                                              if code<>0 then
                                                             mask:=0;
                                         end
                                     else
                                         mask:=0;
                          line := f.readstring(';','');
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          i:=pos(',',ts);
                          if i>0 then
                                     begin
                                          ts2:=system.copy(ts,i+1,length(ts)-i);
                                          ts:=system.copy(ts,1,i-1);
                                     end;
                          b:=TmyVariableToolButton.Create(tb);
                          b.Style:=tbsCheck;
                          TmyVariableToolButton(b).AssignToVar(bc,mask);
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~'+bc,ts);
                          b.hint:=(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(tb,b,line,false,'button_variable~'+bc);
                          //b.AutoSize:=true;
                          AddToBar(tb,b);
                          updatesbytton.Add(b);
                          if ts2<>'' then
                          begin
                               shortcut:=TextToShortCut(ts2);
                               if shortcut>0 then
                               begin
                               baction:=TmyButtonAction.Create(StandartActions);
                               baction.button:=b;
                               baction.ShortCut:=shortcut;
                               StandartActions.AddMyAction(TMyAction(baction));
                               end;
                               ts2:='';
                          end;
                     end;
                     if uppercase(line)='LAYERCOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          {if assigned(LayerBox) then
                                                    shared.ShowError(format(rsReCreating,['LAYERCOMBOBOX']));}
                          LayerBox:=TZCADLayerComboBox.Create(tb);
                          LayerBox.ImageList:=IconList;

                          LayerBox.Index_Lock:=II_LayerLock;
                          LayerBox.Index_UnLock:=II_LayerUnLock;
                          LayerBox.Index_Freze:=II_LayerFreze;
                          LayerBox.Index_UnFreze:=II_LayerUnFreze;
                          LayerBox.Index_ON:=II_LayerOn;
                          LayerBox.Index_OFF:=II_LayerOff;

                          LayerBox.fGetLayerProp:=self.GetLayerProp;
                          LayerBox.fGetLayersArray:=self.GetLayersArray;
                          LayerBox.fClickOnLayerProp:=self.ClickOnLayerProp;
                          {LayerBox.Style:=csOwnerDrawFixed}{Variable};
                          {LayerBox.OnDrawItem:=LayerBoxDrawItem;}
                          if code=0 then
                                        LayerBox.Width:=w;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~LAYERCOMBOBOX',ts);
                               LayerBox.hint:=(ts);
                               LayerBox.ShowHint:=true;
                          end;
                          //LayerBox.OnChange:=ChangeCLayer;
                          {LayerBox.ReadOnly:=true;}
                          LayerBox.AutoSize:=false;
                          {LayerBox.OnMouseLeave:=self.setnormalfocus;}
                          AddToBar(tb,LayerBox);
                          LayerBox.Height:=10;
                          updatescontrols.Add(LayerBox);
                     end;
                     if uppercase(line)='LINEWCOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          LineWBox:=CreateCBox(tb,LineWBoxDrawItem,ChangeCLineW,DropDownColor,DropUpColor,FillLWCombo,w,ts);
                     end;
                     if uppercase(line)='COLORCOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          ColorBox:=CreateCBox(tb,ColorBoxDrawItem,ChangeCColor,DropDownColor,DropUpColor,FillColorCombo,w,ts);
                     end;
                     if uppercase(line)='LTYPECOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          LTypeBox:=CreateCBox(tb,LTypeBoxDrawItem,ChangeLType,DropDownLType,DropUpLType,FillLTCombo,w,ts);
                     end;
                     if uppercase(line)='TSTYLECOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          TStyleBox:=CreateCBox(tb,TSupportTStyleCombo.DrawItemTStyle,TSupportTStyleCombo.ChangeLType,TSupportTStyleCombo.DropDownTStyle,TSupportTStyleCombo.CloseUpTStyle,TSupportTStyleCombo.FillLTStyle,w,ts);
                     end;
                     if uppercase(line)='DIMSTYLECOMBOBOX' then
                     begin
                          ReadComboSubParam(bc,ts,w);
                          DimStyleBox:=CreateCBox(tb,TSupportDimStyleCombo.DrawItemTStyle,TSupportDimStyleCombo.ChangeLType,TSupportDimStyleCombo.DropDownTStyle,TSupportDimStyleCombo.CloseUpTStyle,TSupportDimStyleCombo.FillLTStyle,w,ts);
                     end;
                     if uppercase(line)='SEPARATOR' then
                                         begin
                                         buttonpos:=buttonpos+3;
                                         TToolButton(b):={Tmy}TToolButton.Create(tb);
                                         b.Style:=
                                         tbsDivider;
                                          AddToBar(tb,b);
                                          TToolButton(b).AutoSize:=false;
                                         end;
                end;
                //line := f.readstring(';','');
           end;

           until not(f.ReadPos<f.count);
           if (tbname='Status')and(not sysparam.standartinterface) then
                       begin
                            if assigned(LayoutBox) then
                                                      shared.ShowError(format(rsReCreating,['LAYOUTBOX']));
                            CreateLayoutbox(tb);
                            //LayoutBox.OnDrawItem:=LineWBoxDrawItem;

                            //if code=0 then
                            //              LineWBox.Width:=w;
                            if ts<>''then
                            begin
                                 //ts:=InterfaceTranslate('hint_panel~LAYOUTBOX',ts);
                                 //LineWBox.hint:=(ts);
                                 //LineWBox.ShowHint:=true;
                            end;
                            AddToBar(tb,LayoutBox);
                            LayoutBox.AutoSize:=false;
                            LayoutBox.Width:=200;
                            LayoutBox.Align:=alRight;

                       end;
           f.done;

      end;
end;
procedure addfiletoLayoutbox(filename:GDBString);
var
    s:string;
begin
     s:=ExtractFileName(filename);
     LayoutBox.AddItem(copy(s,1,length(s)-4),nil);
end;
procedure MainForm.CreateLayoutbox(tb:TToolBar);
var
    s:string;
begin
  LayoutBox:=TComboBox.Create(tb);
  LayoutBox.Style:=csDropDownList;
  LayoutBox.Sorted:=true;
  FromDirIterator(sysparam.programpath+'components/','*.xml','',addfiletoLayoutbox,nil);
  LayoutBox.OnChange:=ChangeLayout;

  s:=extractfilename(sysvar.PATH.LayoutFile^);
  LayoutBox.ItemIndex:=LayoutBox.Items.IndexOf(copy(s,1,length(s)-4));

end;
procedure MainForm.ChangeLayout(Sender:Tobject);
var
    s:string;
begin
  //LayoutBox.Items.Strings[LayoutBox.ItemIndex]:='1';
  //LayoutBox.text:=LayoutBox.text;
  s:=sysparam.programpath+'components/'+LayoutBox.text+'.xml';
  //LoadLayout_com(@s[1]);
  LoadLayoutFromFile(s);
  (*var
    XMLConfig: TXMLConfigStorage;
    filename:string;
    s:string;
  begin
    if Operands='' then
                       s:='defaultlayout.xml'
                   else
                       s:=Operands;

    try
      // load the xml config file
      filename:=utf8tosys(sysparam.programpath+'components/'+{'defaultlayout.xml'}s);*)
end;

procedure MainForm.loadpanels(pf:GDBString);
var
    f:GDBOpenArrayOfByte;
    line{,ts}{bn,}{bc}{,bh}:GDBString;
    //buttonpos:GDBInteger;
    //ppanel:TToolBar;
    //b:TToolButton;
    //i:longint;
    //y,xx,yy,w,code:GDBInteger;
    //bmp:TBitmap;
    //action:tmyaction;

    paneldesk:string;
//const bsize=24;
begin
  f.InitFromFile(pf);
  while f.notEOF do
  begin
    line := f.readstring(' ',#$D#$A);
    if (line <> '') and (line[1] <> ';') then
    begin
      if uppercase(line) = 'PANEL' then
      begin
           line := f.readstring('; ','');
           paneldesk:=line+':';
           //ts:=line;
           {if uppercase(ts)='ToolBarR'
           then
               begin
                    ppanel:=ToolBarR
               end
           else
               if uppercase(ts)='UPPANEL' then
               begin
                    ppanel:=ToolBarU;
               end
           else
               if uppercase(ts)='TOOLBARD' then
               begin
                    ppanel:=ToolBarD;
               end;}

           {if ppanel<>ToolBarD then
           begin
                line := f.readstring(',','');
                line := f.readstring(',','');
                y:=strtoint(line);
                line := f.readstring(',','');
                xx:=strtoint(line);
                line := f.readstring(';','');
                yy:=strtoint(line);
           end;}

           //buttonpos:=0;
           while line<>'{' do
                             line := f.readstring(#$A,#$D);
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     paneldesk:=paneldesk+line+';';
                     if uppercase(line)<>'SEPARATOR' then
                     begin
                     line := f.readstring(#$A,#$D);
                     paneldesk:=paneldesk+line+';';
                     end;
                     {if uppercase(line)='ACTION' then
                     begin
                          line := f.readstring(#$A,#$D);
                          action:=tmyaction(self.StandartActions.ActionByName(line));
                          b:=TmyCommandToolButton.Create(standartactions);
                          b.Action:=action;
                          b.ShowCaption:=false;
                          b.ShowHint:=true;
                          b.Caption:=action.imgstr;
                          AddToBar(ppanel,b);
                     end;
                     if uppercase(line)='BUTTON' then
                     begin
                          bc := f.readstring(',','');
                          line := f.readstring(#$A,#$D);
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyCommandToolButton.Create(ppanel);
                          TmyCommandToolButton(b).FCommand:=bc;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~'+bc,ts);
                          b.hint:=(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(ppanel,b,line,true,'button_command~'+bc);
                          buttonpos:=buttonpos+bsize;
                          AddToBar(ppanel,b);
                     end;
                     if uppercase(line)='VARIABLE' then
                     begin
                          bc := f.readstring(',','');
                          line := f.readstring(#$A,#$D);
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyVariableToolButton.Create(ppanel);
                          b.Style:=tbsCheck;
                          TmyVariableToolButton(b).AssignToVar(bc);
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~'+bc,ts);
                          b.hint:=(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(ppanel,b,line,false,'button_variable~'+bc);
                          b.AutoSize:=true;
                          AddToBar(ppanel,b);

                     end;
                     if uppercase(line)='LAYERCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(#$A,#$D);
                          val(bc,w,code);
                          if assigned(LayerBox) then
                                                    shared.ShowError(format(ES_ReCreating,['LAYERCOMBOBOX']));
                          LayerBox:=TComboBox.Create(ppanel);
                          if code=0 then
                                        LayerBox.Width:=w;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~LAYERCOMBOBOX',ts);
                               LayerBox.hint:=(ts);
                               LayerBox.ShowHint:=true;
                          end;
                          LayerBox.OnChange:=ChangeCLayer;
                          LayerBox.ReadOnly:=true;
                          LayerBox.AutoSize:=false;
                          AddToBar(ppanel,LayerBox);
                     end;
                     if uppercase(line)='LINEWCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(#$A,#$D);
                          val(bc,w,code);
                          if assigned(LineWBox) then
                                                    shared.ShowError(format(ES_ReCreating,['LINEWCOMBOBOX']));
                          LineWBox:=TComboBox.Create(ppanel);
                          if code=0 then
                                        LineWBox.Width:=w;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~LINEWCOMBOBOX',ts);
                               LineWBox.hint:=(ts);
                               LineWBox.ShowHint:=true;
                          end;
                          LineWbox.Clear;
                          LineWbox.readonly:=true;
                          LineWbox.items.Add(S_default);
                          LineWbox.items.Add(S_ByBlock);
                          LineWbox.items.Add(S_ByLayer);
                          for i := 0 to 20 do
                          begin
                          s:=floattostr(i / 10) + ' '+S_mm;
                               LineWbox.items.Add((s));
                          end;
                          LineWbox.items.Add(S_Different);
                          LineWbox.OnChange:=ChangeCLineW;
                          LineWbox.AutoSize:=false;
                           AddToBar(ppanel,LineWBox);
                     end;
                     if uppercase(line)='SEPARATOR' then
                                         begin
                                         buttonpos:=buttonpos+3;
                                         TToolButton(b):=TmyToolButton.Create(ppanel);
                                         b.Style:=
                                         tbsDivider;
                                          AddToBar(ppanel,b);
                                          TToolButton(b).AutoSize:=false;
                                         end;}
                end;
                line := f.readstring(#$A' ',#$D);
           end;
           toolbars.Add(paneldesk);
           log.programlog.LogOutStr(paneldesk,0);
           //ppanel^.setxywh(ppanel.wndx,ppanel.wndy,ppanel.wndw,buttonpos+bsize);
           //ppanel^.Show;

      end
      else if uppercase(line) =createmenutoken  then
      begin
           //MainMenu:=menu;
           createmenu(f,{MainMenu,}line);
      end
      else if uppercase(line) =setmainmenutoken  then
      begin
           //MainMenu:=menu;
           setmainmenu(f,{MainMenu,}line);
      end
      else if uppercase(line) = menutoken then
      begin
           //MainMenu:=menu;
           loadmenu(f,{MainMenu,}line);
      end
      else if uppercase(line) = popupmenutoken then
      begin
           //MainMenu:=menu;
           loadpopupmenu(f,{MainMenu,}line);
      end
    end;
  end;
  //--------------------------------SetMenu(MainForm.handle,pmenu.handle);
  //f.close;
  f.done;
end;
procedure MainForm.loadmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    //pmenuitem:TmyMenuItem;
    ppopupmenu:TMenuItem;
begin
           {if not assigned(pm) then
                                   begin
                                   pm:=TMainMenu.Create(self);
                                   pm.Images:=self.StandartActions.Images;
                                   end;}


           line := f.readstring(';','');
           line:=(line);


           ppopupmenu:=TMenuItem.Create({pm}application);
           ppopupmenu.Name:=MenuNameModifier+uppercase(line);
           line:=InterfaceTranslate('menu~'+line,line);
           ppopupmenu.Caption:=line;
           //pm.items.Add(ppopupmenu);

           loadsubmenu(f,ppopupmenu,line);

end;
procedure MainForm.loadpopupmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    //pmenuitem:TmyMenuItem;
    ppopupmenu:TPopupMenu;
begin
           {if not assigned(pm) then
                                   begin
                                   pm:=TMainMenu.Create(self);
                                   pm.Images:=self.StandartActions.Images;
                                   end;}


           line := f.readstring(';','');
           line:=(line);


           ppopupmenu:=TmyPopupMenu.Create({pm}application);
           ppopupmenu.Name:=MenuNameModifier+uppercase(line);
           ppopupmenu.Images := StandartActions.Images;
           line:=InterfaceTranslate('menu~'+line,line);
           //ppopupmenu.Caption:=line;
           //pm.items.Add(ppopupmenu);

           loadsubmenu(f,TMenuItem(ppopupmenu),line);
           //ppopupmenu.Alignment:=paLeft;

           cxmenumgr.RegisterLCLMenu(ppopupmenu)

end;
procedure MainForm.setmainmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    pmenu:TMainMenu;
begin
     line := f.readstring(';','');
     pmenu:=TMainMenu(self{application}.FindComponent(MenuNameModifier+uppercase(line)));
     self.Menu:=pmenu;
end;

procedure MainForm.createmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    //pmenuitem:TmyMenuItem;
    ppopupmenu:TMenuItem;
    ts:GDBString;
    menuname:string;
    createdmenu:TMenu;
begin
           {if not assigned(createdmenu) then
                                   begin}
                                   createdmenu:=TMainMenu.Create(self{application});
                                   createdmenu.Images:=self.StandartActions.Images;
                                   {end;}


           line := f.readstring(';','');
           GetPartOfPath(menuname,line,' ');
           createdmenu.Name:=MenuNameModifier+uppercase(menuname);
           repeat
           GetPartOfPath(ts,line,',');
           ppopupmenu:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(ts)));
           if ppopupmenu<>nil then
                                  begin
                                       createdmenu.items.Add(ppopupmenu);
                                  end
                              else
                                  shared.ShowError(format(rsMenuNotFounf,[ts]));


           until line='';


           (*ppopupmenu:=TMenuItem.Create({createdmenu}application);
           ppopupmenu.Name:='menu_'+line;
           line:=InterfaceTranslate('menu~'+line,line);
           ppopupmenu.Caption:=line;
           //createdmenu.items.Add(ppopupmenu);

           loadsubmenu(f,ppopupmenu,line);*)

end;
procedure bugfileiterator(filename:GDBString);
var
    myitem:TmyMenuItem;
begin
  myitem:=TmyMenuItem.Create(localpm.localpm,'**'+extractfilename(filename),'Load('+filename+')');
  localpm.localpm.SubMenuImages:=IconList;
  myitem.ImageIndex:=localpm.ImageIndex;
  localpm.localpm.Add(myitem);
  //localpm.Add(pmenuitem);
end;
procedure MainForm.loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);
var
    pmenuitem:TmyMenuItem;
    pm1:TMenuItem;
    {ppopupmenu,}submenu:TMenuItem;
    line2:GDBString;
    i:integer;
    pstr:PGDBString;
    action:tmyaction;
    debs:string;
begin
           while line<>'{' do
                             begin
                             line := f.readstring(#$A,#$D);
                             line:=readspace(line);
                             end;
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='ACTION' then
                     begin
                          line := f.readstring(#$A,#$D);
                          action:=tmyaction(self.StandartActions.ActionByName(line));
                          pm1:=TMenuItem.Create(pm);
                          pm1.Action:=action;
                          if pm is TMenuItem then
                                                 pm.Add(pm1)
                                             else
                                                 TMyPopUpMenu(pm).Items.Add(pm1);
                          line := f.readstring(#$A' ',#$D);
                          line:=readspace(line);
                     end
                else if uppercase(line)='COMMAND' then
                                                      begin
                                                           line2 := f.readstring(',','');
                                                           //GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
                                                           //pmenuitem.init(line);
                                                           //pmenuitem.addto(ppopupmenu);
                                                           line := f.readstring(',','');
                                                           //pmenuitem.command:=line;

                                                           line2:=InterfaceTranslate('menucommand~'+line,line2);
                                                           pmenuitem:=TmyMenuItem.Create(pm,line2,line);
                                                           {ppopupmenu}pm.Add(pmenuitem);
                                                           line := f.readstring(',','');
                                                           line := f.readstring(#$A' ',#$D);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line)='BUGFILES' then
                                                      begin
                                                           localpm.localpm:=pm;
                                                           localpm.ImageIndex:=II_Bug;
                                                           FromDirIterator(expandpath('*../errors/'),'*.dxf','',@bugfileiterator,nil);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                           localpm.localpm:=nil;
                                                           localpm.ImageIndex:=-1;
                                                      end
                else if uppercase(line)='SAMPLEFILES' then
                                                      begin
                                                           localpm.localpm:=pm;
                                                           localpm.ImageIndex:=II_Dxf;
                                                           FromDirIterator(expandpath('*/sample'),'*.dxf','',@bugfileiterator,nil);
                                                           FromDirIterator(expandpath('*/sample'),'*.dwg','',@bugfileiterator,nil);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                           localpm.localpm:=nil;
                                                           localpm.ImageIndex:=-1;
                                                      end
                else if uppercase(line)='FILEHISTORY' then
                                                      begin

                                                           for i:=low(FileHistory) to high(FileHistory) do
                                                           begin
                                                                pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
                                                                if assigned(pstr)then
                                                                                     line:=pstr^
                                                                                 else
                                                                                     line:='';
                                                                if line<>''then
                                                                                     //FileHistory[i]:=TmyMenuItem.Create(pm,line,'Load('+line+')')
                                                                                       begin
                                                                                       FileHistory[i].SetCommand(line,'Load',line);
                                                                                       FileHistory[i].visible:=true;
                                                                                       end
                                                                                 else
                                                                                     //FileHistory[i]:=TmyMenuItem.Create(line,rsEmpty,line);
                                                                                     begin
                                                                                     FileHistory[i].SetCommand(line,'',line);
                                                                                     FileHistory[i].visible:=false
                                                                                     end;
                                                                pm1:=TMenuItem.Create(pm);
                                                                pm1.Action:=FileHistory[i];
                                                                {ppopupmenu}pm.Add(pm1);
                                                           end;
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line)='DRAWINGS' then
                                                      begin
                                                           for i:=low(Drawings) to high(Drawings) do
                                                           begin
                                                                pm1:=TMenuItem.Create(pm);
                                                                pm1.Action:=Drawings[i];
                                                                pm.Add(pm1);
                                                           end;
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line)='LASTCOMMANDS' then
                                                      begin
                                                           for i:=low(CommandsHistory) to high(CommandsHistory) do
                                                           begin
                                                                pm1:=TMenuItem.Create(pm);
                                                                pm1.Action:=CommandsHistory[i];
                                                                if pm is TMenuItem then
                                                                                       pm.Add(pm1)
                                                                                   else
                                                                                       TMyPopUpMenu(pm).Items.Add(pm1);
                                                                //pm.Add(pm1);
                                                           end;
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line)='TOOLBARS' then
                                                      begin
                                                           for i:=0 to toolbars.Count-1 do
                                                           begin
                                                                debs:=toolbars.Strings[i];
                                                                debs:=copy(debs,1,pos(':',debs)-1);

                                                                action:=TmyAction.Create(self);
                                                                //if actionshortcut<>'' then
                                                                //                          action.ShortCut:=TextToShortCut(actionshortcut);
                                                                action.Name:='ACN_SHOW_'+uppercase(debs);
                                                                action.Caption:=debs;
                                                                action.command:='Show';
                                                                action.options:=debs;

                                                                //action.Hint:=actionhint;
                                                                action.DisableIfNoHandler:=false;
                                                                //SetImage(actionpic,actionname+'~textimage',action);
                                                                self.StandartActions.AddMyAction(action);
                                                                action.pfoundcommand:=commandmanager.FindCommand('SHOW');


                                                                pm1:=TMenuItem.Create(pm);
                                                                pm1.Action:=action;
                                                                pm.Add(pm1);

                                                           end;
                                                           {for i:=0 to 9 do
                                                           begin
                                                                pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
                                                                if assigned(pstr)then
                                                                                     line:=pstr^
                                                                                 else
                                                                                     line:='';
                                                                if line<>''then
                                                                                     FileHistory[i]:=TmyMenuItem.Create(pm,line,'Load('+line+')')
                                                                                 else
                                                                                     FileHistory[i]:=TmyMenuItem.Create(pm,S_Empty,'');
                                                                pm.Add(FileHistory[i]);
                                                           end;}
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else     if uppercase(line)='SEPARATOR' then
                                                      begin
                                                           if pm is TMenuItem then
                                                                                  pm.AddSeparator
                                                                              else
                                                                                  begin
                                                                                       pm1:=TMenuItem.Create(pm);
                                                                                       pm1.Caption:='-';
                                                                                       TMyPopUpMenu(pm).Items.Add(pm1);
                                                                                  end;
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line) = submenutoken then
                                                      begin

                                                           line := f.readstring(';','');
                                                           submenu:=TMenuItem.Create(pm);
                                                           line:=InterfaceTranslate('submenu~'+line,line);
                                                           submenu.Caption:=(line);
                                                           //{ppopupmenu}pm.{items.}Add(submenu);
                                                           if pm is TMenuItem then
                                                                                  pm.Add(submenu)
                                                                              else
                                                                                  TMyPopUpMenu(pm).Items.Add(submenu);
                                                           loadsubmenu(f,{ppopupmenu}submenu,line);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                end;
           end;
           //ppopupmenu.addto(pm);
end;
procedure MainForm.UpdateControls;
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
          TComboBox(updatescontrols[i]).Invalidate;
     end;
end;

procedure  MainForm.ChangedDWGTabCtrl(Sender: TObject);
var
   ogl:TOGlwnd;
begin
     OGL:=TOGLwnd(FindControlByType(TPageControl(sender).ActivePage,TOGLwnd));
     if assigned(OGL) then
                          OGL.GDBActivate;
     ReturnToDefaultProc;
end;

destructor MainForm.Destroy;
begin
    {if layerbox<>nil then
                         layerbox.Items.Clear;}
    if DockMaster<>nil then
    DockMaster.CloseAll;
    freeandnil(toolbars);
    freeandnil(updatesbytton);
    freeandnil(updatescontrols);
     inherited;
end;
function IsEditableShortCut(var Message: TLMKey):boolean;
var
   chrcode:word;
   ss:tshiftstate;
begin
     chrcode:=Message.CharCode;
     ss:=MsgKeyDataToShiftState(Message.KeyData);
     if ssShift in ss then
                               chrcode:=chrcode or scShift;
    if ssCtrl in ss then
                              chrcode:=chrcode or scCtrl;

     case chrcode of
               (scCtrl or VK_V),
               (scCtrl or VK_A),
               (scCtrl or VK_C),
               (scCtrl or VK_INSERT),
               (scShift or VK_INSERT),
               (scCtrl or VK_Z),
               (scCtrl or scShift or VK_Z),
                VK_DELETE,
                VK_HOME,VK_END,
                VK_PRIOR,VK_NEXT,//=PGUP,PGDN
                VK_BACK,
                VK_LEFT,
                VK_RIGHT,
                VK_UP,
                VK_DOWN
                    :begin
                         result:=true;
                     end
                else result:=false;

     end;

end;
procedure MainForm.ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
var
   //IsEditableFocus:boolean;
   //IsCommandNotEmpty:boolean;
   {_enabled,}_disabled:boolean;
   ctrl:TControl;
   ti:integer;
   POGLWndParam:POGLWndtype;
   PSimpleDrawing:PTSimpleDrawing;
   //i:integer;
//const
     //EditableShortCut=[(scCtrl or VK_Z),{(VK_CONTROL or VK_SHIFT or VK_Z),}VK_DELETE,VK_BACK,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN];
     //ClipboardShortCut=[VK_SHIFT or VK_DELETE,VK_BACK,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN];
begin
     if AAction is TmyAction then
     begin
     Handled:=true;


          if uppercase(TmyAction(AAction).command)='SHOWPAGE' then
          if uppercase(TmyAction(AAction).options)<>'' then
          begin
               if assigned(mainformn)then
               if assigned(mainformn.PageControl)then
               if mainformn.PageControl.ActivePageIndex=strtoint(TmyAction(AAction).options) then
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

(*
     IsEditableFocus:=(((ActiveControl is tedit)and(ActiveControl<>cmdedit))
                     or (ActiveControl is tmemo)
                     or (ActiveControl is tcombobox));
     if assigned(cmdedit) then
                              IsCommandNotEmpty:=((cmdedit.Text<>'')and(ActiveControl=cmdedit))
                          else
                              IsCommandNotEmpty:=false;
     {log.programlog.LogOutStr(AAction.Name,0);
     if AAction.Name='ACN_UNDO'then
     begin
          i:=TmyAction(AAction).ShortCut;
          i:=scCtrl or VK_Z;
     end;}
     if IsEditableShortCut(TmyAction(AAction).ShortCut)
     and ((IsEditableFocus)or(IsCommandNotEmpty))
          then _disabled:=true;
     //GetCommandContext;
     //i:=TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr;
*)

     PSimpleDrawing:=gdb.GetCurrentDWG;
     if PSimpleDrawing<>nil then
                                POGLWndParam:=@PSimpleDrawing.wa.param
                            else
                                POGLWndParam:=nil;
     if assigned(TmyAction(AAction).pfoundcommand) then
     begin
     if ((GetCommandContext(PSimpleDrawing,POGLWndParam) xor TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)and TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)<>0
          then
              _disabled:=true;


     TmyAction(AAction).Enabled:=not _disabled;
     end;

     end;
end;

function MainForm.IsShortcut(var Message: TLMKey): boolean;
var
   IsEditableFocus:boolean;
   IsCommandNotEmpty:boolean;
begin
     if message.charcode<>VK_SHIFT then
     if message.charcode<>VK_CONTROL then
                                      IsCommandNotEmpty:=IsCommandNotEmpty;
  IsEditableFocus:=(((ActiveControl is tedit)and(ActiveControl<>cmdedit))
                  or (ActiveControl is tmemo)
                  or (ActiveControl is tcombobox));
  if assigned(cmdedit) then
                           IsCommandNotEmpty:=((cmdedit.Text<>'')and(ActiveControl=cmdedit))
                       else
                           IsCommandNotEmpty:=false;
  if IsEditableShortCut(Message)
  and ((IsEditableFocus)or(IsCommandNotEmpty))
       then result:=false
       else result:=inherited IsShortcut(Message)
end;

procedure MainForm.myKeyPress{(var Key: char)}(Sender: TObject; var Key: Word; Shift: TShiftState);
//procedure MainForm.Pre_Char;
var
   //ccg:char;
   tempkey:word;
   comtext{,deb}:string;
   //ct:tclass;
begin
     if assigned(GetPeditorProc) then
     if GetPeditorProc<>nil then
     //if (ActiveControl)=GDBobjinsp.PEditor.Components[0] then
      begin
           if key=VK_ESCAPE then
                                begin
                                     if assigned(FreEditorProc) then
                                                                    FreEditorProc;
                                     key:=0;
                                     exit;
                                end;
      end;
     //deb:=ActiveControl.ClassName;
     //ct:=ActiveControl.ClassType;
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
                                                                 self.setnormalfocus(nil);
                                                                 end;
     tempkey:=key;

     comtext:='';
     if assigned(cmdedit) then
                              comtext:=cmdedit.text;
     if comtext='' then
     begin
     if assigned(gdb.GetCurrentDWG) then
     if assigned(gdb.GetCurrentDWG.wa.getviewcontrol)then
                    gdb.GetCurrentDWG.wa.myKeyPress(tempkey,shift);
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
                                              commandmanager.executecommandsilent('PrevDrawing',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                                              tempkey:=00;
                                         end;
                                 end
        else if (tempkey=VK_TAB)and(shift=[ssctrl]) then
                                 begin
                                      if assigned(PageControl)then
                                         if PageControl.PageCount>1 then
                                         begin
                                              commandmanager.executecommandsilent('NextDrawing',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
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
             {if (commandmanager.pcommandrunning=nil)and() then
             begin
                  ccg:=UPPERCASE(chr(key))[1];
                  key:=00;
                  case  ccg of
                              'C':commandmanager.executecommand('Copy');
                              'M':commandmanager.executecommand('Move');
                              'L':commandmanager.executecommand('Line');
                              else
                                  key:=ord(tempkey);
                  end;
             end}
         end;
     end;
     if tempkey=0 then
                      key:=0;
end;

procedure MainForm.CreateHTPB(tb:TToolBar);
begin
  ProcessBar:=TProgressBar.create(tb); //.initxywh('?', @Pdownpanel, 0,
    //0, 400, statusbarclientheight, false);
  ProcessBar.Hide;
  //ProcessBar.DoubleBuffered:=true;
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

{procedure MainForm.close;
begin
     destroywindow(self.handle);
     commandmanager.executecommand('Quit');
end;}
procedure MainForm.idle(Sender: TObject; var Done: Boolean);
var
   pdwg:PTSimpleDrawing;
   rc:TDrawContext;
begin
     done:=true;
     sysvar.debug.languadedeb.UpdatePO:=_UpdatePO;
     sysvar.debug.languadedeb.NotEnlishWord:=_NotEnlishWord;
     sysvar.debug.languadedeb.DebugWord:=_DebugWord;
     //exit;
     pdwg:=gdb.GetCurrentDWG;
     if pdwg<>nil then
     begin
     if pdwg.wa.getviewcontrol<>nil then
     begin
          {if pdwg.wa.Fastmmx>=0 then
          begin
               //pdwg.OGLwindow1._onMouseMove(nil,pdwg.OGLwindow1.Fastmmshift,pdwg.OGLwindow1.Fastmmx,pdwg.OGLwindow1.Fastmmy);
               //pdwg.OGLwindow1.Fastmmx:=-1;
          end
          else}
              if  pdwg.pcamera.DRAWNOTEND then
                                              begin
                                                   rc:=pdwg.wa.CreateRC;
                                              pdwg.wa.finishdraw(rc);
                                              done:=false;
                                              end;
     end
     end
     else
         SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     if pdwg<>nil then
     if not pdwg^.GetChangeStampt then
                                      SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     //SysVar.debug.memi2:=memman.i2;
     if (SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and(commandmanager.pcommandrunning=nil) then
     if (pdwg)<>nil then
     if (pdwg.wa.param.SelDesc.Selectedobjcount=0) then
     begin
          commandmanager.executecommandsilent('QSave(QS)',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
          SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     end;
     date:=sysutils.date;
  {if  (rt<>SysVar.SYS.SYS_RunTime^) and OGLwindow1.param.zoommode then
                        begin
                             OGLwindow1.param.zoommode:=false;
                             begin
                                  OGLwindow1.param.scrollmode:=false;
                                  gdb.GetCurrentDWG.ObjRoot.ObjArray.renderfeedbac;
                                  OGLwindow1.paint;
                             end;

                        end;}
     if rt<>SysVar.SYS.SYS_RunTime^ then
                                        begin
                                             if assigned(UpdateObjInspProc)then
                                                                               UpdateObjInspProc;
                                        end;
     rt:=SysVar.SYS.SYS_RunTime^;
     if historychanged then
                           begin
                                historychanged:=false;
                                HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
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
procedure MainForm.DropDownColor(Sender:Tobject);
begin
     OldColor:=tcombobox(Sender).ItemIndex;
     tcombobox(Sender).ItemIndex:=-1;
end;
procedure MainForm.DropUpLType(Sender:Tobject);
begin
     tcombobox(Sender).ItemIndex:=0;
end;

procedure MainForm.DropDownLType(Sender:Tobject);
var
   i:integer;
begin
     //Correct items count
     SetcomboItemsCount(tcombobox(Sender),gdb.GetCurrentDWG.LTypeStyleTable.Count+1);

     //Correct items
     for i:=0 to gdb.GetCurrentDWG.LTypeStyleTable.Count-1 do
     begin
          tcombobox(Sender).Items.Objects[i]:=tobject(gdb.GetCurrentDWG.LTypeStyleTable.getelement(i));
     end;
     tcombobox(Sender).Items.Objects[gdb.GetCurrentDWG.LTypeStyleTable.Count]:=LTEditor;
end;
procedure MainForm.DropUpColor(Sender:Tobject);
begin
     if tcombobox(Sender).ItemIndex=-1 then
                                           tcombobox(Sender).ItemIndex:=OldColor;
end;
procedure MainForm.ChangeLType(Sender:Tobject);
var
   LTIndex,index:Integer;
   CLTSave,plt:PGDBLtypeProp;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     plt:=PGDBLtypeProp(tcombobox(Sender).items.Objects[index]);
     LTIndex:=gdb.GetCurrentDWG.LTypeStyleTable.GetIndexByPointer(plt);
     if plt=nil then
                         exit;
     if plt=lteditor then
                         begin
                              commandmanager.ExecuteCommand('LineTypes',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                         end
     else
     begin
     if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
     end
     else
     begin
          CLTSave:=SysVar.dwg.DWG_CLType^;
          SysVar.dwg.DWG_CLType^:={LTIndex}plt;
          commandmanager.ExecuteCommand('SelObjChangeLTypeToCurrent',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CLType^:=CLTSave;
     end;
     end;
     setvisualprop;
     setnormalfocus(nil);
end;

procedure  MainForm.ChangeCColor(Sender:Tobject);
var
   ColorIndex,CColorSave,index:Integer;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     ColorIndex:=integer(tcombobox(Sender).items.Objects[index]);
     if ColorIndex=ClSelColor then
                           begin
                               if not assigned(ColorSelectWND)then
                               Application.CreateForm(TColorSelectWND, ColorSelectWND);
                               ShowAllCursors;
                               mr:=ColorSelectWND.run(SysVar.dwg.DWG_CColor^,true){showmodal};
                               if mr=mrOk then
                                              begin
                                              ColorIndex:=ColorSelectWND.ColorInfex;
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
                               RestoreCursors;
                               freeandnil(ColorSelectWND);
                           end;
     if colorindex<0 then
                         exit;
     if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CColor^:=ColorIndex;
     end
     else
     begin
          CColorSave:=SysVar.dwg.DWG_CColor^;
          SysVar.dwg.DWG_CColor^:=ColorIndex;
          commandmanager.ExecuteCommand('SelObjChangeColorToCurrent',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CColor^:=CColorSave;
     end;
     setvisualprop;
     setnormalfocus(nil);
end;

procedure  MainForm.ChangeCLineW(Sender:Tobject);
var tcl,index:GDBInteger;
begin
  index:=tcombobox(Sender).ItemIndex;
  index:=integer(tcombobox(Sender).items.Objects[index]);
  if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
  then
  begin
      SysVar.dwg.DWG_CLinew^:=index;
  end
  else
  begin
           begin
                tcl:=SysVar.dwg.DWG_CLinew^;
                SysVar.dwg.DWG_CLinew^:=index;
                commandmanager.ExecuteCommand('SelObjChangeLWToCurrent',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                SysVar.dwg.DWG_CLinew^:=tcl;
           end;
  end;
  setvisualprop;
  setnormalfocus(nil);
end;

{procedure MainForm.idle(Sender: TObject; var Done: Boolean);
begin

end;

procedure MainForm.ReloadLayer(plt: PGDBNamedObjectsArray);
begin

end;}

(*procedure MainForm.ChangeCLayer(Sender:Tobject);
var tcl:GDBInteger;
begin
  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
  then
  begin
  if layerbox.ItemIndex = layerbox.ItemsCount-1 then {layerbox.ItemIndex := getsortedindex(SysVar.dwg.DWG_CLayer^)}
                                                else
                                                     begin
                                                          SysVar.dwg.DWG_CLayer^:=gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(pointer(layerbox.Item{s.Objects}[layerbox.ItemIndex].PLayer));
                                                          if assigned(SetGDBObjInspProc)then
                                                          SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBLayerProp'),gdb.GetCurrentDWG.LayerTable.GetCurrentLayer);
                                                     end;
  end
  else
  begin
       if layerbox.ItemIndex = layerbox.ItemsCount-1
           then
           begin
                setvisualprop;
           end
           else
           begin
                tcl:=SysVar.dwg.DWG_CLayer^;
                SysVar.dwg.DWG_CLayer^:=gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(pointer(layerbox.Item{s.Objects}[layerbox.ItemIndex].PLayer));
                commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent');
                SysVar.dwg.DWG_CLayer^:=tcl;
                setvisualprop;
           end;
  end;
  setnormalfocus(nil);
end;*)
procedure MainForm.GeneralTick(Sender: TObject);//(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;
begin
     if sysvar.SYS.SYS_RunTime<>nil then
     begin
          inc(sysvar.SYS.SYS_RunTime^);
          if SysVar.SAVE.SAVE_Auto_On^ then
                                           dec(sysvar.SAVE.SAVE_Auto_Current_Interval^);
          //sendmessageA(mainwindow.MainForm.handle,wm_user,0,0);
     end;
end;
procedure MainForm.StartLongProcess(total:integer;processname:GDBString);
begin
     LPTime:=now;
     pname:=processname;
     if (assigned(ProcessBar)and assigned(HintText)) then
     begin
  ProcessBar.max:=total;
  ProcessBar.min:=0;
  ProcessBar.position:=0;
  HintText.Hide;
  //ProcessBar.BarShowText:=true;
  //ProcessBar.Caption:='qwerty';
  ProcessBar.Show;
  oldlongprocess:=0;
     end;
end;
procedure MainForm.ProcessLongProcess(current:integer);
var
    pos:integer;
begin
     if (assigned(ProcessBar)and assigned(HintText)) then
     begin
          pos:=round(clientwidth*(current/ProcessBar.max));
          if pos>oldlongprocess then
          begin
               ProcessBar.position:=current;
               oldlongprocess:=pos+20;
               ProcessBar.repaint;
               //application.ProcessMessages;
          end;
     end;
end;
{function MainForm.DOShowModal(MForm:TForm): Integer;
begin
     ShowAllCursors;
     result:=MForm.ShowModal;
     RestoreCursors;
end;}
function MainForm.MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
begin
     ShowAllCursors;
     result:=application.MessageBox(Text, Caption,Flags);
     RestoreCursors;
end;
procedure MainForm.ShowAllCursors;
begin
     if gdb.GetCurrentDWG<>nil then
     gdb.GetCurrentDWG.wa.showmousecursor;
end;

procedure MainForm.RestoreCursors;
begin
     if gdb.GetCurrentDWG<>nil then
     gdb.GetCurrentDWG.wa.hidemousecursor;
end;

procedure MainForm.Say(word:gdbstring);
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
          if assigned(HintText)then
          begin
          HintText.caption:=word;
          HintText.repaint;
          end;
          //application.ProcessMessages;
     end;
end;
procedure MainForm.EndLongProcess;
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
    //say(format(rscompiledtimemsg,[ts]));
    if pname='' then
                     shared.HistoryOutStr(format(rscompiledtimemsg,[ts]))
                 else
                     shared.HistoryOutStr(format(rsprocesstimemsg,[pname,ts]));
    pname:='';
end;
procedure MainForm.ReloadLayer(plt: PGDBNamedObjectsArray);
var
  //i: GDBInteger;
  ir:itrec;
  plp:PGDBLayerProp;
  s:ansistring{[ls]};
  //ss:ansistring;
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

procedure MainForm.MainMouseMove;
begin
     cxmenumgr.reset;
end;
function MainForm.MainMouseDown:GDBBoolean;
begin
     if (cxmenumgr.ismenupopup)or(ActivePopupMenu<>nil) then
                                                            result:=true
                                                        else
                                                            result:=false;
end;

procedure MainForm.ShowCXMenu;
var
  menu:TmyPopupMenu;
begin
  menu:=nil;
                                  if gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount>0 then
                                                                          menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'SELECTEDENTSCXMENU'))
                                                                      else
                                                                          menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'NONSELECTEDENTSCXMENU'));
                                  if menu<>nil then
                                  begin
                                       menu.PopUp;
                                  end;
end;
procedure MainForm.ShowFMenu;
var
  menu:TmyPopupMenu;
begin
    menu:=TmyPopupMenu(application.FindComponent(MenuNameModifier+'FASTMENU'));
    if menu<>nil then
    begin
         menu.PopUp;
    end;
end;


procedure MainForm._scroll(Sender: TObject; ScrollCode: TScrollCode;var ScrollPos: Integer);
var
   pdwg:PTSimpleDrawing;
   nevpos:gdbvertex;
begin
  pdwg:=gdb.GetCurrentDWG;
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
     pdwg.wa.draw;
  end;
end;

procedure MainForm.correctscrollbars;
var
   //poglwnd:toglwnd;
   //name:gdbstring;
   //i:Integer;
   pdwg:PTSimpleDrawing;
   BB:GDBBoundingBbox;
   size,min,max,position:integer;
begin
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  if pdwg.wa<>nil then begin
  bb:=pdwg.GetCurrentROOT.vp.BoundingBox;
  size:=round(pdwg.wa.getviewcontrol.ClientWidth*pdwg.GetPcamera^.prop.zoom);
  position:=round(-pdwg.GetPcamera^.prop.point.x);
  min:=round(bb.LBN.x+size/2);
  max:=round(bb.RTF.x+{$IFDEF LINUX}-{$ENDIF}size/2);
  if max<min then max:=min;
  MainFormN.HScrollBar.SetParams(position,min,max,size);

  size:=round(pdwg.wa.getviewcontrol.ClientHeight*pdwg.GetPcamera^.prop.zoom);
  min:=round(bb.LBN.y+size/2);
  max:=round(bb.RTF.y+{$IFDEF LINUX}-{$ENDIF}size/2);
  if max<min then max:=min;
  position:=round((bb.LBN.y+bb.RTF.y+pdwg.GetPcamera^.prop.point.y));
  MainFormN.VScrollBar.SetParams(position,min,max,size);
  end;
end;

function getoglwndparam: GDBPointer; export;
begin
  result := addr(gdb.GetCurrentDWG.wa.param);
end;
procedure updatevisible; export;
var
   //ir:itrec;
   poglwnd:toglwnd;
   name:gdbstring;
   i,k:Integer;
   pdwg:PTSimpleDrawing;
   //BB:GDBBoundingBbox;
   //size,min,max,position:integer;
begin

   pdwg:=gdb.GetCurrentDWG;
   if assigned(mainformn)then
   begin
   MainFormN.UpdateControls;
   MainFormN.correctscrollbars;
   k:=0;
  if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
  begin
  mainformn.setvisualprop;
  mainformn.Caption:='ZCad v'+sysvar.SYS.SYS_Version^+' - ['+gdb.GetCurrentDWG.GetFileName+']';

  if assigned(mainwindow.LayerBox) then
  mainwindow.LayerBox.enabled:=true;
  if assigned(mainwindow.LineWBox) then
  mainwindow.LineWBox.enabled:=true;
  if assigned(mainwindow.ColorBox) then
  mainwindow.ColorBox.enabled:=true;
  if assigned(mainwindow.LTypeBox) then
  mainwindow.LTypeBox.enabled:=true;
  if assigned(mainwindow.TStyleBox) then
  mainwindow.TStyleBox.enabled:=true;
  if assigned(mainwindow.DimStyleBox) then
  mainwindow.DimStyleBox.enabled:=true;


  if assigned(MainFormN.PageControl) then
  if assigned(SysVar.INTF.INTF_ShowDwgTabs) then
  if sysvar.INTF.INTF_ShowDwgTabs^ then
                                       MainFormN.PageControl.ShowTabs:=true
                                   else
                                       MainFormN.PageControl.ShowTabs:=false;
  if assigned(SysVar.INTF.INTF_DwgTabsPosition) then
  begin
       case SysVar.INTF.INTF_DwgTabsPosition^ of
                                                TATop:MainFormN.PageControl.TabPosition:=tpTop;
                                                TABottom:MainFormN.PageControl.TabPosition:=tpBottom;
                                                TALeft:MainFormN.PageControl.TabPosition:=tpLeft;
                                                TARight:MainFormN.PageControl.TabPosition:=tpRight;
       end;
  end;
  if assigned(MainFormN.PageControl) then
  if assigned(SysVar.INTF.INTF_ShowDwgTabCloseBurron) then
  begin
       if SysVar.INTF.INTF_ShowDwgTabCloseBurron^ then
                                                      MainFormN.PageControl.Options:=MainFormN.PageControl.Options+[nboShowCloseButtons]
                                                  else
                                                      MainFormN.PageControl.Options:=MainFormN.PageControl.Options-[nboShowCloseButtons];
  end;

  if assigned(MainFormN.HScrollBar) then
  begin
  MainFormN.HScrollBar.enabled:=true;
  MainFormN.correctscrollbars;
  if assigned(sysvar.INTF.INTF_ShowScrollBars) then
  if sysvar.INTF.INTF_ShowScrollBars^ then
                                       MainFormN.HScrollBar.Show
                                   else
                                       MainFormN.HScrollBar.Hide;
  end;

  if assigned(MainFormN.VScrollBar) then
  begin
  MainFormN.VScrollBar.enabled:=true;
  if assigned(sysvar.INTF.INTF_ShowScrollBars) then
  if sysvar.INTF.INTF_ShowScrollBars^ then
                                       MainFormN.VScrollBar.Show
                                   else
                                       MainFormN.VScrollBar.Hide;
  end;
  for i:=0 to MainFormN.PageControl.PageCount-1 do
    begin
         tobject(poglwnd):=FindControlByType(MainFormN.PageControl.Pages[i]{.PageControl},TOGLwnd);
           if assigned(poglwnd) then
            if poglwnd.wa.PDWG<>nil then
            begin
                name:=extractfilename(PTDrawing(poglwnd.wa.PDWG)^.FileName);
                if @PTDRAWING(poglwnd.wa.PDWG).mainObjRoot=(PTDRAWING(poglwnd.wa.PDWG).pObjRoot) then
                                                                     MainFormN.PageControl.Pages[i].caption:=(name)
                                                                 else
                                                                     MainFormN.PageControl.Pages[i].caption:='BEdit('+name+':'+PGDBObjBlockdef(PTDRAWING(poglwnd.wa.PDWG).pObjRoot).Name+')';

                if k<=high(MainFormN.Drawings) then
                begin
                MainFormN.Drawings[k].Caption:=MainFormN.PageControl.Pages[i].caption;
                MainFormN.Drawings[k].visible:=true;
                MainFormN.Drawings[k].command:='ShowPage';
                MainFormN.Drawings[k].options:=inttostr(i);
                inc(k);
                end;
                end;

            end;

    { i:=0;
    pcontrol:=MainForm.PageControl.pages.beginiterate(ir);
     if pcontrol<>nil then
     repeat
           if pcontrol^.pobj<>nil then
           begin
           poglwnd:=nil;
           //переделать//poglwnd:=pointer(pzbasic(pcontrol^.pobj)^.FindKidsByType(typeof(TOGLWnd)));
           if poglwnd<>nil then
            if poglwnd^.PDWG<>nil then
           begin
                name:=extractfilename(PTDrawing(poglwnd^.PDWG)^.FileName);
                if @PTDRAWING(poglwnd^.PDWG).mainObjRoot=(PTDRAWING(poglwnd^.PDWG).pObjRoot) then
                                                                     MainForm.PageControl.setpagetext(name,i)
                                                                 else
                                                                     MainForm.PageControl.setpagetext('BEdit('+name+':'+PGDBObjBlockdef(PTDRAWING(poglwnd^.PDWG).pObjRoot).Name+')',i);
           end;
           end;
           inc(i);
           pcontrol:=MainForm.PageControl.pages.iterate(ir);
     until pcontrol=nil;                  }
  for i:=k to high(MainFormN.Drawings) do
  begin
       MainFormN.Drawings[i].visible:=false;
  end;
  end
  else
      begin
           for i:=low(MainFormN.Drawings) to high(MainFormN.Drawings) do
             begin
                         MainFormN.Drawings[i].Caption:='';
                         MainFormN.Drawings[i].visible:=false;
                         MainFormN.Drawings[i].command:='';
             end;
           mainformn.Caption:=('ZCad v'+sysvar.SYS.SYS_Version^);
           if assigned(mainwindow.LayerBox)then
           mainwindow.LayerBox.enabled:=false;
           if assigned(mainwindow.LineWBox)then
           mainwindow.LineWBox.enabled:=false;
           if assigned(mainwindow.ColorBox) then
           mainwindow.ColorBox.enabled:=false;
           if assigned(mainwindow.TStyleBox) then
           mainwindow.TStyleBox.enabled:=false;
           if assigned(mainwindow.DimStyleBox) then
           mainwindow.DimStyleBox.enabled:=false;
           if assigned(mainwindow.LTypeBox) then
           mainwindow.LTypeBox.enabled:=false;
           if assigned(MainFormN.HScrollBar) then
           begin
           MainFormN.HScrollBar.enabled:=false;
           if assigned(sysvar.INTF.INTF_ShowScrollBars) then
           if sysvar.INTF.INTF_ShowScrollBars^ then

                                       MainFormN.HScrollBar.Show
                                   else
                                       MainFormN.HScrollBar.Hide;

           end;
           if assigned(MainFormN.VScrollBar) then
           begin
           MainFormN.VScrollBar.enabled:=false;
           if assigned(sysvar.INTF.INTF_ShowScrollBars) then
           if sysvar.INTF.INTF_ShowScrollBars^ then
                                       MainFormN.VScrollBar.Show
                                   else
                                       MainFormN.VScrollBar.Hide;
           end;
      end;
  end;
  end;
function DockingOptions_com(Operands:pansichar):GDBInteger;
begin
     ShowAnchorDockOptions(DockMaster);
end;
initialization
begin
  {$IFDEF DEBUGINITSECTION}LogOut('mainwindow.initialization');{$ENDIF}
  //DockMaster:= TAnchorDockMaster.Create(nil);
  CreateCommandFastObjectPlugin(pointer($100),'GetAV',0,0);
  CreateCommandFastObjectPlugin(@DockingOptions_com,'DockingOptions',0,0);
end
finalization
begin
end;
end.

