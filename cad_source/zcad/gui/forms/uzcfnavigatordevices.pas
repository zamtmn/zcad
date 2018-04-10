unit uzcfnavigatordevices;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees,
  uzbtypes,gzctnrvectortypes,uzbgeomtypes ,uzegeometry, uzccommandsmanager,
  uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,
  varmandef,uzbstrproc,uzcmainwindow,uzctreenode,
  uzcnavigatorsnodedesk,Varman;

resourcestring
  rsByPrefix='byPrefix';
  rsByBase='byBase';
  rsStandaloneDevices='Standalone devices';

type
  { TNavigatorDevices }
  TNavigatorDevices = class(TForm)
    CoolBar1: TCoolBar;
    MainToolBar: TToolBar;
    NavTree: TVirtualStringTree;
    ToolButton1: TToolButton;
    RefreshToolButton: TToolButton;
    ToolButton3: TToolButton;
    ActionList1:TActionList;
    Refresh:TAction;
    procedure RefreshTree(Sender: TObject);
    procedure AutoRefreshTree(sender:TObject;GUIAction:TZMessageID);
    procedure TVDblClick(Sender: TObject);
    procedure TVOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);virtual;
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure _onCreate(Sender: TObject);
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);virtual;
    procedure NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);

  private
    CombinedNode:TBaseRootNodeDesk;
    CombinedNodeStates:TNodesStates;
    StandaloneNode:TBaseRootNodeDesk;
    StandaloneNodeStates:TNodesStates;
    NavMX,NavMy:integer;
    pref,base:TmyVariableAction;
    GroupByPrefix,GroupByBase:boolean;

  public
    procedure CreateRoots;
    procedure EraseRoots;
    procedure FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);

    function EntsFilter(pent:pGDBObjEntity):Boolean;virtual;
    function TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;virtual;
  end;

var
  NavigatorDevices: TNavigatorDevices;
  NavGroupIconIndex,NavAutoGroupIconIndex:integer;

implementation

{$R *.lfm}

function TNavigatorDevices.EntsFilter(pent:pGDBObjEntity):Boolean;
begin
  result:=pent^.GetObjType=GDBDeviceID;
end;

function  TNavigatorDevices.TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;
var
  BaseName:string;
  basenode:PVirtualNode;
begin
  result:=nil;
  Name:=GetEntityVariableValue(pent,'NMO_Name','Absent Name');

  if GroupByPrefix then begin
    BaseName:=GetEntityVariableValue(pent,'NMO_Prefix','Absent Prefix');
    basenode:=rootdesk.find(BaseName,rootdesk.rootnode);
  end else
    basenode:=rootdesk.rootnode;

  if GroupByBase then begin
    BaseName:=GetEntityVariableValue(pent,'NMO_BaseName','Absent BaseName');
    result:=rootdesk.find(BaseName,basenode);
  end else
    result:=basenode;
end;


{ TNavigatorDevices }
procedure TNavigatorDevices.FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if Assigned(pnd) then
     system.Finalize(pnd^);
end;
procedure TNavigatorDevices.VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
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
  end;
end;
procedure TNavigatorDevices._onCreate(Sender: TObject);
begin
   pref:=TmyVariableAction.Create(self);
   pref.ActionList:=ZCADMainWindow.StandartActions;
   pref.AssignToVar('DSGN_NavigatorsGroupByPrefix',0);
   pref.Caption:=rsByPrefix;
   ToolButton1.Action:=pref;

   base:=TmyVariableAction.Create(self);
   base.ActionList:=ZCADMainWindow.StandartActions;
   base.AssignToVar('DSGN_NavigatorsGroupByBaseName',0);
   base.Caption:=rsByBase;
   ToolButton3.Action:=base;

   ActionList1.Images:=ImagesManager.IconList;
   MainToolBar.Images:=ImagesManager.IconList;
   Refresh.ImageIndex:=ImagesManager.GetImageIndex('Refresh');

   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   NavTree.Images:=ImagesManager.IconList;
   NavTree.NodeDataSize:=sizeof(TNodeData);
   NavTree.OnFreeNode:=FreeNode;
   NavTree.OnFocusChanged:=VTFocuschanged;
   NavTree.OnCompareNodes:=VTCompareNodes;

   ZCMsgCallBackInterface.RegisterHandler_GUIAction(AutoRefreshTree);
end;
procedure TNavigatorDevices.RefreshTree(Sender: TObject);
var
  pv:pGDBObjEntity;
  ir:itrec;
  pb:pboolean;
begin
   NavTree.BeginUpdate;
   EraseRoots;
   CreateRoots;

   pb:=SysVarUnit.FindValue('DSGN_NavigatorsGroupByPrefix');
   if pb<>nil then
     GroupByPrefix:=pb^
   else
     GroupByPrefix:=true;

   pb:=SysVarUnit.FindValue('DSGN_NavigatorsGroupByBaseName');
   if pb<>nil then
     GroupByBase:=pb^
   else
     GroupByBase:=true;

   if drawings.GetCurrentDWG<>nil then
   begin
     pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
       if assigned(CombinedNode)then
         CombinedNode.ProcessEntity(pv,EntsFilter,TraceEntity);
       if assigned(StandaloneNode)then
         StandaloneNode.ProcessEntity(pv,EntsFilter,TraceEntity);
       pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
     until pv=nil;
   end;

   if assigned(StandaloneNodeStates) then
   begin
   StandaloneNode.RestoreState(StandaloneNodeStates);
   freeandnil(StandaloneNodeStates);
   end;
   NavTree.EndUpdate;
end;
procedure TNavigatorDevices.AutoRefreshTree(sender:TObject;GUIAction:TZMessageID);
begin
  if GUIAction=ZMsgID_GUIActionRebuild then
    RefreshTree(sender);
end;

procedure TNavigatorDevices.TVDblClick(Sender: TObject);
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

procedure TNavigatorDevices.TVOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  NavMX:=x;
  NavMy:=y;
end;

procedure TNavigatorDevices.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  Result := //WideCompareStr(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column]);
            AnsiNaturalCompare(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column],False);
end;

procedure TNavigatorDevices.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo
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

procedure TNavigatorDevices.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
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
procedure TNavigatorDevices.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
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

procedure TNavigatorDevices.CreateRoots;
begin
  //CombinedNode:=TRootNodeDesk.Create(self, NavTree);
  //CombinedNode.ftext:='Combined devices';
  //CombinedNode.ficonindex:=ImagesManager.GetImageIndex('caddie');
  StandaloneNode:=TBaseRootNodeDesk.Create(self, NavTree,rsStandaloneDevices);
  StandaloneNode.ficonindex:=ImagesManager.GetImageIndex('basket');
end;

procedure TNavigatorDevices.EraseRoots;
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

