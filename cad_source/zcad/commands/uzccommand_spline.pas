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
unit uzccommand_spline;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentspline,uzeentity,uzeentityfactory,
  uzcutils,
  UGDBPoint3DArray;

implementation

function InteractiveDrawSpline(const Context:TZCADCommandContext):TCommandResult;
var
  pspline:PGDBObjSpline;
  points:GDBPoint3dArray;
  p1:gdbvertex;
  i:integer;
  knotValue:single;
begin
  Result:=cmd_ok;
  points.init(100);

  // Запрос первой контрольной точки
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then begin
    points.PushBackData(p1);

    // Запрос следующих контрольных точек
    while True do begin
      if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p1)=GRNormal then begin
        points.PushBackData(p1);
      end else
        break;
    end;

    // Создаем сплайн только если есть минимум 2 точки
    if points.Count >= 2 then begin
      // Создаем и инициализируем примитив сплайна
      pspline:=AllocEnt(GDBSplineID);
      pspline^.init(nil,nil,LnWtByLayer,false);

      // Устанавливаем степень сплайна (кубический сплайн)
      pspline^.Degree:=3;

      // Добавляем контрольные точки
      for i:=0 to points.Count-1 do
        pspline^.AddVertex(points.getData(i)^);

      // Создаем узловой вектор (uniform knot vector)
      // Для кубического сплайна (degree=3) с n контрольными точками
      // нужно n+degree+1 узлов
      for i:=0 to pspline^.Degree do
        pspline^.Knots.PushBackData(0.0);

      for i:=1 to points.Count-pspline^.Degree-1 do begin
        knotValue:=i/(points.Count-pspline^.Degree);
        pspline^.Knots.PushBackData(knotValue);
      end;

      for i:=0 to pspline^.Degree do
        pspline^.Knots.PushBackData(1.0);

      // Присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
      zcSetEntPropFromCurrentDrawingProp(pspline);

      // Добавляем в чертеж
      zcAddEntToCurrentDrawingWithUndo(pspline);

      // Перерисовываем
      zcRedrawCurrentDrawing;
    end;
  end;

  points.done;
end;

function DrawSpline_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  Result:=InteractiveDrawSpline(Context);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawSpline_com,'Spline',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.