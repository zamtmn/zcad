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
unit uzeentcomplex;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzestyleslayers,SysUtils,
  UGDBSelectedObjArray,UGDBVisibleOpenArray,uzeentity,UGDBVisibleTreeArray,
  uzeentitiestree,uzeentwithlocalcs,gzctnrVectorTypes,uzegeometrytypes,
  uzeconsts,uzegeometry,uzglviewareadata,uzeSnap,uzCtnrVectorpBaseEntity,
  uzeTypes;

type
  PGDBObjComplex=^GDBObjComplex;

  GDBObjComplex=object(GDBObjWithLocalCS)
    ConstObjArray:GDBObjEntityTreeArray;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure getonlyoutbound(var DC:TDrawContext);virtual;
    function getonlyvisibleoutbound(
      var DC:TDrawContext):TBoundingBox;virtual;
    destructor done;virtual;
    constructor initnul;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    function CalcInFrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure SetInFrustumFromTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;
      var DC:TDrawContext);virtual;
    function CalcActualVisible(
      const Actuality:TVisActuality):boolean;virtual;
    function IsNeedSeparate:boolean;virtual;
  end;

implementation

function GDBObjComplex.IsNeedSeparate:boolean;
begin
  Result:=True;
end;

function GDBObjComplex.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  q:boolean;
begin
  Result:=inherited;
  q:=ConstObjArray.CalcActualVisible(Actuality);
  Result:=Result or q;
end;

procedure GDBObjComplex.BuildGeometry;
begin
  ConstObjArray.ObjTree.ClearSub;
  ConstObjArray.ObjTree.maketreefrom(ConstObjArray,vp.BoundingBox,nil);
end;

function GDBObjComplex.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  Result:=ConstObjArray.onpoint(objects,point);
end;

procedure GDBObjComplex.SetInFrustumFromTree;
begin
  inherited;
  ConstObjArray.SetInFrustumFromTree(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  ConstObjArray.ObjTree.NodeData.infrustum:=Actuality.InfrustumActualy;
  ConstObjArray.ObjTree.BoundingBox:=vp.BoundingBox;
  ProcessTree(frustum,Actuality,ConstObjArray.ObjTree,IRFully,
    TDTFulDraw,Counters,ProjectProc,zoom,currentdegradationfactor);
end;

procedure GDBObjComplex.rtmodifyonepoint;
var
  m:TzeTypedMatrix4d;
begin
  m:=onematrix;
  if rtmod.point.pointtype=os_point then begin
    if rtmod.point.PDrawable=nil then
      Local.p_insert:=vectortransform3d(VertexAdd(rtmod.point.worldcoord,
        rtmod.dist),m)
    else
      Local.p_insert:=vectortransform3d(
        VertexSub(VertexAdd(rtmod.point.worldcoord,rtmod.dist),rtmod.point.dcoord),m);
  end;
end;

procedure GDBObjComplex.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_point then begin
    if pdesc.PDrawable=nil then begin
      pdesc.worldcoord:=self.P_insert_in_WCS;
      ProjectProc(pdesc.worldcoord,tv);
      pdesc.dispcoord:=ToTzePoint2i(tv);
    end else begin
      pdesc.worldcoord:=PGDBObjComplex(pdesc.PDrawable).P_insert_in_WCS;
      ProjectProc(pdesc.worldcoord,tv);
      pdesc.dispcoord:=ToTzePoint2i(tv);
      pdesc.dcoord:=vertexsub(PGDBObjComplex(pdesc.PDrawable).P_insert_in_WCS,
        P_insert_in_WCS);
    end;

  end;
end;

procedure GDBObjComplex.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;
  pdesc.pointtype:=os_point;
  pdesc.worldcoord:=self.P_insert_in_WCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

procedure GDBObjComplex.DrawGeometry;
var
  oldlw:smallint;
  oldColor:TGDBPaletteColor;
begin
  oldlw:=dc.OwnerLineWeight;
  oldColor:=dc.ownercolor;
  dc.OwnerLineWeight:=self.GetLineWeight;
  case vp.Color of
    ClByBlock:;
    ClByLayer:
      dc.ownercolor:=vp.Layer^.color;
    else
      dc.ownercolor:=vp.Color;
  end;
  Inc(dc.subrender);
  TZEntsManipulator.treerender(ConstObjArray.ObjTree,dc);
  if DC.SystmGeometryDraw then
    ConstObjArray.ObjTree.DrawVolume(dc);
  Dec(dc.subrender);
  dc.OwnerLineWeight:=oldlw;
  dc.ownercolor:=oldColor;
  inherited;
end;

procedure GDBObjComplex.getoutbound;
begin
  vp.BoundingBox:=ConstObjArray.getoutbound(dc);
end;

procedure GDBObjComplex.getonlyoutbound;
begin
  vp.BoundingBox:=ConstObjArray.getonlyoutbound(dc);
end;

function GDBObjComplex.getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
begin
  Result:=ConstObjArray.getonlyvisibleoutbound(dc);
end;

constructor GDBObjComplex.initnul;
begin
  inherited initnul(nil);
  ConstObjArray.init(3);
end;

constructor GDBObjComplex.init;
begin
  inherited init(own,layeraddres,LW);
  ConstObjArray.init(3);
end;

destructor GDBObjComplex.done;
begin
  ConstObjArray.Free;
  ConstObjArray.done;
  inherited done;
end;

function GDBObjComplex.CalcInFrustum(const frustum:TzeFrustum;
  const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double):boolean;
begin
  Result:=ConstObjArray.calcvisible(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  ProcessTree(frustum,Actuality,ConstObjArray.ObjTree,IRPartially,
    TDTFulDraw,Counters,ProjectProc,zoom,currentdegradationfactor);
end;

function GDBObjComplex.CalcTrueInFrustum;
begin
  Result:=ConstObjArray.CalcTrueInFrustum(frustum);
end;

procedure GDBObjComplex.FormatAfterDXFLoad;
var
  p:pgdbobjEntity;
  ir:itrec;
begin
  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.FormatAfterDXFLoad(drawing,dc);
      p:=ConstObjArray.iterate(ir);
    until p=nil;
  inherited;
end;

function GDBObjComplex.onmouse;
var
  p:pgdbobjEntity;
  ot:boolean;
  ir:itrec;
begin
  Result:=False;

  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      ot:=p^.isonmouse(popa,mf,InSubEntry);
      if ot then
        popa.PushBackData(p);
      Result:=Result or ot;
      p:=ConstObjArray.iterate(ir);
    until p=nil;
end;

procedure GDBObjComplex.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  calcobjmatrix;
  ConstObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  self.BuildGeometry(drawing);
  CalcActualVisible(dc.DrawingContext.VActuality);
end;

begin
end.
