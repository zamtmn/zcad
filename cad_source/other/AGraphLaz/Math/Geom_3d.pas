{ Version 990825. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit Geom_3d;

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Aliasm, F32g, F64g, F80g, F32m, F64m, F80m;

procedure BuildPlane(M1, M2, M3: TGenericFloatVector; var A, B, C, D: Float);
{ Builds plane (Ax + By + Cz + D = 0) that contains points M1, M2, M3 }

function BuildCircle(M1, M2, M3: TGenericFloatVector; var x0, y0, z0, R: Float): Bool;
{ Builds circle that contains points M1, M2 and M3, if the circle exists
  (if no, returns False) }

function BuildSphere(M1, M2, M3, M4: TGenericFloatVector; var x0, y0, z0, R: Float): Bool;
{ Builds sphere that contains points M1, M2, M3 and M4, if the sphere exists
  (if no, returns False) }

implementation

uses Gauss;

const
  Eps = 1E-6;

procedure BuildPlane(M1, M2, M3: TGenericFloatVector; var A, B, C, D: Float);
begin
  A:=(M2[1] - M1[1]) * (M3[2] - M1[2]) - (M2[2] - M1[2]) * (M3[1] - M1[1]);
  B:=(M3[0] - M1[0]) * (M2[2] - M1[2]) - (M2[0] - M1[0]) * (M3[2] - M1[2]);
  C:=(M2[0] - M1[0]) * (M3[1] - M1[1]) - (M2[1] - M1[1]) * (M3[0] - M1[0]);
  D:= - M1[0] * A - M1[1] * B - M1[2] * C;
end;

function BuildCircle(M1, M2, M3: TGenericFloatVector; var x0, y0, z0, R: Float): Bool;
var
  Matrix: TFloatMatrix;
  f, x: TFloatVector;
  A, B, C, D: Float;
begin
  Result:=False;
  BuildPlane(M1, M2, M3, A, B, C, D);
  if (A <> 0) or (B <> 0) or (C <> 0) then begin
    Matrix:=TFloatMatrix.Create(4, 4, 1);
    f:=TFloatVector.Create(4, 0);
    x:=TFloatVector.Create(4, 0);
    try
      Matrix[0, 0]:=M1[0];
      Matrix[0, 1]:=M1[1];
      Matrix[0, 2]:=M1[2];
{      Matrix[0, 3]:=1; - default value }
      Matrix[1, 0]:=M2[0];
      Matrix[1, 1]:=M2[1];
      Matrix[1, 2]:=M2[2];
{      Matrix[1, 3]:=1;}
      Matrix[2, 0]:=M3[0];
      Matrix[2, 1]:=M3[1];
      Matrix[2, 2]:=M3[2];
{      Matrix[2, 3]:=1;}
      Matrix[3, 0]:=A;
      Matrix[3, 1]:=B;
      Matrix[3, 2]:=C;
      Matrix[3, 3]:=0;
      f[0]:=(Sqr(M1[0]) + Sqr(M1[1]) + Sqr(M1[2])) / 2;
      f[1]:=(Sqr(M2[0]) + Sqr(M2[1]) + Sqr(M2[2])) / 2;
      f[2]:=(Sqr(M3[0]) + Sqr(M3[1]) + Sqr(M3[2])) / 2;
      f[3]:= -D;
      if SolveLinearSystem(Matrix, f, x, Eps) > 0 then begin
        x0:=x[0];
        y0:=x[1];
        z0:=x[2];
        R:=Sqrt(Sqr(x0) + Sqr(y0) + Sqr(z0) + 2 * x[3]);
        Result:=True;
      end;
    finally
      Matrix.Free;
      f.Free;
      x.Free;
    end;
  end;
end;

function BuildSphere(M1, M2, M3, M4: TGenericFloatVector; var x0, y0, z0, R: Float): Bool;
var
  Matrix: TFloatMatrix;
  f, x: TFloatVector;
begin
  Matrix:=TFloatMatrix.Create(4, 4, 1);
  f:=TFloatVector.Create(4, 0);
  x:=TFloatVector.Create(4, 0);
  try
    Matrix[0, 0]:=M1[0];
    Matrix[0, 1]:=M1[1];
    Matrix[0, 2]:=M1[2];
{    Matrix[0, 3]:=1;}
    Matrix[1, 0]:=M2[0];
    Matrix[1, 1]:=M2[1];
    Matrix[1, 2]:=M2[2];
{    Matrix[1, 3]:=1;}
    Matrix[2, 0]:=M3[0];
    Matrix[2, 1]:=M3[1];
    Matrix[2, 2]:=M3[2];
{    Matrix[2, 3]:=1;}
    Matrix[3, 0]:=M4[0];
    Matrix[3, 1]:=M4[1];
    Matrix[3, 2]:=M4[2];
{    Matrix[3, 3]:=1;}
    f[0]:=(Sqr(M1[0]) + Sqr(M1[1]) + Sqr(M1[2]));
    f[1]:=(Sqr(M2[0]) + Sqr(M2[1]) + Sqr(M2[2]));
    f[2]:=(Sqr(M3[0]) + Sqr(M3[1]) + Sqr(M3[2]));
    f[3]:=(Sqr(M4[0]) + Sqr(M4[1]) + Sqr(M4[2]));
    if SolveLinearSystem(Matrix, f, x, Eps) > 0 then begin
      x0:=x[0] / 2;
      y0:=x[1] / 2;
      z0:=x[2] / 2;
      R:=Sqrt(Sqr(x0) + Sqr(y0) + Sqr(z0) + x[3]);
      Result:=True;
    end
    else
      Result:=False;
  finally
    Matrix.Free;
    f.Free;
    x.Free;
  end;
end;

end.
