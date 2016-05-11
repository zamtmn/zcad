program VBench;

{$I VCheck.inc}

{$IFDEF V_FREEPASCAL}
  {$DEFINE CONS}
{$ENDIF}
{$IFDEF LINUX}
  {$DEFINE CONS}
{$ENDIF}

uses
  Benchmrk{$IFNDEF CONS}, Forms, Debug{$ENDIF};

{$IFDEF CONS}{$APPTYPE CONSOLE}{$ENDIF}

begin
  RunBenchMark(350);
  {$IFNDEF CONS}
  Application.Run;
  {$ENDIF}
end.

