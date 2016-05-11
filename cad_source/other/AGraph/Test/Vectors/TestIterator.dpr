program TestIterator;

{$APPTYPE CONSOLE}

uses
  SIDic;

procedure Test;
var
  SI: TStrIntDic;
  It: TStrIntDicIterator;

  procedure Print;
  begin
    It.First;
    while not It.EOF do begin
      writeln(It.Data.key);
      It.Next;
    end;
    writeln;
  end;

begin
  SI:=TStrIntDic.Create;
  It:=TStrIntDicIterator.Create(SI);
  try
    Print;
    SI.Add('iop', 0);
    Print;
    SI.Add('qwe', 0);
    Print;
    SI.Add('ert', 0);
    Print;
    SI.Add('abc', 0);
    SI.Add('zxc', 0);
    Print;
  finally
    SI.Free;
    It.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
