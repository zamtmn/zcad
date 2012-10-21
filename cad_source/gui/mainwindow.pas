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
  lineweightwnd,ugdbsimpledrawing,zcadsysvars,GDBBlockDef,layercombobox,ucxmenumgr,zcadstrconsts,math,LMessages,LCLIntf,
  ActnList,LCLType,LCLProc,strproc,log,intftranslations,toolwin,
  umytreenode,menus,Classes, SysUtils, FileUtil,{ LResources,} Forms, stdctrls, ExtCtrls, ComCtrls,Controls, {Graphics, Dialogs,}
  gdbasetypes,SysInfo, oglwindow, io,
  gdbase, languade,geometry,
  varmandef, varman, UUnitManager, GDBManager, {odbase, odbasedef, iodxf,} UGDBOpenArrayOfByte, plugins,
  {math, }UGDBDescriptor,cmdline,
  {gdbobjectsconstdef,}UGDBLayerArray,{deveditor,}
  {ZEditsWithProcedure,}{zforms,}{ZButtonsWithCommand,}{ZComboBoxsWithProc,}{ZButtonsWithVariable,}{zmenus,}
  {GDBCommandsBase,}{ GDBCommandsDraw,GDBCommandsElectrical,}
  commanddefinternal,commandline,{zmainforms,}memman,UGDBNamedObjectsArray,
  {ZGUIArrays,}{ZBasicVisible,}{ZEditsWithVariable,}{ZTabControlsGeneric,}shared,{ZPanelsWithSplit,}{ZGUIsCT,}{ZstaticsText,}{UZProcessBar,}strmy{,strutils},{ZPanelsGeneric,}
  graphics,
  AnchorDocking,AnchorDockOptionsDlg,ButtonPanel,AnchorDockStr{,xmlconf},zcadinterface,colorwnd;
type
  TInterfaceVars=record
                       CColor,CLWeight:GDBInteger;
                       CLayer:PGDBLayerProp;
                 end;

  TmyAnchorDockHeader = class(TAnchorDockHeader)
                        protected
                                 procedure Paint; override;
                        end;
  TmyAnchorDockSplitter = class(TAnchorDockSplitter)
  public
    constructor Create(TheOwner: TComponent); override;

                          end;

  TFileHistory=Array [0..9] of {TmyMenuItem}TmyAction;

  { MainForm }

  MainForm = class(TFreedForm)
                    ToolBarU{,ToolBarR}:TToolBar;
                    //ToolBarD: TToolBar;
                    //ObjInsp,
                    MainPanel:{TForm}TPanel;
                    FToolBar{,MainPanelU}:TToolButtonForm;
                    //MainPanelD:TCLine;
                    //SplitterV,SplitterH: TSplitter;

                    PageControl:TmyPageControl;

                    //MainMenu:TMenu;
                    StandartActions:TmyActionList;

                    SystemTimer: TTimer;

                    toolbars:tstringlist;
                    IconList: TImageList;

                    updatesbytton,updatescontrols:tlist;

                    {procedure LayerBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                               State: TOwnerDrawState);}
                    procedure LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                               State: TOwnerDrawState);
                    procedure ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                                   State: TOwnerDrawState);
                    function findtoolbatdesk(tbn:string):string;
                    procedure CreateToolbarFromDesk(tb:TToolBar;tbname,tbdesk:string);
                    procedure CreateHTPB(tb:TToolBar);

                    procedure FormCreate(Sender: TObject);
                    procedure ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
                    procedure AfterConstruction; override;
                    destructor Destroy;override;
                    procedure setnormalfocus(Sender: TObject);

                    procedure draw;

                    procedure loadpanels(pf:GDBString);
                    procedure CreateLayoutbox(tb:TToolBar);
                    procedure loadmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
                    procedure loadpopupmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
                    procedure createmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
                    procedure setmainmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
                    procedure loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);

                    procedure ChangedDWGTabCtrl(Sender: TObject);
                    procedure UpdateControls;

                    procedure StartLongProcess(total:integer);
                    procedure ProcessLongProcess(current:integer);
                    procedure EndLongProcess;
                    procedure Say(word:gdbstring);

                    procedure SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean;identifer:string);

                    function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
                    procedure ShowAllCursors;
                    procedure RestoreCursors;
                    //function DOShowModal(MForm:TForm): Integer;
                    procedure CloseDWGPageInterf(Sender: TObject);
                    function CloseDWGPage(Sender: TObject):integer;

                    procedure PageControlMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);


                    private
                    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
                    public
                    rt:GDBInteger;
                    FileHistory:TFileHistory;
                    //hToolTip: HWND;

                    //procedure KeyPress(var Key: char);override;
                    procedure CreateAnchorDockingInterface;
                    procedure CreateStandartInterface;
                    procedure CreateInterfaceLists;
                    procedure InitSystemCalls;
                    procedure LoadActions;
                    procedure LoadIcons;
                    procedure myKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);

                    //procedure ChangeCLayer(Sender:Tobject);
                    procedure ChangeCLineW(Sender:Tobject);
                    procedure ChangeCColor(Sender:Tobject);
                    procedure DropDownColor(Sender:Tobject);
                     procedure DropUpColor(Sender:Tobject);

                    procedure ChangeLayout(Sender:Tobject);

                    procedure idle(Sender: TObject; var Done: Boolean);virtual;
                    procedure ReloadLayer(plt:PGDBNamedObjectsArray);

                    procedure GeneralTick(Sender: TObject);//(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;

                    procedure asynccloseapp(Data: PtrInt);

                    procedure processfilehistory(filename:GDBString);

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

               end;
  TMyAnchorDockManager = class(TAnchorDockManager)
  public
    procedure ResetBounds(Force: Boolean); override;
  end;
