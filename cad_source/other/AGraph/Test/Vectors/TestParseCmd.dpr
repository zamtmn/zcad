program TestParseCmd;

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,{$ENDIF}
  ParseCmd;

{$APPTYPE CONSOLE}

procedure Test;
var
  CLP: TCommandLineParser;
  I: Integer;
  S: String;
begin
  CLP:=TCommandLineParser.Create([], True);
  try
//    S:=GetCommandLine;
    S:='program file1 /i:i_value file2 /f -g /help file3';
    writeln('Command Line: ', S);
    CLP.Parse(S, 1);
    writeln('ParamCount: ', CLP.ParamCount);
    for I:=0 to CLP.ParamCount - 1 do
      writeln(I, ': ', CLP.ParamStr(I));
    writeln('SimpleParamCount: ', CLP.SimpleParamCount);
    for I:=0 to CLP.SimpleParamCount - 1 do
      writeln(I, ': ', CLP.SimpleParamStr(I));
    writeln('OptionCount: ', CLP.OptionCount);
    for I:=0 to CLP.OptionCount - 1 do
      writeln(I, ': ', CLP.OptionStr(I));
    writeln('HasOption(''i''): ', CLP.HasOption('i'));
    writeln('HasOption(''I''): ', CLP.HasOption('I'));
    writeln('OptionValue(''i''): ', CLP.OptionValue('i'));
    writeln('OptionValue(''I''): ', CLP.OptionValue('I'));
  finally
    CLP.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
