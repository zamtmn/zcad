program vtbasic;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, Main
  {$ifdef DEBUG_VTV}
  ,vtlogger, ipcchannel
  {$endif}
  ;

{$R *.res}

begin
  {$ifdef DEBUG_VTV}
  Logger.Channels.Add(TIPCChannel.Create);
  Logger.Clear;
  Logger.ActiveClasses := [lcScroll, lcWarning];
  {$endif}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

