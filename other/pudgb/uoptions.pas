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
  TCircularG=packed record
    CalcEdgesWeight:Boolean;
  end;
  TFullG=packed record
    IncludeNotFoundedUnits:Boolean;
    IncludeInterfaceUses:Boolean;
    IncludeImplementationUses:Boolean;
    IncludeOnlyLoops:Boolean;
    SourceUnit:string;
    DestUnit:string;
    CalcEdgesWeight:Boolean;
  end;
  TEdgeType=(ETContinuous,ETDotted);
  TGraphBulding=packed record
    Circ:TCircularG;
    FullG:TFullG;
    InterfaceUsesEdgeType:TEdgeType;
    ImplementationUsesEdgeType:TEdgeType;
    PathClusters:Boolean;
  end;
  TLogger=packed record
    ScanerMessages:Boolean;
    ParserMessages:Boolean;
    Timer:Boolean;
    Notfounded:Boolean;
  end;
  TOptions=packed record
    Paths:TPaths;
    ParserOptions:TParser;
    GraphBulding:TGraphBulding;
    Logger:TLogger;
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
 {$ifdef CPU64}adddef('CPU64');{$endif}
 {$ifdef CPU32}adddef('CPU32');{$endif}

 {$ifdef LCLWIN32}adddef('LCLWIN32');{$endif}
 {$ifdef LCLQT}adddef('LCLQT');{$endif}
 {$ifdef LCLQT5}adddef('LCLQT5');{$endif}
 {$ifdef LCLGTK2}adddef('LCLGTK2');{$endif}
end;

function DefaultOptions:TOptions;
begin
 result.Paths._File:='?? import or edit this';
 result.Paths._Paths:='?? import or edit this';

 result.ParserOptions._CompilerOptions:='-Sc '+GetCompilerDefs;
 result.ParserOptions.TargetOS:={$I %FPCTARGETOS%};
 result.ParserOptions.TargetCPU:={$I %FPCTARGETCPU%};

 result.GraphBulding.FullG.IncludeNotFoundedUnits:=false;
 result.GraphBulding.FullG.IncludeInterfaceUses:=true;
 result.GraphBulding.InterfaceUsesEdgeType:=ETContinuous;
 result.GraphBulding.FullG.IncludeImplementationUses:=true;
 result.GraphBulding.ImplementationUsesEdgeType:=ETDotted;
 result.GraphBulding.PathClusters:=true;
 result.GraphBulding.FullG.IncludeOnlyLoops:=false;
 result.GraphBulding.FullG.CalcEdgesWeight:=true;
 result.GraphBulding.Circ.CalcEdgesWeight:=false;

 result.GraphBulding.FullG.SourceUnit:='uzeentity';
 result.GraphBulding.FullG.DestUnit:='uzeenttext';
end;

end.

