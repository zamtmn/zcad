unit uzcfnavigatordevices;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, laz.VirtualTrees,
  uzbtypes,gzctnrvectortypes,uzbgeomtypes ,uzegeometry, uzccommandsmanager,
  uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,uzbtypesbase,
  varmandef,uzbstrproc,uzcmainwindow,uzctreenode,
  uzcnavigatorsnodedesk,Varman,uzcstrconsts,uztoolbarsmanager,uzmenusmanager,
  uzccommandsimpl,uzccommandsabstract,uzcutils,uzcenitiesvariablesextender,
  GraphType,generics.collections,uzglviewareaabstract;

resourcestring
  rsByPrefix='byPrefix';
  rsByBase='byBase';
  rsStandaloneDevices='Standalone devices';

type
  TEnt2NodeMap=TDictionary<pGDBObjEntity,PVirtualNode>;
  { TNavigatorDevices }
  TNavigatorDevices = class(TForm)
    CoolBar1: TCoolBar;
    MainToolBar: TToolBar;
    NavTree: TVirtualStringTree;
    Ent2NodeMap:TEnt2NodeMap;
    ToolButton1: TToolButton;
    RefreshToolButton: TToolButton;
    ToolButton3: TToolButton;
    ActionList1:TActionList;
    Refresh:TAction;
    function CreateEntityNode(Tree: TVirtualStringTree;basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;virtual;
    procedure RefreshTree(Sender: TObject);
    procedure AutoRefreshTree(sender:TObject;GUIAction:TZMessageID);
    procedure TVDblClick(Sender: TObject);
    procedure TVOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VTOnContextMenu(Sender: TObject; MousePos: TPoint;
                                 var Handled: Boolean);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);virtual;
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure _onCreate(Sender: TObject);
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);virtual;
    procedure NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);
    procedure getImageindex;
    procedure AfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellRect: TRect);
    procedure DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
        Column: TColumnIndex; const CellText: String; const CellRect: TRect; var DefaultDraw: Boolean) ;
    procedure MeasureTextWidth(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellText: String; var Extent: Integer);
  private
    CombinedNode:TBaseRootNodeDesk;//удаляем ее, ненужно!!!
    CombinedNodeStates:TNodesStates;
    StandaloneNode:TBaseRootNodeDesk;
    StandaloneNodeStates:TNodesStates;
    NavMX,NavMy:integer;
    pref,base:TmyVariableAction;
    GroupByPrefix,GroupByBase:boolean;
    MainFunctionIconIndex:integer;
    BuggyIconIndex:integer;
    SaveCellRectLeft:integer;

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
  MainFunction:pGDBObjEntity;
  mainfuncnode:PVirtualNode;
  pnd:PTNodeData;
begin
  MainFunction:=GetMainFunction(pent);
  if mainfunction<>nil then
  begin
     mainfunction:=mainfunction;
     if Ent2NodeMap.TryGetValue(MainFunction,mainfuncnode) then
       basenode:=mainfuncnode.Parent
     else begin
        StandaloneNode.ProcessEntity(self.CreateEntityNode,MainFunction,EntsFilter,TraceEntity);
        if Ent2NodeMap.TryGetValue(pent,mainfuncnode) then
          basenode:=mainfuncnode.Parent
     end;
     if mainfuncnode<>nil then
     begin
       pnd:=rootdesk.Tree.GetNodeData(mainfuncnode);
       if pnd^.NodeMode<>TNMHardGroup then
         rootdesk.ConvertNameNodeToGroupNode(mainfuncnode);
       pnd^.NodeMode:=TNMHardGroup;
       exit(mainfuncnode);
     end;
  end;

  {procedure TBaseRootNodeDesk.ConvertNameNodeToGroupNode(pnode:PVirtualNode);
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
  end;}

  result:=nil;
  Name:=GetEntityVariableValue(pent,'NMO_Name',rsNameAbsent);

  if GroupByPrefix then begin
    BaseName:=GetEntityVariableValue(pent,'NMO_Prefix',rsPrefixAbsent);
    basenode:=rootdesk.find(BaseName,rootdesk.rootnode);
  end else
    basenode:=rootdesk.rootnode;

  if GroupByBase then begin
    BaseName:=GetEntityVariableValue(pent,'NMO_BaseName',rsBaseNameAbsent);
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
var
  po:TVTPaintOptions;
  //mo:TVTMiscOptions;
  //ts:TVirtualTreeStates;
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
   NavTree.OnAfterCellPaint:=AfterCellPaint;
   NavTree.OnMeasureTextWidth:=MeasureTextWidth;
   NavTree.OnDrawText:=DrawText;
   {ts:=NavTree.TreeStates;
   ts:=ts+[tsUseThemes];
   NavTree.TreeStates:=ts;}
   po:=NavTree.TreeOptions.PaintOptions;
   po:=po-[toShowFilteredNodes,toHideSelection]+[toPopupMode];
   NavTree.TreeOptions.PaintOptions:=po;
   {mo:=NavTree.TreeOptions.MiscOptions;
   mo:=mo+[toGridExtensions];
   NavTree.TreeOptions.MiscOptions:=mo;}
   MainFunctionIconIndex:=-1;
   BuggyIconIndex:=-1;

   OnShow:=RefreshTree;

   NavTree.OnContextPopup:=VTOnContextMenu;

   ZCMsgCallBackInterface.RegisterHandler_GUIAction(AutoRefreshTree);
