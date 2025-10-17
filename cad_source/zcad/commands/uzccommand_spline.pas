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
  TSingleArray=array of single;
  TMatrix=array of TSingleArray;

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
  BasisValues:array of single;
  j,k:integer;
  saved,temp:single;
  uleft,uright:single;
  numCtrlPts:integer;
begin
  // Cox-de Boor recursion formula:
  // N_i,0(u) = 1 if knots[i] <= u < knots[i+1], else 0
  // N_i,p(u) = ((u - knots[i]) / (knots[i+p] - knots[i])) * N_i,p-1(u) +
  //            ((knots[i+p+1] - u) / (knots[i+p+1] - knots[i+1])) * N_i+1,p-1(u)

  // Special case for clamped B-splines at the endpoint
  // For n+1 control points with degree p, the knot vector has n+p+2 elements
  // When u equals the last knot value (u=1.0 for normalized knots), only the last basis function should be non-zero
  numCtrlPts:=Length(knots)-p-2;  // Number of control points minus 1
  if (abs(u-knots[Length(knots)-1])<1e-10) and (abs(knots[Length(knots)-1]-knots[Length(knots)-p-1])<1e-10) then begin
    // At the last knot with multiplicity p+1
    if i=numCtrlPts then
      Result:=1.0
    else
      Result:=0.0;
    exit;
  end;

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
  SetLength(BasisValues,p+1);

  // Initialize degree 0
  for j:=0 to p do begin
    if (u>=knots[i+j]) and (u<knots[i+j+1]) then
      BasisValues[j]:=1.0
    else if (u=knots[i+j+1]) and (i+j=Length(knots)-2) then
      BasisValues[j]:=1.0
    else
      BasisValues[j]:=0.0;
  end;

  // Build up to degree p
  for k:=1 to p do begin
    // Handle left end
    if BasisValues[0]=0.0 then
      saved:=0.0
    else begin
      uright:=knots[i+k];
      uleft:=knots[i];
      if abs(uright-uleft)<1e-10 then
        saved:=0.0
      else
        saved:=((u-uleft)/(uright-uleft))*BasisValues[0];
    end;

    // Process middle terms
    for j:=0 to p-k do begin
      uleft:=knots[i+j+1];
      uright:=knots[i+j+k+1];

      if BasisValues[j+1]=0.0 then begin
        BasisValues[j]:=saved;
        saved:=0.0;
      end else begin
        if abs(uright-uleft)<1e-10 then
          temp:=0.0
        else
          temp:=((uright-u)/(uright-uleft))*BasisValues[j+1];
        BasisValues[j]:=saved+temp;

        if abs(knots[i+j+k+1]-knots[i+j+1])<1e-10 then
          saved:=0.0
        else
          saved:=((u-knots[i+j+1])/(knots[i+j+k+1]-knots[i+j+1]))*BasisValues[j+1];
      end;
    end;
  end;

  Result:=BasisValues[0];
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
  // Fix: normalize ALL intermediate points including the last one
  // The last point was already set to totalLength in the loop above (line 190)
  // and needs to be normalized to 1.0
  if totalLength>0.0001 then
    for i:=1 to Length(points)-1 do
      params[i]:=params[i]/totalLength
  else
    for i:=1 to Length(points)-1 do
      params[i]:=i/(Length(points)-1);
end;

// Generate knot vector using averaging method for global interpolation
// Based on standard B-spline interpolation algorithm (Piegl & Tiller, "The NURBS Book")
procedure GenerateKnotVector(n,p:integer;const params:array of single;var knots:array of single);
var
  i,j:integer;
  m:integer;
  sum:single;
begin
  m:=n+p+1;

  // Clamped knot vector: repeat 0 (p+1) times at start
  for i:=0 to p do
    knots[i]:=0.0;

  // Internal knots: average p consecutive parameter values
  // Formula: knots[j] = (params[j-p] + params[j-p+1] + ... + params[j-1]) / p
  // This ensures the matrix system for finding control points is well-conditioned
  for j:=p+1 to n do begin
    sum:=0.0;
    for i:=j-p to j-1 do
      sum:=sum+params[i];
    knots[j]:=sum/p;
  end;

  // Clamped knot vector: repeat 1 (p+1) times at end
  for i:=n+1 to m do
    knots[i]:=1.0;
end;

