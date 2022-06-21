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
unit zcmultiobjectcreateundocommand;
{$INCLUDE zengineconfig.inc}
interface
uses UGDBOpenArrayOfPV,zeundostack,zebaseundocommands,uzbtypes,
     gzctnrVectorTypes,uzeentity,uzcdrawings;

{DEFINE TCommand  := TGDBMultiCreateCommand}
{DEFINE PTCommand := PTGDBMultiCreateCommand}
{DEFINE TData     := GDBObjOpenArrayOfPV}


type
generic TGMultiObjectProcessCommand<_LT> =object(TCustomChangeCommand)
                                      DoData,UnDoData:tmethod;
                                      ObjArray:_LT;
                                      FreeArray:boolean;
                                      public
                                      constructor Assign(const _dodata,_undodata:tmethod;const objcount:Integer);
                                      //procedure StoreUndoData(var _undodata:_T);virtual;
                                      procedure AddObject(PObject:PGDBaseObject);virtual;

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      destructor Done;virtual;
                                  end;

PTGDBMultiCreateCommand=^TGDBMultiCreateCommand;
TGDBMultiCreateCommand=specialize TGMultiObjectProcessCommand<GDBObjOpenArrayOfPV>;


function CreateMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTGDBMultiCreateCommand;overload;
function PushMultiObjectCreateCommand(var us:TZctnrVectorUndoCommands; var dodata,undodata:tmethod;objcount:integer):PTGDBMultiCreateCommand;overload;


implementation
constructor TGMultiObjectProcessCommand.Assign(const _dodata,_undodata:tmethod;const objcount:Integer);
begin
     DoData:=_DoData;
     UnDoData:=_UnDoData;
     self.ObjArray.init(objcount);
     FreeArray:={false}true;
end;
procedure TGMultiObjectProcessCommand.AddObject(PObject:PGDBaseObject);
var
   p:pointer;
begin
     p:=PObject;
     objarray.PushBackData(P);
end;
procedure TGMultiObjectProcessCommand.UnDo;
type
    TCangeMethod=procedure(const data:GDBASEOBJECT)of object;
    //PTMethod=^TMethod;
var
  p:PGDBASEOBJECT;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(UnDoData)(p^);
        if FreeArray then
                             PGDBObjEntity(p)^.YouChanged(drawings.GetCurrentDWG^);
       p:=ObjArray.iterate(ir);
  until p=nil;
  FreeArray:=not FreeArray;
end;
procedure TGMultiObjectProcessCommand.Comit;
type
    TCangeMethod=procedure(const data:GDBASEOBJECT)of object;
    //PTMethod=^TMethod;
var
  p:PGDBASEOBJECT;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(DoData)(p^);
        if FreeArray then
                             PGDBObjEntity(p)^.YouChanged(drawings.GetCurrentDWG^);
       p:=ObjArray.iterate(ir);
  until p=nil;
  FreeArray:=not FreeArray;
end;
destructor TGMultiObjectProcessCommand.Done;
begin
     inherited;
     if {not} FreeArray then
                          ObjArray.done
                        else
                          begin
                            ObjArray.clear;
                            ObjArray.done;
                          end;
end;

function {TZctnrVectorUndoCommands.}CreateMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTGDBMultiCreateCommand;overload;
begin
     Getmem(result,sizeof(TGDBMultiCreateCommand));
     result^.Assign(dodata,undodata,objcount);
end;
function {TZctnrVectorUndoCommands.}PushMultiObjectCreateCommand(var us:TZctnrVectorUndoCommands; var dodata,undodata:tmethod;objcount:integer):PTGDBMultiCreateCommand;overload;
begin
  result:=CreateMultiObjectCreateCommand(dodata,undodata,objcount);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;

end.
