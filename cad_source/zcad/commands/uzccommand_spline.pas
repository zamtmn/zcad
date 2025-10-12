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
    PSpline:PGDBObjSpline;
    UserPoints:GDBPoint3dArray;
  end;

implementation

type
  TControlPointsArray=array of GDBVertex;

procedure UpdateSplineFromControlpoints(var ASpleneEntity:GDBObjSpline;
  Point:GDBVertex;Click:boolean;const ControlPoints:array of GDBVertex);
var
  i:integer;
  knotValue:single;
begin
  // Очищаем старые контрольные точки и узлы
  ASpleneEntity.vertexarrayinocs.Clear;
  ASpleneEntity.ControlArrayInOCS.Clear;
  ASpleneEntity.Knots.Clear;

  // Добавляем все сохраненные точки
  for i:=0 to length(ControlPoints)-1 do
    ASpleneEntity.AddVertex(ControlPoints[i]);

  // Добавляем текущую точку (preview)
  //if not Click then
    ASpleneEntity.AddVertex(Point);

  // Генерируем узловой вектор для текущего количества точек
  if ASpleneEntity.vertexarrayinocs.Count>=2 then begin
    // Добавляем начальные узлы (повторяем degree+1 раз)
    for i:=0 to ASpleneEntity.Degree do
      ASpleneEntity.Knots.PushBackData(0.0);

    // Добавляем внутренние узлы
    for i:=1 to ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree-1 do begin
      knotValue:=i/(ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree);
      ASpleneEntity.Knots.PushBackData(knotValue);
    end;

    // Добавляем конечные узлы (повторяем degree+1 раз)
    for i:=0 to ASpleneEntity.Degree do
      ASpleneEntity.Knots.PushBackData(1.0);
  end;
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of GDBVertex):TControlPointsArray;
begin
end;

procedure InteractiveSplineManipulator(const PInteractiveData:PSplineInteractiveData;
  Point:GDBVertex;Click:boolean);
var
  vcp:TControlPointsArray;
begin
  if PInteractiveData^.PSpline=nil then
    exit;

  PInteractiveData^.UserPoints.PushBackData(point);

  if false then
    UpdateSplineFromControlpoints(PInteractiveData^.PSpline^,Point,
      Click,PInteractiveData^.UserPoints.PTArr(PInteractiveData^.UserPoints.getPFirst)^
      [0..PInteractiveData^.UserPoints.Count-1])
  else begin
    vcp:=ConvertOnCurvePointsToControlPointsArray(PInteractiveData^.PSpline^.Degree,PInteractiveData^.UserPoints.PTArr(PInteractiveData^.UserPoints.getPFirst)^[0..PInteractiveData^.UserPoints.Count-1]);
    UpdateSplineFromControlpoints(PInteractiveData^.PSpline^,Point,
      Click,vcp)
  end;

  PInteractiveData^.UserPoints.DeleteElement(PInteractiveData^.UserPoints.Count-1);

  // Обновляем примитив
  zcSetEntPropFromCurrentDrawingProp(PInteractiveData^.PSpline);
  PInteractiveData^.PSpline^.YouChanged(drawings.GetCurrentDWG^);
end;

function InteractiveDrawSpline(const Context:TZCADCommandContext):TCommandResult;
var
  interactiveData:TSplineInteractiveData;
  p1,p2,p3:gdbvertex;
  i:integer;
  knotValue:single;
begin
  Result:=cmd_ok;
  interactiveData.UserPoints.init(100);
  interactiveData.PSpline:=nil;

  // Запрос первыч двух контрольных точек
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
    if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p2)=GRNormal then
      if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p2,p3)=GRNormal then begin
        interactiveData.PSpline:=AllocEnt(GDBSplineID);
        interactiveData.PSpline^.init(nil,nil,LnWtByLayer,false);
        interactiveData.PSpline^.Degree:=3;
        interactiveData.UserPoints.PushBackData(p1);
        interactiveData.UserPoints.PushBackData(p2);
        interactiveData.UserPoints.PushBackData(p3);

        // Добавляем сплайн в конструкторскую область для визуализации
        zcAddEntToCurrentDrawingConstructRoot(interactiveData.PSpline);

        // Запрос следующих контрольных точек с интерактивным отображением
        while True do begin
          // Обновляем сплайн перед запросом следующей точки
          InteractiveSplineManipulator(@interactiveData,p1,False);

          if commandmanager.Get3DPointInteractive(rscmSpecifyNextPoint,p2,
             @InteractiveSplineManipulator,@interactiveData)=GRNormal then begin
            interactiveData.UserPoints.PushBackData(p2);
            p1:=p2;
          end else
            break;
        end;

        // Создаем финальный сплайн если есть минимум 2 точки
        if interactiveData.UserPoints.Count >= 2 then begin
          // Очищаем временный сплайн и заполняем финальными данными
          interactiveData.PSpline^.vertexarrayinocs.clear;
          interactiveData.PSpline^.ControlArrayInOCS.clear;
          interactiveData.PSpline^.Knots.Clear;

          // Добавляем контрольные точки
          for i:=0 to interactiveData.UserPoints.Count-1 do
            interactiveData.PSpline^.AddVertex(interactiveData.UserPoints.getData(i));

          // Создаем узловой вектор (uniform knot vector)
          for i:=0 to interactiveData.PSpline^.Degree do
            interactiveData.PSpline^.Knots.PushBackData(0.0);

          for i:=1 to interactiveData.UserPoints.Count-interactiveData.PSpline^.Degree-1 do begin
            knotValue:=i/(interactiveData.UserPoints.Count-interactiveData.PSpline^.Degree);
            interactiveData.PSpline^.Knots.PushBackData(knotValue);
          end;

          for i:=0 to interactiveData.PSpline^.Degree do
            interactiveData.PSpline^.Knots.PushBackData(1.0);

          // Присваиваем текущие свойства
          zcSetEntPropFromCurrentDrawingProp(interactiveData.PSpline);

          // Переносим из конструкторской области в чертеж
          zcAddEntToCurrentDrawingWithUndo(interactiveData.PSpline);
        end;

        // Очищаем конструкторскую область
        zcClearCurrentDrawingConstructRoot;

        // Перерисовываем
        zcRedrawCurrentDrawing;

      end;

  interactiveData.UserPoints.done;
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
