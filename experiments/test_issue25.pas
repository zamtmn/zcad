program test_issue25;

{$mode objfpc}{$H+}

uses
  SysUtils, Math;

type
  TVector3D = record
    x, y, z: Double;
  end;

  TMatrix4D = array[0..3, 0..3] of Double;

function IdentityMatrix: TMatrix4D;
var
  i, j: Integer;
begin
  for i := 0 to 3 do
    for j := 0 to 3 do
      if i = j then
        Result[i, j] := 1.0
      else
        Result[i, j] := 0.0;
end;

function CreateRotationMatrixZ(angleRad: Double): TMatrix4D;
var
  c, s: Double;
begin
  Result := IdentityMatrix;
  c := Cos(angleRad);
  s := Sin(angleRad);
  Result[0, 0] := c;
  Result[0, 1] := -s;
  Result[1, 0] := s;
  Result[1, 1] := c;
end;

function CreateTranslationMatrix(dx, dy, dz: Double): TMatrix4D;
begin
  Result := IdentityMatrix;
  Result[3, 0] := dx;
  Result[3, 1] := dy;
  Result[3, 2] := dz;
end;

function MultiplyMatrix(const A, B: TMatrix4D): TMatrix4D;
var
  i, j, k: Integer;
begin
  for i := 0 to 3 do
    for j := 0 to 3 do begin
      Result[i, j] := 0.0;
      for k := 0 to 3 do
        Result[i, j] := Result[i, j] + A[i, k] * B[k, j];
    end;
end;

function TransformPoint(const P: TVector3D; const M: TMatrix4D): TVector3D;
begin
  Result.x := P.x * M[0, 0] + P.y * M[1, 0] + P.z * M[2, 0] + M[3, 0];
  Result.y := P.x * M[0, 1] + P.y * M[1, 1] + P.z * M[2, 1] + M[3, 1];
  Result.z := P.x * M[0, 2] + P.y * M[1, 2] + P.z * M[2, 2] + M[3, 2];
end;

function TransformAngle(angle, rotationAngle: Double): Double;
begin
  Result := angle + rotationAngle;
  while Result >= 360.0 do
    Result := Result - 360.0;
  while Result < 0.0 do
    Result := Result + 360.0;
end;

var
  arcCenter, rotCenter, newCenter: TVector3D;
  startAngle, endAngle, rotAngle: Double;
  radius: Double;
  M, T1, R, T2: TMatrix4D;
  newStartAngle, newEndAngle: Double;

begin
  WriteLn('=== Test Issue #25: Arc Rotation ===');
  WriteLn;

  arcCenter.x := 2.0;
  arcCenter.y := 5.0;
  arcCenter.z := 0.0;
  radius := 10.0;
  startAngle := 8.0;
  endAngle := 94.0;

  WriteLn('Original Arc:');
  WriteLn('  Center: (', arcCenter.x:0:4, ', ', arcCenter.y:0:4, ', ', arcCenter.z:0:4, ')');
  WriteLn('  Radius: ', radius:0:4);
  WriteLn('  Start Angle: ', startAngle:0:4, '°');
  WriteLn('  End Angle: ', endAngle:0:4, '°');
  WriteLn;

  rotCenter.x := 1.0;
  rotCenter.y := 1.0;
  rotCenter.z := 1.0;
  rotAngle := 25.0;

  WriteLn('Rotation:');
  WriteLn('  Around point: (', rotCenter.x:0:4, ', ', rotCenter.y:0:4, ', ', rotCenter.z:0:4, ')');
  WriteLn('  Angle: ', rotAngle:0:4, '°');
  WriteLn;

  T1 := CreateTranslationMatrix(-rotCenter.x, -rotCenter.y, -rotCenter.z);
  R := CreateRotationMatrixZ(DegToRad(rotAngle));
  T2 := CreateTranslationMatrix(rotCenter.x, rotCenter.y, rotCenter.z);

  M := MultiplyMatrix(T1, R);
  M := MultiplyMatrix(M, T2);

  newCenter := TransformPoint(arcCenter, M);
  newStartAngle := TransformAngle(startAngle, rotAngle);
  newEndAngle := TransformAngle(endAngle, rotAngle);

  WriteLn('Transformed Arc (Simple Calculation):');
  WriteLn('  Center: (', newCenter.x:0:4, ', ', newCenter.y:0:4, ', ', newCenter.z:0:4, ')');
  WriteLn('  Radius: ', radius:0:4);
  WriteLn('  Start Angle: ', newStartAngle:0:4, '°');
  WriteLn('  End Angle: ', newEndAngle:0:4, '°');
  WriteLn;

  WriteLn('Expected (from issue #25):');
  WriteLn('  Center: (-0.2158, 5.0478, 0.0000)');
  WriteLn('  Radius: 10.0000');
  WriteLn('  Start Angle: 33.0000°');
  WriteLn('  End Angle: 119.0000°');
  WriteLn;

  ReadLn;
end.
