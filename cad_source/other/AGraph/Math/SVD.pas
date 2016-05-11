{ Singular value decomposition. Programmed by Eugene Vodopianov, v.000629 }

unit SVD;

interface

{$I VCheck.inc}

{$DEFINE FAST_ACCESS}

uses
  SysUtils, ExtType, ExtSys, Aliasv, F32v, F64v, F80v, Aliasm, F32m, F64m, F80m,
  VectErr;

procedure SingularValueDecomposition(A: TFloatMatrix; W: TFloatVector;
  V: TFloatMatrix);
{ Вычисляет SVD разложение матрицы A = U * W * VT. Значения U замещают входные
  значения матрицы A, в W возвращается вектор сингулярных чисел, которые
  образуют диагональ W-матрицы SVD-разложения, в V - V-матрица SVD-разложения
  (нетранспонированная). Размерности матриц: %A = [m, n], %V = [n, n],
  %U = [m, n]; длина вектора W равна n. В случае неудачи возбуждается исключение
  EMathError.
  Given a matrix A[1..m][1..n], this routine computes its singular value
  decomposition A = U * W * VT. The matrix U replaces A on output, the diagonal
  matrix of singular values W is output as a vector W[1..n], the matrix V (not
  the transposed VT) is output as V[1..n][1..n]. The exception EMathError is
  raised in case of failure. }

procedure PrepareToSolveSLE(U: TFloatMatrix; W: TFloatVector;
  WReciprocal: TFloatMatrix; Eps: Float);
{ Подготавливает результаты SVD-разложения для использования при решении систем
  линейных алгебраических уравнений (SLE): транспонирует матрицу U и строит
  диагональную матрицу WReciprocal, диагональные элементы которой равны 1/Wj,
  если Abs(Wj) >= Eps, и 0 иначе.
  Prepares the results of the SVD for solving systems of linear equations (SLE):
  transposes the U matrix and constructs the diagonal matrix WReciprocal,
  which diagonal elements are equal to 1/Wj if Abs(Wj) >= Eps, and 0 otherwise. }

procedure SolveSLE(UTransposed, WReciprocal, V: TFloatMatrix; b, x: TFloatVector);
{ Решает систему линейных алгебраических уравнений Ax=b, для левой части которой
  уже выполнено SVD-разложение; процедуре необходимо передавать транспонированную
  U-матрицу разложения (в UTransposed), диагональную матрицу WReciprocal,
  диагональные элементы которой равны 1/Wj либо 0, V-матрицу разложения и
  правую часть решаемой системы; для подготовки параметров UTransposed и
  WReciprocal можно использовать процедуру PrepareToSolveSLE.
  Solves the system of linear equations Ax=b if SVD for A is already done; the
  procedure needs the transposed U-matrix of the decomposition (in UTransposed),
  diagonal matrix WReciprocal, which diagonal elements are equal to either 1/Wj
  of 0, V-matrix of the decomposition and the right part of the system; the
  PrepareToSolveSLE procedure can be used for preparing parameters UTransposed
  and WReciprocal. }

implementation

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
procedure SingularValueDecomposition(A: TFloatMatrix; W: TFloatVector;
  V: TFloatMatrix);
const
  MaxConvergenceIter = 30; { max iterations count for convergence }

  function Pythagorean(a, b: Float): Float;
  { Computes(a^2 + b^2 )^1/2 without destructive under ow or over ow. }
  var
    fa, fb: Float;
  begin
    fa:=Abs(a);
    fb:=Abs(b);
    if fa > fb then begin
      fb:=fb / fa;
      Result:=fa * sqrt(1.0 + fb * fb);
    end
    else if fb = 0 then
      Result:=0
    else begin
      fa:=fa / fb;
      Result:=fb * sqrt(1.0 + fa * fa);
    end;
  end;

  function Sgn(a, b: Float): Float;
  { result = Abs(a)*Sgn(b) }
  begin
    Result:=Abs(a);
    if b < 0 then Result:=-Result;
  end;