end;
procedure TNavigatorDevices.AfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellRect: TRect);
var
  pnd:PTNodeData;
  pentvarext:PTVariablesExtender;
  myContentRect:TRect;
begin
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.pent<>nil then
  begin
    pentvarext:=pnd^.pent^.GetExtension(typeof(TVariablesExtender));
    if pentvarext<>nil then begin

    getImageIndex;

    //if CellPaintMode=cpmPaint then begin
      myContentRect:=CellRect;
      myContentRect.Left:=SaveCellRectLeft;

      ImagesManager.IconList.Draw(TargetCanvas,myContentRect.Left,(myContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.pent,'ENTID_Function','bug'),BuggyIconIndex),gdeNormal);
      myContentRect.Left:=myContentRect.Left+ImagesManager.IconList.Width;
      ImagesManager.IconList.Draw(TargetCanvas,myContentRect.Left,(myContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.pent,'ENTID_Representation','bug'),BuggyIconIndex),gdeNormal);
      myContentRect.Left:=myContentRect.Left+ImagesManager.IconList.Width;
    //end;
    end;
  end;
end;
procedure TNavigatorDevices.DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellText: String; const CellRect: TRect; var DefaultDraw: Boolean);
var
  pnd:PTNodeData;
  pentvarext:PTVariablesExtender;
  myCellRect:TRect;
begin
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.pent<>nil then
  begin
    pentvarext:=pnd^.pent^.GetExtension(typeof(TVariablesExtender));
    if pentvarext<>nil then begin
      SaveCellRectLeft:=CellRect.Left;
      myCellRect:=CellRect;
      DefaultDraw:=false;
      myCellRect.Left:=myCellRect.Left+2*ImagesManager.IconList.Width;
      TargetCanvas.TextRect(myCellRect,myCellRect.Left,myCellRect.Top,CellText);
      //DrawText(TargetCanvas.Handle, PChar(Text), Length(Text), CellRect, DrawFormat);
      //ImagesManager.IconList.Draw(TargetCanvas,ContentRect.Left,(ContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.pent,'ENTID_Function','bug'),BuggyIconIndex),gdeNormal);
      //ImagesManager.IconList.Draw(TargetCanvas,ContentRect.Left,(ContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetEntityVariableValue(pnd^.pent,'ENTID_Representation','bug'),BuggyIconIndex),gdeNormal);
    end;
  end;
end;
procedure TNavigatorDevices.MeasureTextWidth(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
Column: TColumnIndex; const CellText: String; var Extent: Integer);
var
  pnd:PTNodeData;
  pentvarext:PTVariablesExtender;
begin
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.pent<>nil then
  begin
    pentvarext:=pnd^.pent^.GetExtension(typeof(TVariablesExtender));
    if pentvarext<>nil then
      Extent:=Extent+2*ImagesManager.IconList.Width;
  end;
end;

