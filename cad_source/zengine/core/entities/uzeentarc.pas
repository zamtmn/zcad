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
unit uzeentarc;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
    uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzeentwithlocalcs,
    uzecamera,uzestyleslayers,UGDBSelectedObjArray,
    uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,uzctnrVectorBytes,uzbtypes,
    uzegeometrytypes,uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentplain,
    uzeSnap,math,uzMVReader,uzCtnrVectorpBaseEntity;

type

PGDBObjArc=^GDBObjARC;
GDBObjArc= object(GDBObjPlain)
                 R:Double;
                 StartAngle:Double;
                 EndAngle:Double;
                 angle:Double;
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 q0:GDBvertex;
                 q1:GDBvertex;
                 q2:GDBvertex;
                 pq0:GDBvertex;
                 pq1:GDBvertex;
                 pq2:GDBvertex;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex;RR,S,E:Double);
                 constructor initnul;
                 procedure LoadFromDXF(var f:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                 procedure precalc;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure createpoints(var DC:TDrawContext);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 function beforertmodify:Pointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;virtual;
                 procedure SetFromClone(_clone:PGDBObjEntity);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 destructor done;virtual;
                 function GetObjTypeName:String;virtual;
                 function calcinfrustum(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 function CalcTrueInFrustum(const frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure ReCalcFromObjMatrix;virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 //function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;

                 class function CreateInstance:PGDBObjArc;static;
                 function GetObjType:TObjID;virtual;
           end;

implementation
//uses log;
{function GDBObjARC.GetTangentInPoint(point:GDBVertex):GDBVertex;
var
   m1:DMatrix4D;
   td,td2,td3,slbegin,slend,t1,t2,llbegin_x2,llbegin_y2,llend_x2,llend_y2:double;
   llbegin,llend:gdbvertex;
begin
     m1:=GetMatrix^;
     MatrixInvert(m1);
     result:=VectorTransform3D(point,m1);
     result:=normalizevertex(result);
end;}

procedure GDBObjARC.TransformAt;
var
    tv:GDBVertex4D;
begin
    objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);

    tv:=PGDBVertex4D(@t_matrix[3])^;
    PGDBVertex4D(@t_matrix[3])^:=NulVertex4D;
    //MajorAxis:=VectorTransform3D(PGDBObjEllipse(p)^.MajorAxis,t_matrix^);
    PGDBVertex4D(@t_matrix[3])^:=tv;

     {Local.oz:=PGDBVertex(@objmatrix[2])^;

     Local.p_insert:=PGDBVertex(@objmatrix[3])^;}ReCalcFromObjMatrix;
end;
function GDBObjARC.onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;
begin
     if Vertex3D_in_WCS_Array.onpoint(point,false) then
                                                                                  begin
                                                                                    result:=true;
                                                                                    objects.PushBackData(@self);
                                                                                  end
                                                                                else
                                                                                    result:=false;
end;

procedure GDBObjARC.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
var
   m1:DMatrix4D;
   //td,td2,td3,slbegin,slend,t1,t2,llbegin_x2,llbegin_y2,llend_x2,llend_y2:double;
   dir,tv:gdbvertex;
begin
     m1:=GetMatrix^;
     MatrixInvert(m1);
     dir:=VectorTransform3D(posr.worldcoord,m1);

     processaxis(posr,dir);
     //posr.arrayworldaxis.Add(@dir);
     tv:=uzegeometry.vectordot(dir,zwcs);
     processaxis(posr,tv);
     //posr.arrayworldaxis.Add(@tv);

end;

procedure GDBObjARC.transform;
var
  sav,eav,pins:gdbvertex;
begin
  precalc;
  if t_matrix[0].v[0]*t_matrix[1].v[1]*t_matrix[2].v[2]<eps then begin
    sav:=q2;
    eav:=q0;
  end else begin
    sav:=q0;
    eav:=q2;
  end;
  pins:=P_insert_in_WCS;
  sav:=VectorTransform3D(sav,t_matrix);
  eav:=VectorTransform3D(eav,t_matrix);
  pins:=VectorTransform3D(pins,t_matrix);
  inherited;
  sav:=NormalizeVertex(VertexSub(sav,pins));
  eav:=NormalizeVertex(VertexSub(eav,pins));

  StartAngle:=TwoVectorAngle(_X_yzVertex,sav);
  if sav.y<eps then StartAngle:=2*pi-StartAngle;

  EndAngle:=TwoVectorAngle(_X_yzVertex,eav);
  if eav.y<eps then EndAngle:=2*pi-EndAngle;
end;

procedure GDBObjARC.ReCalcFromObjMatrix;
var
  ox,oy:gdbvertex;
  m:DMatrix4D;
begin
     inherited;

     ox:=GetXfFromZ(Local.basis.oz);
     oy:=NormalizeVertex(CrossVertex(Local.basis.oz,Local.basis.ox));
     m:=CreateMatrixFromBasis(ox,oy,Local.basis.oz);

     Local.P_insert:=VectorTransform3D(PGDBVertex(@objmatrix[3])^,m);
     self.R:=PGDBVertex(@objmatrix[0])^.x/local.basis.OX.x;
end;
function GDBObjARC.CalcTrueInFrustum;
var
  i:Integer;
  rad:Double;
begin
  rad:=abs(ObjMatrix[0].v[0]);
  for i:=0 to 5 do
    if(frustum[i].v[0] * P_insert_in_WCS.x + frustum[i].v[1] * P_insert_in_WCS.y + frustum[i].v[2] * P_insert_in_WCS.z + frustum[i].v[3]+rad{+GetLTCorrectH} < 0 ) then
      exit(IREmpty);
  result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,false);
end;
function GDBObjARC.calcinfrustum;
var i:Integer;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i].v[0] * outbound[0].x + frustum[i].v[1] * outbound[0].y + frustum[i].v[2] * outbound[0].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[1].x + frustum[i].v[1] * outbound[1].y + frustum[i].v[2] * outbound[1].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[2].x + frustum[i].v[1] * outbound[2].y + frustum[i].v[2] * outbound[2].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * outbound[3].x + frustum[i].v[1] * outbound[3].y + frustum[i].v[2] * outbound[3].z + frustum[i].v[3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjARC.GetObjTypeName;
begin
     result:=ObjN_GDBObjArc;
end;
destructor GDBObjARC.done;
begin
     inherited done;
     //Vertex3D_in_WCS_Array.Clear;
     Vertex3D_in_WCS_Array.Done;
end;
constructor GDBObjARC.initnul;
begin
  inherited initnul(nil);
  //vp.ID := GDBArcID;
  r := 1;
  startangle := 0;
  endangle := pi/2;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init(3);
end;
constructor GDBObjARC.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBArcID;
  Local.p_insert := p;
  r := rr;
  startangle := s;
  endangle := e;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init(3);
  //format;
end;
function GDBObjArc.GetObjType;
begin
     result:=GDBArcID;
end;
procedure GDBObjArc.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'ARC','AcDbCircle',IODXFContext);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfDoubleout(outhandle,40,r);
    SaveToDXFObjPostfix(outhandle);

  dxfStringout(outhandle,100,'AcDbArc');
  //WriteString_EOL(outhandle, '100');
  //WriteString_EOL(outhandle, 'AcDbArc');
  dxfDoubleout(outhandle,50,startangle * 180 / pi);
  dxfDoubleout(outhandle,51,endangle * 180 / pi);
