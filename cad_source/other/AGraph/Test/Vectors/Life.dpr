program Life;

{$I VCheck.inc}

uses
  Boolm,
  {$IFDEF WIN32}
  Windows
  {$ELSE}
    {$IFDEF V_DELPHI}
    WinCrt
    {$ELSE}
    Crt
    {$ENDIF}
  {$ENDIF};

{$IFDEF WIN32}
{$APPTYPE CONSOLE}
{$ENDIF}

const
  N = 20;
  Density = 0.5;
var
  OldState, NewState: TBoolMatrix;

procedure InitializeField;
var
  I, J: Integer;
begin
  for I:=0 to N - 1 do
    for J:=0 to N - 1 do
      if Random <= Density then OldState[I, J]:=True;
end;

procedure PrintField;
{$IFDEF WIN32}
var
  Coord: TCoord;
{$ENDIF}
begin
  {$IFDEF WIN32}
  Integer(Coord):=0;
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
  {$ELSE}
  GotoXY(1, 1);
  {$ENDIF}
  OldState.DebugWrite01;
end;

procedure Simulate;
var
  I, J: Integer;

  function NumOfNeighbours(I, J: Integer): Integer;
  var
    Sum: Integer;

    procedure Check(K, L: Integer);
    begin
      if (K >= 0) and (K < N) and (L >= 0) and (L < N) then
        Inc(Sum, Ord(OldState[K, L]));
    end;

  begin
    Sum:=0;
    Check(I - 1, J - 1);
    Check(I - 1, J);
    Check(I - 1, J + 1);
    Check(I, J - 1);
    Check(I, J + 1);
    Check(I + 1, J - 1);
    Check(I + 1, J);
    Check(I + 1, J + 1);
    Result:=Sum;
  end;

begin
  for I:=0 to N - 1 do
    for J:=0 to N - 1 do
      if OldState[I, J] then
        NewState[I, J]:=NumOfNeighbours(I, J) in [2..3]
      else
        NewState[I, J]:=NumOfNeighbours(I, J) = 3;
  OldState.Assign(NewState);
  PrintField;
end;

var
  C: Char;
begin
  Randomize;
  OldState:=TBoolMatrix.Create(N, N, False);
  NewState:=TBoolMatrix.Create(N, N, False);
  try
    InitializeField;
    PrintField;
    repeat
      Simulate;
      write('Press Return to continue, ^C to quit...');
    {$IFDEF V_WIN}
      readln;
    until False;
    {$ELSE}
      readln(C); { for GO32V2 }
    until C = ^C;
    {$ENDIF}
  finally
    OldState.Free;
    NewState.Free;
  end;
end.
