unit VTLogger;

{$mode objfpc}{$H+}

interface

uses
  LCLLogger, MultiLog;

const
  lcAll = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
  lcDebug = 0;
  lcError = 1;
  lcInfo = 2;
  lcWarning = 3;
  lcEvents = 4;
  //reserved
  lcUser = 8;

  lcVTEvents = lcUser + 1;
  lcPaint = lcUser + 2;
  lcPaintHeader = lcUser + 3;
  lcDummyFunctions = lcUser + 4;
  lcMessages = lcUser + 5;
  lcPaintSelection = lcUser + 6;
  lcSetCursor = lcUser + 7;//it generates a lot of messages. so it will be debugged alone
  lcPaintBitmap = lcUser + 8;
  lcScroll = lcUser + 8;
  lcPaintDetails = lcUser + 9;
  lcCheck = lcUser + 10;
  lcEditLink = lcUser + 11;
  lcEraseBkgnd = lcUser + 12;
  lcColumnPosition = lcUser + 13;
  lcTimer = lcUser + 14;
  lcDrag = lcUser + 15;
  lcOle = lcUser + 16;
  lcPanning = lcUser + 17;
  lcHeaderOffset = lcUser + 18;
  lcSelection = lcUser + 19;
  lcAlphaBlend = lcUser + 20;
  lcHint = lcUser + 21;
  lcMouseEvent = lcUser + 22;

  lcVT = [lcEvents..lcMouseEvent];

var
  Logger: TLCLLogger;


  function GetSelectedNodes(Sender: TLogger; Data: Pointer; var DoSend: Boolean): String;

implementation

uses
  VirtualTrees, sysutils;

type
  TNodeData = record
    Title: String;
  end;
  PNodeData = ^TNodeData;

  function GetSelectedNodes(Sender: TLogger; Data: Pointer; var DoSend: Boolean): String;
  var
    i: Integer;
    TempNode: PVirtualNode;
  begin
    with TBaseVirtualTree(Data) do
    begin
      Result:='SelectedCount: '+IntToStr(SelectedCount)+LineEnding;
      TempNode:=GetFirstSelected;
      if TempNode = nil then exit;
      Result:=Result+PNodeData(GetNodeData(TempNode))^.Title+LineEnding;
      for i:= 1 to SelectedCount -1 do
      begin
        TempNode:=GetNextSelected(TempNode);
        Result:=Result+PNodeData(GetNodeData(TempNode))^.Title+LineEnding;
      end;
    end;
  end;


initialization
  Logger:=TLCLLogger.Create;
finalization
  Logger.Free;
end.