end;
procedure GDBObjARC.CalcObjMatrix;
var m1:DMatrix4D;
    v:GDBvertex4D;
begin
  inherited CalcObjMatrix;
  m1:=ONEMATRIX;
  m1[0].v[0] := r;
  m1[1].v[1] := r;
  m1[2].v[2] := r;
  //m1[3, 3] := r;
  objmatrix:=matrixmultiply(m1,objmatrix);

    pgdbvertex(@v)^:=local.p_insert;
  v.z:=0;
  v.w:=1;
  m1:=objMatrix;
  MatrixInvert(m1);
  v:=VectorTransform(v,m1);
end;
procedure GDBObjARC.precalc;
var
  v:GDBvertex4D;
begin
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;
  SinCos(startangle,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q0:=pgdbvertex(@v)^;
  SinCos(startangle+angle/2,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q1:=pgdbvertex(@v)^;
  SinCos(endangle,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q2:=pgdbvertex(@v)^;
end;

procedure GDBObjARC.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  calcObjMatrix;
  precalc;

  calcbb(dc);
  createpoints(dc);
  Representation.Clear;
  if not (ESTemp in State)and(DCODrawable in DC.Options) then
    Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,false,false);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjARC.getoutbound;
function getQuadrant(a:Double):integer;
{
2|1
---
3|4
}
begin
      if a<pi/2 then
                    result:=0
    else
      if a<pi then
                    result:=1
    else
      if a<3*pi/2 then
                    result:=2
    else
                    result:=3
end;
function AxisIntersect(q1,q2:integer):integer;
{
  2
 2|1
4---1
 3|4
  8
}
begin
     result:=0;
     while q1<>q2 do
     begin
          inc(q1);
          //if q1=4 then q1:=0;
          q1:=q1 and 3;
          result:=result or (1 shl q1);
     end;
end;
var
    sx,sy,ex,ey,minx,miny,maxx,maxy:Double;
    {i,}sq,eq,q:integer;
begin
  vp.BoundingBox:=CreateBBFrom2Point(q0,q2);
  //concatBBandPoint(vp.BoundingBox,q1);
         sq:=getQuadrant(self.StartAngle);
         eq:=getQuadrant(self.EndAngle);
         q:=AxisIntersect(sq,eq);
         if (self.StartAngle>self.EndAngle)and(q=0) then
                                              q:=q xor 15;
         SinCos(self.StartAngle,sy,sx);
         SinCos(self.EndAngle,ey,ex);
         if sx>ex then
                      begin
                           minx:=ex;
                           maxx:=sx
                      end
                  else
                      begin
                           minx:=sx;
                           maxx:=ex
                      end;
         if sy>ey then
                      begin
                           miny:=ey;
                           maxy:=sy
                      end
                  else
                      begin
                           miny:=sy;
                           maxy:=ey
                      end;
  if (q and 1)>0 then
                     begin
                     concatBBandPoint(vp.BoundingBox,VectorTransform3d(CreateVertex(1,0,0),objMatrix));
                     //concatBBandPoint(vp.BoundingBox,vertexadd(P_insert_in_WCS,VertexMulOnSc(local.Basis.ox,r)));
                     maxx:=1;
                     end;
  if (q and 4)>0 then
                     begin
                     concatBBandPoint(vp.BoundingBox,VectorTransform3d(CreateVertex(-1,0,0),objMatrix));
                     //concatBBandPoint(vp.BoundingBox,vertexadd(P_insert_in_WCS,VertexMulOnSc(local.Basis.ox,-r)));
                     minx:=-1;
                     end;
  if (q and 2)>0 then
                     begin
                     concatBBandPoint(vp.BoundingBox,VectorTransform3d(CreateVertex(0,1,0),objMatrix));
                     //concatBBandPoint(vp.BoundingBox,vertexadd(P_insert_in_WCS,VertexMulOnSc(local.Basis.oy,r)));
                     maxy:=1;
                     end;
  if (q and 8)>0 then
                     begin
                     concatBBandPoint(vp.BoundingBox,VectorTransform3d(CreateVertex(0,-1,0),objMatrix));
                     //concatBBandPoint(vp.BoundingBox,vertexadd(P_insert_in_WCS,VertexMulOnSc(local.Basis.oy,-r)));
                     miny:=-1;
                     end;

         outbound[0]:=VectorTransform3d(CreateVertex(minx,maxy,0),objMatrix);
         outbound[1]:=VectorTransform3d(CreateVertex(maxx,maxy,0),objMatrix);
         outbound[2]:=VectorTransform3d(CreateVertex(maxx,miny,0),objMatrix);
         outbound[3]:=VectorTransform3d(CreateVertex(minx,miny,0),objMatrix);


  if PProjoutbound=nil then
  begin
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;
end;
procedure GDBObjARC.createpoints(var DC:TDrawContext);
var
  i: Integer;
  l: Double;
  v:GDBvertex;
  pv:GDBVertex;
  maxlod:integer;
begin
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;

  if dc.MaxDetail then
                      maxlod:=100
                  else
                      maxlod:=60;

  l:=r*angle/(dc.DrawingContext.zoom{*dc.DrawingContext.zoom}*10);
  if (l>maxlod)or dc.MaxDetail then lod:=maxlod
           else
               begin
                    lod:=round(l);
                    if lod<5 then lod:=5;
               end;
  Vertex3D_in_WCS_Array.SetSize(lod+1);

  Vertex3D_in_WCS_Array.clear;
  SinCos(startangle,v.y,v.x);
  v.z:=0;
  pv:=VectorTransform3D(v,objmatrix);
  Vertex3D_in_WCS_Array.PushBackData(pv);

  for i:=1 to lod do
  begin
              SinCos(startangle+i / lod * angle,v.y,v.x);
              v.z:=0;
              pv:=VectorTransform3D(v,objmatrix);
              Vertex3D_in_WCS_Array.PushBackData(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjARC.Renderfeedback;
var //pm:DMatrix4D;
    tv:GDBvertex;
    //d:Double;
begin
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(Local.p_insert,ProjP_insert);
           pprojoutbound^.clear;
           //pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[0],tv);
           pprojoutbound^.PushBackIfNotLastWithCompareProc(ToVertex2DI(tv),EqualVertex2DI);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[1],tv);
           pprojoutbound^.PushBackIfNotLastWithCompareProc(ToVertex2DI(tv),EqualVertex2DI);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[2],tv);
           pprojoutbound^.PushBackIfNotLastWithCompareProc(ToVertex2DI(tv),EqualVertex2DI);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[3],tv);
           pprojoutbound^.PushBackIfNotLastOrFirstWithCompareProc(ToVertex2DI(tv),EqualVertex2DI);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(q0,pq0);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(q1,pq1);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(q2,pq2);
           (*if pprojoutbound^.count<4 then
           begin
            lod:=4;
            //projectpoint;
           end
           else
           begin
                d:=pprojoutbound^.perimetr;
                d:=(angle/(2*pi))*(d/10);
                if d>255 then d:=255;
                if d<10 then d:=10;
                if lod<>round(d) then
                begin
                     lod:=round(d);
                     createpoints(dc);
                end;
                projectpoint;
           end;*)
