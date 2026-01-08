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

unit uzcOIRegister;
{$INCLUDE zengineconfig.inc}
interface
uses
  Laz2_DOM,Toolwin,Clipbrd,sysutils,uzccommandsabstract,uzcfcommandline,
  uzcutils,uzbpaths,uzcTranslations,Forms,uzcinterface,uzeroot,
  uzedrawingdef,uzgldrawcontext,uzctnrvectorstrings,uzsbVarmanDef,
  uzedrawingsimple,uzeentity,uzcenitiesvariablesextender,uzObjectInspector,
  uzcguimanager,uzcstrconsts,gzctnrVectorTypes,Controls,uzcdrawings,
  Varman,UUnitManager,uzcsysvars,uzcsysparams,
  uzcoimultiobjects,uzccommandsimpl,uzmenusmanager,uzcLog,menus,ComCtrls,
  uztoolbarsmanager,uzcimagesmanager,uzctreenode,uzcActionsManager,
  uzObjectInspectorManager,zeundostack,uzcOI,UObjectDescriptor,classes,uzbUnits,
  uzbBaseUtils,uzeTypes;
const
    PEditorFocusPriority=550;
type
  tdummyclass=class
    procedure UpdateObjInsp(sender:TObject;GUIMode:TzcMessageID);
    procedure ReBuild(sender:TObject;GUIMode:TzcMessageID);
    procedure SetCurrentObjDefault(sender:TObject;GUIMode:TzcMessageID);
    procedure FreEditor(sender:TObject;GUIMode:TzcMessageID);
    procedure StoreAndFreeEditor(sender:TObject;GUIMode:TzcMessageID);
    procedure ReturnToDefault(sender:TObject;GUIMode:TzcMessageID);
    procedure ContextPopup(Sender: TObject; MousePos: TPoint;var Handled: Boolean);
    function GetPeditorFocusPriority:TControlWithPriority;
    class procedure _onAfterFreeEditor(sender:tobject);
  end;
var
  dummyclass:tdummyclass;
implementation
var
  system_pas_path:string;
