unit uzmacros;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  MacroIntf,TransferMacros,MacroDefIntf;//From lazarus ide

  // todo: когда пакет ideconfig попадет в релиз
  // нужно убрать $(LazarusDir)\ide\packages\ideconfig из путей и
  // и добавить зависимость от ideconfig

type
  TMacroProcessFunc=function (var s: string): boolean of object;
  TDefaultMacroMethods=class
    function MacroFuncTargetCPU(const {%H-}Param: string; const Data: PtrInt;
                                  var {%H-}Abort: boolean): string;
    function MacroFuncTargetOS (const {%H-}Param: string; const Data: PtrInt;
                                  var {%H-}Abort: boolean): string;
  end;
  generic TZMacros<T> = class
  public
    CurrentContext:T;
    procedure setMarkUnhandled(m:boolean);
    function SubstituteMacros(var s: string): boolean;virtual;
    function SubstituteMacrosWithCurrentContext(var s: string): boolean;virtual;
    procedure AddMacro(NewMacro:TTransferMacro);virtual;

    procedure SetCurrentContext(ctx:T);
    procedure ReSetCurrentContext(ctx:T);

  end;
  TDefaultMacros=specialize TZMacros<tobject>;



var
  DMM:TDefaultMacroMethods;
  DefaultMacros:TDefaultMacros = nil;
  MainMacroList: TTransferMacroList = nil;
implementation

generic procedure TZMacros<T>.SetCurrentContext(ctx:T);
begin
  CurrentContext:=ctx;
end;
generic procedure TZMacros<T>.ReSetCurrentContext(ctx:T);
begin
  CurrentContext:=default(T);
end;

procedure TZMacros.setMarkUnhandled(m:boolean);
begin
  MainMacroList.MarkUnhandledMacros:=m;
end;

function TZMacros.SubstituteMacros(var s: string): boolean;
begin
  Result:=MainMacroList.SubstituteStr(s);
end;

function TZMacros.SubstituteMacrosWithCurrentContext(var s: string): boolean;
begin
  Result:=MainMacroList.SubstituteStr(s,PtrInt(@CurrentContext));
end;

procedure TZMacros.AddMacro(NewMacro:TTransferMacro);
begin
  MainMacroList.Add(NewMacro);
end;

function TDefaultMacroMethods.MacroFuncTargetCPU(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
    Result:={$I %FPCTARGETCPU%};
end;
function TDefaultMacroMethods.MacroFuncTargetOS(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
    Result:={$I %FPCTARGETOS%};
end;

initialization
  DefaultMacros:=TDefaultMacros.Create;
  MainMacroList:=TTransferMacroList.Create;
  DMM:=TDefaultMacroMethods.Create;
  DefaultMacros.AddMacro(TTransferMacro.Create('CPU','',
                         'CPU',@DMM.MacroFuncTargetCPU,[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('OS','',
                         'OS',@DMM.MacroFuncTargetOS,[]));
finalization
  FreeAndNil(DefaultMacros);
  FreeAndNil(DMM);
  FreeAndNil(MainMacroList);
end.
