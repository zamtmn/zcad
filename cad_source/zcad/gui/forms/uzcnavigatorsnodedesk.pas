unit uzcnavigatorsnodedesk;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, laz.VirtualTrees, gvector,
  uzegeometry, uzccommandsmanager,
  uzcinterface,uzeentity,uzcimagesmanager,
  uzcenitiesvariablesextender,varmandef,uzbstrproc,uzcmainwindow,uzctreenode,
  Varman,uzcoimultiproperties;
type
  TExtColumnParams=record
    Pattern:string;
    SaveWidthVar:string;
  end;
  TExtColumnsParams=array of TExtColumnParams;
  PTExtTreeParam=^TExtTreeParam;
  TExtTreeParam=record
    ExtColumnsParams:TExtColumnsParams;
  end;


  TCreateEntityNodeFunc=function(Tree: TVirtualStringTree;basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode of object;
  TBaseRootNodeDesk=class;
  TFilterEntityProc=function(pent:pGDBObjEntity):Boolean of object;
  TTraceEntityProc=function(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode of object;
  TNodeMode=(TNMGroup,TNMAutoGroup,TNMData,TNMHardGroup);
  PTNodeData=^TNodeData;
  TNodeData=record
    NodeMode:TNodeMode;
    name,id:string;
    pent:PGDBObjEntity;
  end;
  TNodesStatesVector=tvector<TNodeData>;
  TNodesStates=class
      OpenedNodes:TNodesStatesVector;
      SelectedNode:TNodeData;
      constructor Create;
      destructor Destroy;override;
  end;
  TFindFunc=function(pnd:Pointer; Criteria:string):boolean of object;
  TBaseRootNodeDesk=class(Tcomponent)
    public
    RootNode:PVirtualNode;
    Tree: TVirtualStringTree;
    ficonindex:integer;
    function FindById(pnd:Pointer; Criteria:string):boolean;
    function FindByName(pnd:Pointer; Criteria:string):boolean;
    constructor Create(AOwner:TComponent; ATree: TVirtualStringTree; AName:string);overload;
    destructor Destroy;override;
    function find(BaseName:string;basenode:PVirtualNode):PVirtualNode;
    procedure ProcessEntity(CreateEntityNode:TCreateEntityNodeFunc;pent:pGDBObjEntity;filterproc:TFilterEntityProc;traceproc:TTraceEntityProc);
    function CreateEntityNode(Tree: TVirtualStringTree;basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;virtual;
    procedure ConvertNameNodeToGroupNode(pnode:PVirtualNode);
    function FindGroupNodeBy(RootNode:PVirtualNode;criteria:string;func:TFindFunc):PVirtualNode;
    function SaveState:TNodesStates;
    procedure RecursiveSaveState(Node:PVirtualNode;NodesStates:TNodesStates);
    procedure RestoreState(State:TNodesStates);
    procedure RecursiveRestoreState(Node:PVirtualNode;var StartInNodestates:integer;NodesStates:TNodesStates);

    //function FilterEntity(pent:pGDBObjEntity):Boolean;virtual;
    function DefaultTraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;virtual;
  end;

function GetEntityVariableValue(const pent:pGDBObjEntity;varname,defvalue:string):string;
function GetMainFunction(const pent:pGDBObjEntity):pGDBObjEntity;

implementation

function GetMainFunction(const pent:pGDBObjEntity):pGDBObjEntity;
var
  pentvarext:TVariablesExtender;
  //pvd:pvardesk;
begin
  pentvarext:=pent^.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then
    result:=pentvarext.pMainFuncEntity
  else
    result:=nil;
end;

function GetEntityVariableValue(const pent:pGDBObjEntity;varname,defvalue:string):string;
var
  pentvarext:TVariablesExtender;
  pvd:pvardesk;
begin
  result:=defvalue;
  pentvarext:=pent^.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then
  begin
       pvd:=pentvarext.entityunit.FindVariable(varname);
       if pvd<>nil then
                       result:=pvd.data.PTD^.GetValueAsString(pvd.data.Addr.Instance);
  end;
end;


function TBaseRootNodeDesk.FindById(pnd:Pointer; Criteria:string):boolean;
begin
  if PTNodeData(pnd)^.NodeMode<>TNMHardGroup then
    result:=PTNodeData(pnd)^.id=Criteria
  else
    result:=false;
end;
function TBaseRootNodeDesk.FindByName(pnd:Pointer; Criteria:string):boolean;
begin
  if PTNodeData(pnd)^.NodeMode<>TNMHardGroup then
    result:=PTNodeData(pnd)^.name=Criteria
  else
    result:=false;
end;

{ TNavigatorDevices }
constructor TNodesStates.Create;
begin
  OpenedNodes:=TNodesStatesVector.create;
  SelectedNode.id:='';
  SelectedNode.name:='';
  SelectedNode.pent:=nil;
end;
destructor TNodesStates.Destroy;
begin
  OpenedNodes.Destroy;
end;
procedure TBaseRootNodeDesk.RecursiveSaveState(Node:PVirtualNode;NodesStates:TNodesStates);
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  pnd:=Tree.GetNodeData(Node);
  if pnd<>nil then
  begin
    if vsExpanded in Node.states then
      NodesStates.OpenedNodes.PushBack(pnd^);
    if Tree.Selected[Node]then
      NodesStates.SelectedNode:=pnd^;
  end;
  child:=Node^.FirstChild;
  while child<>nil do
  begin
   RecursiveSaveState(child,NodesStates);
   child:=child^.NextSibling;
  end;
end;
function TBaseRootNodeDesk.SaveState:TNodesStates;
begin
  result:=TNodesStates.create;
  RecursiveSaveState(RootNode,result);
end;
function findin(pnd:PTNodeData;var StartInNodestates:integer;NodesStates:TNodesStates):boolean;
var
  i:integer;
  deb:TNodeData;
begin
  for i:=0 to NodesStates.OpenedNodes.Size-1 do
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

procedure TBaseRootNodeDesk.RecursiveRestoreState(Node:PVirtualNode;var StartInNodestates:integer;NodesStates:TNodesStates);
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  pnd:=Tree.GetNodeData(Node);
  if pnd<>nil then
  begin
    if findin(pnd,StartInNodestates,NodesStates) then
      Tree.Expanded[Node]:=true;
    if (pnd.pent=NodesStates.SelectedNode.pent)
    and(pnd.name=NodesStates.SelectedNode.name)
    and(pnd.id=NodesStates.SelectedNode.id) then
      Tree.AddToSelection(Node);
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
procedure TBaseRootNodeDesk.RestoreState(State:TNodesStates);
var
  StartInNodestates:integer;
begin
  StartInNodestates:=-1;
  RecursiveRestoreState(RootNode,StartInNodestates,State);
end;
function TBaseRootNodeDesk.FindGroupNodeBy(RootNode:PVirtualNode;criteria:string;func:TFindFunc):PVirtualNode;
var
  child:PVirtualNode;
  pnd:PTNodeData;
begin
  child:=RootNode^.FirstChild;
  while child<>nil do
  begin
    pnd := Tree.GetNodeData(child);
    if Assigned(pnd) then
    if func(pnd,criteria) then
                      system.Break;
   child:=child^.NextSibling;
  end;
  result:=child;
end;

procedure TBaseRootNodeDesk.ConvertNameNodeToGroupNode(pnode:PVirtualNode);
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

function TBaseRootNodeDesk.find(BaseName:string;basenode:PVirtualNode):PVirtualNode;
var
  pnd:PTNodeData;
begin
    result:=FindGroupNodeBy(basenode,BaseName,FindById);
    if result=nil then begin
      result:=Tree.AddChild(basenode,nil);
      pnd:=Tree.GetNodeData(result);
      if Assigned(pnd) then begin
       pnd^.NodeMode:=TNMGroup;
       pnd^.id:=BaseName;
       pnd^.name:=BaseName;
      end;
    end;
end;


{function TBaseRootNodeDesk.FilterEntity(pent:pGDBObjEntity):Boolean;
begin
  result:=true;
end;}

function TBaseRootNodeDesk.DefaultTraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;
begin
  name:=pent.GetObjTypeName;
  result:=rootnode;
end;

function TBaseRootNodeDesk.CreateEntityNode(Tree: TVirtualStringTree;basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;
var
   pnd:PTNodeData;
begin
  result:=Tree.AddChild(basenode,nil);
  pnd := Tree.GetNodeData(result);
  if Assigned(pnd) then begin
    pnd^.NodeMode:=TNMData;
    pnd^.pent:=pent;
    pnd^.id:=Name;
    pnd^.name:=Name;
  end;
end;

procedure TBaseRootNodeDesk.ProcessEntity(CreateEntityNode:TCreateEntityNodeFunc;pent:pGDBObjEntity;filterproc:TFilterEntityProc;traceproc:TTraceEntityProc);
var
  Name:string;
  basenode2,namenode,pnode:PVirtualNode;
  //pnd:PTNodeData;
  include:boolean;
begin
  basenode2:=nil;
  if assigned(filterproc) then
    include:=filterproc(pent)
  else
    include:=true;
  if include then begin
    if assigned(traceproc)then
      basenode2:=traceproc(self,pent,Name)
    else
      basenode2:=DefaultTraceEntity(self,pent,Name);
    if basenode2<>nil then begin
      namenode:=FindGroupNodeBy(basenode2,Name,FindByName);
      if namenode<>nil then begin
        ConvertNameNodeToGroupNode(namenode);
        basenode2:=namenode;
      end;
      pnode:=CreateEntityNode(tree,basenode2,pent,Name);
    end;
  end;
end;

constructor TBaseRootNodeDesk.create(AOwner:TComponent; ATree: TVirtualStringTree; AName:string);
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
destructor TBaseRootNodeDesk.Destroy;
begin
   tree.DeleteNode(RootNode);
   RootNode:=nil;
   inherited;
end;

initialization
finalization;
end.