procedure SetLastClientWidth(w:integer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.NameColumnWidthCorrector.LastClientWidth:=w;
                                  end;
end;

function GetPeditor:TComponent;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.peditor;
                                  end
                               else
                                   result:=nil;
end;

function GetNameColWidth:integer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.NameColumnWidth;
                                  end
                               else
                                   result:=0;
end;
function GetOIWidth:integer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.ClientWidth;
                                  end
                               else
                                   result:=0;
end;
function  GetCurrentObj:Pointer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.CurrData.PObj;
                                  end
                              else
                                  result:=nil;
end;
procedure SetCurrentObjDefault;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.SetCurrentObjDefault;
                                  end;
end;
function isGDBObjInstance(const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:pointer;const pcurrobj:pointer):boolean;
begin
  result:=false;
  if (currobjgdbtype<>nil)and(pcurrobj<>nil) then
    if IsObjectIt(typeof(currobjgdbtype^),typeof(ObjectDescriptor)) then
      if IsObjectIt(PObjectDescriptor(currobjgdbtype)^.PVMT,typeof(GDBaseObject)) then
        result:=True;
end;
procedure _onGetOtherValues(var vsa:TZctnrVectorStrings;const valkey:string;const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:pointer;const pcurrobj:pointer;const f:TzeUnitsFormat);
var
  pentvarext:TVariablesExtender;
  pobj:pGDBObjEntity;
  ir:itrec;
  pv:pvardesk;
  vv:String;
begin
  if (valkey<>'')and(pcurcontext<>nil) then
  begin
       pobj:=PTSimpleDrawing(pcurcontext).GetCurrentROOT.ObjArray.beginiterate(ir);
       if pobj<>nil then
       repeat
             if isGDBObjInstance(currobjgdbtype,pcurcontext,pcurrobj) then
             begin
             pentvarext:=pobj^.GetExtension<TVariablesExtender>;
             if ((pobj^.GetObjType=pgdbobjentity(pcurrobj)^.GetObjType)or(pgdbobjentity(pcurrobj)^.GetObjType=0))and({pobj.ou.Instance}pentvarext<>nil) then
             begin
                  pv:={PTEntityUnit(pobj.ou.Instance)}pentvarext.entityunit.FindVariable(valkey);
                  if pv<>nil then
                  begin
                       vv:=pv.data.PTD.GetEditableAsString(pv.data.Addr.Instance,f);
                       if vv<>'' then

                       vsa.PushBackIfNotPresent(vv);
                  end;
             end;
             end;
             pobj:=PTSimpleDrawing(pcurcontext).GetCurrentROOT.ObjArray.iterate(ir);
       until pobj=nil;
       vsa.sort;
  end;
end;
procedure _onUpdateObjectInInsp(const EDContext:TEditorContext;const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:pointer;const pcurrobj:pointer{;const GDBobj:boolean});
  function CurrObjIsEntity:boolean;
  begin
    result:=false;
    //if GDBobj then
    //  if PGDBaseObject(pcurrobj)^.IsEntity then
    //    result:=true;
  end;
  function IsEntityInCurrentContext:boolean;
  begin
       if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple
       then
           result:=true
      else
           result:=false;
  end;
var
   dc:TDrawContext;
   pdwg:PTSimpleDrawing;
begin
  if isGDBObjInstance(currobjgdbtype,pcurcontext,pcurrobj) then
                begin
                     dc:=PTDrawingDef(pcurcontext)^.CreateDrawingRC;
                    if CurrObjIsEntity then
                                           begin
                                               PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^,dc);
                                               if IsEntityInCurrentContext
                                               then
                                                   PGDBObjEntity(pcurrobj).YouChanged(PTDrawingDef(pcurcontext)^)
                                               else
                                                   PGDBObjRoot(PTDrawingDef(pcurcontext)^.GetCurrentRootSimple)^.FormatAfterEdit(PTDrawingDef(pcurcontext)^,dc);
                                           end
                                       else
                                        begin
                                           if assigned(EDContext.ppropcurrentedit) then
                                             PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(EDContext.ppropcurrentedit^.valueAddres,currobjgdbtype);
                                        end;
                end;
  //zcUI.Do_GUIaction(nil,zcMsgUIResetOGLWNDProc);
  pdwg:=drawings.GetCurrentDWG;
  if pdwg<>nil then
    pdwg.wa.param.lastonmouseobject:=nil;

  zcRedrawCurrentDrawing;
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);

  // убрано, потому что с этим не работают фильтры в инспекторе
  //if GDBobj then
  //  if typeof(PGDBaseObject(pcurrobj)^)=typeof(TMSEditor) then
  //    PMSEditor(pcurrobj)^.CreateUnit(PMSEditor(pcurrobj)^.SavezeUnitsFormat);
end;
procedure _onNotify(const pcurcontext:pointer);
begin
  if pcurcontext<>nil then
  begin
       PTDrawingDef(pcurcontext).ChangeStampt(true);
  end;
end;
class procedure tdummyclass._onAfterFreeEditor(sender:tobject);
begin
  zcUI.Do_SetNormalFocus;
end;

procedure StoreAndSetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer;popoldpos:boolean=false);
begin
     if assigned(GDBobjinsp)then
     begin
     if popoldpos then
     if (GDBobjinsp.StoredData.PObj=nil) then
                             begin
                               GDBobjinsp.StoredData:=GDBobjinsp.CurrData;
                                  //GDBobjinsp.PStoredObj:=GDBobjinsp.CurrPObj;
                                  //GDBobjinsp.StoredObjGDBType:=GDBobjinsp.CurrObjGDBType;
                                  //GDBobjinsp.pStoredContext:=GDBobjinsp.CurrContext;
                                  //GDBobjinsp.StoredUndoStack:=GDBobjinsp.EDContext.UndoStack;
                                  //GDBobjinsp.StoredUnitsFormat:=GDBobjinsp.CurrUnitsFormat;
                             end;
     GDBobjinsp.setptr(TDisplayedData.CreateRec(addr,exttype,context,f));
     end;
