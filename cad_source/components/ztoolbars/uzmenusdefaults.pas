unit uzmenusdefaults;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections;

const
     MenuNameModifier='MENU_';

type
  TMenuCreateFunc=procedure (fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem) of object;
  TMenuCreateFuncRegister=specialize TDictionary <string,TMenuCreateFunc>;
  TMenuDefaults=class
    class var MenuCreateFuncRegister:TMenuCreateFuncRegister;
    class procedure CreateDefaultMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure CreateDefaultMenuSeparator(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure DefaultSetMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure DefaultMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);

    class procedure TryRunMenuCreateFunc(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    class procedure RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
    class procedure UnRegisterMenuCreateFunc(aNodeName:string);
  end;
implementation

class procedure TMenuDefaults.CreateDefaultMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

class procedure TMenuDefaults.DefaultSetMenu(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  fmf.Menu:=TMainMenu(application.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''))));
end;


class procedure TMenuDefaults.CreateDefaultMenuSeparator(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

class procedure TMenuDefaults.TryRunMenuCreateFunc(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  mcf:TMenuCreateFunc;
  msg:string;
begin
if assigned(MenuCreateFuncRegister) then
  if MenuCreateFuncRegister.TryGetValue(uppercase(aName),mcf)then
    mcf(fmf,aName,aNode,actlist,RootMenuItem)
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

class procedure TMenuDefaults.DefaultMainMenuItemReader(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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
        TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,actlist,CreatedMenuItem);
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
finalization
  if assigned(TMenuDefaults.MenuCreateFuncRegister) then
   FreeAndNil(TMenuDefaults.MenuCreateFuncRegister);

end.