function TNavigatorDevices.CreateEntityNode(Tree: TVirtualStringTree;basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;
var
  pnd:PTNodeData;
  pentvarext:PTVariablesExtender;
begin
  result:=StandaloneNode.CreateEntityNode(Tree,basenode,pent,Name);
  pentvarext:=pent^.GetExtension(typeof(TVariablesExtender));
  if pentvarext<>nil then begin
    if pentvarext^.isMainFunction then begin
      pnd:=Tree.GetNodeData(result);
      pnd^.NodeMode:=TNMHardGroup;
    end;
  end;
  Ent2NodeMap.add(pent,result);
end;

procedure TNavigatorDevices.RefreshTree(Sender: TObject);
var
  pv:pGDBObjEntity;
  ir:itrec;
  pb:pboolean;
begin
   if not isvisible then exit;

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
       {if assigned(CombinedNode)then
         CombinedNode.ProcessEntity(pv,EntsFilter,TraceEntity);}
       if assigned(StandaloneNode)then
         StandaloneNode.ProcessEntity(self.CreateEntityNode,pv,EntsFilter,TraceEntity);
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
var
  sender_wa:TAbstractViewArea;
  devnode:PVirtualNode;
begin
  if GUIAction=ZMsgID_GUIActionRebuild then
    RefreshTree(sender);
  if (sender is (TAbstractViewArea))and(GUIAction=ZMsgID_GUIActionSelectionChanged) then begin
    sender_wa:=sender as TAbstractViewArea;
    if sender_wa.param.SelDesc.LastSelectedObject<>nil then begin
      if (pGDBObjEntity(sender_wa.param.SelDesc.LastSelectedObject)^.GetObjType=GDBDeviceID)and(assigned(Ent2NodeMap)) then begin
        if Ent2NodeMap.TryGetValue(sender_wa.param.SelDesc.LastSelectedObject,devnode) then begin
          NavTree.Selected[devnode]:=true;
          NavTree.VisiblePath[devnode]:=true;
          NavTree.ScrollIntoView(devnode,false);
        end;
      end;
    end else begin
      NavTree.ClearSelection;
      if assigned (StandaloneNodeStates) then
        freeandnil(StandaloneNodeStates);
      if assigned (StandaloneNode) then
      StandaloneNodeStates:=StandaloneNode.SaveState;
    end;
  end;
end;
procedure TNavigatorDevices.TVDblClick(Sender: TObject);
var
  pnode:PVirtualNode;
  pnd:PTNodeData;
  pc:gdbvertex;
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
procedure TNavigatorDevices.VTOnContextMenu(Sender: TObject; MousePos: TPoint;
                             var Handled: Boolean);
var
  pnode:PVirtualNode;
  pnd:PTNodeData;
  pc:gdbvertex;
  bb:TBoundingBox;
  PopupMenu:TmyPopupMenu;
begin
  Handled:=true;
  pnode:=NavTree.GetNodeAt(MousePos.X,MousePos.Y);
  if pnode<>nil then
  begin
    NavTree.Selected[pnode]:=true;
    PopupMenu:=TmyPopupMenu(MenusManager.GetMenu_tmp('NAVIGATORNODECONTEXTMENU',nil));
    if assigned(PopupMenu) then begin
      CommandManager.ContextCommandParams:=NavTree;
      PopupMenu.PopUp;
    end;
    {pnd:=NavTree.GetNodeData(pnode);
    if pnd<>nil then
    if pnd^.pent<>nil then
    begin
      pc:=Vertexmorph(pnd^.pent^.vp.BoundingBox.LBN,pnd^.pent^.vp.BoundingBox.RTF,0.5);
      bb.LBN:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.pent^.vp.BoundingBox.LBN),scale));
      bb.RTF:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.pent^.vp.BoundingBox.RTF),scale));
      drawings.GetCurrentDWG.wa.ZoomToVolume(bb);
    end;}
  end;
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
                                   celltext:=GetEntityVariableValue(pnd^.pent,'NMO_Name',rsNameAbsent);
  end;
end;
procedure TNavigatorDevices.getImageIndex;
begin
  if MainFunctionIconIndex=-1 then
    MainFunctionIconIndex:=ImagesManager.GetImageIndex('basket');
  if BuggyIconIndex=-1 then
    BuggyIconIndex:=ImagesManager.GetImageIndex('bug');
  if NavGroupIconIndex=-1 then
                              NavGroupIconIndex:=ImagesManager.GetImageIndex('navmanualgroup');
  if NavAutoGroupIconIndex=-1 then
                              NavAutoGroupIconIndex:=ImagesManager.GetImageIndex('navautogroup');
end;

procedure TNavigatorDevices.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
var
  pnd:PTNodeData;
  pentvarext:PTVariablesExtender;
begin
  getImageIndex;
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
          TNMData,TNMHardGroup:begin
                    if pnd^.pent<>nil then
                                          begin
                                           pentvarext:=pnd^.pent^.GetExtension(typeof(TVariablesExtender));
                                           if pentvarext<>nil then
                                           begin
                                             if pentvarext^.isMainFunction then
                                               ImageIndex:=MainFunctionIconIndex
                                             else
                                               ImageIndex:=-1;
                                           end
                                           else
                                             ImageIndex:=BuggyIconIndex;
                                          end
                    else
                      ImageIndex:=BuggyIconIndex;
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
  Ent2NodeMap:=TEnt2NodeMap.create;
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
  Ent2NodeMap.Free;
end;

procedure SelectSubNodes(nav:TVirtualStringTree;pnode:PVirtualNode);
var
  psubnode:PVirtualNode;
  pnd:PTNodeData;
  i:integer;
  s:string;
begin
  if pnode^.ChildCount>0 then begin
    psubnode:=pnode^.FirstChild;
    for i:=1 to pnode^.ChildCount do begin
      SelectSubNodes(nav,psubnode);
      pnd:=nav.GetNodeData(psubnode);
      if pnd<>nil then
        if ((pnd.NodeMode=TNMData)or(pnd.NodeMode=TNMHardGroup))and(pnd^.pent<>nil) then
          zcSelectEntity(pnd^.pent);
      psubnode:=psubnode^.NextSibling;
    end;
  end;
end;

function NavSelectSubNodes_com(operands:TCommandOperands):TCommandResult;
var
  pnode:PVirtualNode;
  nav:TVirtualStringTree;
begin
     if commandmanager.ContextCommandParams<>nil then begin
       nav:=commandmanager.ContextCommandParams;
       pnode:=nav.GetFirstSelected;
       SelectSubNodes(nav,pnode);
       ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
       result:=cmd_ok;
     end else
       ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
end;

begin
  CreateCommandFastObjectPlugin(@NavSelectSubNodes_com,'NavSelectSubNodes',CADWG,0);
  NavGroupIconIndex:=-1;
  NavAutoGroupIconIndex:=-1;
end.

