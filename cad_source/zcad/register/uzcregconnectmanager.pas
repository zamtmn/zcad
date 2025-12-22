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

unit uzcregconnectmanager;
{$INCLUDE zengineconfig.inc}
interface
uses
  Types,Controls,
  uzcguimanager,
  synchMain;

implementation

procedure formSynchsSetupProc(Form:TControl);
begin
 //тут можно чтото настроить
end;

initialization
  ZCADGUIManager.RegisterZCADFormInfo('formSynchs','formSynchs',TformSynch,rect(0,100,200,600),formSynchsSetupProc,nil,@formSynch,true);
finalization
end.