procedure UpdateVisible;
function getoglwndparam: GDBPointer; export;
function LoadLayout_com(Operands:pansichar):GDBInteger;
function _CloseDWGPage(ClosedDWG:PTDrawing;lincedcontrol:TObject):Integer;
{procedure startup;
procedure finalize;}
var
  IVars:TInterfaceVars;
  MainFormN: MainForm;
  //MainForm: MainForm;
  uGeneralTimer:cardinal;
  GeneralTime:GDBInteger;
  LayerBox:{TComboBox}TZCADLayerComboBox;
  LineWBox,ColorBox:TComboBox;
  LayoutBox:TComboBox;
  LPTime:Tdatetime;
  oldlongprocess:integer;
  tf:tform;
  OLDColor:integer;
  //DockMaster:  TAnchorDockMaster = nil;

  //imagesindex
  II_Plus,
  II_Minus,
  II_Ok,
  II_LayerOff,
  II_LayerOn,
  II_LayerUnPrint,
  II_LayerPrint,
  II_LayerUnLock,
  II_LayerLock,
  II_LayerFreze,
  II_LayerUnFreze
  :integer;

  function CloseApp:GDBInteger;
  function IsRealyQuit:GDBBoolean;

implementation

uses {GDBCommandsBase,}{Objinsp}{,optionswnd, Tedit_form, MTedit_form}
  GDBEntity,UGDBSelectedObjArray,dialogs,XMLPropStorage{,layerwnd};
procedure TMyAnchorDockManager.ResetBounds(Force: Boolean);
begin
     inherited;
     //OldSiteClientRect:=FSiteClientRect;
     //FSiteClientRect:=Site.ClientRect;
     //site:=site;
     //Site.ClientRect:=FSiteClientRect;
end;
constructor TmyAnchorDockSplitter.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  self.MinSize:=1;
end;

procedure TmyAnchorDockHeader.Paint;

  {procedure DrawGrabber(r: TRect);
  begin
    Canvas.Frame3d(r,2,bvLowered);
    Canvas.Frame3d(r,4,bvRaised);
  end;}
  procedure DrawGrabber(r: TRect);
   var
     dx : integer = 0;
     dy : integer = 0;
   begin
     InflateRect(r,-2,-2);
     if Align in [alLeft,alRight] then begin // Vertical
       dx := 3;
       r.Right := r.Left + (r.Right - r.Left) div 3 ;
       r.Left := r.Right - dx;
     end else begin
       dy := 3;
       r.Bottom := r.top + (r.bottom - r.Top) div 3;
       r.top := r.bottom - dy;
     end;

     DrawEdge(Canvas.Handle,r, BDR_RAISEDINNER, BF_RECT );
     OffsetRect(r,dx,dy);
     DrawEdge(Canvas.Handle,r, BDR_RAISEDINNER, BF_RECT );
     OffsetRect(r,dx,dy);
     DrawEdge(Canvas.Handle,r, BDR_RAISEDINNER, BF_RECT );
   end;

var
  r,r1: TRect;
  TxtH: longint;
  TxtW: longint;
  dx,dy: Integer;
  ts:TTextStyle;
begin
  //exit;
  r:=ClientRect;
  Canvas.Frame3d(r,1,bvRaised);
  canvas.Brush.Color := clBtnFace;
  Canvas.FillRect(r);
  if CloseButton.IsControlVisible and (CloseButton.Parent=Self) then begin
    if Align in [alLeft,alRight] then
      r.Top:=CloseButton.Top+CloseButton.Height+1
    else
      r.Right:=CloseButton.Left-1;
  end;

  // caption
  if Caption<>'' then begin
    Canvas.Brush.Color:=clNone;
    Canvas.Brush.Style:=bsClear;
    Canvas.Font.Orientation:=0;
    TxtH:=Canvas.TextHeight('ABCMgq');
    TxtW:=Canvas.TextWidth(Caption);
    if Align in [alLeft,alRight] then begin
      // vertical
      dx:=Max(0,(r.Right-r.Left-Txth) div 2);
      dy:=Max(0,(r.Bottom-r.Top-Txtw) div 2);
      Canvas.Font.Orientation:=900;
      if TxtW<(r.Bottom-r.Top)then
        begin
      Canvas.TextOut(r.Left+dx-1,r.Bottom-dy-2,Caption);
      //Canvas.Font.Orientation:=-500;
      //ts:=Canvas.TextStyle;
      //ts.Alignment:=taCenter;//taRightJustify;
      //Canvas.TextStyle:=ts;
      //Canvas.TextRect(r,r.Left+dx,r.Bottom-dy,Caption);
      DrawGrabber(Rect(r.Left,r.Top,r.Right,r.Bottom-dy-TxtW-1));
      DrawGrabber(Rect(r.Left,r.Bottom-dy+1,r.Right,r.Bottom));
        end
           else DrawGrabber(r);
    end else begin
      // horizontal
      dx:=Max(0,(r.Right-r.Left-TxtW) div 2);
      dy:=Max(0,(r.Bottom-r.Top-TxtH) div 2);
      Canvas.Font.Orientation:=0;
      //Canvas.TextOut(r.Left+dx,r.Top+dy,Caption);
      if TxtW<(r.right-r.Left)then
        begin
      Canvas.TextRect(r,dx+2,dy,Caption);
      DrawGrabber(Rect(r.Left,r.Top,r.Left+dx-1,r.Bottom));
      DrawGrabber(Rect(r.Left+dx+TxtW+2,r.Top,r.Right,r.Bottom));
        end
        else DrawGrabber(r);
    end;
  end else
    DrawGrabber(r);
end;
procedure setlayerstate(PLayer:PGDBLayerProp;var lp:TLayerPropRecord);
begin
     lp.OnOff:=player^._on;
     lp.Freze:=false;
     lp.Lock:=player^._lock;
     lp.Name:=player.Name;
     lp.PLayer:=player;;
end;
procedure MainForm.setvisualprop;
const pusto=-1000;
      lpusto=pointer(0);
      different=-10001;
      ldifferent=pointer(1);
var lw:GDBInteger;
    color:GDBInteger;
    layer:pgdblayerprop;
    //i,se:GDBInteger;
    pv:{pgdbobjEntity}PSelectedObjDesc;
        ir:itrec;