end;
procedure GDBObjARC.DrawGeometry;
var
//  i: Integer;
    simply:Boolean;
begin
  {oglsm.myglpushmatrix;
  glscaledf(r, r, 1);
  gltranslatef(p_insert.x / r, p_insert.y / r, p_insert.z);
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;
  myglbegin(GL_line_strip);
  glVertex3d(cos(startangle), sin(startangle), 0);
  for i := 1 to arccount do
  begin
    glVertex3d(cos(startangle + i / arccount * angle), sin(startangle + i / arccount * angle), 0);
  end;
  myglend;
  oglsm.myglpopmatrix;}


  //oglsm.myglpushmatrix;
  //glmultmatrixd(@objmatrix);
  if dc.selected then
                     begin
                     //Vertex3D_in_WCS_Array.drawgeometry2
                          Representation.DrawNiceGeometry(DC);
                     end
                 else
                     begin
                           {if endangle>startangle then
                                                      angle:=endangle-startangle
                                                  else
                                                      angle:=2*pi-(startangle-endangle);}
                           {if angle>pi then
                                           begin
                                               simply:=CanSimplyDrawInOCS(DC,r,20)
                                            end
                                       else begin
                                               simply:=CanSimplyDrawInOCS(DC,sin(angle/2)*tan(angle/4)*r,20)
                                            end;}
                         simply:=CanSimplyDrawInOCS(DC,angle,10);
                         if simply then
                                       begin
                                           //Vertex3D_in_WCS_Array.drawgeometry
                                           Representation.DrawGeometry(DC);
                                       end
                                                        else
                                                            begin
                                                                 DC.Drawer.DrawLine3DInModelSpace(q0,q1,DC.DrawingContext.matrixs);
                                                                 DC.Drawer.DrawLine3DInModelSpace(q1,q2,DC.DrawingContext.matrixs);
                                                            end;
                     end;
  //myglbegin(gl_points);
  //ppoint.iterategl(@glvertex2dv);
  //myglend;
  //oglsm.myglpopmatrix;
  inherited;

