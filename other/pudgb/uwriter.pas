unit uwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uoptions,uscanresult;



procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure ProcessNode(Options:TOptions;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;ForceInclude:boolean=false);

implementation
function IncludeToGraph(Options:TOptions;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
begin
  result:=false;
  if not Options.GraphBulding.IncludeNotFoundedUnits then
    if (node.UnitPath='')and(index<>0) then exit;
  if Options.GraphBulding.IncludeOnlyLoops and not(UFLoop in node.UnitFlags) then exit;
  result:=true;
end;

procedure ProcessNode(Options:TOptions;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;ForceInclude:boolean=false);
begin
  if node.NodeState=NSNotCheced then
  begin
    if ForceInclude or IncludeToGraph(Options,Node,index,LogWriter)then
    begin
        if Node.UnitType=UTProgram then
          LogWriter(format(' %s [shape=box]',[Node.UnitName]));
        if (Node.UnitPath='')and(index<>0) then
          LogWriter(format(' %s [style=dashed]',[Node.UnitName]));
        node.NodeState:=NSCheced;
    end
    else
        node.NodeState:=NSFiltredOut;
  end;
end;

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  i,j:integer;
  s:string;
begin
  if assigned(LogWriter) then
  begin
    LogWriter('DiGraph Classes {');
    if assigned(ScanResult) then
    begin
      for i:=0 to ScanResult.UnitInfoArray.Size-1 do
       ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;

    if Options.GraphBulding.IncludeInterfaceUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].InterfaceUses.Size>0 then
     begin
       ProcessNode(Options,ScanResult.UnitInfoArray.Mutable[i]^,i,LogWriter);
       if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         ProcessNode(Options,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].InterfaceUses[j]]^,ScanResult.UnitInfoArray[i].InterfaceUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.InterfaceUsesEdgeType=ETDotted then
                                                                    LogWriter(' edge [style=dotted]')
                                                                else
                                                                    LogWriter(' edge [style=solid]');
         LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].UnitName]));
         end;
       end;
     end;
    end;

    if Options.GraphBulding.IncludeImplementationUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
     if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
     begin
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
       begin
         ProcessNode(Options,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].ImplementationUses[j]]^,ScanResult.UnitInfoArray[i].ImplementationUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.ImplementationUsesEdgeType=ETDotted then
                                                                         LogWriter(' edge [style=dotted]')
                                                                     else
                                                                         LogWriter(' edge [style=solid]');
           LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
         end;
       end;
     end;
    end;
    end;

    LogWriter('}');
    //LogWriter('CUT HERE 8x----------------------');

  end;
end;



end.

