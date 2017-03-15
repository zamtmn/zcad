{ Version 990813. Copyright © Alexey A.Chernobaev, 1996–1999 }

{procedure MatrixProductProc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);}
var
  I, J, K, Offset0, Offset1, Offset2, Offset3: Integer;
  T: NumberType;
begin
  Offset0:=0;
  Offset1:=0;
  for I:=0 to ResultRowCount - 1 do begin
    for J:=0 to ResultColCount - 1 do begin
      T:=0;
      Offset2:=Offset0;
      Offset3:=J;
      for K:=0 to Matrix1ColCount - 1 do begin
        T:=T + ArrayType(Matrix1)[Offset2] * ArrayType(Matrix2)[Offset3];
        Inc(Offset2);
        Inc(Offset3, ResultColCount);
      end;
      ArrayType(Result)[Offset1]:=T;
      Inc(Offset1);
    end;
    Inc(Offset0, Matrix1ColCount);
  end;
end;
