unit uzmenusmanager;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,uzmenusdefaults,uzmacros,uzxmlnodesutils,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections,Classes;

const
  MenuNameModifier='MENU_';
  MenuNodeName='Menu';
  SubMenuNodeName='SubMenu';
  UCMenuNodeName='MENU';
  UCSubMenuNodeName='SUBMENU';
var
  MenuConfig:TXMLConfig=nil;

type
  generic TGMenusManager<T>=class(specialize TCMContextChecker<T>)
  type
    TMenusMacros=specialize TZMacros<T>;
  private
    factionlist:TActionList;
    fmainform:TForm;
    function GetMenu_tmp(MT:TMenuType;aName: string;ctx:T;ForceReCreate:boolean=false;MMProcessor:TMenusMacros=nil):TMainMenu;

  public
    constructor Create;
    destructor Destroy;override;

    procedure setup(mainform:TForm;actlist:TActionList);
    procedure GetPart(out part:String;var path:String;const separator:String);
    function readspace(expr:String):String;
    procedure DoIfOneNode(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);virtual;
    procedure DoIfAllNode(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);virtual;

    procedure ConcatNodes(Child,NewChild: TDOMNode);
    function FindsubNodeWithAttrName(node: TDOMNode;attrname:DOMString): TDOMNode;
    function isMenu(Child: TDOMNode):boolean;

    procedure LoadMenus(filename:string;MMProcessor:TMenusMacros=nil);
    function GetMacroProcessFuncAddr(MMProcessor:TMenusMacros):TMacroProcessFunc;
    procedure CheckMainMenu(node:TDomNode;MMProcessor:TMenusMacros=nil);

    function GetMainMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMainMenu;
    function GetPopupMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TPopupMenu;
    function GetSubMenu(MT:TMenuType;aName:string;ctx:T;MMProcessor:TMenusMacros=nil):TMenuItem;
  end;
  TGeneralMenuManager=specialize TGMenusManager<TObject>;

var
  MenusManager:TGeneralMenuManager;

implementation

constructor TGMenusManager.Create;
begin
  setup(nil,nil);
end;
procedure TGMenusManager.setup(mainform:TForm;actlist:TActionList);
begin
  fmainform:=mainform;
  factionlist:=actlist;
end;
destructor TGMenusManager.Destroy;
begin
  inherited;
end;

function TGMenusManager.isMenu(Child: TDOMNode):boolean;
var
  s:DOMString;
begin
  if assigned(child) then begin
    s:=uppercase(child.NodeName);
    if (s=UCMenuNodeName)or(s=UCSubMenuNodeName)then
      result:=true
    else
      result:=false;
  end else
    result:=false;

end;

function TGMenusManager.FindsubNodeWithAttrName(node: TDOMNode;attrname:DOMString): TDOMNode;
var
  TBSubNode,TBSubNode2:TDomNode;
  s:DOMString;
begin
  if attrname='' then exit(nil);
  TBSubNode2:=node.FirstChild;
  while assigned(TBSubNode2)do
  begin
    s:=TBSubNode2.NodeName;
    if getAttrValue(TBSubNode2,'Name','')=attrname then
      exit(TBSubNode2);
    TBSubNode2:=TBSubNode2.NextSibling;
  end;
  exit(nil);
end;

procedure TGMenusManager.ConcatNodes(Child,NewChild: TDOMNode);
var
  TBSubNode,TBSubNode2:TDomNode;
  s:DOMString;
begin
  TBSubNode:=FindsubNodeWithAttrName(Child,getAttrValue(NewChild,'Name',''));
  if (assigned(TBSubNode))and(isMenu(TBSubNode))and(isMenu(NewChild)) then begin
    TBSubNode2:=NewChild.FirstChild;
    while assigned(TBSubNode2)do
    begin
      s:=TBSubNode2.NodeName;
      ConcatNodes(TBSubNode,TBSubNode2);
      TBSubNode2:=TBSubNode2.NextSibling;
    end;
  end else begin
    Child.AppendChild(NewChild.CloneNode(true,Child.OwnerDocument));
  end;
end;

