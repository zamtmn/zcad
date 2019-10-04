unit uzmenusmanager;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections;

const
     MenuNameModifier='MENU_';

type
  TMenuCreateFunc=procedure (aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem) of object;
  TMenuCreateFuncRegister=specialize TDictionary <string,TMenuCreateFunc>;

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
    MenuCreateFuncRegister:TMenuCreateFuncRegister;

  public
    constructor Create(mainform:TForm;actlist:TActionList);
    destructor Destroy;override;

    procedure LoadMenus(filename:string);
    procedure TryRunMenuCreateFunc(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
    procedure DefaultMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenuAction(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure DefaultSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenuSeparator(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    function GetMenu_tmp(aName: string):TPopupMenu;

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

  MenuCreateFuncRegister:=nil;
end;
destructor TMenusManager.Destroy;
begin
  if assigned(MenuCreateFuncRegister) then
    MenuCreateFuncRegister.Free;
end;
procedure TMenusManager.LoadMenus(filename:string);
var
  ActionsConfig:TXMLConfig;
  TBNode,TBSubNode:TDomNode;
begin
  ActionsConfig:=TXMLConfig.Create(nil);
  ActionsConfig.Filename:=filename;

  TBNode:=ActionsConfig.FindNode('MenusContent',false);
  if assigned(TBNode) then
    TBSubNode:=TBNode.FirstChild
  else
    TBSubNode:=nil;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      TryRunMenuCreateFunc(TBSubNode.NodeName,TBSubNode,factionlist,nil);
      TBSubNode:=TBSubNode.NextSibling;
    end;

  ActionsConfig.Free;
end;

procedure TMenusManager.TryRunMenuCreateFunc(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  mcf:TMenuCreateFunc;
  msg:string;
begin
if assigned(MenuCreateFuncRegister) then
  if MenuCreateFuncRegister.TryGetValue(uppercase(aName),mcf)then
    mcf(aName,aNode,actlist,RootMenuItem)
  else begin
    msg:=format('"%s" not found in MenuCreateFuncRegister',[aName]);
    Application.MessageBox(@msg[1],'Error');
  end;
end;

procedure TMenusManager.RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
begin
  if not assigned(MenuCreateFuncRegister) then
    MenuCreateFuncRegister:=TMenuCreateFuncRegister.create;
  MenuCreateFuncRegister.add(uppercase(aNodeName),MenuCreateFunc);
end;

procedure TMenusManager.DefaultMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
 var
  CreatedMenuItem:TMenuItem;
  line:string;
  TBSubNode:TDomNode;
  mcf:TMenuCreateFunc;
begin
    CreatedMenuItem:=TMenuItem.Create(application);
    line:=getAttrValue(aNode,'Name','');
    if RootMenuItem=nil then
      CreatedMenuItem.Name:=MenuNameModifier+line;
    line:=getAttrValue(aNode,'Caption',line);
    CreatedMenuItem.Caption:=line;
    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        TryRunMenuCreateFunc(TBSubNode.NodeName,TBSubNode,factionlist,CreatedMenuItem);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    if assigned(RootMenuItem) then
    begin
      if RootMenuItem is TMenuItem then
        RootMenuItem.Add(CreatedMenuItem)
      else
        TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
    end;
end;

procedure TMenusManager.CreateDefaultMenuAction(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  CreatedMenuItem:TMenuItem;
  _action:TContainedAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');
  _action:=factionlist.ActionByName(ActionName);
  CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
  CreatedMenuItem.Action:=_action;
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
end;

procedure TMenusManager.CreateDefaultMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  ppopupmenu:TMenuItem;
  ts:String;
  createdmenu:TMenu;
  TBSubNode:TDomNode;
begin
  createdmenu:=TMainMenu.Create(application);
  createdmenu.Images:=actlist.Images;
  createdmenu.Name:=MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''));

  if assigned(aNode) then
    TBSubNode:=aNode.FirstChild;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      ppopupmenu:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(TBSubNode.NodeName)));

      if ppopupmenu<>nil then
                                begin
                                     createdmenu.items.Add(ppopupmenu);
                                end;
                            {else
                                ZCMsgCallBackInterface.TextMessage(format(rsMenuNotFounf,[ts]),TMWOShowError);}

      TBSubNode:=TBSubNode.NextSibling;
    end;
end;

procedure TMenusManager.DefaultSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  fmainform.Menu:=TMainMenu(application.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''))));
end;


procedure TMenusManager.CreateDefaultMenuSeparator(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  CreatedMenuItem:TMenuItem;
begin
  if RootMenuItem is TMenuItem then
    RootMenuItem.AddSeparator
  else
    begin
      CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
      CreatedMenuItem.Caption:='-';
      TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
    end;
end;

function TMenusManager.GetMenu_tmp(aName: string):TPopupMenu;
begin
  result:=TPopupMenu(application.FindComponent(MenuNameModifier+aName))
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
