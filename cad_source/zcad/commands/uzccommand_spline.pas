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
  uzcdrawings,
  UGDBPoint3DArray;

type
  PSplineInteractiveData=^TSplineInteractiveData;
  TSplineInteractiveData=record
    pspline:PGDBObjSpline;
    points:GDBPoint3dArray;
  end;

implementation

procedure InteractiveSplineManipulator(
  const PInteractiveData:PSplineInteractiveData;
  Point:GDBVertex;
  Click:boolean);
var
  i:integer;
  knotValue:single;
  //data:TSplineInteractiveData absolute PInteractiveData;
begin
  if PInteractiveData^.pspline=nil then
    exit;

  // Очищаем старые контрольные точки и узлы
  PInteractiveData^.pspline^.ControlArrayInOCS.clear;
  PInteractiveData^.pspline^.Knots.Clear;

  // Добавляем все сохраненные точки
  for i:=0 to PInteractiveData^.points.Count-1 do
    PInteractiveData^.pspline^.AddVertex(PInteractiveData^.points.getData(i));

  // Добавляем текущую точку (preview)
  if not Click then
    PInteractiveData^.pspline^.AddVertex(Point);

  // Генерируем узловой вектор для текущего количества точек
  if PInteractiveData^.pspline^.ControlArrayInOCS.Count >= 2 then begin
    // Добавляем начальные узлы (повторяем degree+1 раз)
    for i:=0 to PInteractiveData^.pspline^.Degree do
      PInteractiveData^.pspline^.Knots.PushBackData(0.0);

    // Добавляем внутренние узлы
    for i:=1 to PInteractiveData^.pspline^.ControlArrayInOCS.Count-PInteractiveData^.pspline^.Degree-1 do begin
      knotValue:=i/(PInteractiveData^.pspline^.ControlArrayInOCS.Count-PInteractiveData^.pspline^.Degree);
      PInteractiveData^.pspline^.Knots.PushBackData(knotValue);
    end;

    // Добавляем конечные узлы (повторяем degree+1 раз)
    for i:=0 to PInteractiveData^.pspline^.Degree do
      PInteractiveData^.pspline^.Knots.PushBackData(1.0);
  end;

  // Обновляем примитив
  zcSetEntPropFromCurrentDrawingProp(PInteractiveData^.pspline);
  PInteractiveData^.pspline^.YouChanged(drawings.GetCurrentDWG^);
end;

function InteractiveDrawSpline(const Context:TZCADCommandContext):TCommandResult;
var
  interactiveData:TSplineInteractiveData;
  p1,p2:gdbvertex;
  i:integer;
  knotValue:single;
begin
  Result:=cmd_ok;
  interactiveData.points.init(100);
  interactiveData.pspline:=nil;

  // Запрос первой контрольной точки
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then begin
    interactiveData.points.PushBackData(p1);

    // Создаем и инициализируем примитив сплайна для предварительного просмотра
    interactiveData.pspline:=AllocEnt(GDBSplineID);
    interactiveData.pspline^.init(nil,nil,LnWtByLayer,false);
    interactiveData.pspline^.Degree:=3;

    // Добавляем сплайн в конструкторскую область для визуализации
    zcAddEntToCurrentDrawingConstructRoot(interactiveData.pspline);

    // Запрос следующих контрольных точек с интерактивным отображением
    while True do begin
      // Обновляем сплайн перед запросом следующей точки
      InteractiveSplineManipulator(@interactiveData,p1,False);

      if commandmanager.Get3DPointInteractive(rscmSpecifyNextPoint,p2,
         @InteractiveSplineManipulator,@interactiveData)=GRNormal then begin
        interactiveData.points.PushBackData(p2);
        p1:=p2;
      end else
        break;
    end;

    // Создаем финальный сплайн если есть минимум 2 точки
    if interactiveData.points.Count >= 2 then begin
      // Очищаем временный сплайн и заполняем финальными данными
      interactiveData.pspline^.ControlArrayInOCS.clear;
      interactiveData.pspline^.Knots.Clear;

      // Добавляем контрольные точки
      for i:=0 to interactiveData.points.Count-1 do
        interactiveData.pspline^.AddVertex(interactiveData.points.getData(i));

      // Создаем узловой вектор (uniform knot vector)
      for i:=0 to interactiveData.pspline^.Degree do
        interactiveData.pspline^.Knots.PushBackData(0.0);

      for i:=1 to interactiveData.points.Count-interactiveData.pspline^.Degree-1 do begin
        knotValue:=i/(interactiveData.points.Count-interactiveData.pspline^.Degree);
        interactiveData.pspline^.Knots.PushBackData(knotValue);
      end;

      for i:=0 to interactiveData.pspline^.Degree do
        interactiveData.pspline^.Knots.PushBackData(1.0);

      // Присваиваем текущие свойства
      zcSetEntPropFromCurrentDrawingProp(interactiveData.pspline);

      // Переносим из конструкторской области в чертеж
      zcAddEntToCurrentDrawingWithUndo(interactiveData.pspline);
    end;

    // Очищаем конструкторскую область
    zcClearCurrentDrawingConstructRoot;

    // Перерисовываем
    zcRedrawCurrentDrawing;
  end;

  interactiveData.points.done;
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
