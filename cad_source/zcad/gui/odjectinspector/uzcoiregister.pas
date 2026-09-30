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
  Laz2_DOM,ToolWin,Clipbrd,SysUtils,uzccommandsabstract,uzcfcommandline,
  uzcutils,uzbpaths,uzcTranslations,Forms,uzcinterface,
  uzedrawingdef,uzgldrawcontext,uzctnrvectorstrings,uzsbVarmanDef,
  uzedrawingsimple,uzeentity,uzcenitiesvariablesextender,uzObjectInspector,
  uzcguimanager,uzcstrconsts,gzctnrVectorTypes,Controls,uzcdrawings,
  Varman,UUnitManager,uzcsysvars,uzcsysparams,
  uzcoimultiobjects,uzccommandsimpl,uzmenusmanager,uzcLog,Menus,ComCtrls,
  uztoolbarsmanager,uzcimagesmanager,uzctreenode,uzcActionsManager,
  uzObjectInspectorManager,zeundostack,uzcOI,UObjectDescriptor,Classes,uzbUnits,
  uzeTypes;

implementation

const
  PEditorFocusPriority=550;

type
  TDummyOIClass=class
    class procedure UpdateObjInsp(Sender:TObject;GUIMode:TzcMessageID);
    class procedure ReBuild(Sender:TObject;GUIMode:TzcMessageID);
    class procedure SetCurrentObjDefault(Sender:TObject;GUIMode:TzcMessageID);
    class procedure FreEditor(Sender:TObject;GUIMode:TzcMessageID);
    class procedure StoreAndFreeEditor(Sender:TObject;GUIMode:TzcMessageID);
    class procedure ReturnToDefault(Sender:TObject;GUIMode:TzcMessageID);
    class procedure ContextPopup(Sender:TObject;MousePos:TPoint;var Handled:boolean);
    class function GetPeditorFocusPriority:TControlWithPriority;
    class procedure _onAfterFreeEditor(Sender:TObject);
  end;

function GetPeditor:TComponent;
begin
  if assigned(GDBobjinsp) then begin
    Result:=GDBobjinsp.InPlaceEditor;
  end else
    Result:=nil;
end;

function GetCurrentObj:Pointer;
begin
  if assigned(GDBobjinsp) then begin
    Result:=GDBobjinsp.DisplayedDataPData;
  end else
    Result:=nil;
end;

procedure SetCurrentObjDefault;
begin
  if assigned(GDBobjinsp) then begin
    GDBobjinsp.SetDisplayedDataAsDefault;
  end;
end;

procedure _onGetOtherValues(var vsa:TZctnrVectorStrings;const valkey:string;const DD:TDisplayedData);
var
  pentvarext:TVariablesExtender;
  pobj:pGDBObjEntity;
  ir:itrec;
  pv:pvardesk;
  vv:string;
begin
  if (DD.PData=@MSEditor)and(valkey<>'')and(DD.Ctx<>nil) then begin
    pobj:=PTSimpleDrawing(DD.Ctx).GetCurrentROOT.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        pentvarext:=pobj^.GetExtension<TVariablesExtender>;
        if pentvarext<>nil then begin
          pv:=pentvarext.entityunit.FindVariable(valkey);
          if pv<>nil then begin
            vv:=pv.Data.PTD.GetEditableAsString(pv.Data.Addr.Instance,DD.UnitsFormat);
            if vv<>'' then
              vsa.PushBackIfNotPresent(vv);
          end;
        end;
        pobj:=PTSimpleDrawing(DD.Ctx).GetCurrentROOT.ObjArray.iterate(ir);
      until pobj=nil;
    vsa.sort;
  end;
end;

procedure _onUpdateObjectInInsp(const EDContext:TEditorContext;const currobjgdbtype:PUserTypeDescriptor;
  const pcurcontext:pointer;const pcurrobj:pointer;const OnFieldModifyProc:TOnFieldModifyProc);

  function IsEntityInCurrentContext:boolean;
  begin
    Result:=PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple;
  end;

var
  pdwg:PTSimpleDrawing;
