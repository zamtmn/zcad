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
{$MODE OBJFPC}
unit zcobjectchangeundocommand;
{$INCLUDE def.inc}
interface
uses memman,UGDBOpenArrayOfPV,ugdbopenarrayofucommands,zebaseundocommands,gdbase,gdbasetypes,GDBEntity;

type
PTGDBRTModifyChangeCommand=^TGDBRTModifyChangeCommand;
TGDBRTModifyChangeCommand=specialize TGObjectChangeCommand<TRTModifyData>;

{DEFINE TCommand  := TGDBRTModifyChangeCommand}
{DEFINE PTCommand := PTGDBRTModifyChangeCommand}
{DEFINE TData     := TRTModifyData}
  {I TGObjectChangeCommandIMPL.inc}

function CreateTGObjectChangeCommand(var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
function PushCreateTGObjectChangeCommand(var us:GDBObjOpenArrayOfUCommands; var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;


implementation

function {GDBObjOpenArrayOfUCommands.}CreateTGObjectChangeCommand(var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{9FE25B12-DEE0-410A-BDCD-7E69A41E4389}',{$ENDIF}result,sizeof(TGDBRTModifyChangeCommand));
     result^.Assign(data,_method);
end;
function {GDBObjOpenArrayOfUCommands.}PushCreateTGObjectChangeCommand(var us:GDBObjOpenArrayOfUCommands; var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
begin
  result:=CreateTGObjectChangeCommand(data,_method);
  us.add(@result);
  inc(us.CurrentCommand);
end;

end.
