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
unit uzeentgenericsubentry;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzestyleslayers,
  UGDBVisibleTreeArray,UGDBOpenArrayOfPV,uzeentwithmatrix,uzeentsubordinated,
  uzegeometry,uzeentity,gzctnrVectorTypes,uzegeometrytypes,uzeconsts,
  uzeentitiestree,uzeffdxfsupport,uzCtnrVectorpBaseEntity,uzeTypes,uzeEntBase,
  Generics.Collections;

type
  TZctnrVectorPGDBaseEntityNoDbl=object(TZctnrVectorPGDBaseEntity)
    type
      TDic=TDictionary<PGDBObjBaseEntity,Integer>;
    const
      MaxCountWithoutSet=100;
    var
    Dctr:TDic;
    function PushBackIfNotPresent(data:PGDBObjBaseEntity):Integer;virtual;
    function IsDataExist(pobj:PGDBObjBaseEntity):Integer;virtual;
    procedure Clear;virtual;
    destructor destroy; virtual;
  end;

  PTDrawingPreCalcData=^TDrawingPreCalcData;

  TDrawingPreCalcData=record
    InverseObjMatrix:TzeTypedMatrix4d;
  end;
  PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;

  GDBObjGenericSubEntry=object(GDBObjWithMatrix)
    ObjArray:GDBObjEntityTreeArray;
    ObjCasheArray:TZctnrVectorPGDBaseEntityNoDbl{TZctnrVectorPGDBaseEntity};
    ObjToConnectedArray:TZctnrVectorPGDBaseEntityNoDbl{TZctnrVectorPGDBaseEntity};
    lstonmouse:PGDBObjEntity;
    InFrustumAABB:TBoundingBox;
    function AddObjectToObjArray(p:Pointer):integer;virtual;
    procedure RemoveMiFromArray(pobj:PGDBObjSubordinated;
      pobjinarray:integer;const drawing:TDrawingDef);virtual;
    procedure GoodAddObjectToObjArray(
      const obj:PGDBObjSubordinated);virtual;
    procedure GoodRemoveMiFromArray(
      const obj:PGDBObjSubordinated;
      const drawing:TDrawingDef);virtual;
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure DrawGeometry(lw:integer;
      var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
    function CalcInFrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcActualVisible(
      const Actuality:TVisActuality):boolean;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure FormatAfterEdit(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure restructure(var drawing:TDrawingDef);virtual;
    function getowner:PGDBObjSubordinated;virtual;
    function CanAddGDBObj(pobj:PGDBObjEntity):boolean;virtual;
    function EubEntryType:integer;virtual;
    procedure MigrateTo(new_sub:PGDBObjGenericSubEntry);virtual;
    procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:integer;
      var drawing:TDrawingDef);virtual;
    //** Добавляет объект в область ConstructObjRoot или mainObjRoot или итд. Пример добавления gdb.GetCurrentDWG^.ConstructObjRoot.AddMi(@sampleObj);
    procedure AddMi(pobj:PGDBObjSubordinated);virtual;
    procedure ImEdited(pobj:PGDBObjSubordinated;
      pobjinarray:integer;var drawing:TDrawingDef);virtual;
    function ReturnLastOnMouse(InSubEntry:boolean):PGDBObjEntity;
      virtual;
    procedure correctobjects(powner:PGDBObjEntity;
      pinownerarray:integer);virtual;
    destructor done;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure getonlyoutbound(var DC:TDrawContext);virtual;
    procedure DrawBB(var DC:TDrawContext);
    procedure RemoveInArray(pobjinarray:integer);virtual;
    procedure DrawWithAttrib(var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function CreatePreCalcData:PTDrawingPreCalcData;virtual;
    procedure DestroyPreCalcData(
      PreCalcData:PTDrawingPreCalcData);virtual;
    function CalcVisibleByTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var enttree:TEntTreeNode;
      var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    procedure SetInFrustumFromTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;
    function FindObjectsInVolume(const Volume:TBoundingBox;
      var Objects:GDBObjOpenArrayOfPV):boolean;virtual;
    function FindObjectsInPoint(const point:TzePoint3d;
      var Objects:GDBObjOpenArrayOfPV):boolean;virtual;
    function FindObjectsInPointSlow(const point:TzePoint3d;
      var Objects:GDBObjOpenArrayOfPV):boolean;
    function FindObjectsInPointInNode(const point:TzePoint3d;
      const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):boolean;
    function FindObjectsInVolumeInNode(
      const Volume:TBoundingBox;const Node:TEntTreeNode;
      var Objects:GDBObjOpenArrayOfPV):boolean;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    procedure correctsublayers(var la:GDBLayerArray);virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure IterateCounter(PCounted:Pointer;
      var Counter:integer;proc:TProcCounter);virtual;
    procedure postload(var context:TIODXFLoadContext);virtual;
    function GetMainOwner:PGDBObjSubordinated;virtual;
    function calcvisible(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
  end;

implementation

destructor TZctnrVectorPGDBaseEntityNoDbl.destroy;
begin
  Dctr.Free;
  inherited;
end;
procedure TZctnrVectorPGDBaseEntityNoDbl.Clear;
begin
  inherited;
  if Dctr<>nil then
    Dctr.Clear;
end;
function TZctnrVectorPGDBaseEntityNoDbl.IsDataExist(pobj:PGDBObjBaseEntity):Integer;
var
  PTempObj:PGDBObjBaseEntity;
  ir:itrec;
begin
  if Count<MaxCountWithoutSet then
    result:=inherited IsDataExist(pobj)
  else begin
    if Dctr=nil then
      Dctr:=TDic.Create(MaxCountWithoutSet);
    result:=-1;
    if Dctr.Count=0 then begin
      PTempObj:=beginiterate(ir);
      if PTempObj<>nil then
        repeat
          if PTempObj=pobj then
            Result:=ir.itc;
          Dctr.Add(PTempObj,ir.itc);
          PTempObj:=iterate(ir);
        until PTempObj=nil;
      if result<>-1 then
        exit;
    end;
    if not Dctr.TryGetValue(pobj,Result) then
      result:=-1;
  end;
end;
function TZctnrVectorPGDBaseEntityNoDbl.PushBackIfNotPresent(data:PGDBObjBaseEntity):Integer;
var
  c:integer;
begin
  c:=count;
  result:=inherited PushBackIfNotPresent(data);
  if Dctr<>nil then
    if (c<>count)and(Dctr.Count>0) then
      Dctr.Add(data,result);
end;

function GDBObjGenericSubEntry.calcvisible(const frustum:TzeFrustum;
  const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double):boolean;
begin
  inherited;
  Result:=ObjArray.calcvisible(frustum,Actuality,Counters,ProjectProc,
    zoom,currentdegradationfactor);
end;

function GDBObjGenericSubEntry.GetMainOwner:PGDBObjSubordinated;
begin
  Result:=@self;
end;

procedure GDBObjGenericSubEntry.postload(var context:TIODXFLoadContext);
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  p:=objarray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.Postload(context);
      p:=objarray.iterate(ir);
    until p=nil;
end;

procedure GDBObjGenericSubEntry.IterateCounter(PCounted:Pointer;
  var Counter:integer;proc:TProcCounter);
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  inherited;
  p:=objarray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.IterateCounter(PCounted,Counter,proc);
      p:=objarray.iterate(ir);
    until p=nil;
end;

function GDBObjGenericSubEntry.CalcTrueInFrustum;
begin
  Result:=ObjArray.CalcTrueInFrustum(frustum);
end;

procedure GDBObjGenericSubEntry.correctsublayers(var la:GDBLayerArray);
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  if objarray.Count=0 then
    exit;
  p:=objarray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.vp.Layer:=la.createlayerifneed(p^.vp.Layer);
      p^.correctsublayers(la);
      p:=objarray.iterate(ir);
    until p=nil;
end;

function GDBObjGenericSubEntry.FindObjectsInPointSlow(const point:TzePoint3d;
  var Objects:GDBObjOpenArrayOfPV):boolean;
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  pobj:=objarray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.onpoint(Objects,point) then begin
        Result:=True;
      end;

      pobj:=objarray.iterate(ir);
    until pobj=nil;
end;

function GDBObjGenericSubEntry.FindObjectsInPointInNode(const point:TzePoint3d;
  const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):boolean;
var
  minus:boolean{$IFNDEF DELPHI}=False{$ENDIF};
  plus:boolean{$IFNDEF DELPHI}=False{$ENDIF};
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  plus:=False;
  minus:=False;
  Result:=False;
  if assigned(Node.pminusnode) then
    if uzegeometry.IsPointInBB(point,Node.pminusnode.BoundingBox) then begin
      minus:=FindObjectsInPointInNode(point,PTEntTreeNode(
        Node.pminusnode)^,Objects);
    end;
  if assigned(Node.pplusnode) then
    if uzegeometry.IsPointInBB(point,Node.pplusnode.BoundingBox) then begin
      plus:=FindObjectsInPointInNode(point,PTEntTreeNode(Node.pplusnode)^,Objects);
    end;

  pobj:=Node.nulbeginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.onpoint(Objects,point) then begin
        Result:=True;
      end;

      pobj:=Node.nuliterate(ir);
    until pobj=nil;

  Result:=Result or (plus or minus);
end;

function GDBObjGenericSubEntry.FindObjectsInVolumeInNode(const Volume:TBoundingBox;
  const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):boolean;
var
  minus:boolean{$IFNDEF DELPHI}=False{$ENDIF};
  plus:boolean{$IFNDEF DELPHI}=False{$ENDIF};
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  plus:=False;
  minus:=False;
  Result:=False;
  if assigned(Node.pminusnode) then
    if uzegeometry.boundingintersect(Volume,Node.pminusnode.BoundingBox) then begin
      minus:=FindObjectsInVolumeInNode(Volume,PTEntTreeNode(
        Node.pminusnode)^,Objects);
    end;
  if assigned(Node.pplusnode) then
    if uzegeometry.boundingintersect(Volume,Node.pplusnode.BoundingBox) then begin
      plus:=FindObjectsInVolumeInNode(Volume,PTEntTreeNode(
        Node.pplusnode)^,Objects);
    end;

  pobj:=Node.nulbeginiterate(ir);
  if pobj<>nil then
    repeat
      if boundingintersect(Volume,pobj^.vp.BoundingBox) then begin
        Result:=True;
        Objects.PushBackData(pobj);
      end;

      pobj:=Node.nuliterate(ir);
    until pobj=nil;

  Result:=Result or (plus or minus);
end;

function GDBObjGenericSubEntry.FindObjectsInPoint(const point:TzePoint3d;
  var Objects:GDBObjOpenArrayOfPV):boolean;
begin
  if uzegeometry.IsPointInBB(point,self.ObjArray.ObjTree.BoundingBox) then begin
    Result:=FindObjectsInPointInNode(point,ObjArray.ObjTree,Objects);
  end else
    Result:=False;
end;

function GDBObjGenericSubEntry.FindObjectsInVolume(const Volume:TBoundingBox;
  var Objects:GDBObjOpenArrayOfPV):boolean;
begin
  if uzegeometry.boundingintersect(Volume,self.ObjArray.ObjTree.BoundingBox) then
  begin
    Result:=FindObjectsInVolumeInNode(Volume,ObjArray.ObjTree,Objects);
  end else
    Result:=False;
end;

procedure GDBObjGenericSubEntry.GoodAddObjectToObjArray(const obj:PGDBObjSubordinated);
var
  p:pointer;
begin
  p:=obj;
  AddObjectToObjArray(@p);
end;

function GDBObjGenericSubEntry.AddObjectToObjArray(p:Pointer):integer;
begin
  Result:=ObjArray.AddPEntity(PGDBObjEntity(p^)^);
  PGDBObjEntity(p^).bp.ListPos.Owner:=@self;
end;

procedure GDBObjGenericSubEntry.SetInFrustumFromTree;
begin
  inherited;
  ObjArray.SetInFrustumFromTree(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  ObjArray.ObjTree.NodeData.infrustum:=Actuality.InfrustumActualy;
  ObjArray.ObjTree.BoundingBox:=vp.BoundingBox;
  ProcessTree(frustum,Actuality,ObjArray.ObjTree,IRFully,
    TDTFulDraw,Counters,ProjectProc,zoom,currentdegradationfactor);
end;

function GDBObjGenericSubEntry.CalcVisibleByTree(const frustum:TzeFrustum;
  const Actuality:TVisActuality;var enttree:TEntTreeNode;
  var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double):boolean;
begin
  CalcInFrustumByTree(frustum,Actuality,enttree,Counters,ProjectProc,
    zoom,currentdegradationfactor);
end;

function GDBObjGenericSubEntry.CreatePreCalcData:PTDrawingPreCalcData;
begin
  Getmem(Pointer(Result),sizeof(TDrawingPreCalcData));
  Result.InverseObjMatrix:=objmatrix;
  uzegeometry.MatrixInvert(Result.InverseObjMatrix);
end;

procedure GDBObjGenericSubEntry.DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);
begin
  Freemem(pointer(PreCalcData));
end;

procedure GDBObjGenericSubEntry.DrawWithAttrib;
var
  _selected:boolean;
begin
  Inc(dc.subrender);
  _selected:=dc.selected;
  if selected then
    dc.selected:=True;
  self.ObjArray.DrawWithattrib(dc,inFrustumState);
  Dec(dc.subrender);
  dc.selected:=_selected;

end;

procedure GDBObjGenericSubEntry.DrawBB;
begin
  inherited;
  if DC.SystmGeometryDraw then begin
    dc.drawer.SetColor(palette[{sysvar.SYS.SYS_SystmGeometryColor^+2}4].RGB);
    dc.drawer.DrawAABB3DInModelSpace(InFrustumAABB,dc.DrawingContext.matrixs);
  end;
end;

procedure GDBObjGenericSubEntry.RemoveInArray(pobjinarray:integer);
begin
  ObjArray.DeleteElement(pobjinarray);
end;

procedure GDBObjGenericSubEntry.AddMi;
begin
  ObjArray.AddPEntity(pGDBObjEntity(ppointer(pobj)^)^);
  pGDBObjEntity(ppointer(pobj)^).bp.ListPos.Owner:=@self;
  if assigned(pGDBObjEntity(ppointer(pobj)^).EntExtensions) then
    pGDBObjEntity(ppointer(pobj)^).EntExtensions.RunSetRoot(pobj,@self);
end;

procedure GDBObjGenericSubEntry.correctobjects;
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  bp.ListPos.Owner:=powner;
  bp.ListPos.SelfIndex:=pinownerarray;
  pobj:=self.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      pobj^.correctobjects(@self,ir.itc);
      pobj:=self.ObjArray.iterate(ir);
    until pobj=nil;
end;

procedure GDBObjGenericSubEntry.GoodRemoveMiFromArray(const obj:PGDBObjSubordinated;
  const drawing:TDrawingDef);
begin
  RemoveMiFromArray(obj,obj.bp.ListPos.SelfIndex,drawing);
end;

procedure GDBObjGenericSubEntry.RemoveMiFromArray(pobj:PGDBObjSubordinated;
  pobjinarray:integer;const drawing:TDrawingDef);
begin
  if assigned(pobj^.EntExtensions) then
    pobj^.EntExtensions.RunRemoveFromArray(pobj,drawing);

  if pobj^.bp.TreePos.Owner<>nil then begin
    PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nulDeleteElement(
      pobj^.bp.TreePos.SelfIndexInNode);
    if pobj^.IsNeedSeparate then
      PTEntTreeNode(pobj^.bp.TreePos.Owner)^.DeleteFromSeparated(PGDBObjEntity(pobj)^);
  end;
  pobj^.bp.TreePos.Owner:=nil;
  ObjArray.DeleteElement(pobjinarray);
end;

procedure GDBObjGenericSubEntry.EraseMi;
begin
  RemoveMiFromArray(pobj,pobjinarray,drawing);
  pobj^.done;
  Freemem(Pointer(pobj));
end;

procedure GDBObjGenericSubEntry.ImEdited;
begin
  ObjCasheArray.PushBackIfNotPresent(pobj);
end;

function GDBObjGenericSubEntry.ReturnLastOnMouse;
begin
  if InSubEntry then
    Result:=lstonmouse
  else
    Result:=@self;
end;

procedure GDBObjGenericSubEntry.MigrateTo;
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  if objarray.Count=0 then
    exit;
  p:=objarray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.bp.ListPos.Owner:=new_sub;
      new_sub^.ObjArray.AddPEntity(p^);
      p:=objarray.iterate(ir);
    until p=nil;
  objarray.Count:=0;
end;

function GDBObjGenericSubEntry.EubEntryType;
begin
  Result:=se_Abstract;
end;

function GDBObjGenericSubEntry.CanAddGDBObj;
begin
  Result:=False;
end;

function GDBObjGenericSubEntry.getowner;
begin
  Result:=pointer(bp.TreePos.owner);
end;

destructor GDBObjGenericSubEntry.done;
begin
  ObjCasheArray.Clear;
  ObjToConnectedArray.Clear;
  ObjArray.Done;
  ObjCasheArray.Done;
  ObjToConnectedArray.Done;
  inherited done;
end;

constructor GDBObjGenericSubEntry.initnul;
begin
  inherited initnul(owner);
  ObjArray.init(10);
  ObjCasheArray.init(10);
  ObjToConnectedArray.init(100);
end;

procedure GDBObjGenericSubEntry.DrawGeometry;
var
  _selected:boolean;
begin
  Inc(dc.subrender);
  _selected:=dc.selected;
  if selected then
    dc.selected:=True;
  ObjArray.DrawGeometry(CalculateLineWeight(dc),dc,infrustumstate);
  dc.selected:=_selected;
  Dec(dc.subrender);
  DrawBB(dc);
end;

function GDBObjGenericSubEntry.CalcInFrustum(const frustum:TzeFrustum;
  const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double):boolean;
begin
  Result:=ObjArray.calcvisible(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  self.InFrustumAABB:=ObjArray.calcvisbb(Actuality.infrustumactualy);
end;

function GDBObjGenericSubEntry.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  q:boolean;
begin
  Result:=inherited;
  q:=ObjArray.CalcActualVisible(Actuality);
  Result:=Result or q;
end;

procedure GDBObjGenericSubEntry.getoutbound;
begin
  vp.BoundingBox:=ObjArray.calcbb;
end;

procedure GDBObjGenericSubEntry.getonlyoutbound;
begin
  vp.BoundingBox:=ObjArray.getonlyoutbound(dc);
end;

procedure GDBObjGenericSubEntry.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  inherited FormatEntity(drawing,dc);
  ObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  restructure(drawing);
end;

procedure GDBObjGenericSubEntry.formatafteredit;
var
  PEntity:PGDBObjBaseEntity;
begin
  for PEntity in ObjCasheArray do
    PEntity^.Formatafteredit(drawing,dc);
  //ObjCasheArray.Formatafteredit(drawing,dc);

  ObjCasheArray.Clear;
  calcbb(dc);
  restructure(drawing);
  formatentity(drawing,dc,Stage);
end;

procedure GDBObjGenericSubEntry.restructure;
begin
end;

function GDBObjGenericSubEntry.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
var
  i:integer;
  p:pGDBObjEntity;
  ot:boolean;
begin
  Result:=False;
  for i:=0 to ObjArray.Count-1 do begin
    p:=Pointer(ObjArray.getDataMutable(i));
    if p<>nil then begin
      ot:=p^.onpoint(objects,point);
      if ot then begin
        Result:=True;
      end;
    end;
  end;
end;

function GDBObjGenericSubEntry.onmouse;
var
  i:integer;
  p:pGDBObjEntity;
  ot:boolean;
begin
  Result:=False;
  for i:=0 to ObjArray.Count-1 do begin
    p:=Pointer(ObjArray.getDataMutable(i));
    if p<>nil then begin
      ot:=p^.onmouse(popa,mf,InSubEntry);
      if ot then begin
        lstonmouse:=p;
        popa.PushBackData(p);
      end;
      Result:=Result or ot;
    end;
  end;
end;

begin
end.
