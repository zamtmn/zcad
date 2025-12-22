program test_spline_interpolation;

{$mode delphi}

uses
  SysUtils, Math;

type
  GDBVertex = record
    x, y, z: Double;
  end;

  TSingleArray = array of Single;
  TMatrix = array of TSingleArray;
  TControlPointsArray = array of GDBVertex;

// Test data from issue #253
const
  // Input: 7 points that should be ON the curve
  FIT_POINTS: array[0..6] of GDBVertex = (
    (x: 1583.2136549257; y: 417.836639195; z: 0),
    (x: 2346.3909069169; y: 988.9560396917; z: 0),
    (x: 1396.2099574179; y: 1772.3499076297; z: 0),
    (x: -392.9605538726; y: 1716.754213776; z: 0),
    (x: -41.2801529313; y: 2784.8206166348; z: 0),
    (x: 1717.1218517754; y: 2954.1482170881; z: 0),
    (x: 3449.4734564123; y: 2146.5858149265; z: 0)
  );

  // Expected output: 9 control points for degree 3 NURBS
  EXPECTED_CONTROL_POINTS: array[0..8] of GDBVertex = (
    (x: 1583.2137; y: 417.8366; z: 0),
    (x: 1943.9619; y: 588.3078; z: 0),
    (x: 2770.7705; y: 979.0151; z: 0),
    (x: 1225.7225; y: 2260.4551; z: 0),
    (x: -771.0874; y: 1052.6822; z: 0),
    (x: -50.7662; y: 3342.0538; z: 0),
    (x: 1877.21; y: 3020.2007; z: 0),
    (x: 2911.8082; y: 2445.335; z: 0),
    (x: 3449.4735; y: 2146.5858; z: 0)
  );

  DEGREE = 3;

function BasisFunction(i, p: Integer; u: Single; const knots: array of Single): Single;
var
  BasisValues: array of Single;
  j, k: Integer;
  saved, temp: Single;
  uleft, uright: Single;
  numCtrlPts: Integer;
begin
  numCtrlPts := Length(knots) - p - 2;
  if Abs(u - knots[Length(knots) - 1]) < 1e-10 then begin
    if i = numCtrlPts then
      Result := 1.0
    else
      Result := 0.0;
    Exit;
  end;

  if p = 0 then begin
    if (u >= knots[i]) and (u < knots[i + 1]) then
      Result := 1.0
    else if (Abs(u - knots[i + 1]) < 1e-10) and (i + 1 = Length(knots) - 1) then
      Result := 1.0
    else
      Result := 0.0;
    Exit;
  end;

  SetLength(BasisValues, p + 1);

  for j := 0 to p do begin
    if (u >= knots[i + j]) and (u < knots[i + j + 1]) then
      BasisValues[j] := 1.0
    else if (Abs(u - knots[i + j + 1]) < 1e-10) and (i + j + 1 = Length(knots) - 1) then
      BasisValues[j] := 1.0
    else
      BasisValues[j] := 0.0;
  end;

  for k := 1 to p do begin
    if BasisValues[0] = 0.0 then
      saved := 0.0
    else begin
      uright := knots[i + k];
      uleft := knots[i];
      if Abs(uright - uleft) < 1e-10 then
        saved := 0.0
      else
        saved := ((u - uleft) / (uright - uleft)) * BasisValues[0];
    end;

    for j := 0 to p - k do begin
      uleft := knots[i + j + 1];
      uright := knots[i + j + k + 1];

      if BasisValues[j + 1] = 0.0 then begin
        BasisValues[j] := saved;
        saved := 0.0;
      end else begin
        if Abs(uright - uleft) < 1e-10 then
          temp := 0.0
        else
          temp := ((uright - u) / (uright - uleft)) * BasisValues[j + 1];
        BasisValues[j] := saved + temp;

        if Abs(knots[i + j + k + 1] - knots[i + j + 1]) < 1e-10 then
          saved := 0.0
        else
          saved := ((u - knots[i + j + 1]) / (knots[i + j + k + 1] - knots[i + j + 1])) * BasisValues[j + 1];
      end;
    end;
  end;

  Result := BasisValues[0];
end;

procedure ComputeParameters(const points: array of GDBVertex; var params: array of Single);
var
  i: Integer;
  totalLength, chordLength: Single;
