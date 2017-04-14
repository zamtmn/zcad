unit uoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uzbtypesbase;

type
  {$Z1}
  TPaths=packed record
    _File:String;
    _Paths:String;
  end;
  TFileSearhing=packed record
  end;
  TParser=packed record
    _CompilerOptions:String;
    TargetOS,TargetCPU:String;
  end;
  TEdgeType=(ETContinuous,ETDotted);
  TGraphBulding=packed record
    IncludeNotFoundedUnits:Boolean;
    IncludeInterfaceUses:Boolean;
    InterfaceUsesEdgeType:TEdgeType;
    IncludeImplementationUses:Boolean;
    ImplementationUsesEdgeType:TEdgeType;
    IncludeOnlyLoops:Boolean;
  end;
  TOptions=packed record
    Paths:TPaths;
    ParserOptions:TParser;
    GraphBulding:TGraphBulding;
  end;

  TLogWriter=procedure(msg:string) of object;

function DefaultOptions:TOptions;
function GetCompilerDefs:String;

implementation
function GetCompilerDefs:String;
procedure adddef(def:string);
begin
 if result='' then
                  result:=format('-d%s',[def])
              else
                  result:=result+format(' -d%s',[def]);
end;
begin
 result:='';
 {$ifdef LINUX}adddef('LINUX');{$endif}
 {$ifdef WINDOWS}adddef('WINDOWS');{$endif}
 {$ifdef MSWINDOWS}adddef('MSWINDOWS');{$endif}
 {$ifdef WIN32}adddef('WIN32');{$endif}
 {$ifdef LCLWIN32}adddef('LCLWIN32');{$endif}
 {$ifdef FPC}adddef('FPC');{$endif}
end;

function DefaultOptions:TOptions;
begin
 result.Paths._File:='?? import or edit this';
 result.Paths._Paths:='?? import or edit this';

 result.ParserOptions._CompilerOptions:='-Sc '+GetCompilerDefs;
 result.ParserOptions.TargetOS:={$I %FPCTARGETOS%};
 result.ParserOptions.TargetCPU:={$I %FPCTARGETCPU%};

 result.GraphBulding.IncludeNotFoundedUnits:=false;
 result.GraphBulding.IncludeInterfaceUses:=true;
 result.GraphBulding.InterfaceUsesEdgeType:=ETContinuous;
 result.GraphBulding.IncludeImplementationUses:=true;
 result.GraphBulding.ImplementationUsesEdgeType:=ETDotted;
 result.GraphBulding.IncludeOnlyLoops:=false;
end;

end.