end;
procedure GDBObjARC.projectpoint;
//var pm:DMatrix4D;
//    tv:GDBvertex;
//    tpv:GDBPolyVertex2D;
//    ptpv:PGDBPolyVertex2D;
//    i:Integer;
begin

end;
procedure GDBObjARC.LoadFromDXF;
var //s: String;
  byt{, code}: Integer;
  dc:TDrawContext;
begin
  //initnul;
  byt:=f.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfDoubleload(f,40,byt,r) then
    if not dxfDoubleload(f,50,byt,startangle) then
    if not dxfDoubleload(f,51,byt,endangle) then {s := }f.SkipString;
    byt:=f.ParseInteger;
  end;
  startangle := startangle * pi / 180;
  endangle := endangle * pi / 180;
  PProjoutbound:=nil;
  dc:=drawing.createdrawingrc;
  if vp.Layer=nil then
                      vp.Layer:=nil;
  FormatEntity(drawing,dc);
end;
function GDBObjARC.onmouse;
var
 i:Integer;
 rad:Double;
begin
 rad:=abs(ObjMatrix[0].v[0]);
 for i:=0 to 5 do begin
   if(mf[i].v[0] * P_insert_in_WCS.x + mf[i].v[1] * P_insert_in_WCS.y + mf[i].v[2] * P_insert_in_WCS.z + mf[i].v[3]+rad < 0 ) then
   exit(false);
 end;
 result:=Vertex3D_in_WCS_Array.onmouse(mf,false);
 if not result then
   if CalcPointTrueInFrustum(P_insert_in_WCS,mf)=IRFully then
     result:=true;
