{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzctbextpalettes;
{$INCLUDE zengineconfig.inc}
interface
uses
     uzcstrconsts,uzcsysparams,uzcsysvars,
     uzcinfoform,Varman,uzcinterface,laz.VirtualTrees,LCLVersion,
     uzbstrproc,
     EditBtn,Masks,StdCtrls,ExtCtrls,Controls,Classes,Forms,Buttons,
     uzccommandsmanager,Laz2_DOM,
     ComCtrls,uztoolbarsmanager,uzxmlnodesutils,uzcimagesmanager,
     uzctranslations,uzcdrawings;
type
    TZPaletteListItem=class(TListItem)
    public
      Command:ansistring;
  end;
  PTPaletteTreeNodeData=^TPaletteTreeNodeData;
  TPaletteTreeNodeData=record
    text,command:string;
    imageindex:integer;
  end;
  PZPaletteTreeNode=PVirtualNode;
  TZPaletteListView=class(TListView)
    procedure ProcessClick(ListItem:TListItem;DblClck:Boolean);

    protected
    MouseDownItem:TListItem;
    DoubleClick:Boolean;
      procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
  end;
  TZPaletteTreeView=class({$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF})
  public
    procedure _GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
    procedure _GetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);
    procedure _FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  end;
  TZPaletteTreeViewFilter=class(TEditButton)
    tree:TZPaletteTreeView;
    procedure PurgeFilter(Sender: TObject);
    procedure CollapseAll(Sender: TObject);
    procedure ExpandAll(Sender: TObject);
  end;

TPaletteHelper=class

class procedure ZPalettevsIconDoubleClick(Sender: TObject);
class function ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
class procedure ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType;treeprefix:string);

class function ZPaletteTreeCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
class procedure ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType;treeprefix:string);
class procedure ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType;treeprefix:string);
class procedure ZPaletteTreeFilter(Sender: TObject);
end;

implementation
procedure TZPaletteTreeView._GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                     TextType: TVSTTextType; var CellText: String);
var
  pnd:PTPaletteTreeNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if column=0 then
    celltext:=pnd^.text
  else
    celltext:=pnd^.command;
end;


procedure TZPaletteTreeView._GetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                      var Ghosted: Boolean; var ImageIndex: Integer);
var
  pnd:PTPaletteTreeNodeData;
begin
  if column=0 then begin
    pnd := Sender.GetNodeData(Node);
    ImageIndex:=pnd^.imageindex;
  end;
end;

procedure TZPaletteTreeView._FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pnd:PTPaletteTreeNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  pnd^.command:='';
  pnd^.text:='';
end;

procedure TZPaletteListView.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
  if Button=mbLeft then
  begin
   MouseDownItem:=GetItemAt(x,y);
   if ssDouble in Shift then
     doubleclick:=true
   else
     doubleclick:=false;
  end;
end;

procedure TZPaletteListView.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
var
   li:TListItem;
begin
     if Button=mbLeft then
     begin
       li:=GetItemAt(x,y);
       if li=MouseDownItem then
         ProcessClick(li,DoubleClick);
     end;
     MouseDownItem:=nil;
     DoubleClick:=false;
end;

procedure TZPaletteListView.ProcessClick(ListItem:TListItem;DblClck:Boolean);
begin
//  if DblClck then
//     ListItem:=ListItem;
end;


class function TPaletteHelper.ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
var
  UlclzdCaption:String;
