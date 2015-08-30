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
  UGDBDescriptor,Varman,zcadsysvars,gdbasetypes;
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
ZCADGUIManager.RegisterZCADFormInfo('ObjectInspector',rsGDBObjinspWndName,TGDBobjinsp,rect(0,100,200,600),ZCADFormSetupProc,@GDBobjinsp);
finalization
end.

