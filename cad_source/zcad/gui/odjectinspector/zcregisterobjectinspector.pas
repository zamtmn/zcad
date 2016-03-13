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

unit zcregisterobjectinspector;
{$INCLUDE def.inc}
interface
uses paths,TypeDescriptors,intftranslations,uzcshared,Forms,zcadinterface,GDBRoot,gdbase,UGDBDrawingdef,gdbdrawcontext,UGDBStringArray,varmandef,ugdbsimpledrawing,GDBEntity,uzcenitiesvariablesextender,zcobjectinspector,zcguimanager,uzcstrconsts,Types,Controls,
  UGDBDescriptor,Varman,UUnitManager,uzcsysvars,gdbasetypes,uzcsysinfo;
implementation
procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PGDBInteger;
begin
  SetGDBObjInsp(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;
  //pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  SetNameColWidth(Form.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
  if assigned(pint)then
                       SetNameColWidth(pint^);
  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=tform(Form);
end;
procedure _onNotify(const pcurcontext:gdbpointer);
begin
  if pcurcontext<>nil then
  begin
       PTDrawingDef(pcurcontext).ChangeStampt(true);
  end;
end;
procedure _onUpdateObjectInInsp(const EDContext:TEditorContext;const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:gdbpointer;const pcurrobj:GDBPointer;const GDBobj:GDBBoolean);
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
  if assigned(resetoglwndproc) then resetoglwndproc;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  if assigned(UpdateVisibleProc) then UpdateVisibleProc;
end;

procedure _onGetOtherValues(var vsa:GDBGDBStringArray;const valkey:GDBString;const pcurcontext:gdbpointer;const pcurrobj:GDBPointer;const GDBobj:GDBBoolean);
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

                       vsa.addnodouble(@vv);
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
  if assigned(uzcshared.cmdedit) then
       if uzcshared.cmdedit.IsVisible then
                                       uzcshared.cmdedit.SetFocus;
end;

initialization
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_WhiteBackground','GDBBoolean',@INTFObjInspWhiteBackground);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowHeaders','GDBBoolean',@INTFObjInspShowHeaders);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowSeparator','GDBBoolean',@INTFObjInspShowSeparator);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_OldStyleDraw','GDBBoolean',@INTFObjInspOldStyleDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowFastEditors','GDBBoolean',@INTFObjInspShowFastEditors);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_ShowOnlyHotFastEditors','GDBBoolean',@INTFObjInspShowOnlyHotFastEditors);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'INTF_ObjInsp_RowHeight_OverriderEnable','GDBBoolean',@INTFObjInspRowHeight.Enable);
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
StoreAndSetGDBObjInspProc:=TStoreAndSetGDBObjInsp(StoreAndSetGDBObjInsp);
ReStoreGDBObjInspProc:=ReStoreGDBObjInsp;
UpdateObjInspProc:=UpdateObjInsp;
ReturnToDefaultProc:=ReturnToDefault;
ClrarIfItIsProc:=ClrarIfItIs;
ReBuildProc:=ReBuild;
SetCurrentObjDefaultProc:=SetCurrentObjDefault;
GetCurrentObjProc:=GetCurrentObj;
GetNameColWidthProc:=GetNameColWidth;
CreateObjInspInstanceProc:=CreateObjInspInstance;
GetPeditorProc:=GetPeditor;
FreEditorProc:=FreEditor;
StoreAndFreeEditorProc:=StoreAndFreeEditor;

finalization
end.