begin
  result:=TCustomForm(Tform.NewInstance);
  {if result is TWinControl then
    TWinControl(result).DisableAlign;}
  TCustomForm(result).CreateNew(Application);
  if DoDisableAlign then
      TWinControl(result).DisableAutoSizing;
  TCustomForm(result).Name:=aControlName;
  UlclzdCaption:=getAttrValue(TBNode,'Caption',aInternalCaption);
  TCustomForm(result).Caption:=InterfaceTranslate('Palette~'+UlclzdCaption,UlclzdCaption);
  PaletteControl:=TZPaletteListView.Create(result);
  with TZPaletteListView(PaletteControl) do
  begin
    LargeImagesWidth:=getAttrValue(TBNode,'ImagesWidth',64);
    SmallImagesWidth:=LargeImagesWidth;
    LargeImages:=ImagesManager.IconList;
    SmallImages:=ImagesManager.IconList;
    align:=alClient;
    ViewStyle:=vsIcon;
    ReadOnly:=true;
    IconOptions.AutoArrange:=True;
    DragMode:=dmAutomatic;
    Parent:=result;
    BorderStyle:=bsNone;
    OnDblClick:=ZPalettevsIconDoubleClick;
  end;
end;

function Match(pTND:PTPaletteTreeNodeData;pattern:AnsiString):boolean;
begin
  if pTND^.command='' then
    result:=MatchesMask(pTND^.text,pattern)
  else begin
    result:=MatchesMask(pTND^.command,pattern);
    if not result then
      result:=MatchesMask(pTND^.text,pattern);
  end
end;

function DoNode(tree:TZPaletteTreeView;node:PVirtualNode;pattern:AnsiString):boolean;
var
  SubNode:PVirtualNode;
  pTND:PTPaletteTreeNodeData;
  MatchInChildren:boolean;
begin
  result:=false;
  repeat
    SubNode := node.FirstChild;
    if assigned(SubNode) then
      MatchInChildren:=DoNode(tree,SubNode,pattern)
    else
      MatchInChildren:=false;
    if MatchInChildren then
      Tree.Expanded[Node]:=true;
    if pattern='' then
      tree.IsFiltered[node]:=false
    else begin
      pTND:=tree.GetNodeData(node);
      if assigned(pTND) then begin
        if MatchInChildren or Match(pTND,pattern) then begin
          tree.IsFiltered[node]:=false;
          result:=true;
        end else
          tree.IsFiltered[node]:=true;
      end;
    end;
    node:=node.NextSibling;
  until (node=nil)or(node=node.NextSibling);
end;

procedure TZPaletteTreeViewFilter.PurgeFilter(Sender: TObject);
begin
  Text:='';
end;
procedure TZPaletteTreeViewFilter.CollapseAll(Sender: TObject);
begin
  tree.FullCollapse();
end;
procedure TZPaletteTreeViewFilter.ExpandAll(Sender: TObject);
begin
  tree.FullExpand();
end;
class procedure TPaletteHelper.ZPaletteTreeFilter(Sender: TObject);
var
   ZPaletteTreeViewFilter:TZPaletteTreeViewFilter;
   pattern:AnsiString;
begin
  ZPaletteTreeViewFilter:=TZPaletteTreeViewFilter(sender);
  pattern:=ZPaletteTreeViewFilter.Text;
  if pattern<>'' then
    if (pos('*',pattern)=0)and(pos('?',pattern)=0) then
      pattern:='*'+pattern+'*';
  DoNode(ZPaletteTreeViewFilter.tree,ZPaletteTreeViewFilter.tree.RootNode,pattern);
  ZPaletteTreeViewFilter.tree.Invalidate;
end;

class function TPaletteHelper.ZPaletteTreeCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
var
   po:TVTPaintOptions;
   ho:TVTHeaderOptions;
   col1,col2:TVirtualTreeColumn;
   PaletteTreeViewFilter:TZPaletteTreeViewFilter;
   UlclzdCaption:String;
   pnl:TPanel;
   eab,cab:TSpeedButton;
