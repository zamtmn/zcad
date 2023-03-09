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
unit gzundoCmdChgMethods;
interface
uses
  zeundostack,zebaseundocommands;

type
  //команда вызывает для Do и UnDo 2 разных метода с одними данными
  generic GUCmdChgMethods<T> =class(TUCmdBase)
    private
      type
        TCangeMethod=procedure(const data:T)of object;
        TAfterUndoProc=procedure(const AUndoMethod:TMethod)of object;
      var
        Data:T;
        DoMethod,UnDoMethod:tmethod;
        AfterUndoProc:TAfterUndoProc;
        procedure AfterDo;
    public
        constructor Create(var AData:T;ADoMethod,AUndoMethod:TMethod;const AAfterUndoProc:TAfterUndoProc);
        constructor CreateAndPush(var AData:T;ADoMethod,AUndoMethod:TMethod;var us:TZctnrVectorUndoCommands;const AAfterUndoProc:TAfterUndoProc);

        procedure UnDo;override;
        procedure Comit;override;
  end;

implementation

constructor GUCmdChgMethods.CreateAndPush(var AData:T;ADoMethod,AUndoMethod:TMethod;var us:TZctnrVectorUndoCommands;const AAfterUndoProc:TAfterUndoProc);
begin
  Create(AData,ADoMethod,AUndoMethod,AAfterUndoProc);
  us.PushBackData(self);
  inc(us.CurrentCommand);
end;

constructor GUCmdChgMethods.Create(var AData:T;ADoMethod,AUndoMethod:TMethod;const AAfterUndoProc:TAfterUndoProc);
begin
  AfterUndoProc:=AAfterUndoProc;
  Data:=AData;
  DoMethod:=ADoMethod;
  UndoMethod:=AUndoMethod;
end;

procedure GUCmdChgMethods.UnDo;
begin
  TCangeMethod(UnDoMethod)(Data);
  AfterDo;
end;

procedure GUCmdChgMethods.Comit;
begin
  TCangeMethod(DoMethod)(Data);
  AfterDo;
end;

procedure GUCmdChgMethods.AfterDo;
begin
  if assigned(AfterUndoProc) then
    AfterUndoProc(undomethod);
end;

end.
