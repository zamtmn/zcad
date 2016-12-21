unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees,
  uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,uzcenitiesvariablesextender,varmandef;

type

  { TNavigator }
  PTNodeData=^TNodeData;
  TNodeData=record
    pent:PGDBObjEntity;
  end;

  TRootNodeDesk=class(Tcomponent)
    public
    RootNode:PVirtualNode;
    Tree: TVirtualStringTree;
    ftext:string;
    ficonindex:integer;
    constructor Create(AOwner:TComponent; ATree: TVirtualStringTree);
    destructor Destroy;override;
    procedure ProcessEntity(pent:pGDBObjEntity);
  end;

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
    CombinedNode:TRootNodeDesk;
    StandaloneNode:TRootNodeDesk;
  public
    procedure CreateRoots;
    procedure EraseRoots;
    procedure FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  end;

var
  Navigator: TNavigator;

implementation

{$R *.lfm}

{ TNavigator }
function GetEntityVariableValue(const pent:pGDBObjEntity;varname,defvalue:string):string;
var
  pentvarext:PTVariablesExtender;
  pvd:pvardesk;
begin
  result:=defvalue;
  pentvarext:=pent^.GetExtension(typeof(TVariablesExtender));
  if pentvarext<>nil then
  begin
       pvd:=pentvarext^.entityunit.FindVariable(varname);
       if pvd<>nil then
                       result:=pvd.data.PTD^.GetValueAsString(pvd.data.Instance);
  end;
end;

procedure TRootNodeDesk.ProcessEntity(pent:pGDBObjEntity);
var
  pentvarext:PTVariablesExtender;
  pvd:pvardesk;
  BaseName:string;
  pnode:PVirtualNode;
  pnd:PTNodeData;
begin
  if pent^.GetObjType=GDBDeviceID then
  begin
  BaseName:=GetEntityVariableValue(pent,'NMO_BaseName','Absent BaseName');
  BaseName:=GetEntityVariableValue(pent,'NMO_Name','Absent Name');
  pnode:=Tree.AddChild(rootnode,nil);
  pnd := Tree.GetNodeData(pnode);
  if Assigned(pnd) then
                      pnd^.pent:=pent;
  end;
end;
constructor TRootNodeDesk.create(AOwner:TComponent; ATree: TVirtualStringTree);
begin
   inherited create(AOwner);
   Tree:=ATree;
   RootNode:=ATree.AddChild(nil,nil);
end;
destructor TRootNodeDesk.Destroy;
begin
   tree.DeleteNode(RootNode);
   RootNode:=nil;
   inherited;
end;
procedure TNavigator.FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if Assigned(pnd) then
     system.Finalize(pnd^);
end;
procedure TNavigator.VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
    if pnd^.pent<>nil then
  begin
   pnd^.pent.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
   if assigned(redrawoglwndproc) then redrawoglwndproc;
  end;
end;
procedure TNavigator._onCreate(Sender: TObject);
begin
   ActionList1.Images:=ImagesManager.IconList;
   MainToolBar.Images:=ImagesManager.IconList;
   Refresh.ImageIndex:=ImagesManager.GetImageIndex('Refresh');

   //CombinedNode:=nil;
   //StandaloneNode:=nil;

   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   NavTree.Images:=ImagesManager.IconList;
   NavTree.NodeDataSize:=sizeof(TNodeData);
   NavTree.OnFreeNode:=FreeNode;
   NavTree.OnFocusChanged:=VTFocuschanged;
end;
procedure TNavigator.RefreshTree(Sender: TObject);
var
  pv:pGDBObjEntity;
  ir:itrec;
begin
   NavTree.BeginUpdate;
   EraseRoots;
   CreateRoots;
   pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pv<>nil then
   repeat
     if assigned(CombinedNode)then
       CombinedNode.ProcessEntity(pv);
     if assigned(StandaloneNode)then
       StandaloneNode.ProcessEntity(pv);
     pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
   until pv=nil;
   NavTree.EndUpdate;
end;

procedure TNavigator.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
     if (assigned(CombinedNode))and(node=CombinedNode.RootNode) then
                                       celltext:=CombinedNode.ftext
else if (assigned(StandaloneNode))and(node=StandaloneNode.RootNode) then
                                       celltext:=StandaloneNode.ftext
else
  begin
    pnd := Sender.GetNodeData(Node);
    if assigned(pnd) then
      if pnd^.pent<>nil then
       celltext:=GetEntityVariableValue(pnd^.pent,'NMO_Name','Absent Name');
  end;
end;
procedure TNavigator.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
begin
     if (assigned(CombinedNode))and(node=CombinedNode.RootNode) then
                                       ImageIndex:=CombinedNode.ficonindex
else if (assigned(StandaloneNode))and(node=StandaloneNode.RootNode) then
                                       ImageIndex:=StandaloneNode.ficonindex
else
  begin
    ImageIndex:=1;
  end;
end;

procedure TNavigator.CreateRoots;
begin
  //CombinedNode:=TRootNodeDesk.Create(self, NavTree);
  //CombinedNode.ftext:='Combined devices';
  //CombinedNode.ficonindex:=ImagesManager.GetImageIndex('caddie');
  StandaloneNode:=TRootNodeDesk.Create(self, NavTree);
  StandaloneNode.ftext:='Standalone devices';
  StandaloneNode.ficonindex:=ImagesManager.GetImageIndex('basket');
end;

procedure TNavigator.EraseRoots;
begin
  if assigned(CombinedNode) then
    FreeAndNil(CombinedNode);
  if assigned(StandaloneNode) then
  FreeAndNil(StandaloneNode);
end;

end.