begin
  if @OnFieldModifyProc<>nil then
    OnFieldModifyProc(pcurrobj,EDContext.ppropcurrentedit^.valueAddres,currobjgdbtype);

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
    PTDrawingDef(pcurcontext).SetAllChangeStampt;
end;

class procedure TDummyOIClass._onAfterFreeEditor(Sender:TObject);
begin
  zcUI.Do_SetNormalFocus;
end;

procedure StoreAndSetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;
    exttype:PUserTypeDescriptor;addr,context:pointer;popoldpos:boolean=False);
begin
  if assigned(GDBobjinsp) then begin
    if popoldpos then
      if not GDBobjinsp.hasStoredData then
        GDBobjinsp.StoreDisplayedData;
    GDBobjinsp.setDisplayedData(TDisplayedData.CreateRec(addr,exttype,context,f));
  end;
end;

procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PInteger;
  TBNode:TDomNode;
  tb:TToolBar;
  action:tmyaction;
  cw,w:integer;
begin

  GDBobjinsp:=TGDBObjInsp.Create(Application);
  GDBobjinsp.OnContextPopup:=TDummyOIClass.ContextPopup;
  GDBobjinsp.onGetOtherValues:=_onGetOtherValues;
  GDBobjinsp.onUpdateObjectInInsp:=_onUpdateObjectInInsp;
  GDBobjinsp.onNotify:=_onNotify;
  GDBobjinsp.onAfterFreeEditor:=TDummyOIClass._onAfterFreeEditor;

  StoreAndSetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;

  cw:=GetIntegerFromUnit(SavedUnit^,'VIEW_ObjInspSubV','',Form.Width div 2,0,Form.Width);
  w:=GetIntegerFromUnit(SavedUnit^,'VIEW_ObjInspV','',Form.Width,0,Form.Width);
  GDBobjinsp.setPropertyColumnWidth(cw,cw,w);

  TBNode:=nil;
  if assigned(ToolBarsManager) then
    TBNode:=ToolBarsManager.FindBarsContent('ObjInspUpToolbar');
  if assigned(TBNode) then begin
    tb:=ttoolbar.Create(form);
    tb.Images:=ImagesManager.IconList;
    tb.AutoSize:=True;
    tb.ShowCaptions:=True;
    tb.Align:=alTop;
    tb.EdgeBorders:=[];//[ebBottom];
    ToolBarsManager.CreateToolbarContent(tb,TBNode);
    tb.Parent:=TForm(Form);
  end;

  action:=tmyaction(StandartActions.ActionByName(ToolBarNameToActionName('ObjInspUpToolbar')));
  if assigned(action) then begin
    action.Enabled:=False;
    action.Checked:=True;
    action.pfoundcommand:=nil;
    action.command:='';
    action.options:='';
  end;

  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=TForm(Form);
  zcUI.RegisterHandler_KeyDown(GDBobjinsp.myKeyDown);
end;

function CreateObjInspInstance(FormName:string):TForm;
begin
  Result:=TForm(TForm.NewInstance);
end;

function ObjInspCopyToClip_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  if GetCurrentObj=nil then
    zcUI.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut)
  else begin
    if uppercase(Operands)='VAR' then
      clipbrd.clipboard.AsText:=GDBobjinsp.CurrPD.ValKey
    else if uppercase(Operands)='LVAR' then
      clipbrd.clipboard.AsText:='@@['+GDBobjinsp.CurrPD.ValKey+']'
    else if uppercase(Operands)='VALUE' then
      clipbrd.clipboard.AsText:=GDBobjinsp.CurrPD.Value;
  end;
  Result:=cmd_ok;
end;

class procedure TDummyOIClass.ReBuild(Sender:TObject;GUIMode:TzcMessageID);
begin
  if (GUIMode=zcMsgUIRePrepareObject) then begin
    if GetCurrentObj=@MSEditor then
      MSEditor.CreateUnit(drawings.GetUnitsFormat);
    if assigned(GDBobjinsp) then begin
      GDBobjinsp.ReBuild;
    end;
  end;
end;

