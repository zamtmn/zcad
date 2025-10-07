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
   UGDBPoint3DArray,
   Math;

function ConvertControlArrayToFitArray(const AControlPoints: GDBPoint3dArray; Degree: integer): GDBPoint3dArray;

type
  PSplineInteractiveData=^TSplineInteractiveData;
  TSplineInteractiveData=record
    pspline:PGDBObjSpline;
    points:GDBPoint3dArray;
  end;

implementation

// Generate uniform clamped knot vector for B-spline
procedure GenerateUniformClampedKnotVector(n: integer; degree: integer; var knots: array of single);
var
  i: integer;
  numKnots: integer;
  internalKnots: integer;
begin
  numKnots := n + degree + 2;
  SetLength(knots, numKnots);
  internalKnots := n - degree;

  // Start with degree+1 zeros
  for i := 0 to degree do
    knots[i] := 0.0;

  // Internal knots
  if internalKnots > 0 then
    for i := 1 to internalKnots do
      knots[degree + i] := i / (internalKnots + 1);

  // End with degree+1 ones
  for i := 0 to degree do
    knots[numKnots - 1 - i] := 1.0;
end;

// Cox-de Boor recursion for B-spline basis function
function BSplineBasis(i, degree: integer; u: single; const knots: array of single): single;
var
  left, right: single;
begin
  if degree = 0 then begin
    if (knots[i] <= u) and (u < knots[i+1]) then
      Result := 1.0
    else
      Result := 0.0;
    exit;
  end;

  // Left term
  left := 0.0;
  if knots[i+degree] <> knots[i] then
    left := ((u - knots[i]) / (knots[i+degree] - knots[i])) * BSplineBasis(i, degree-1, u, knots);

  // Right term
  right := 0.0;
  if knots[i+degree+1] <> knots[i+1] then
    right := ((knots[i+degree+1] - u) / (knots[i+degree+1] - knots[i+1])) * BSplineBasis(i+1, degree-1, u, knots);

  Result := left + right;
end;

// Evaluate B-spline curve at parameter u
function EvaluateBSplineCurve(const controlPoints: GDBPoint3dArray; degree: integer; u: single; const knots: array of single): GDBVertex;
var
  i: integer;
  basis: single;
  point: GDBVertex;
begin
  point := NulVertex;
  for i := 0 to controlPoints.Count - 1 do begin
    basis := BSplineBasis(i, degree, u, knots);
    point.x := point.x + controlPoints.getData(i).x * basis;
    point.y := point.y + controlPoints.getData(i).y * basis;
    point.z := point.z + controlPoints.getData(i).z * basis;
  end;
  Result := point;
end;

function ConvertControlArrayToFitArray(const AControlPoints: GDBPoint3dArray; Degree: integer): GDBPoint3dArray;
const
  NUM_FIT_POINTS = 20; // Number of points to evaluate on the curve
var
  knots: array of single;
  i: integer;
  u: single;
  fitPoint: GDBVertex;
begin
  Result.init(NUM_FIT_POINTS);

  if AControlPoints.Count < Degree + 1 then begin
    // Not enough control points for the degree
    exit;
  end;

  // Generate knot vector
  SetLength(knots, AControlPoints.Count + Degree + 1);
  GenerateUniformClampedKnotVector(AControlPoints.Count - 1, Degree, knots);

  // Evaluate curve at uniform parameter intervals
  for i := 0 to NUM_FIT_POINTS - 1 do begin
    u := i / (NUM_FIT_POINTS - 1); // from 0 to 1
    fitPoint := EvaluateBSplineCurve(AControlPoints, Degree, u, knots);
    Result.PushBackData(fitPoint);
  end;
end;

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