begin
  if Length(points) < 2 then
    Exit;

  params[0] := 0.0;
  params[Length(points) - 1] := 1.0;

  if Length(points) = 2 then
    Exit;

  totalLength := 0.0;
  for i := 0 to Length(points) - 2 do begin
    chordLength := Sqrt(
      Sqr(points[i + 1].x - points[i].x) +
      Sqr(points[i + 1].y - points[i].y) +
      Sqr(points[i + 1].z - points[i].z)
    );
    totalLength := totalLength + chordLength;
    params[i + 1] := totalLength;
  end;

  if totalLength > 0.0001 then
    for i := 1 to Length(points) - 1 do
      params[i] := params[i] / totalLength
  else
    for i := 1 to Length(points) - 1 do
      params[i] := i / (Length(points) - 1);
end;

procedure GenerateKnotVector(n, p: Integer; const params: array of Single; var knots: array of Single);
var
  i, j: Integer;
  m: Integer;
  sum: Single;
begin
  m := n + p + 1;

  for i := 0 to p do
    knots[i] := 0.0;

  for j := 1 to n - p do begin
    sum := 0.0;
    for i := j to j + p - 1 do
      sum := sum + params[i];
    knots[j + p] := sum / p;
  end;

  for i := n + 1 to m do
    knots[i] := 1.0;
end;

procedure SolveLinearSystem(var A: TMatrix; const b: array of Single; var x: array of Single; n: Integer);
var
  i, j, k, maxRow: Integer;
  maxVal, tmp, factor: Single;
  c: array of Single;
begin
  SetLength(c, n);
  for i := 0 to n - 1 do
    c[i] := b[i];

  for k := 0 to n - 2 do begin
    maxRow := k;
    maxVal := Abs(A[k][k]);
    for i := k + 1 to n - 1 do begin
      if Abs(A[i][k]) > maxVal then begin
        maxVal := Abs(A[i][k]);
        maxRow := i;
      end;
    end;

    if maxRow <> k then begin
      for j := k to n - 1 do begin
        tmp := A[k][j];
        A[k][j] := A[maxRow][j];
        A[maxRow][j] := tmp;
      end;
      tmp := c[k];
      c[k] := c[maxRow];
      c[maxRow] := tmp;
    end;

    for i := k + 1 to n - 1 do begin
      if Abs(A[k][k]) > 1e-10 then begin
        factor := A[i][k] / A[k][k];
        for j := k to n - 1 do
          A[i][j] := A[i][j] - factor * A[k][j];
        c[i] := c[i] - factor * c[k];
      end;
    end;
  end;

  for i := n - 1 downto 0 do begin
    x[i] := c[i];
    for j := i + 1 to n - 1 do
      x[i] := x[i] - A[i][j] * x[j];
    if Abs(A[i][i]) > 1e-10 then
      x[i] := x[i] / A[i][i]
    else
      x[i] := 0;
  end;
end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree: Integer;
  const AOnCurvePoints: array of GDBVertex; var AKnots: TSingleArray): TControlPointsArray;
var
  numPoints, numControlPoints, i, j, k, n, m, numKnots: Integer;
  params: array of Single;
  knots: array of Single;
  u: Single;
  A: TMatrix;
  b_x, b_y, b_z: TSingleArray;
  x_x, x_y, x_z: TSingleArray;
  basis: Single;
