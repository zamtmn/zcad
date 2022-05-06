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
{$MODE OBJFPC}{$H+}
unit zcobjectchangeundocommand;
{$INCLUDE zengineconfig.inc}
interface
uses zeundostack,zebaseundocommands,uzbtypes,uzeentity,uzglviewareadata;

type

    generic TGObjectChangeCommand<_T> =object(TCustomChangeCommand)
                                          {type
                                              TCangeMethod=procedure(data:_T)of object;}
                                          private
                                          DoData,UnDoData:_T;
                                          method:tmethod;
                                          public
                                          constructor Assign(var _dodata:_T;_method:tmethod);
                                          procedure StoreUndoData(var _undodata:_T);virtual;

                                          procedure UnDo;virtual;
                                          procedure Comit;virtual;
                                          //procedure ComitFromObj;virtual;
                                          //function GetDataTypeSize:PtrInt;virtual;
                                      end;

PTGDBRTModifyChangeCommand=^TGDBRTModifyChangeCommand;
TGDBRTModifyChangeCommand=specialize TGObjectChangeCommand<TRTModifyData>;

{DEFINE TCommand  := TGDBRTModifyChangeCommand}
{DEFINE PTCommand := PTGDBRTModifyChangeCommand}
{DEFINE TData     := TRTModifyData}
  {I TGObjectChangeCommandIMPL.inc}

function CreateTGObjectChangeCommand(var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
function PushCreateTGObjectChangeCommand(var us:TZctnrVectorUndoCommands; var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;


implementation
uses uzcdrawings;

constructor TGObjectChangeCommand.Assign(var _dodata:_T;_method:tmethod);
begin
     DoData:=_DoData;
     method:=_method;
end;
procedure TGObjectChangeCommand.StoreUndoData(var _undodata:_T);
begin
     UnDoData:=_undodata;
end;
procedure TGObjectChangeCommand.UnDo;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(method)(UnDoData);
     PGDBObjEntity(method.Data)^.YouChanged(drawings.GetCurrentDWG^);
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;
procedure TGObjectChangeCommand.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(method)(DoData);
     PGDBObjEntity(method.Data)^.YouChanged(drawings.GetCurrentDWG^);
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;


function {GDBObjOpenArrayOfUCommands.}CreateTGObjectChangeCommand(var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
begin
     Getmem(result,sizeof(TGDBRTModifyChangeCommand));
     result^.Assign(data,_method);
end;
function {GDBObjOpenArrayOfUCommands.}PushCreateTGObjectChangeCommand(var us:TZctnrVectorUndoCommands; var data:TRTModifyData;_method:tmethod):PTGDBRTModifyChangeCommand;overload;
begin
  result:=CreateTGObjectChangeCommand(data,_method);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;

end.
