unit uztoolbarsmanager;

{$mode objfpc}{$H+}

interface

uses
  LCLType,ImgList,uzmacros,uzxmlnodesutils,
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,ActnList,
  LazConfigStorage,Laz2_XMLCfg,Laz2_DOM,
  Generics.Collections, Generics.Defaults, gvector;

type
  TPopUpMenyProxyAction=class(TAction)
    ToolButton:TToolButton;
    MainAction:TAction;

    function Execute: Boolean; override;
    procedure Assign(Source: TPersistent); override;
  end;

  TProgramActionsManagerClass=class
    procedure CreateAndAddActionsToList(acnlist:TActionList);virtual;abstract;
  end;
  TActionsManagersVector=specialize TVector <TProgramActionsManagerClass>;
  TActionCreateFunc=procedure (aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList) of object;

  TIterateToolbarsContentProc=procedure (_tb:TToolBar;_control:tcontrol);

  TPaletteControlBaseType=TWinControl;
  TPaletteCreateFunc=function (aName,aCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType of object;
  TPaletteItemCreateFunc=procedure (aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType) of object;
  TTBCreateFunc=function (aName,aType: string):TToolBar of object;
  TTBItemCreateFunc=procedure (fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar) of object;
  TTBRegisterInAPPFunc=procedure (fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string;Data:Pointer) of object;

  TPaletteCreateFuncRegister=specialize TDictionary <string,TPaletteCreateFunc>;
  TPaletteItemCreateFuncRegister=specialize TDictionary <string,TPaletteItemCreateFunc>;
  TTBCreateFuncRegister=specialize TDictionary <string,TTBCreateFunc>;
  TTBItemCreateFuncRegister=specialize TDictionary <string,TTBItemCreateFunc>;
  TActionCreateFuncRegister=specialize TDictionary <string,TActionCreateFunc>;

  TToolBarsManagerDockForm=class(TCustomDockForm)
  protected
    procedure DoClose(var CloseAction: TCloseAction); override;
  end;

  TToolBarsManager=class
    private
    factionlist:TActionList;
    fdefbuttonheight:integer;
    fmainform:TForm;

    TBConfig,PalettesConfig:TXMLConfig;
    TBCreateFuncRegister:TTBCreateFuncRegister;
    TBItemCreateFuncRegister:TTBItemCreateFuncRegister;
    ActionCreateFuncRegister:TActionCreateFuncRegister;
    PaletteCreateFuncRegister:TPaletteCreateFuncRegister;
    PaletteItemCreateFuncRegister:TPaletteItemCreateFuncRegister;

    public
    constructor Create;
    destructor Destroy;override;

    procedure Setup(mainform:TForm;actlist:TActionList;defbuttonheight:integer);
    procedure SaveToolBarsToConfig(Config: TConfigStorage);
    procedure RestoreToolBarsFromConfig(Config: TConfigStorage);
    procedure ShowFloatToolbar(TBName:String;r:trect);
    procedure IterateToolBarsContent(ip:TIterateToolbarsContentProc);
    function FindToolBar(TBName:String;out tb:TToolBar):boolean;
    procedure LoadToolBarsContent(filename:string);
    procedure LoadPalettes(filename:string);
    procedure LoadActions(filename:string);
    function FindBarsContent(toolbarname:string):TDomNode;
    function FindPalettesContent(PaletteName:string):TDomNode;
    procedure EnumerateToolBars(rf:TTBRegisterInAPPFunc;Data:Pointer);
    procedure EnumerateToolPalettes(rf:TTBRegisterInAPPFunc;Data:Pointer);
    procedure CreateToolbarContent(tb:TToolBar;TBNode:TDomNode);
    procedure CreatePaletteContent(Palette:TPaletteControlBaseType;TBNode:TDomNode;rootnode:TPersistent;PaletteControl:TPaletteControlBaseType);
    procedure RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
    procedure RegisterPaletteCreateFunc(PaletteType:string;PaletteCreateFunc:TPaletteCreateFunc);
    procedure RegisterPaletteItemCreateFunc(aNodeName:string;PaletteItemCreateFunc:TPaletteItemCreateFunc);
    procedure RegisterTBItemCreateFunc(aNodeName:string;TBItemCreateFunc:TTBItemCreateFunc);
    procedure RegisterActionCreateFunc(aNodeName:string;ActionCreateFunc:TActionCreateFunc);
    function CreateToolbar(aName:string):TToolBar;
    function CreateToolPalette(aControlName: string;DoDisableAlign:boolean=false):TPaletteControlBaseType;
    function AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;
    function DoTBCreateFunc(aName,aType:string):TToolBar;
    function DoToolPaletteCreateFunc(aControlName,aInternalName:string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
    procedure DoTBItemCreateFunc(fmf:TForm;actlist:TActionList;aNodeName:string; aNode: TDomNode; TB:TToolBar);
    procedure DoToolPaletteItemCreateFunc(aNodeName:string; aNode: TDomNode;rootnode:TPersistent;PC:TPaletteControlBaseType);

    procedure SetupDefaultToolBar(aName,atype: string; tb:TToolBar);
    function CreateDefaultToolBar(aName,atype: string):TToolBar;
    procedure CreateDefaultSeparator(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
    procedure CreateDefaultAction(aNode: TDomNode; TB:TToolBar);
    procedure FloatDockSiteClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SetActionChecked(aName:string;newChecked:boolean);
    procedure DefaultShowToolbar(Sender: TObject);
    procedure DefaultAddToolBarToMenu(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string; Data:Pointer);

    procedure DefaultActionsGroupReader(aName: string;aNode: TDomNode;CategoryOverrider:string;actlist:TActionList);
    procedure DefaultAddToolbars(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);

    procedure CreateManagedActions;
  end;

  function ToolBarNameToActionName(tbname:string):string;
  function ToolPaletteNameToActionName(tbname:string):string;
  function FormNameToActionName(fname:string):string;
  procedure RegisterActionsManager(am:TProgramActionsManagerClass);

var
  ToolBarsManager:TToolBarsManager;
  ActionsManagersVector:TActionsManagersVector;
  ToolPaletteNamePrefix:String='TOOLPALETTE_';

implementation

function TPopUpMenyProxyAction.Execute: Boolean;
begin
  if assigned(ToolButton)then ToolButton.Action:=MainAction;
  if MainAction.ImageIndex<>-1 then ToolButton.caption:='';
  if assigned(MainAction)then result:=MainAction.Execute
                         else result:=false;
end;
procedure TPopUpMenyProxyAction.Assign(Source: TPersistent);
begin
  if source is TAction then begin
    AutoCheck:=(Source as TAction).AutoCheck;
    Caption:=(Source as TAction).Caption;
    Checked:=(Source as TAction).Checked;
    DisableIfNoHandler:=(Source as TAction).DisableIfNoHandler;
    Enabled:=(Source as TAction).Enabled;
    GroupIndex:=(Source as TAction).GroupIndex;
    HelpContext:=(Source as TAction).HelpContext;
    HelpKeyword:=(Source as TAction).HelpKeyword;
    HelpType:=(Source as TAction).HelpType;
    Hint:=(Source as TAction).Hint;
    ImageIndex:=(Source as TAction).ImageIndex;
    OnHint:=(Source as TAction).OnHint;
    SecondaryShortCuts:=(Source as TAction).SecondaryShortCuts;
    ShortCut:=(Source as TAction).ShortCut;
    Visible:=(Source as TAction).Visible;
  end;
end;

{procedure TPopUpMenyProxyAction.SetAutoCheck(Value:Boolean);
begin
  if assigned(MainAction)then
    MainAction.AutoCheck:=Value;
end;
function TPopUpMenyProxyAction.GetAutoCheck:boolean;
begin
  if assigned(MainAction)then
    result:=MainAction.AutoCheck;
end;
procedure TPopUpMenyProxyAction.SetCaption(Value:TTranslateString);
begin
  if assigned(MainAction)then
    MainAction.Caption:=Value;
end;
function TPopUpMenyProxyAction.GetCaption:TTranslateString;
begin
  if assigned(MainAction)then
    result:=MainAction.Caption;
end;
procedure TPopUpMenyProxyAction.SetChecked(Value:Boolean);
begin
  if assigned(MainAction)then
    MainAction.Checked:=Value;
end;
function TPopUpMenyProxyAction.GetChecked:boolean;
begin
  if assigned(MainAction)then
    result:=MainAction.Checked;
end;
procedure TPopUpMenyProxyAction.SetDisableIfNoHandler(Value:Boolean);
begin
  if assigned(MainAction)then
    MainAction.DisableIfNoHandler:=Value;
end;
function TPopUpMenyProxyAction.GetDisableIfNoHandler:boolean;
begin
  if assigned(MainAction)then
    result:=MainAction.DisableIfNoHandler;
end;
procedure TPopUpMenyProxyAction.SetEnabled(Value:Boolean);
begin
  if assigned(MainAction)then
    MainAction.AutoCheck:=Value;
end;
function TPopUpMenyProxyAction.GetEnabled:boolean;
begin
  if assigned(MainAction)then
    result:=MainAction.Enabled;
end;
procedure TPopUpMenyProxyAction.SetGroupIndex(Value:Integer);
begin
  if assigned(MainAction)then
    MainAction.GroupIndex:=GroupIndex;
end;
function TPopUpMenyProxyAction.GetGroupIndex:Integer;
begin
  if assigned(MainAction)then
    result:=MainAction.GroupIndex;
end;
procedure TPopUpMenyProxyAction.SetHelpContext(Value:THelpContext);
begin
  if assigned(MainAction)then
    MainAction.HelpContext:=HelpContext;
end;
function TPopUpMenyProxyAction.GetHelpContext:THelpContext;
begin
  if assigned(MainAction)then
    result:=MainAction.HelpContext;
end;
procedure TPopUpMenyProxyAction.SetHelpKeyword(Value:string);
begin
  if assigned(MainAction)then
    MainAction.HelpKeyword:=Value;
end;
function TPopUpMenyProxyAction.GetHelpKeyword:string;
begin
  if assigned(MainAction)then
    result:=MainAction.HelpKeyword;
end;
procedure TPopUpMenyProxyAction.SetHelpType(Value:THelpType);
begin
  if assigned(MainAction)then
    MainAction.HelpType:=Value;
end;
function TPopUpMenyProxyAction.GetHelpType:THelpType;
begin
  if assigned(MainAction)then
    result:=MainAction.HelpType;
end;
procedure TPopUpMenyProxyAction.SetHint(Value:TTranslateString);
begin
  if assigned(MainAction)then
    MainAction.Hint:=Value;
end;
function TPopUpMenyProxyAction.GetHint:TTranslateString;
begin
  if assigned(MainAction)then
    result:=MainAction.Hint;
end;
procedure TPopUpMenyProxyAction.SetImageIndex(Value:TImageIndex);
begin
  if assigned(MainAction)then
    MainAction.ImageIndex:=Value;
end;
function TPopUpMenyProxyAction.GetImageIndex:TImageIndex;
begin
  if assigned(MainAction)then
    result:=MainAction.ImageIndex;
end;
procedure TPopUpMenyProxyAction.SetOnHint(Value:THintEvent);
begin
  if assigned(MainAction)then
    MainAction.OnHint:=Value;
end;
function TPopUpMenyProxyAction.GetOnHint:THintEvent;
begin
  if assigned(MainAction)then
    result:=MainAction.OnHint;
end;
procedure TPopUpMenyProxyAction.SetSecondaryShortCuts(Value:TShortCutList);
begin
  if assigned(MainAction)then
    MainAction.SecondaryShortCuts:=SecondaryShortCuts;
end;
function TPopUpMenyProxyAction.GetSecondaryShortCuts:TShortCutList;
begin
  if assigned(MainAction)then
    result:=MainAction.SecondaryShortCuts;
end;
procedure TPopUpMenyProxyAction.SetShortCut(Value:TShortCut);
begin
  if assigned(MainAction)then
    MainAction.ShortCut:=Value;
end;
function TPopUpMenyProxyAction.GetShortCut:TShortCut;
begin
  if assigned(MainAction)then
    result:=MainAction.ShortCut;
end;
procedure TPopUpMenyProxyAction.SetVisible(Value:Boolean);
begin
  if assigned(MainAction)then
    MainAction.Visible:=Value;
end;
function TPopUpMenyProxyAction.GetVisible:boolean;
begin
  if assigned(MainAction)then
    result:=MainAction.Visible;
end;}
procedure TToolBarsManagerDockForm.DoClose(var CloseAction: TCloseAction);
begin
  ToolBarsManager.FloatDockSiteClose(self,CloseAction);
  inherited DoClose(CloseAction);
end;

function ToolBarNameToActionName(tbname:string):string;
begin
  result:='ACN_SHOWTOOLBAR_'+uppercase(tbname);
end;
function ToolPaletteNameToActionName(tbname:string):string;
begin
  result:='ACN_SHOWTOOLPALETTE_'+uppercase(tbname);
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
procedure TToolBarsManager.CreateDefaultSeparator(fmf:TForm;actlist:TActionList;aNode: TDomNode; TB:TToolBar);
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

constructor TToolBarsManager.Create;
begin
  Setup(nil,nil,21);

  TBConfig:=nil;
  PalettesConfig:=nil;
  TBCreateFuncRegister:=nil;
  PaletteCreateFuncRegister:=nil;
  PaletteItemCreateFuncRegister:=nil;
  TBItemCreateFuncRegister:=nil;
  ActionCreateFuncRegister:=nil;
end;

procedure TToolBarsManager.Setup(mainform:TForm;actlist:TActionList;defbuttonheight:integer);
begin
  fmainform:=mainform;
  factionlist:=actlist;
  fdefbuttonheight:=defbuttonheight;
end;

destructor TToolBarsManager.Destroy;
begin
    if assigned(TBConfig) then
      TBConfig.Free;
    if assigned(PalettesConfig) then
      PalettesConfig.Free;
    if assigned(TBCreateFuncRegister) then
      TBCreateFuncRegister.Free;
    if assigned(PaletteCreateFuncRegister) then
      PaletteCreateFuncRegister.Free;
    if assigned(PaletteItemCreateFuncRegister) then
      PaletteItemCreateFuncRegister.Free;
    if assigned(TBItemCreateFuncRegister) then
      TBItemCreateFuncRegister.Free;
    if assigned(ActionCreateFuncRegister) then
      ActionCreateFuncRegister.Free;
end;

procedure TToolBarsManager.RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
begin
  if not assigned(TBCreateFuncRegister) then
    TBCreateFuncRegister:=TTBCreateFuncRegister.create;
  TBCreateFuncRegister.add(uppercase(TBType),TBCreateFunc);
end;

procedure TToolBarsManager.RegisterPaletteCreateFunc(PaletteType:string;PaletteCreateFunc:TPaletteCreateFunc);
begin
  if not assigned(PaletteCreateFuncRegister) then
    PaletteCreateFuncRegister:=TPaletteCreateFuncRegister.create;
  PaletteCreateFuncRegister.add(uppercase(PaletteType),PaletteCreateFunc);
end;

procedure TToolBarsManager.RegisterPaletteItemCreateFunc(aNodeName:string;PaletteItemCreateFunc:TPaletteItemCreateFunc);
begin
  if not assigned(PaletteItemCreateFuncRegister) then
    PaletteItemCreateFuncRegister:=TPaletteItemCreateFuncRegister.create;
  PaletteItemCreateFuncRegister.add(uppercase(aNodeName),PaletteItemCreateFunc);
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

procedure TToolBarsManager.DoTBItemCreateFunc(fmf:TForm;actlist:TActionList;aNodeName:string; aNode: TDomNode; TB:TToolBar);
var
  tbicf:TTBItemCreateFunc;
begin
  if assigned(TBItemCreateFuncRegister) then
    if TBItemCreateFuncRegister.TryGetValue(uppercase(aNodeName),tbicf)then
      tbicf(fmf,actlist,aNode,TB);
end;

procedure TToolBarsManager.DoToolPaletteItemCreateFunc(aNodeName:string; aNode: TDomNode;rootnode:TPersistent;PC:TPaletteControlBaseType);
var
  picf:TPaletteItemCreateFunc;
begin
  if assigned(PaletteItemCreateFuncRegister) then
    if PaletteItemCreateFuncRegister.TryGetValue(uppercase(aNodeName),picf)then
      picf(aNode,rootnode,PC);
end;

function TToolBarsManager.DoToolPaletteCreateFunc(aControlName,aInternalName:string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
var
  tpcf:TPaletteCreateFunc;
  aType:string;
begin
  aType:=getAttrValue(TBNode,'Type','');
  if assigned(PaletteCreateFuncRegister) then
    if PaletteCreateFuncRegister.TryGetValue(uppercase(aType),tpcf)then
      result:=tpcf(aControlName,aInternalName,aType,TBNode,PaletteControl,DoDisableAlign);
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
function TToolBarsManager.FindPalettesContent(PaletteName:string):TDomNode;
begin
  if not assigned(PalettesConfig) then
    exit(nil);
  result:=nil;
  result:=PalettesConfig.FindNode('PalettesContent/'+PaletteName,false);
end;
procedure TToolBarsManager.LoadToolBarsContent(filename:string);
var
  tempTBConfig:TXMLConfig;
  tempTBContentNode,TBContentNode,TBSubNode:TDomNode;
begin
  if not assigned(TBConfig) then begin
    TBConfig:=TXMLConfig.Create(nil);
    TBConfig.Filename:=filename;
  end else begin
    tempTBConfig:=TXMLConfig.Create(nil);
    tempTBConfig.Filename:=filename;

    tempTBContentNode:=tempTBConfig.FindNode('ToolBarsContent',false);
    TBContentNode:=TBConfig.FindNode('ToolBarsContent',false);

    if assigned(tempTBContentNode) and assigned(TBContentNode)then begin
      TBSubNode:=tempTBContentNode.FirstChild;
      while assigned(TBSubNode)do
      begin
        TBContentNode.AppendChild(TBSubNode.CloneNode(true,TBContentNode.OwnerDocument));

        TBSubNode:=TBSubNode.NextSibling;
      end;
    end;

    tempTBConfig.Free;
  end;
end;
procedure TToolBarsManager.LoadPalettes(filename:string);
var
  tempPalettesConfig:TXMLConfig;
  tempPalettesContentNode,TBContentNode,TBSubNode:TDomNode;
begin
  if not assigned(PalettesConfig) then begin
    PalettesConfig:=TXMLConfig.Create(nil);
    PalettesConfig.Filename:=filename;
  end else begin
    tempPalettesConfig:=TXMLConfig.Create(nil);
    tempPalettesConfig.Filename:=filename;

    tempPalettesContentNode:=tempPalettesConfig.FindNode('PalettesContent',false);
    TBContentNode:=PalettesConfig.FindNode('PalettesContent',false);

    if assigned(tempPalettesContentNode) and assigned(TBContentNode)then begin
      TBSubNode:=tempPalettesContentNode.FirstChild;
      while assigned(TBSubNode)do
      begin
        TBContentNode.AppendChild(TBSubNode.CloneNode(true,TBContentNode.OwnerDocument));

        TBSubNode:=TBSubNode.NextSibling;
      end;
    end;

    tempPalettesConfig.Free;
  end;
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
         rf(fmainform,factionlist,TBSubNode,TBSubNode.NodeName,getAttrValue(TBSubNode,'Type',''),data);
         TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

procedure TToolBarsManager.EnumerateToolPalettes(rf:TTBRegisterInAPPFunc;Data:Pointer);
var
  TBNode,TBSubNode,TBNodeType:TDomNode;
begin
  if assigned(rf) then
  begin
    TBNode:=PalettesConfig.FindNode('PalettesContent',false);
    if assigned(TBNode) then
      TBSubNode:=TBNode.FirstChild;
    if assigned(TBSubNode) then
      while assigned(TBSubNode)do
      begin
         rf(fmainform,factionlist,TBSubNode,TBSubNode.NodeName,getAttrValue(TBSubNode,'Type',''),data);
         TBSubNode:=TBSubNode.NextSibling;
      end;
  end;
end;

procedure TToolBarsManager.CreateToolbarContent(tb:TToolBar;TBNode:TDomNode);
var
  TBSubNode:TDomNode;
begin
  TBSubNode:=TBNode.FirstChild;
  while assigned(TBSubNode)do
  begin
     DoTBItemCreateFunc(fmainform,factionlist,TBSubNode.NodeName,TBSubNode,tb);
     TBSubNode:=TBSubNode.NextSibling;
  end;
end;
procedure TToolBarsManager.CreatePaletteContent(Palette:TPaletteControlBaseType;TBNode:TDomNode;rootnode:TPersistent;PaletteControl:TPaletteControlBaseType);
var
  TBSubNode:TDomNode;
begin
  //PaletteControl:=TListView(Palette.Controls[1]);
  TBSubNode:=TBNode.FirstChild;
  while assigned(TBSubNode)do
  begin
    DoToolPaletteItemCreateFunc(TBSubNode.NodeName,TBSubNode,rootnode,PaletteControl);
    TBSubNode:=TBSubNode.NextSibling;
  end;
end;

function TToolBarsManager.CreateToolPalette(aControlName: string;DoDisableAlign:boolean=false):TPaletteControlBaseType;
var
  aInternalName:string;
  TBNode,TBSubNode:TDomNode;
  PaletteControl:TPaletteControlBaseType;
begin
  aInternalName:=copy(aControlName,length(ToolPaletteNamePrefix)+1,length(aControlName)-length(ToolPaletteNamePrefix));
  TBNode:=FindPalettesContent(aInternalName);
  if TBNode<>nil then begin
    result:=DoToolPaletteCreateFunc(aControlName,aInternalName,TBNode,PaletteControl,DoDisableAlign);
    if assigned(TBNode) then
      CreatePaletteContent(result,TBNode,nil,PaletteControl);
  end else begin
    aInternalName:=format('Palette "%s" content not found',[aInternalName]);
    Application.messagebox(pchar(aInternalName),'');
    result:=nil;
  end;
end;
function TToolBarsManager.CreateToolbar(aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  if TBNode<>nil then begin
    TBType:=getAttrValue(TBNode,'Type','');
    result:=DoTBCreateFunc(aName,TBType);
    if assigned(result) then begin
      result.FloatingDockSiteClass:=TToolBarsManagerDockForm;
      if assigned(TBNode) then
        CreateToolbarContent(result,TBNode);
    end;
  end else begin
    TBType:=format('Toolbar "%s" content not found',[aName]);
    Application.messagebox(pchar(TBType),'');
    result:=nil;
  end;
end;

function TToolBarsManager.AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  if TBNode<>nil then begin
    TBType:=getAttrValue(TBNode,'Type','');
    CreateToolbarContent(tb,TBNode);
  end;
end;
procedure IterateTBContent(tb:TToolBar;ip:TIterateToolbarsContentProc);
var
  i:integer;
begin
  for i:=0 to tb.ControlCount-1 do
    ip(tb,tb.Controls[i]);
end;
procedure TToolBarsManager.IterateToolBarsContent(ip:TIterateToolbarsContentProc);
var
  i,j:integer;
  cb:TCoolBar;
  tf:TCustomDockForm;
  tb:TToolBar;
begin
  for i:=fmainform.ComponentCount-1 downto 0 do
  if fmainform.Components[i] is TControl then
  begin
    if fmainform.Components[i] is TCoolBar then
    begin
      cb:=fmainform.Components[i] as TCoolBar;
      for j:=cb.Bands.Count-1 downto 0 do
      begin
        if cb.Bands[j].Control is TToolBar then
        begin
          IterateTBContent(ttoolbar(cb.Bands[j].Control),ip)
        end;
      end;
    end;
    if fmainform.Components[i] is TToolBar then
    begin
      tb:=fmainform.Components[i] as TToolBar;
      if IsFloatToolbar(tb,tf) then
      begin
        IterateTBContent(tb,ip)
      end;
    end;
  end;
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
                     if assigned(tb) then begin
                       cb.InsertControl(tb,j);
                       cb.Bands[j].Break:=Config.GetValue('Break',True);
                       //if not cb.Bands[j].Break then
                       cb.Bands[j].Width:=Config.GetValue('Width',100);
                     end;
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
procedure TToolBarsManager.DefaultAddToolBarToMenu(fmf:TForm;actlist:TActionList;aTBNode: TDomNode;aName,aType: string; Data:Pointer);
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

procedure TToolBarsManager.DefaultAddToolbars(fmf:TForm;aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem;MPF:TMacroProcessFunc);
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
  //if not assigned(ToolBarsManager) then
  ToolBarsManager:=TToolBarsManager.create;

finalization
  if assigned(ToolBarsManager) then
    ToolBarsManager.Free;
  if assigned(ActionsManagersVector)then
    ActionsManagersVector.free;
end.