end;

procedure SetNameColWidth(w:integer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.NameColumnWidth:=w;
                                       GDBobjinsp.NameColumnWidthCorrector.LastNameColumnWidth:=w;
                                  end;
end;

procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PInteger;
  TBNode:TDomNode;
  tb:TToolBar;
  action:tmyaction;
begin

  GDBobjinsp:=TGDBObjInsp.Create(Application);
  //GDBobjinsp._IsCurrObjInUndoContext:=IsCurrObjInUndoContext;
  GDBobjinsp.OnContextPopup:=dummyclass.ContextPopup;
  GDBobjinsp.onGetOtherValues:=_onGetOtherValues;
  GDBobjinsp.onUpdateObjectInInsp:=_onUpdateObjectInInsp;
  GDBobjinsp.onNotify:=_onNotify;
  GDBobjinsp.onAfterFreeEditor:=tdummyclass._onAfterFreeEditor;

  StoreAndSetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;
  //pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  SetNameColWidth(Form.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV').data.Addr.Instance;
  if assigned(pint)then
                       SetNameColWidth(pint^);
  pint:=SavedUnit.FindValue('VIEW_ObjInspV').data.Addr.Instance;
  if assigned(pint)then
                       SetLastClientWidth(pint^);
  TBNode:=nil;
  if assigned(ToolBarsManager)then
    TBNode:=ToolBarsManager.FindBarsContent('ObjInspUpToolbar');
  if assigned(TBNode)then begin
    tb:=ttoolbar.create(form);
    tb.Images:=ImagesManager.IconList;
    tb.AutoSize:=true;
    tb.ShowCaptions:=true;
    tb.Align:=alTop;
    tb.EdgeBorders:=[];//[ebBottom];
    ToolBarsManager.CreateToolbarContent(tb,TBNode);
    tb.Parent:=tform(Form);
  end;

  action:=tmyaction(StandartActions.ActionByName(ToolBarNameToActionName('ObjInspUpToolbar')));
  if assigned(action) then
    begin
      action.Enabled:=false;
      action.Checked:=true;
      action.pfoundcommand:=nil;
      action.command:='';
      action.options:='';
    end;

  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=tform(Form);
  zcUI.RegisterHandler_KeyDown(GDBobjinsp.myKeyDown);
end;
function CreateObjInspInstance(FormName:string):TForm;
begin
  result:=tform(TForm.NewInstance);
end;

function ObjInspCopyToClip_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
   if GetCurrentObj=nil then
                             zcUI.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut)
                         else
                             begin
                                  if uppercase(Operands)='VAR' then
                                                                   clipbrd.clipboard.AsText:=GDBobjinsp.currpd.ValKey
                             else if uppercase(Operands)='LVAR' then
                                                                   clipbrd.clipboard.AsText:='@@['+GDBobjinsp.currpd.ValKey+']'
                             else if uppercase(Operands)='VALUE' then
                                                                   clipbrd.clipboard.AsText:=GDBobjinsp.currpd.Value;
                                  GDBobjinsp.currpd:=nil;
                             end;
   result:=cmd_ok;
end;
procedure tdummyclass.ReBuild(sender:TObject;GUIMode:TzcMessageID);
begin
       if (GUIMode=zcMsgUIRePrepareObject)then
       begin
         if GetCurrentObj=@MSEditor then  MSEditor.CreateUnit(drawings.GetUnitsFormat);
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.ReBuild;
                                  end;
       end;
end;
procedure tdummyclass.UpdateObjInsp(sender:TObject;GUIMode:TzcMessageID);
begin
   if (GUIMode=zcMsgUIActionRedraw)
   or (GUIMode=zcMsgUITimerTick) then
     if assigned(GDBobjinsp)then
                                begin
                                     GDBobjinsp.updateinsp;
                                end;
end;
procedure tdummyclass.SetCurrentObjDefault;
begin
  if (GUIMode=zcMsgUISetDefaultObject) then
    uzcoiregister.SetCurrentObjDefault
