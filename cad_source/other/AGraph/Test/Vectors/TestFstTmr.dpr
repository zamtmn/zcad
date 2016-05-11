program TestFstTmr;

uses
  SysUtils,
  VFstTmr;

{$APPTYPE CONSOLE}

procedure Test;
const
  TestTime = 2;
var
  T: TVFastTimer;
  I: Integer;
  S1, S2: String;
begin
  T:=TVFastTimer.Create;
  try
    write('Formatting string using ''+'' operator: ');
    S2:='567';
    I:=0;
    T.Start;
    repeat
      S1:='123' + S2 + '890';
      Inc(I);
    until T.UsedTime >= TestTime;
    T.Stop;
    writeln(I div TestTime, ' times per second');
    write('Formatting string using ''Format'' operator: ');
    I:=0;
    T.Start;
    repeat
      S1:=Format('123%s890', [S2]);
      Inc(I);
    until T.UsedTime >= TestTime;
    T.Stop;
    writeln(I div TestTime, ' times per second');
  finally
    T.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
