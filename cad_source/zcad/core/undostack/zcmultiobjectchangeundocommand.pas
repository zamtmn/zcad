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
{$MODE OBJFPC}{$H+}
unit zcmultiobjectchangeundocommand;
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVector,zeundostack,zebaseundocommands,
     gzctnrVectorTypes,uzegeometrytypes,uzeentity,uzcdrawings;

{DEFINE TCommand  := TGDBTransformChangeCommand}
{DEFINE PTCommand := PTGDBTransformChangeCommand}
{DEFINE TData     := DMatrix4d}

type
TtmethodVector=specialize GZVector<tmethod>;
    generic TGMultiObjectChangeCommand<_T> =class(TUCmdBase)
                                          DoData,UnDoData:_T;
                                          ObjArray:{GDBOpenArrayOfData}TtmethodVector;
                                          public
                                          constructor Create(const _dodata,_undodata:_T;const objcount:Integer);
                                          //procedure StoreUndoData(var _undodata:_T);virtual;
                                          procedure AddMethod(method:tmethod);virtual;

                                          procedure UnDo;override;
                                          procedure Comit;override;
                                          destructor Destroy;override;
                                      end;


PTGDBTransformChangeCommand=^TGDBTransformChangeCommand;
TGDBTransformChangeCommand=specialize TGMultiObjectChangeCommand<TzeTypedMatrix4d>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;

{IFDEF CLASSDECLARATION}
function CreateTGMultiObjectChangeCommand(const data,undodata:TzeTypedMatrix4d;const objcount:Integer):TGDBTransformChangeCommand;overload;
function PushCreateTGMultiObjectChangeCommand(const us:PTZctnrVectorUndoCommands; const data,undodata:TzeTypedMatrix4d;const objcount:Integer):TGDBTransformChangeCommand;overload;
{ENDIF}

implementation

constructor TGMultiObjectChangeCommand.Create(const _dodata,_undodata:_T;const objcount:Integer);
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

destructor TGMultiObjectChangeCommand.Destroy;
begin
     inherited;
     ObjArray.done;
end;


function {TZctnrVectorUndoCommands.}CreateTGMultiObjectChangeCommand(const data,undodata:TzeTypedMatrix4d;const objcount:Integer):TGDBTransformChangeCommand;overload;
begin
     //Getmem(result,sizeof(TGDBTransformChangeCommand));
     result:=TGDBTransformChangeCommand.Create(data,undodata,objcount);
end;
function {TZctnrVectorUndoCommands.}PushCreateTGMultiObjectChangeCommand(const us:PTZctnrVectorUndoCommands; const data,undodata:TzeTypedMatrix4d;const objcount:Integer):TGDBTransformChangeCommand;overload;
begin
  result:=CreateTGMultiObjectChangeCommand(data,undodata,objcount);
  us^.PushBackData(result);
  inc(us^.CurrentCommand);
end;
end.
