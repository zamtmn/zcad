program VTest;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Testproc in 'TESTPROC.PAS' {$IFDEF WIN32},
  Windows {$ELSE},
  WinCrt {$ENDIF},
  Debug in 'Debug.pas' {DebugForm};

begin
  {$IFDEF WIN32}AllocConsole;{$ENDIF}
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.Run;
end.
