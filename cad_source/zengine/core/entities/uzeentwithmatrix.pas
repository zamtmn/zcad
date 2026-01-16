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
unit uzeentwithmatrix;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzgldrawcontext,uzedrawingdef,uzecamera,uzeentity,gzctnrVectorTypes,
  uzegeometrytypes,uzegeometry,uzeentsubordinated,uzeentitiestree,
  uzeTypes;

type
  PGDBObjWithMatrix=^GDBObjWithMatrix;

  GDBObjWithMatrix=object(GDBObjEntity)
    protected
    fObjMatrix:TzeTypedMatrix4d;
    procedure SetObjMatrix(const AObjMatrix:TzeTypedMatrix4d);virtual;
    public
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    function GetMatrix:PzeTypedMatrix4d;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure createfield;virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure ReCalcFromObjMatrix;virtual;abstract;
    procedure CalcInFrustumByTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;
      var enttree:TEntTreeNode;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;
    procedure ProcessTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var enttree:TEntTreeNode;
      OwnerInFrustum:TInBoundingVolume;OwnerFuldraw:TDrawType;
      var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;

     property ObjMatrix:TzeTypedMatrix4d read fObjMatrix write SetObjMatrix;
  end;

implementation

procedure GDBObjWithMatrix.SetObjMatrix(const AObjMatrix:TzeTypedMatrix4d);
begin
  fObjMatrix:=AObjMatrix;
end;

procedure GDBObjWithMatrix.ProcessTree(const frustum:TzeFrustum;
  const Actuality:TVisActuality;var enttree:TEntTreeNode;
  OwnerInFrustum:TInBoundingVolume;OwnerFuldraw:TDrawType;
  var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double);
var
  ImInFrustum:TInBoundingVolume;
  pobj:PGDBObjEntity;
  ir:itrec;
  v1:TzePoint3d;
  tx:double;
  inFrustomEnts:integer;
