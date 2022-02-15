program testzcontainers;

{$mode objfpc}{$H+}

uses
  //MemCheck,
  Classes, consoletestrunner,
  zvectorsimpletest;

var
  Application: TTestRunner;

begin
  Application := TTestRunner.Create(nil);
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
