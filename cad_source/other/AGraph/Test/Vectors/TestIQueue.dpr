program TestIQueue;

uses
  IQueue;

{$APPTYPE CONSOLE}

procedure Test;
var
  Q: TIntegerQueue;
  I: Integer;
begin
  Q:=TIntegerQueue.Create;
  try
    Q.AddAfter(2);
    Q.AddAfter(3);
    Q.InsertBefore(1);
    writeln('Empty: ', Q.IsEmpty);
    writeln('Head: ', Q.Head);
    writeln('Tail: ', Q.Tail);
    writeln('Delete all');
    for I:=0 to Q.Count - 1 do
      writeln(Q.DeleteHead);
    writeln('Empty: ', Q.IsEmpty);
    Q.InsertBefore(2);
    Q.InsertBefore(1);
    Q.AddAfter(3);
    while not Q.IsEmpty do
      writeln(Q.DeleteHead);
  finally
    Q.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.