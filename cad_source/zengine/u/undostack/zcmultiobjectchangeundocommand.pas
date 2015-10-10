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
unit zcmultiobjectchangeundocommand;
{$INCLUDE def.inc}
interface
uses memman,zeundostack,zebaseundocommands,gdbase,gdbasetypes,GDBEntity,UGDBDescriptor;

{DEFINE TCommand  := TGDBTransformChangeCommand}
{DEFINE PTCommand := PTGDBTransformChangeCommand}
{DEFINE TData     := DMatrix4D}

type
PTGDBTransformChangeCommand=^TGDBTransformChangeCommand;
TGDBTransformChangeCommand=specialize TGMultiObjectChangeCommand<DMatrix4D>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;

{IFDEF CLASSDECLARATION}
function CreateTGMultiObjectChangeCommand(var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
function PushCreateTGMultiObjectChangeCommand(var us:GDBObjOpenArrayOfUCommands; var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
{ENDIF}

implementation

function {GDBObjOpenArrayOfUCommands.}CreateTGMultiObjectChangeCommand(var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{2FFA68C4-3209-4CB4-8DD1-28A818A795D1}',{$ENDIF}result,sizeof(DMatrix4D));
     result^.Assign(data,undodata,objcount);
end;
function {GDBObjOpenArrayOfUCommands.}PushCreateTGMultiObjectChangeCommand(var us:GDBObjOpenArrayOfUCommands; var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
begin
  result:=CreateTGMultiObjectChangeCommand(data,undodata,objcount);
  us.add(@result);
  inc(us.CurrentCommand);
end;
end.
