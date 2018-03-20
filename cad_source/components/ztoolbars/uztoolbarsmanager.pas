unit uztoolbarsmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,ActnList,
  LazConfigStorage,Laz2_XMLCfg,Laz2_DOM,
  Generics.Collections, Generics.Defaults, gvector;

const
     MenuNameModifier='MENU_';

type
  TProgramActionsManagerClass=class
    procedure CreateAndAddActionsToList(acnlist:TActionList);virtual;abstract;
  end;
  TActionsManagersVector=specialize TVector <TProgramActionsManagerClass>;
  TActionCreateFunc=procedure (aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList) of object;
  TMenuCreateFunc=procedure (aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem) of object;

  TTBCreateFunc=function (aName,aType: string):TToolBar of object;
  TTBItemCreateFunc=procedure (aNode: TDomNode; TB:TToolBar) of object;
  TTBRegisterInAPPFunc=procedure (aTBNode: TDomNode;aName,aType: string; Data:Pointer) of object;

  TTBCreateFuncRegister=specialize TDictionary <string,TTBCreateFunc>;
  TTBItemCreateFuncRegister=specialize TDictionary <string,TTBItemCreateFunc>;
  TActionCreateFuncRegister=specialize TDictionary <string,TActionCreateFunc>;
  TMenuCreateFuncRegister=specialize TDictionary <string,TMenuCreateFunc>;

  TToolBarsManagerDockForm=class(TCustomDockForm)
  protected
    procedure DoClose(var CloseAction: TCloseAction); override;
  end;

  TToolBarsManager=class
    private
    factionlist:TActionList;
    fdefbuttonheight:integer;
    fmainform:TForm;

    TBConfig:TXMLConfig;
    TBCreateFuncRegister:TTBCreateFuncRegister;
    TBItemCreateFuncRegister:TTBItemCreateFuncRegister;
    ActionCreateFuncRegister:TActionCreateFuncRegister;
    MenuCreateFuncRegister:TMenuCreateFuncRegister;

    public
    constructor Create(mainform:TForm;actlist:TActionList;defbuttonheight:integer);
    destructor Destroy;override;

    procedure SaveToolBarsToConfig(Config: TConfigStorage);
    procedure RestoreToolBarsFromConfig(Config: TConfigStorage);
    procedure ShowFloatToolbar(TBName:String;r:trect);
    function FindToolBar(TBName:String;out tb:TToolBar):boolean;
    procedure LoadToolBarsContent(filename:string);
    procedure LoadActions(filename:string);
    procedure LoadMenus(filename:string);
    function FindBarsContent(toolbarname:string):TDomNode;
    procedure EnumerateToolBars(rf:TTBRegisterInAPPFunc;Data:Pointer);
    procedure CreateToolbarContent(tb:TToolBar;TBNode:TDomNode);
    procedure RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
    procedure RegisterTBItemCreateFunc(aNodeName:string;TBItemCreateFunc:TTBItemCreateFunc);
    procedure RegisterActionCreateFunc(aNodeName:string;ActionCreateFunc:TActionCreateFunc);
    procedure RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
    procedure TryRunMenuCreateFunc(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    function CreateToolbar(aName:string):TToolBar;
    function AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;
    function DoTBCreateFunc(aName,aType:string):TToolBar;
    procedure DoTBItemCreateFunc(aNodeName:string; aNode: TDomNode; TB:TToolBar);

    procedure SetupDefaultToolBar(aName,atype: string; tb:TToolBar);
    function CreateDefaultToolBar(aName,atype: string):TToolBar;
    procedure CreateDefaultSeparator(aNode: TDomNode; TB:TToolBar);
    procedure CreateDefaultAction(aNode: TDomNode; TB:TToolBar);
    procedure FloatDockSiteClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SetActionChecked(aName:string;newChecked:boolean);
    procedure DefaultShowToolbar(Sender: TObject);
    procedure DefaultAddToolBarToMenu(aTBNode: TDomNode;aName,aType: string; Data:Pointer);

    procedure DefaultActionsGroupReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    procedure DefaultMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenuAction(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure DefaultSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure CreateDefaultMenuSeparator(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure DefaultAddToolbars(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);

    procedure CreateManagedActions;
  end;

  function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
  function getAttrValue(const aNode:TDomNode;const AttrName:string;const DefValue:integer):integer;overload;
  function ToolBarNameToActionName(tbname:string):string;
  function FormNameToActionName(fname:string):string;
  procedure RegisterActionsManager(am:TProgramActionsManagerClass);

var
  ToolBarsManager:TToolBarsManager;
  ActionsManagersVector:TActionsManagersVector;

implementation

procedure TToolBarsManagerDockForm.DoClose(var CloseAction: TCloseAction);
begin
  ToolBarsManager.FloatDockSiteClose(self,CloseAction);
  inherited DoClose(CloseAction);
end;

function ToolBarNameToActionName(tbname:string):string;
begin
  result:='ACN_SHOWTOOLBAR_'+uppercase(tbname);
end;

function FormNameToActionName(fname:string):string;
begin
  result:='ACN_SHOWFORM_'+uppercase(fname);
end;

procedure TToolBarsManager.SetupDefaultToolBar(aName,atype: string; tb:TToolBar);
var
  ta:TAction;
begin
  SetActionChecked(ToolBarNameToActionName(aname),true);
  if fdefbuttonheight>0 then
    tb.ButtonHeight:=fdefbuttonheight;
  tb.Align:=alclient;
  tb.Top:=0;
  tb.Left:=0;
  //tb.AutoSize:=true;
  tb.Align:=alClient;
  tb.Wrapable:=false;
  tb.Transparent:=true;
  tb.DragKind:=dkDock;
  tb.DragMode:=dmAutomatic;
  tb.ShowCaptions:=true;
  tb.Name:=aname;
  tb.EdgeBorders:=[];
  if assigned(factionlist)then
  if not assigned(tb.Images) then
                                 tb.Images:=factionlist.Images;
end;

function TToolBarsManager.CreateDefaultToolBar(aName,atype: string):TToolBar;
var
  ta:TAction;
begin
  result:=TToolBar.Create(fmainform);
  SetupDefaultToolBar(aName,atype,result);
end;
procedure TToolBarsManager.CreateDefaultSeparator(aNode: TDomNode; TB:TToolBar);
begin
 with TToolButton.Create(TB) do
 begin
   Style:=tbsDivider;
   Parent:=TB;
   AutoSize:={False}True;
 end;
end;
procedure TToolBarsManager.CreateDefaultAction(aNode: TDomNode; TB:TToolBar);
var
  _action:TContainedAction;
  ActionName:string;
begin
  ActionName:=getAttrValue(aNode,'Name','');
  _action:=factionlist.ActionByName(ActionName);
  with TToolButton.Create(tb) do
  begin
    Action:=_action;
    ShowCaption:=false;
    ShowHint:=true;
    //Caption:=_action.imgstr;
    Parent:=tb;
    Visible:=true;
  end;
end;

constructor TToolBarsManager.Create(mainform:TForm;actlist:TActionList;defbuttonheight:integer);
begin
  fmainform:=mainform;
  factionlist:=actlist;
  fdefbuttonheight:=defbuttonheight;

  TBConfig:=nil;
  TBCreateFuncRegister:=nil;
  TBItemCreateFuncRegister:=nil;
  ActionCreateFuncRegister:=nil;
  MenuCreateFuncRegister:=nil;
end;
destructor TToolBarsManager.Destroy;
begin
    if assigned(TBConfig) then
      TBConfig.Free;
    if assigned(TBCreateFuncRegister) then
      TBCreateFuncRegister.Free;
    if assigned(TBItemCreateFuncRegister) then
      TBItemCreateFuncRegister.Free;
    if assigned(ActionCreateFuncRegister) then
      ActionCreateFuncRegister.Free;
    if assigned(MenuCreateFuncRegister) then
      MenuCreateFuncRegister.Free;
end;
function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
var
  aNodeAttr:TDomNode;
begin
  aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName);
  if assigned(aNodeAttr) then
                              result:=aNodeAttr.NodeValue
                          else
                              result:=DefValue;
end;

function getAttrValue(const aNode:TDomNode;const AttrName:string;const DefValue:integer):integer;overload;
var
  aNodeAttr:TDomNode;
  value:string;
begin
  value:='';
  aNodeAttr:=aNode.Attributes.GetNamedItem(AttrName);
  if assigned(aNodeAttr) then
                              value:=aNodeAttr.NodeValue;
  if not TryStrToInt(value,result) then
    result:=DefValue;
end;

procedure TToolBarsManager.RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
begin
  if not assigned(TBCreateFuncRegister) then
    TBCreateFuncRegister:=TTBCreateFuncRegister.create;
  TBCreateFuncRegister.add(uppercase(TBType),TBCreateFunc);
end;

function TToolBarsManager.DoTBCreateFunc(aName,aType:string):TToolBar;
var
  tbcf:TTBCreateFunc;
begin
  result:=nil;
  if assigned(TBCreateFuncRegister) then
    if TBCreateFuncRegister.TryGetValue(uppercase(aType),tbcf)then
      result:=tbcf(aName,aType);
end;

procedure TToolBarsManager.RegisterTBItemCreateFunc(aNodeName:string;TBItemCreateFunc:TTBItemCreateFunc);
begin
  if not assigned(TBItemCreateFuncRegister) then
    TBItemCreateFuncRegister:=TTBItemCreateFuncRegister.create;
  TBItemCreateFuncRegister.add(uppercase(aNodeName),TBItemCreateFunc);
end;

procedure TToolBarsManager.RegisterActionCreateFunc(aNodeName:string;ActionCreateFunc:TActionCreateFunc);
begin
  if not assigned(ActionCreateFuncRegister) then
    ActionCreateFuncRegister:=TActionCreateFuncRegister.create;
  ActionCreateFuncRegister.add(uppercase(aNodeName),ActionCreateFunc);
end;

procedure TToolBarsManager.RegisterMenuCreateFunc(aNodeName:string;MenuCreateFunc:TMenuCreateFunc);
begin
  if not assigned(MenuCreateFuncRegister) then
    MenuCreateFuncRegister:=TMenuCreateFuncRegister.create;
  MenuCreateFuncRegister.add(uppercase(aNodeName),MenuCreateFunc);
end;

procedure TToolBarsManager.TryRunMenuCreateFunc(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  mcf:TMenuCreateFunc;
  msg:string;
begin
if assigned(ToolBarsManager.MenuCreateFuncRegister) then
  if MenuCreateFuncRegister.TryGetValue(uppercase(aName),mcf)then
    mcf(aName,aNode,actlist,RootMenuItem)
  else begin
    msg:=format('"%s" not found in MenuCreateFuncRegister',[aName]);
    Application.MessageBox(@msg[1],'Error');
  end;
end;

procedure TToolBarsManager.DoTBItemCreateFunc(aNodeName:string; aNode: TDomNode; TB:TToolBar);
var
  tbicf:TTBItemCreateFunc;
begin
  if assigned(TBItemCreateFuncRegister) then
    if TBItemCreateFuncRegister.TryGetValue(uppercase(aNodeName),tbicf)then
      tbicf(aNode,TB);
end;

function IsFloatToolbar(tb:TToolBar;out tf:TCustomDockForm):boolean;
begin
  tf:=TCustomDockForm(tb.Parent);
  if tf is TCustomDockForm then
    result:=true
  else
    result:=false;
end;

procedure TToolBarsManager.SaveToolBarsToConfig(Config: TConfigStorage);
var
  i,j,ItemCount:integer;
  cb:TCoolBar;
  tb:TToolBar;
  tf:TCustomDockForm;
begin
  ItemCount:=0;
  Config.AppendBasePath('ToolBarsConfig/');
  for i:=0 to fmainform.ComponentCount-1 do
  if fmainform.Components[i] is TControl then
  begin
    if fmainform.Components[i] is TCoolBar then
    begin
      cb:=fmainform.Components[i] as TCoolBar;
      Config.AppendBasePath('Item'+inttostr(ItemCount));
      inc(ItemCount);
      Config.SetDeleteValue('Type','CoolBar','');
      Config.SetDeleteValue('Name',cb.Name,'');
      Config.SetDeleteValue('ItemCount',cb.Bands.Count,-1);
      for j:=0 to cb.Bands.Count-1 do
      begin
        Config.AppendBasePath('Item'+inttostr(j));
        Config.SetDeleteValue('Type','ToolBar','');
        Config.SetDeleteValue('Name',cb.Bands[j].Control.Name,'');
        Config.SetDeleteValue('Break',cb.Bands[j].Break,true);
        //if not cb.Bands[j].Break then
        Config.SetDeleteValue('Width',cb.Bands[j].Width,100);
        Config.UndoAppendBasePath;
      end;
      Config.UndoAppendBasePath;
    end;
    if fmainform.Components[i] is TToolBar then
    begin
      tb:=fmainform.Components[i] as TToolBar;
      if tb.IsVisible then
      if IsFloatToolbar(tb,tf) then
      begin
        Config.AppendBasePath('Item'+inttostr(ItemCount));
        inc(ItemCount);
        Config.SetDeleteValue('Type','FloatToolBar','');
        Config.SetDeleteValue('Name',tb.name,'');
        Config.SetDeleteValue('BoundsRect',tf.BoundsRect,Rect(0,0,0,0));
        Config.UndoAppendBasePath;
      end;
    end;
  end;
  Config.SetDeleteValue('ItemCount',ItemCount,0);
  Config.UndoAppendBasePath;
end;
procedure FreeAllToolBars(MainForm:TForm);
var
  i,j:integer;
  cb:TCoolBar;
  tb:TToolBar;
  tf:TCustomDockForm;
begin
  for i:=MainForm.ComponentCount-1 downto 0 do
  if MainForm.Components[i] is TControl then
  begin
    if MainForm.Components[i] is TCoolBar then
    begin
      cb:=MainForm.Components[i] as TCoolBar;
      for j:=cb.Bands.Count-1 downto 0 do
      begin
        cb.Bands[j].Control.Free;
      end;
    end;
    if MainForm.Components[i] is TToolBar then
    begin
      tb:=MainForm.Components[i] as TToolBar;
      if IsFloatToolbar(tb,tf) then
      begin
        tb.Free;
      end;
    end;
  end;
end;
function FindCoolBar(MainForm:TForm;Name:string):TCoolBar;
var
  i:integer;
begin
  for i:=MainForm.ComponentCount-1 downto 0 do
  if MainForm.Components[i] is TCoolBar then
  if (MainForm.Components[i] as TCoolBar).Name=Name then
  begin
    result:=MainForm.Components[i] as TCoolBar;
    exit;
  end;
  result:=nil;
end;

function CreateFloatingDockSite(tb:TToolBar; const Bounds: TRect): TWinControl;//copy  from LCL
var
  FloatingClass: TWinControlClass;
  NewWidth: Integer;
  NewHeight: Integer;
  NewClientWidth: Integer;
  NewClientHeight: Integer;
begin
  Result := nil;
  FloatingClass:=tb.FloatingDockSiteClass;
  if (FloatingClass<>nil) and (FloatingClass<>TWinControlClass(tb.ClassType)) then
  begin
    Result := TWinControl(FloatingClass.NewInstance);
    Result.DisableAutoSizing{$IFDEF DebugDisableAutoSizing}('TControl.CreateFloatingDockSite'){$ENDIF};
    Result.Create(tb);
    {if result is TCustomDockForm then
      (result as TCustomDockForm).OnClose:=@ToolBarsManager.FloatDockSiteClose;}
    result.TabStop:=false;
    NewClientWidth:=Bounds.Right-Bounds.Left;
    NewClientHeight:=Bounds.Bottom-Bounds.Top;
    NewWidth:=Result.Width-Result.ClientWidth+NewClientWidth;
    NewHeight:=Result.Height-Result.ClientHeight+NewClientHeight;
    Result.SetBounds(Bounds.Left,Bounds.Top,NewWidth,NewHeight);
    Result.EnableAutoSizing{$IFDEF DebugDisableAutoSizing}('TControl.CreateFloatingDockSite'){$ENDIF};
  end;
end;
procedure TToolBarsManager.SetActionChecked(aName:string;newChecked:boolean);
var
  ta:TAction;
begin
  if assigned(factionlist)then
  begin
    ta:=taction(factionlist.ActionByName(aName));
    if ta<>nil then
                   ta.Checked:=newChecked;
  end;
end;

procedure TToolBarsManager.FloatDockSiteClose(Sender: TObject; var CloseAction: TCloseAction);
var
  ta:TAction;
begin
  SetActionChecked(ToolBarNameToActionName((Sender as TCustomDockForm).caption),false);
end;
function TToolBarsManager.FindBarsContent(toolbarname:string):TDomNode;
begin
  if not assigned(TBConfig) then
    exit(nil);
  result:=nil;
  result:=TBConfig.FindNode('ToolBarsContent/'+toolbarname,false);
end;

procedure TToolBarsManager.LoadToolBarsContent(filename:string);
begin
  if not assigned(TBConfig) then
    TBConfig:=TXMLConfig.Create(nil);
  TBConfig.Filename:=filename;
end;
procedure TToolBarsManager.LoadActions(filename:string);
var
  ActionsConfig:TXMLConfig;
  TBNode,TBSubNode:TDomNode;
  acf:TActionCreateFunc;
begin
  ActionsConfig:=TXMLConfig.Create(nil);
  ActionsConfig.Filename:=filename;

  TBNode:=ActionsConfig.FindNode('ActionsContent',false);
  if assigned(TBNode) then
    TBSubNode:=TBNode.FirstChild;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      if assigned(ActionCreateFuncRegister) then
        if ActionCreateFuncRegister.TryGetValue(uppercase(TBSubNode.NodeName),acf)then
          acf(TBSubNode.NodeName,TBSubNode,'',factionlist);
      TBSubNode:=TBSubNode.NextSibling;
    end;

  ActionsConfig.Free;
end;

procedure TToolBarsManager.LoadMenus(filename:string);
var
  ActionsConfig:TXMLConfig;
  TBNode,TBSubNode:TDomNode;
begin
  ActionsConfig:=TXMLConfig.Create(nil);
  ActionsConfig.Filename:=filename;

  TBNode:=ActionsConfig.FindNode('MenusContent',false);
  if assigned(TBNode) then
    TBSubNode:=TBNode.FirstChild;
  if assigned(TBSubNode) then
    while assigned(TBSubNode)do
    begin
      TryRunMenuCreateFunc(TBSubNode.NodeName,TBSubNode,factionlist,nil);
      TBSubNode:=TBSubNode.NextSibling;
    end;

  ActionsConfig.Free;
end;


procedure TToolBarsManager.EnumerateToolBars(rf:TTBRegisterInAPPFunc;Data:Pointer);
var
  TBNode,TBSubNode,TBNodeType:TDomNode;
begin
  if assigned(rf) then
  begin
    TBNode:=TBConfig.FindNode('ToolBarsContent',false);
    if assigned(TBNode) then
      TBSubNode:=TBNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
         rf(TBSubNode,TBSubNode.NodeName,getAttrValue(TBSubNode,'Type',''),data);
         TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

procedure TToolBarsManager.CreateToolbarContent(tb:TToolBar;TBNode:TDomNode);
var
  TBSubNode:TDomNode;
  TBType:string;
begin
  TBSubNode:=TBNode.FirstChild;
  while assigned(TBSubNode)do
  begin
     DoTBItemCreateFunc(TBSubNode.NodeName,TBSubNode,tb);
     TBSubNode:=TBSubNode.NextSibling;
  end;
end;

function TToolBarsManager.CreateToolbar(aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  TBType:=getAttrValue(TBNode,'Type','');
  result:=DoTBCreateFunc(aName,TBType);
  result.FloatingDockSiteClass:=TToolBarsManagerDockForm;
  CreateToolbarContent(result,TBNode);
end;

function TToolBarsManager.AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  TBType:=getAttrValue(TBNode,'Type','');
  CreateToolbarContent(tb,TBNode);
end;
function TToolBarsManager.FindToolBar(TBName:String;out tb:TToolBar):boolean;
var
  i,j:integer;
  cb:TCoolBar;
  tf:TCustomDockForm;
begin
  TBName:=uppercase(TBName);
  for i:=fmainform.ComponentCount-1 downto 0 do
  if fmainform.Components[i] is TControl then
  begin
    if fmainform.Components[i] is TCoolBar then
    begin
      cb:=fmainform.Components[i] as TCoolBar;
      for j:=cb.Bands.Count-1 downto 0 do
      begin
        if cb.Bands[j].Control is TToolBar then
        if uppercase(cb.Bands[j].Control.name)=TBName then
        begin
          result:=true;
          tb:=ttoolbar(cb.Bands[j].Control);
          exit;
        end;
      end;
    end;
    if fmainform.Components[i] is TToolBar then
    begin
      tb:=fmainform.Components[i] as TToolBar;
      if IsFloatToolbar(tb,tf) then
      if uppercase(tb.name)=TBName then
      begin
        result:=true;
        exit;
      end;
    end;
  end;
  result:=false;
  tb:=nil;
end;
Procedure TToolBarsManager.ShowFloatToolbar(TBName:String;r:trect);
var
  tb:TToolBar;
  FloatHost: TWinControl;
begin
  if FindToolBar(TBName,tb) then
  begin
    FloatHost:=GetParentForm(tb);
    FloatHost.Show;
    tb.Show;
    SetActionChecked(ToolBarNameToActionName(tb.name),true);
    exit;
  end;
  tb:=CreateToolbar(TBName);
  FloatHost := CreateFloatingDockSite(tb,r);
  if FloatHost <> nil then
  begin
    tb.dock(FloatHost,FloatHost.ClientRect);
    FloatHost.Caption := FloatHost.GetDockCaption(tb);
    FloatHost.Show;
  end;
end;

procedure TToolBarsManager.RestoreToolBarsFromConfig(Config: TConfigStorage);
var
  i,j,ItemCount:integer;
  itemName,itemType:string;
  cb:TCoolBar;
  tb:TToolBar;
  r:trect;
  FloatHost: TWinControl;
begin
  FreeAllToolBars(fmainform);
  Config.AppendBasePath('ToolBarsConfig/');
  ItemCount:=Config.GetValue('ItemCount',0);
  for i:=0 to ItemCount-1 do
  begin
    Config.AppendBasePath('Item'+IntToStr(i)+'/');
    itemType:=Config.GetValue('Type','');
    itemName:=Config.GetValue('Name','');
    case itemType of
     'CoolBar':begin
                 cb:=FindCoolBar(fmainform,itemName);
                 ItemCount:=Config.GetValue('ItemCount',0);
                 if cb<>nil then
                 begin
                   cb.BeginUpdate;
                   for j:=0 to ItemCount-1 do
                   begin
                     Config.AppendBasePath('Item'+IntToStr(j)+'/');
                     itemType:=Config.GetValue('Type','');
                     itemName:=Config.GetValue('Name','');
                     tb:=CreateToolbar(itemName);
                     //tb:=TBCreateFunc(itemName,itemType);
                     cb.InsertControl(tb,j);
                     cb.Bands[j].Break:=Config.GetValue('Break',True);
                     //if not cb.Bands[j].Break then
                     cb.Bands[j].Width:=Config.GetValue('Width',100);
                     Config.UndoAppendBasePath;
                   end;
                   cb.EndUpdate;
                 end;
               end;
'FloatToolBar':begin
                 Config.GetValue('BoundsRect',r,Rect(0,0,300,50));
                 ShowFloatToolbar(itemName,r);
               end;
    end;
    Config.UndoAppendBasePath;
  end;
  Config.UndoAppendBasePath;
end;

//Show toolbar OnExecute handler
procedure TToolBarsManager.DefaultShowToolbar(Sender: TObject);
begin
    if sender is TAction then
      ToolBarsManager.ShowFloatToolbar((Sender as TAction).Caption,rect(0,0,300,50));
end;

//Add to menu callback procedure for enumerate toolbars
procedure TToolBarsManager.DefaultAddToolBarToMenu(aTBNode: TDomNode;aName,aType: string; Data:Pointer);
var
  pm1:TMenuItem;
  aaction:taction;
begin
  aaction:=TAction.Create(fmainform);
  aaction.Name:=ToolBarNameToActionName(aName);
  aaction.Caption:=aName;
  aaction.OnExecute:=@DefaultShowToolbar;
  aaction.DisableIfNoHandler:=false;
  aaction.ActionList:=factionlist;

  pm1:=TMenuItem.Create(TMenuItem(Data));
  pm1.Action:=aaction;
  TMenuItem(Data).Add(pm1);
end;

procedure TToolBarsManager.DefaultActionsGroupReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
var
  TBSubNode:TDomNode;
  acf:TActionCreateFunc;
  category:string;
begin
    category:=getAttrValue(aNode,'Category','');
    if assigned(aNode) then
      TBSubNode:=aNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
        if assigned(ActionCreateFuncRegister) then
          if ActionCreateFuncRegister.TryGetValue(uppercase(TBSubNode.NodeName),acf)then
            acf(TBSubNode.NodeName,TBSubNode,category,factionlist);
        TBSubNode:=TBSubNode.NextSibling;
      end;
end;

procedure TToolBarsManager.DefaultMainMenuItemReader(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

procedure TToolBarsManager.CreateDefaultMenuAction(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

procedure TToolBarsManager.CreateDefaultMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

procedure TToolBarsManager.DefaultSetMenu(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  fmainform.Menu:=TMainMenu(application.FindComponent(MenuNameModifier+uppercase(getAttrValue(aNode,'Name',''))));
end;


procedure TToolBarsManager.CreateDefaultMenuSeparator(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
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

procedure TToolBarsManager.DefaultAddToolbars(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
begin
  ToolBarsManager.EnumerateToolBars(@ToolBarsManager.DefaultAddToolBarToMenu,pointer(RootMenuItem));
end;

procedure TToolBarsManager.CreateManagedActions;
var
  am:TProgramActionsManagerClass;
begin
  if assigned(ActionsManagersVector) then
    for am in ActionsManagersVector do
      am.CreateAndAddActionsToList(factionlist);
end;

procedure RegisterActionsManager(am:TProgramActionsManagerClass);
begin
  if not assigned(ActionsManagersVector) then
    ActionsManagersVector:=TActionsManagersVector.Create;
  ActionsManagersVector.PushBack(am);
end;

initialization
{if not assigned(ToolBarsManager) then
  ToolBarsManager.Create;}

finalization
  if assigned(ToolBarsManager) then
    ToolBarsManager.Free;
  if assigned(ActionsManagersVector)then
    ActionsManagersVector.free;
end.
