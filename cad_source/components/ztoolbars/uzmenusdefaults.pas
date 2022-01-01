unit uzmenusdefaults;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,uzmacros,uzxmlnodesutils,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections;

const
     MenuNameModifier='MENU_';

type
  TMenuType=(TMT_MainMenu,TMT_PopupMenu);
  TMenuContextNameType=string;
  TContextStateType=boolean;
  TCMenuContextNameManipulator=class
    class function Standartize(id:TMenuContextNameType):TMenuContextNameType;
    class function DefaultContexCheckState:TContextStateType;
  end;

  generic TCMContextChecker<T>=class (specialize TGCContextChecker<T,TMenuContextNameType,TContextStateType,TCMenuContextNameManipulator>)
    CurrentContext:T;
    Cashe:TContextStateRegister;
    procedure SetCurrentContext(ctx:T);
    procedure ReSetCurrentContext(ctx:T);
    procedure ReleaseCashe;
  end;

  TGeneralContextChecker=specialize TCMContextChecker<TObject>;

  TMenuCreateFunc=procedure (MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc) of object;
  TMenuCreateFuncRegister=specialize TDictionary <string,TMenuCreateFunc>;
  TMenuDefaults=class
    class var MenuCreateFuncRegister:TMenuCreateFuncRegister;
    class procedure DefaultCreateMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultInsertMenuContent(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultInsertMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultCreateMenuSeparator(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultCreateMenuAction(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultSetMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultMainMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);

    class procedure TryRunMenuCreateFunc(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class function RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc):boolean;
    class procedure UnRegisterMenuCreateFunc(aNodeName:string);
  end;
procedure RegisterGeneralContextCheckFunc(ContextId:TGeneralContextChecker.TContextIdType;ContextCheckFunc:TGeneralContextChecker.TContextCheckFunc);
var
  GeneralContextChecker:TGeneralContextChecker;
implementation
uses uzmenusmanager;
procedure RegisterGeneralContextCheckFunc(ContextId:TGeneralContextChecker.TContextIdType;ContextCheckFunc:TGeneralContextChecker.TContextCheckFunc);
begin
  if GeneralContextChecker=nil then GeneralContextChecker:=TGeneralContextChecker.Create;
  GeneralContextChecker.RegisterContextCheckFunc(ContextId,ContextCheckFunc);
end;

generic procedure TCMContextChecker<T>.SetCurrentContext(ctx:T);
begin
  CurrentContext:=ctx;
end;
generic procedure TCMContextChecker<T>.ReSetCurrentContext(ctx:T);
begin
  CurrentContext:=default(T);
end;
generic procedure TCMContextChecker<T>.ReleaseCashe;
begin
  if assigned(Cashe) then
    FreeAndNil(Cashe);
end;

class function TCMenuContextNameManipulator.Standartize(id:TMenuContextNameType):TMenuContextNameType;
begin
  result:=uppercase(id);
end;
class function TCMenuContextNameManipulator.DefaultContexCheckState:TContextStateType;
begin
  result:=false;
end;

function FindMenuContent(aName:string):TDomNode;
var
  TBNode,TBSubNode:TDomNode;
  menuname:string;
begin
  if not assigned(MenuConfig) then
    exit(nil);
  TBNode:=MenuConfig.FindNode('MenusContent',false);
  if assigned(TBNode) then begin
    TBSubNode:=TBNode.FirstChild;
    menuname:=uppercase(getAttrValue(TBSubNode,'Name',''));
  end
  else
    TBSubNode:=nil;
  aName:=uppercase(aName);
  if assigned(TBSubNode) then
    while (assigned(TBSubNode))and(menuname<>aName)do
    begin
      TBSubNode:=TBSubNode.NextSibling;
      if assigned(TBSubNode) then
        menuname:=uppercase(getAttrValue(TBSubNode,'Name',''));
    end;
  result:=TBSubNode;
end;

class procedure TMenuDefaults.DefaultInsertMenuContent(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  MenuName:string;
  MenuNode:TDomNode;
begin
  MenuName:=getAttrValue(aNode,'Name','');
  MenuNode:=FindMenuContent(MenuName);
  TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,'Menu',MenuNode,actlist,RootMenuItem,MPF);
end;

class procedure TMenuDefaults.DefaultInsertMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  MenuName:string;
  MenuNode:TDomNode;
begin
  MenuName:=getAttrValue(aNode,'Name','');
  MenuNode:=FindMenuContent(MenuName);
  TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,'SubMenu',MenuNode,actlist,RootMenuItem,MPF);
end;


class procedure TMenuDefaults.DefaultCreateMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  MenuItem:TMenuItem;
  //ts:String;
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
      MenuItem:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(TBSubNode.NodeName)));
      if MenuItem=nil then begin
        MenuItem:=MenusManager.GetSubMenu(MT,TBSubNode.NodeName,nil);
        //MenuItem:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(TBSubNode.NodeName)));
      end;
      if MenuItem<>nil then
                                begin
                                     createdmenu.items.Add(MenuItem);
                                end;
                            {else
                                ZCMsgCallBackInterface.TextMessage(format(rsMenuNotFounf,[ts]),TMWOShowError);}

      TBSubNode:=TBSubNode.NextSibling;
    end;
