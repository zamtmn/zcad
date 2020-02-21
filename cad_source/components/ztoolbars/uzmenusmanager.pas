unit uzmenusmanager;

{$mode objfpc}{$H+}

interface

uses
  ugcontextchecker,uztoolbarsmanager,uzmenusdefaults,uzmacros,
  ActnList,Laz2_XMLCfg,Laz2_DOM,Menus,Forms,
  sysutils,Generics.Collections;

const
  MenuNameModifier='MENU_';
var
  MenuConfig:TXMLConfig=nil;

type
  TMenuType=(TMT_MainMenu,TMT_PopupMenu);
  generic TGMenusManager<T>=class(specialize TCMContextChecker<T>)
  type
    TMenusMacros=specialize TZMacros<T>;
  private
    factionlist:TActionList;
    fmainform:TForm;
    function GetMenu_tmp(aName: string;ctx:T;ForceReCreate:boolean=false;MMProcessor:TMenusMacros=nil):TMenu;

  public
    constructor Create(mainform:TForm;actlist:TActionList);
    destructor Destroy;override;

    procedure GetPart(out part:String;var path:String;const separator:String);
    function readspace(expr:String):String;
    procedure DoIfOneNode(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);virtual;
    procedure DoIfAllNode(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);virtual;

    procedure LoadMenus(filename:string;MMProcessor:TMenusMacros=nil);
    function GetMacroProcessFuncAddr(MMProcessor:TMenusMacros):TMacroProcessFunc;
    procedure CheckMainMenu(node:TDomNode;MMProcessor:TMenusMacros=nil);

    function GetMainMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMenu;
    function GetPopupMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TPopupMenu;
    function GetSubMenu(aName:string;ctx:T;MMProcessor:TMenusMacros=nil):TMenuItem;
  end;
  TGeneralMenuManager=specialize TGMenusManager<TObject>;

var
  MenusManager:TGeneralMenuManager;

implementation

constructor TGMenusManager.Create(mainform:TForm;actlist:TActionList);
begin
  fmainform:=mainform;
  factionlist:=actlist;
end;
destructor TGMenusManager.Destroy;
begin
end;
procedure TGMenusManager.LoadMenus(filename:string;MMProcessor:TMenusMacros=nil);
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

procedure TGMenusManager.DoIfOneNode(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
        TMenuDefaults.TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,factionlist,RootMenuItem,MPF);
        TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

procedure TGMenusManager.DoIfAllNode(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
        TMenuDefaults.TryRunMenuCreateFunc(fmf,TBSubNode.NodeName,TBSubNode,factionlist,RootMenuItem,MPF);
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
function TGMenusManager.GetMainMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMenu;
begin
  result:=GetMenu_tmp(aName,ctx,false,MMProcessor);
end;
function TGMenusManager.GetPopupMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TPopupMenu;
begin
  result:=TPopupMenu(GetMenu_tmp(aName,ctx,true,MMProcessor));
end;
function TGMenusManager.GetSubMenu(aName: string;ctx:T;MMProcessor:TMenusMacros=nil):TMenuItem;
begin
  result:=TMenuItem(GetMenu_tmp(aName,ctx,true,MMProcessor));
end;
function TGMenusManager.GetMenu_tmp(aName: string;ctx:T;ForceReCreate:boolean=false;MMProcessor:TMenusMacros=nil):TMenu;
var
  TBNode,TBSubNode:TDomNode;
  menuname:string;
  MPF:TMacroProcessFunc;
begin
  menuname:='';
  result:=TPopupMenu(application.FindComponent(MenuNameModifier+aName));
  if ForceReCreate then
    if result<>nil then
      FreeAndNil(result);
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
    if assigned(TBSubNode) then begin
      MPF:=GetMacroProcessFuncAddr(MMProcessor);
      if assigned(MMProcessor)then
        MMProcessor.SetCurrentContext(ctx);
      SetCurrentContext(ctx);
      GeneralContextChecker.SetCurrentContext(Application);
      TMenuDefaults.RegisterMenuCreateFunc('IFONE',@DoIfOneNode);
      TMenuDefaults.RegisterMenuCreateFunc('IFALL',@DoIfAllNode);
      TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,MPF);
      TMenuDefaults.UnRegisterMenuCreateFunc('IFONE');
      TMenuDefaults.UnRegisterMenuCreateFunc('IFALL');
      GeneralContextChecker.ReleaseCashe;
      GeneralContextChecker.ReSetCurrentContext(Application);
      ReleaseCashe;
      if assigned(MMProcessor)then
        MMProcessor.ReSetCurrentContext(ctx);
      ReSetCurrentContext(ctx);
      result:=TPopupMenu(application.FindComponent(MenuNameModifier+aName));
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
          TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,mpf);
          //exit;
        end;
        if TBSubNode.nodeName='SetMainMenu' then begin
          TMenuDefaults.TryRunMenuCreateFunc(fmainform,TBSubNode.NodeName,TBSubNode,factionlist,nil,mpf);
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

finalization
  if assigned(MenuConfig) then
    FreeAndNil(MenuConfig);
  if assigned(MenusManager) then
    FreeAndNil(MenusManager);
end.
