unit uztoolbarsutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Controls, Graphics, Menus, Forms,
  LazConfigStorage;

procedure SaveToolBarsToConfig(MainForm:TForm; Config: TConfigStorage);

implementation



procedure SaveToolBarsToConfig(MainForm:TForm; Config: TConfigStorage);
var
  i,j,fcount,ccount:integer;
  cb:TCoolBar;
  tb:TToolBar;
  tf:TCustomDockForm;
begin
  fcount:=0;
  ccount:=0;
  Config.AppendBasePath('ToolBarsConfig/');
  for i:=0 to MainForm.ComponentCount-1 do
  if MainForm.Components[i] is TControl then
  begin
    if MainForm.Components[i] is TCoolBar then
    begin
      cb:=MainForm.Components[i] as TCoolBar;
      Config.AppendBasePath('CoolBar'+inttostr(ccount));
      inc(ccount);
      Config.SetDeleteValue('Name',cb.Name,'');
      for j:=0 to cb.Bands.Count-1 do
      begin
        Config.AppendBasePath('ToolBar'+inttostr(j));
        Config.SetDeleteValue('Name',cb.Bands[j].Control.Name,'');
        Config.UndoAppendBasePath;
      end;
      Config.UndoAppendBasePath;
    end;
    if MainForm.Components[i] is TToolBar then
    begin
      tb:=MainForm.Components[i] as TToolBar;
      tf:=TCustomDockForm(tb.Parent);
      if tf is TCustomDockForm then
      begin
        Config.AppendBasePath('FloatToolbar'+inttostr(fcount));
        inc(fcount);
        Config.SetDeleteValue('Name',tb.name,'');
        Config.SetDeleteValue('BoundsRect',tf.BoundsRect,Rect(0,0,0,0));
        Config.UndoAppendBasePath;
      end;
    end;
  end;
  Config.UndoAppendBasePath;
end;

end.