begin
  if OwnerFuldraw=TDTFulDraw then begin
    {вариант с точным расчетом - медленный((}
    {gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.LBN.y,
      enttree.BoundingBox.LBN.Z),v1);
    bb.LBN:=v1;
    bb.RTF:=v1;
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,
      enttree.BoundingBox.LBN.Z),v1);
    concatBBandPoint(bb,v1);
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.RTF.y,
      enttree.BoundingBox.LBN.Z),v1);
    concatBBandPoint(bb,v1);
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,
      enttree.BoundingBox.LBN.Z),v1);
    concatBBandPoint(bb,v1);

    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.LBN.y,
      enttree.BoundingBox.RTF.Z),v1);
    concatBBandPoint(bb,v1);
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,
      enttree.BoundingBox.RTF.Z),v1);
    concatBBandPoint(bb,v1);
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.RTF.y,
      enttree.BoundingBox.RTF.Z),v1);
    concatBBandPoint(bb,v1);
    gdb.GetCurrentDWG^.myGluProject2(
      createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,
      enttree.BoundingBox.RTF.Z),v1);
    concatBBandPoint(bb,v1);
    v1:=bb.RTF;
    v2:=bb.LBN;}

    {вариант с  неточным расчетом - неточный}
    {ProjectProc(enttree.BoundingBox.LBN,v1);
    ProjectProc(enttree.BoundingBox.RTF,v2);
    if abs((v2.x-v1.x)*(v2.y-v1.y))<10 then begin
      ProjectProc(
        createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,
        enttree.BoundingBox.LBN.Z),v1);
      ProjectProc(
        createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,
        enttree.BoundingBox.RTF.Z),v2);
      if abs((v2.x-v1.x)*(v2.y-v1.y))<10 then
        enttree.
          FulDraw:=False
      else
        enttree.
          FulDraw:=True;
    end else
      enttree.FulDraw:=True;}

    v1:=uzegeometry.VertexSub(enttree.BoundingBox.RTF,enttree.BoundingBox.LBN);
    tx:=uzegeometry.oneVertexlength(v1);
    if tx/zoom<currentdegradationfactor then
      enttree.NodeData.FulDraw:=TDTSimpleDraw
    else
      enttree.NodeData.FulDraw:=TDTFulDraw;
  end else
    enttree.NodeData.FulDraw:=TDTSimpleDraw;
  case OwnerInFrustum of
    //IREmpty:begin
    //  OwnerInFrustum:=OwnerInFrustum;
    //end;
    IRFully:begin
      enttree.NodeData.infrustum:=Actuality.infrustumactualy;
      enttree.NodeData.inFrustumState:=IRFully;
      enttree.NodeData.InFrustumBoundingBox:=enttree.BoundingBox;
      pobj:=enttree.NodeData.NeedToSeparated.beginiterate(ir);
      if pobj<>nil then
        repeat
          pobj^.SetInFrustumFromTree(
            frustum,Actuality,Counters,
            ProjectProc,zoom,currentdegradationfactor);
          pobj:=enttree.NodeData.NeedToSeparated.iterate(ir);
        until pobj=nil;
      if assigned(enttree.pminusnode) then
        ProcessTree(
          frustum,Actuality,PTEntTreeNode(enttree.pminusnode)^,
          IRFully,enttree.NodeData.FulDraw,Counters,ProjectProc,
          zoom,currentdegradationfactor);
      if assigned(enttree.pplusnode) then
        ProcessTree(
          frustum,Actuality,PTEntTreeNode(enttree.pplusnode)^,
          IRFully,enttree.NodeData.FulDraw,Counters,ProjectProc,
          zoom,currentdegradationfactor);
    end;
    IRPartially:begin
      ImInFrustum:=CalcAABBInFrustum(enttree.BoundingBox,frustum);
      enttree.NodeData.inFrustumState:=ImInFrustum;
      case ImInFrustum of
        //IREmpty:begin
        //  OwnerInFrustum:=OwnerInFrustum;
        //end;
        IRFully:begin
          enttree.NodeData.infrustum:=Actuality.infrustumactualy;
          enttree.NodeData.InFrustumBoundingBox:=enttree.BoundingBox;
          pobj:=enttree.NodeData.NeedToSeparated.beginiterate(ir);
          if pobj<>nil then
            repeat
              pobj^.SetInFrustumFromTree(
                frustum,Actuality,Counters,
                ProjectProc,zoom,currentdegradationfactor);
              pobj:=enttree.NodeData.NeedToSeparated.iterate(ir);
            until pobj=nil;
          if assigned(enttree.pminusnode) then
            ProcessTree(frustum
              ,Actuality,PTEntTreeNode(enttree.pminusnode)^,
              ImInFrustum,enttree.NodeData.FulDraw,Counters,ProjectProc,
              zoom,currentdegradationfactor);
          if assigned(enttree.pplusnode) then
            ProcessTree(frustum,Actuality,
              PTEntTreeNode(enttree.pplusnode)^,ImInFrustum,
              enttree.NodeData.FulDraw,Counters,
              ProjectProc,zoom,currentdegradationfactor);

        end;
        IRPartially:begin
          enttree.NodeData.infrustum:=Actuality.infrustumactualy;
          inFrustomEnts:=0;
          pobj:=enttree.nul.beginiterate(ir);
          if pobj<>nil then
            repeat
              {if pobj^.CalcInFrustum(
                frustum,Actuality,Counters,
                ProjectProc,zoom,currentdegradationfactor) then} begin
                {pobj^.SetInFrustumFromTree(
                  frustum,Actuality,Counters,
                  ProjectProc,zoom,currentdegradationfactor);}
                if inFrustomEnts=0 then
                  enttree.NodeData.InFrustumBoundingBox:=pobj^.vp.BoundingBox
                else
                  ConcatBB(enttree.NodeData.InFrustumBoundingBox,pobj^.vp.BoundingBox);
                Inc(inFrustomEnts);
              end;
              pobj:=enttree.nul.iterate(ir);
            until pobj=nil;

          pobj:=enttree.NodeData.NeedToSeparated.beginiterate(ir);
          if pobj<>nil then
            repeat
              {if pobj^.CalcInFrustum(
                frustum,Actuality,Counters,
                ProjectProc,zoom,currentdegradationfactor) then} begin
                pobj^.SetInFrustumFromTree(
                  frustum,Actuality,Counters,
                  ProjectProc,zoom,currentdegradationfactor);
                if inFrustomEnts=0 then
                  enttree.NodeData.InFrustumBoundingBox:=pobj^.vp.BoundingBox
                else
                  ConcatBB(enttree.NodeData.InFrustumBoundingBox,pobj^.vp.BoundingBox);
                Inc(inFrustomEnts);
              end;
              pobj:=enttree.NodeData.NeedToSeparated.iterate(ir);
            until pobj=nil;

          if assigned(enttree.pminusnode) then begin
            ProcessTree(
              frustum,Actuality,PTEntTreeNode(enttree.pminusnode)^,
              IRPartially,enttree.NodeData.FulDraw,Counters,ProjectProc,
              zoom,currentdegradationfactor);
            if PTEntTreeNode(enttree.pminusnode)^.NodeData.infrustum=
              Actuality.infrustumactualy then begin
              if inFrustomEnts=0 then
                enttree.NodeData.InFrustumBoundingBox:=
                  PTEntTreeNode(enttree.pminusnode)^.BoundingBox
              else
                ConcatBB(enttree.NodeData.InFrustumBoundingBox,
                  PTEntTreeNode(enttree.pminusnode)^.BoundingBox);
              Inc(inFrustomEnts);
            end;

          end;
          if assigned(enttree.pplusnode) then begin
            ProcessTree(
              frustum,Actuality,PTEntTreeNode(enttree.pplusnode)^,
              IRPartially,enttree.NodeData.FulDraw,Counters,ProjectProc,
              zoom,currentdegradationfactor);
            if PTEntTreeNode(enttree.pplusnode)^.NodeData.infrustum=
              Actuality.infrustumactualy then begin
              if inFrustomEnts=0 then
                enttree.NodeData.InFrustumBoundingBox:=
                  PTEntTreeNode(enttree.pplusnode)^.BoundingBox
              else
                ConcatBB(enttree.NodeData.InFrustumBoundingBox,
                  PTEntTreeNode(enttree.pplusnode)^.BoundingBox);
              Inc(inFrustomEnts);
            end;
          end;

          if inFrustomEnts=0 then
            enttree.NodeData.InFrustumBoundingBox:={BBNul}enttree.BoundingBox;
        end;
        IRNotAplicable,IREmpty:
          enttree.NodeData.InFrustumBoundingBox:=BBNul;
      end;

    end;
    IRNotAplicable,IREmpty:
      enttree.NodeData.InFrustumBoundingBox:=BBNul;
  end;
end;

procedure GDBObjWithMatrix.CalcInFrustumByTree(const frustum:TzeFrustum;
  const Actuality:TVisActuality;
  var enttree:TEntTreeNode;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
  const zoom,currentdegradationfactor:double);
begin
  ProcessTree(frustum,Actuality,enttree,IRPartially,TDTFulDraw,
    Counters,ProjectProc,zoom,currentdegradationfactor);
end;

procedure GDBObjWithMatrix.transform(const t_matrix:TzeTypedMatrix4d);
begin
  ObjMatrix:=uzegeometry.MatrixMultiply(ObjMatrix,t_matrix);
end;

procedure GDBObjWithMatrix.createfield;
begin
  inherited;
  objmatrix:=onematrix;
end;

function GDBObjWithMatrix.GetMatrix;
begin
  Result:=@ObjMatrix;
end;

procedure GDBObjWithMatrix.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  CalcObjMatrix;
  CalcActualVisible(dc.DrawingContext.VActuality);
end;

constructor GDBObjWithMatrix.initnul;
begin
  inherited initnul(owner);
  objmatrix:=onematrix;
  CalcObjMatrix;
end;

begin
end.
