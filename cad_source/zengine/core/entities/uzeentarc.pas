{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE def.inc}
interface
uses
    uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzeentwithlocalcs,
    uzecamera,gzctnrvectorpobjects,uzestyleslayers,uzbtypesbase,UGDBSelectedObjArray,
    uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,UGDBOpenArrayOfByte,uzbtypes,
    uzbgeomtypes,uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzbmemman,uzeentplain;
type
{Export+}
{REGISTEROBJECTTYPE GDBObjArc}
PGDBObjArc=^GDBObjARC;
GDBObjArc= object(GDBObjPlain)
                 R:GDBDouble;(*saved_to_shd*)
                 StartAngle:GDBDouble;(*saved_to_shd*)
                 EndAngle:GDBDouble;(*saved_to_shd*)
                 angle:GDBDouble;(*oi_readonly*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 q0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR,S,E:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure CalcObjMatrix;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure createpoints(var DC:TDrawContext);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                 function beforertmodify:GDBPointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;
                 procedure SetFromClone(_clone:PGDBObjEntity);virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 destructor done;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure ReCalcFromObjMatrix;virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 //function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;

                 class function CreateInstance:PGDBObjArc;static;
                 function GetObjType:TObjID;virtual;
           end;
{EXPORT-}
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
function GDBObjARC.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
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
  if t_matrix[0][0]*t_matrix[1][1]*t_matrix[2][2]<eps then begin
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
//var
    //ox:gdbvertex;
begin
     inherited;
     Local.P_insert:=PGDBVertex(@objmatrix[3])^;
     self.R:=PGDBVertex(@objmatrix[0])^.x/local.basis.OX.x;
end;
function GDBObjARC.CalcTrueInFrustum;
var i{,count}:GDBInteger;
    //d1,d2,d3,d4:gdbdouble;
begin
      for i:=0 to 5 do
      begin
      if(frustum[i][0] * P_insert_in_WCS.x + frustum[i][1] * P_insert_in_WCS.y + frustum[i][2] * P_insert_in_WCS.z + frustum[i][3]+R < 0 )
      then
      begin
           result:=IREmpty;
           exit;
           //system.break;
      end;
      end;
      result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum);
end;
function GDBObjARC.calcinfrustum;
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i][0] * outbound[0].x + frustum[i][1] * outbound[0].y + frustum[i][2] * outbound[0].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[1].x + frustum[i][1] * outbound[1].y + frustum[i][2] * outbound[1].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[2].x + frustum[i][1] * outbound[2].y + frustum[i][2] * outbound[2].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[3].x + frustum[i][1] * outbound[3].y + frustum[i][2] * outbound[3].z + frustum[i][3] < 0 )
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
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{7E7B2243-1D9C-43AD-BB6B-959FE9F49D5D}-GDBObjARC.Vertex3D_in_WCS_Array',{$ENDIF}100);
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
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{AEF4273C-4EE8-4520-B23A-04C3AD6DABE3}',{$ENDIF}100);
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
  dxfGDBDoubleout(outhandle,40,r);
    SaveToDXFObjPostfix(outhandle);

  dxfGDBStringout(outhandle,100,'AcDbArc');
  //WriteString_EOL(outhandle, '100');
  //WriteString_EOL(outhandle, 'AcDbArc');
  dxfGDBDoubleout(outhandle,50,startangle * 180 / pi);
  dxfGDBDoubleout(outhandle,51,endangle * 180 / pi);
end;
procedure GDBObjARC.CalcObjMatrix;
var m1:DMatrix4D;
    v:GDBvertex4D;
begin
  inherited CalcObjMatrix;
  m1:=ONEMATRIX;
  m1[0, 0] := r;
  m1[1, 1] := r;
  m1[2, 2] := r;
  //m1[3, 3] := r;
  objmatrix:=matrixmultiply(m1,objmatrix);

    pgdbvertex(@v)^:=local.p_insert;
  v.z:=0;
  v.w:=1;
  m1:=objMatrix;
  MatrixInvert(m1);
  v:=VectorTransform(v,m1);
end;
procedure GDBObjARC.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var
  v:GDBvertex4D;
begin
  calcObjMatrix;
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;
  v.x:=cos(startangle{*pi/180});
  v.y:=sin(startangle{*pi/180});
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q0:=pgdbvertex(@v)^;
  v.x:=cos(startangle+angle{*pi/180}/2);
  v.y:=sin(startangle+angle{*pi/180}/2);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q1:=pgdbvertex(@v)^;
  v.x:=cos(endangle{*pi/180});
  v.y:=sin(endangle{*pi/180});
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q2:=pgdbvertex(@v)^;

  calcbb(dc);
  createpoints(dc);
  Representation.Clear;
  Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,false,false);
