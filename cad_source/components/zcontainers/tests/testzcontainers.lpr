program testzcontainers;

{$mode objfpc}{$H+}

uses
  //MemCheck,
  Classes, consoletestrunner,
  zvectorsimpletest;

type

  { TLazTestRunner }

  TMyTestRunner = class(TTestRunner)
  protected
  // override the protected methods of TTestRunner to customize its behavior
  end;

var
  Application: TMyTestRunner;

begin
  Application := TMyTestRunner.Create(nil);
  DefaultFormat:={fplain}fXML;
  DefaultRunAllTests:=True;
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
