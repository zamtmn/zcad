var
  M1, M2, M3, S1, S2, RM1, RM2, RS1, RS2: TMatrix;
  V: TGenericNumberVector;

  procedure Check(Matrix: TMatrix; const Values: array of const);

    procedure DoCheck;
    var
      I, J: Integer;
    begin
      if Matrix.RowCount * Matrix.ColCount <> High(Values) + 1 then
        Error(EWrongResult);
      for I:=0 to Matrix.RowCount - 1 do
        for J:=0 to Matrix.ColCount - 1 do begin
          if Matrix[I, J] <> Values[I * Matrix.ColCount + J].VInteger then
            Error(EWrongResult);
          Matrix.IncItem(I, J, 2);
          if Matrix[I, J] <> Values[I * Matrix.ColCount + J].VInteger + 2 then
            Error(EWrongResult);
          Matrix.DecItem(I, J, 2);
          if Matrix[I, J] <> Values[I * Matrix.ColCount + J].VInteger then
            Error(EWrongResult);
          Matrix.MulItem(I, J, 2);
          if Matrix[I, J] <> Values[I * Matrix.ColCount + J].VInteger * 2 then
            Error(EWrongResult);
          Matrix.DivItem(I, J, 2);
          if Matrix[I, J] <> Values[I * Matrix.ColCount + J].VInteger then
            Error(EWrongResult);
        end;
    end;

  var
    T: TVMemStream;
  begin
    DoCheck;
    T:=TVMemStream.Create;
    try
      Matrix.WriteToStream(T);
      T.Seek(0);
      Matrix.ReadFromStream(T);
      DoCheck;
    finally
      T.Free;
    end;
  end;

  procedure SetItems(Matrix: TMatrix);
  var
    I, J: Integer;
  begin
    for I:=0 to Matrix.RowCount - 1 do
      for J:=0 to Matrix.ColCount - 1 do
        Matrix[I, J]:=I * Matrix.ColCount + J;
  end;

  procedure Check1;
  begin
    Check(M1,
      [0, 1, 2,
       3, 4, 5]);
    Check(RM1,
      [0, 1, 2,
       3, 4, 5]);
    Check(S1,
      [0, 4, 8,12,
       4, 5, 9,13,
       8, 9,10,14,
      12,13,14,15]);
    Check(RS1,
      [0, 4, 8,12,
       4, 5, 9,13,
       8, 9,10,14,
      12,13,14,15]);
  end;

  procedure Check2;
  begin
    Check(M1,
      [1, 2, 3,
       4, 5, 6]);
    Check(RM1,
      [1, 2, 3,
       4, 5, 6]);
    Check(S1,
      [1, 5, 9,13,
       5, 6,10,14,
       9,10,11,15,
      13,14,15,16]);
    Check(RS1,
      [1, 5, 9,13,
       5, 6,10,14,
       9,10,11,15,
      13,14,15,16]);
  end;

