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
unit gzundoCmdChgMethod;
interface
uses zeundostack,zebaseundocommands,uzeentity;

type
  generic GUCmdChgMethod<T> =class(TCustomChangeCommand)
     private
       type
         TCangeMethod=procedure(const data:T)of object;
       var
         DoData,UnDoData:T;
         method:TMethod;
         procedure AfterDo;
     public
         constructor Create(var AData:T;AMethod:tmethod);
         constructor CreateAndPush(var AData:T;AMethod:TMethod;var us:TZctnrVectorUndoCommands);
         procedure StoreUndoData(var AUndoData:T);

         procedure UnDo;override;
         procedure Comit;override;
   end;

implementation
uses uzcdrawings;

constructor GUCmdChgMethod.CreateAndPush(var AData:T;AMethod:TMethod;var us:TZctnrVectorUndoCommands);
begin
  Create(AData,AMethod);
  us.PushBackData(self);
  inc(us.CurrentCommand);
end;

constructor GUCmdChgMethod.Create(var AData:T;AMethod:tmethod);
begin
  AData:=AData;
  method:=AMethod;
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
  PGDBObjEntity(method.Data)^.YouChanged(drawings.GetCurrentDWG^);
end;

end.
