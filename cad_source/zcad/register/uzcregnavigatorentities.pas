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

unit uzcregnavigatorentities;
{$INCLUDE zengineconfig.inc}
interface
uses uzcfnavigatorentities,uzcfcommandline,uzbpaths,TypeDescriptors,uzctranslations,Forms,
     varmandef,
     uzeentity,zcobjectinspector,uzcguimanager,
     Types,Controls,Varman,UUnitManager,uzcsysvars,uzcLog;
resourcestring
  rsEntities='Entities';
implementation
procedure ZCADFormSetupProc(Form:TControl);
begin
//  Form:=Form;
end;
initialization
  ZCADGUIManager.RegisterZCADFormInfo('NavigatorEntities',rsEntities,TNavigatorEntities,rect(0,100,200,600),ZCADFormSetupProc,nil,@NavigatorEntities,true);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

