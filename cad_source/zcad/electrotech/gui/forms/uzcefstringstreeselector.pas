unit uzcefstringstreeselector;

{$mode delphi}

interface

uses
  Classes,SysUtils,Forms,Controls,Graphics,StdCtrls,ButtonPanel,LCLVersion,
  laz.VirtualTrees,uzceltechtreeprop,uzbtypes,uzeTypes,Math;

type

  { TStringsTreeSelector }

  PTStringsTreeNodeData=^TStringsTreeNodeData;
  TStringsTreeNodeData=record
    data:TBlobTree.TTreeNodeType;
  end;

  TStringsTreeSelector = class(TForm)
    ButtonPanel1: TButtonPanel;
    ComboBox1: TComboBox;
    StringsTree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
    procedure filltree(StringTreeNode:PVirtualNode;BlobTreeNode:TBlobTree.TTreeNodeType);
    procedure fill(BlobTree:TBlobTree);
    function FindNearestNode(value:TStringTreeType):PVirtualNode;
    procedure FindNode(CurrentNode:PVirtualNode;value:TStringTreeType;var MatchSize:integer; var NearestNode:PVirtualNode);
    procedure clear;
    procedure setValue(value:TStringTreeType);
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure EdChanged(Sender: TObject);
  private

  public
    TreeResult:TStringTreeType;
    RootNode:PVirtualNode;
    procedure gt(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                 TextType: TVSTTextType; var CellText: String);

  end;

var
  StringsTreeSelector: TStringsTreeSelector;

implementation
{todo: убрать когда выкинут TVirtualStringTree}
{$IF DECLARED(TVirtualStringTree)}{$R uzcefstringstreeselector.lfm}{$ELSE}{$R uzcefstringstreeselector-laz.lfm}{$ENDIF}

procedure TStringsTreeSelector.filltree(StringTreeNode:PVirtualNode;BlobTreeNode:TBlobTree.TTreeNodeType);
var
  PNodeData:PTStringsTreeNodeData;
  Child:TBlobTree.TTreeNodeType;
  childNode:PVirtualNode;
begin
  PNodeData:=StringsTree.GetNodeData(StringTreeNode);
  if PNodeData<>nil then
    PNodeData^.data:=BlobTreeNode;
  for Child in BlobTreeNode.Children do begin
    childNode:=StringsTree.AddChild(StringTreeNode,nil);
    filltree(childNode,Child);
  end;
end;

procedure TStringsTreeSelector.VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  PNodeData:PTStringsTreeNodeData;
begin
  PNodeData:=StringsTree.GetNodeData(Node);
  TreeResult:=PNodeData^.data.Data.FullName;
  ComboBox1.Text:=TreeResult;
end;

procedure TStringsTreeSelector.EdChanged(Sender: TObject);
begin
  TreeResult:=ComboBox1.Text;
end;

procedure TStringsTreeSelector.fill(BlobTree:TBlobTree);
begin
  StringsTree.NodeDataSize:=sizeof(TStringsTreeNodeData);
  RootNode:={StringsTree.AddChild(nil,nil)}nil;
  filltree(RootNode,BlobTree.Root);
  StringsTree.OnGetText:=gt;
  StringsTree.OnFocusChanged:=VTFocuschanged;
  ComboBox1.OnChange:=EdChanged;
end;

procedure TStringsTreeSelector.clear;
begin
  RootNode:=nil;
  StringsTree.Clear;
end;

function MyCompareStr(s1,s2:TStringTreeType):integer;
var
  i:integer;
begin
  result:=0;
  for i:=1 to min(length(s1),length(s2)) do
    if s1[i]=s2[i] then
      inc(result)
    else
      break;
end;

procedure TStringsTreeSelector.FindNode(CurrentNode:PVirtualNode;value:TStringTreeType;var MatchSize:integer; var NearestNode:PVirtualNode);
var
  PNodeData:PTStringsTreeNodeData;
  _MatchSize:integer;
  //dbg:TStringTreeType;
  NewNode:PVirtualNode;
begin
  repeat
    PNodeData:=StringsTree.GetNodeData(CurrentNode);
    if PNodeData<>nil then begin
      //dbg:=PNodeData^.data.Data.FullName;
      _MatchSize:=MyCompareStr(PNodeData^.data.Data.FullName,value);
      if _MatchSize>MatchSize then begin
        MatchSize:=_MatchSize;
        NearestNode:=CurrentNode;
      end;
    end;
    if CurrentNode.FirstChild<>nil then
      FindNode(CurrentNode.FirstChild,value,MatchSize,NearestNode);
    NewNode:=CurrentNode.NextSibling;
    if NewNode<>CurrentNode then
      CurrentNode:=NewNode
    else
      CurrentNode:=nil;
  until CurrentNode=nil;
end;


function TStringsTreeSelector.FindNearestNode(value:TStringTreeType):PVirtualNode;
var
 _MatchSize:integer;
begin
  _MatchSize:=0;
  result:=nil;
  FindNode(StringsTree.RootNode,value,_MatchSize,result);
end;

procedure TStringsTreeSelector.setValue(value:TStringTreeType);
var
  NearestNode:PVirtualNode;
begin
  ComboBox1.Text:=value;
  NearestNode:=FindNearestNode(value);
  if assigned(NearestNode) then begin
    StringsTree.Selected[NearestNode]:=true;
    StringsTree.FullyVisible[NearestNode]:=true;
  end;
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

