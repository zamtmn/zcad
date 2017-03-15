unit TBool;

interface

uses ExtType, Boolv, TestProc;

procedure TestBoolVectors;

implementation

procedure TestBoolVectors;
var
  B1, B2, PB1, PB2: TBoolVector;

  procedure Check(Vector: TBoolVector; const Values: array of Boolean);
  var
    I: Integer;
  begin
    if Vector.Count <> High(Values) + 1 then Error(EWrongResult);
    for I:=0 to High(Values) do
      if Vector[I] <> Values[I] then Error(EWrongResult);
  end;

  procedure SetItems(Vector: TBoolVector; B: Bool);
  var
    I: Integer;
  begin
    for I:=0 to Vector.Count - 1 do begin
      Vector[I]:=B;
      B:=not B;
    end;
  end;

  procedure CheckEqual(Vector: TBoolVector; B: Bool);
  var
    I: Integer;
  begin
    for I:=0 to Vector.Count - 1 do
      if Vector[I] <> B then Error(EWrongResult);
  end;

  procedure Check1;
  begin
    CheckEqual(B1, False);
    CheckEqual(B2, True);
    CheckEqual(PB1, False);
    CheckEqual(PB2, True);
  end;

begin
  B1:=TBoolVector.Create(5, False);
  B2:=TBoolVector.Create(5, True);
  PB1:=TPackedBoolVector.Create(5, False);
  PB2:=TPackedBoolVector.Create(5, True);
  try
    Check1;

    SetItems(B1, True);
    SetItems(B2, True);
    SetItems(PB1, True);
    SetItems(PB2, True);
    Check(B1, [True, False, True, False, True]);
    Check(B2, [True, False, True, False, True]);
    Check(PB1, [True, False, True, False, True]);
    Check(PB2, [True, False, True, False, True]);

    B1.SetToDefault;
    B2.SetToDefault;
    PB1.SetToDefault;
    PB2.SetToDefault;

    Check1;

    B1.Count:=50;
    B2.Count:=50;
    PB1.Count:=50;
    PB2.Count:=50;

    Check1;

    if B2.NumTrue <> B2.Count then Error(EWrongResult);

    B1.OrVector(B2);
    CheckEqual(B1, True);

    B1.SetToDefault;
    B2.AndVector(B1);
    CheckEqual(B2, False);
    B2.NotVector;
    CheckEqual(B2, True);
    PB1.OrVector(B2);
    CheckEqual(PB1, True);
    if PB1.NumTrue <> PB1.Count then Error(EWrongResult);

    PB1.SetToDefault;
    PB2.AndVector(PB1);
    CheckEqual(PB2, False);
    if PB2.NumTrue <> 0 then Error(EWrongResult);
    PB2.NotVector;
    CheckEqual(PB2, True);
    if PB2.NumTrue <> PB2.Count then Error(EWrongResult);

    B2.Count:=10;
    SetItems(B2, False);
    Check(B2, [False, True, False, True, False, True, False, True, False, True]);
    PB2.Assign(B2);
    Check(PB2, [False, True, False, True, False, True, False, True, False, True]);
    PB2.Count:=12;
    { DefaultValue changes on Assign }
    Check(PB2, [False, True, False, True, False, True, False, True, False, True,
      True, True]);
    PB2.SetToDefault;
    CheckEqual(PB2, True);

    B1.Count:=12;
    SetItems(B1, False);
    PB1.Assign(B1);
    B1.Sort;
    PB1.Sort;
    Check(B1, [False, False, False, False, False, False, True, True, True, True,
      True, True]);
    Check(PB1, [False, False, False, False, False, False, True, True, True, True,
      True, True]);
    PB1.Insert(2, True);
    Check(PB1, [False, False, True, False, False, False, False, True, True, True,
      True, True, True]);
    PB1.Delete(2);
    Check(PB1, [False, False, False, False, False, False, True, True, True, True,
      True, True]);
  finally
    B1.Free;
    B2.Free;
    PB1.Free;
    PB2.Free;
  end;
end;

end.