begin
  // STANDARD B-spline Global Interpolation (Piegl & Tiller, Algorithm A9.1)
  // For m+1 fit points with degree p:
  // Number of control points: n+1 = m+1 (same as number of fit points)
  // where n = m (indices 0 to n)

  numPoints := Length(AOnCurvePoints);

  if numPoints < 2 then begin
    SetLength(Result, 0);
    SetLength(AKnots, 0);
    Exit;
  end;

  if ADegree >= numPoints then begin
    SetLength(Result, numPoints);
    for i := 0 to numPoints - 1 do
      Result[i] := AOnCurvePoints[i];
    SetLength(AKnots, 0);
    Exit;
  end;

  if ADegree < 1 then begin
    SetLength(Result, numPoints);
    for i := 0 to numPoints - 1 do
      Result[i] := AOnCurvePoints[i];
    SetLength(AKnots, 0);
    Exit;
  end;

  if ADegree = 1 then begin
    SetLength(Result, numPoints);
    for i := 0 to numPoints - 1 do
      Result[i] := AOnCurvePoints[i];
    SetLength(AKnots, 0);
    Exit;
  end;

  if numPoints = 2 then begin
    SetLength(Result, 2);
    Result[0] := AOnCurvePoints[0];
    Result[1] := AOnCurvePoints[1];
    SetLength(AKnots, 0);
    Exit;
  end;

  // Standard global interpolation: n+1 = m+1
  // where m = numPoints - 1 (last fit point index)
  m := numPoints - 1;
  n := m;  // n = m for standard interpolation
  numControlPoints := n + 1;  // n+1 = m+1 = numPoints control points
  SetLength(Result, numControlPoints);

  // Step 1: Compute parameter values using chord length parameterization
  SetLength(params, numPoints);
  ComputeParameters(AOnCurvePoints, params);

  // Step 2: Generate knot vector
  // Knot vector has n+p+2 elements
  numKnots := n + ADegree + 2;
  SetLength(knots, numKnots);
  GenerateKnotVector(n, ADegree, params, knots);

  SetLength(AKnots, Length(knots));
  for i := 0 to Length(knots) - 1 do
    AKnots[i] := knots[i];

  // Step 3: Build the interpolation matrix system
  // We have n+1 = m+1 control points and m+1 fit points
  // Build (m+1) × (m+1) matrix: C(t_k) = sum(N_i,p(t_k) * P_i) = D_k
  SetLength(A, numPoints);
  for k := 0 to numPoints - 1 do
    SetLength(A[k], numControlPoints);

  SetLength(b_x, numPoints);
  SetLength(b_y, numPoints);
  SetLength(b_z, numPoints);
  SetLength(x_x, numControlPoints);
  SetLength(x_y, numControlPoints);
  SetLength(x_z, numControlPoints);

  // Build the matrix
  for k := 0 to numPoints - 1 do begin
    // Right-hand side: fit point
    b_x[k] := AOnCurvePoints[k].x;
    b_y[k] := AOnCurvePoints[k].y;
    b_z[k] := AOnCurvePoints[k].z;

    // Matrix row: basis functions evaluated at parameter t_k
    for i := 0 to numControlPoints - 1 do begin
      basis := BasisFunction(i, ADegree, params[k], knots);
      A[k][i] := basis;
    end;
  end;

  // Solve the linear system
  SolveLinearSystem(A, b_x, x_x, numControlPoints);
  SolveLinearSystem(A, b_y, x_y, numControlPoints);
  SolveLinearSystem(A, b_z, x_z, numControlPoints);

  // Store results
  for i := 0 to numControlPoints - 1 do begin
    Result[i].x := x_x[i];
    Result[i].y := x_y[i];
    Result[i].z := x_z[i];
  end;
end;

procedure RunTest;
var
  controlPoints: TControlPointsArray;
  knots: TSingleArray;
  i: Integer;
  maxError: Double;
  error: Double;
begin
  WriteLn('Testing NURBS Global Interpolation');
  WriteLn('===================================');
  WriteLn;
  WriteLn('Input: ', Length(FIT_POINTS), ' fit points');
  WriteLn('Degree: ', DEGREE);
  WriteLn('Expected output: ', Length(EXPECTED_CONTROL_POINTS), ' control points');
  WriteLn;

  // Convert fit points to control points
  controlPoints := ConvertOnCurvePointsToControlPointsArray(DEGREE, FIT_POINTS, knots);

  WriteLn('Computed ', Length(controlPoints), ' control points:');
  WriteLn;

  maxError := 0.0;
  for i := 0 to Length(controlPoints) - 1 do begin
    WriteLn(Format('P%d: (%.4f, %.4f, %.4f)', [i, controlPoints[i].x, controlPoints[i].y, controlPoints[i].z]));

    if i < Length(EXPECTED_CONTROL_POINTS) then begin
      error := Sqrt(
        Sqr(controlPoints[i].x - EXPECTED_CONTROL_POINTS[i].x) +
        Sqr(controlPoints[i].y - EXPECTED_CONTROL_POINTS[i].y) +
        Sqr(controlPoints[i].z - EXPECTED_CONTROL_POINTS[i].z)
      );
      WriteLn(Format('    Expected: (%.4f, %.4f, %.4f) - Error: %.4f',
        [EXPECTED_CONTROL_POINTS[i].x, EXPECTED_CONTROL_POINTS[i].y, EXPECTED_CONTROL_POINTS[i].z, error]));
      if error > maxError then
        maxError := error;
    end;
  end;

  WriteLn;
  WriteLn('Knot vector (', Length(knots), ' elements):');
  for i := 0 to Length(knots) - 1 do
    Write(Format('%.4f ', [knots[i]]));
  WriteLn;
  WriteLn;

  WriteLn('Maximum error: ', maxError:0:4);

  if maxError < 0.01 then
    WriteLn('TEST PASSED!')
  else
    WriteLn('TEST FAILED - Error too large');
end;

begin
  try
    RunTest;
  except
    on E: Exception do
      WriteLn('ERROR: ', E.Message);
  end;

  WriteLn;
  WriteLn('Press Enter to exit...');
  ReadLn;
end.
