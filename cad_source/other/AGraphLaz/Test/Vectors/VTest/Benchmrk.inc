var
  I: Integer;
  V1, V2: TFastVector;
begin
  V1:=TFastVector.Create(0, 0);
  V2:=TFastVector.Create(0, 0);
  try
    S:='AddVector ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      V2.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.AddVector(V2);
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);
    S:='AddScaled ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      V2.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.AddScaled(1, V2);
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='DotProduct';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      V2.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.DotProduct(V2);
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='AddScalar ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.AddScalar(0);
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='MulScalar ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.MulScalar(1);
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='SqrSum    ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.SqrSum;
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='Sum       ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.Sum;
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='Sort      ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.Sort;
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);

    S:='SortDesc  ';
    for I:=0 to TestCount - 1 do begin
      V1.Count:=SizeToTest[I];
      StartTimer;
      repeat
        V1.SortDesc;
        Inc(Counter);
      until TimePassed > TestTime;
      S:=S + Format('%8.0f', [Counter / T * 1000]);
    end;
    DebugLine(S);
  finally
    V1.Free;
    V2.Free;
  end;
end;