begin

  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
  then
      begin
           if assigned(LinewBox) then
           if sysvar.dwg.DWG_CLinew^<0 then LineWbox.ItemIndex:=(sysvar.dwg.DWG_CLinew^+3)
                                       else LinewBox.ItemIndex:=((sysvar.dwg.DWG_CLinew^ div 10)+3);
           {if assigned(LayerBox) then
           LayerBox.ItemIndex:=getsortedindex(SysVar.dwg.DWG_CLayer^);}
           IVars.CColor:=sysvar.dwg.DWG_CColor^;
           IVars.CLWeight:=sysvar.dwg.DWG_CLinew^+3;
           ivars.CLayer:=gdb.GetCurrentDWG.LayerTable.getelement(sysvar.dwg.DWG_CLayer^);
      end
  else
      begin
           //se:=param.seldesc.Selectedobjcount;
           lw:=pusto;
           layer:=lpusto;
           color:=pusto;
           pv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
           //pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
           if pv<>nil then
           repeat
           if pv^.objaddr<>nil then
           begin
                //if pv^.Selected
                //then
                    begin
                         if lw=pusto then lw:=pv^.objaddr^.vp.LineWeight
                                      else if lw<> pv^.objaddr^.vp.LineWeight then lw:=different;
                         if layer=lpusto then layer:=pv^.objaddr^.vp.layer
                                      else if layer<> pv^.objaddr^.vp.layer then layer:=ldifferent;
                         if color=pusto then color:=pv^.objaddr^.vp.color
                                        else if color<> pv^.objaddr^.vp.color then color:=different;
                    end;
                if (layer=ldifferent)and(lw=different)and(color=different) then system.Break;
           end;
           pv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
           until pv=nil;
           if lw<>pusto then
           if lw=different then
                               ivars.CLWeight:=ColorBoxDifferent
                           else
                               begin
                                    ivars.CLWeight:=lw+3
                               end;
           if layer<>lpusto then
           if layer=ldifferent then
                                  ivars.CLayer:=nil
                               else
                               begin
                                    ivars.CLayer:=layer;
                               end;
           if color<>pusto then
           if color=different then
                                  ivars.CColor:=ColorBoxDifferent
                           else
                               begin
                                    ivars.CColor:=color;
                               end;

      end;
      UpdateControls;
end;
procedure MainForm.addoneobject;
//const //pusto=-1000;
      //different=-10001;
var lw,layer:GDBInteger;
begin

  lw:=PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.LineWeight;
  layer:=gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.layer);
  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=1
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
           ivars.CColor:=PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.color;
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

           if ivars.CColor<>PGDBObjEntity(gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject)^.vp.color then
              ivars.CColor:=ColorBoxDifferent;
      end;
end;

