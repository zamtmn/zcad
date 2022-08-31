unit Logtest;

interface

uses
  SysUtils,TypInfo,
  fpcunit,
  testregistry,uzbLog;

type
  TLogTest = class(TTestCase)
  Published
    Procedure WithoutLog;
    Procedure WithLog;
  end;


implementation

Procedure TLogTest.WithoutLog;
var
  i,j:Integer;
begin
  for i:=0 to 10000 do
    for j:=0 to 10000 do
    ;
end;

Procedure TLogTest.WithLog;
var
  i,j:Integer;
  log:tlog;
begin
  log.init();
  for i:=0 to 10000 do
    for j:=0 to 10000 do
    log.LogOutStr('test')
    ;
  log.done;
end;


begin
  RegisterTests([TLogTest]);
end.

