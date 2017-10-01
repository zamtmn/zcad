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

unit uzcoiregister;
{$INCLUDE def.inc}
interface
uses Clipbrd,sysutils,uzccommandsabstract,uzcfcommandline,uzcutils,uzbpaths,TypeDescriptors,uzctranslations,uzcshared,Forms,uzcinterface,uzeroot,
     uzbtypes,uzedrawingdef,uzgldrawcontext,uzctnrvectorgdbstring,varmandef,uzedrawingsimple,
     uzeentity,uzcenitiesvariablesextender,zcobjectinspector,uzcguimanager,uzcstrconsts,
     gzctnrvectortypes,Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,
     uzcoimultiobjects,uzccommandsimpl,uzbtypesbase,uzcsysinfo,LazLogger;
type
  tdummyclass=class
    procedure UpdateObjInsp(sender:TObject;GUIMode:TZMessageID);
  end;
var
  INTFObjInspRowHeight:TGDBIntegerOverrider;
  dummyclass:tdummyclass;
implementation
procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PGDBInteger;
begin
  SetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;
  //pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  SetNameColWidth(Form.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
  if assigned(pint)then
                       SetNameColWidth(pint^);
  pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  if assigned(pint)then
                       GDBobjinsp.NameColumnWidthCorrector.LastClientWidth:=pint^;
  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=tform(Form);
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
  //if assigned(resetoglwndproc) then resetoglwndproc;
  zcRedrawCurrentDrawing;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
end;

procedure _onGetOtherValues(var vsa:TZctnrVectorGDBString;const valkey:string;const pcurcontext:pointer;const pcurrobj:pointer;const GDBobj:boolean);
var
  pentvarext:PTVariablesExtender;
  pobj:pGDBObjEntity;
  ir:itrec;
  pv:pvardesk;
  vv:gdbstring;
begin
  if (valkey<>'')and(pcurcontext<>nil) then
  begin
       pobj:=PTSimpleDrawing(pcurcontext).GetCurrentROOT.ObjArray.beginiterate(ir);
       if pobj<>nil then
       repeat
             if GDBobj then
             begin
             pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
             if ((pobj^.GetObjType=pgdbobjentity(pcurrobj)^.GetObjType)or(pgdbobjentity(pcurrobj)^.GetObjType=0))and({pobj.ou.Instance}pentvarext<>nil) then
             begin
                  pv:={PTObjectUnit(pobj.ou.Instance)}pentvarext^.entityunit.FindVariable(valkey);
                  if pv<>nil then
                  begin
                       vv:=pv.data.PTD.GetValueAsString(pv.data.Instance);
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
function IsCurrObjInUndoContext(_GDBobj:boolean;_pcurrobj:pointer):boolean;
begin
  result:=false;
  if _GDBobj then
    if PGDBaseObject(_pcurrobj)^.IsEntity then
      //if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple then
      result:=true;
end;

function CreateObjInspInstance:TForm;
begin
     GDBobjinsp:=TGDBObjInsp.Create(Application);
     //result:=GDBobjinsp;
     result:=tform(TForm.NewInstance);
     GDBobjinsp._IsCurrObjInUndoContext:=IsCurrObjInUndoContext;
end;

function ObjInspCopyToClip_com(operands:TCommandOperands):TCommandResult;
begin
   if assigned(GetCurrentObjProc)then
   begin
   if GetCurrentObjProc=nil then
                             ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut)
                         else
                             begin
                                  if uppercase(Operands)='VAR' then
                                                                   clipbrd.clipboard.AsText:={Objinsp.}currpd.ValKey
                             else if uppercase(Operands)='LVAR' then
                                                                   clipbrd.clipboard.AsText:='@@['+{Objinsp.}currpd.ValKey+']'
                             else if uppercase(Operands)='VALUE' then
                                                                   clipbrd.clipboard.AsText:={Objinsp.}currpd.Value;
                                  {Objinsp.}currpd:=nil;
                             end;
   end;
   result:=cmd_ok;
end;
procedure ReBuild;
begin
       if assigned(GetCurrentObjProc)then
         if GetCurrentObjProc=@MSEditor then  MSEditor.CreateUnit(drawings.GetUnitsFormat);
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.ReBuild;
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


initialization
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','GDBBoolean',@INTFObjInspWhiteBackground);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowHeaders','GDBBoolean',@INTFObjInspShowHeaders);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowSeparator','GDBBoolean',@INTFObjInspShowSeparator);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_OldStyleDraw','GDBBoolean',@INTFObjInspOldStyleDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowFastEditors','GDBBoolean',@INTFObjInspShowFastEditors);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowOnlyHotFastEditors','GDBBoolean',@INTFObjInspShowOnlyHotFastEditors);
INTFObjInspRowHeight.Enable:=LocalRowHeightOverride;
INTFObjInspRowHeight.Value:=LocalRowHeight;
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderEnable','GDBBoolean',@INTFObjInspRowHeight.Enable);
PRowHeight:=@INTFObjInspRowHeight.Value;
PRowHeightOverride:=@INTFObjInspRowHeight.Enable;
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderValue','GDBInteger',@INTFObjInspRowHeight.Value);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_SpaceHeight','GDBInteger',@INTFObjInspSpaceHeight);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowEmptySections','GDBBoolean',@INTFObjInspShowEmptySections);
SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight:=@INTFObjInspRowHeight;
zcobjectinspector.INTFDefaultControlHeight:=sysparam.defaultheight;
ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,rect(0,100,200,600),ZCADFormSetupProc,CreateObjInspInstance,@GDBobjinsp);
PropertyRowName:=rsProperty;
ValueRowName:=rsValue;
DifferentName:=rsDifferent;
onGetOtherValues:=_onGetOtherValues;
onUpdateObjectInInsp:=_onUpdateObjectInInsp;
onNotify:=_onNotify;
onAfterFreeEditor:=_onAfterFreeEditor;

currpd:=nil;
SetGDBObjInspProc:=TSetGDBObjInsp(SetGDBObjInsp);
//StoreAndSetGDBObjInspProc:=TSetGDBObjInsp(StoreAndSetGDBObjInsp);
ReStoreGDBObjInspProc:=ReStoreGDBObjInsp;
dummyclass:=tdummyclass.create;
ZCMsgCallBackInterface.RegisterHandler_GUIAction(dummyclass.UpdateObjInsp);
//UpdateObjInspProc:=dummyclass.UpdateObjInsp;
ReturnToDefaultProc:=ReturnToDefault;
ClrarIfItIsProc:=ClrarIfItIs;
ReBuildProc:=ReBuild;
SetCurrentObjDefaultProc:=SetCurrentObjDefault;
GetCurrentObjProc:=GetCurrentObj;
GetNameColWidthProc:=GetNameColWidth;
GetOIWidthProc:=GetOIWidth;
GetPeditorProc:=GetPeditor;
FreEditorProc:=FreEditor;
StoreAndFreeEditorProc:=StoreAndFreeEditor;
CreateCommandFastObjectPlugin(@ObjInspCopyToClip_com,'ObjInspCopyToClip',0,0).overlay:=true;

finalization
  dummyclass.free;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

