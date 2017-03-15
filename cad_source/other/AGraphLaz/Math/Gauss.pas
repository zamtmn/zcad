{ Version 990825. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit Gauss;
{
  1. Решение системы линейных уравнений методом Гаусса с выбором максимального
  по модулю элемента в столбце. Число операций умножения и деления: ~(m^3/3).

  2. Обращение матрицы. Число операций умножения и деления: ~(m^4/3).
  Примечание: существует более эффективный метод.
}

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Aliasm, Int16v, F32g, F64g, F80g, F32m, F32v, F64v, F80v,
  F64m, F80m, Boolv, VectErr, MathErr;

function SolveLinearSystem(A: TFloatMatrix; f: TGenericFloatVector;
  x: TGenericFloatVector; Eps: Float): Int8;
{
  На входе: система Ax = f, где

  A - матрица коэффициентов (квадратная); f - вектор правой части;
  x - вектор, в котором будет возвращено решение.

  Eps - малое неотрицательное число; задание Eps > 0 позволяет в некоторых
  случаях приближенно решать вырожденные и плохо обусловленные системы
  (системы, у которых собственные значения A близки к нулю).

  На выходе:
  1) результат > 0 => решение найдено (x - решение); если результат равен 1,
     то система имеет единственное решение; > 1 => более одного решения
     (x - одно из решений);
  2) результат равен -1 => система несовместна (в этом случае значение x
     не определено).
}

function MatrixInversion(A, B: TFloatMatrix): Bool;
{
  На входе:
  A - исходная матрица (квадратная); B - матрица результата (той же размерности).

  На выходе:
  1) True => матрица успешно обращена; B - результат;
  2) False => матрицу не удалось обратить (матрица A сингулярна); в этом случае
     значения B не определены.
}

implementation

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function SolveLinearSystem(A: TFloatMatrix; f: TGenericFloatVector;
  x: TGenericFloatVector; Eps: Float): Int8;
var
  Temp: TFloatMatrix;
  RowTrace: TIntegerVector;
  RowProcessed: TBoolVector;
  I, J, K, L, M: Integer;
  T1, T2: Float;
begin
  {$IFDEF CHECK_MATH}
  if (A.RowCount <> A.ColCount) or (A.RowCount <> x.Count) or
    (A.RowCount <> f.Count) then MathError(SErrorInParameters, [0]);
  {$ENDIF}
  Result:=1;
  M:=A.RowCount;
  Temp:=TFloatMatrix.Create(M, M + 1, 0);
  RowTrace:=TIntegerVector.Create(M, -1);
  RowProcessed:=TBoolVector.Create(M, False);
  try
    { инициализация }
    for I:=0 to M - 1 do begin
      for J:=0 to M - 1 do
        Temp[I, J]:=A[I, J];
      Temp[I, M]:=f[I];
    end;
    { прямой ход }
    for J:=0 to M - 1 do begin
      L:=-1;
      T1:=0;
      for I:=0 to M - 1 do
        if not RowProcessed[I] then begin
          K:=I;
          T2:=Abs(Temp[I, J]);
          if T2 > T1 then begin
            T1:=T2;
            L:=I;
          end;
        end;
      if L >= 0 then begin
        K:=L;
        RowProcessed[K]:=True;
        if J < M - 1 then begin
          T1:=Temp[K, J];
          for I:=0 to M - 1 do begin
            T2:=Temp[I, J];
            if (T2 <> 0) and not RowProcessed[I] then begin
              T2:=T2 / T1;
              Temp[I, J]:=0;
              for L:=J + 1 to M do
                Temp.DecItem(I, L, T2 * Temp[K, L]);
            end;
          end;
        end;
      end
      else begin
        RowProcessed[K]:=True;
        Result:=2;
      end;
      RowTrace[J]:=K;
    end;
    { обратный ход }
    for J:=M - 1 downto 0 do begin
      I:=RowTrace[J];
      T1:=Temp[I, M];
      for K:=J + 1 to M - 1 do
        T1:=T1 - Temp[I, K] * x[K];
      T2:=Temp[I, J];
      if T2 <> 0 then x[J]:=T1 / T2
      else
        if Abs(T1) < Eps then x[J]:=0 { любое значение }
        else begin { считаем, что система несовместна }
          Result:=-1;
          Exit;
        end;
    end;
  finally
    Temp.Free;
    RowTrace.Free;
    RowProcessed.Free;
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

function MatrixInversion(A, B: TFloatMatrix): Bool;
var
  I, J, M: Integer;
  f, x: TFloatVector;
begin
  {$IFDEF CHECK_MATH}
  if (A.RowCount <> A.ColCount) or (B.RowCount <> B.ColCount) or
    (A.RowCount <> B.RowCount) then TFloatMatrix.Error(SErrorInParameters, [0]);
  {$ENDIF}
  M:=A.RowCount;
  f:=TFloatVector.Create(M, 0);
  x:=TFloatVector.Create(M, 0);
  try
    for J:=0 to M - 1 do begin
      if J > 0 then f[J - 1]:=0;
      f[J]:=1;
      if SolveLinearSystem(A, f, x, 0) <> 1 then begin
        Result:=False;
        Exit;
      end;
      for I:=0 to M - 1 do
        B[I, J]:=x[I];
    end;
    Result:=True;
  finally
    f.Free;
    x.Free;
  end;
end;

end.
