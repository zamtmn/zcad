var
  M1, M2, M3: TMatrix;
begin
  M1:=TMatrix.Create(40, 64, 0);
  M2:=TMatrix.Create(64, 32, 0);
  M3:=TMatrix.Create(40, 32, 0);
  try
    S:='Matrix Product 40x64 * 64x32';
    StartTimer;
    repeat
      M3.MatrixProduct(M1, M2);
      Inc(Counter);
    until TimePassed > TestTime;
    S:=S + Format('%8.0f', [Counter / T * 1000]);
    DebugLine(S);
  finally
    M1.Free;
    M2.Free;
    M3.Free;
  end;
end;
