{ Version 990830. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit SLS_Iter;
{
  –ешение системы линейных уравнений итерационным методом минимизации нев€зок.

  —истема: Ax = f;
  итерационна€ формула: (x(n+1) - x(n))/t(n+1) + Ax(n)=f;
  нев€зка: r(n)=Ax(n) - f;
  t(n+1)=(r(n), Ar(n)) / (Ar(n), Ar(n)).

  ƒостаточное условие сходимости: A > 0.
}

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Aliasm, F32v, F64v, F80v, F32m, F64m, F80m, VectErr;

function SolveLinearSystemIter(A: TFloatMatrix; f: TFloatVector;
  MaxIter: Integer; Precision: Float; x: TFloatVector): Bool;
{ Ќа входе:
  A - матрица коэффициентов (квадратна€); f - вектор правой части;
  MaxIter - максимальное количество операций, которые разрешаетс€ осуществить;
  Precision - точность (выход произойдет при |r(n)| <= Precision).

  A и f должны быть правильной размерности.

  Ќа выходе: результат равен True, если достигнута требуема€ точность, и False,
  если произошел выход по превышению количества итераций MaxIter;
  x - приближенное решение. }

implementation

function SolveLinearSystemIter(A: TFloatMatrix; f: TFloatVector;
  MaxIter: Integer; Precision: Float; x: TFloatVector): Bool;
var
  xn, Arn, rn: TFloatMatrix;
  I, m: Integer;
begin
  {$IFDEF CHECK_MATH}
  if (A.RowCount <> A.ColCount) or (A.RowCount <> x.Count) or
    (A.RowCount <> f.Count) then TFloatMatrix.Error(SErrorInParameters, [0]);
  {$ENDIF}
  Result:=False;
  m:=A.RowCount;
  xn:=TFloatMatrix.Create(m, 1, 0); { x(0):=0 }
  rn:=TFloatMatrix.Create(m, 1, 0);
  Arn:=TFloatMatrix.Create(m, 1, 0);
  Precision:=Sqr(Precision);
  try
    rn.Vector.SubVector(f); { r(0):=-f }
    for I:=0 to MaxIter - 1 do begin
      if rn.Vector.SqrSum <= Precision then begin
        Result:=True;
        Break;
      end;
      Arn.MatrixProduct(A, rn); { Ar(n):=A*r(n) }
      xn.Vector.AddScaled( - Arn.Vector.DotProduct(rn.Vector) /
        Arn.Vector.DotProduct(Arn.Vector), rn.Vector); { x(n+1):=-t(n+1)*r(n)+x(n) }
      rn.MatrixProduct(A, xn); { r(n):=A*x(n) }
      rn.Vector.SubVector(f); { r(n):=A*x(n)-f }
    end;
    x.Assign(xn.Vector);
  finally
    xn.Free;
    rn.Free;
    Arn.Free;
  end;
end;

end.
