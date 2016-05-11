program TestSVD;

uses
  ExtType, Aliasv, Aliasm, F64v, F64m, SVD;

{$APPTYPE CONSOLE}

procedure Test;
var
  Matrix, Product, SingMatrix, U, V, T1, T2: TFloatMatrix;
  SingValues, b, x: TFloatVector;
  I, J: Integer;
begin
  Matrix:=TFloatMatrix.Create(3, 3, 0);
  Product:=nil;
  U:=nil;
  V:=nil;
  SingMatrix:=nil;
  SingValues:=nil;
  T1:=nil;
  T2:=nil;
  b:=nil;
  x:=nil;
  try
    SingMatrix:=TFloatMatrix.Create(3, 3, 0);
    U:=TFloatMatrix.Create(0, 0, 0);
    V:=TFloatMatrix.Create(0, 0, 0);
    SingValues:=TFloatVector.Create(0, 0);
    for I:=0 to Matrix.RowCount - 1 do
      for J:=0 to Matrix.ColCount - 1 do
        Matrix[I, J]:=Random * 10;
{    Matrix.SetItems([
      1, 2, 3,
      4, 5, 6,
      7, 8, 9]);}
    writeln('Matrix');
    Matrix.DebugWrite;
    U.Assign(Matrix);
    SingularValueDecomposition(U, SingValues, V);
    write('Singular values: ');
    SingValues.DebugWrite;
    for I:=0 to SingValues.Count - 1 do
      SingMatrix[I, I]:=SingValues[I];
    writeln('Checking...');
    Product:=TFloatMatrix.CreateMatrixProduct(U, SingMatrix);
    V.Transpose;
    T1:=TFloatMatrix.Create(0, 0, 0);
    T2:=TFloatMatrix.Create(0, 0, 0);
    T1.Assign(Product);
    Product.MatrixProduct(T1, V);
    writeln('Result');
    Product.DebugWrite;
    PrepareToSolveSLE(U, SingValues, SingMatrix, 1E-6);
    x:=TFloatVector.Create(0, 0);
    V.Transpose;
    b:=TFloatVector.Create(Product.RowCount, 0);
    writeln('Solving systems of linear equations using SVD');
    for I:=1 to 4 do begin
      for J:=0 to b.Count - 1 do
        b[J]:=Random * 5;
      write('b:'^I);
      b.DebugWrite;
      SolveSLE(U, SingMatrix, V, b, x);
      write('A * x:'^I);
      T1.AssignColumn(x);
      T2.MatrixProduct(Product, T1);
      T2.Vector.DebugWrite;
      writeln;
    end;
  finally
    Matrix.Free;
    Product.Free;
    U.Free;
    V.Free;
    SingMatrix.Free;
    SingValues.Free;
    T1.Free;
    T2.Free;
    b.Free;
    x.Free;
  end;
end;

begin
  Randomize;
  Test;
  write('Press Return to continue...');
  readln;
end.
