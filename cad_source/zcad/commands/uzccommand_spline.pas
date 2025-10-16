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

// Compute basis function N_i,p(u) using Cox-de Boor recursion formula
function BasisFunction(i,p:integer;u:single;const knots:array of single):single;
var
  left,right:array of single;
  j,r:integer;
  saved,temp:single;
begin
  SetLength(left,p+1);
  SetLength(right,p+1);

  // Special case: if u is exactly at a knot
  if (u>=knots[i]) and (u<knots[i+1]) and (p=0) then begin
    Result:=1.0;
    exit;
  end;

  if p=0 then begin
    Result:=0.0;
    exit;
  end;

  // Initialize first order
  Result:=1.0;

  for j:=1 to p do begin
    left[j]:=u-knots[i+1-j];
    right[j]:=knots[i+j]-u;
    saved:=0.0;

    for r:=0 to j-1 do begin
      temp:=Result/(right[r+1]+left[j-r]);
      Result:=saved+right[r+1]*temp;
      saved:=left[j-r]*temp;
    end;
    Result:=saved;
  end;
end;

// Generate parameter values using chord length parameterization
procedure ComputeParameters(const points:array of GDBVertex;var params:array of single);
var
  i:integer;
  totalLength,chordLength:single;
begin
  if Length(points)<2 then
    exit;

  params[0]:=0.0;
  params[Length(points)-1]:=1.0;

  if Length(points)=2 then
    exit;

  // Calculate total chord length
  totalLength:=0.0;
  for i:=0 to Length(points)-2 do begin
    chordLength:=sqrt(
      sqr(points[i+1].x-points[i].x)+
      sqr(points[i+1].y-points[i].y)+
      sqr(points[i+1].z-points[i].z)
    );
    totalLength:=totalLength+chordLength;
    params[i+1]:=totalLength;
  end;

  // Normalize to [0,1]
  if totalLength>0.0001 then
    for i:=1 to Length(points)-2 do
      params[i]:=params[i]/totalLength
  else
    for i:=1 to Length(points)-2 do
      params[i]:=i/(Length(points)-1);
end;

// Generate uniform knot vector
procedure GenerateKnotVector(n,p:integer;var knots:array of single);
var
  i:integer;
  m:integer;
begin
  m:=n+p+1;

  // Clamped knot vector: repeat 0 and 1 (p+1) times
  for i:=0 to p do
    knots[i]:=0.0;

  for i:=p+1 to n do
    knots[i]:=(i-p)/(n-p+1);

  for i:=n+1 to m do
    knots[i]:=1.0;
end;

// Solve tridiagonal system using Thomas algorithm
procedure SolveTridiagonal(const a,b,c,d:array of single;var x:array of single;n:integer);
var
  i:integer;
  cprime:array of single;
  dprime:array of single;
begin
  SetLength(cprime,n);
  SetLength(dprime,n);

  cprime[0]:=c[0]/b[0];
  dprime[0]:=d[0]/b[0];

  for i:=1 to n-1 do begin
    if i<n-1 then
      cprime[i]:=c[i]/(b[i]-a[i]*cprime[i-1])
    else
      cprime[i]:=0;
    dprime[i]:=(d[i]-a[i]*dprime[i-1])/(b[i]-a[i]*cprime[i-1]);
  end;

  x[n-1]:=dprime[n-1];
  for i:=n-2 downto 0 do
    x[i]:=dprime[i]-cprime[i]*x[i+1];
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of GDBVertex):TControlPointsArray;
var
  n,m,i,j:integer;
  params:array of single;
  knots:array of single;
  N:array of array of single;
  a,b,c:array of single;
  dx,dy,dz:array of single;
  cx,cy,cz:array of single;
begin
  n:=Length(AOnCurvePoints);

  // Handle edge cases
  if n<2 then begin
    SetLength(Result,0);
    exit;
  end;

  // For degree >= n, or simple cases, return the points themselves
  if (ADegree>=n) or (ADegree<1) then begin
    SetLength(Result,n);
    for i:=0 to n-1 do
      Result[i]:=AOnCurvePoints[i];
    exit;
  end;

  // For degree 1 (linear), return the points as-is
  if ADegree=1 then begin
    SetLength(Result,n);
    for i:=0 to n-1 do
      Result[i]:=AOnCurvePoints[i];
    exit;
  end;

  // General case: solve interpolation problem
  // Number of control points equals number of interpolation points
  m:=n;
  SetLength(Result,m);

  // Compute parameter values
  SetLength(params,n);
  ComputeParameters(AOnCurvePoints,params);

  // Generate knot vector
  SetLength(knots,m+ADegree+1);
  GenerateKnotVector(m-1,ADegree,knots);

  // Build coefficient matrix using basis functions
  SetLength(N,n);
  for i:=0 to n-1 do begin
    SetLength(N[i],m);
    for j:=0 to m-1 do
      N[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  end;

  // For cubic and higher degree splines, we solve a system of equations
  // For simplicity with boundary conditions, we'll use the first and last points directly
  if n=2 then begin
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
  end else if ADegree=2 then begin
    // Quadratic case: simple interpolation
    Result[0]:=AOnCurvePoints[0];
    Result[n-1]:=AOnCurvePoints[n-1];
    for i:=1 to n-2 do begin
      // Simple averaging for intermediate points
      Result[i].x:=AOnCurvePoints[i].x;
      Result[i].y:=AOnCurvePoints[i].y;
      Result[i].z:=AOnCurvePoints[i].z;
    end;
  end else begin
    // Cubic (degree 3) and higher: use tridiagonal solver
    SetLength(a,n);
    SetLength(b,n);
    SetLength(c,n);
    SetLength(dx,n);
    SetLength(dy,n);
    SetLength(dz,n);
    SetLength(cx,n);
    SetLength(cy,n);
    SetLength(cz,n);

    // Setup tridiagonal system based on basis functions
    // First and last control points = first and last data points
    Result[0]:=AOnCurvePoints[0];
    Result[n-1]:=AOnCurvePoints[n-1];

    // For interior control points, set up system
    for i:=1 to n-2 do begin
      a[i]:=0.25;
      b[i]:=1.0;
      c[i]:=0.25;
      dx[i]:=AOnCurvePoints[i].x;
      dy[i]:=AOnCurvePoints[i].y;
      dz[i]:=AOnCurvePoints[i].z;
    end;

    // Boundary conditions
    b[0]:=1.0;
    c[0]:=0.0;
    a[0]:=0.0;
    dx[0]:=AOnCurvePoints[0].x;
    dy[0]:=AOnCurvePoints[0].y;
    dz[0]:=AOnCurvePoints[0].z;

    a[n-1]:=0.0;
    b[n-1]:=1.0;
    c[n-1]:=0.0;
    dx[n-1]:=AOnCurvePoints[n-1].x;
    dy[n-1]:=AOnCurvePoints[n-1].y;
    dz[n-1]:=AOnCurvePoints[n-1].z;

    // Solve for each coordinate
    if n>2 then begin
      SolveTridiagonal(a,b,c,dx,cx,n);
      SolveTridiagonal(a,b,c,dy,cy,n);
      SolveTridiagonal(a,b,c,dz,cz,n);

      for i:=0 to n-1 do begin
        Result[i].x:=cx[i];
        Result[i].y:=cy[i];
        Result[i].z:=cz[i];
      end;
    end;
  end;
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
