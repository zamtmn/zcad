program mvcdemo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, MVCDemoMain, lclextensions_package;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMVCDemo, fmMVCDemo);
  Application.Run;
end.