end;
procedure GDBObjARC.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
  if pdesc^.pointtype=os_begin then begin
    pdesc.worldcoord:=q0;
    pdesc.dispcoord.x:=round(Pq0.x);
    pdesc.dispcoord.y:=round(Pq0.y);
  end else if pdesc^.pointtype=os_midle then begin
    pdesc.worldcoord:=q1;
    pdesc.dispcoord.x:=round(Pq1.x);
    pdesc.dispcoord.y:=round(Pq1.y);
  end else if pdesc^.pointtype=os_end then begin
    pdesc.worldcoord:=q2;
    pdesc.dispcoord.x:=round(Pq2.x);
    pdesc.dispcoord.y:=round(Pq2.y);
  end;
end;
procedure GDBObjARC.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(3);
          pdesc.selected:=false;
          pdesc.PDrawable:=nil;

          pdesc.pointtype:=os_begin;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=q0;
          {pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(Pq0.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_midle;
          pdesc.attr:=[];
          pdesc.worldcoord:=q1;
          {pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(Pq1.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_end;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=q1;
          {pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(Pq2.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
function GDBObjARC.getsnap;
//var t,d,e:Double;
  //  tv,n,v:gdbvertex;
begin
     if onlygetsnapcount=4 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (SnapMode and osm_center)<>0
            then
            begin
            osp.worldcoord:=P_insert_in_WCS;
            osp.dispcoord:=ProjP_insert;
            osp.ostype:=os_center;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=q0;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq0)^;
            osp.ostype:=os_begin;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (SnapMode and osm_midpoint)<>0
            then
            begin
            osp.worldcoord:=q1;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq1)^;
            osp.ostype:=os_midle;
            end
            else osp.ostype:=os_none;
       end;
     3:begin
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=q2;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq2)^;
            osp.ostype:=os_end;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
function GDBObjARC.beforertmodify;
begin
     Getmem(result,sizeof(tarcrtmodify));
     tarcrtmodify(result^).p1.x:=q0.x;
     tarcrtmodify(result^).p1.y:=q0.y;
     tarcrtmodify(result^).p2.x:=q1.x;
     tarcrtmodify(result^).p2.y:=q1.y;
     tarcrtmodify(result^).p3.x:=q2.x;
     tarcrtmodify(result^).p3.y:=q2.y;
end;
function GDBObjARC.IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;
begin
     result:=true;
end;
procedure GDBObjARC.SetFromClone(_clone:PGDBObjEntity);
begin
     q0:=PGDBObjARC(_clone)^.q0;
     q1:=PGDBObjARC(_clone)^.q1;
     q2:=PGDBObjARC(_clone)^.q2;
end;

procedure GDBObjARC.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  tv3d:gdbvertex;
  tq0,tq1,tq2:gdbvertex;
  ptdata:tarcrtmodify;
  ad:TArcData;
  m:DMatrix4D;
begin
  m:=ObjMatrix;
  MatrixInvert(m);
  m[3]:=NulVector4D;

  tq0:=VectorTransform3D(q0*R,m);
  tq1:=VectorTransform3D(q1*R,m);
  tq2:=VectorTransform3D(q2*R,m);
  tv3d:=VectorTransform3D(rtmod.wc*R,m);

  ptdata.p1.x:=tq0.x;
  ptdata.p1.y:=tq0.y;
  ptdata.p2.x:=tq1.x;
  ptdata.p2.y:=tq1.y;
  ptdata.p3.x:=tq2.x;
  ptdata.p3.y:=tq2.y;

  if rtmod.point.pointtype=os_begin then begin
    ptdata.p1.x:=tv3d.x;
    ptdata.p1.y:=tv3d.y;
  end else if rtmod.point.pointtype=os_midle then begin
    ptdata.p2.x:=tv3d.x;
    ptdata.p2.y:=tv3d.y;
  end else if rtmod.point.pointtype=os_end then begin
    ptdata.p3.x:=tv3d.x;
    ptdata.p3.y:=tv3d.y;
  end;

  if GetArcParamFrom3Point2D(ptdata,ad) then begin
    Local.p_insert.x:=ad.p.x;
    Local.p_insert.y:=ad.p.y;
    Local.p_insert.z:=0;
    startangle:=ad.startangle;
    endangle:=ad.endangle;
    r:=ad.r;
  end;
end;
function GDBObjARC.Clone;
var tvo: PGDBObjArc;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjArc));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert, r,startangle,endangle);
  tvo^.Local.basis.oz:=Local.basis.oz;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjARC.rtsave;
