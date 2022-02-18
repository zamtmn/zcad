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
{$mode delphi}
unit uzccommand_line;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentline,uzeentityfactory,
  uzcutils;

implementation

 function DrawLine_com(operands:TCommandOperands):TCommandResult;
var
  pline:PGDBObjLine;
  p1,p2:gdbvertex;
begin
 {запрос первой координаты}
 if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
   while true do
     {запрос следующей координаты
      с рисованием резиновой линии от базовой точки p1}
     if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p2)=GRNormal then begin

       //создаем и инициализируем примитив
       pline:=AllocEnt(GDBLineID);
       pline^.init(nil,nil,LnWtByLayer,p1,p2);

       //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
       zcSetEntPropFromCurrentDrawingProp(pline);
       //добавляем в чертеж
       zcAddEntToCurrentDrawingWithUndo(pline);
       //перерисовываем
       zcRedrawCurrentDrawing;

       p1:=p2;
     end else
       break;
 result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@DrawLine_com,'Line',   CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
