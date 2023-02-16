unit uzcfnavigatordevicescxmenu;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  uzmenusmanager,
  laz.VirtualTrees,uzmacros,TransferMacros,MacroDefIntf,Forms,ActnList,LCLVersion;

type
  PTNavigatorDevicesContext=^TNavigatorDevicesContext;
  TNavigatorDevicesContext=record
    tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
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


function CreateNavigatorDevicesContext(const tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};const pnode:PVirtualNode):TNavigatorDevicesContext;
procedure InitializeNavigatorDevicesCXMenu(mainform:TForm;actlist:TActionList);
procedure FinalizeNavigatorDevicesCXMenu;
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

function CreateNavigatorDevicesContext(const tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};const pnode:PVirtualNode):TNavigatorDevicesContext;
begin
  result.tree:=tree;
  result.pnode:=pnode;
end;

procedure InitializeNavigatorDevicesCXMenu(mainform:TForm;actlist:TActionList);
begin
  if not assigned(NavigatorDevicesMenuManager) then begin
    NavigatorDevicesMenuManager:=TNavigatorDevicesMenuManager.Create;
    NavigatorDevicesMenuManager.setup(mainform,actlist);
  end;
  if not assigned(NavigatorDevicesMacros) then
    NavigatorDevicesMacros:=TNavigatorDevicesMacros.Create;
end;

procedure FinalizeNavigatorDevicesCXMenu;
begin
  if assigned(NavigatorDevicesMenuManager) then
    FreeAndNil(NavigatorDevicesMenuManager);
  if assigned(NavigatorDevicesMacros) then
    FreeAndNil(NavigatorDevicesMacros);
  if assigned(NavigatorDevicesMacroList) then
    FreeAndNil(NavigatorDevicesMacroList);
end;

finalization
  FinalizeNavigatorDevicesCXMenu;
end.

