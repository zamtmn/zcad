unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees, gvector,
  gzctnrvectortypes,uzbgeomtypes ,uzegeometry, uzccommandsmanager,uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,uzcenitiesvariablesextender,varmandef;

type

  { TNavigator }
  TNodeMode=(TNMGroup,TNMAutoGroup,TNMData);
  PTNodeData=^TNodeData;
  TNodeData=record
    NodeMode:TNodeMode;
    name,id:string;
    pent:PGDBObjEntity;
  end;
  TNodesStatesVector=tvector<TNodeData>;
  TNodesStates=class
      OpenedNodes:TNodesStatesVector;
      constructor Create;
      destructor Destroy;override;
  end;
  TRootNodeDesk=class(Tcomponent)
    public
    RootNode:PVirtualNode;
    Tree: TVirtualStringTree;
    ficonindex:integer;
    constructor Create(AOwner:TComponent; ATree: TVirtualStringTree; AName:string);
    destructor Destroy;override;
    procedure ProcessEntity(pent:pGDBObjEntity);
    procedure ConvertNameNodeToGroupNode(pnode:PVirtualNode);
    function FindGroupNodeById(RootNode:PVirtualNode;id:string):PVirtualNode;
    function FindGroupNodeByName(RootNode:PVirtualNode;Name:string):PVirtualNode;
    function SaveState:TNodesStates;
    procedure RecursiveSaveState(Node:PVirtualNode;NodesStates:TNodesStates);
    procedure RestoreState(State:TNodesStates);
    procedure RecursiveRestoreState(Node:PVirtualNode;var StartInNodestates:integer;NodesStates:TNodesStates);
    //function FindGroupNodeById(RootNode:PVirtualNode;id:string):PVirtualNode;
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
    procedure TVDblClick(Sender: TObject);
    procedure TVOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure _onCreate(Sender: TObject);
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
    procedure NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);

  private
    CombinedNode:TRootNodeDesk;
    CombinedNodeStates:TNodesStates;
    StandaloneNode:TRootNodeDesk;
    StandaloneNodeStates:TNodesStates;
    NavMX,NavMy:integer;
  public
    procedure CreateRoots;
    procedure EraseRoots;
    procedure FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  end;

var
  Navigator: TNavigator;
  NavGroupIconIndex,NavAutoGroupIconIndex:integer;

implementation

{$R *.lfm}

{ TNavigator }
constructor TNodesStates.Create;
begin
  OpenedNodes:=TNodesStatesVector.create;
end;
destructor TNodesStates.Destroy;
begin
  OpenedNodes.Destroy;
end;
procedure TRootNodeDesk.RecursiveSaveState(Node:PVirtualNode;NodesStates:TNodesStates);
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  if vsExpanded in Node.states then
  begin
    pnd:=Tree.GetNodeData(Node);
    if pnd<>nil then
      NodesStates.OpenedNodes.PushBack(pnd^);
  end;
  child:=Node^.FirstChild;
  while child<>nil do
  begin
   RecursiveSaveState(child,NodesStates);
   child:=child^.NextSibling;
  end;
end;
function TRootNodeDesk.SaveState:TNodesStates;
begin
  result:=TNodesStates.create;
  RecursiveSaveState(RootNode,result);
end;
function findin(pnd:PTNodeData;var StartInNodestates:integer;NodesStates:TNodesStates):boolean;
var
  i:integer;
  deb:TNodeData;
begin
  for i:={StartInNodestates+1}0 to NodesStates.OpenedNodes.Size-1 do
  begin
  deb:=NodesStates.OpenedNodes[i];
  if (pnd^.id=deb.id)
  and(pnd^.name=deb.name)
  and(pnd^.NodeMode=deb.NodeMode)
  and(pnd^.pent=deb.pent)then
   begin
    StartInNodestates:=i;
    exit(true);
   end;
  end;
    result:=false;
end;

procedure TRootNodeDesk.RecursiveRestoreState(Node:PVirtualNode;var StartInNodestates:integer;NodesStates:TNodesStates);
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  pnd:=Tree.GetNodeData(Node);
  if pnd<>nil then
  begin
    if findin(pnd,StartInNodestates,NodesStates) then
    Tree.Expanded[Node]:=true;
      //Node^.Expand(True);
      //Node.states:=Node.states+[vsExpanded];
  end;
  if StartInNodestates=NodesStates.OpenedNodes.Size then
                                                        exit;
  child:=Node^.FirstChild;
  while child<>nil do
  begin
   RecursiveRestoreState(child,StartInNodestates,NodesStates);
   child:=child^.NextSibling;
  end;