end;
procedure GDBObjARC.getoutbound;
function getQuadrant(a:GDBDouble):integer;
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
    sx,sy,ex,ey,minx,miny,maxx,maxy:GDBDouble;
    {i,}sq,eq,q:integer;
begin
  vp.BoundingBox:=CreateBBFrom2Point(q0,q2);
  //concatBBandPoint(vp.BoundingBox,q1);
         sq:=getQuadrant(self.StartAngle);
         eq:=getQuadrant(self.EndAngle);
         q:=AxisIntersect(sq,eq);
         if (self.StartAngle>self.EndAngle)and(q=0) then
                                              q:=q xor 15;
         sx:=cos(self.StartAngle);
         sy:=sin(self.StartAngle);
         ex:=cos(self.EndAngle);
         ey:=sin(self.EndAngle);
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
       GDBGetMem({$IFDEF DEBUGBUILD}'{B9B13A5B-467C-4E8A-B4BD-6F54713EBC0D}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{2D0D05D3-F10A-473F-88FC-D5FB9BD7B539}',{$ENDIF}4);
  end;
end;
procedure GDBObjARC.createpoints(var DC:TDrawContext);
var
  i: GDBInteger;
  l: GDBDouble;
  v:GDBvertex;
  pv:GDBVertex;
  maxlod:integer;
