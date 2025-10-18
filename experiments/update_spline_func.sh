#!/bin/bash

# Script to update the spline conversion function

FILE="cad_source/zcad/commands/uzccommand_spline.pas"

# Create the new helper function and updated main function
cat > /tmp/new_functions.pas << 'EOF'

// Helper function to compute second derivative of basis function
// Uses finite difference approximation
function BasisFunctionSecondDerivative(i,p:integer;u:single;const knots:array of single):single;
var
  h:single;
  f_plus,f_center,f_minus:single;
  u_eval:single;
begin
  h:=1e-6;

  // Adjust u to avoid boundary issues
  if u<h then
    u_eval:=h
  else if u>1.0-h then
    u_eval:=1.0-h
  else
    u_eval:=u;

  // Evaluate basis function at three points
  f_plus:=BasisFunction(i,p,Min(u_eval+h,1.0),knots);
  f_center:=BasisFunction(i,p,u_eval,knots);
  f_minus:=BasisFunction(i,p,Max(u_eval-h,0.0),knots);

  // Second derivative using central difference
  Result:=(f_plus - 2.0*f_center + f_minus) / (h*h);
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of GDBVertex;var AKnots:TSingleArray):TControlPointsArray;
var
  numPoints,numControlPoints,i,j,k,n,m,numKnots,numEq:integer;
  params:array of single;
  knots:array of single;
  A:TMatrix;
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
    SetLength(AKnots,0);
    exit;
  end;

  // For degree >= numPoints, return the points themselves
  if ADegree>=numPoints then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    SetLength(AKnots,0);
    exit;
  end;

  // For degree < 1, invalid
  if ADegree<1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    SetLength(AKnots,0);
    exit;
  end;

  // For degree 1 (linear), return the points as-is
  if ADegree=1 then begin
    SetLength(Result,numPoints);
    for i:=0 to numPoints-1 do
      Result[i]:=AOnCurvePoints[i];
    SetLength(AKnots,0);
    exit;
  end;

  // Special case: only 2 points
  if numPoints=2 then begin
    SetLength(Result,2);
    Result[0]:=AOnCurvePoints[0];
    Result[1]:=AOnCurvePoints[1];
    SetLength(AKnots,0);
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
  SetLength(AKnots,Length(knots));
  for i:=0 to Length(knots)-1 do
    AKnots[i]:=knots[i];

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
  SolveLinearSystem(A,b_x,x_x,numEq);
  SolveLinearSystem(A,b_y,x_y,numEq);
  SolveLinearSystem(A,b_z,x_z,numEq);

  // Store results
  for i:=0 to numControlPoints-1 do begin
    Result[i].x:=x_x[i];
    Result[i].y:=x_y[i];
    Result[i].z:=x_z[i];
  end;
end;
EOF

# Create a sed script to replace the function
# First, extract lines before the function (lines 1-280)
head -n 280 "$FILE" > /tmp/spline_new.pas

# Add the new functions
cat /tmp/new_functions.pas >> /tmp/spline_new.pas

# Add lines after the old function (from line 421 onwards)
tail -n +421 "$FILE" >> /tmp/spline_new.pas

# Replace the original file
mv /tmp/spline_new.pas "$FILE"

echo "File updated successfully"