var
  i, its, j, jj, k, l, m, n, nm: Integer;
  flag: Bool;
  anorm, c, f, g, h, s, t, scale, x, y, z: Float;
  rv1: TFloatVector;
  {$IFDEF FAST_ACCESS}P1, P2, PBase: PFloat;{$ENDIF}
begin
  m:=A.RowCount;
  n:=A.ColCount;
  W.Count:=n;
  V.SetSize(n, n);
  rv1:=TFloatVector.Create(n, 0);
  try
    g:=0;
    scale:=0;
    anorm:=0; { Householder reduction to bidiagonal form. }
    for i:=0 to n - 1 do begin
      l:=i + 1;
      rv1[i]:=scale * g;
      g:=0;
      s:=0;
      scale:=0;
      if i < m then begin
        {$IFNDEF FAST_ACCESS}
        for k:=i to m - 1 do
          scale:=scale + Abs(A[k, i]);
        {$ELSE}
        PBase:=@PFloatArray(A.Vector.Memory)^[i * n];
        P1:=PBase;
        Inc(P1, i);
        for k:=i to m - 1 do begin
          scale:=scale + Abs(P1^);
          Inc(P1, n);
        end;
        {$ENDIF}
        if scale <> 0 then begin
          {$IFNDEF FAST_ACCESS}
          for k:=i to m - 1 do begin
            A.DivItem(k, i, scale); { A[k, i] /= scale; }
            s:=s + A[k, i] * A[k, i];
          end;
          {$ELSE}
          P1:=PBase;
          Inc(P1, i);
          for k:=i to m - 1 do begin
            P1^:=P1^ / scale;
            s:=s + Sqr(P1^);
            Inc(P1, n);
          end;
          {$ENDIF}
          f:=A[i, i];
          g:=-Sgn(Sqrt(s), f);
          h:=f * g - s;
          A[i, i]:=f - g;
          {$IFNDEF FAST_ACCESS}
          for j:=l to n - 1 do begin
            s:=0.0;
            for k:=i to m - 1 do
              s:=s + A[k, i] * A[k, j];
            f:=s / h;
            for k:=i to m - 1 do
              A.IncItem(k, j, f * A[k, i]); { A[k, j] += f*A[k, i]; }
          end;
          for k:=i to m - 1 do
            A.MulItem(k, i, scale); { A[k, i] *= scale; }
          {$ELSE}
          for j:=l to n - 1 do begin
            s:=0.0;
            P1:=PBase;
            Inc(P1, j);
            P2:=PBase;
            Inc(P2, i);
            for k:=i to m - 1 do begin
              s:=s + P1^ * P2^;
              Inc(P1, n);
              Inc(P2, n);
            end;
            f:=s / h;
            P1:=PBase;
            Inc(P1, j);
            P2:=PBase;
            Inc(P2, i);
            for k:=i to m - 1 do begin
              P1^:=P1^ + f * P2^;
              Inc(P1, n);
              Inc(P2, n);
            end;
          end;
          Inc(PBase, i);
          for k:=i to m - 1 do begin
            PBase^:=PBase^ * scale;
            Inc(PBase, n);
          end;
          {$ENDIF}
        end;
      end;
      w[i]:=scale * g;
      g:=0;
      s:=0;
      scale:=0;
      if (i < m) and (i <> n - 1) then begin
        {$IFNDEF FAST_ACCESS}
        for k:=l to n - 1 do
          scale:=scale + Abs(A[i, k]);
        {$ELSE}
        PBase:=@PFloatArray(A.Vector.Memory)^[i * n];
        P1:=PBase;
        Inc(P1, l);
        P2:=P1;
        for k:=l to n - 1 do begin
          scale:=scale + Abs(P1^);
          Inc(P1);
        end;
        {$ENDIF}
        if scale <> 0 then begin
          {$IFNDEF FAST_ACCESS}
          for k:=l to n - 1 do begin
            A.DivItem(i, k, scale); { A[i, k] /= scale; }
            s:=s + A[i, k] * A[i, k];
          end;
          {$ELSE}
          P1:=P2;
          for k:=l to n - 1 do begin
            P1^:=P1^ / Scale;
            s:=s + P1^ * P1^;
            Inc(P1);
          end;
          {$ENDIF}
          f:=A[i, l];
          g:=-Sgn(Sqrt(s), f);
          h:=f * g - s;
          A[i, l]:=f - g;
          {$IFNDEF FAST_ACCESS}
          for k:=l to n - 1 do
            rv1[k]:=A[i, k] / h;
          for j:=l to m - 1 do begin
            s:=0.0;
            for k:=l to n - 1 do
              s:=s + A[j, k] * A[i, k];
            for k:=l to n - 1 do
              A.IncItem(j, k, s * rv1[k]); { A[j, k] += s*rv1[k]; }
          end;
          for k:=l to n - 1 do
            A.MulItem(i, k, scale); { A[i, k] *= scale; }
          {$ELSE}
          P1:=P2;
          for k:=l to n - 1 do begin
            rv1[k]:=P1^ / h;
            Inc(P1);
          end;
          for j:=l to m - 1 do begin
            s:=0.0;
            P1:=PBase;
            Inc(P1, l);
            P2:=@PFloatArray(A.Vector.Memory)^[j * n + l];
            for k:=l to n - 1 do begin
              s:=s + P2^ * P1^;
              Inc(P2);
              Inc(P1);
            end;
            P2:=@PFloatArray(A.Vector.Memory)^[j * n + l];
            for k:=l to n - 1 do begin
              P2^:=P2^ + s * rv1[k];
              Inc(P2);
            end;
          end;
          Inc(PBase, l);
          for k:=l to n - 1 do begin
            PBase^:=PBase^ * scale;
            Inc(PBase);
          end;
          {$ENDIF}
        end;
      end;
      anorm:=FloatMax(anorm,(Abs(w[i]) + Abs(rv1[i])));
    end; {for i}
    for i:=n - 1 downto 0 do begin { Accumulation of right-hand transformations. }
      if i < n - 1 then begin
        if g <> 0 then begin
          {$IFNDEF FAST_ACCESS}
          for j:=l to n - 1 do { Double division to avoid possible under ow. }
            v[j, i]:=(A[i, j] / A[i, l]) / g;
          for j:=l to n - 1 do begin
            s:=0.0;
            for k:=l to n - 1 do
              s:=s + A[i, k] * v[k, j];
            for k:=l to n - 1 do
              v.IncItem(k, j, s * v[k, i]); { v[k, j] += s*v[k, i]; }
          end;
          {$ELSE}
          P1:=@PFloatArray(A.Vector.Memory)^[i * n + l];
          t:=P1^;
          for j:=l to n - 1 do begin
            v[j, i]:=(P1^ / t) / g;
            Inc(P1);
          end;
          for j:=l to n - 1 do begin
            s:=0.0;
            P1:=@PFloatArray(A.Vector.Memory)^[i * n + l];
            P2:=@PFloatArray(v.Vector.Memory)^[l * n + j];
            for k:=l to n - 1 do begin
              s:=s + P1^ * P2^;
              Inc(P1);
              Inc(P2, n);
            end;
            P1:=@PFloatArray(v.Vector.Memory)^[l * n + j];
            P2:=@PFloatArray(v.Vector.Memory)^[l * n + i];
            for k:=l to n - 1 do begin
              P1^:=P1^ + s * P2^;
              Inc(P1, n);
              Inc(P2, n);
            end;
          end;
          {$ENDIF}
        end;
        for j:=l to n - 1 do begin
          v[i, j]:=0;
          v[j, i]:=0;
        end;
      end;
      v[i, i]:=1.0;
      g:=rv1[i];
      l:=i;
    end; {for i}
    for i:=IntMin(m, n) - 1 downto 0 do begin { Accumulation of left-hand transformations. }
      l:=i + 1;
      g:=w[i];
      for j:=l to n - 1 do
        A[i, j]:=0.0;
      if g <> 0 then begin
        g:=1.0 / g;
        {$IFNDEF FAST_ACCESS}
	for j:=l to n - 1 do begin
          s:=0.0;
          for k:=l to m - 1 do
            s:=s + A[k, i] * A[k, j];
          f:=(s / A[i, i]) * g;
          for k:=i to m - 1 do
            A.IncItem(k, j, f * A[k, i]); { A[k, j] += f*A[k, i]; }
        end;
        for j:=i to m - 1 do
          A.MulItem(j, i, g); { A[j, i] *= g; }
        {$ELSE}
        PBase:=@PFloatArray(A.Vector.Memory)^[l * n];
	for j:=l to n - 1 do begin
          s:=0.0;
          P1:=PBase;
          Inc(P1, i);
          P2:=PBase;
          Inc(P2, j);
          for k:=l to m - 1 do begin
            s:=s + P1^ * P2^;
            Inc(P1, n);
            Inc(P2, n);
          end;
          f:=(s / A[i, i]) * g;
          P1:=@PFloatArray(A.Vector.Memory)^[i * n + j];
          P2:=@PFloatArray(A.Vector.Memory)^[i * n + i];
          for k:=i to m - 1 do begin
            P1^:=P1^ + f * P2^;
            Inc(P1, n);
            Inc(P2, n);
          end;
        end;
        for j:=i to m - 1 do
          A.MulItem(j, i, g); { A[j, i] *= g; }
        {$ENDIF}
      end
      else
        for j:=i to m - 1 do
          A[j, i]:=0;
      A.IncItem(i, i, 1); { ++A[i, i]; }
    end; {for i}
    for k:=n - 1 downto 0 do begin
      { Diagonalization of the bidiagonal form: Loop over singular values, and
        over allowed iterations. }
      for its:=1 to MaxConvergenceIter do begin
        flag:=True;
        l:=k;
        while l >= 0 do begin { Test for splitting. }
          nm:=l - 1; { Note that rv1[1] is always zero. }
	  if (Abs(rv1[l]) + anorm) = anorm then begin
            flag:=False;
	    break;
          end;
          if(Abs(w[nm]) + anorm) = anorm then
            break;
          Dec(l);
        end;
        if flag then begin
          c:=0.0; { Cancellation of rv1[l], ifl>1. }
          s:=1.0;
	  for i:=l to k do begin
            f:=s * rv1[i];
            rv1.MulItem(i, c); { rv1[i]:=c * rv1[i]; }
            if(Abs(f) + anorm) = anorm then
              break;
            g:=w[i];
            h:=Pythagorean(f, g);
            w[i]:=h;
            h:=1.0 / h;
            c:=g * h;
            s:=-f * h;
            for j:=0 to m - 1 do begin
              y:=A[j, nm];
              z:=A[j, i];
              A[j, nm]:=y * c + z * s;
              A[j, i]:=z * c - y * s;
            end;
          end;
        end; {for its}
        z:=w[k];
        if l = k then begin { Convergence. }
          if z < 0 then begin { Singular value is made nonnegative. }
            w[k]:=-z;
            for j:=0 to n - 1 do
              v.MulItem(j, k, -1); { v[j, k]:=-v[j, k]; }
          end;
          break;
        end;
        if its = MaxConvergenceIter then
          raise EMathError.Create(SAlgorithmFailure);
        x:=w[l]; { Shiftfrom bottom 2-by-2minor. }
        nm:=k - 1;
        y:=w[nm];
        g:=rv1[nm];
        h:=rv1[k];
        f:=((y - z) * (y + z) +(g - h) * (g + h)) / (2.0 * h * y);
        g:=Pythagorean(f, 1);
        f:=((x - z) * (x + z) + h * (( y / (f + Sgn(g, f))) - h)) / x;
        c:=1.0;
        s:=1.0; { Next QR transformation: }
        for j:=l to nm do begin
          i:=j + 1;
          g:=rv1[i];
          y:=w[i];
          h:=s * g;
          g:=c * g;
          z:=Pythagorean(f, h);
          rv1[j]:=z;
          c:=f / z;
          s:=h / z;
          f:=x * c + g * s;
          g:=g * c - x * s;
          h:=y * s;
          y:=y * c;
          {$IFNDEF FAST_ACCESS}
          for jj:=0 to n - 1 do begin
            x:=v[jj, j];
            z:=v[jj, i];
            v[jj, j]:=x * c + z * s;
            v[jj, i]:=z * c - x * s;
          end;
          {$ELSE}
          P1:=@PFloatArray(v.Vector.Memory)^[j];
          P2:=@PFloatArray(v.Vector.Memory)^[i];
          for jj:=0 to n - 1 do begin
            x:=P1^;
            z:=P2^;
            P1^:=x * c + z * s;
            P2^:=z * c - x * s;
            Inc(P1, n);
            Inc(P2, n);
          end;
          {$ENDIF}
          z:=Pythagorean(f, h);
          w[j]:=z; { Rotation can be arbitrary if z = 0. }
          if z <> 0 then begin
            z:=1.0 / z;
            c:=f * z;
            s:=h * z;
          end;
          f:=c * g + s * y;
          x:=c * y - s * g;
          {$IFNDEF FAST_ACCESS}
          for jj:=0 to m - 1 do begin
            y:=A[jj, j];
            z:=A[jj, i];
            A[jj, j]:=y * c + z * s;
            A[jj, i]:=z * c - y * s;
          end;
          {$ELSE}
          P1:=@PFloatArray(A.Vector.Memory)^[j];
          P2:=@PFloatArray(A.Vector.Memory)^[i];
          for jj:=0 to m - 1 do begin
            y:=P1^;
            z:=P2^;
            P1^:=y * c + z * s;
            P2^:=z * c - y * s;
            Inc(P1, n);
            Inc(P2, n);
          end;
          {$ENDIF}
        end; {for j}
        rv1[l]:=0.0;
        rv1[k]:=f;
        w[k]:=x;
      end;
    end; {for k}
  finally
    rv1.Free;
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