class procedure TDummyOIClass.UpdateObjInsp(Sender:TObject;GUIMode:TzcMessageID);
begin
  if (GUIMode=zcMsgUIActionRedraw)  or (GUIMode=zcMsgUITimerTick) then
    if assigned(GDBobjinsp) then begin
      GDBobjinsp.updateinsp;
    end;
end;

class procedure TDummyOIClass.SetCurrentObjDefault;
begin
  if (GUIMode=zcMsgUISetDefaultObject) then
    uzcoiregister.SetCurrentObjDefault;
end;

class procedure TDummyOIClass.FreEditor;
begin
  if (GUIMode=zcMsgUIFreEditorProc) then
    if assigned(GDBobjinsp) then begin
      GDBobjinsp.freeeditor;
    end;
end;

class procedure TDummyOIClass.StoreAndFreeEditor;
begin
  if (GUIMode=zcMsgUIStoreAndFreeEditorProc) then
    if assigned(GDBobjinsp) then begin
      GDBobjinsp.StoreAndFreeEditor;
    end;
end;

class procedure TDummyOIClass.ReturnToDefault;
begin
  if (GUIMode=zcMsgUIReturnToDefaultObject) then
    if assigned(GDBobjinsp) then begin
      GDBobjinsp.ForgetStoredData;
      GDBobjinsp.ReturnToDefault;
    end;
end;

class procedure TDummyOIClass.ContextPopup(Sender:TObject;MousePos:TPoint;var Handled:boolean);
var
  menu:TPopupMenu;
begin
  if Sender is TGDBobjinsp then begin
    menu:=nil;
    if (Sender as TGDBobjinsp).CurrPD=nil then
      menu:=MenusManager.GetPopupMenu('OBJINSPHEADERCXMENU',nil)
    else if (Sender as TGDBobjinsp).CurrPD^.valkey<>'' then
      menu:=MenusManager.GetPopupMenu('OBJINSPVARCXMENU',nil)
    else if (Sender as TGDBobjinsp).CurrPD^.Value<>'' then
      menu:=MenusManager.GetPopupMenu('OBJINSPCXMENU',nil)
    else
      menu:=MenusManager.GetPopupMenu('OBJINSPHEADERCXMENU',nil);
    if menu<>nil then begin
      menu.PopUp;
    end;
  end;
end;

class function TDummyOIClass.GetPeditorFocusPriority:TControlWithPriority;
begin
  Result.priority:=UnPriority;
  Result.control:=nil;

  if assigned(GDBobjinsp) then
    if GDBobjinsp.InPlaceEditor<>nil then
      if GDBobjinsp.InPlaceEditor.geteditor<>nil then
        if GDBobjinsp.InPlaceEditor.geteditor.IsVisible then
          if GDBobjinsp.InPlaceEditor.geteditor.CanFocus then begin
            Result.priority:=PEditorFocusPriority;
            Result.control:=GDBobjinsp.InPlaceEditor.geteditor;
          end;
end;

procedure StoreOICfg(var AUnit:TSimpleUnit);
begin
  if assigned(GDBobjinsp) then begin
    StoreIntegerToUnit(AUnit,'','VIEW_ObjInspSubV',GDBobjinsp.PropertyColumnWidth);
    StoreIntegerToUnit(AUnit,'','VIEW_ObjInspV',GDBobjinsp.ClientWidth);
  end;
end;

var
  vd:vardesk;
  system_pas_path:string;

