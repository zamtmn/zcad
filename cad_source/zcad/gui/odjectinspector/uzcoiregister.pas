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

unit uzcoiregister;
{$INCLUDE zengineconfig.inc}
interface
uses Laz2_DOM,Toolwin,Clipbrd,sysutils,uzccommandsabstract,uzcfcommandline,uzcutils,uzbpaths,TypeDescriptors,uzcTranslations,Forms,uzcinterface,uzeroot,
     uzbtypes,uzedrawingdef,uzgldrawcontext,uzctnrvectorstrings,varmandef,uzedrawingsimple,
     uzeentity,uzcenitiesvariablesextender,zcobjectinspector,uzcguimanager,uzcstrconsts,
     gzctnrVectorTypes,Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,
     uzcsysparams,zcobjectinspectorui,uzcoimultiobjects,uzccommandsimpl,
     uzmenusmanager,uzcLog,menus,ComCtrls,uztoolbarsmanager,uzcimagesmanager;
const
    PEditorFocusPriority=550;
type
  tdummyclass=class
    procedure UpdateObjInsp(sender:TObject;GUIMode:TZMessageID);
    procedure ReBuild(sender:TObject;GUIMode:TZMessageID);
    procedure SetCurrentObjDefault(sender:TObject;GUIMode:TZMessageID);
    procedure FreEditor(sender:TObject;GUIMode:TZMessageID);
    procedure StoreAndFreeEditor(sender:TObject;GUIMode:TZMessageID);
    procedure ReturnToDefault(sender:TObject;GUIMode:TZMessageID);
    procedure ContextPopup(Sender: TObject; MousePos: TPoint;var Handled: Boolean);
    function GetPeditorFocusPriority:TControlWithPriority;
  end;
var
  INTFObjInspRowHeight:TIntegerOverrider;
  dummyclass:tdummyclass;
implementation
procedure SetCurrentObjDefault;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.SetCurrentObjDefault;
                                  end;
end;
function IsCurrObjInUndoContext(_GDBobj:boolean;_pcurrobj:pointer):boolean;
begin
  result:=false;
  if _GDBobj then
    if PGDBaseObject(_pcurrobj)^.IsEntity then
      //if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple then
      result:=true;
end;
procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PInteger;
  TBNode:TDomNode;
  tb:TToolBar;
begin

  GDBobjinsp:=TGDBObjInsp.Create(Application);
  GDBobjinsp._IsCurrObjInUndoContext:=IsCurrObjInUndoContext;
  GDBobjinsp.OnContextPopup:=dummyclass.ContextPopup;

  StoreAndSetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  //StoreAndSetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('PTLayerControl'),@sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable,nil);
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
    tb.EdgeBorders:=[ebBottom];
    ToolBarsManager.CreateToolbarContent(tb,TBNode);
    tb.Parent:=tform(Form);
  end;
  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=tform(Form);
  ZCMsgCallBackInterface.RegisterHandler_KeyDown(GDBobjinsp.myKeyDown);
end;
procedure _onNotify(const pcurcontext:pointer);
begin
  if pcurcontext<>nil then
  begin
       PTDrawingDef(pcurcontext).ChangeStampt(true);
  end;
end;
procedure _onUpdateObjectInInsp(const EDContext:TEditorContext;const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:pointer;const pcurrobj:pointer;const GDBobj:boolean);
function CurrObjIsEntity:boolean;
begin
result:=false;
            if GDBobj then
            if PGDBaseObject(pcurrobj)^.IsEntity then
            //if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple then
                                                     result:=true;
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
begin
  if GDBobj then
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
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIResetOGLWNDProc);
  zcRedrawCurrentDrawing;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);

  // убрано, потому что с этим не работают фильтры в инспекторе
  //if GDBobj then
  //  if typeof(PGDBaseObject(pcurrobj)^)=typeof(TMSEditor) then
  //    PMSEditor(pcurrobj)^.CreateUnit(PMSEditor(pcurrobj)^.SavezeUnitsFormat);
end;

procedure _onGetOtherValues(var vsa:TZctnrVectorStrings;const valkey:string;const pcurcontext:pointer;const pcurrobj:pointer;const GDBobj:boolean);
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
             if GDBobj then
             begin
             pentvarext:=pobj^.GetExtension<TVariablesExtender>;
             if ((pobj^.GetObjType=pgdbobjentity(pcurrobj)^.GetObjType)or(pgdbobjentity(pcurrobj)^.GetObjType=0))and({pobj.ou.Instance}pentvarext<>nil) then
             begin
                  pv:={PTEntityUnit(pobj.ou.Instance)}pentvarext.entityunit.FindVariable(valkey);
                  if pv<>nil then
                  begin
                       vv:=pv.data.PTD.GetValueAsString(pv.data.Addr.Instance);
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
procedure _onAfterFreeEditor(sender:tobject);
begin
  if assigned(uzcfcommandline.cmdedit) then
    if uzcfcommandline.cmdedit.IsVisible then
      if uzcfcommandline.cmdedit.CanFocus then
        uzcfcommandline.cmdedit.SetFocus;
