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
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,uzegeometry,
  uzccommandsmanager,
  uzeentspline,uzeentity,uzeentityfactory,
  uzcutils,
  uzcdrawings,
  UGDBPoint3DArray,
  Math;

implementation

type
  TControlPointsArray=array of GDBVertex;
  TPointsType=(PTControl,PTOnCurve);
  TSingleArray=array of single;
  TMatrix=array of TSingleArray;
  PSplineInteractiveData=^TSplineInteractiveData;

  TSplineInteractiveData=record
    PSpline:PGDBObjSpline;
    PT:TPointsType;
    UserPoints:GDBPoint3dArray;
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
  if abs(u-knots[Length(knots)-1])<1e-10 then begin
    // At the last knot value
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
    else if (abs(u-knots[i+1])<1e-10) and (i+1=Length(knots)-1) then
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
    else if (abs(u-knots[i+j+1])<1e-10) and (i+j+1=Length(knots)-1) then
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
  const AOnCurvePoints:array of GDBVertex;var AKnots:TSingleArray):TControlPointsArray;
var
  numPoints,numControlPoints,i,j:integer;
  params:array of single;
  knots:array of single;
  u:single;
  A:TMatrix;
  b_x,b_y,b_z:TSingleArray;
  x_x,x_y,x_z:TSingleArray;
begin
  numPoints:=Length(AOnCurvePoints);

  // Handle edge cases
  if numPoints<2 then begin
    SetLength(Result,0);
    SetLength(AKnots,0);
    exit;
  end;

  // For degree >= numPoints, or simple cases, return the points themselves
  if (ADegree>=numPoints) or (ADegree<1) then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    SetLength(AKnots,0);  // Will use default knot generation
    exit;
  end;

  // For degree 1 (linear), return the points as-is
  if ADegree=1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    SetLength(AKnots,0);  // Will use default knot generation
    exit;
  end;

  // Special case: only 2 points
  if numPoints=2 then begin
    SetLength(Result,2);
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
    SetLength(AKnots,0);  // Will use default knot generation
    exit;
  end;

  // STANDARD Global Interpolation
  // Following Piegl & Tiller "The NURBS Book" Chapter 9.2.1:
  // Global curve interpolation through fit points
  // For n+1 data points (n = numPoints-1), generates n+1 control points
  // This is the standard NURBS interpolation method used in academic literature

  // Compute parameter values using chord length parameterization
  SetLength(params,numPoints);
  ComputeParameters(AOnCurvePoints,params);

  // Number of control points = numPoints (same as number of fit points)
  // For n+1 data points indexed as D[0..n], we compute n+1 control points P[0..n]
  // such that C(u_i) = D_i for all i
  numControlPoints:=numPoints;
  SetLength(Result,numControlPoints);

  // Generate knot vector using averaging method
  // For n+1 control points (indexed 0 to n) with degree p:
  // Knot vector has m+1 elements where m = n + p + 1
  SetLength(knots,numPoints+ADegree+1);
  GenerateKnotVector(numPoints-1,ADegree,params,knots);

  // Copy knots to output parameter so caller can use the same knot vector
  SetLength(AKnots,Length(knots));
  for i:=0 to Length(knots)-1 do
    AKnots[i]:=knots[i];

  // Set up linear system: N * P = D
  // where N is the matrix of basis function values,
  // P are the unknown control points,
  // D are the known fit points
  SetLength(A,numPoints);
  SetLength(b_x,numPoints);
  SetLength(b_y,numPoints);
  SetLength(b_z,numPoints);
  SetLength(x_x,numPoints);
  SetLength(x_y,numPoints);
  SetLength(x_z,numPoints);

  // Build the coefficient matrix N
  for i:=0 to numPoints-1 do begin
    SetLength(A[i],numPoints);
    u:=params[i];

    // Evaluate all basis functions N_j,p(u_i) for j = 0 to numPoints-1
    for j:=0 to numPoints-1 do begin
      A[i][j]:=BasisFunction(j,ADegree,u,knots);
    end;

    // Right-hand side: fit points
    b_x[i]:=AOnCurvePoints[i].x;
    b_y[i]:=AOnCurvePoints[i].y;
    b_z[i]:=AOnCurvePoints[i].z;
  end;

  // Solve the linear system for each dimension
  SolveLinearSystem(A,b_x,x_x,numPoints);
  SolveLinearSystem(A,b_y,x_y,numPoints);
  SolveLinearSystem(A,b_z,x_z,numPoints);

  // Store control points
  for i:=0 to numPoints-1 do begin
    Result[i].x:=x_x[i];
    Result[i].y:=x_y[i];
    Result[i].z:=x_z[i];
  end;