end;
procedure tdummyclass.FreEditor;
begin
       if (GUIMode=zcMsgUIFreEditorProc) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.freeeditor;
                                  end
end;
procedure tdummyclass.StoreAndFreeEditor;
begin
       if (GUIMode=zcMsgUIStoreAndFreeEditorProc) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.StoreAndFreeEditor;
                                  end
end;
procedure tdummyclass.ReturnToDefault;
begin
  if (GUIMode=zcMsgUIReturnToDefaultObject) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.StoredData.PObj:=nil;
                                       GDBobjinsp.StoredData.PType:=nil;
                                       GDBobjinsp.ReturnToDefault;
                                  end;
end;
procedure tdummyclass.ContextPopup(Sender: TObject; MousePos: TPoint;var Handled: Boolean);
var
  menu:TPopupMenu;
begin
  if sender is TGDBobjinsp then begin
  menu:=nil;
  if {(clickonheader)or}(sender as TGDBobjinsp).currpd=nil then
  menu:=MenusManager.GetPopupMenu('OBJINSPHEADERCXMENU',nil)
else if (sender as TGDBobjinsp).currpd^.valkey<>''then
  menu:=MenusManager.GetPopupMenu('OBJINSPVARCXMENU',nil)
else if (sender as TGDBobjinsp).currpd^.Value<>''then
  menu:=MenusManager.GetPopupMenu('OBJINSPCXMENU',nil)
else
  menu:=MenusManager.GetPopupMenu('OBJINSPHEADERCXMENU',nil);
  if menu<>nil then
  begin
  menu.PopUp;
  end;
  end;
end;
function tdummyclass.GetPeditorFocusPriority:TControlWithPriority;
begin
  result.priority:=UnPriority;
  result.control:=nil;

  if assigned(GDBobjinsp) then
  if GDBobjinsp.PEditor<>nil then
  if GDBobjinsp.PEditor.geteditor<>nil then
  if GDBobjinsp.PEditor.geteditor.IsVisible then
  if GDBobjinsp.PEditor.geteditor.CanFocus then begin
    result.priority:=PEditorFocusPriority;
    result.control:=GDBobjinsp.PEditor.geteditor;
  end;
end;
var
  vd:vardesk;
