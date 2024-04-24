program testdxfload;

{$mode objfpc}{$H+}

uses
  //MemCheck,
  Classes, consoletestrunner,
  dxfloadsimpletest;

var
  Application: TTestRunner;

begin
  Application := TTestRunner.Create(nil);
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
