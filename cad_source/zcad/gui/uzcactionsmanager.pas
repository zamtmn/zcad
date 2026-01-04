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

unit uzcActionsManager;
{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,SysUtils,ActnList,
  //LResources,LazUTF8,Controls,Graphics,
  //gzctnrSTL,uzctnrVectorBytesStream,
  {uzbpaths,uzbstrproc,}uzcLog;
var
  Actions:TActionList;
function StandartActions:TActionList;
implementation
function StandartActions:TActionList;
begin
  if not Assigned(Actions) then
      Actions:=TActionList.Create(nil);
  Result:=Actions;
end;

initialization
  Actions:=nil;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if Assigned(Actions) then
    Actions.Destroy;
end.