begin
  pgdbobjarc(refp)^.Local.p_insert := Local.p_insert;
  pgdbobjarc(refp)^.startangle := startangle;
  pgdbobjarc(refp)^.endangle := endangle;
  pgdbobjarc(refp)^.r := r;
  //pgdbobjarc(refp)^.format;
  //pgdbobjarc(refp)^.renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
end;
function AllocArc:PGDBObjArc;
begin
  Getmem(pointer(result),sizeof(GDBObjArc));
end;
function AllocAndInitArc(owner:PGDBObjGenericWithSubordinated):PGDBObjArc;
begin
  result:=AllocArc;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
procedure SetArcGeomProps(AArc:PGDBObjArc; const args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  AArc^.Local.P_insert:=CreateVertexFromArray(counter,args);
  AArc^.R:=CreateDoubleFromArray(counter,args);
  AArc^.StartAngle:=CreateDoubleFromArray(counter,args);
  AArc^.EndAngle:=CreateDoubleFromArray(counter,args);
end;
function AllocAndCreateArc(owner:PGDBObjGenericWithSubordinated; const args:array of const):PGDBObjArc;
begin
  result:=AllocAndInitArc(owner);
  SetArcGeomProps(result,args);
end;

class function GDBObjARC.CreateInstance:PGDBObjArc;
begin
  result:=AllocAndInitArc(nil);
end;
begin
  RegisterDXFEntity(GDBArcID,'ARC','Arc',@AllocArc,@AllocAndInitArc,@SetArcGeomProps,@AllocAndCreateArc);
end.
