unit uzcnavigatorsnodedesk;

{$mode delphi}
{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, laz.VirtualTrees, gzctnrSTL,
  uzccommandsmanager,
  uzcinterface, uzeentity, uzcimagesmanager,
  uzcenitiesvariablesextender,uzcExtdrSCHConnection,
  uzsbVarmanDef, uzctreenode,
  Varman, uzcoimultiproperties,LCLType,LCLVersion;

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

  TCreateEntityNodeFunc=function(Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode of object;
  TBaseRootNodeDesk=class;
  TFilterEntityProc=function(pent:pGDBObjEntity):Boolean of object;
  TTraceEntityProc=function(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode of object;
  TNodeMode=(TNMGroup,TNMAutoGroup,TNMData,TNMHardGroup);
  TNodePastProcessParam=record
    subNodesCounter:Integer;
    subLeafCounter:Integer;
    subLeafCounterWithMainFubction:Integer;
  end;

  TNodeIdent=record
    name,id:string;
    pent:PGDBObjEntity;
    class operator =(a,b:TNodeIdent):Boolean;
  end;
  TNodePath=TMyVector<TNodeIdent>;

  PTNodeData=^TNodeData;
  TNodeData=record
    NodeMode:TNodeMode;
    Ident:TNodeIdent;
    ppp:TNodePastProcessParam;
  end;

  //TNodesStatesVector=TMyVector<TNodeIdent>;
  TNodesStatesVector=TMyVectorArray<TNodeIdent,TNodePath>;

  GLeveMetric<T>=object
   type
    TBuf=TMyVector<Integer>;
   var
    buf:TBuf;
    Constructor Init;
    Destructor Done;virtual;
    function LeveDist(s,t:T):Integer;
    function Equaly(s,t:T):Boolean;
  end;
  TLeveMetric=GLeveMetric<TNodePath>;

  TNodesStates=class
    OpenedNodes:TNodesStatesVector;
    TrueOpenedNodes:TNodesStatesVector;
    SelectedNode:TNodeData;
    SaveOffset:TPoint;
    constructor Create;
    destructor Destroy;override;
  end;

  TFindFunc=function(pnd:Pointer; Criteria:string):boolean of object;

  TBaseRootNodeDesk=class(Tcomponent)
    public
    RootNode:PVirtualNode;
    Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
    ficonindex:integer;
    function FindById(pnd:Pointer; Criteria:string):boolean;
    function FindByName(pnd:Pointer; Criteria:string):boolean;
    constructor Create(AOwner:TComponent; ATree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF}; AName:string; CreateRootNode:Boolean=False);overload;
    destructor Destroy;override;
    function find(BaseName:string;basenode:PVirtualNode):PVirtualNode;
    procedure ProcessEntity(CreateEntityNode:TCreateEntityNodeFunc;pent:pGDBObjEntity;filterproc:TFilterEntityProc;traceproc:TTraceEntityProc);
    function CreateEntityNode(Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;virtual;
    procedure ConvertNameNodeToGroupNode(pnode:PVirtualNode);
    function FindGroupNodeBy(RootNode:PVirtualNode;criteria:string;func:TFindFunc):PVirtualNode;
    function SaveState(var CurrentSel:TNodeData):TNodesStates;
    procedure RecursiveSaveState(PrevNodeExpanded:Boolean;var Node:PVirtualNode;CurrPath:TNodePath;NodesStates:TNodesStates);
    procedure RestoreState(State:TNodesStates;Dist:Integer);
    procedure RecursiveRestoreState(Node:PVirtualNode;Path:TNodePath;var StartInNodestates:integer;NodesStates:TNodesStates;Dist:Integer);
    function DefaultTraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;virtual;
  end;

function GetEntityVariableValue(const pent:pGDBObjEntity;varname,defvalue:string):string;
function GetVariableValue(const EntVarExt:TVariablesExtender;varname,defvalue:string):string;
function GetPVD(const EntVarExt:TVariablesExtender;varname:string):pvardesk;

function GetMainFunction(const pent:pGDBObjEntity):pGDBObjEntity;

var
 LeveMetric:TLeveMetric;
 InterfaceOnly:Boolean=False;

implementation

Constructor GLeveMetric<T>.Init;
begin
  buf:=TBuf.create;
end;

Destructor GLeveMetric<T>.Done;
begin
  buf.Free;
end;

function GLeveMetric<T>.Equaly(s,t:T):Boolean;
var
  i:Integer;
begin
  if s.Size<>t.Size then
    exit(false);
  for i:=0 to s.Size-1 do
    if s[i]<>t[i] then
      exit(false);
  Result:=true;
end;

function GLeveMetric<T>.LeveDist(s,t:T):Integer;
  function max(const a,b:Integer):integer;
  begin
    if a>b then
      Result:=a
    else
      Result:=b;
  end;
  function min3(const a,b,c:Integer):Integer;
  begin
    Result := a;
    if b < Result then Result := b;
    if c < Result then Result := c;
  end;
var
  i,j,m,n:Integer;
  cost:Integer;
  flip:Boolean;
  cuthalf:Integer;
begin
  m := s.Size;// length(s);
  n := t.Size;// length(t);
  cuthalf:=max(m,n)+1;
  buf.Reserve((cuthalf * 2) - 1);

  if m = 0 then Result := n
  else if n = 0 then Result := m
  else begin
    flip := false;
    for i := 0 to n do buf[i] := i;
    for i := 1 to m do begin
      if flip then buf[0] := i
      else buf[cuthalf] := i;
      for j := 1 to n do begin
        if s[i-1{в векторе с 0}] = t[j-1{в векторе с 0}] then cost := 0
        else cost := 1;
        if flip then
          buf[j] := min3((buf[cuthalf + j] + 1),
                         (buf[j - 1] + 1),
                         (buf[cuthalf + j - 1] + cost))
        else
          buf[cuthalf + j] := min3((buf[j] + 1),
                                   (buf[cuthalf + j - 1] + 1),
                                   (buf[j - 1] + cost));
      end;
      flip := not flip;
    end;
    if flip then Result := buf[cuthalf + n]
    else Result := buf[n];
  end;
end;

class operator TNodeIdent.=(a,b:TNodeIdent):Boolean;
begin
  result:=(a.name=b.name)and(a.id=b.id)and(a.pent=b.pent);
end;

function GetMainFunction(const pent:pGDBObjEntity):pGDBObjEntity;
var
  EntVarExt:TVariablesExtender;
begin
  EntVarExt:=pent^.GetExtension<TVariablesExtender>;
  if EntVarExt<>nil then
    result:=EntVarExt.pMainFuncEntity
  else
    result:=nil;
end;

function GetEntityVariableValue(const pent:pGDBObjEntity;varname,defvalue:string):string;
var
  EntVarExt:TVariablesExtender;
  EntConnectionExt:TSCHConnectionExtender;
  i:integer;
  pvd:pvardesk;
begin
  if not InterfaceOnly then begin
    EntConnectionExt:=pent^.GetExtension<TSCHConnectionExtender>;
    if (EntConnectionExt<>nil)and(EntConnectionExt.Net<>nil) then begin
      for i:=0 to EntConnectionExt.Net.Setters.Count-1 do begin
        EntVarExt:=EntConnectionExt.Net.Setters.getDataMutable(i)^.pThisEntity^.GetExtension<TVariablesExtender>;
        if EntVarExt<>nil then begin
          pvd:=EntVarExt.EntityUnit.FindVariable(varname);
          if pvd<>nil then
            exit(pvd^.GetValueAsString);
        end;
      end;
      exit('0x'+inttohex(PtrUInt(EntConnectionExt.Net)));
    end;
  end;

  EntVarExt:=pent^.GetExtension<TVariablesExtender>;
  if EntVarExt<>nil then
    result:=GetVariableValue(EntVarExt,varname,defvalue)
  else
    result:=defvalue;
end;

function GetVariableValue(const EntVarExt:TVariablesExtender;varname,defvalue:string):string;
var
  pvd:pvardesk;
begin
  pvd:=GetPVD(EntVarExt,varname);
  if pvd<>nil then
    result:=pvd.data.PTD^.GetValueAsString(pvd.data.Addr.Instance)
  else
    result:=defvalue;
end;

function GetPVD(const EntVarExt:TVariablesExtender;varname:string):pvardesk;
begin
  result:=EntVarExt.entityunit.FindVariable(varname,InterfaceOnly);
end;




function TBaseRootNodeDesk.FindById(pnd:Pointer; Criteria:string):boolean;
begin
  if PTNodeData(pnd)^.NodeMode<>TNMHardGroup then
    result:=PTNodeData(pnd)^.Ident.id=Criteria
  else
    result:=false;
end;
function TBaseRootNodeDesk.FindByName(pnd:Pointer; Criteria:string):boolean;
begin
  if PTNodeData(pnd)^.NodeMode<>TNMHardGroup then
    result:=PTNodeData(pnd)^.Ident.name=Criteria
  else
    result:=false;
end;

{ TNavigatorDevices }
constructor TNodesStates.Create;
begin
  OpenedNodes:=TNodesStatesVector.create;
  TrueOpenedNodes:=TNodesStatesVector.create;
  SelectedNode.Ident.id:='';
  SelectedNode.Ident.name:='';
  SelectedNode.Ident.pent:=nil;
end;
destructor TNodesStates.Destroy;
begin
  FreeAndNil(OpenedNodes);
  FreeAndNil(TrueOpenedNodes);
end;

{rocedure dbg(pref:string;Path:TNodePath);
var
  ni:TNodeIdent;
  s:string;
begin
  s:='';
  for ni in path do
    s:=format('%s(%s|%s|%p)',[s,ni.name,ni.id,ni.pent]);
  zcUI.TextMessage(pref+s,TMWOHistoryOut);
end;}

procedure TBaseRootNodeDesk.RecursiveSaveState(PrevNodeExpanded:Boolean;var Node:PVirtualNode;CurrPath:TNodePath;NodesStates:TNodesStates);
var
  child,ischild:PVirtualNode;
  pnd:PTNodeData;
  ThisNodeExpanded:Boolean;
begin
  pnd:=Tree.GetNodeData(Node);
  child:=Node^.FirstChild;
  ischild:=child;
  if pnd<>nil then
  begin
    if (child<>nil)or
       ((pnd.Ident.pent=NodesStates.SelectedNode.Ident.pent)
        and(pnd.Ident.name=NodesStates.SelectedNode.Ident.name)
        and(pnd.Ident.id=NodesStates.SelectedNode.Ident.id)) then begin
      CurrPath.PushBack(pnd^.Ident);
      if Tree.Expanded[Node]=true then begin
        ThisNodeExpanded:=True;
        if PrevNodeExpanded then begin
          //dbg('Save TrueOpenedNodes ',CurrPath);
          NodesStates.TrueOpenedNodes.AddArrayAndSetCurrent;
          CurrPath.CopyTo(NodesStates.TrueOpenedNodes.GetCurrentArray);
        end else begin
          //dbg('Save OpenedNodes ',CurrPath);
          NodesStates.OpenedNodes.AddArrayAndSetCurrent;
          CurrPath.CopyTo(NodesStates.OpenedNodes.GetCurrentArray);
        end
      end;
    end;
  end else
    ThisNodeExpanded:=PrevNodeExpanded;
  while child<>nil do
  begin
   RecursiveSaveState(PrevNodeExpanded and ThisNodeExpanded,child,CurrPath,NodesStates);
   child:=child^.NextSibling;
  end;
  if (pnd<>nil)and(ischild<>nil) then
    CurrPath.PopBack;
end;
function TBaseRootNodeDesk.SaveState(var CurrentSel:TNodeData):TNodesStates;
var
  Path:TNodePath;
begin
  result:=TNodesStates.create;
  result.SelectedNode:=CurrentSel;
  Path:=TNodePath.Create;
  RecursiveSaveState(True,RootNode,Path,result);
  Path.Free;
end;

function findin(Path:TNodePath;var StartInNodestates:integer;OpNod:TNodesStatesVector;Dist:Integer):boolean;
var
  i:SizeUInt;
  //deb:TNodeIdent;
  IsEqual:Boolean;
begin
  //dbg('Start compare ',Path);
  if OpNod.VArray.Size>0 then
    for i:=OpNod.VArray.Size-1 downto 0 do
    begin
     //dbg('  compare with',OpNod.VArray[i]);
     if Dist=0 then
        IsEqual:=LeveMetric.Equaly(OpNod.VArray[i],Path)
     else begin
        if abs(integer(OpNod.VArray[i].Size-Path.Size))<2 then
          IsEqual:=LeveMetric.LeveDist(OpNod.VArray[i],Path)<=Dist
        else
          IsEqual:=False;
     end;
     if IsEqual then begin
       //zcUI.TextMessage('yes!',TMWOHistoryOut);
       exit(true);
     end;
    end;
      result:=false;
    //zcUI.TextMessage('end((',TMWOHistoryOut);
end;

procedure TBaseRootNodeDesk.RecursiveRestoreState(Node:PVirtualNode;Path:TNodePath;var StartInNodestates:integer;NodesStates:TNodesStates;Dist:Integer);
var
  child,ischild,vparent:PVirtualNode;
  pnd:PTNodeData;
begin
  pnd:=Tree.GetNodeData(Node);
  child:=Node^.FirstChild;
  ischild:=child;
  if pnd<>nil then begin
    if child<>nil then begin
      Path.PushBack(pnd.Ident);
      if findin(Path,StartInNodestates,NodesStates.TrueOpenedNodes,Dist) then begin
        Tree.Expanded[Node]:=true;
        vparent:=Node.Parent;
        while vparent<>RootNode do begin
          Tree.Expanded[vparent]:=true;
          vparent:=vparent.Parent;
        end;
      end else if findin(Path,StartInNodestates,NodesStates.OpenedNodes,Dist) then
        Tree.Expanded[Node]:=true;
    end;
    {if StartInNodestates=NodesStates.OpenedNodes.VArray.Size then
      exit;}
    if(pnd.Ident.pent=NodesStates.SelectedNode.Ident.pent)
       and(pnd.Ident.name=NodesStates.SelectedNode.Ident.name)
       and(pnd.Ident.id=NodesStates.SelectedNode.Ident.id) then begin
        Tree.FocusedNode:=Node;
        //Tree.AddToSelection(Node);
    end;
  end;
  while child<>nil do
  begin
   RecursiveRestoreState(child,Path,StartInNodestates,NodesStates,Dist);
   child:=child^.NextSibling;
  end;
  if (pnd<>nil)and(ischild<>nil) then
    Path.PopBack;
end;
procedure TBaseRootNodeDesk.RestoreState(State:TNodesStates;Dist:Integer);
var
  StartInNodestates:integer;
  Path:TNodePath;
begin
  StartInNodestates:=-1;
  Path:=TNodePath.Create;
  RecursiveRestoreState(RootNode,Path,StartInNodestates,State,Dist);
  Path.Free;
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
    pnd^.Ident.pent:=nil;
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
       pnd^.Ident.id:=BaseName;
       pnd^.Ident.name:=BaseName;
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

function TBaseRootNodeDesk.CreateEntityNode(Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;
var
   pnd:PTNodeData;
begin
  result:=Tree.AddChild(basenode,nil);
  pnd := Tree.GetNodeData(result);
  if Assigned(pnd) then begin
    pnd^.NodeMode:=TNMData;
    pnd^.Ident.pent:=pent;
    pnd^.Ident.id:=Name;
    pnd^.Ident.name:=Name;
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

constructor TBaseRootNodeDesk.create(AOwner:TComponent; ATree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF}; AName:string; CreateRootNode:Boolean=False);
var
   pnd:PTNodeData;
begin
   inherited create(AOwner);
   Tree:=ATree;
   if CreateRootNode then
     RootNode:=ATree.AddChild(nil,nil)
   else
     RootNode:=ATree.RootNode;
   pnd := Tree.GetNodeData(RootNode);
   if Assigned(pnd) then
   begin
      pnd^.NodeMode:=TNMGroup;
      pnd^.Ident.name:=AName;
   end;
end;
destructor TBaseRootNodeDesk.Destroy;
begin
  if RootNode=Tree.RootNode then
    tree.Clear
  else begin
    tree.DeleteNode(RootNode);
    RootNode:=nil;
  end;
   inherited;
end;

initialization
  LeveMetric.Init;
finalization;
  LeveMetric.Done;
end.

