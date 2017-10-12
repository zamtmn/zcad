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

unit uzcregnavigatordevices;
{$INCLUDE def.inc}
interface
uses uzcfnavigatordevices,uzcfcommandline,uzbpaths,TypeDescriptors,uzctranslations,uzcshared,Forms,
     uzbtypes,varmandef,
     uzeentity,zcobjectinspector,uzcguimanager,
     Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,uzcsysinfo,LazLogger;
implementation
procedure ZCADFormSetupProc(Form:TControl);
{var
  pint:PGDBInteger;}
begin
  {SetGDBObjInsp(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,nil);
  SetCurrentObjDefault;
  SetNameColWidth(Form.Width div 2);
  pint:=SavedUnit.FindValue('VIEW_ObjInspSubV');
  if assigned(pint)then
                       SetNameColWidth(pint^);
  GDBobjinsp.Align:=alClient;
  GDBobjinsp.BorderStyle:=bsNone;
  GDBobjinsp.Parent:=tform(Form);}
end;
initialization
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorDevices','Navigator(Devices)',TNavigatorDevices,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorDevices,true);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

