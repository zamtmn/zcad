var
  V1, V2: TFastVector;
  RV1, RV2: TGenericVector;

  procedure Check(Vector: TGenericVector; const Values: array of const);

    procedure DoCheck;
    var
      I, J, MinI, MaxI: Integer;
      Sum, SqrSum: Float64;
      Min, Max, T: NumberType;
    begin
      if Vector.Count <> High(Values) + 1 then Error(EWrongResult);
      Sum:=0;
      SqrSum:=0;
      Min:=Values[0].VInteger;
      Max:=Min;
      MinI:=0;
      MaxI:=0;
      for I:=0 to High(Values) do begin
        if Vector[I] <> Values[I].VInteger then Error(EWrongResult);
        Sum:=Sum + Vector[I];
        SqrSum:=SqrSum + Sqr(Vector[I]);
        if Vector[I] > Max then begin
          Max:=Vector[I];
          MaxI:=I;
        end;
        if Vector[I] < Min then begin
          Min:=Vector[I];
          MinI:=I;
        end;
      end;
      if Abs(Sum - Vector.Sum) > MinFloat64 then Error(EWrongResult);
      if Abs(SqrSum - Vector.SqrSum) > MinFloat64 then Error(EWrongResult);
      if Min <> Vector.Min then Error(EWrongResult);
      if Max <> Vector.Max then Error(EWrongResult);
      if (Vector.MinIndex(T) <> MinI) or (T <> Min) then Error(EWrongResult);
      if (Vector.MaxIndex(T) <> MaxI) or (T <> Max) then Error(EWrongResult);
      Vector.Reverse;
      J:=0;
      for I:=High(Values) downto 0 do begin
        if Vector[I] <> Values[J].VInteger then Error(EWrongResult);
        Vector.IncItem(I, 2);
        if Vector[I] <> Values[J].VInteger + 2 then Error(EWrongResult);
        Vector.DecItem(I, 2);
        if Vector[I] <> Values[J].VInteger then Error(EWrongResult);
        Vector.MulItem(I, 3);
        if Vector[I] <> Values[J].VInteger * 3 then Error(EWrongResult);
        Vector.DivItem(I, 3);
        if Vector[I] <> Values[J].VInteger then Error(EWrongResult);
        Inc(J);
      end;
      Vector.Reverse;
    end;

  var
    T: TVMemStream;
  begin
    DoCheck;
    T:=TVMemStream.Create;
    try
      Vector.WriteToStream(T);
      T.Seek(0);
      Vector.ReadFromStream(T);
      DoCheck;
    finally
      T.Free;
    end;
  end;

  procedure SetItems(Vector: TGenericVector);
  var
    I: Integer;
  begin
    for I:=0 to Vector.Count - 1 do begin
      Vector[I]:=I;
      if Vector[I] <> I then Error(EWrongResult);
    end;
  end;

  procedure Grow(Vector: TGenericVector; N: Integer);
  var
    I: Integer;
  begin
    for I:=1 to N do Vector.Add(I);
  end;

  procedure Diminish(Vector: TGenericVector; N: Integer);
  var
    I: Integer;
  begin
    for I:=1 to N do Vector.Delete(Vector.Count - 1);
{    for I:=1 to N do Vector.Pop;}
  end;

  procedure Test(V: TGenericVector);
  begin
    V.Clear;
    V.Count:=4;
    V[1]:=0;
    V[2]:=3;
    V[3]:=4;
    V.Count:=12;
    V[5]:=6;
    V[9]:=2;
    V[10]:=8;
    if V.IndexFrom(3, 6) <> 5 then Error(EWrongResult);
    if V.IndexFrom(3, 2) <> 9 then Error(EWrongResult);
    if V.IndexFrom(3, 1) <> 4 then Error(EWrongResult);
    if V.IndexFrom(10, 1) <> 11 then Error(EWrongResult);
    if V.IndexFrom(100, 1) <> -1 then Error(EWrongResult);
    if V.IndexFrom(-1, 1) <> 0 then Error(EWrongResult);
    if V.IndexFrom(-1, 101) <> -1 then Error(EWrongResult);
    if V.LastIndexFrom(10, 6) <> 5 then Error(EWrongResult);
    if V.LastIndexFrom(3, 3) <> 2 then Error(EWrongResult);
    if V.LastIndexFrom(2, 1) <> 0 then Error(EWrongResult);
    if V.LastIndexFrom(100, 1) <> 11 then Error(EWrongResult);
    if V.LastIndexFrom(-1, 1) <> -1 then Error(EWrongResult);
    if V.LastIndexFrom(100, 101) <> -1 then Error(EWrongResult);
  end;

