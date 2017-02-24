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

implementation
function DefaultOptions:TOptions;
begin
 result.Paths._File:='?? import or edit this';
 result.Paths._Paths:='?? import or edit this';

 result.ParserOptions._CompilerOptions:='-Sc';
 result.ParserOptions.TargetOS:='linux';
 result.ParserOptions.TargetCPU:='i386';

 result.GraphBulding.IncludeNotFoundedUnits:=false;
 result.GraphBulding.IncludeInterfaceUses:=true;
 result.GraphBulding.InterfaceUsesEdgeType:=ETContinuous;
 result.GraphBulding.IncludeImplementationUses:=true;
 result.GraphBulding.ImplementationUsesEdgeType:=ETDotted;
 result.GraphBulding.IncludeOnlyLoops:=false;
end;

end.

