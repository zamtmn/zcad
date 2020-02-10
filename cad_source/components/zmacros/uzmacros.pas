unit uzmacros;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  MacroIntf,TransferMacros,MacroDefIntf;//From lazarus ide

type
  TDefaultMacroMethods=class
      function MacroFuncTargetCPU(const {%H-}Param: string; const Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
      function MacroFuncTargetOS (const {%H-}Param: string; const Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
  end;
  TZMacros = class
  public
    function SubstituteMacros(var s: string): boolean;virtual;
  end;



var
  DMM:TDefaultMacroMethods;
  DefaultMacros:TZMacros = nil;
  MainMacroList: TTransferMacroList = nil;
implementation

function TZMacros.SubstituteMacros(var s: string): boolean;
begin
  Result:=MainMacroList.SubstituteStr(s);
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
  DefaultMacros:=TZMacros.Create;
  MainMacroList:=TTransferMacroList.Create;
  DMM:=TDefaultMacroMethods.Create;

  MainMacroList.Add(TTransferMacro.Create('CPU','',
                      'CPU',@DMM.MacroFuncTargetCPU,[]));
  MainMacroList.Add(TTransferMacro.Create('OS','',
                      'OS',@DMM.MacroFuncTargetOS,[]));
finalization
  FreeAndNil(DMM);
  FreeAndNil(MainMacroList);
end.
