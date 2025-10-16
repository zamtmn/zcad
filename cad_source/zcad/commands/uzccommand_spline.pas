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
  N:array of single;
  j,k:integer;
  saved,temp:single;
  uleft,uright:single;
begin
  // Cox-de Boor recursion formula:
  // N_i,0(u) = 1 if knots[i] <= u < knots[i+1], else 0
  // N_i,p(u) = ((u - knots[i]) / (knots[i+p] - knots[i])) * N_i,p-1(u) +
  //            ((knots[i+p+1] - u) / (knots[i+p+1] - knots[i+1])) * N_i+1,p-1(u)

  // Special case for degree 0
  if p=0 then begin
    if (u>=knots[i]) and (u<knots[i+1]) then
      Result:=1.0
    else if (u=knots[i+1]) and (i=Length(knots)-2) then
      // Special case: u is at the last knot
      Result:=1.0
    else
      Result:=0.0;
    exit;
  end;

  // Use triangular table to build up from degree 0 to degree p
  SetLength(N,p+1);

  // Initialize degree 0
  for j:=0 to p do begin
    if (u>=knots[i+j]) and (u<knots[i+j+1]) then
      N[j]:=1.0
    else if (u=knots[i+j+1]) and (i+j=Length(knots)-2) then
      N[j]:=1.0
    else
      N[j]:=0.0;
  end;

  // Build up to degree p
  for k:=1 to p do begin
    // Handle left end
    if N[0]=0.0 then
      saved:=0.0
    else begin
      uright:=knots[i+k];
      uleft:=knots[i];
      if abs(uright-uleft)<1e-10 then
        saved:=0.0
      else
        saved:=((u-uleft)/(uright-uleft))*N[0];
    end;

    // Process middle terms
    for j:=0 to p-k do begin
      uleft:=knots[i+j+1];
      uright:=knots[i+j+k+1];

      if N[j+1]=0.0 then begin
        N[j]:=saved;
        saved:=0.0;
      end else begin
        if abs(uright-uleft)<1e-10 then
          temp:=0.0
        else
          temp:=((uright-u)/(uright-uleft))*N[j+1];
        N[j]:=saved+temp;

        if abs(knots[i+j+k+1]-knots[i+j+1])<1e-10 then
          saved:=0.0
        else
          saved:=((u-knots[i+j+1])/(knots[i+j+k+1]-knots[i+j+1]))*N[j+1];
      end;
    end;
  end;

  Result:=N[0];
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

// Solve linear system using Gaussian elimination with partial pivoting
procedure SolveLinearSystem(var A:array of array of single;const b:array of single;var x:array of single;n:integer);
var
  i,j,k,maxRow:integer;
  maxVal,tmp,factor:single;
  c:array of single;
begin
  // Create augmented matrix [A|b]
  SetLength(c,n);
  for i:=0 to n-1 do
    c[i]:=b[i];

  // Forward elimination with partial pivoting
  for k:=0 to n-2 do begin
    // Find pivot
    maxRow:=k;
    maxVal:=abs(A[k][k]);
    for i:=k+1 to n-1 do begin
      if abs(A[i][k])>maxVal then begin
        maxVal:=abs(A[i][k]);
        maxRow:=i;
      end;
    end;

    // Swap rows if needed
    if maxRow<>k then begin
      for j:=k to n-1 do begin
        tmp:=A[k][j];
        A[k][j]:=A[maxRow][j];
        A[maxRow][j]:=tmp;
      end;
      tmp:=c[k];
      c[k]:=c[maxRow];
      c[maxRow]:=tmp;
    end;

    // Eliminate column
    for i:=k+1 to n-1 do begin
      if abs(A[k][k])>1e-10 then begin
        factor:=A[i][k]/A[k][k];
        for j:=k to n-1 do
          A[i][j]:=A[i][j]-factor*A[k][j];
        c[i]:=c[i]-factor*c[k];
      end;
    end;
  end;

  // Back substitution
  for i:=n-1 downto 0 do begin
    x[i]:=c[i];
    for j:=i+1 to n-1 do
      x[i]:=x[i]-A[i][j]*x[j];
    if abs(A[i][i])>1e-10 then
      x[i]:=x[i]/A[i][i]
    else
      x[i]:=0;
  end;
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of GDBVertex):TControlPointsArray;
var
  n,i,j:integer;
  params:array of single;
  knots:array of single;
  N:array of array of single;
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

  // Special case: only 2 points
  if n=2 then begin
    SetLength(Result,2);
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
    exit;
  end;

  // General case: solve global interpolation problem
  // Number of control points equals number of interpolation points
  SetLength(Result,n);

  // Compute parameter values using chord length parameterization
  SetLength(params,n);
  ComputeParameters(AOnCurvePoints,params);

  // Generate knot vector for n control points and given degree
  SetLength(knots,n+ADegree+1);
  GenerateKnotVector(n-1,ADegree,knots);

  // Build coefficient matrix N where N[i][j] = BasisFunction(j, degree, params[i])
  // This represents the system: sum(N[i][j] * P[j]) = D[i]
  // where P[j] are unknown control points and D[i] are given data points
  SetLength(N,n);
  for i:=0 to n-1 do begin
    SetLength(N[i],n);
    for j:=0 to n-1 do
      N[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  end;

  // Set up right-hand side vectors for each coordinate
  SetLength(dx,n);
  SetLength(dy,n);
  SetLength(dz,n);
  SetLength(cx,n);
  SetLength(cy,n);
  SetLength(cz,n);

  for i:=0 to n-1 do begin
    dx[i]:=AOnCurvePoints[i].x;
    dy[i]:=AOnCurvePoints[i].y;
    dz[i]:=AOnCurvePoints[i].z;
  end;

  // Solve the linear system N * P = D for each coordinate
  // Need to copy N for each solve since the solver modifies it
  SolveLinearSystem(N,dx,cx,n);

  // Rebuild N for y coordinate
  for i:=0 to n-1 do
    for j:=0 to n-1 do
      N[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  SolveLinearSystem(N,dy,cy,n);

  // Rebuild N for z coordinate
  for i:=0 to n-1 do
    for j:=0 to n-1 do
      N[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  SolveLinearSystem(N,dz,cz,n);

  // Store results
  for i:=0 to n-1 do begin
    Result[i].x:=cx[i];
    Result[i].y:=cy[i];
    Result[i].z:=cz[i];
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