initialization
  system_pas_path:=expandpath('$(DistribPath)/rtl/system.pas');
  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getWhiteBackground,
    OIManager.setWhiteBackground);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_WhiteBackground.Setup(OIManager.getWhiteBackground,
    OIManager.setWhiteBackground);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ShowHeaders','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getShowHeaders,OIManager.setShowHeaders);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowHeaders.Setup(OIManager.getShowHeaders,
    OIManager.setShowHeaders);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ShowSeparator','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getShowSeparator,
    OIManager.setShowSeparator);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator.Setup(OIManager.getShowSeparator,
    OIManager.setShowSeparator);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_OldStyleDraw','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getOldStyleDraw,
    OIManager.setOldStyleDraw);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw.Setup(OIManager.getOldStyleDraw,
    OIManager.setOldStyleDraw);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ShowFastEditors','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getShowFastEditors,
    OIManager.setShowFastEditors);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowFastEditors.Setup(OIManager.getShowFastEditors,
    OIManager.setShowFastEditors);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ShowOnlyHotFastEditors','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getShowOnlyHotFastEditors,
    OIManager.setShowOnlyHotFastEditors);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowOnlyHotFastEditors.Setup(
    OIManager.getShowOnlyHotFastEditors,OIManager.setShowOnlyHotFastEditors);


  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
  InterfaceTranslate,
    'INTF_ObjInsp_Level0HeaderColor','TGetterSetterTColor');
  PTGetterSetterTColor(vd.Data.Addr.GetInstance)^.Setup(OIManager.getLevel0HeaderColor,
    OIManager.setLevel0HeaderColor);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_Level0HeaderColor.Setup(
    OIManager.getLevel0HeaderColor,OIManager.setLevel0HeaderColor);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
  InterfaceTranslate,'INTF_ObjInsp_BorledColor','TGetterSetterTColor');
  PTGetterSetterTColor(vd.Data.Addr.GetInstance)^.Setup(OIManager.getBorderColor,OIManager.setBorderColor);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_BorderColor.Setup(OIManager.getBorderColor,
    OIManager.setBorderColor);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderEnable','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getRowHeightOverrideUsable,
    OIManager.setRowHeightOverrideUsable);
  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderValue','TGetterSetterInteger');
  PTGetterSetterInteger(vd.Data.Addr.GetInstance)^.Setup(OIManager.getRowHeightOverrideValue,
    OIManager.setRowHeightOverrideValue);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Setup(OIManager.getRowHeightOverride,
    OIManager.setRowHeightOverride);


  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ButtonSizeReducing','TGetterSetterInteger');
  PTGetterSetterInteger(vd.Data.Addr.GetInstance)^.Setup(OIManager.getButtonSizeReducing,
    OIManager.setButtonSizeReducing);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ButtonSizeReducing.Setup(
    OIManager.getButtonSizeReducing,OIManager.setButtonSizeReducing);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_SpaceHeight','TGetterSetterInteger');
  PTGetterSetterInteger(vd.Data.Addr.GetInstance)^.Setup(OIManager.getOpenNodeIdent,
    OIManager.setOpenNodeIdent);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_SpaceHeight.Setup(OIManager.getOpenNodeIdent,
    OIManager.setOpenNodeIdent);

  vd:=units.CreateInternalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,
    InterfaceTranslate,'INTF_ObjInsp_ShowEmptySections','TGetterSetterBoolean');
  PTGetterSetterBoolean(vd.Data.Addr.GetInstance)^.Setup(OIManager.getShowEmptySections,
    OIManager.setShowEmptySections);
  SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowEmptySections.Setup(
    OIManager.getShowEmptySections,OIManager.setShowEmptySections);



  OIManager.DefaultRowHeight:=ZCSysParams.notsaved.defaultheight;
  ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,
  rect(0,100,200,600),ZCADFormSetupProc,CreateObjInspInstance,@GDBobjinsp);
  OIManager.PropertyRowName:=rsProperty;
  OIManager.ValueRowName:=rsValue;
  OIManager.DifferentName:=rsDifferent;

  zcUI.RegisterHandler_PrepareObject(StoreAndSetGDBObjInsp());
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.UpdateObjInsp);
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.ReturnToDefault());
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.ReBuild);
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.SetCurrentObjDefault);
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.FreEditor);
  zcUI.RegisterHandler_GUIAction(TDummyOIClass.StoreAndFreeEditor);
  zcUI.RegisterHandler_GetFocusedControl(TDummyOIClass.GetPeditorFocusPriority);
  zcUI.RegisterStoreProc(StoreOICfg);
  CreateZCADCommand(@ObjInspCopyToClip_com,'ObjInspCopyToClip',0,0).overlay:=True;

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
