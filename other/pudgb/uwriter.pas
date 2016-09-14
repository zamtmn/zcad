unit uwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uoptions,uscanresult;

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);

implementation

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  i,j:integer;
  s:string;
begin
  if assigned(LogWriter) then
  begin
    {LogWriter(format('Total %d nodes:',[ScanResult.UnitInfoArray.Size-1]));
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     LogWriter(format('Node %s',[ScanResult.UnitInfoArray[i].UnitName]));

     if ScanResult.UnitInfoArray[i].InterfaceUses.Size>0 then
     begin
       s:='';
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-2 do
         s:=s+ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].UnitName+',';
         s:=s+ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[ScanResult.UnitInfoArray[i].InterfaceUses.Size-1]].UnitName+';';
       LogWriter(format(' Interface uses %s',[s]));
     end;

     if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
     begin
       s:='';
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-2 do
         s:=s+ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName+',';
         s:=s+ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[ScanResult.UnitInfoArray[i].ImplementationUses.Size-1]].UnitName+';';
       LogWriter(format(' Implementation uses %s',[s]));
     end;
    end;}

    //LogWriter('CUT HERE 8x----------------------');
    LogWriter('DiGraph Classes {');
    if assigned(ScanResult) then
    begin
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].InterfaceUses.Size>0 then
     begin
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].UnitName]));
     end;
    end;

    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
     begin
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
       LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
     end;
    end;
    end;

    LogWriter('}');
    //LogWriter('CUT HERE 8x----------------------');

  end;
end;

end.

