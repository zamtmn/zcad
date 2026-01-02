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
unit uzeentabstracttext;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,UGDBSelectedObjArray,uzgldrawcontext,uzeentity,uzecamera,uzbstrproc,
  uzeentplainwithox,uzegeometrytypes,uzbtypes,uzeTypes,uzegeometry,Math,
  uzglviewareadata,uzeSnap,uzedrawingdef,uzCtnrVectorpBaseEntity;

type

  TTextJustify=(jstl(*'TopLeft'*),
                jstc(*'TopCenter'*),
                jstr(*'TopRight'*),
                jsml(*'MiddleLeft'*),
                jsmc(*'MiddleCenter'*), //СерединаЦентр
                jsmr(*'MiddleRight'*),
                jsbl(*'BottomLeft'*),
                jsbc(*'BottomCenter'*),
                jsbr(*'BottomRight'*),
                jsbtl(*'Left'*),
                jsbtc(*'Center'*),
                jsbtr(*'Right'*));

  PGDBTextProp=^GDBTextProp;

  GDBTextProp=record
    size:double;
    oblique:double;
    wfactor:double;
    justify:TTextJustify;
    upsidedown:boolean;
    backward:boolean;
  end;
  PGDBObjAbstractText=^GDBObjAbstractText;

  GDBObjAbstractText=object(GDBObjPlainWithOX)
    textprop:GDBTextProp;
    P_drawInOCS:TzePoint3d;
    DrawMatrix:TzeTypedMatrix4d;
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
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
    procedure ReCalcFromObjMatrix;virtual;
    function CalcRotate:double;virtual;
    procedure setrot(r:double);
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure rtsave(refp:Pointer);virtual;
  end;

var
  SysVarRDPanObjectDegradation:boolean=False;

implementation

procedure GDBObjAbstractText.rtsave(refp:Pointer);
begin
  inherited;
  PGDBObjAbstractText(refp)^.textprop:=textprop;
end;


procedure GDBObjAbstractText.transform;
var
  tv:TzePoint3d;
  m:TzeTypedMatrix4d;
begin
  tv:=CreateVertex(0,textprop.size,0);
  m:=t_matrix;
  PzePoint3d(@m.mtr.v[3])^:=NulVertex;

  tv:=VectorTransform3d(tv,m);
  textprop.size:=oneVertexlength(tv);
  inherited;
end;

procedure GDBObjAbstractText.setrot(r:double);
var
  m1:TzeTypedMatrix4d;
begin
  m1:=CreateRotationMatrixZ(r);
  objMatrix:=MatrixMultiply(m1,objMatrix);
end;


procedure GDBObjAbstractText.ReCalcFromObjMatrix;
begin
  inherited;
  Local.basis.ox:=PzePoint3d(@objmatrix.mtr.v[0])^;
  Local.basis.oy:=PzePoint3d(@objmatrix.mtr.v[1])^;

  Local.basis.ox:=normalizevertex(Local.basis.ox);
  Local.basis.oy:=normalizevertex(Local.basis.oy);
  Local.basis.oz:=normalizevertex(Local.basis.oz);

  Local.P_insert:=PzePoint3d(@objmatrix.mtr.v[3])^;
end;

function GDBObjAbstractText.CalcRotate:double;
var
  v1,v2:TzePoint3d;
  l1,l0:double;
begin

  if bp.ListPos.owner<>nil then begin
    V1:=PzePoint3d(@bp.ListPos.owner^.GetMatrix^.mtr.v[0])^;
    l0:=scalardot(NormalizeVertex(V1),_X_yzVertex);
    l0:=arccos(l0);
    if v1.y<-eps then
      l0:=2*pi-l0;
  end else
    l0:=0;

  V1:=Local.basis.ox;
  V2:=GetXfFromZ(Local.basis.oz);
  l1:=scalardot(v1,v2);
  l1:=arccos(l1);
  if v1.y<-eps then
    l1:=2*pi-l1;
  l1:=l1+L0;
  if l1>2*pi then
    l1:=l1-2*pi;
  Result:=l1;
end;