procedure TGMenusManager.LoadMenus(filename:string;MMProcessor:TMenusMacros=nil);
var
  ActionsConfig:TXMLConfig;
  TBNode,TBSubNode:TDomNode;

  tempMenuConfig:TXMLConfig;
  tempTBContentNode,TBContentNode:TDomNode;
  s: TFileStream;
  ss:string;
begin

  if not assigned(MenuConfig) then begin
    MenuConfig:=TXMLConfig.Create(nil);
    MenuConfig.Filename:=filename;
    tempTBContentNode:=MenuConfig.FindNode('MenusContent',false);
    CheckMainMenu(tempTBContentNode);
  end else begin
    tempMenuConfig:=TXMLConfig.Create(nil);
    tempMenuConfig.Filename:=filename;

    tempTBContentNode:=tempMenuConfig.FindNode('MenusContent',false);
    ss:=tempTBContentNode.NodeName;
    CheckMainMenu(tempTBContentNode);
    TBContentNode:=MenuConfig.FindNode('MenusContent',false);
    ss:=TBContentNode.NodeName;

    if assigned(tempTBContentNode) and assigned(TBContentNode)then begin
      TBSubNode:=tempTBContentNode.FirstChild;
      ss:=TBSubNode.NodeName;
      while assigned(TBSubNode)do
      begin
        ConcatNodes(TBContentNode,TBSubNode);
        TBSubNode:=TBSubNode.NextSibling;
      end;
    end;
    tempMenuConfig.Free;

    {s:=TFileStream.Create('d:\test.xml',fmCreate);
    MenuConfig.WriteToStream(S);
    s.Free;}
  end;
end;

procedure TGMenusManager.GetPart(out part:String;var path:String;const separator:String);
var
   i:Integer;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
end;

function TGMenusManager.readspace(expr:String):String;
var
  i:Integer;
