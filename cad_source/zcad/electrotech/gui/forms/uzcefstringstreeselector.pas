unit uzcefstringstreeselector;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ButtonPanel,
  VirtualTrees, uzceltechtreeprop, uzbtypes;

type

  { TStringsTreeSelector }

  PTStringsTreeNodeData=^TStringsTreeNodeData;
  TStringsTreeNodeData=record
    data:TBlobTree.TTreeNodeType;
  end;

  TStringsTreeSelector = class(TForm)
    ButtonPanel1: TButtonPanel;
    ComboBox1: TComboBox;
    StringsTree: TVirtualStringTree;
    procedure filltree(StringTreeNode:PVirtualNode;BlobTreeNode:TBlobTree.TTreeNodeType);
    procedure fill(BlobTree:TBlobTree);
    procedure clear;
    procedure setValue(value:TStringTreeType);
  private

  public
    RootNode:PVirtualNode;
    procedure gt(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                 TextType: TVSTTextType; var CellText: String);

  end;

var
  StringsTreeSelector: TStringsTreeSelector;

implementation

{$R *.lfm}

procedure TStringsTreeSelector.filltree(StringTreeNode:PVirtualNode;BlobTreeNode:TBlobTree.TTreeNodeType);
var
  PNodeData:PTStringsTreeNodeData;
  Child:TBlobTree.TTreeNodeType;
  childNode:PVirtualNode;
begin
  PNodeData:=StringsTree.GetNodeData(StringTreeNode);
  PNodeData^.data:=BlobTreeNode;
  for Child in BlobTreeNode.Children do begin
    childNode:=StringsTree.AddChild(StringTreeNode,nil);
    filltree(childNode,Child);
  end;
end;

procedure TStringsTreeSelector.fill(BlobTree:TBlobTree);
begin
  StringsTree.NodeDataSize:=sizeof(TStringsTreeNodeData);
  RootNode:=StringsTree.AddChild(nil,nil);
  filltree(RootNode,BlobTree.Root);
  StringsTree.OnGetText:=gt;
end;

procedure TStringsTreeSelector.clear;
begin
  RootNode:=nil;
  StringsTree.Clear;
end;

procedure TStringsTreeSelector.setValue(value:TStringTreeType);
begin
  ComboBox1.Text:=value;
end;


procedure TStringsTreeSelector.gt(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                  TextType: TVSTTextType; var CellText: String);
var
  PNodeData:PTStringsTreeNodeData;
begin
  PNodeData:=Sender.GetNodeData(Node);
  if assigned(PNodeData) then
  if assigned(PNodeData^.data) then
  begin
    CellText:=PNodeData^.data.Data.LocalizedName;
  end
end;

end.