procedure GDBObjAbstractText.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_point then begin
    pdesc.worldcoord:=P_insert_in_WCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

procedure GDBObjAbstractText.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;
  pdesc.pointtype:=os_point;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=P_insert_in_WCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

function GDBObjAbstractText.onmouse;
var
  subresult:TInBoundingVolume;
begin
  Result:=False;
  subresult:=CalcOutBound4VInFrustum(outbound,mf);
  if subresult<>IRPartially then
    if subresult=irempty then
      exit
    else begin
      Result:=True;
      exit;
    end;

  if Representation.CalcTrueInFrustum(mf,False)<>IREmpty then
    Result:=True
  else
    Result:=False;
end;

function GDBObjAbstractText.CalcInFrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum.v[i].v[0]*outbound[0].x+frustum.v[i].v[1]*outbound[0].y+
        frustum.v[i].v[2]*outbound[0].z+frustum.v[i].v[3]<0)  and
       (frustum.v[i].v[0]*outbound[1].x+frustum.v[i].v[1]*outbound[1].y+
        frustum.v[i].v[2]*outbound[1].z+frustum.v[i].v[3]<0)  and
       (frustum.v[i].v[0]*outbound[2].x+frustum.v[i].v[1]*outbound[2].y+
        frustum.v[i].v[2]*outbound[2].z+frustum.v[i].v[3]<0)  and
       (frustum.v[i].v[0]*outbound[3].x+frustum.v[i].v[1]*outbound[3].y+
        frustum.v[i].v[2]*outbound[3].z+frustum.v[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjAbstractText.CalcTrueInFrustum;
begin
  Result:=CalcOutBound4VInFrustum(outbound,frustum);
  if Result<>IRPartially then
    exit;
  Result:=Representation.CalcTrueInFrustum(frustum,True);
end;

procedure GDBObjAbstractText.CalcObjMatrix;
var
  m1,m2,m3:TzeTypedMatrix4d;
  angle:double;
begin
  inherited CalcObjMatrix;
  if textprop.upsidedown then begin
    PzePoint3d(@objmatrix.mtr.v[1])^.x:=-Local.basis.oy.x;
    PzePoint3d(@objmatrix.mtr.v[1])^.y:=-Local.basis.oy.y;
    PzePoint3d(@objmatrix.mtr.v[1])^.z:=-Local.basis.oy.z;
  end;
  if textprop.backward then begin
    PzePoint3d(@objmatrix.mtr.v[0])^.x:=-Local.basis.ox.x;
    PzePoint3d(@objmatrix.mtr.v[0])^.y:=-Local.basis.ox.y;
    PzePoint3d(@objmatrix.mtr.v[0])^.z:=-Local.basis.ox.z;
  end;
  m1:=OneMatrix;
  objMatrix:=MatrixMultiply(m1,objMatrix);

  angle:=(pi/2-textprop.oblique);
  if abs(angle-pi/2)>eps then begin
    m1.CreateRec(OneMtr,CMTShear);
    m1.mtr.v[1].v[0]:=cotan(angle);
  end else
    m1:=OneMatrix;

  m2:=CreateTranslationMatrix(P_drawInOCS);

  m3:=CreateScaleMatrix(textprop.wfactor*textprop.size,textprop.size,textprop.size);

  DrawMatrix:=MatrixMultiply(m3,m1);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);
end;

procedure GDBObjAbstractText.DrawGeometry;
var
  PanObjectDegradation:boolean;
begin
  dc.subrender:=dc.subrender+1;
  PanObjectDegradation:=SysVarRDPanObjectDegradation;
  if (not dc.scrollmode)or(not PanObjectDegradation) then
    Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState)
  else begin
    DC.Drawer.DrawLine3DInModelSpace(outbound[0],outbound[1],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[1],outbound[2],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[2],outbound[3],DC.DrawingContext.matrixs);
    DC.Drawer.DrawLine3DInModelSpace(outbound[3],outbound[0],DC.DrawingContext.matrixs);
  end;
  dc.subrender:=dc.subrender-1;
  inherited;
end;

begin
end.
