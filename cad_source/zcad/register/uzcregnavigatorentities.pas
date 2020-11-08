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

unit uzcregnavigatorentities;
{$INCLUDE def.inc}
interface
uses uzcfnavigatorentities,uzcfcommandline,uzbpaths,TypeDescriptors,uzctranslations,Forms,
     uzbtypes,varmandef,
     uzeentity,zcobjectinspector,uzcguimanager,
     Types,Controls,uzcdrawings,Varman,UUnitManager,uzcsysvars,uzcsysinfo,LazLogger;
resourcestring
  rsEntities='Entities';
implementation
procedure ZCADFormSetupProc(Form:TControl);
begin
  Form:=Form;
end;
initialization
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorEntities',rsEntities,TNavigatorEntities,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorEntities,true);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

