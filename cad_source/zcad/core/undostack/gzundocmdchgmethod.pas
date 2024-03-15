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
unit gzUndoCmdChgMethod;
interface
uses zeundostack,zebaseundocommands,uzeentity;

type
  //команда вызывает для Do и UnDo один метод с разными данными
  generic GUCmdChgMethod<T> =class(TUCmdBase)
     private
       type
         TCangeMethod=procedure(const data:T)of object;
         TAfterUndoProc=procedure(const AUndoMethod:TMethod)of object;
       var
         DoData,UnDoData:T;
         method:TMethod;
         AfterUndoProc:TAfterUndoProc;
         procedure AfterDo;
     public
         constructor Create(var AData:T;AMethod:tmethod;const AAfterUndoProc:TAfterUndoProc);
         constructor CreateAndPush(var AData:T;AMethod:TMethod;var us:TZctnrVectorUndoCommands;const AAfterUndoProc:TAfterUndoProc);
         procedure StoreUndoData(var AUndoData:T);

         procedure UnDo;override;
         procedure Comit;override;
   end;

implementation
//uses uzcdrawings;

constructor GUCmdChgMethod.CreateAndPush(var AData:T;AMethod:TMethod;var us:TZctnrVectorUndoCommands;const AAfterUndoProc:TAfterUndoProc);
begin
  Create(AData,AMethod,AAfterUndoProc);
  us.PushBackData(self);
  inc(us.CurrentCommand);
end;

constructor GUCmdChgMethod.Create(var AData:T;AMethod:tmethod;const AAfterUndoProc:TAfterUndoProc);
begin
  DoData:=AData;
  method:=AMethod;
  AfterUndoProc:=AAfterUndoProc;
end;
procedure GUCmdChgMethod.StoreUndoData(var AUndoData:T);
begin
  UnDoData:=AUndoData;
end;
procedure GUCmdChgMethod.UnDo;
begin
  TCangeMethod(method)(UnDoData);
  AfterDo;
end;
procedure GUCmdChgMethod.Comit;
begin
  TCangeMethod(method)(DoData);
  AfterDo;
end;
procedure GUCmdChgMethod.AfterDo;
begin
  if Assigned(AfterUndoProc)then
    AfterUndoProc(method);
  //PGDBObjEntity(method.Data)^.YouChanged(drawings.GetCurrentDWG^);
end;

end.