begin
  if expr='' then exit('');
  i := 1;
  while not (expr[i] in ['@','{','}','a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''','~']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
  result := copy(expr, i, length(expr) - i + 1);
end;

procedure TGMenusManager.DoIfOneNode(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  TBSubNode:TDomNode;
  conditions,condition:string;
  passed:boolean;
begin
  conditions:=getAttrValue(aNode,'Сonditions','');
  passed:=false;
  repeat
    GetPart(condition,conditions,',');
    condition:=readspace(condition);
    if condition<>''  then begin
      if condition[1]<>'~'  then begin
        if GeneralContextChecker.ContainContext(condition) then
          passed:=passed or GeneralContextChecker.CashedContextCheck(GeneralContextChecker.Cashe,condition,GeneralContextChecker.CurrentContext)
        else
          passed:=passed or CashedContextCheck(Cashe,condition,CurrentContext)
      end else
        if length(condition)>1  then begin
          condition:=copy(condition,2,length(condition)-1);
          if GeneralContextChecker.ContainContext(condition) then
            passed:=passed or (not GeneralContextChecker.CashedContextCheck(GeneralContextChecker.Cashe,condition,GeneralContextChecker.CurrentContext))
          else
            passed:=passed or (not CashedContextCheck(Cashe,condition,CurrentContext));
        end;
    end;
  until (condition='')or(passed);
  if passed then begin
    TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do begin
        TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,TBSubNode.NodeName,TBSubNode,factionlist,RootMenuItem,MPF);
        TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

procedure TGMenusManager.DoIfAllNode(MT:TMenuType;fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
var
  TBSubNode:TDomNode;
  conditions,condition:string;
  passed:boolean;
begin
  conditions:=getAttrValue(aNode,'Сonditions','');
  passed:=true;
  repeat
    GetPart(condition,conditions,',');
    condition:=readspace(condition);
    if condition<>''  then begin
      if condition[1]<>'~' then begin
        if GeneralContextChecker.ContainContext(condition) then
          passed:=passed and GeneralContextChecker.CashedContextCheck(GeneralContextChecker.Cashe,condition,GeneralContextChecker.CurrentContext)
        else
          passed:=passed and CashedContextCheck(Cashe,condition,CurrentContext)
      end
      else
        if length(condition)>1  then begin
          condition:=copy(condition,2,length(condition)-1);
          if GeneralContextChecker.ContainContext(condition) then
            passed:=passed and (not GeneralContextChecker.CashedContextCheck(GeneralContextChecker.Cashe,condition,GeneralContextChecker.CurrentContext))
          else
            passed:=passed and (not CashedContextCheck(Cashe,condition,CurrentContext));
        end;
    end;
  until (condition='')or(not passed);
  if passed then begin
    TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do begin
        TMenuDefaults.TryRunMenuCreateFunc(MT,fmf,TBSubNode.NodeName,TBSubNode,factionlist,RootMenuItem,MPF);
        TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

function TGMenusManager.GetMacroProcessFuncAddr(MMProcessor:TMenusMacros):TMacroProcessFunc;
begin
  if assigned(MMProcessor)then
    result:=@MMProcessor.SubstituteMacrosWithCurrentContext
  else
    result:=nil;
end;
function TGMenusManager.GetMainMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMainMenu;
begin
  result:=GetMenu_tmp(TMenuType.TMT_MainMenu,aName,ctx,false,MMProcessor);
end;
function TGMenusManager.GetPopupMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TPopupMenu;
begin
  result:=TPopupMenu(GetMenu_tmp(TMenuType.TMT_PopupMenu,aName,ctx,true,MMProcessor));
end;
function TGMenusManager.GetSubMenu(MT:TMenuType;aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMenuItem;
begin
  result:=TMenuItem(GetMenu_tmp(MT,aName,ctx,true,MMProcessor));
end;
function TGMenusManager.GetMenu_tmp(MT:TMenuType;aName: string;ctx:T;ForceReCreate:boolean=false;MMProcessor:TMenusMacros=nil):TMainMenu;
var
  TBNode,TBSubNode:TDomNode;
  menuname:string;
  MPF:TMacroProcessFunc;
  IFONERegistred,IFALLRegistred:boolean;
begin
  menuname:='';
  result:=TMainMenu(application.FindComponent(MenuNameModifier+aName));
  if ForceReCreate then
    if result<>nil then
      FreeAndNil(result);
  result:={TMainMenu(application.FindComponent(MenuNameModifier+aName))}nil;
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
    if assigned(TBSubNode) then begin
      MPF:=GetMacroProcessFuncAddr(MMProcessor);
      if assigned(MMProcessor)then
        MMProcessor.SetCurrentContext(ctx);
      SetCurrentContext(ctx);
      if assigned(GeneralContextChecker) then
        GeneralContextChecker.SetCurrentContext(Application);
      IFONERegistred:=TMenuDefaults.RegisterMenuCreateFunc('IFONE',@DoIfOneNode);
      IFALLRegistred:=TMenuDefaults.RegisterMenuCreateFunc('IFALL',@DoIfAllNode);
      TMenuDefaults.TryRunMenuCreateFunc(MT,fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,MPF);
      if IFONERegistred then
        TMenuDefaults.UnRegisterMenuCreateFunc('IFONE');
      if IFALLRegistred then
        TMenuDefaults.UnRegisterMenuCreateFunc('IFALL');
      if assigned(GeneralContextChecker) then
        GeneralContextChecker.ReleaseCashe;
      if assigned(GeneralContextChecker) then
        GeneralContextChecker.ReSetCurrentContext(Application);
      ReleaseCashe;
      if assigned(MMProcessor)then
        MMProcessor.ReSetCurrentContext(ctx);
      ReSetCurrentContext(ctx);
      result:=TMainMenu(application.FindComponent(MenuNameModifier+aName));
    end;
  end;
end;

procedure TGMenusManager.CheckMainMenu(node:TDomNode;MMProcessor:TMenusMacros=nil);
var
  TBSubNode:TDomNode;
  menuname:string;
  MPF:TMacroProcessFunc;
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
          TMenuDefaults.TryRunMenuCreateFunc(TMenuType.TMT_MainMenu,fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,mpf);
          //exit;
        end;
        if TBSubNode.nodeName='SetMainMenu' then begin
          TMenuDefaults.TryRunMenuCreateFunc(TMenuType.TMT_MainMenu,fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,mpf);
          //exit;
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
  MenuConfig:=nil;
  MenusManager:=TGeneralMenuManager.create;

finalization
  if assigned(MenuConfig) then
    FreeAndNil(MenuConfig);
  if assigned(MenusManager) then
    FreeAndNil(MenusManager);
end.