// Solve linear system using Gaussian elimination with partial pivoting
procedure SolveLinearSystem(var A:TMatrix;const b:array of single;var x:array of single;n:integer);
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
  numPoints,i,j:integer;
  params:array of single;
  knots:array of single;
  BasisMatrix:TMatrix;
  dx,dy,dz:array of single;
  cx,cy,cz:array of single;
begin
  numPoints:=Length(AOnCurvePoints);

  // Handle edge cases
  if numPoints<2 then begin
    SetLength(Result,0);
    exit;
  end;

  // For degree >= numPoints, or simple cases, return the points themselves
  if (ADegree>=numPoints) or (ADegree<1) then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    exit;
  end;

  // For degree 1 (linear), return the points as-is
  if ADegree=1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    exit;
  end;

  // Special case: only 2 points
  if numPoints=2 then begin
    SetLength(Result,2);
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
    exit;
  end;

  // General case: solve global interpolation problem
  // Number of control points equals number of interpolation points
  SetLength(Result,numPoints);

  // Compute parameter values using chord length parameterization
  SetLength(params,numPoints);
  ComputeParameters(AOnCurvePoints,params);

  // Generate knot vector for numPoints control points and given degree
  SetLength(knots,numPoints+ADegree+1);
  GenerateKnotVector(numPoints-1,ADegree,params,knots);

  // Build coefficient matrix BasisMatrix where BasisMatrix[i][j] = BasisFunction(j, degree, params[i])
  // This represents the system: sum(BasisMatrix[i][j] * P[j]) = D[i]
  // where P[j] are unknown control points and D[i] are given data points
  SetLength(BasisMatrix,numPoints);
  for i:=0 to numPoints-1 do begin
    SetLength(BasisMatrix[i],numPoints);
    for j:=0 to numPoints-1 do
      BasisMatrix[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  end;

  // Set up right-hand side vectors for each coordinate
  SetLength(dx,numPoints);
  SetLength(dy,numPoints);
  SetLength(dz,numPoints);
  SetLength(cx,numPoints);
  SetLength(cy,numPoints);
  SetLength(cz,numPoints);

  for i:=0 to numPoints-1 do begin
    dx[i]:=AOnCurvePoints[i].x;
    dy[i]:=AOnCurvePoints[i].y;
    dz[i]:=AOnCurvePoints[i].z;
  end;

  // Solve the linear system BasisMatrix * P = D for each coordinate
  // Need to copy BasisMatrix for each solve since the solver modifies it
  SolveLinearSystem(BasisMatrix,dx,cx,numPoints);

  // Rebuild BasisMatrix for y coordinate
  for i:=0 to numPoints-1 do
    for j:=0 to numPoints-1 do
      BasisMatrix[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  SolveLinearSystem(BasisMatrix,dy,cy,numPoints);

  // Rebuild BasisMatrix for z coordinate
  for i:=0 to numPoints-1 do
    for j:=0 to numPoints-1 do
      BasisMatrix[i][j]:=BasisFunction(j,ADegree,params[i],knots);
  SolveLinearSystem(BasisMatrix,dz,cz,numPoints);

  // Store results
  for i:=0 to numPoints-1 do begin
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
  controlPoints:TControlPointsArray;
  params:array of single;
  knots:array of single;
  numPoints:integer;
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

        // Устанавливаем p1 в последнюю добавленную точку для корректной работы цикла
        p1:=p3;

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

          numPoints:=interactiveData.UserPoints.Count;

          // Конвертируем точки интерполяции в контрольные точки
          // чтобы сплайн проходил через указанные пользователем точки
          controlPoints:=ConvertOnCurvePointsToControlPointsArray(
            interactiveData.PSpline^.Degree,
            interactiveData.UserPoints.PTArr(interactiveData.UserPoints.getPFirst)^[0..numPoints-1]
          );

          // Добавляем вычисленные контрольные точки
          for i:=0 to Length(controlPoints)-1 do
            interactiveData.PSpline^.AddVertex(controlPoints[i]);

          // Генерируем узловой вектор используя метод усреднения
          // для обеспечения корректной интерполяции
          SetLength(params,numPoints);
          ComputeParameters(
            interactiveData.UserPoints.PTArr(interactiveData.UserPoints.getPFirst)^[0..numPoints-1],
            params
          );

          SetLength(knots,numPoints+interactiveData.PSpline^.Degree+1);
          GenerateKnotVector(numPoints-1,interactiveData.PSpline^.Degree,params,knots);

          // Добавляем узлы в сплайн
          for i:=0 to Length(knots)-1 do
            interactiveData.PSpline^.Knots.PushBackData(knots[i]);

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
