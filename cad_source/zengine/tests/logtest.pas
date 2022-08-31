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
  i,j,a:Integer;
begin
  for i:=0 to 10000 do begin
    for j:=0 to 10000 do
      a:=j;
  end;
end;

Procedure TLogTest.WithLog;
var
  i,j,a:Integer;
  log:tlog;
begin
  log.init();
  for i:=0 to 10000 do begin
    for j:=0 to 10000 do
      a:=j;
    log.LogOutStr('test');
  end;
  log.done;
end;


begin
  RegisterTests([TLogTest]);
end.