procedure PrepareToSolveSLE(U: TFloatMatrix; W: TFloatVector;
  WReciprocal: TFloatMatrix; Eps: Float);
var
  I, N: Integer;
begin
  U.Transpose;
  N:=W.Count;
  WReciprocal.SetSize(N, N);
  WReciprocal.Vector.FillValue(0);
  for I:=0 to N - 1 do
    if Abs(W[I]) > Eps then
      WReciprocal[I, I]:=1 / W[I]
    else
      WReciprocal[I, I]:=0;
end;

procedure SolveSLE(UTransposed, WReciprocal, V: TFloatMatrix; b, x: TFloatVector);
{ x = V * (WReciprocal * (UTransposed * b)) }
var
  M, N: Integer;
  T1, T2: TFloatMatrix;
begin
  M:=b.Count;
  N:=UTransposed.RowCount;
  if (UTransposed.ColCount <> M) or (WReciprocal.RowCount <> N) or
    (WReciprocal.ColCount <> N)
  then
    raise EMathError.Create(SErrorInParameters);
  T1:=TFloatMatrix.Create(0, 0, 0);
  T2:=nil;
  try
    T1.AssignColumn(b);
    T2:=TFloatMatrix.CreateMatrixProduct(UTransposed, T1);
    T1.MatrixProduct(WReciprocal, T2);
    T2.MatrixProduct(V, T1);
    x.Assign(T2.Vector);
  finally
    T1.Free;
    T2.Free;
  end;
end;

end.
