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
unit uzeNURBSUtils;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzegeometrytypes,
  uzeNURBSTypes;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of TzePoint3d;var AKnots:TKnotsVector):TControlPointsArray;

implementation

type
  TMatrix=array of TSingleArray;

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
procedure ComputeParameters(const points:array of TzePoint3d;var params:array of single);
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
// Based on STANDARD B-spline interpolation algorithm (Piegl & Tiller, "The NURBS Book", Algorithm A9.1)
// For m+1 data points with degree p, we have n=m control points
// Knot vector has n+p+2 elements
procedure GenerateKnotVector(n,p:integer;const params:array of single;var knots:array of single);
var
  i,j:integer;
  m:integer;
  sum:single;
begin
  // For standard interpolation: m = n (same number of control points as data points)
  // Knot vector length: m+1 where m = n+p+1
  // So: length = n+p+1+1 = n+p+2
  m:=n+p+1;

  // Clamped knot vector: repeat 0 (p+1) times at start
  for i:=0 to p do
    knots[i]:=0.0;

  // Internal knots: average p consecutive parameter values
  // Formula: u_{j+p} = (1/p) * sum_{i=j}^{j+p-1} t_i
  // for j = 1, 2, ..., n-p
  for j:=1 to n-p do begin
    sum:=0.0;
    for i:=j to j+p-1 do
      sum:=sum+params[i];
    knots[j+p]:=sum/p;
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


// New implementation of ConvertOnCurvePointsToControlPointsArray
// with natural boundary conditions

// Helper function to compute derivative of basis function
// Uses analytical recursive formula for B-spline derivatives
// N'_{i,p}(u) = p/(u_{i+p} - u_i) * N_{i,p-1}(u) - p/(u_{i+p+1} - u_{i+1}) * N_{i+1,p-1}(u)
function BasisFunctionDerivative(i,p:integer;u:single;const knots:array of single;deriv:integer):single;
var
  denom1,denom2:single;
  term1,term2:single;
  u_eval:single;
begin
  // Base case: no derivative, just return basis function value
  if deriv=0 then begin
    Result:=BasisFunction(i,p,u,knots);
    exit;
  end;

  // Base case: degree 0 basis functions have zero derivative
  if p=0 then begin
    Result:=0.0;
    exit;
  end;

  // For derivatives at the endpoint u=1.0, use a slight offset to avoid special case issues
  // This evaluates the left-side limit of the derivative
  u_eval:=u;
  if abs(u-1.0)<1e-10 then
    u_eval:=1.0-1e-6;

  // Recursive formula for derivative
  denom1:=knots[i+p]-knots[i];
  denom2:=knots[i+p+1]-knots[i+1];

  term1:=0.0;
  if abs(denom1)>1e-10 then
    term1:=p/denom1*BasisFunctionDerivative(i,p-1,u_eval,knots,deriv-1);

  term2:=0.0;
  if abs(denom2)>1e-10 then
    term2:=p/denom2*BasisFunctionDerivative(i+1,p-1,u_eval,knots,deriv-1);

  Result:=term1-term2;
end;

// Helper function to compute second derivative of basis function
function BasisFunctionSecondDerivative(i,p:integer;u:single;const knots:array of single):single;
begin
  Result:=BasisFunctionDerivative(i,p,u,knots,2);
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of TzePoint3d;var AKnots:TKnotsVector):TControlPointsArray;
var
  numPoints,numControlPoints,i,j,k,n,m,numKnots,numEq:integer;
  params:array of single;
  knots:array of single;
  A,A_copy:TMatrix;
  b_x,b_y,b_z:TSingleArray;
  x_x,x_y,x_z:TSingleArray;
  basis,deriv2:single;