end;
function CreateObjInspInstance(FormName:string):TForm;
begin
  result:=tform(TForm.NewInstance);
end;

function ObjInspCopyToClip_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
   if GetCurrentObj=nil then
                             ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut)
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
procedure tdummyclass.ReBuild(sender:TObject;GUIMode:TZMessageID);
begin
       if (GUIMode=ZMsgID_GUIRePrepareObject)then
       begin
         if GetCurrentObj=@MSEditor then  MSEditor.CreateUnit(drawings.GetUnitsFormat);
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.ReBuild;
                                  end;
       end;
end;
procedure tdummyclass.UpdateObjInsp(sender:TObject;GUIMode:TZMessageID);
begin
   if (GUIMode=ZMsgID_GUIActionRedraw)
   or (GUIMode=ZMsgID_GUITimerTick) then
     if assigned(GDBobjinsp)then
                                begin
                                     GDBobjinsp.updateinsp;
                                end;
end;
procedure tdummyclass.SetCurrentObjDefault;
begin
  if (GUIMode=ZMsgID_GUISetDefaultObject) then
    uzcoiregister.SetCurrentObjDefault
end;
procedure tdummyclass.FreEditor;
begin
       if (GUIMode=ZMsgID_GUIFreEditorProc) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.freeeditor;
                                  end
end;
procedure tdummyclass.StoreAndFreeEditor;
begin
       if (GUIMode=ZMsgID_GUIStoreAndFreeEditorProc) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.StoreAndFreeEditor;
                                  end
end;
procedure tdummyclass.ReturnToDefault;
begin
  if (GUIMode=ZMsgID_GUIReturnToDefaultObject) then
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.PStoredObj:=nil;
                                       GDBobjinsp.StoredObjGDBType:=nil;
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

initialization
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','Boolean',@INTFObjInspWhiteBackground);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowHeaders','Boolean',@INTFObjInspShowHeaders);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowSeparator','Boolean',@INTFObjInspShowSeparator);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_OldStyleDraw','Boolean',@INTFObjInspOldStyleDraw);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowFastEditors','Boolean',@INTFObjInspShowFastEditors);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowOnlyHotFastEditors','Boolean',@INTFObjInspShowOnlyHotFastEditors);
INTFObjInspRowHeight.Enable:=LocalRowHeightOverride;
INTFObjInspRowHeight.Value:=LocalRowHeight;
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderEnable','Boolean',@INTFObjInspRowHeight.Enable);
PRowHeight:=@INTFObjInspRowHeight.Value;
PRowHeightOverride:=@INTFObjInspRowHeight.Enable;
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderValue','Integer',@INTFObjInspRowHeight.Value);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_SpaceHeight','Integer',@INTFObjInspSpaceHeight);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowEmptySections','Boolean',@INTFObjInspShowEmptySections);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ButtonSizeReducing','Integer',@INTFObjInspButtonSizeReducing);
SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight:=@INTFObjInspRowHeight;
zcobjectinspector.INTFDefaultControlHeight:=sysparam.notsaved.defaultheight;
ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,rect(0,100,200,600),ZCADFormSetupProc,CreateObjInspInstance,@GDBobjinsp);
PropertyRowName:=rsProperty;
ValueRowName:=rsValue;
DifferentName:=rsDifferent;
onGetOtherValues:=_onGetOtherValues;
onUpdateObjectInInsp:=_onUpdateObjectInInsp;
onNotify:=_onNotify;
onAfterFreeEditor:=_onAfterFreeEditor;

//GDBobjinsp.currpd:=nil;
ZCMsgCallBackInterface.RegisterHandler_PrepareObject(StoreAndSetGDBObjInsp());
//PrepareObject:={TSetGDBObjInsp}(StoreAndSetGDBObjInsp);
//StoreAndSetGDBObjInspProc:=TSetGDBObjInsp(StoreAndSetGDBObjInsp);
//ReStoreGDBObjInspProc:=ReStoreGDBObjInsp;
dummyclass:=tdummyclass.create;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.UpdateObjInsp);
//UpdateObjInspProc:=dummyclass.UpdateObjInsp;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.ReturnToDefault());
//ReturnToDefaultProc:=ReturnToDefault;
//ClrarIfItIsProc:=ClrarIfItIs;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.ReBuild);
//ReBuildProc:=ReBuild;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.SetCurrentObjDefault);
//SetCurrentObjDefaultProc:=SetCurrentObjDefault;
//GetCurrentObjProc:=GetCurrentObj;
GetNameColWidthProc:=GetNameColWidth;
GetOIWidthProc:=GetOIWidth;
//GetPeditorProc:=GetPeditor;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.FreEditor);
//FreEditorProc:=FreEditor;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.StoreAndFreeEditor);
ZCMsgCallBackInterface.RegisterHandler_GetFocusedControl(dummyclass.GetPeditorFocusPriority);
//StoreAndFreeEditorProc:=StoreAndFreeEditor;
CreateZCADCommand(@ObjInspCopyToClip_com,'ObjInspCopyToClip',0,0).overlay:=true;

finalization
  dummyclass.free;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

