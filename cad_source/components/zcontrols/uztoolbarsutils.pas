unit uztoolbarsutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,
  LazConfigStorage,Laz2_XMLCfg,Laz2_DOM,
  Generics.Collections;

type
  TTBCreateFunc=function (aName,aType: string):TToolBar of object;
  TTBItemCreateFunc=procedure (aNode: TDomNode; TB:TToolBar) of object;
  TTBRegisterInAPPFunc=procedure (aTBNode: TDomNode;aName,aType: string; Data:Pointer) of object;

  TTBCreateFuncRegister=specialize TDictionary <string,TTBCreateFunc>;
  TTBItemCreateFuncRegister=specialize TDictionary <string,TTBItemCreateFunc>;

procedure SaveToolBarsToConfig(MainForm:TForm; Config: TConfigStorage);
procedure RestoreToolBarsFromConfig(MainForm:TForm; Config: TConfigStorage);
Procedure ShowFloatToolbar(TBName:String;r:trect);
procedure LoadToolBarsContent(filename:string);
procedure EnumerateToolBars(rf:TTBRegisterInAPPFunc;Data:Pointer);
procedure RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
procedure RegisterTBItemCreateFunc(aNodeName:string;TBItemCreateFunc:TTBItemCreateFunc);
function getAttrValue(const aNode:TDomNode;const AttrName,DefValue:string):string;overload;
function getAttrValue(const aNode:TDomNode;const AttrName:string;const DefValue:integer):integer;overload;
function CreateToolbar(aName:string):TToolBar;
function AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;

implementation

var
  TBConfig:TXMLConfig=nil;
  TBCreateFuncRegister:TTBCreateFuncRegister=nil;
  TBItemCreateFuncRegister:TTBItemCreateFuncRegister=nil;

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

procedure RegisterTBCreateFunc(TBType:string;TBCreateFunc:TTBCreateFunc);
begin
  if not assigned(TBCreateFuncRegister) then
    TBCreateFuncRegister:=TTBCreateFuncRegister.create;
  TBCreateFuncRegister.add(uppercase(TBType),TBCreateFunc);
end;

function DoTBCreateFunc(aName,aType:string):TToolBar;
var
  tbcf:TTBCreateFunc;
begin
  result:=nil;
  if assigned(TBCreateFuncRegister) then
    if TBCreateFuncRegister.TryGetValue(uppercase(aType),tbcf)then
      result:=tbcf(aName,aType);
end;

procedure RegisterTBItemCreateFunc(aNodeName:string;TBItemCreateFunc:TTBItemCreateFunc);
begin
  if not assigned(TBItemCreateFuncRegister) then
    TBItemCreateFuncRegister:=TTBItemCreateFuncRegister.create;
  TBItemCreateFuncRegister.add(uppercase(aNodeName),TBItemCreateFunc);
end;

procedure DoTBItemCreateFunc(aNodeName:string; aNode: TDomNode; TB:TToolBar);
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

procedure SaveToolBarsToConfig(MainForm:TForm; Config: TConfigStorage);
var
  i,j,ItemCount:integer;
  cb:TCoolBar;
  tb:TToolBar;
  tf:TCustomDockForm;
begin
  ItemCount:=0;
  Config.AppendBasePath('ToolBarsConfig/');
  for i:=0 to MainForm.ComponentCount-1 do
  if MainForm.Components[i] is TControl then
  begin
    if MainForm.Components[i] is TCoolBar then
    begin
      cb:=MainForm.Components[i] as TCoolBar;
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
    if MainForm.Components[i] is TToolBar then
    begin
      tb:=MainForm.Components[i] as TToolBar;
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
      for j:=0 to cb.Bands.Count-1 do
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

function CreateFloatingDockSite(tb:TToolBar; const Bounds: TRect): TWinControl;
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
    if result is TCustomDockForm then
      (result as TCustomDockForm).BorderStyle:=bsSizeToolWin;
    result.TabStop:=false;
    // resize with minimal resizes
    NewClientWidth:=Bounds.Right-Bounds.Left;
    NewClientHeight:=Bounds.Bottom-Bounds.Top;
    NewWidth:=Result.Width-Result.ClientWidth+NewClientWidth;
    NewHeight:=Result.Height-Result.ClientHeight+NewClientHeight;
    Result.SetBounds(Bounds.Left,Bounds.Top,NewWidth,NewHeight);
    //Result.SetClientSize(Point(NewClientWidth,NewClientHeight));
    {$IFDEF DebugDisableAutoSizing}
    debugln('TControl.CreateFloatingDockSite A ',DbgSName(Self),' ',DbgSName(Result),' ',dbgs(Result.BoundsRect));
    {$ENDIF}
    Result.EnableAutoSizing{$IFDEF DebugDisableAutoSizing}('TControl.CreateFloatingDockSite'){$ENDIF};
  end;
end;

function FindBarsContent(toolbarname:string):TDomNode;
//var
//  node,subnode,namenode:TDomNode;
//  s:string;
begin
  if not assigned(TBConfig) then
    exit(nil);
  result:=nil;
  result:=TBConfig.FindNode('ToolBarsContent/'+toolbarname,false);
  //s:=result.NodeName;
end;

procedure LoadToolBarsContent(filename:string);
begin
  if not assigned(TBConfig) then
    TBConfig:=TXMLConfig.Create(nil);
  TBConfig.Filename:=filename;
end;

procedure EnumerateToolBars(rf:TTBRegisterInAPPFunc;Data:Pointer);
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

procedure CreateToolbarContent(tb:TToolBar;TBNode:TDomNode);
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

function CreateToolbar(aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  TBType:=getAttrValue(TBNode,'Type','');
  result:=DoTBCreateFunc(aName,TBType);
  CreateToolbarContent(result,TBNode);
end;

function AddContentToToolbar(tb:TToolBar;aName:string):TToolBar;
var
  TBNode,TBSubNode:TDomNode;
  TBType:string;
begin
  TBNode:=FindBarsContent(aName);
  TBType:=getAttrValue(TBNode,'Type','');
  CreateToolbarContent(tb,TBNode);
end;

Procedure ShowFloatToolbar(TBName:String;r:trect);
var
  tb:TToolBar;
  FloatHost: TWinControl;
begin
  tb:=CreateToolbar(TBName);
  FloatHost := CreateFloatingDockSite(tb,r);
  if FloatHost <> nil then
  begin
    tb.dock(FloatHost,FloatHost.ClientRect);
    FloatHost.Caption := FloatHost.GetDockCaption(tb);
    FloatHost.Show;
  end;
end;

procedure RestoreToolBarsFromConfig(MainForm:TForm; Config: TConfigStorage);
var
  i,j,ItemCount:integer;
  itemName,itemType:string;
  cb:TCoolBar;
  tb:TToolBar;
  r:trect;
  FloatHost: TWinControl;
begin
  FreeAllToolBars(MainForm);
  Config.AppendBasePath('ToolBarsConfig/');
  ItemCount:=Config.GetValue('ItemCount',0);
  for i:=0 to ItemCount-1 do
  begin
    Config.AppendBasePath('Item'+IntToStr(i)+'/');
    itemType:=Config.GetValue('Type','');
    itemName:=Config.GetValue('Name','');
    case itemType of
     'CoolBar':begin
                 cb:=FindCoolBar(MainForm,itemName);
                 ItemCount:=Config.GetValue('ItemCount',0);
                 if cb<>nil then
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

finalization
  if assigned(TBConfig) then
    TBConfig.Free;
end.