begin
  // B-spline Interpolation with Natural Boundary Conditions
  // For cubic splines (degree 3), this produces n+1 = m+3 control points
  // where m+1 is the number of data points
  // Based on scipy.interpolate.make_interp_spline with bc_type='natural'

  numPoints:=Length(AOnCurvePoints);

  // Handle edge cases
  if numPoints<2 then begin
    SetLength(Result,0);
    AKnots.Clear;
    //SetLength(AKnots,0);
    exit;
  end;

  // For degree >= numPoints, return the points themselves
  if ADegree>=numPoints then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    AKnots.Clear;
    //SetLength(AKnots,0);
    exit;
  end;

  // For degree < 1, invalid
  if ADegree<1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    AKnots.Clear;
    //SetLength(AKnots,0);
    exit;
  end;

  // For degree 1 (linear), return the points as-is
  if ADegree=1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    AKnots.Clear;
    //SetLength(AKnots,0);
    exit;
  end;

  // Special case: only 2 points
  if numPoints=2 then begin
    SetLength(Result,2);
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
    AKnots.Clear;
    //SetLength(AKnots,0);
    exit;
  end;

  // Natural spline interpolation:
  // For m+1 fit points (indexed 0 to m): generate n+1 = m+3 control points (for degree 3)
  // This adds 2 extra control points to satisfy natural boundary conditions
  m:=numPoints-1;  // m is index of last fit point
  n:=m+2;          // n = m+2 for natural spline (n+1 = m+3 control points)
  numControlPoints:=n+1;
  SetLength(Result,numControlPoints);

  // Step 1: Compute parameter values using chord length parameterization
  SetLength(params,numPoints);
  ComputeParameters(AOnCurvePoints,params);

  // Step 2: Generate knot vector - place internal parameter values as knots
  // For natural spline with n+1 control points, degree p:
  // Knot vector has n+p+2 elements
  // Format: [0,0,0,0, param[1], param[2], ..., param[m-1], 1,1,1,1]
  // Note: we skip param[0]=0 and param[m]=1 in the internal knots
  numKnots:=n+ADegree+2;
  SetLength(knots,numKnots);

  // Clamped: first p+1 knots are 0
  for i:=0 to ADegree do
    knots[i]:=0.0;

  // Internal knots: place at parameter values (skip first and last)
  for i:=1 to numPoints-2 do
    knots[ADegree+i]:=params[i];

  // Clamped: last p+1 knots are 1
  for i:=numKnots-ADegree-1 to numKnots-1 do
    knots[i]:=1.0;

  // Copy knots to output parameter
  AKnots.SetSize(Length(knots));
  AKnots.Clear;
  //SetLength(AKnots,Length(knots));
  for i:=0 to Length(knots)-1 do
    AKnots.PushBackData(knots[i]);//AKnots[i]:=knots[i];

  // Step 3: Build the augmented matrix system
  // We have (m+1) interpolation constraints + 2 natural boundary conditions
  // This gives us (m+3) equations for (m+3) unknowns - a square system
  numEq:=numPoints+2;

  SetLength(A,numEq);
  for k:=0 to numEq-1 do
    SetLength(A[k],numControlPoints);

  SetLength(b_x,numEq);
  SetLength(b_y,numEq);
  SetLength(b_z,numEq);
  SetLength(x_x,numControlPoints);
  SetLength(x_y,numControlPoints);
  SetLength(x_z,numControlPoints);

  // Build the interpolation constraint rows (first m+1 rows)
  for k:=0 to numPoints-1 do begin
    // Right-hand side: fit point
    b_x[k]:=AOnCurvePoints[k].x;
    b_y[k]:=AOnCurvePoints[k].y;
    b_z[k]:=AOnCurvePoints[k].z;

    // Matrix row: basis functions at parameter t_k
    for i:=0 to numControlPoints-1 do begin
      basis:=BasisFunction(i,ADegree,params[k],knots);
      A[k][i]:=basis;
    end;
  end;

  // Build the natural boundary condition rows (last 2 rows)
  // Natural BC: second derivative = 0 at start (u=0) and end (u=1)

  // Row for start boundary (second derivative = 0 at params[0])
  b_x[numPoints]:=0.0;
  b_y[numPoints]:=0.0;
  b_z[numPoints]:=0.0;
  for i:=0 to numControlPoints-1 do begin
    deriv2:=BasisFunctionSecondDerivative(i,ADegree,params[0],knots);
    A[numPoints][i]:=deriv2;
  end;

  // Row for end boundary (second derivative = 0 at params[m])
  b_x[numPoints+1]:=0.0;
  b_y[numPoints+1]:=0.0;
  b_z[numPoints+1]:=0.0;
  for i:=0 to numControlPoints-1 do begin
    deriv2:=BasisFunctionSecondDerivative(i,ADegree,params[m],knots);
    A[numPoints+1][i]:=deriv2;
  end;

  // Solve the linear system (now it's a square system: (m+3) × (m+3))
  // NOTE: SolveLinearSystem modifies matrix A during Gaussian elimination,
  // so we need to make a copy before solving for each coordinate

  // Save original matrix A before it gets modified
  SetLength(A_copy,numEq);
  for i:=0 to numEq-1 do begin
    SetLength(A_copy[i],numControlPoints);
    for j:=0 to numControlPoints-1 do
      A_copy[i][j]:=A[i][j];
  end;

  // Solve for X coordinates (this will modify A)
  SolveLinearSystem(A,b_x,x_x,numEq);

  // Solve for Y coordinates - restore A from copy first
  for i:=0 to numEq-1 do
    for j:=0 to numControlPoints-1 do
      A[i][j]:=A_copy[i][j];
  SolveLinearSystem(A,b_y,x_y,numEq);

  // Solve for Z coordinates - restore A from copy first
  for i:=0 to numEq-1 do
    for j:=0 to numControlPoints-1 do
      A[i][j]:=A_copy[i][j];
  SolveLinearSystem(A,b_z,x_z,numEq);

  // Store results
  for i:=0 to numControlPoints-1 do begin
    Result[i].x:=x_x[i];
    Result[i].y:=x_y[i];
    Result[i].z:=x_z[i];
  end;
end;

initialization

finalization
end.