begin
  result:=TCustomForm(Tform.NewInstance);
  {if result is TWinControl then
    TWinControl(result).DisableAlign;}
  TCustomForm(result).CreateNew(Application);
  if DoDisableAlign then
      TWinControl(result).DisableAutoSizing;
  TCustomForm(result).Name:=aControlName;
  UlclzdCaption:=getAttrValue(TBNode,'Caption',aInternalCaption);
  TCustomForm(result).Caption:=InterfaceTranslate('Palette~'+UlclzdCaption,UlclzdCaption);
  pnl:=TPanel.Create(result);
  with pnl do
  begin
    Align:=alTop;
    Parent:=result;
    AutoSize:=True;
    BorderStyle:=bsNone;
  end;
  cab:=TSpeedButton.Create(result);
  with cab do
  begin
    Align:=alRight;
    AutoSize:=True;
    Images:=ImagesManager.IconList;
    ImageIndex:=ImagesManager.GetImageIndex('Plus');
    ShowCaption:=false;
    Flat:=true;
    Parent:=pnl;
  end;
  eab:=TSpeedButton.Create(result);
  with eab do
  begin
    Align:=alRight;
    AutoSize:=True;
    Images:=ImagesManager.IconList;
    ImageIndex:=ImagesManager.GetImageIndex('Minus');
    ShowCaption:=false;
    Flat:=true;
    Parent:=pnl;
  end;
  PaletteTreeViewFilter:=TZPaletteTreeViewFilter.Create(result);
  with PaletteTreeViewFilter do
  begin
    TextHint:=rsFilterHint;
    Edit.BorderStyle:=bsNone;
    Flat:=true;
    align:=alClient;
    Parent:=pnl;
    OnChange:=ZPaletteTreeFilter;
    Button.Images:=ImagesManager.IconList;
    Button.ImageIndex:=ImagesManager.GetImageIndex('purge');
    Button.OnClick:=ZPaletteTreeFilter;
  end;
  PaletteControl:=TZPaletteTreeView.Create(result);
  with TZPaletteTreeView(PaletteControl) do
  begin
    ho:=Header.Options;
    ho:=ho+[hoVisible,hoAutoResize];
    Header.Options:=ho;
    col1:=Header.Columns.Add;
    col1.Text:=rsDescription;
    col1.CaptionAlignment:=taCenter;
    col1.Width:=2;
    col2:=Header.Columns.Add;
    col2.Text:=rsCommand;
    col2.CaptionAlignment:=taCenter;
    col1.Width:=20;

    po:=TreeOptions.PaintOptions;
    po:=po-[toShowFilteredNodes];
    TreeOptions.PaintOptions:=po;

    NodeDataSize:=sizeof(TPaletteTreeNodeData);
    OnGetText:=_GetText;
    OnGetImageIndex:=_GetImage;
    OnFreeNode:=_FreeNode;
    ImagesWidth:=getAttrValue(TBNode,'ImagesWidth',64);
    Images:=ImagesManager.IconList;
    align:=alClient;
    BorderSpacing.Top:=4;
    DragMode:=dmAutomatic;
    Parent:=result;
    BorderStyle:=bsNone;
    OnDblClick:=ZPalettevsIconDoubleClick;
  end;
  PaletteTreeViewFilter.tree:=TZPaletteTreeView(PaletteControl);
  PaletteTreeViewFilter.Button.OnClick:=PaletteTreeViewFilter.PurgeFilter;
  eab.OnClick:=PaletteTreeViewFilter.ExpandAll;
  cab.OnClick:=PaletteTreeViewFilter.CollapseAll;
end;
class procedure TPaletteHelper.ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType;treeprefix:string);
var
  TN:PZPaletteTreeNode;
  pTND:PTPaletteTreeNodeData;
  command,operands:AnsiString;
begin
  TN:=TZPaletteTreeView(palette).AddChild(PZPaletteTreeNode(rootnode),nil);
  pTND:=TZPaletteTreeView(palette).GetNodeData(TN);
  pTND^.Command:=getAttrValue(aNode,'Command','');
  ParseCommand(pTND^.Command,command,operands);
  pTND^.Text:=getAttrValue(aNode,'Caption','');
  if pTND^.Text='' then
    pTND^.Text:=operands
  else
    pTND^.Text:=InterfaceTranslate(palette.Parent.Name+'~caption',pTND^.Text);
  pTND^.ImageIndex:=ImagesManager.GetImageIndex(getAttrValue(aNode,'Img',operands));
