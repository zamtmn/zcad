program TestM;

{$I VCheck.inc}

uses
  TestMatr{$IFDEF V_WIN}{$IFNDEF WIN32}, WinCrt{$ENDIF}{$ENDIF};

{$IFDEF WIN32}{$APPTYPE CONSOLE}{$ENDIF}

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