begin
  M1:=TMatrix.Create(2, 3, 0);
  RM1:=TSparseMatrix.Create(2, 3, 0);
  M2:=TMatrix.Create(2, 3, 1);
  RM2:=TSparseMatrix.Create(2, 3, 1);
  S1:=TSimMatrix.Create(4, 0);
  S2:=TSimMatrix.Create(4, 1);
  RS1:=TSimMatrix.Create(4, 0);
  RS2:=TSimMatrix.Create(4, 1);
  M3:=nil;
  V:=nil;
  try
    Check(M1,
      [0, 0, 0,
       0, 0, 0]);
    Check(RM1,
      [0, 0, 0,
       0, 0, 0]);
    Check(M2,
      [1, 1, 1,
       1, 1, 1]);
    Check(RM2,
      [1, 1, 1,
       1, 1, 1]);
    Check(S1,
      [0, 0, 0, 0,
       0, 0, 0, 0,
       0, 0, 0, 0,
       0, 0, 0, 0]);
    Check(RS1,
      [0, 0, 0, 0,
       0, 0, 0, 0,
       0, 0, 0, 0,
       0, 0, 0, 0]);
    Check(S2,
      [1, 1, 1, 1,
       1, 1, 1, 1,
       1, 1, 1, 1,
       1, 1, 1, 1]);
    Check(RS2,
      [1, 1, 1, 1,
       1, 1, 1, 1,
       1, 1, 1, 1,
       1, 1, 1, 1]);

    SetItems(M1);
    SetItems(RM1);
    SetItems(S1);
    SetItems(RS1);

    Check1;

    M1.AddScalar(1);
    RM1.AddScalar(1);
    S1.AddScalar(1);
    RS1.AddScalar(1);

    Check2;

    M1.SubScalar(1);
    RM1.SubScalar(1);
    S1.SubScalar(1);
    RS1.SubScalar(1);

    Check1;

    M1.AddMatrix(M2);
    RM1.AddMatrix(RM2);
    S1.AddMatrix(S2);
    RS1.AddMatrix(RS2);

    Check2;
    M1.SubMatrix(M2);
    RM1.SubMatrix(RM2);
    S1.SubMatrix(S2);
    RS1.SubMatrix(RS2);

    Check1;

    M1.Transpose;
    RM1.Transpose;
    S1.Transpose;
    RS1.Transpose;

    Check(M1,
      [0, 3,
       1, 4,
       2, 5]);
    Check(RM1,
      [0, 3,
       1, 4,
       2, 5]);
    Check(S1,
      [0, 4, 8,12,
       4, 5, 9,13,
       8, 9,10,14,
      12,13,14,15]);
    Check(RS1,
      [0, 4, 8,12,
       4, 5, 9,13,
       8, 9,10,14,
      12,13,14,15]);

    M1.Transpose;
    RM1.Transpose;
    S1.Transpose;
    RS1.Transpose;

    Check1;

    M1.AddMatrix(RM2);
    RM1.AddMatrix(M2);
    S1.AddMatrix(RS2);
    RS1.AddMatrix(S2);

    Check2;

    M1.SubMatrix(RM2);
    RM1.SubMatrix(M2);
    S1.SubMatrix(RS2);
    RS1.SubMatrix(S2);

    Check1;

    M2.Assign(M1);
    RM2.Assign(RM1);
    S2.Assign(S1);
    RS2.Assign(RS1);

    M1.RowCount:=3;
    M1.ColCount:=4;
    RM1.RowCount:=3;
    RM1.ColCount:=4;
    S1.RowCount:=5;
    RS1.RowCount:=5;
    M2.RowCount:=3;
    M2.ColCount:=4;
    RM2.RowCount:=3;
    RM2.ColCount:=4;
    S2.RowCount:=5;
    RS2.RowCount:=5;
    Check(M1,
      [0, 1, 2, 0,
       3, 4, 5, 0,
       0, 0, 0, 0]);
    Check(RM1,
      [0, 1, 2, 0,
       3, 4, 5, 0,
       0, 0, 0, 0]);
    Check(S1,
      [0, 4, 8,12, 0,
       4, 5, 9,13, 0,
       8, 9,10,14, 0,
      12,13,14,15, 0,
       0, 0, 0, 0, 0]);
    Check(RS1,
      [0, 4, 8,12, 0,
       4, 5, 9,13, 0,
       8, 9,10,14, 0,
      12,13,14,15, 0,
       0, 0, 0, 0, 0]);
    { DefaultValue тоже присваивается! }
    Check(M2,
      [0, 1, 2, 0,
       3, 4, 5, 0,
       0, 0, 0, 0]);
    Check(RM2,
      [0, 1, 2, 0,
       3, 4, 5, 0,
       0, 0, 0, 0]);
    Check(S2,
      [0, 4, 8,12, 0,
       4, 5, 9,13, 0,
       8, 9,10,14, 0,
      12,13,14,15, 0,
       0, 0, 0, 0, 0]);
    Check(RS2,
      [0, 4, 8,12, 0,
       4, 5, 9,13, 0,
       8, 9,10,14, 0,
      12,13,14,15, 0,
       0, 0, 0, 0, 0]);

    M1.SetSize(2, 3);
    RM1.RowCount:=2;
    RM1.ColCount:=3;
    S1.RowCount:=4;
    RS1.RowCount:=4;
    Check1;

    M2.SetSize(3, 2);
    M2[0, 0]:=1;
    M2[0, 1]:=4;
    M2[1, 0]:=2;
    M2[1, 1]:=3;
    M2[2, 0]:=5;
    M2[2, 1]:=6;
    M3:=TMatrix.CreateMatrixProduct(M1, M2);
    Check(M3,
      [12, 15,
       36, 54]);
    V:=TNumberVector.Create(4, 0);
    V[1]:=3;
    V[2]:=4;
    V[3]:=5;
    M1.ConvertToRow(V);

    if (M1.ColCount <> 4) or (V <> nil) then Error(EWrongResult);
    Check(M1, [0, 3, 4, 5]);

    V:=TNumberVector.Create(4, 0);
    V[1]:=3;
    V[2]:=4;
    V[3]:=5;
    M1.AssignColumn(V);

    if M1.RowCount <> V.Count then Error(EWrongResult);
    Check(M1,
      [0,
       3,
       4,
       5]);
  finally
    M1.Free;
    RM1.Free;
    M2.Free;
    RM2.Free;
    S1.Free;
    RS1.Free;
    S2.Free;
    RS2.Free;
    M3.Free;
    V.Free;
  end;
end;