end;

procedure UpdateSplineFromPoints(var ASpleneEntity:GDBObjSpline;
  APointsType:TPointsType;
  const APoints:array of GDBVertex);
var
  i:integer;
  knotValue:single;
  vcp:TControlPointsArray;
  computedKnots:TSingleArray;
  tp:TControlPointsArray;
begin
  // Очищаем старые контрольные точки и узлы
  ASpleneEntity.vertexarrayinocs.Clear;
  ASpleneEntity.ControlArrayInOCS.Clear;
  ASpleneEntity.Knots.Clear;

  if APointsType=PTControl then begin
    //имеем контрольные точки
    //Добавляем все точки в сплайн
    for i:=low(APoints) to high(APoints) do
      ASpleneEntity.AddVertex(APoints[i]);

    // Генерируем узловой вектор для текущего количества точек (uniform)
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
  end else begin
    //имеем точки на кривой
    //пересчитываем точки и получаем соответствующий узловой вектор
    vcp:=ConvertOnCurvePointsToControlPointsArray(ASpleneEntity.Degree,APoints,computedKnots);

    //Добавляем все контрольные точки в сплайн
    for i:=low(vcp) to high(vcp) do
      ASpleneEntity.AddVertex(vcp[i]);

    // Используем узловой вектор, вычисленный вместе с контрольными точками
    // ВАЖНО: Контрольные точки и узловой вектор должны соответствовать друг другу!
    if Length(computedKnots)>0 then begin
      // Используем вычисленный узловой вектор
      for i:=0 to Length(computedKnots)-1 do
        ASpleneEntity.Knots.PushBackData(computedKnots[i]);
    end else begin
      // Fallback: генерируем стандартный узловой вектор для простых случаев
      if ASpleneEntity.vertexarrayinocs.Count>=2 then begin
        for i:=0 to ASpleneEntity.Degree do
          ASpleneEntity.Knots.PushBackData(0.0);

        for i:=1 to ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree-1 do begin
          knotValue:=i/(ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree);
          ASpleneEntity.Knots.PushBackData(knotValue);
        end;

        for i:=0 to ASpleneEntity.Degree do
          ASpleneEntity.Knots.PushBackData(1.0);
      end;
    end;
  end;
end;

procedure InteractiveSplineManipulator(const PInteractiveData:PSplineInteractiveData;
  Point:GDBVertex;Click:boolean);
begin
  if PInteractiveData^.PSpline=nil then
    exit;

  //добавляем preview точку последней
  PInteractiveData^.UserPoints.PushBackData(point);

  UpdateSplineFromPoints(PInteractiveData^.PSpline^,PInteractiveData^.PT,
    PInteractiveData^.UserPoints.PTArr(PInteractiveData^.UserPoints.getPFirst)^
    [0..PInteractiveData^.UserPoints.Count-1]);

  PInteractiveData^.UserPoints.DeleteElement(PInteractiveData^.UserPoints.Count-1);

  // Обновляем примитив
  zcSetEntPropFromCurrentDrawingProp(PInteractiveData^.PSpline);
  PInteractiveData^.PSpline^.YouChanged(drawings.GetCurrentDWG^);
end;

function InteractiveDrawSpline(APointType:TPointsType;
  const Context:TZCADCommandContext):TCommandResult;
var
  interactiveData:TSplineInteractiveData;
  p1,p2,p3:gdbvertex;
  i:integer;
  knotValue:single;
begin
  Result:=cmd_ok;
  interactiveData.PT:=APointType;
  interactiveData.UserPoints.init(100);
  interactiveData.PSpline:=nil;

  // Запрос первыч двух контрольных точек
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
    if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p2)=
      GRNormal then
      if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p2,p3)=
        GRNormal then begin
        interactiveData.PSpline:=AllocEnt(GDBSplineID);
        interactiveData.PSpline^.init(nil,nil,LnWtByLayer,False);
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
        if interactiveData.UserPoints.Count>=2 then begin
          UpdateSplineFromPoints(interactiveData.PSpline^,APointType,
            interactiveData.UserPoints.PTArr(interactiveData.UserPoints.getPFirst)^
            [0..interactiveData.UserPoints.Count-1]);

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
var
  pt:TPointsType;
begin
  if uppercase(operands)='CP' then
    pt:=PTControl
  else
    pt:=PTOnCurve;
  Result:=InteractiveDrawSpline(pt,Context);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawSpline_com,'Spline',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
