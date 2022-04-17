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
unit zcmultiobjectchangeundocommand;
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVector,zeundostack,zebaseundocommands,
     gzctnrVectorTypes,uzegeometrytypes,uzeentity,uzcdrawings;

{DEFINE TCommand  := TGDBTransformChangeCommand}
{DEFINE PTCommand := PTGDBTransformChangeCommand}
{DEFINE TData     := DMatrix4D}

type
TtmethodVector=specialize GZVector<tmethod>;
    generic TGMultiObjectChangeCommand<_T> =object(TCustomChangeCommand)
                                          DoData,UnDoData:_T;
                                          ObjArray:{GDBOpenArrayOfData}TtmethodVector;
                                          public
                                          constructor Assign(const _dodata,_undodata:_T;const objcount:Integer);
                                          //procedure StoreUndoData(var _undodata:_T);virtual;
                                          procedure AddMethod(method:tmethod);virtual;

                                          procedure UnDo;virtual;
                                          procedure Comit;virtual;
                                          destructor Done;virtual;
                                      end;


PTGDBTransformChangeCommand=^TGDBTransformChangeCommand;
TGDBTransformChangeCommand=specialize TGMultiObjectChangeCommand<DMatrix4D>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;

{IFDEF CLASSDECLARATION}
function CreateTGMultiObjectChangeCommand(var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
function PushCreateTGMultiObjectChangeCommand(var us:TZctnrVectorUndoCommands; var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
{ENDIF}

implementation

constructor TGMultiObjectChangeCommand.Assign(const _dodata,_undodata:_T;const objcount:Integer);
begin
     DoData:=_DoData;
     UnDoData:=_UnDoData;
     self.ObjArray.init(objcount{,sizeof(tmethod)});
end;
procedure TGMultiObjectChangeCommand.AddMethod(method:tmethod);
begin
     objarray.PushBackData(method);
end;
{procedure TGMultiObjectChangeCommand.StoreUndoData(var _undodata:_T);
begin
     UnDoData:=_undodata;
end;}
procedure TGMultiObjectChangeCommand.UnDo;
type
    TCangeMethod=procedure(const data:_T)of object;
    PTMethod=^TMethod;
var
  p:PTMethod;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(p^)(UnDoData);
        PGDBObjEntity(p^.Data)^.YouChanged(drawings.GetCurrentDWG^);
        //PGDBObjSubordinated(p^.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(p^.Data),PGDBObjSubordinated(p^.Data)^.bp.PSelfInOwnerArray);

       p:=ObjArray.iterate(ir);
  until p=nil;
end;
procedure TGMultiObjectChangeCommand.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
    PTMethod=^TMethod;
var
  p:PTMethod;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(p^)(DoData);
        PGDBObjEntity(p^.Data)^.YouChanged(drawings.GetCurrentDWG^);
        //PGDBObjSubordinated(p^.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(p^.Data),PGDBObjSubordinated(p^.Data)^.bp.PSelfInOwnerArray);

       p:=ObjArray.iterate(ir);
  until p=nil;
end;

destructor TGMultiObjectChangeCommand.Done;
begin
     inherited;
     ObjArray.done;
end;


function {TZctnrVectorUndoCommands.}CreateTGMultiObjectChangeCommand(var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
begin
     Getmem(result,sizeof(TGDBTransformChangeCommand));
     result^.Assign(data,undodata,objcount);
end;
function {TZctnrVectorUndoCommands.}PushCreateTGMultiObjectChangeCommand(var us:TZctnrVectorUndoCommands; var data,undodata:DMatrix4D;const objcount:Integer):PTGDBTransformChangeCommand;overload;
begin
  result:=CreateTGMultiObjectChangeCommand(data,undodata,objcount);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;
end.
