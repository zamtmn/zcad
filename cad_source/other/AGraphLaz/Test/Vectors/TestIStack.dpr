program TestIStack;

uses
  IStack;

{$APPTYPE CONSOLE}

procedure Test;
var
  S: TIntegerStack;
  I: Integer;
begin
  S:=TIntegerStack.Create;
  try
    S.Push(1);
    S.Push(2);
    S.Push(5);
    writeln('Empty: ', S.IsEmpty);
    writeln('Top: ', S.Top);
    S.SetTop(3);
    writeln('Top: ', S.Top);
    writeln('Pop all');
    for I:=0 to S.Count - 1 do
      writeln(S.Pop);
    writeln('Empty: ', S.IsEmpty);
    S.Push(3);
    S.Push(2);
    S.Push(1);
    while not S.IsEmpty do
      writeln(S.Pop);
  finally
    S.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.