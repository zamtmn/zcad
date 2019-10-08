unit uzmenusmanager;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,uzmenusdefaults,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections;

const
     MenuNameModifier='MENU_';

type
  TMenuContextNameType=string;
  TContextStateType=boolean;
  TCMenuContextNameManipulator=class
    class function Standartize(id:TMenuContextNameType):TMenuContextNameType;
    class function DefaultContexCheckState:TContextStateType;
  end;
  generic TCMContextChecker<T>=class (specialize TGCContextChecker<T,TMenuContextNameType,TContextStateType,TCMenuContextNameManipulator>)
  end;

  TMenusManager=class
  private
    factionlist:TActionList;
    fmainform:TForm;
    MenuConfig:TXMLConfig;

  public
    constructor Create(mainform:TForm;actlist:TActionList);
    destructor Destroy;override;

    procedure LoadMenus(filename:string);
    function GetMenu_tmp(aName: string):TPopupMenu;
    procedure CheckMainMenu(node:TDomNode);
  end;

var
  MenusManager:TMenusManager;

  {TTestContextChecker=specialize TCMContextChecker<integer>;
var
  CC:TTestContextChecker;
  Cashe:TTestContextChecker.TContextStateRegister;}

implementation

class function TCMenuContextNameManipulator.Standartize(id:TMenuContextNameType):TMenuContextNameType;
begin
  result:=uppercase(id);
end;
class function TCMenuContextNameManipulator.DefaultContexCheckState:TContextStateType;
begin
  result:=false;
end;


constructor TMenusManager.Create(mainform:TForm;actlist:TActionList);
begin
  fmainform:=mainform;
  factionlist:=actlist;

  MenuConfig:=nil;
end;
destructor TMenusManager.Destroy;
begin
  if assigned(MenuConfig) then
    MenuConfig.Free;
end;
procedure TMenusManager.LoadMenus(filename:string);
var
  ActionsConfig:TXMLConfig;
  TBNode,TBSubNode:TDomNode;

  tempMenuConfig:TXMLConfig;
  tempTBContentNode,TBContentNode:TDomNode;
begin

  if not assigned(MenuConfig) then begin
    MenuConfig:=TXMLConfig.Create(nil);
    MenuConfig.Filename:=filename;
  end else begin
    tempMenuConfig:=TXMLConfig.Create(nil);
    tempMenuConfig.Filename:=filename;

    tempTBContentNode:=tempMenuConfig.FindNode('MenusContent',false);
    CheckMainMenu(tempTBContentNode);
    TBContentNode:=MenuConfig.FindNode('MenusContent',false);

    if assigned(tempTBContentNode) and assigned(TBContentNode)then begin
      TBSubNode:=tempTBContentNode.FirstChild;
      while assigned(TBSubNode)do
      begin
        TBContentNode.AppendChild(TBSubNode.CloneNode(true,TBContentNode.OwnerDocument));

        TBSubNode:=TBSubNode.NextSibling;
      end;
    end;

    tempMenuConfig.Free;
  end;

  {ActionsConfig:=TXMLConfig.Create(nil);
  ActionsConfig.Filename:=filename;

  TBNode:=ActionsConfig.FindNode('MenusContent',false);
  if assigned(TBNode) then
    TBSubNode:=TBNode.FirstChild
  else
    TBSubNode:=nil;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil);
      TBSubNode:=TBSubNode.NextSibling;
    end;

  ActionsConfig.Free;}
end;



function TMenusManager.GetMenu_tmp(aName: string):TPopupMenu;
var
  TBNode,TBSubNode:TDomNode;
  menuname:string;
begin
  menuname:='';
  result:=TPopupMenu(application.FindComponent(MenuNameModifier+aName));
  if result=nil then begin
    TBNode:=MenuConfig.FindNode('MenusContent',false);
    if assigned(TBNode) then begin
      TBSubNode:=TBNode.FirstChild;
      menuname:=getAttrValue(TBSubNode,'Name','');
    end
    else
      TBSubNode:=nil;
    if assigned(TBSubNode) then
      while (assigned(TBSubNode))and(menuname<>aName)do
      begin
        TBSubNode:=TBSubNode.NextSibling;
        if assigned(TBSubNode) then
          menuname:=getAttrValue(TBSubNode,'Name','');
      end;
    if assigned(TBSubNode) then
      TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil);
  end;
end;

procedure TMenusManager.CheckMainMenu(node:TDomNode);
var
  TBSubNode:TDomNode;
  menuname:string;
begin
    if assigned(node) then begin
      TBSubNode:=node.FirstChild;
      //menuname:=getAttrValue(TBSubNode,'Name','');
    end
    else
      TBSubNode:=nil;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        if TBSubNode.nodeName='CreateMenu' then begin
          TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil);
          exit;
        end;
        TBSubNode:=TBSubNode.NextSibling;
      end;
end;

{function testCheck(const Context:integer):boolean;
begin
  if Context=5 then
    result:=true
  else
    result:=false;
end;}

initialization
  (*CC:=TTestContextChecker.create;
  CC.RegisterContextCheckFunc('test',@testCheck);
  Cashe:={TContextStateRegister.create}nil;
  CC.CashedContextCheck(Cashe,'teSt',5);
  CC.CashedContextCheck(Cashe,'tEst',5);
  if assigned(Cashe) then
    Cashe.free;*)
finalization
if assigned(MenusManager) then
  MenusManager.Free;
end.
