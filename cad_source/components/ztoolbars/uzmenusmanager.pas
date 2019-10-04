unit uzmenusmanager;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,sysutils;

type
  TMenuContextNameType=string;
  TContextStateType=boolean;
  TCMenuContextNameManipulator=class
    class function Standartize(id:TMenuContextNameType):TMenuContextNameType;
    class function DefaultContexCheckState:TContextStateType;
  end;
  generic TCMContextChecker<T>=class (specialize TGCContextChecker<T,TMenuContextNameType,TContextStateType,TCMenuContextNameManipulator>)
  end;
  TTestContextChecker=specialize TCMContextChecker<integer>;
var
  CC:TTestContextChecker;
  Cashe:TTestContextChecker.TContextStateRegister;

implementation

class function TCMenuContextNameManipulator.Standartize(id:TMenuContextNameType):TMenuContextNameType;
begin
  result:=uppercase(id);
end;
class function TCMenuContextNameManipulator.DefaultContexCheckState:TContextStateType;
begin
  result:=false;
end;
function testCheck(const Context:integer):boolean;
begin
  if Context=5 then
    result:=true
  else
    result:=false;
end;

initialization
  CC:=TTestContextChecker.create;
  CC.RegisterContextCheckFunc('test',@testCheck);
  Cashe:={TContextStateRegister.create}nil;
  CC.CashedContextCheck(Cashe,'teSt',5);
  CC.CashedContextCheck(Cashe,'tEst',5);
  if assigned(Cashe) then
    Cashe.free;
finalization
end.