end;
procedure TRootNodeDesk.RestoreState(State:TNodesStates);
var
  StartInNodestates:integer;
begin
  StartInNodestates:=-1;
  RecursiveRestoreState(RootNode,StartInNodestates,State);
end;
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
function TRootNodeDesk.FindGroupNodeById(RootNode:PVirtualNode;id:string):PVirtualNode;
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  child:=RootNode^.FirstChild;
  while child<>nil do
  begin
    pnd := Tree.GetNodeData(child);
    if Assigned(pnd) then
    if pnd^.id=id then
                      system.Break;
   child:=child^.NextSibling;
  end;
  result:=child;
end;
function TRootNodeDesk.FindGroupNodeByName(RootNode:PVirtualNode;Name:string):PVirtualNode;
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  child:=RootNode^.FirstChild;
  while child<>nil do
  begin
    pnd := Tree.GetNodeData(child);
    if Assigned(pnd) then
    if pnd^.Name=Name then
                      system.Break;
   child:=child^.NextSibling;
  end;
  result:=child;
end;
procedure TRootNodeDesk.ConvertNameNodeToGroupNode(pnode:PVirtualNode);
var
  pnewnode:PVirtualNode;
  pnd,pnewnd:PTNodeData;
begin
    if pnode^.FirstChild<>nil then
                                  exit;
    pnewnode:=Tree.AddChild(pnode,nil);
    pnd:=Tree.GetNodeData(pnode);
    pnewnd:=Tree.GetNodeData(pnewnode);
    if (pnewnd<>nil)and(pnd<>nil) then
     pnewnd^:=pnd^;
    pnd^.NodeMode:=TNMAutoGroup;
    pnd^.pent:=nil;
end;

procedure TRootNodeDesk.ProcessEntity(pent:pGDBObjEntity);
var
  BaseName,Name:string;
  basenode,namenode,pnode:PVirtualNode;
  pnd:PTNodeData;
begin
  if pent^.GetObjType=GDBDeviceID then
  begin
  BaseName:=GetEntityVariableValue(pent,'NMO_BaseName','Absent BaseName');
  Name:=GetEntityVariableValue(pent,'NMO_Name','Absent Name');
  basenode:=FindGroupNodeById(rootnode,BaseName);
  if basenode=nil then
  begin
    basenode:=Tree.AddChild(rootnode,nil);
    pnd:=Tree.GetNodeData(basenode);
    if Assigned(pnd) then
                       begin
                         pnd^.NodeMode:=TNMGroup;
                         pnd^.id:=BaseName;
                         pnd^.name:=BaseName;
                       end;
  end;
  namenode:=FindGroupNodeByName(basenode,Name);
  if namenode<>nil then
                       begin
                         ConvertNameNodeToGroupNode(namenode);
                         basenode:=namenode;
                       end;
  pnode:=Tree.AddChild(basenode,nil);
  pnd := Tree.GetNodeData(pnode);
  if Assigned(pnd) then
                      begin
                      pnd^.NodeMode:=TNMData;
                      pnd^.pent:=pent;
                      pnd^.id:=Name;
                      pnd^.name:=Name;
                      end;
  end;
end;
constructor TRootNodeDesk.create(AOwner:TComponent; ATree: TVirtualStringTree; AName:string);
var
   pnd:PTNodeData;
