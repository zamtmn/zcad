unit uzmenusdefaults;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,uzmacros,
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
    CurrentContext:T;
    Cashe:TContextStateRegister;
    procedure SetCurrentContext(ctx:T);
    procedure ReSetCurrentContext(ctx:T);
    procedure ReleaseCashe;
  end;

  TGeneralContextChecker=specialize TCMContextChecker<TObject>;

  TMenuCreateFunc=procedure (fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc) of object;
  TMenuCreateFuncRegister=specialize TDictionary <string,TMenuCreateFunc>;
  TMenuDefaults=class
    class var MenuCreateFuncRegister:TMenuCreateFuncRegister;
    class procedure CreateDefaultMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure CreateDefaultMenuSeparator(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultSetMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure DefaultMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);

    class procedure TryRunMenuCreateFunc(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
    class procedure RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
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

class procedure TMenuDefaults.CreateDefaultMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
      if ppopupmenu=nil then begin
        ppopupmenu:=TMenuItem(MenusManager.GetMenu_tmp(TBSubNode.NodeName,nil));
        //ppopupmenu:=tmenuitem(application.FindComponent(MenuNameModifier+uppercase(TBSubNode.NodeName)));
      end;
      if ppopupmenu<>nil then
                                begin
                                     createdmenu.items.Add(ppopupmenu);
                                end;
                            {else
                                ZCMsgCallBackInterface.TextMessage(format(rsMenuNotFounf,[ts]),TMWOShowError);}

      TBSubNode:=TBSubNode.NextSibling;
    end;
end;

class procedure TMenuDefaults.DefaultSetMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
begin
  fmf.Menu:=TMainMenu(TMenuItem(MenusManager.GetMenu_tmp(getAttrValue(aNode,'Name',''),nil)))//;{application.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name','')))});
end;


class procedure TMenuDefaults.CreateDefaultMenuSeparator(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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

class procedure TMenuDefaults.TryRunMenuCreateFunc(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  mcf:TMenuCreateFunc;
  msg:string;
begin
if assigned(MenuCreateFuncRegister) then
  if MenuCreateFuncRegister.TryGetValue(uppercase(aName),mcf)then
    mcf(fmf,aName,aNode,actlist,RootMenuItem,mpf)
  else begin
    msg:=format('"%s" not found in MenuCreateFuncRegister',[aName]);
    Application.MessageBox(@msg[1],'Error');
  end;
end;

class procedure TMenuDefaults.RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
begin
  if not assigned(TMenuDefaults.MenuCreateFuncRegister) then
    TMenuDefaults.MenuCreateFuncRegister:=TMenuCreateFuncRegister.create;
  TMenuDefaults.MenuCreateFuncRegister.add(uppercase(aNodeName),MenuCreateFunc);
end;

class procedure TMenuDefaults.UnRegisterMenuCreateFunc(aNodeName:string);
begin
  if assigned(TMenuDefaults.MenuCreateFuncRegister) then
    TMenuDefaults.MenuCreateFuncRegister.Remove(uppercase(aNodeName));
end;

class procedure TMenuDefaults.DefaultMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
        TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem,mpf);
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
