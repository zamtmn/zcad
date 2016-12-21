unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees,
  uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,uzcenitiesvariablesextender,varmandef;

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
    PCombinedNode1,PStandaloneNode:PVirtualNode;
  end;

var
  Navigator: TNavigator;

implementation

{$R *.lfm}

{ TNavigator }

procedure TNavigator._onCreate(Sender: TObject);
begin
   ActionList1.Images:=ImagesManager.IconList;
   MainToolBar.Images:=ImagesManager.IconList;
   Refresh.ImageIndex:=ImagesManager.GetImageIndex('Refresh');
end;

procedure TNavigator.RefreshTree(Sender: TObject);
var
  i:integer;
  pv:pGDBObjEntity;
  ir:itrec;
  pentvarext:PTVariablesExtender;
  pvd:pvardesk;
  BaseName:string;
begin
   NavTree.BeginUpdate;
   NavTree.Clear;
   NavTree.Images:=ImagesManager.IconList;
   PCombinedNode1:=NavTree.AddChild(nil,nil);
   PStandaloneNode:=NavTree.AddChild(nil,nil);
   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   {for i:=0 to 9 do
      NavTree.AddChild(PCombinedNode1,nil);}
   {for i:=0 to 9 do
      NavTree.AddChild(PStandaloneNode,nil);}
   pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
    if pentvarext<>nil then
    begin
         pvd:=pentvarext^.entityunit.FindVariable('NMO_BaseName');
         if pvd<>nil then
                         BaseName:=pgdbstring(pvd.data.Instance)^
                     else
                         BaseName:='??'
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
   NavTree.EndUpdate;
end;

procedure TNavigator.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
begin
     if Node=PCombinedNode1 then
                            CellText:='Combined devices'
else if Node=PStandaloneNode then
                            CellText:='Standalone devices'
else
  begin
  end;
end;
procedure TNavigator.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
begin
     if Node=PCombinedNode1 then
                            ImageIndex:=ImagesManager.GetImageIndex('caddie')
else if Node=PStandaloneNode then
                            ImageIndex:=ImagesManager.GetImageIndex('basket')
else
  begin
  end;
end;
end.

