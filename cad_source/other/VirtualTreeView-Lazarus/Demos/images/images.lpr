program images;

{$mode objfpc}{$H+}

{.$define DEBUG_VTV}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, Unit1
  {$ifdef DEBUG_VTV}
  ,ipcchannel, vtlogger
  {$endif}
  ;

{$R *.res}

begin
  {$ifdef DEBUG_VTV}
  Logger.Channels.Add(TIPCChannel.Create);
  Logger.Clear;
  Logger.ActiveClasses := [lcHeaderOffset];
  {$endif}

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

