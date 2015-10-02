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
uses zcobjectinspector,zcguimanager,zcadstrconsts,Types,Controls,
  UGDBDescriptor,Varman,UUnitManager,zcadsysvars,gdbasetypes,sysinfo;
implementation
procedure ZCADFormSetupProc(Form:TControl);
var
  pint:PGDBInteger;
begin
  SetGDBObjInsp(gdb.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;
  //pint:=SavedUnit.FindValue('VIEW_ObjInspV');
  SetNameColWidth(Form.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
  if assigned(pint)then
                       SetNameColWidth(pint^);
end;
initialization
{$IFDEF DEBUGINITSECTION}LogOut('zcregisterobjectinspector.initialization');{$ENDIF}
units.CreateExtenalSystemVariable('INTF_ObjInsp_WhiteBackground','GDBBoolean',@INTFObjInspWhiteBackground);
units.CreateExtenalSystemVariable('INTF_ObjInsp_ShowHeaders','GDBBoolean',@INTFObjInspShowHeaders);
units.CreateExtenalSystemVariable('INTF_ObjInsp_ShowSeparator','GDBBoolean',@INTFObjInspShowSeparator);
units.CreateExtenalSystemVariable('INTF_ObjInsp_OldStyleDraw','GDBBoolean',@INTFObjInspOldStyleDraw);
units.CreateExtenalSystemVariable('INTF_ObjInsp_ShowFastEditors','GDBBoolean',@INTFObjInspShowFastEditors);
units.CreateExtenalSystemVariable('INTF_ObjInsp_ShowOnlyHotFastEditors','GDBBoolean',@INTFObjInspShowOnlyHotFastEditors);
units.CreateExtenalSystemVariable('INTF_ObjInsp_RowHeight_OverriderEnable','GDBBoolean',@INTFObjInspRowHeight.Enable);
units.CreateExtenalSystemVariable('INTF_ObjInsp_RowHeight_OverriderValue','GDBInteger',@INTFObjInspRowHeight.Value);
units.CreateExtenalSystemVariable('INTF_ObjInsp_SpaceHeight','GDBInteger',@INTFObjInspSpaceHeight);
units.CreateExtenalSystemVariable('INTF_ObjInsp_ShowEmptySections','GDBBoolean',@INTFObjInspShowEmptySections);
SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight:=@INTFObjInspRowHeight;
zcobjectinspector.INTFDefaultControlHeight:=sysparam.defaultheight;
ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,rect(0,100,200,600),ZCADFormSetupProc,@GDBobjinsp);
PropertyRowName:=rsProperty;
ValueRowName:=rsValue;
DifferentName:=rsDifferent;
finalization
end.

