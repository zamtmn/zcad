unit Grevil;
{
  Псевдообращение матрицы методом Гревиля.

  Автор оригинального кода: Макс Берило. Прислал для включения в библиотеку
  Vectors: Игорь Федоров (2:5036/9.26).

  "Псевдообратная A_ к матрице A удовлетворяет следующим условиям:
  1) A*A_*A=A
  2) A_*A*A_=A_
  3) A*A_ и A_*A симметричны
  Для обратимой матрицы она совпадает с обратной. К тому же если есть уравнение
  типа A*x=b и А необратима, то x_=A_*b минимизирует невязку ||Ax-b|| (метод
  наименьших квадратов).

  Литература:
  1. Шумский В.И., Шумская Т.H. О применении методов псевдообращения для
  решения плохо обусловленных задач МHК // Заводская лаборатория. - 1989, № 1.
  2. Блюмин С.Л., Денисенко Ю.И., Миловидов С.П. К исследованию и решению
  целочисленных систем линейных уравнений // Ж. вычисл. матем. и мат.физики. -
  1988, т. 28, № 6.
  3. Блюмин С.Л., Миловидов С.П. Взвешенное псевдообращение в оптимальном
  управлении дискретно-аргументными системами. М., 1990. Деп. в ВИHИТИ ред.ж.
  "Известия АH СССР. Техническая кибернетика" 13.03.90, № 1390В-90."

  Адаптация для библиотеки Vectors: А.Чернобаев (v.990825).
}

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Aliasm, F32v, F64v, F80v, F32m, F64m, F80m, VectErr, MathErr;

procedure GrevilTransform(Source, Destin: TFloatMatrix; Eps: Float);
{ Source: исходная (обращаемая) матрица; Destin: результат; Eps - ? }

implementation

procedure GrevilTransform(Source, Destin: TFloatMatrix; Eps: Float);
var
  A, f: TFloatVector;
  I, J, K, L: Integer;
  SqrSum, T: Float;
begin
  {$IFDEF CHECK_MATH}
  if Destin.Vector.DefaultValue <> 0 then MathError(SErrorInParameters, [0]);
  {$ENDIF}
  Destin.SetSize(Source.ColCount, Source.RowCount);
  Destin.Vector.SetToDefault;
  A:=TFloatVector.Create(Source.ColCount, 0);
  try
    f:=TFloatVector.Create(Source.RowCount, 0);
    try
      { first step }
      SqrSum:=0;
      for I:=0 to Source.RowCount - 1 do SqrSum:=SqrSum + Sqr(Source[I, 0]);
      if SqrSum > Eps then
        for I:=0 to Source.RowCount - 1 do Destin[0, I]:=Source[I, 0] / SqrSum;
      { iterate }
      for J:=0 to Source.ColCount - 1 do begin
        { compute }
        A.SetToDefault;
        for K:=0 to J - 1 do
          for L:=0 to Destin.ColCount - 1 do
            A.IncItem(K, Destin[K, L] * Source[L, J]);
        F.SetToDefault;
        SqrSum:=0;
        for K:=0 to Destin.ColCount - 1 do begin
          T:=F[K];
          for L:=0 to J - 1 do
            T:=T + Source[K, L] * A[L];
          T:=Source[K, J] - T;
          F[K]:=T;
          SqrSum:=SqrSum + Sqr(T);
        end;
        If SqrSum <= Eps Then begin
          F.SetToDefault;
          SqrSum:=1;                         
          for K:=0 to J - 1 do begin
            T:=A[K];
            for L:=0 to Destin.ColCount - 1 do
              F.IncItem(L, T * Destin[K, L]);
            SqrSum:=SqrSum + Sqr(T);
          end;
        end;
        for L:=0 to Destin.ColCount - 1 do
          F[L]:=F[L] / SqrSum;
        { rebuild }
        for L:=0 to Destin.ColCount - 1 do begin
          for K:=0 to J - 1 do
            Destin.DecItem(K, L, A[K] * F[L]);
          Destin[J, L]:=F[L];
        end;
      end;
    finally
      f.Free;
    end;
  finally
    A.Free;
  end;
end;

end.