initialization
  system_pas_path:=expandpath('$(DistribPath)/rtl/system.pas');
  //units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','Boolean',@OIManager.INTFObjInspWhiteBackground);
  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getWhiteBackground,OIManager.setWhiteBackground);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_WhiteBackground.Setup(OIManager.getWhiteBackground,OIManager.setWhiteBackground);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ShowHeaders','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getShowHeaders,OIManager.setShowHeaders);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowHeaders.Setup(OIManager.getShowHeaders,OIManager.setShowHeaders);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ShowSeparator','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getShowSeparator,OIManager.setShowSeparator);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator.Setup(OIManager.getShowSeparator,OIManager.setShowSeparator);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_OldStyleDraw','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getOldStyleDraw,OIManager.setOldStyleDraw);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw.Setup(OIManager.getOldStyleDraw,OIManager.setOldStyleDraw);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ShowFastEditors','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getShowFastEditors,OIManager.setShowFastEditors);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowFastEditors.Setup(OIManager.getShowFastEditors,OIManager.setShowFastEditors);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ShowOnlyHotFastEditors','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getShowOnlyHotFastEditors,OIManager.setShowOnlyHotFastEditors);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowOnlyHotFastEditors.Setup(OIManager.getShowOnlyHotFastEditors,OIManager.setShowOnlyHotFastEditors);


  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_Level0HeaderColor','TGetterSetterTColor');
  PTGetterSetterTColor(vd.data.Addr.GetInstance)^.Setup(OIManager.getLevel0HeaderColor,OIManager.setLevel0HeaderColor);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_Level0HeaderColor.Setup(OIManager.getLevel0HeaderColor,OIManager.setLevel0HeaderColor);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_BorledColor','TGetterSetterTColor');
  PTGetterSetterTColor(vd.data.Addr.GetInstance)^.Setup(OIManager.getBorderColor,OIManager.setBorderColor);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_BorderColor.Setup(OIManager.getBorderColor,OIManager.setBorderColor);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderEnable','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getRowHeightOverrideUsable,OIManager.setRowHeightOverrideUsable);
  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderValue','TGetterSetterInteger');
  PTGetterSetterInteger(vd.data.Addr.GetInstance)^.Setup(OIManager.getRowHeightOverrideValue,OIManager.setRowHeightOverrideValue);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Setup(OIManager.getRowHeightOverride,OIManager.setRowHeightOverride);


  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ButtonSizeReducing','TGetterSetterInteger');
  PTGetterSetterInteger(vd.data.Addr.GetInstance)^.Setup(OIManager.getButtonSizeReducing,OIManager.setButtonSizeReducing);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ButtonSizeReducing.Setup(OIManager.getButtonSizeReducing,OIManager.setButtonSizeReducing);

  //INTFObjInspRowHeight.Enable:=OIManager.LocalRowHeightOverride;
  //INTFObjInspRowHeight.Value:=OIManager.LocalRowHeight;
  //OIManager.PRowHeight:=@INTFObjInspRowHeight.Value;
  //OIManager.PRowHeightOverride:=@INTFObjInspRowHeight.Enable;

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_SpaceHeight','TGetterSetterInteger');
  PTGetterSetterInteger(vd.data.Addr.GetInstance)^.Setup(OIManager.getOpenNodeIdent,OIManager.setOpenNodeIdent);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_SpaceHeight.Setup(OIManager.getOpenNodeIdent,OIManager.setOpenNodeIdent);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_ObjInsp_ShowEmptySections','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.data.Addr.GetInstance)^.Setup(OIManager.getShowEmptySections,OIManager.setShowEmptySections);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowEmptySections.Setup(OIManager.getShowEmptySections,OIManager.setShowEmptySections);



  OIManager.DefaultRowHeight:=ZCSysParams.notsaved.defaultheight;
  ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,rect(0,100,200,600),ZCADFormSetupProc,CreateObjInspInstance,@GDBobjinsp);
  OIManager.PropertyRowName:=rsProperty;
  OIManager.ValueRowName:=rsValue;
  OIManager.DifferentName:=rsDifferent;

  //GDBobjinsp.currpd:=nil;
  zcUI.RegisterHandler_PrepareObject(StoreAndSetGDBObjInsp());
  dummyclass:=tdummyclass.create;
  zcUI.RegisterHandler_GUIAction(dummyclass.UpdateObjInsp);
  //UpdateObjInspProc:=dummyclass.UpdateObjInsp;
  zcUI.RegisterHandler_GUIAction(dummyclass.ReturnToDefault());
  //ReturnToDefaultProc:=ReturnToDefault;
  //ClrarIfItIsProc:=ClrarIfItIs;
  zcUI.RegisterHandler_GUIAction(dummyclass.ReBuild);
  //ReBuildProc:=ReBuild;
  zcUI.RegisterHandler_GUIAction(dummyclass.SetCurrentObjDefault);
  //SetCurrentObjDefaultProc:=SetCurrentObjDefault;
  //GetCurrentObjProc:=GetCurrentObj;
  GetNameColWidthProc:=GetNameColWidth;
  GetOIWidthProc:=GetOIWidth;
  //GetPeditorProc:=GetPeditor;
  zcUI.RegisterHandler_GUIAction(dummyclass.FreEditor);
  //FreEditorProc:=FreEditor;
  zcUI.RegisterHandler_GUIAction(dummyclass.StoreAndFreeEditor);
  zcUI.RegisterHandler_GetFocusedControl(dummyclass.GetPeditorFocusPriority);
  //StoreAndFreeEditorProc:=StoreAndFreeEditor;
  CreateZCADCommand(@ObjInspCopyToClip_com,'ObjInspCopyToClip',0,0).overlay:=true;

finalization
  dummyclass.free;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