begin
   inherited create(AOwner);
   Tree:=ATree;
   RootNode:=ATree.AddChild(nil,nil);
   pnd := Tree.GetNodeData(RootNode);
   if Assigned(pnd) then
   begin
      pnd^.NodeMode:=TNMGroup;
      pnd^.name:=AName;
   end;
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
  s:ansistring;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
    if pnd^.pent<>nil then
  begin
   s:='SelectObjectByAddres('+inttostr(GDBPlatformUInt(pnd^.pent))+')';
   commandmanager.executecommandsilent(@s[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
   //pnd^.pent.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
   //if assigned(redrawoglwndproc) then redrawoglwndproc;
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
   if drawings.GetCurrentDWG<>nil then
   begin
     pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
       if assigned(CombinedNode)then
         CombinedNode.ProcessEntity(pv);
       if assigned(StandaloneNode)then
         StandaloneNode.ProcessEntity(pv);
       pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
     until pv=nil;
   end;

   if assigned(StandaloneNodeStates) then
   begin
   StandaloneNode.RestoreState(StandaloneNodeStates);
   freeandnil(StandaloneNodeStates);
   end;
   NavTree.EndUpdate;
   //NavTree.UpdateRanges;
end;

procedure TNavigator.TVDblClick(Sender: TObject);
var
  pnode:PVirtualNode;
  pnd:PTNodeData;
  pc,pp:gdbvertex;
  bb:TBoundingBox;
const
  scale=10;
begin
  pnode:=NavTree.GetNodeAt(NavMX,NavMy);
  if pnode<>nil then
  begin
    pnd:=NavTree.GetNodeData(pnode);
    if pnd<>nil then
    if pnd^.pent<>nil then
    begin
      pc:=Vertexmorph(pnd^.pent^.vp.BoundingBox.LBN,pnd^.pent^.vp.BoundingBox.RTF,0.5);
      bb.LBN:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.pent^.vp.BoundingBox.LBN),scale));
      bb.RTF:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.pent^.vp.BoundingBox.RTF),scale));
      drawings.GetCurrentDWG.wa.ZoomToVolume(bb);
    end;
  end;
end;

procedure TNavigator.TVOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  NavMX:=x;
  NavMy:=y;
end;

procedure TNavigator.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  Result := WideCompareStr(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column]);
end;

procedure TNavigator.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo
  );
begin
  if HitInfo.Button = mbLeft then
  begin
    // Меняем индекс сортирующей колонки на индекс колонки,
    // которая была нажата.
    NavTree.Header.SortColumn := HitInfo.Column;
    // Сортируем всё дерево относительно этой колонки
    // и изменяем порядок сортировки на противополжный
    if NavTree.Header.SortDirection = sdAscending then
    begin
      NavTree.Header.SortDirection := sdDescending;
      NavTree.SortTree(HitInfo.Column, NavTree.Header.SortDirection);
    end
    else begin
      NavTree.Header.SortDirection := sdAscending;
      NavTree.SortTree(HitInfo.Column, NavTree.Header.SortDirection);
    end;
  end;
end;

procedure TNavigator.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
  begin
     if pnd^.NodeMode<>TNMData then
                                   celltext:=pnd^.name
                               else
                                   celltext:=GetEntityVariableValue(pnd^.pent,'NMO_Name','Absent Name');
  end;
end;
procedure TNavigator.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
var
  pnd:PTNodeData;
begin
  if NavGroupIconIndex=-1 then
                              NavGroupIconIndex:=ImagesManager.GetImageIndex('navmanualgroup');
  if NavAutoGroupIconIndex=-1 then
                              NavAutoGroupIconIndex:=ImagesManager.GetImageIndex('navautogroup');

     if (assigned(CombinedNode))and(node=CombinedNode.RootNode) then
                                       ImageIndex:=CombinedNode.ficonindex
else if (assigned(StandaloneNode))and(node=StandaloneNode.RootNode) then
                                       ImageIndex:=StandaloneNode.ficonindex
else
  begin
    pnd := Sender.GetNodeData(Node);
      if assigned(pnd) then
        begin
          case pnd^.NodeMode of
          TNMGroup:ImageIndex:=NavGroupIconIndex;
          TNMAutoGroup:ImageIndex:=NavAutoGroupIconIndex;
          TNMData:begin
                    if pnd^.pent<>nil then
                                          begin
                                           ImageIndex:=ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.pent,'ENTID_Type','bug'));
                                          end
                    else
                      ImageIndex:=3;
                  end;
          end;
        end
      else
        ImageIndex:=1;
  end;
end;

procedure TNavigator.CreateRoots;
begin
  //CombinedNode:=TRootNodeDesk.Create(self, NavTree);
  //CombinedNode.ftext:='Combined devices';
  //CombinedNode.ficonindex:=ImagesManager.GetImageIndex('caddie');
  StandaloneNode:=TRootNodeDesk.Create(self, NavTree,'Standalone devices');
  StandaloneNode.ficonindex:=ImagesManager.GetImageIndex('basket');
end;

procedure TNavigator.EraseRoots;
begin
  if assigned(CombinedNode) then
  begin
    CombinedNodeStates:=CombinedNode.SaveState;
    FreeAndNil(CombinedNode);
  end;
  if assigned(StandaloneNode) then
  begin
    StandaloneNodeStates:=StandaloneNode.SaveState;
    FreeAndNil(StandaloneNode);
  end;
end;
begin
  NavGroupIconIndex:=-1;
  NavAutoGroupIconIndex:=-1;
end.