end;
class procedure TPaletteHelper.ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType;treeprefix:string);
var
  TN:PZPaletteTreeNode;
  pTND:PTPaletteTreeNodeData;
  TBSubNode:TDomNode;
  imgname:AnsiString;
  cptn:string;
begin
  TN:=TZPaletteTreeView(palette).AddChild(PZPaletteTreeNode(rootnode),nil);
  pTND:=TZPaletteTreeView(palette).GetNodeData(TN);
  cptn:=getAttrValue(aNode,'Caption','');
  if IsLatin(cptn) then
    pTND^.Text:=InterfaceTranslate(palette.Parent.Name+treeprefix+'_itemcaption'+'~'+cptn,cptn)
  else
    pTND^.Text:=cptn;
  imgname:=getAttrValue(aNode,'Img','');
  if imgname<>'' then
    pTND^.ImageIndex:=ImagesManager.GetImageIndex(imgname)
  else
    pTND^.ImageIndex:=-1;
  TBSubNode:=aNode.FirstChild;
  while assigned(TBSubNode)do
  begin
    ToolBarsManager.DoToolPaletteItemCreateFunc(TBSubNode.NodeName,TBSubNode,tpersistent(TN),palette,treeprefix+'_'+cptn);
    TBSubNode:=TBSubNode.NextSibling;
  end;
end;

class procedure TPaletteHelper.ZPalettevsIconDoubleClick(Sender: TObject);
var
    cmd:AnsiString;
    TN:PZPaletteTreeNode;
    pTND:PTPaletteTreeNodeData;
begin
  if Sender is TZPaletteListView then begin
    if TZPaletteListView(Sender).Selected=nil then  exit;
    cmd:=TZPaletteListItem(TZPaletteListView(Sender).Selected).Command;
  end else
  if Sender is TZPaletteTreeView then begin
    if TZPaletteTreeView(Sender).GetFirstSelected=nil then  exit;
    TN:=PZPaletteTreeNode(TZPaletteTreeView(Sender).GetFirstSelected);
    pTND:=TZPaletteTreeView(Sender).GetNodeData(TN);
    cmd:=pTND^.Command;
  end;
  if cmd<>'' then
    commandmanager.executecommandsilent(@cmd[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

class procedure TPaletteHelper.ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType;treeprefix:string);
var
  LI:TZPaletteListItem;
begin
  LI:=TZPaletteListItem.Create(TListView(palette).Items);
  TListView(palette).Items.AddItem(LI);
  LI.Caption:=getAttrValue(aNode,'Caption','');
  LI.Caption:=InterfaceTranslate(palette.Parent.Name+treeprefix+'_itemcaption'+'~'+LI.Caption,LI.Caption);
  LI.ImageIndex:=ImagesManager.GetImageIndex(getAttrValue(aNode,'Img',''));
  LI.Command:=getAttrValue(aNode,'Command','');
end;


initialization
  ToolBarsManager.RegisterPaletteCreateFunc('vsIcon',TPaletteHelper.ZPalettevsIconCreator);
  ToolBarsManager.RegisterPaletteItemCreateFunc('ZVSICommand',TPaletteHelper.ZPalettevsIconItemCreator);
  ToolBarsManager.RegisterPaletteCreateFunc('Tree',TPaletteHelper.ZPaletteTreeCreator);
  ToolBarsManager.RegisterPaletteItemCreateFunc('ZTreeCommand',TPaletteHelper.ZPaletteTreeItemCreator);
  ToolBarsManager.RegisterPaletteItemCreateFunc('ZTreeNode',TPaletteHelper.ZPaletteTreeNodeCreator);
finalization
end.
