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
{$mode delphi}
unit uzccommand_line;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentline,uzeentity,uzeentityfactory,
  uzcutils;

type
  TEntitySetupProc=procedure(const PEnt:PGDBObjEntity);

function InteractiveDrawLines(const Context:TZCADCommandContext;APrompt1,APromptNext:String;ESP:TEntitySetupProc):TCommandResult;

implementation

function InteractiveDrawLines(const Context:TZCADCommandContext;APrompt1,APromptNext:String;ESP:TEntitySetupProc):TCommandResult;
var
  pline:PGDBObjLine;
  p1,p2:gdbvertex;
begin
 {запрос первой координаты}
 if commandmanager.get3dpoint(APrompt1,p1)=GRNormal then
   while true do
     {запрос следующей координаты
      с рисованием резиновой линии от базовой точки p1}
     if commandmanager.Get3DPointWithLineFromBase(APromptNext,p1,p2)=GRNormal then begin

       //создаем и инициализируем примитив
       pline:=AllocEnt(GDBLineID);
       pline^.init(nil,nil,LnWtByLayer,p1,p2);

       //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
       zcSetEntPropFromCurrentDrawingProp(pline);

       //дополнительная настройка
       if assigned(ESP) then
         ESP(pline);

       //добавляем в чертеж
       zcAddEntToCurrentDrawingWithUndo(pline);

       //перерисовываем
       zcRedrawCurrentDrawing;

       p1:=p2;
     end else
       break;
 result:=cmd_ok;
end;


function DrawLine_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
 Result:=InteractiveDrawLines(Context,rscmSpecifyFirstPoint,rscmSpecifyNextPoint,nil);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawLine_com,'Line',   CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
