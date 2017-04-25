unit yEdWriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uoptions,uscanresult,uwriter;

{$I yed.inc}
// потом продумаю подробнее параметры
procedure WriteGML (Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure NodeGML (Options:TOptions;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;ForceInclude:boolean=false);
procedure GraphGML (Options:TOptions; var Node:TUnitInfo); //проставление связей. (второй проход по узлам) параметры пока не ставлю специально.


implementation


procedure WriteGML(Options: TOptions; ScanResult: TScanResult;
  const LogWriter: TLogWriter);
var
  i,j:integer;
  s,Tabs:string;
begin
  if assigned(LogWriter) then
  begin
  //шапка файла
    LogWriter(Title);
    LogWriter(Vers);
    LogWriter('Graph');
    LogWriter(BracketLeft);
    Tabs:=tab; // отступ от начала строки   выставляем на один таб т. к. начинается шапка graph
    LogWriter(Tabs + yEdMode + Tab + '1');
    LogWriter(Tabs + yEdLabel +Tab + '""');
    LogWriter(Tabs + yEdDirected + Tab + '1');
    // конец шапки

    if assigned(ScanResult) then
    begin
      for i:=0 to ScanResult.UnitInfoArray.Size-1 do
       ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;

    if Options.GraphBulding.FullG.IncludeInterfaceUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].InterfaceUses.Size>0 then
     begin
     // изменить
     NodeGML(Options,ScanResult.UnitInfoArray.Mutable[i]^,i,LogWriter);
       if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         NodeGML(Options,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].InterfaceUses[j]]^,ScanResult.UnitInfoArray[i].InterfaceUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.InterfaceUsesEdgeType=ETDotted then //изменить
                                                                    LogWriter(' edge [style=dotted]');
         LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].UnitName]));
         end;
       end;
     end;
    end;

    if Options.GraphBulding.FullG.IncludeImplementationUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
     if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
     begin
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
       begin
         NodeGML(Options,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].ImplementationUses[j]]^,ScanResult.UnitInfoArray[i].ImplementationUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.ImplementationUsesEdgeType=ETDotted then  //изменить
                                                                         LogWriter(' edge [style=dotted]');
           LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
         end;
       end;
     end;
    end;
    end;

    LogWriter(BracketRight);      //конец файла потом проверить


  end;
end;

procedure NodeGML(Options: TOptions; var Node: TUnitInfo; const index: integer;
  const LogWriter: TLogWriter; ForceInclude: boolean);
begin
   if node.NodeState=NSNotCheced then
  begin
    if ForceInclude or IncludeToGraph(Options,Node,index,LogWriter)then
    begin
        if Node.UnitType=UTProgram then   // здесь заполняется первый этап
          LogWriter(format(' %s [shape=box]',[Node.UnitName]));
        if (Node.UnitPath='')and(index<>0) then
          LogWriter(format(' %s [style=dashed]',[Node.UnitName]));
        node.NodeState:=NSCheced;
    end
    else
        node.NodeState:=NSFiltredOut;
  end;
end;

procedure GraphGML(Options: TOptions; var Node: TUnitInfo);
begin

end;



end.