begin
  V1:=TFastVector.Create(5, 0);
  RV1:=TSparseVector.Create(5, 0);
  V2:=TFastVector.Create(5, 1);
  RV2:=TSparseVector.Create(5, 1);
  try
    Check(V1, [0, 0, 0, 0, 0]);

    V1[0]:=5;
    V1[3]:=8;
    V1[4]:=7;
    Check(V1, [5, 0, 0, 8, 7]);
    V1.SetToDefault;

    if V1.NumberOfValues(0) <> V1.Count then Error(EWrongResult);
    if V1.NumberOfValues(1) <> 0 then Error(EWrongResult);
    if V2.NumberOfValues(0) <> 0 then Error(EWrongResult);
    if V2.NumberOfValues(1) <> V2.Count then Error(EWrongResult);

    if RV1.NumberOfValues(0) <> RV1.Count then Error(EWrongResult);
    RV1.Pack;
    if RV1.NumberOfValues(1) <> 0 then Error(EWrongResult);
    if RV2.NumberOfValues(0) <> 0 then Error(EWrongResult);
    if RV2.NumberOfValues(1) <> RV2.Count then Error(EWrongResult);

    if V1.IndexOf(0) <> 0 then Error(EWrongResult);
    if V1.LastIndexOf(0) <> 4 then Error(EWrongResult);
    if V1.IndexOf(1) <> -1 then Error(EWrongResult);
    if V1.LastIndexOf(1) <> -1 then Error(EWrongResult);
    Check(RV1, [0, 0, 0, 0, 0]);
    if RV1.IndexOf(0) <> 0 then Error(EWrongResult);
    if RV1.LastIndexOf(0) <> 4 then Error(EWrongResult);
    if RV1.IndexOf(1) <> -1 then Error(EWrongResult);
    if RV1.LastIndexOf(1) <> -1 then Error(EWrongResult);
    Check(V2, [1, 1, 1, 1, 1]);
    if V2.IndexOf(0) <> -1 then Error(EWrongResult);
    if V2.LastIndexOf(0) <> -1 then Error(EWrongResult);
    if V2.IndexOf(1) <> 0 then Error(EWrongResult);
    if V2.LastIndexOf(1) <> 4 then Error(EWrongResult);
    Check(RV2, [1, 1, 1, 1, 1]);
    RV2.Pack;
    if RV2.IndexOf(0) <> -1 then Error(EWrongResult);
    if RV2.LastIndexOf(0) <> -1 then Error(EWrongResult);
    if RV2.IndexOf(1) <> 0 then Error(EWrongResult);
    if RV2.LastIndexOf(1) <> 4 then Error(EWrongResult);

    SetItems(V1);
    Check(V1, [0, 1, 2, 3, 4]);
    V1.AddScalar(1);
    V1.Divide(V1);
    Check(V1, [1, 1, 1, 1, 1]);
    SetItems(V1);
    V1.Divide(V2);
    Check(V1, [0, 1, 2, 3, 4]);
    V1.Divide(RV2);
    Check(V1, [0, 1, 2, 3, 4]);
    if V1.IndexFrom(1, 1) <> 1 then Error(EWrongResult);
    if V1.IndexFrom(2, 1) <> -1 then Error(EWrongResult);
    if V1.LastIndexFrom(4, 4) <> 4 then Error(EWrongResult);
    if V1.LastIndexFrom(3, 4) <> -1 then Error(EWrongResult);
    SetItems(RV1);
    Check(RV1, [0, 1, 2, 3, 4]);
    RV1.Divide(V2);
    Check(RV1, [0, 1, 2, 3, 4]);
    RV1.Divide(RV2);
    Check(RV1, [0, 1, 2, 3, 4]);
    if RV1.IndexFrom(1, 1) <> 1 then Error(EWrongResult);
    if RV1.IndexFrom(2, 1) <> -1 then Error(EWrongResult);
    if RV1.LastIndexFrom(4, 4) <> 4 then Error(EWrongResult);
    if RV1.LastIndexFrom(3, 4) <> -1 then Error(EWrongResult);
    V1.Mul(V1);
    Check(V1, [0, 1, 4, 9, 16]);
    SetItems(V1);
    V1.Mul(RV1);
    Check(V1, [0, 1, 4, 9, 16]);
    SetItems(V1);
    SetItems(RV1);
    SetItems(V2);
    Check(V2, [0, 1, 2, 3, 4]);
    SetItems(RV2);
    RV2.Pack;
    Check(RV2, [0, 1, 2, 3, 4]);

    V1.SortDesc;
    Check(V1, [4, 3, 2, 1, 0]);
    V1.Sort;
    Check(V1, [0, 1, 2, 3, 4]);
    if V1.FindInSorted(2) <> 2 then Error(EWrongResult);
    if V1.FindInSorted(5) <> -1 then Error(EWrongResult);
    RV1.SortDesc;
    Check(RV1, [4, 3, 2, 1, 0]);
    RV1.Sort;
    Check(RV1, [0, 1, 2, 3, 4]);

    V1.SetToDefault;
    Check(V1, [0, 0, 0, 0, 0]);
    RV1.SetToDefault;
    Check(RV1, [0, 0, 0, 0, 0]);
    V2.SetToDefault;
    V2.Pack;
    Check(V2, [1, 1, 1, 1, 1]);
    RV2.SetToDefault;
    Check(RV2, [1, 1, 1, 1, 1]);

    V1.Count:=10;
    Check(V1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    RV1.Count:=10;
    Check(RV1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    V2.Count:=10;
    Check(V2, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    RV2.Count:=10;
    Check(RV2, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);

    V1.Count:=5;
    Check(V1, [0, 0, 0, 0, 0]);
    V1.Clear;
    V1.Count:=5;
    Check(V1, [0, 0, 0, 0, 0]);
    RV1.Count:=5;
    Check(RV1, [0, 0, 0, 0, 0]);
    RV1.Clear;
    RV1.Count:=5;
    Check(RV1, [0, 0, 0, 0, 0]);
    V2.Count:=5;
    Check(V2, [1, 1, 1, 1, 1]);
    V2.Clear;
    V2.Count:=5;
    Check(V2, [1, 1, 1, 1, 1]);
    RV2.Count:=5;
    Check(RV2, [1, 1, 1, 1, 1]);
    RV2.Clear;
    RV2.Count:=5;
    Check(RV2, [1, 1, 1, 1, 1]);

    SetItems(V2);
    if V1.EqualTo(V2) then Error(EWrongResult);
    V1.Assign(V2);
    if not V1.EqualTo(V2) then Error(EWrongResult);
    if not V2.EqualTo(V1) then Error(EWrongResult);
    Check(V1, [0, 1, 2, 3, 4]);
    V1.Count:=6;
    Check(V1, [0, 1, 2, 3, 4, 1]); { DefaultValue changes on Assign }
    V1.Sort;
    Check(V1, [0, 1, 1, 2, 3, 4]);
    if V1.NumberOfValues(1) <> 2 then Error(EWrongResult);
    if V1.NumberOfValues(2) <> 1 then Error(EWrongResult);
    SetItems(RV2);
    RV2.SortDesc;
    if V1.EqualTo(RV2) then Error(EWrongResult);
    V1.Assign(RV2);
    if not V1.EqualTo(RV2) then Error(EWrongResult);
    if not RV2.EqualTo(V1) then Error(EWrongResult);
    RV2.Sort;
    V1.Assign(RV2);
    V1.Count:=6;
    Check(V1, [0, 1, 2, 3, 4, 1]);
    SetItems(RV1);
    if V1.EqualTo(RV1) then Error(EWrongResult);
    V1.Assign(RV1);
    if not V1.EqualTo(RV1) then Error(EWrongResult);
    if not RV1.EqualTo(V1) then Error(EWrongResult);
    V1.Count:=6;
    Check(V1, [0, 1, 2, 3, 4, 0]);

    RV1.Assign(V1);
    if not RV1.EqualTo(V1) then Error(EWrongResult);
    if not V1.EqualTo(RV1) then Error(EWrongResult);
    Check(RV1, [0, 1, 2, 3, 4, 0]);

    V1.Count:=15;

    V1.AddScalar(1);
    Check(V1, [1, 2, 3, 4, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    V1.SubScalar(1);
    V1[V1.Count - 1]:=2;
    Check(V1, [0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2]);
    V1.MulScalar(10);
    Check(V1, [0, 10, 20, 30, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20]);
    V1.DivScalar(10);
    Check(V1, [0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2]);

    V1[V1.Count - 1]:=1;
    V1.AddVector(V1);
    Check(V1, [0, 2, 4, 6, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2]);

    RV1.Count:=15;

    RV1.AddScalar(1);
    Check(RV1, [1, 2, 3, 4, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    RV1.SubScalar(1);
    Check(RV1, [0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    if RV1.NumberOfValues(0) <> 11 then Error(EWrongResult);
    RV1.MulScalar(10);
    Check(RV1, [0, 10, 20, 30, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    RV1.DivScalar(10);
    Check(RV1, [0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    RV1.AddVector(RV1);
    Check(RV1, [0, 2, 4, 6, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    if V1.DotProduct(RV1) <> 120 then Error(EWrongResult);

    if RV1.DotProduct(V1) <> 120 then Error(EWrongResult);

    if V1.DotProduct(V1) <> 124 then Error(EWrongResult);

    V1.SubVector(V1);
    Check(V1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    RV1.SubVector(RV1);
    Check(RV1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    V1.Count:=34;
    SetItems(V1);
    Check(V1, [0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14,
               15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
               30, 31, 32, 33]);
    V2.Count:=34;
    SetItems(V2);
    V2.SortDesc;
    V2.CopyRange(4, V1, 5, 5);
    V2.CopyRange(10, V1, 23, 29);
    V2.CopyRange(40, V1, 23, 29);
    V2.ExchangeRange(0, 35, 3);
    Check(V2, [1,  1,  1,  30, 5, 28, 27, 26, 25, 24, 23, 24, 25, 26, 27, 28,
               29, 16, 15, 14, 13, 12, 11, 10, 9,  8,  7,  6,  5,  4,  3,  2,
               1,  0,  1,  33, 32, 31, 1,  1, 23, 24, 25, 26, 27, 28, 29]);
    V2.Count:=34;
    SetItems(V2);
    V2.SortDesc;
    Check(V2, [33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19,
               18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,
                3,  2,  1,  0]);
    V1.AddVector(V2);
    Check(V1, [33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33,
               33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33,
               33, 33, 33, 33]);

    V1.Count:=0;
    if (V1.Sum <> 0) or (V1.SqrSum <> 0) or (V1.DotProduct(V1) <> 0) then Error(EWrongResult);
    Grow(V1, 8);
    Check(V1, [1, 2, 3, 4, 5, 6, 7, 8]);
    V1.Delete(3);
    Check(V1, [1, 2, 3, 5, 6, 7, 8]);
    V1.Insert(3, 4);
    Check(V1, [1, 2, 3, 4, 5, 6, 7, 8]);
    V1.Delete(7);
    Check(V1, [1, 2, 3, 4, 5, 6, 7]);
    V1.DeleteRange(7, 0);
    Check(V1, [1, 2, 3, 4, 5, 6, 7]);
    V1.DeleteRange(7, -1);
    Check(V1, [1, 2, 3, 4, 5, 6, 7]);
    V1.DeleteRange(3, 4);
    Check(V1, [1, 2, 3]);
    V1.Add(4);
    V1.Add(5);
    V1.Add(6);
    V1.Add(7);

    RV2.Count:=0;
    Grow(RV2, 8);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 8]);
    RV2.Delete(3);
    Check(RV2, [1, 2, 3, 5, 6, 7, 8]);
    RV2.Insert(3, 4);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 8]);
    RV2.Insert(8, 1);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 8, 1]);
    if RV2.Add(0) <> 9 then Error(EWrongResult);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 8, 1, 0]);
    RV2.Delete(9);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 8, 1]);
    RV2.Delete(7);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7, 1]);
    RV2.Delete(7);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7]);
    RV2.DeleteRange(7, 0);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7]);
    RV2.DeleteRange(7, -1);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7]);
    RV2.DeleteRange(3, 4);
    Check(RV2, [1, 2, 3]);
    RV2.Add(4);
    RV2.Add(5);
    RV2.Add(6);
    RV2.Add(7);

    V1.MulScalar(2);
    V1.SubVector(RV2);
    Check(V1, [1, 2, 3, 4, 5, 6, 7]);

    RV2.MulScalar(2);
    RV2.SubVector(V1);
    Check(RV2, [1, 2, 3, 4, 5, 6, 7]);

    if V1.Remove(5) <> 4 then Error(EWrongResult);
    Check(V1, [1, 2, 3, 4, 6, 7]);
    if V1.Remove(5) <> -1 then Error(EWrongResult);
    V1[3]:=2;
    if V1.RemoveLast(2) <> 3 then Error(EWrongResult);
    Check(V1, [1, 2, 3, 6, 7]);
    V1[3]:=2;
    if V1.RemoveFrom(2, 2) <> 3 then Error(EWrongResult);
    V1.Add(3);
    V1.Insert(2, 4);
    Check(V1, [1, 2, 4, 3, 7, 3]);
    if V1.RemoveLastFrom(3, 3) <> 3 then Error(EWrongResult);
    Check(V1, [1, 2, 4, 7, 3]);

    V1.Move(3, 1);
    Check(V1, [1, 7, 2, 4, 3]);
    V1.Move(0, 4);
    Check(V1, [7, 2, 4, 3, 1]);

    V1.AddScaled(2, V1);
    Check(V1, [3 * 7, 3 * 2, 3 * 4, 3 * 3, 3 * 1]);

    if RV2.Remove(5) <> 4 then Error(EWrongResult);
    Check(RV2, [1, 2, 3, 4, 6, 7]);
    if RV2.Remove(5) <> -1 then Error(EWrongResult);
    RV2[3]:=2;
    if RV2.RemoveLast(2) <> 3 then Error(EWrongResult);
    Check(RV2, [1, 2, 3, 6, 7]);
    RV2[3]:=2;
    if RV2.RemoveFrom(2, 2) <> 3 then Error(EWrongResult);
    RV2.Add(3);
    RV2.Insert(2, 4);
    Check(RV2, [1, 2, 4, 3, 7, 3]);
    if RV2.RemoveLastFrom(3, 3) <> 3 then Error(EWrongResult);
    Check(RV2, [1, 2, 4, 7, 3]);

    RV2.Move(3, 1);
    Check(RV2, [1, 7, 2, 4, 3]);
    RV2.Move(0, 4);
    Check(RV2, [7, 2, 4, 3, 1]);
    if RV1.EqualTo(RV2) then Error(EWrongResult);
    RV1.Assign(RV2);
    Check(RV1, [7, 2, 4, 3, 1]);
    if not RV1.EqualTo(RV2) then Error(EWrongResult);
    if not RV2.EqualTo(RV1) then Error(EWrongResult);

    Test(V2);
    Test(RV2);

    V1.Count:=1;
    V1[0]:=5;
    RV2.Assign(V1);
    RV2.Count:=2;
    Check(RV2, [5, 0]);
  finally
    V1.Free;
    RV1.Free;
    V2.Free;
    RV2.Free;
  end;
end;
