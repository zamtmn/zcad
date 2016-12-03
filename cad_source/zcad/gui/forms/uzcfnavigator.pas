unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees,
  uzcimagesmanager;

type

  { TNavigator }

  TNavigator = class(TForm)
    MainToolBar: TToolBar;
    NavTree: TVirtualStringTree;
    ToolButton1: TToolButton;
    RefreshToolButton: TToolButton;
    ToolButton3: TToolButton;
    ActionList1:TActionList;
    Refresh:TAction;
    procedure RefreshTree(Sender: TObject);
    procedure _onCreate(Sender: TObject);
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
    procedure NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);

  private

  public
    PRootNode1,PRootNode2:PVirtualNode;
  end;

var
  Navigator: TNavigator;

implementation

{$R *.lfm}

{ TNavigator }

procedure TNavigator._onCreate(Sender: TObject);
begin
   ActionList1.Images:=IconList;
   MainToolBar.Images:=IconList;
   Refresh.ImageIndex:=II_Refresh;
end;

procedure TNavigator.RefreshTree(Sender: TObject);
var
  i:integer;
begin
   NavTree.BeginUpdate;
   NavTree.Clear;
   NavTree.Images:=IconList;
   PRootNode1:=NavTree.AddChild(nil,nil);
   PRootNode2:=NavTree.AddChild(nil,nil);
   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   for i:=0 to 9 do
      NavTree.AddChild(PRootNode1,nil);
   for i:=0 to 9 do
      NavTree.AddChild(PRootNode2,nil);
   NavTree.EndUpdate;
end;

procedure TNavigator.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
begin
     if Node=PRootNode1 then
                            CellText:='Root1'
else if Node=PRootNode2 then
                            CellText:='Root2'
else
  begin
  end;
end;
procedure TNavigator.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
begin
     if Node=PRootNode1 then
                            ImageIndex:=1
else if Node=PRootNode2 then
                            ImageIndex:=2
else
  begin
  end;
end;
end.

