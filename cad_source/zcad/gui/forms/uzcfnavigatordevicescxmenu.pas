unit uzcfnavigatordevicescxmenu;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  uzmenusmanager,laz.VirtualTrees;

type
  TNavigatorDevicesContext=record
    tree:TVirtualStringTree;
    pnode:PVirtualNode;
  end;

  TNavigatorDevicesMenuManager=specialize TGMenusManager<TNavigatorDevicesContext>;

var
  NavigatorDevicesMenuManager:TNavigatorDevicesMenuManager=nil;


function CreateNavigatorDevicesContext(const tree:TVirtualStringTree;const pnode:PVirtualNode):TNavigatorDevicesContext;
implementation
function CreateNavigatorDevicesContext(const tree:TVirtualStringTree;const pnode:PVirtualNode):TNavigatorDevicesContext;
begin
  result.tree:=tree;
  result.pnode:=pnode;
end;

finalization
if assigned(NavigatorDevicesMenuManager) then
  FreeAndNil(NavigatorDevicesMenuManager);
end.

