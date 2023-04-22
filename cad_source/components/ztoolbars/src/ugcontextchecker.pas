unit ugcontextchecker;

{$mode objfpc}{$H+}

interface

uses
  LCLType,ImgList,
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,ActnList,
  LazConfigStorage,Laz2_XMLCfg,Laz2_DOM,
  Generics.Collections, Generics.Defaults, gvector, gtree;

type
  generic TGCContextIdManipulator<TGContextIdType,TGContextStateType>=class
    class function Standartize(id:TGContextIdType):TGContextIdType;
    class function DefaultContexCheckState:TGContextStateType;
  end;
  generic TGCContextChecker<TGContextType,TGContextIdType,TGContextStateType,TGContextIdManipulator>=class
  type
    //TGContextIdType=String;
    //TGContextStateType=Boolean;
    TContextIdType=TGContextIdType;
    TContextCheckFunc=function(const Context:TGContextType):TGContextStateType;
    TContextCheckFuncRegister=specialize TDictionary <TGContextIdType,TContextCheckFunc>;
    TContextStateRegister=specialize TDictionary <TContextCheckFunc,TGContextStateType>;
  var
    ContextStateRegister:TContextCheckFuncRegister;
    constructor Create;
    destructor Destroy; override;
    procedure RegisterContextCheckFunc(ContextId:TGContextIdType;ContextCheckFunc:TContextCheckFunc);
    procedure CasheContextState(Cashe:TContextStateRegister;ContextId:TGContextIdType;ContextCheckFunc:TContextCheckFunc;value:TGContextStateType);
    function ContextCheck(const ContextId:TGContextIdType;const Context:TGContextType):TGContextStateType;
    function CashedContextCheck(var Cashe:TContextStateRegister;const ContextId:TGContextIdType;const Context:TGContextType):TGContextStateType;
    function ContainContext(const ContextId:TGContextIdType):boolean;
  end;
implementation

class function TGCContextIdManipulator.Standartize(id:TGContextIdType):TGContextIdType;
begin
  result:=id;
end;
class function TGCContextIdManipulator.DefaultContexCheckState:TGContextStateType;
begin
  result:=default(TGContextStateType);
end;

constructor TGCContextChecker.Create;
begin
  ContextStateRegister:=nil;
end;

destructor TGCContextChecker.Destroy;
begin
  if assigned(ContextStateRegister)then
    FreeAndNil(ContextStateRegister);
end;

procedure TGCContextChecker.RegisterContextCheckFunc(ContextId:TGContextIdType;ContextCheckFunc:TContextCheckFunc);
var
  StandartizedContextId:TContextIdType;
  OldContextCheckFunc:TContextCheckFunc;
begin
  if not assigned(ContextStateRegister) then
    ContextStateRegister:=TContextCheckFuncRegister.create;
  StandartizedContextId:=TGContextIdManipulator.Standartize(ContextId);

  if ContextStateRegister.TryGetValue(StandartizedContextId,OldContextCheckFunc) then
    //logmessage
  else
    ContextStateRegister.add(StandartizedContextId,ContextCheckFunc);
end;

function TGCContextChecker.ContextCheck(const ContextId:TGContextIdType;const Context:TGContextType):TGContextStateType;
var
  state:TContextCheckFunc;
begin
  result:=TGContextIdManipulator.DefaultContexCheckState;
  if assigned(ContextStateRegister) then
    if ContextStateRegister.TryGetValue(TGContextIdManipulator.Standartize(ContextId),state)then
      result:=state(Context);
end;

procedure TGCContextChecker.CasheContextState(Cashe:TContextStateRegister;ContextId:TGContextIdType;ContextCheckFunc:TContextCheckFunc;value:TGContextStateType);
begin

end;

function TGCContextChecker.CashedContextCheck(var Cashe:TContextStateRegister;const ContextId:TGContextIdType;const Context:TGContextType):TGContextStateType;
var
  state:TContextCheckFunc;
begin
  result:=TGContextIdManipulator.DefaultContexCheckState;
  if assigned(ContextStateRegister) then
    if ContextStateRegister.TryGetValue(TGContextIdManipulator.Standartize(ContextId),state)then begin
      if assigned(Cashe) then begin
        if Cashe.TryGetValue(state,result)then
          exit
        else begin
          result:=state(Context);
          Cashe.add(state,result);
        end;
      end else begin
        Cashe:=TContextStateRegister.create;
        result:=state(Context);
        Cashe.add(state,result);
      end;
    end;
end;
function TGCContextChecker.ContainContext(const ContextId:TGContextIdType):boolean;
var
  state:TContextCheckFunc;
begin
  result:=ContextStateRegister.TryGetValue(TGContextIdManipulator.Standartize(ContextId),state);
end;

initialization
finalization
end.
