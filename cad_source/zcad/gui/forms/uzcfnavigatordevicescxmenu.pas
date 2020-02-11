unit uzcfnavigatordevicescxmenu;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  uzmenusmanager,laz.VirtualTrees,uzmacros,TransferMacros,MacroDefIntf;

type
  PTNavigatorDevicesContext=^TNavigatorDevicesContext;
  TNavigatorDevicesContext=record
    tree:TVirtualStringTree;
    pnode:PVirtualNode;
  end;

  TNavigatorDevicesMenuManager=specialize TGMenusManager<TNavigatorDevicesContext>;
  TNavigatorDevicesMacros=class(specialize TZMacros<TNavigatorDevicesContext>)
    function SubstituteMacrosWithCurrentContext(var s: string): boolean;override;
    procedure AddMacro(NewMacro:TTransferMacro);override;
  end;

var
  NavigatorDevicesMenuManager:TNavigatorDevicesMenuManager=nil;
  NavigatorDevicesMacros:TNavigatorDevicesMacros=nil;
  NavigatorDevicesMacroList:TTransferMacroList = nil;


function CreateNavigatorDevicesContext(const tree:TVirtualStringTree;const pnode:PVirtualNode):TNavigatorDevicesContext;
implementation
function TNavigatorDevicesMacros.SubstituteMacrosWithCurrentContext(var s: string): boolean;
begin
  setMarkUnhandled(false);
  Result:=inherited SubstituteMacros(s);
  setMarkUnhandled(true);
  {Result:=Result or }NavigatorDevicesMacroList.SubstituteStr(s,PtrInt(@CurrentContext));
end;

procedure TNavigatorDevicesMacros.AddMacro(NewMacro:TTransferMacro);
begin
  if not assigned(NavigatorDevicesMacroList) then
    NavigatorDevicesMacroList:=TTransferMacroList.Create;
  NavigatorDevicesMacroList.Add(NewMacro);
end;

function CreateNavigatorDevicesContext(const tree:TVirtualStringTree;const pnode:PVirtualNode):TNavigatorDevicesContext;
begin
  result.tree:=tree;
  result.pnode:=pnode;
end;

finalization
if assigned(NavigatorDevicesMenuManager) then
  FreeAndNil(NavigatorDevicesMenuManager);
if assigned(NavigatorDevicesMacros) then
  FreeAndNil(NavigatorDevicesMacros);
if assigned(NavigatorDevicesMacroList) then
  FreeAndNil(NavigatorDevicesMacroList);
end.