function MainForm.ClickOnLayerProp(PLayer:Pointer;NumProp:integer;var newlp:TLayerPropRecord):boolean;
var
   cdwg:PTSimpleDrawing;
   tcl:integer;
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
                                if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0 then
                                begin
                                          if assigned(sysvar.dwg.DWG_CLayer) then
                                            sysvar.dwg.DWG_CLayer^:=cdwg^.LayerTable.GetIndexByPointer(Player);
                                          if not PGDBLayerProp(PLayer)^._on then
                                                                            MessageBox(@rsCurrentLayerOff[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
                                          setvisualprop;
                                end
                                else
                                begin
                                       tcl:=SysVar.dwg.DWG_CLayer^;
                                       SysVar.dwg.DWG_CLayer^:=cdwg^.LayerTable.GetIndexByPointer(Player);
                                       commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent');
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
         if assigned(cdwg^.OGLwindow1) then
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
   pcl:PGDBLayerProp;
begin
     if player=nil then
                       begin
                            result:=false;
                            cdwg:=gdb.GetCurrentDWG;
                            if cdwg<>nil then
                            begin
                                 if assigned(cdwg^.OGLwindow1) then
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

procedure MainForm.processfilehistory(filename:GDBString);
var i,j,k:integer;
    pstr,pstrnext:PGDBString;
    //pvarfirst:pvardesk;
begin
     k:=8;
     for i:=0 to 9 do
     begin
          if assigned(FileHistory[i]) then
          if FileHistory[i].Caption=filename then
          begin
               k:=i-1;
               system.break;
          end;
     end;
     if k<0 then exit;
      for i:=k downto 0 do
      begin
           j:=i+1;
           pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
           pstrnext:=SavedUnit.FindValue('PATH_File'+inttostr(j));
           if (assigned(pstr))and(assigned(pstrnext))then
                                                         pstrnext^:=pstr^;
           if (assigned(FileHistory[j]))and(assigned(FileHistory[i]))then
           FileHistory[j].SetCommand(FileHistory[i].caption,FileHistory[i].{F}Command,FileHistory[i].options);
      end;
      pstr:=SavedUnit.FindValue('PATH_File0');
      if (assigned(pstr))then
                              pstr^:=filename;
      if assigned(FileHistory[0]) then
      if FileName<>''then
                           FileHistory[0].SetCommand(FileName,'Load',FileName)
                       else
                           FileHistory[0].SetCommand(rsEmpty,'','');
      for i:=0 to 9 do
      begin
           if assigned(FileHistory[i]) then
           if FileHistory[i].command='' then
                                            FileHistory[i].visible:=false
                                        else
                                            FileHistory[i].visible:=true;
      end;
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
                                        if poglwnd.PDWG.GetChangeStampt then
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
                                    pint^:=CLine.DMenu.Left;
               pint:=SavedUnit.FindValue('DMenuY');
               if assigned(pint)then
                                    pint^:=CLine.DMenu.Top;

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
var
   pint:PGDBInteger;
   mem:GDBOpenArrayOfByte;
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
                    if MainFormN.CloseDWGPage(MainFormN.PageControl.ActivePage)=IDNO then
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
   i:integer;
   s:string;
begin
  if ClosedDWG<>nil then
  begin
       result:=IDYES;
       if ClosedDWG.Changed then
                                 begin
                                      s:=format(rsCloseDWGQuery,[ClosedDWG.FileName]);
                                      result:=MainFormN.MessageBox(@s[1],@rsWarningCaption[1],MB_YESNO);
                                      if result<>IDYES then exit;
                                 end;
       commandmanager.executecommandtotalend;
       poglwnd:=ClosedDWG.OGLwindow1;
       gdb.eraseobj(ClosedDWG);
       gdb.pack;
       poglwnd.PDWG:=nil;

       poglwnd.{GDBActivateGLContext}MakeCurrent;
       poglwnd.free;

       lincedcontrol.Free;
       tobject(poglwnd):=mainformn.PageControl.ActivePage;

       if poglwnd<>nil then
       begin
            tobject(poglwnd):=FindControlByType(poglwnd,TOGLWnd);
            gdb.CurrentDWG:=PTDrawing(poglwnd.PDWG);
            poglwnd.GDBActivate;
       end;
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
   i:integer;
begin
  //application.ProcessMessages;
  Closeddwg:=nil;
  TControl(poglwnd):=FindControlByType(TTabSheet(sender),TOGLWnd);
  if poglwnd<>nil then
                      Closeddwg:=ptdrawing(poglwnd.PDWG);
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
procedure MainForm.DockMasterCreateControl(Sender: TObject; aName: string; var
  AControl: TControl; DoDisableAutoSizing: boolean);
var
  i:integer;
  pint:PGDBInteger;
  TB:TToolBar;
  tbdesk:string;
  ta:TmyAction;
  TempForm:TForm;
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

                 ta:=tmyaction(self.StandartActions.ActionByName('ACN_Show_'+aname));
               if ta<>nil then
                              ta.Checked:=true;

  // if the form does not yet exist, create it
  if aName='PageControl' then
  begin
       MainPanel:={Tform}Tpanel(Tform.NewInstance);
       //MainPanel.FormStyle:=fsStayOnTop;
       MainPanel.DisableAlign;
       MainPanel.Create(Application);
       MainPanel.SetBounds(200,200,600,500);
   //MainPanel:={TPanel}Tform.create(application);
   MainPanel.Caption:=rsDrawingWindowWndName;
   MainPanel.BorderWidth:=0;
   //MainPanel.Parent:=self;
   //mainpanel.show;
  PageControl:=TmyPageControl.Create(MainPanel{Application});
      PageControl.Constraints.MinHeight:=32;
      PageControl.Parent:=MainPanel;
      PageControl.Align:=alClient;
      PageControl.{OnPageChanged}OnChange:=ChangedDWGTabCtrl;
      PageControl.BorderWidth:=0;
      PageControl.Options:=[nboShowCloseButtons];
      PageControl.OnCloseTabClicked:=CloseDWGPageInterf;
      PageControl.OnMouseDown:=PageControlMouseDown;

   AControl:=MainPanel;
   AControl.Name:=aname;
   //Acontrol.Caption:=caption;
               if not DoDisableAutoSizing then
                                            Acontrol.EnableAutoSizing;
  end
  else if aName='CommandLine' then
  begin
        CLine:=TCLine(TCLine.NewInstance);
        CLine.FormStyle:=fsStayOnTop;
        CLine.DisableAlign;
        CLine.Create(Application);
        CLine.SetBounds(200,100,600,100);
        //CLine.Caption:=Title;
       //CLine:=TCLine.create({MainPanel}application);
       //CLine.Parent:=MainPanel;
       CLine.Caption:=rsCommandLineWndName;
       CLine.Align:=alBottom;
       pint:=SavedUnit.FindValue('VIEW_CommandLineH');
       {if assigned(pint)then
                            Cline.Height:=pint^;}
       AControl:=CLine;

       AControl.Name:=aname;
       //Acontrol.Caption:=caption;
                   if not DoDisableAutoSizing then
                                                Acontrol.EnableAutoSizing;

  end
  else if aName='ObjectInspector' then
            begin
               if assigned(CreateObjInspInstanceProc)then
               begin
               TempForm:=CreateObjInspInstanceProc;
               TempForm.DisableAlign;
               TempForm.Create(Application);
               TempForm.Caption:=rsGDBObjInspWndName;
               TempForm.SetBounds(0,100,200,600);

               //if assigned(ACN_Show_ObjectInspector) then
               //                                 ACN_ShowObjInsp.Checked:=true;


               //TempForm.FormStyle:=fsStayOnTop;
               //TempForm.Caption:=Title;
               //TempForm:=TGDBObjInsp.create({self}application);
               //TempForm.BorderStyle:=bsSingle;

               //TempForm.Align:=alLeft;
               //TempForm.BorderStyle:=bssizetoolwin;
               if assigned(SetGDBObjInspProc)then
               SetGDBObjInspProc(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
               if assigned(SetCurrentObjDefaultProc)then
                                                        SetCurrentObjDefaultProc;
               //{TempForm.}ReturnToDefault;

               pint:=SavedUnit.FindValue('VIEW_ObjInspV');
               {if assigned(pint)then
                                    TempForm.Width:=pint^;}
               if assigned(SetNameColWidthProc)then
               //TempForm.namecol:=TempForm.Width div 2;
                                                  SetNameColWidthProc(TempForm.Width div 2);
               pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
               if assigned(pint)then
                                    if assigned(SetNameColWidthProc)then
                                    SetNameColWidthProc(pint^);//TempForm.namecol:=pint^;

               //TempForm.Parent:=self;
               //  TempForm.show;
               AControl:=TempForm;

               AControl.Name:=aname;
               //Acontrol.Caption:=caption;

                   if not DoDisableAutoSizing then
                                                Acontrol.EnableAutoSizing;
               end;
               //Acontrol.BoundsRect:=NewBounds;
          end
  else //if copy(aName,1,7)='ToolBar' then
  begin
       tbdesk:=self.findtoolbatdesk(aName);
       if tbdesk=''then
                       shared.ShowError(format(rsToolBarNotFound,[aName]));
       FToolBar:=TToolButtonForm(TToolButtonForm.NewInstance);
       //FToolBar.FormStyle:=fsStayOnTop;
       FToolBar.DisableAlign;
       FToolBar.Create(Application);
       //FToolBar.Caption:=aName;
       FToolBar.Caption:='';
       //FToolBar.BevelInner:=bvnone;
       FToolBar.SetBounds(100,64,500,26);
       //FToolBar.AutoSize:=false;

       TB:=TToolBar.Create(application);
       TB.Align:={alRight}alclient;
       //TB.AutoSize:=false;
       //TB.Width:=ToolBarU.Height;
       if aName<>'Status' then
       TB.EdgeBorders:=[];
       TB.ShowCaptions:=true;
       //TB.Wrapable:=true;
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

       AControl:=FToolBar;

       AControl.Name:=aname;
       FToolBar.Caption:='';
       //Acontrol.Caption:=caption;
           if not DoDisableAutoSizing then
                                        Acontrol.EnableAutoSizing;

  end;
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
function loadicon(iconlist: TImageList;f:string):integer;
var
  bmp:TPortableNetworkGraphic;
begin
  bmp:=TPortableNetworkGraphic.create;
  bmp.LoadFromFile(f);
  bmp.Transparent:=true;
  result:=iconlist.Add(bmp,nil);
  freeandnil(bmp);
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
end;

procedure MainForm.LoadActions;
var
   i:integer;
begin
  StandartActions:=TmyActionList.Create(self);
  if not assigned(StandartActions.Images) then
                             StandartActions.Images:=TImageList.Create(
                               StandartActions);
  StandartActions.brocenicon:=StandartActions.LoadImage(sysparam.programpath+
  'menu/BMP/noimage.bmp');
  StandartActions.LoadFromACNFile(sysparam.programpath+'menu/actions.acn');
  StandartActions.LoadFromACNFile(sysparam.programpath+'menu/electrotech.acn');
  StandartActions.OnUpdate:=ActionUpdate;

  for i:=0 to 9 do
  begin
       FileHistory[i]:=TmyAction.Create(self);
  end;
end;

procedure MainForm.LoadIcons;
begin
  iconlist:=timagelist.Create(self);

  II_Plus:=loadicon(iconlist, sysparam.programpath+'images/plus.png');
  II_Minus:=loadicon(iconlist, sysparam.programpath+'images/minus.png');
  II_Ok:=loadicon(iconlist, sysparam.programpath+'images/ok.png');
  II_LayerOff:=loadicon(iconlist, sysparam.programpath+'images/off.png');
  II_LayerOn:=loadicon(iconlist, sysparam.programpath+'images/on.png');
  II_LayerUnPrint:=loadicon(iconlist, sysparam.programpath+'images/unprint.png');
  II_LayerPrint:=loadicon(iconlist, sysparam.programpath+'images/print.png');
  II_LayerUnLock:=loadicon(iconlist, sysparam.programpath+'images/unlock.png');
  II_LayerLock:=loadicon(iconlist, sysparam.programpath+'images/lock.png');
  II_LayerFreze:=loadicon(iconlist, sysparam.programpath+'images/freze.png');
  II_LayerUnFreze:=loadicon(iconlist, sysparam.programpath+'images/unfreze.png');
end;

procedure MainForm.CreateInterfaceLists;
begin
  updatesbytton:=tlist.Create;
  updatescontrols:=tlist.Create;
end;

procedure MainForm.CreateAnchorDockingInterface;
var
  action: tmyaction;
begin
  self.SetBounds(0, 0, 800, 44);
  DockMaster.HeaderClass:=TmyAnchorDockHeader;
  DockMaster.SplitterClass:=TmyAnchorDockSplitter;
  DockMaster.ManagerClass:=TMyAnchorDockManager;
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
  action: tmyaction;
  TempForm:TForm;
  pint:PGDBInteger;
begin
  self.SetBounds(10,10,800,500);

  ToolBarU:=TToolBar.Create(self);
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
                          end;


  TempForm:=CreateObjInspInstanceProc;
  TempForm.Create(Application);
                 TempForm.Caption:=rsGDBObjInspWndName;
                 TempForm.Parent:=self;
                 TempForm.Align:=alLeft;
                 TempForm.Show;
                 if assigned(SetGDBObjInspProc)then
                 SetGDBObjInspProc(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
                 if assigned(SetCurrentObjDefaultProc)then
                                                          SetCurrentObjDefaultProc;
                 {pint:=SavedUnit.FindValue('VIEW_ObjInspV');
                 if assigned(SetNameColWidthProc)then
                                                    SetNameColWidthProc(TempForm.Width div 2);
                 pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
                 if assigned(pint)then
                                      if assigned(SetNameColWidthProc)then
                                      SetNameColWidthProc(pint^);//TempForm.namecol:=pint^;}



  MainPanel:=Tpanel.Create(Application);
  MainPanel.parent:=self;
  MainPanel.Align:=alClient;
  MainPanel.Caption:=rsDrawingWindowWndName;
  MainPanel.BorderWidth:=0;

  PageControl:=TmyPageControl.Create(MainPanel);
  PageControl.Constraints.MinHeight:=32;
  PageControl.Parent:=MainPanel;
  PageControl.Align:=alClient;
  PageControl.OnChange:=ChangedDWGTabCtrl;
  PageControl.BorderWidth:=0;
  PageControl.Options:=[nboShowCloseButtons];
  PageControl.OnCloseTabClicked:=CloseDWGPageInterf;
  PageControl.OnMouseDown:=PageControlMouseDown;
end;


procedure MainForm.FormCreate(Sender: TObject);
var
  i:integer;
  pint:PGDBInteger;
  bmp:TPortableNetworkGraphic;
begin
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

procedure MainForm.LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
   plp:PGDBLayerProp;
   Dest: PChar;
   y,pw,ll:integer;
begin
  //y:=(ARect.Top+ARect.Bottom)div 2;
  //TComboBox(Control).canvas.Rectangle(ARect.Left,y,ARect.Left+10,y+10);
  //TComboBox(Control).canvas.Line(ARect.Left,y,ARect.Left+ll,y);
    if gdb.GetCurrentDWG=nil then
                                 exit;
    TComboBox(Control).canvas.FillRect(ARect);
    if {(odComboBoxEdit in State)}not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CLWeight;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
   s:=GetLWNameFromLW(index-3);
   if (index<4)or(index=ColorBoxDifferent) then
              ll:=0
          else
              ll:=30;
    ARect.Left:=ARect.Left+2;
    drawLW(TComboBox(Control).canvas,ARect,ll,(index-3) div 10,s);
end;
procedure MainForm.ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
   plp:PGDBLayerProp;
   Dest: PChar;
   y:integer;
   textrect:TRect;
const
     cellsize=13;
     textoffset=cellsize+5;
begin
    if (gdb.GetCurrentDWG=nil)or(sysvar.DWG.DWG_CColor=nil) then
     exit;
    begin
    TComboBox(Control).canvas.FillRect(ARect);
    if {(odComboBoxEdit in State)}not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CColor;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
    s:=GetColorNameFromIndex(index);
    {case index of
                 0:
                   s:=rsByBlock;
               256:
                   s:=rsByLayer;
            1..255:
                   s:=palette[index].name;
  ColorBoxSelColor:
                   s:=rsSelectColor;
 ColorBoxDifferent:
                   s:=rsDifferent;
    end;}
    ARect.Left:=ARect.Left+2;
    textrect:=ARect;
    if index<ColorBoxSelColor then
     begin
          textrect.Left:=textrect.Left+textoffset;
          DrawText(TComboBox(Control).canvas.Handle,@s[1],length(s),textrect,DT_LEFT or DT_VCENTER);

          if index in [1..255] then
                         begin
                              TComboBox(Control).canvas.Brush.Color:=RGBToColor(palette[index].r,palette[index].g,palette[index].b);
                         end
                     else
                         TComboBox(Control).canvas.Brush.Color:=clWhite;
          y:=(ARect.Top+ARect.Bottom-cellsize)div 2;
          TComboBox(Control).canvas.Rectangle(ARect.Left,y,ARect.Left+cellsize,y+cellsize);
          if index=7 then
                         begin
                              TComboBox(Control).canvas.Brush.Color:=clBlack;
                              TComboBox(Control).canvas.Polygon([point(ARect.Left,y),point(ARect.Left+cellsize-1,y),point(ARect.Left+cellsize-1,y+cellsize-1)]);
                          end
     end
    else
    DrawText(TComboBox(Control).canvas.Handle,@s[1],length(s),arect,DT_LEFT or DT_VCENTER)
    end;
end;

procedure MainForm.CreateToolbarFromDesk(tb:TToolBar;tbname,tbdesk:string);
var
    f:GDBOpenArrayOfByte;
    line,ts,{bn,}bc{,bh}:GDBString;
    buttonpos:GDBInteger;
    b:TToolButton;
    i:longint;
    y,xx,yy,w,code:GDBInteger;
    bmp:TBitmap;
    te:tedit;
    action:tmyaction;
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
                          line := f.readstring(';','');
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyVariableToolButton.Create(tb);
                          b.Style:=tbsCheck;
                          TmyVariableToolButton(b).AssignToVar(bc);
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~'+bc,ts);
                          b.hint:=(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(tb,b,line,false,'button_variable~'+bc);
                          b.AutoSize:=true;
                          AddToBar(tb,b);

                          updatesbytton.Add(b);

                     end;
                     if uppercase(line)='LAYERCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(';','');
                          val(bc,w,code);
                          {if assigned(LayerBox) then
                                                    shared.ShowError(format(rsReCreating,['LAYERCOMBOBOX']));}
                          LayerBox:={TComboBox}TZCADLayerComboBox.Create(tb);
                          IconList.GetBitmap(II_LayerOn,LayerBox.Glyph_OnOff_ON);
                          IconList.GetBitmap(II_LayerOff,LayerBox.Glyph_OnOff_OFF);
                          IconList.GetBitmap(II_LayerFreze,LayerBox.Glyph_Freze_ON);
                          IconList.GetBitmap(II_LayerUnFreze,LayerBox.Glyph_Freze_OFF);
                          IconList.GetBitmap(II_LayerLock,LayerBox.Glyph_Lock_ON);
                          IconList.GetBitmap(II_LayerUnLock,LayerBox.Glyph_Lock_OFF);
                          LayerBox.UpdateIcon;

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
                          bc := f.readstring(',','');
                          ts := f.readstring(';','');
                          val(bc,w,code);
                          {if assigned(LineWBox) then
                                                    shared.ShowError(format(rsReCreating,['LINEWCOMBOBOX']));}
                          LineWBox:=TComboBox.Create(tb);
                          LineWBox.Style:=csOwnerDrawFixed;
                          LineWBox.OnDrawItem:=LineWBoxDrawItem;
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
                          //LineWbox.items.Add(rsdefault);
                          //LineWbox.items.Add(rsByBlock);
                          LineWbox.items.AddObject(rsByLayer,TObject(2));
                          LineWbox.items.AddObject(rsByBlock,TObject(1));
                          LineWbox.items.AddObject(rsdefault,TObject(0));
                          //LineWbox.items.Add(rsByLayer);
                          {for i := 0 to 20 do
                          begin
                          s:=floattostr(i / 10) + ' '+rsmm;
                               LineWbox.items.AddObject(s,TObject(I*10+2));
                               //LineWbox.items.Add(s);
                          end;}
                          for i := low(lwarray) to high(lwarray) do
                          begin
                          //s:=floattostr(lwarray[i]/100) + ' '+rsmm;
                          s:=GetLWNameFromN(i);
                               LineWbox.items.AddObject(s,TObject(lwarray[i]+3));
                               //LineWbox.items.Add(s);
                          end;

                          //LineWbox.items.Add(rsDifferent);
                          LineWbox.OnChange:=ChangeCLineW;
                          LineWbox.OnDropDown:=DropDownColor;
                          LineWbox.OnCloseUp:=DropUpColor;
                          LineWbox.AutoSize:={false}true;
                          LineWbox.OnMouseLeave:=self.setnormalfocus;
                          LineWbox.DropDownCount:=50;
                          LineWbox.ItemHeight:=16;
                           AddToBar(tb,LineWBox);
                           updatescontrols.Add(LineWBox);
                     end;
                     if uppercase(line)='COLORCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(';','');
                          val(bc,w,code);
                          {if assigned(ColorBox) then
                                                    shared.ShowError(format(rsReCreating,['COLORCOMBOBOX']));}
                          ColorBox:=TComboBox.Create(tb);
                          ColorBox.Style:=csOwnerDrawFixed;
                          ColorBox.OnDrawItem:=ColorBoxDrawItem;
                          if code=0 then
                                        ColorBox.Width:=w;
                          if ts<>''then
                          begin
                               ts:=InterfaceTranslate('hint_panel~COLORCOMBOBOX',ts);
                               ColorBox.hint:=(ts);
                               ColorBox.ShowHint:=true;
                          end;
                          ColorBox.Clear;
                          ColorBox.readonly:=true;
                          ColorBox.items.AddObject(rsByBlock,TObject(0));
                          ColorBox.items.AddObject(rsByLayer,TObject(256));
                          for i := 1 to 7 do
                          begin
                               ts:=palette[i].name;
                               ColorBox.items.AddObject(ts,TObject(i));
                          end;
                          ColorBox.items.AddObject(rsSelectColor,TObject(ColorBoxSelColor));
                          ColorBox.ItemIndex:=0;
                          ColorBox.OnChange:=ChangeCColor;
                          ColorBox.OnDropDown:=DropDownColor;
                          ColorBox.OnCloseUp:=DropUpColor;
                          ColorBox.AutoSize:={false}true;
                          ColorBox.OnMouseLeave:=self.setnormalfocus;
                          ColorBox.DropDownCount:=50;
                          ColorBox.ItemHeight:=16;
                          AddToBar(tb,ColorBox);
                          updatescontrols.Add(ColorBox);
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
           if (tbname='STANDART')and(not sysparam.standartinterface) then
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
    line,ts,{bn,}bc{,bh}:GDBString;
    buttonpos:GDBInteger;
    ppanel:TToolBar;
    b:TToolButton;
    i:longint;
    y,xx,yy,w,code:GDBInteger;
    bmp:TBitmap;
    action:tmyaction;

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
           ts:=line;
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

           buttonpos:=0;
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
    pmenuitem:TmyMenuItem;
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
    pmenuitem:TmyMenuItem;
    ppopupmenu:TmyPopupMenu;
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

           cxmenumgr.RegisterLCLMenu(ppopupmenu)

end;
procedure MainForm.setmainmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    pmenu:TMainMenu;
begin
     line := f.readstring(';','');
     pmenu:=TMainMenu(application.FindComponent(MenuNameModifier+uppercase(line)));
     self.Menu:=pmenu;
end;

procedure MainForm.createmenu(var f:GDBOpenArrayOfByte;{var pm:TMenu;}var line:GDBString);
var
    pmenuitem:TmyMenuItem;
    ppopupmenu:TMenuItem;
    ts:GDBString;
    menuname:string;
    createdmenu:TMenu;
begin
           {if not assigned(createdmenu) then
                                   begin}
                                   createdmenu:=TMainMenu.Create({self}application);
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

procedure MainForm.loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);
var
    pmenuitem:TmyMenuItem;
    pm1:TMenuItem;
    ppopupmenu,submenu:TMenuItem;
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
                else if uppercase(line)='FILEHISTORY' then
                                                      begin

                                                           for i:=0 to 9 do
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
                                                           {ppopupmenu}pm.{items.}Add(submenu);

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
          TmyVariableToolButton(updatesbytton[i]).AssignToVar(TmyVariableToolButton(updatesbytton[i]).FVariable);
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
   IsEditableFocus:boolean;
   IsCommandNotEmpty:boolean;
   _enabled,_disabled:boolean;
   i:integer;
//const
     //EditableShortCut=[(scCtrl or VK_Z),{(VK_CONTROL or VK_SHIFT or VK_Z),}VK_DELETE,VK_BACK,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN];
     //ClipboardShortCut=[VK_SHIFT or VK_DELETE,VK_BACK,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN];
begin
     if AAction is TmyAction then
     begin
     Handled:=true;

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
     if assigned(TmyAction(AAction).pfoundcommand) then
     begin
     if ((GetCommandContext xor TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)and TmyAction(AAction).pfoundcommand^.CStartAttrEnableAttr)<>0
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
   ccg:char;
   tempkey:word;
   comtext,deb:string;
   ct:tclass;
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
     if assigned(gdb.GetCurrentDWG.OGLwindow1)then
                    gdb.GetCurrentDWG.OGLwindow1.myKeyPress(tempkey,shift);
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
                                              commandmanager.executecommandsilent('PrevDrawing');
                                              tempkey:=00;
                                         end;
                                 end
        else if (tempkey=VK_TAB)and(shift=[ssctrl]) then
                                 begin
                                      if assigned(PageControl)then
                                         if PageControl.PageCount>1 then
                                         begin
                                              commandmanager.executecommandsilent('NextDrawing');
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
     if pdwg.OGLwindow1<>nil then
     begin
          if pdwg.OGLwindow1.Fastmmx>=0 then
          begin
               //pdwg.OGLwindow1._onMouseMove(nil,pdwg.OGLwindow1.Fastmmshift,pdwg.OGLwindow1.Fastmmx,pdwg.OGLwindow1.Fastmmy);
               //pdwg.OGLwindow1.Fastmmx:=-1;
          end
          else
              if  pdwg.pcamera.DRAWNOTEND then
                                              begin
                                                   rc:=pdwg.OGLwindow1.CreateRC;
                                              pdwg.OGLwindow1.finishdraw(rc);
                                              done:=false;
                                              end;
     end
     end
     else
         SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     //SysVar.debug.memi2:=memman.i2;
     if (SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and(commandmanager.pcommandrunning=nil) then
     if (pdwg)<>nil then
     if (pdwg.OGLwindow1.param.SelDesc.Selectedobjcount=0) then
     begin
          commandmanager.executecommandsilent('QSave(QS)');
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
procedure MainForm.DropUpColor(Sender:Tobject);
begin
     if tcombobox(Sender).ItemIndex=-1 then
                                           tcombobox(Sender).ItemIndex:=OldColor;
end;

procedure  MainForm.ChangeCColor(Sender:Tobject);
var
   ColorIndex,CColorSave,index:Integer;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     ColorIndex:=integer(tcombobox(Sender).items.Objects[index]);
     if ColorIndex=ColorBoxSelColor then
                           begin
                               if not assigned(ColorSelectWND)then
                               Application.CreateForm(TColorSelectWND, ColorSelectWND);
                               ShowAllCursors;
                               mr:=ColorSelectWND.showmodal;
                               if mr=mrOk then
                                              begin
                                              ColorIndex:=ColorSelectWND.ColorInfex;
                                              AddToComboIfNeed(tcombobox(Sender),palette[ColorIndex].name,TObject(ColorIndex));
                                              tcombobox(Sender).ItemIndex:=tcombobox(Sender).Items.Count-2;
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
     if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CColor^:=ColorIndex;
     end
     else
     begin
          CColorSave:=SysVar.dwg.DWG_CColor^;
          SysVar.dwg.DWG_CColor^:=ColorIndex;
          commandmanager.ExecuteCommand('SelObjChangeColorToCurrent');
          SysVar.dwg.DWG_CColor^:=CColorSave;
     end;
     setvisualprop;
     setnormalfocus(nil);
end;

procedure  MainForm.ChangeCLineW(Sender:Tobject);
var tcl,index:GDBInteger;
begin
  index:=tcombobox(Sender).ItemIndex;
  index:=integer(tcombobox(Sender).items.Objects[index])-3;
  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
  then
  begin
      SysVar.dwg.DWG_CLinew^:=index;
  end
  else
  begin
           begin
                tcl:=SysVar.dwg.DWG_CLinew^;
                SysVar.dwg.DWG_CLinew^:=index;
                commandmanager.ExecuteCommand('SelObjChangeLWToCurrent');
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
procedure MainForm.StartLongProcess(total:integer);
begin
     LPTime:=now;

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
     if gdb.GetCurrentDWG.OGLwindow1<>nil then
     gdb.GetCurrentDWG.OGLwindow1.Cursor:=crDefault;
end;

procedure MainForm.RestoreCursors;
begin
     if gdb.GetCurrentDWG<>nil then
     if gdb.GetCurrentDWG.OGLwindow1<>nil then
     gdb.GetCurrentDWG.OGLwindow1.Cursor:=crNone;
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
    shared.HistoryOutStr(format(rscompiledtimemsg,[ts]));
end;
procedure MainForm.ReloadLayer(plt: PGDBNamedObjectsArray);
var
  //i: GDBInteger;
  ir:itrec;
  plp:PGDBLayerProp;
  s:ansistring{[ls]};
  //ss:ansistring;
begin

  {layerbox.ClearText;}
  layerbox.ItemsClear;
  //layerbox.Sorted:=true;
  plp:=plt^.beginiterate(ir);
  if plp<>nil then
  repeat
       s:=plp^.GetFullName;
       //(OnOff,Freze,Lock:boolean;ItemName:utf8string;lo:pointer)
       layerbox.AddItem(plp^._on,false,plp^._lock,s,pointer(plp));//      sdfg
       //layerbox.Items.Add(s);
       plp:=plt^.iterate(ir);
  until plp=nil;
  //layerbox.Items.;
  //layerbox.Sorted:=false;
  //layerbox.Items.Add(S_Different);
  layerbox.Additem(false,false,false,rsDifferent,nil);
  layerbox.ItemIndex:=(SysVar.dwg.DWG_CLayer^);
  //layerbox.Sorted:=true;
end;
function getoglwndparam: GDBPointer; export;
begin
  result := addr(gdb.GetCurrentDWG.OGLwindow1.param);
end;
procedure updatevisible; export;
var
   ir:itrec;
   poglwnd:toglwnd;
   name:gdbstring;
   i:Integer;
   pdwg:PTSimpleDrawing;
begin
   pdwg:=gdb.GetCurrentDWG;
   if assigned(mainformn)then
   begin
   mainformn.UpdateControls;
  if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
  begin
                                      begin
                                           mainformn.setvisualprop;
                                           mainformn.Caption:=(('ZCad v'+sysvar.SYS.SYS_Version^+' - ['+gdb.GetCurrentDWG.GetFileName+']'));
  if assigned(mainwindow.LayerBox) then
  mainwindow.LayerBox.enabled:=true;
  if assigned(mainwindow.LineWBox) then
  mainwindow.LineWBox.enabled:=true;
  if assigned(mainwindow.ColorBox) then
  mainwindow.ColorBox.enabled:=true;

  for i:=0 to MainFormN.PageControl.PageCount-1 do
    begin
         tobject(poglwnd):=FindControlByType(MainFormN.PageControl.Pages[i]{.PageControl},TOGLwnd);
           if assigned(poglwnd) then
            if poglwnd.PDWG<>nil then
           begin
                name:=extractfilename(PTDrawing(poglwnd.PDWG)^.FileName);
                if @PTDRAWING(poglwnd.PDWG).mainObjRoot=(PTDRAWING(poglwnd.PDWG).pObjRoot) then
                                                                     MainFormN.PageControl.Pages[i].caption:=(name)
                                                                 else
                                                                     MainFormN.PageControl.Pages[i].caption:='BEdit('+name+':'+PGDBObjBlockdef(PTDRAWING(poglwnd.PDWG).pObjRoot).Name+')';
           end;    end;
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
                                      end;
  end
  else
      begin
           mainformn.Caption:=('ZCad v'+sysvar.SYS.SYS_Version^);
           if assigned(mainwindow.LayerBox)then
           mainwindow.LayerBox.enabled:=false;
           if assigned(mainwindow.LineWBox)then
           mainwindow.LineWBox.enabled:=false;
           if assigned(mainwindow.ColorBox) then
           mainwindow.ColorBox.enabled:=false;
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

