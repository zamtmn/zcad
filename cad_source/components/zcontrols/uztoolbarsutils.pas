unit uztoolbarsutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,
  LazConfigStorage;

type
  TTBCreateFunc=function (aName: string):TToolBar of object;

procedure SaveToolBarsToConfig(MainForm:TForm; Config: TConfigStorage);
procedure RestoreToolBarsFromConfig(MainForm:TForm; Config: TConfigStorage;TBCreateFunc:TTBCreateFunc);

implementation

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
        Config.UndoAppendBasePath;
      end;
      Config.UndoAppendBasePath;
    end;
    if MainForm.Components[i] is TToolBar then
    begin
      tb:=MainForm.Components[i] as TToolBar;
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

procedure RestoreToolBarsFromConfig(MainForm:TForm; Config: TConfigStorage;TBCreateFunc:TTBCreateFunc);
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
                   tb:=TBCreateFunc(itemName);
                   cb.InsertControl(tb,j);
                   Config.UndoAppendBasePath;
                 end;
               end;
'FloatToolBar':begin
                 Config.GetValue('BoundsRect',r,Rect(0,0,0,0));
                 tb:=TBCreateFunc(itemName);

                 FloatHost := CreateFloatingDockSite(tb,r);
                 if FloatHost <> nil then
                 begin
                   tb.dock(FloatHost,FloatHost.ClientRect);
                   FloatHost.Caption := FloatHost.GetDockCaption(tb);
                   FloatHost.Show;
                 end;
               end;
    end;
    Config.UndoAppendBasePath;
  end;
  Config.UndoAppendBasePath;
end;

end.

