unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees,
  uzccommandsmanager,uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,uzcenitiesvariablesextender,varmandef;

type

  { TNavigator }
  TNodeMode=(TNMGroup,TNMAutoGroup,TNMData);
  PTNodeData=^TNodeData;
  TNodeData=record
    NodeMode:TNodeMode;
    name,id:string;
    pent:PGDBObjEntity;
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
                         pnd^.NodeMode:=TNMAutoGroup;
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
   NavTree.EndUpdate;
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
  StandaloneNode:=TRootNodeDesk.Create(self, NavTree,'Standalone devices');
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