begin
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;

  Vertex3D_in_WCS_Array.clear;

  v.x:=cos(startangle);
  v.y:=sin(startangle);
  v.z:=0;
  pv:=VectorTransform3D(v,objmatrix);
  Vertex3D_in_WCS_Array.PushBackData(pv);

  if dc.MaxDetail then
                      maxlod:=50
                  else
                      maxlod:=20;

  l:=r*angle/(dc.DrawingContext.zoom*dc.DrawingContext.zoom*3);
  if (l>maxlod)or dc.MaxDetail then lod:=maxlod
           else
               begin
                    lod:=round(l);
                    if lod<5 then lod:=5;
               end;

  for i:=1 to lod do
  begin
              v.x:=cos(startangle+i / lod * angle);
              v.y:=sin(startangle+i / lod * angle);
              v.z:=0;
              pv:=VectorTransform3D(v,objmatrix);
              Vertex3D_in_WCS_Array.PushBackData(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjARC.Renderfeedback;
var //pm:DMatrix4D;
    tv:GDBvertex;
    //d:GDBDouble;
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
//  i: GDBInteger;
    simply:GDBBoolean;
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
//    i:GDBInteger;
begin

end;
procedure GDBObjARC.LoadFromDXF;
var //s: GDBString;
  byt{, code}: GDBInteger;
  dc:TDrawContext;
begin
  //initnul;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfGDBDoubleload(f,40,byt,r) then
    if not dxfGDBDoubleload(f,50,byt,startangle) then
    if not dxfGDBDoubleload(f,51,byt,endangle) then {s := }f.readgdbstring;
    byt:=readmystrtoint(f);
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
var i:GDBInteger;
begin
     for i:=0 to 5 do
     begin
     if(mf[i][0] * P_insert_in_WCS.x + mf[i][1] * P_insert_in_WCS.y + mf[i][2] * P_insert_in_WCS.z + mf[i][3]+R < 0 )
     then
     begin
          result:=false;
          //system.break;
          exit;
     end;
     end;
     result:=Vertex3D_in_WCS_Array.onmouse(mf,false);
     if not result then
                  if CalcPointTrueInFrustum(P_insert_in_WCS,mf)=IRFully then
                                                                            result:=true;
end;
procedure GDBObjARC.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_begin:begin
          pdesc.worldcoord:=q0;
          pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(Pq0.y);
                             end;
                    os_midle:begin
          pdesc.worldcoord:=q1;
          pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(Pq1.y);
                             end;
                    os_end:begin
          pdesc.worldcoord:=q2;
          pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(Pq2.y);
                             end;
                    end;
end;
procedure GDBObjARC.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{8E7285C9-05AD-4D34-9E9D-479D394B2AAF}',{$ENDIF}3);
          pdesc.selected:=false;
          pdesc.pobject:=nil;

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
//var t,d,e:GDBDouble;
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
     GDBGetMem({$IFDEF DEBUGBUILD}'{77AF2FA4-2EDC-46CD-A813-6E34E2AC91A5}',{$ENDIF}result,sizeof(tarcrtmodify));
     tarcrtmodify(result^).p1.x:=q0.x;
     tarcrtmodify(result^).p1.y:=q0.y;
     tarcrtmodify(result^).p2.x:=q1.x;
     tarcrtmodify(result^).p2.y:=q1.y;
     tarcrtmodify(result^).p3.x:=q2.x;
     tarcrtmodify(result^).p3.y:=q2.y;
end;
function GDBObjARC.IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;
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
var //a,b,c,d,e,f,g,p_x,p_y,rr:GDBDouble;
    //tv:gdbvertex2d;
    tv3d:gdbvertex;
    ptdata:tarcrtmodify;
    //m1:DMatrix4D;
    ad:TArcData;
begin
     //rtmod.point.pobject:=;
     tv3d:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
     //m1:=GetMatrix^;
     //MatrixInvert(m1);
     //tv3d:=VectorTransform3D(tv3d,m1);

     ptdata.p1.x:=q0.x;
     ptdata.p1.y:=q0.y;
     ptdata.p2.x:=q1.x;
     ptdata.p2.y:=q1.y;
     ptdata.p3.x:=q2.x;
     ptdata.p3.y:=q2.y;

          case rtmod.point.pointtype of
               os_begin:begin
                             ptdata.p1.x:={q0.x+rtmod.dist}tv3d.x;
                             ptdata.p1.y:={q0.y+rtmod.dist}tv3d.y;
                        end;
               os_midle:begin
                             ptdata.p2.x:={q1.x+rtmod.dist}tv3d.x;
                             ptdata.p2.y:={q1.y+rtmod.dist}tv3d.y;
                      end;
               os_end:begin
                             ptdata.p3.x:={q2.x+rtmod.dist}tv3d.x;
                             ptdata.p3.y:={q2.y+rtmod.dist}tv3d.y;
                        end;
          end;
        if GetArcParamFrom3Point2D(ptdata,ad) then
        begin
              Local.p_insert.x:=ad.p.x;
              Local.p_insert.y:=ad.p.y;
              Local.p_insert.z:=0;
              startangle:=ad.startangle;
              endangle:=ad.endangle;
              r:=ad.r;
              //format;
        end;
        {A:= ptdata.p2.x - ptdata.p1.x;
        B:= ptdata.p2.y - ptdata.p1.y;
        C:= ptdata.p3.x - ptdata.p1.x;
        D:= ptdata.p3.y - ptdata.p1.y;

        E:= A*(ptdata.p1.x + ptdata.p2.x) + B*(ptdata.p1.y + ptdata.p2.y);
        F:= C*(ptdata.p1.x + ptdata.p3.x) + D*(ptdata.p1.y + ptdata.p3.y);

        G:= 2*(A*(ptdata.p3.y - ptdata.p2.y)-B*(ptdata.p3.x - ptdata.p2.x));
        if abs(g)>eps then
        begin
        p_x:= (D*E - B*F) / G;
        p_y:= (A*F - C*E) / G;
        rr:= sqrt(sqr(ptdata.p1.x - p_x) + sqr(ptdata.p1.y - p_y));
        r:=rr;
        Local.p_insert.x:=p_x;
        Local.p_insert.y:=p_y;
        Local.p_insert.z:=0;
        tv.x:=p_x;
        tv.y:=p_y;
        startangle:=vertexangle(tv,ptdata.p1);
        endangle:=vertexangle(tv,ptdata.p3);
        if startangle>endangle then
        begin
                                                                                      rr:=startangle;
                                                                                      startangle:=endangle;
                                                                                      endangle:=rr
        end;
        rr:=vertexangle(tv,ptdata.p2);
        if (rr>startangle) and (rr<endangle) then
                                                                                 begin
                                                                                 end
                                                                             else
                                                                                 begin
                                                                                      rr:=startangle;
                                                                                      startangle:=endangle;
                                                                                      endangle:=rr
                                                                                 end;
        format;
        //renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
        end;}

end;
function GDBObjARC.Clone;
var tvo: PGDBObjArc;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{368BA81A-219B-4DE9-A8E0-64EE16001126}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjArc));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, Local.p_insert, r,startangle,endangle);
  tvo^.Local.basis.oz:=Local.basis.oz;
  CopyVPto(tvo^);
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
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocArc}',{$ENDIF}pointer(result),sizeof(GDBObjArc));
end;
function AllocAndInitArc(owner:PGDBObjGenericWithSubordinated):PGDBObjArc;
begin
  result:=AllocArc;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
class function GDBObjARC.CreateInstance:PGDBObjArc;
begin
  result:=AllocAndInitArc(nil);
end;
begin
  RegisterDXFEntity(GDBArcID,'ARC','Arc',@AllocArc,@AllocAndInitArc);
end.