end;

class procedure TMenuDefaults.DefaultSetMenu(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  fmf.Menu:=TMainMenu(MenusManager.GetMainMenu(getAttrValue(aNode,'Name',''),nil))//;{application.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name','')))});
end;


class procedure TMenuDefaults.DefaultCreateMenuSeparator(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
class procedure TMenuDefaults.DefaultCreateMenuAction(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  CreatedMenuItem:TMenuItem;
  _action:TContainedAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');

  _action:=actlist.ActionByName(ActionName);
  if _action=nil then begin
    _action:=TAction.Create(fmf);
    _action.ActionList:=actlist;
    _action.Name:=ActionName;
  end;

  CreatedMenuItem:=TMenuItem.Create(RootMenuItem);
  CreatedMenuItem.Action:=_action;
  if RootMenuItem is TMenuItem then
    RootMenuItem.Add(CreatedMenuItem)
  else
    TPopUpMenu(RootMenuItem).Items.Add(CreatedMenuItem);
end;


class procedure TMenuDefaults.TryRunMenuCreateFunc(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  mcf:TMenuCreateFunc;
  msg:string;
begin
if assigned(MenuCreateFuncRegister) then
  if MenuCreateFuncRegister.TryGetValue(uppercase(aName),mcf)then
    mcf(MT,fmf,aName,aNode,actlist,RootMenuItem,mpf)
  else begin
    msg:=format('"%s" not found in MenuCreateFuncRegister',[aName]);
    Application.MessageBox(@msg[1],'Error');
  end;
end;

class function TMenuDefaults.RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc):boolean;
var
  nn:string;
begin
  if not assigned(TMenuDefaults.MenuCreateFuncRegister) then
    TMenuDefaults.MenuCreateFuncRegister:=TMenuCreateFuncRegister.create;
  nn:=uppercase(aNodeName);
  result:=not TMenuDefaults.MenuCreateFuncRegister.ContainsKey(nn);
  if result then
    TMenuDefaults.MenuCreateFuncRegister.add(nn,MenuCreateFunc);
end;

class procedure TMenuDefaults.UnRegisterMenuCreateFunc(aNodeName:string);
begin
  if assigned(TMenuDefaults.MenuCreateFuncRegister) then
    TMenuDefaults.MenuCreateFuncRegister.Remove(uppercase(aNodeName));
end;

class procedure TMenuDefaults.DefaultMainMenuItemReader(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
 var
  CreatedMenuItem:TMenuItem;
  line:string;
  TBSubNode:TDomNode;
  //mcf:TMenuCreateFunc;
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
        TryRunMenuCreateFunc(MT,fmf,TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem,mpf);
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

initialization
  TMenuDefaults.MenuCreateFuncRegister:=nil;
  GeneralContextChecker:=nil;
finalization
  if assigned(TMenuDefaults.MenuCreateFuncRegister) then
   FreeAndNil(TMenuDefaults.MenuCreateFuncRegister);
  if assigned(GeneralContextChecker) then
   FreeAndNil(GeneralContextChecker);
end.
