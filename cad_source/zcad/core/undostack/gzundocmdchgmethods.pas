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
  zeundostack,zebaseundocommands,
  uzeentity,uzgldrawcontext,uzcdrawings;

type
  generic GUCmdChgMethods<T> =class(TCustomChangeCommand)
    private
      type
        TCangeMethod=procedure(const data:T)of object;
      var
        AfterAction:Boolean;
        AutoProcessGDB:Boolean;
        Data:T;
        DoMethod,UnDoMethod:tmethod;
        procedure AfterDo;
    public
        constructor Create(var AData:T;ADoMethod,AUndoMethod:TMethod);
        constructor CreateAndPush(var AData:T;ADoMethod,AUndoMethod:TMethod;var us:TZctnrVectorUndoCommands);

        procedure UnDo;override;
        procedure Comit;override;
  end;

implementation

constructor GUCmdChgMethods.CreateAndPush(var AData:T;ADoMethod,AUndoMethod:TMethod;var us:TZctnrVectorUndoCommands);
begin
  Create(AData,ADoMethod,AUndoMethod);
  us.PushBackData(self);
  inc(us.CurrentCommand);
end;

constructor GUCmdChgMethods.Create(var AData:T;ADoMethod,AUndoMethod:TMethod);
begin
  AutoProcessGDB:=True;
  AfterAction:=True;
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
var
  DC:TDrawContext;
begin
  if AfterAction then begin
    if AutoProcessGDB then
      PGDBObjEntity(undomethod.Data)^.YouChanged(drawings.GetCurrentDWG^)
    else begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      PGDBObjEntity(undomethod.Data)^.formatEntity(drawings.GetCurrentDWG^,dc);
    end;
  end;
end;

end.
