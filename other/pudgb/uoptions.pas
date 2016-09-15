unit uoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uzbtypesbase;

type
  {$Z1}
  TPaths=packed record
    _File:GDBString;
    _Paths:GDBString;
  end;
  TFileSearhing=packed record
  end;
  TParser=packed record
    _CompilerOptions:GDBString;
    TargetOS,TargetCPU:GDBString;
  end;
  TEdgeType=(ETContinuous,ETDotted);
  TGraphBulding=packed record
    IncludeInterfaceUses:GDBBoolean;
    InterfaceUsesEdgeType:TEdgeType;
    IncludeImplementationUses:GDBBoolean;
    ImplementationUsesEdgeType:TEdgeType;
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

 result.GraphBulding.IncludeInterfaceUses:=true;
 result.GraphBulding.InterfaceUsesEdgeType:=ETContinuous;
 result.GraphBulding.IncludeImplementationUses:=true;
 result.GraphBulding.ImplementationUsesEdgeType:=ETDotted;
end;

end.

