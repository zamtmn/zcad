unit uzcfnavigatorentities;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, ComCtrls,
  ActnList, laz.VirtualTrees,
  {uzbtypes,}gzctnrVectorTypes,uzegeometrytypes ,uzegeometry, uzccommandsmanager,
  uzcinterface,uzeentity,uzcimagesmanager,uzcdrawings,
  varmandef,uzbstrproc,uzcnavigatorsnodedesk,LCLVersion;

type

  { TNavigatorEntities }
  TNavigatorEntities = class(TForm)
    CoolBar1: TCoolBar;
    MainToolBar: TToolBar;
    NavTree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
    ToolButton1: TToolButton;
    RefreshToolButton: TToolButton;
    ToolButton3: TToolButton;
    ActionList1:TActionList;
    Refresh:TAction;
    procedure RefreshTree(Sender: TObject);
    procedure AutoRefreshTree(sender:TObject;GUIAction:TzcMessageID);
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
    EntitiesNode:TBaseRootNodeDesk;
    EntitiesNodeStates:TNodesStates;
    NavMX,NavMy:integer;
  public
    CurrentSel:TNodeData;
    LastAutoselectedEnt:PGDBObjEntity;
    procedure CreateRoots;
    procedure EraseRoots;
    procedure FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  end;

var
  NavigatorEntities: TNavigatorEntities;
  NavGroupIconIndex,NavAutoGroupIconIndex:integer;

implementation
{todo: убрать когда TLazVirtualStringTree попадет в релиз лазаря}
{$IF DECLARED(TVirtualStringTree)}{$R olduzcfnavigatorentities.lfm}{$ELSE}{$R *.lfm}{$ENDIF}

{ TNavigatorEntities }
procedure TNavigatorEntities.FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if Assigned(pnd) then
     system.Finalize(pnd^);
end;
procedure TNavigatorEntities.VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  pnd:PTNodeData;
  s:ansistring;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then begin
    CurrentSel:=pnd^;
    if (pnd^.Ident.pent<>nil)and(pnd^.Ident.pent<>LastAutoselectedEnt) then begin
       LastAutoselectedEnt:=pnd^.Ident.pent;
       s:='SelectObjectByAddres('+inttostr(PtrUInt(pnd^.Ident.pent))+')';
       commandmanager.executecommandsilent(s,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
    end;
  end;
end;
procedure TNavigatorEntities._onCreate(Sender: TObject);
begin
   ActionList1.Images:=ImagesManager.IconList;
   MainToolBar.Images:=ImagesManager.IconList;
   Refresh.ImageIndex:=ImagesManager.GetImageIndex('Refresh');

   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   NavTree.Images:=ImagesManager.IconList;
   NavTree.NodeDataSize:=sizeof(TNodeData);
   NavTree.OnFreeNode:=FreeNode;
   NavTree.OnFocusChanged:=VTFocuschanged;

   OnShow:=RefreshTree;

   zcUI.RegisterHandler_GUIAction(AutoRefreshTree);
end;
procedure TNavigatorEntities.RefreshTree(Sender: TObject);
var
  pv:pGDBObjEntity;
  ir:itrec;
begin
   if not isvisible then exit;

   NavTree.BeginUpdate;
   EraseRoots;
   CreateRoots;
   if drawings.GetCurrentDWG<>nil then
   begin
     pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
       if assigned(EntitiesNode)then
         EntitiesNode.ProcessEntity(EntitiesNode.CreateEntityNode,pv,nil,nil);
       pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
     until pv=nil;
   end;

   if assigned(EntitiesNodeStates) then
   begin
   EntitiesNode.RestoreState(EntitiesNodeStates,0);
   freeandnil(EntitiesNodeStates);
   end;
   NavTree.EndUpdate;
end;
procedure TNavigatorEntities.AutoRefreshTree(sender:TObject;GUIAction:TzcMessageID);
begin
  if GUIAction=zcMsgUIActionRebuild then
    RefreshTree(sender);
end;

procedure TNavigatorEntities.TVDblClick(Sender: TObject);
var
  pnode:PVirtualNode;
  pnd:PTNodeData;
  pc:TzePoint3d;
  bb:TBoundingBox;
const
  scale=10;
begin
  pnode:=NavTree.GetNodeAt(NavMX,NavMy);
  if pnode<>nil then
  begin
    pnd:=NavTree.GetNodeData(pnode);
    if pnd<>nil then
    if pnd^.Ident.pent<>nil then
    begin
      pc:=Vertexmorph(pnd^.Ident.pent^.vp.BoundingBox.LBN,pnd^.Ident.pent^.vp.BoundingBox.RTF,0.5);
      bb.LBN:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.Ident.pent^.vp.BoundingBox.LBN),scale));
      bb.RTF:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.Ident.pent^.vp.BoundingBox.RTF),scale));
      drawings.GetCurrentDWG.wa.ZoomToVolume(bb);
    end;
  end;
end;

procedure TNavigatorEntities.TVOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  NavMX:=x;
  NavMy:=y;
end;

procedure TNavigatorEntities.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  Result := 0;
            //AnsiNaturalCompare(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column],False);
end;

procedure TNavigatorEntities.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo
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

procedure TNavigatorEntities.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  celltext:=pnd^.Ident.name
end;
procedure TNavigatorEntities.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
var
  pnd:PTNodeData;
begin
  if NavGroupIconIndex=-1 then
                              NavGroupIconIndex:=ImagesManager.GetImageIndex('navmanualgroup');
  if NavAutoGroupIconIndex=-1 then
                              NavAutoGroupIconIndex:=ImagesManager.GetImageIndex('navautogroup');

  if (assigned(EntitiesNode))and(node=EntitiesNode.RootNode) then
                                       ImageIndex:=EntitiesNode.ficonindex
else
  begin
    pnd := Sender.GetNodeData(Node);
      if assigned(pnd) then
        begin
          case pnd^.NodeMode of
          TNMGroup,TNMHardGroup:ImageIndex:=NavGroupIconIndex;
          TNMAutoGroup:ImageIndex:=NavAutoGroupIconIndex;
          TNMData:begin
                    if pnd^.Ident.pent<>nil then
                                          begin
                                           ImageIndex:=ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.Ident.pent,'ENTID_Representation','bug'));
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

procedure TNavigatorEntities.CreateRoots;
begin
  //CombinedNode:=TRootNodeDesk.Create(self, NavTree);
  //CombinedNode.ftext:='Combined devices';
  //CombinedNode.ficonindex:=ImagesManager.GetImageIndex('caddie');
  EntitiesNode:=TBaseRootNodeDesk.Create(self, NavTree,'Entities');
  EntitiesNode.ficonindex:=ImagesManager.GetImageIndex('basket');
end;

procedure TNavigatorEntities.EraseRoots;
begin
  if assigned(EntitiesNode) then
  begin
    EntitiesNodeStates:=EntitiesNode.SaveState(CurrentSel);
    FreeAndNil(EntitiesNode);
  end;
end;
begin
  NavGroupIconIndex:=-1;
  NavAutoGroupIconIndex:=-1;
end.

