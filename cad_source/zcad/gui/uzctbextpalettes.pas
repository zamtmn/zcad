{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE def.inc}
interface
uses
     uzcstrconsts,uzcsysparams,uzcsysvars,uzbtypes,uzcsysinfo,
     uzcinfoform,Varman,uzcinterface,laz.VirtualTrees,
     uzbstrproc,uzeenttext,
     EditBtn,Masks,StdCtrls,Controls,Classes,Forms,uzccommandsmanager,Laz2_DOM,ComCtrls,uztoolbarsmanager,uzxmlnodesutils,uzcimagesmanager,uzctranslations,uzcdrawings;
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
  TZPaletteTreeView=class(TVirtualStringTree)
  public
    procedure _GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
    procedure _GetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);
  end;
  TZPaletteTreeViewFilter=class(TEditButton)
    tree:TZPaletteTreeView;
    procedure PurgeFilter(Sender: TObject);
  end;

TPaletteHelper=class

class procedure ZPalettevsIconDoubleClick(Sender: TObject);
class function ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
class procedure ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);

class function ZPaletteTreeCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
class procedure ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);
class procedure ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent;palette:TPaletteControlBaseType);
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
var i:integer;
begin
  if DblClck then
     ListItem:=ListItem;
end;


class function TPaletteHelper.ZPalettevsIconCreator(aControlName,aInternalCaption,aType: string;TBNode:TDomNode;var PaletteControl:TPaletteControlBaseType;DoDisableAlign:boolean):TPaletteControlBaseType;
begin
  result:=TCustomForm(Tform.NewInstance);
  {if result is TWinControl then
    TWinControl(result).DisableAlign;}
  TCustomForm(result).CreateNew(Application);
  if DoDisableAlign then
      TWinControl(result).DisableAutoSizing;
  TCustomForm(result).Name:=aControlName;
  TCustomForm(result).Caption:=getAttrValue(TBNode,'Caption',aInternalCaption);
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
      node.States:=node.States+[vsExpanded];
    if pattern='' then
      node.States:=node.States-[vsFiltered]
    else begin
      pTND:=tree.GetNodeData(node);
      if assigned(pTND) then begin
          if MatchInChildren or Match(pTND,pattern) then begin
            node.States:=node.States-[vsFiltered];
            result:=true;
          end else
            node.States:=node.States+[vsFiltered]
      end;
    end;
    node:=node.NextSibling;
  until (node=nil)or(node=node.NextSibling);
end;

procedure TZPaletteTreeViewFilter.PurgeFilter(Sender: TObject);
begin
  Text:='';
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
   pTND:PTPaletteTreeNodeData;
   po:TVTPaintOptions;
   mo:TVTMiscOptions;
   ho:TVTHeaderOptions;
   col1,col2:TVirtualTreeColumn;
   PaletteTreeViewFilter:TZPaletteTreeViewFilter;
begin
  result:=TCustomForm(Tform.NewInstance);
  {if result is TWinControl then
    TWinControl(result).DisableAlign;}
  TCustomForm(result).CreateNew(Application);
  if DoDisableAlign then
      TWinControl(result).DisableAutoSizing;
  TCustomForm(result).Name:=aControlName;
  TCustomForm(result).Caption:=getAttrValue(TBNode,'Caption',aInternalCaption);
  PaletteTreeViewFilter:=TZPaletteTreeViewFilter.Create(result);
  with PaletteTreeViewFilter do
  begin
    TextHint:=rsFilterHint;
    Edit.BorderStyle:=bsNone;
    Flat:=true;
    align:=alTop;
    Parent:=result;
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
    ImagesWidth:=getAttrValue(TBNode,'ImagesWidth',64);
    Images:=ImagesManager.IconList;
    align:=alClient;
    DragMode:=dmAutomatic;
    Parent:=result;
    OnDblClick:=ZPalettevsIconDoubleClick;
  end;
  PaletteTreeViewFilter.tree:=TZPaletteTreeView(PaletteControl);
  PaletteTreeViewFilter.Button.OnClick:=PaletteTreeViewFilter.PurgeFilter;
end;
class procedure TPaletteHelper.ZPaletteTreeItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
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
class procedure TPaletteHelper.ZPaletteTreeNodeCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
var
  TN:PZPaletteTreeNode;
  pTND:PTPaletteTreeNodeData;
  TBSubNode:TDomNode;
  imgname:AnsiString;
begin
  TN:=TZPaletteTreeView(palette).AddChild(PZPaletteTreeNode(rootnode),nil);
  pTND:=TZPaletteTreeView(palette).GetNodeData(TN);
  pTND^.Text:=InterfaceTranslate(palette.Parent.Name+'~caption',getAttrValue(aNode,'Caption',''));
  imgname:=getAttrValue(aNode,'Img','');
  if imgname<>'' then
    pTND^.ImageIndex:=ImagesManager.GetImageIndex(imgname)
  else
    pTND^.ImageIndex:=-1;
  TBSubNode:=aNode.FirstChild;
  while assigned(TBSubNode)do
  begin
    ToolBarsManager.DoToolPaletteItemCreateFunc(TBSubNode.NodeName,TBSubNode,tpersistent(TN),palette);
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

class procedure TPaletteHelper.ZPalettevsIconItemCreator(aNode: TDomNode;rootnode:TPersistent; palette:TPaletteControlBaseType);
var
  LI:TZPaletteListItem;
begin
  LI:=TZPaletteListItem.Create(TListView(palette).Items);
  TListView(palette).Items.AddItem(LI);
  LI.Caption:=getAttrValue(aNode,'Caption','');
  LI.Caption:=InterfaceTranslate(palette.Parent.Name+'~caption',LI.Caption);
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
