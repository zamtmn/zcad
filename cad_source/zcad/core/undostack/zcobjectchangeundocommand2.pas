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
unit zcobjectchangeundocommand2;
{$INCLUDE zengineconfig.inc}
interface
uses
  zeundostack,zebaseundocommands,
  uzeentity,uzgldrawcontext,uzcdrawings;

type
  generic GUCmdChgMethods<_T> =class(TCustomChangeCommand)
    public
      type
        PCmd=specialize GUCmdChgMethods<_T>;
      var
        Data:_T;
        DoMethod,UnDoMethod:tmethod;
        constructor Create(var _dodata:_T;_domethod,_undomethod:tmethod);

        procedure UnDo;override;
        procedure Comit;override;

        class function CreateCmd(var _dodata:_T;_domethod,_undomethod:tmethod):PCmd;static;
        class function PushCreateCmd(var us:TZctnrVectorUndoCommands; var _dodata:_T;_domethod,_undomethod:tmethod):PCmd;static;
  end;

implementation

class function GUCmdChgMethods.CreateCmd(var _dodata:_T;_domethod,_undomethod:tmethod):PCmd;
begin
  //Getmem(result,sizeof(specialize GUCmdChgMethods<_T>));
  result:=PCmd.Create(_dodata,_domethod,_undomethod);
end;
class function GUCmdChgMethods.PushCreateCmd(var us:TZctnrVectorUndoCommands; var _dodata:_T;_domethod,_undomethod:tmethod):PCmd;
begin
  result:=CreateCmd(_dodata,_domethod,_undomethod);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;


constructor GUCmdChgMethods.Create(var _dodata:_T;_domethod,_undomethod:tmethod);
begin
  AutoProcessGDB:=True;
  AfterAction:=true;
  Data:=_DoData;
  domethod:=_domethod;
  undomethod:=_undomethod;
end;

procedure GUCmdChgMethods.UnDo;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(undomethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(drawings.GetCurrentDWG^)
                       else
                           begin
                                dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                                PGDBObjEntity(undomethod.Data)^.formatEntity(drawings.GetCurrentDWG^,dc);
                           end;
     end;
end;

procedure GUCmdChgMethods.Comit;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(domethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(drawings.GetCurrentDWG^)
                       else
                           begin
                           dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                           PGDBObjEntity(undomethod.Data)^.formatEntity(drawings.GetCurrentDWG^,dc);
                           end;
     end;
end;

end.
