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

unit uzeentcircle;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
    gzctnrVectorTypes,uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzecamera,
    uzestyleslayers,uzehelpobj,UGDBSelectedObjArray,
    uzegeometrytypes,uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,uzctnrVectorBytes,
    uzbtypes,uzeentwithlocalcs,uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,
    uzeSnap,uzMVReader,uzCtnrVectorpBaseEntity;
type
  ptcirclertmodify=^tcirclertmodify;
  tcirclertmodify=record
                        r,p_insert:Boolean;
                  end;
PGDBObjCircle=^GDBObjCircle;
GDBObjCircle= object(GDBObjWithLocalCS)
                 Radius:GDBLength;(*'Radius'*)
                 q0:GDBvertex;
                 q1:GDBvertex;
                 q2:GDBvertex;
                 q3:GDBvertex;
                 Outbound:OutBound4V;
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex;RR:Double);
                 constructor initnul;
                 procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                 function calcinfrustum(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 function CalcTrueInFrustum(const frustum:ClipArray):TInBoundingVolume;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 procedure createpoint(var DC:TDrawContext);virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 //procedure higlight;virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 //function InRect:TInRect;virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);virtual;
                 function beforertmodify:Pointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;virtual;

                 function ObjToString(const prefix,sufix:String):String;virtual;
                 destructor done;virtual;

                 function GetObjTypeName:String;virtual;

                 procedure createfield;virtual;
                 function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual; //<**Пересечение с линией описанной 2-я точками
                 procedure ReCalcFromObjMatrix;virtual;

                 function GetTangentInPoint(const point:GDBVertex):GDBVertex;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;virtual;

                 class function CreateInstance:PGDBObjCircle;static;
                 function GetObjType:TObjID;virtual;
           end;
implementation
//uses
//    log;
function GDBObjCircle.onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;
var
   m1:DMatrix4D;
   ppoint:GDBVertex;
begin
     m1:=GetMatrix^;
     MatrixInvert(m1);
     ppoint:=VectorTransform3D(point,m1);
     if (abs(ppoint.z)>eps) then
                                exit(false);
     if abs(uzegeometry.Vertexlength(point,P_insert_in_WCS)-radius)<bigeps then
                                                                     begin
                                                                       result:=true;
                                                                       objects.pushbackdata(@self);
                                                                     end
                                                                   else
                                                                     result:=false;
end;
procedure GDBObjCircle.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
var tv,dir:gdbvertex;
begin
     dir:=VertexSub(P_insert_in_WCS,posr.worldcoord);
     processaxis(posr,dir);
     tv:=uzegeometry.vectordot(dir,zwcs);
     processaxis(posr,tv);
end;

function GDBObjCircle.GetTangentInPoint(const point:GDBVertex):GDBVertex;
begin
     result:=normalizevertex(
                             uzegeometry.vectordot(
                                                   uzegeometry.VertexSub(self.P_insert_in_WCS,point)
                                                   ,self.Local.basis.oz));
end;
procedure GDBObjCircle.ReCalcFromObjMatrix;
var
  scl:GDBvertex;
begin
  Local:=GetPInsertInOCSBymatrix(objmatrix,scl);
  Radius:=scl.x;
end;
function GDBObjCircle.IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;
var
   m1:DMatrix4D;
   td,td2,td3,{slbegin,slend,}t1,t2,llbegin_x2,llbegin_y2,llend_x2,llend_y2:double;
   llbegin,llend:gdbvertex;
begin
     m1:=GetMatrix^;
     MatrixInvert(m1);
     llbegin:=VectorTransform3D(lbegin,m1);
     llend:=VectorTransform3D(lend,m1);
     if (abs(lbegin.z)<eps)and(abs(lend.z)<eps)
        then
            begin
                 //slbegin:=SqrOneVertexlength(llbegin);
                 //slend:=SqrOneVertexlength(llend);

                 llbegin_x2:=llbegin.x*llbegin.x;
                 llbegin_y2:=llbegin.y*llbegin.y;
                 llend_x2:=llend.x*llend.x;
                 llend_y2:=llend.y*llend.y;
                 td3:=llbegin_x2+llbegin_y2-2*llbegin.x*llend.x+llend_x2-2*llbegin.y*llend.y+llend_y2;
                 if abs(td3)>eps then
                 begin
                 td:=llbegin_x2+llbegin_y2-llbegin.x*llend.x-llbegin.y*llend.y;
                 td2:=(llbegin_x2+llbegin_y2-2*llbegin.x*llend.x+llend_x2-llbegin_y2*llend_x2-2*llbegin.y*llend.y+2*llbegin.x*llbegin.y*llend.x*llend.y+llend_y2-llbegin_x2*llend_y2);
                 if td2>0 then
                 begin
                 td2:=sqrt(td2);
                 t1:=(td+td2)/td3;
                 t2:=(td-td2)/td3;
                 result.isintercept:=true;
                 if abs(1-abs(t1))<abs(1-abs(t2)) then
                 begin
                 result.t1:=t1;
                 result.interceptcoord:=Vertexmorph(lbegin,lend,result.t1);
                 end
                 else
                 begin
                 result.t1:=t2;
                 result.interceptcoord:=Vertexmorph(lbegin,lend,result.t1);
                 end
                 end
                    else
                        result.isintercept:=false;
                 end
                    else
                        result.isintercept:=false;

                 {td:=distance2piece(NulVertex,llbegin,llend);
                 if td<=1 then
                              begin
                                   td:=Vertexlength(llbegin,llend);
                                   if td>=1 then
                                                begin
                                                     result.isintercept:=true;
                                                     slbegin:=SqrOneVertexlength(llbegin);
                                                     slend:=SqrOneVertexlength(llend);
                                                     if slbegin>slend
                                                       then
                                                           begin
                                                                result.t1:=(td-1)/td;
                                                           end
                                                       else
                                                           begin
                                                                result.t1:=1/td;
                                                           end;
                                                     result.interceptcoord:=Vertexmorph(lbegin,lend,result.t1);
                                                end
                                                   else
                                                    result.isintercept:=false;

                              end
                          else
                              result.isintercept:=false;}
            end
        else
            result.isintercept:=false;

     //result:=intercept3d(lbegin,lend,CoordInWCS.lBegin,CoordInWCS.lEnd);
end;
procedure GDBObjCircle.createfield;
begin
     inherited;
     Radius:=1;
     q0:=nulvertex;
     q1:=nulvertex;
     q2:=nulvertex;
     q3:=nulvertex;
     Outbound[0]:=nulvertex;
     Outbound[1]:=nulvertex;
     Outbound[2]:=nulvertex;
     Outbound[3]:=nulvertex;
end;
function GDBObjCircle.GetObjTypeName;
begin
     result:=ObjN_GDBObjCircle;
end;
destructor GDBObjCircle.done;
begin
     //Vertex3D_in_WCS_Array.Clear;
     Vertex3D_in_WCS_Array.Done;
     inherited done;
end;
function GDBObjCircle.ObjToString(const prefix,sufix:String):String;
begin
     result:=prefix+inherited ObjToString('GDBObjCircle (addr:',')')+sufix;
end;
constructor GDBObjCircle.initnul;
begin
  inherited initnul(nil);
  //vp.ID := GDBCircleID;
  Radius := 1;
  //PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init(4);
end;
constructor GDBObjCircle.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBCircleID;
  Local.p_insert := p;
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  Radius := rr;
  //ObjToString('','');
  //PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init(4);
  //format;
end;
function GDBObjCircle.GetObjType;
begin
     result:=GDBCircleID;
end;
procedure GDBObjCircle.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'CIRCLE','AcDbCircle',IODXFContext);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfDoubleout(outStream,40,Radius);
  SaveToDXFObjPostfix(outStream);
end;

procedure GDBObjCircle.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  calcObjMatrix;
  createpoint(dc);
  q0:=VectorTransform3d(CreateVertex(1,0,0),objMatrix);
  q1:=VectorTransform3d(CreateVertex(0,-1,0),objMatrix);
  q2:=VectorTransform3d(CreateVertex(-1,0,0),objMatrix);
  q3:=VectorTransform3d(CreateVertex(0,1,0),objMatrix);
  //getoutbound;
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  Representation.Clear;
  if not (ESTemp in State)and(DCODrawable in DC.Options) then
    Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,true,true);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjCircle.getoutbound;
var //tv,tv2:GDBVertex4D;
    t,b,l,r,n,f:Double;
    i:integer;
begin
  outbound[0]:=VectorTransform3d(CreateVertex(-1,1,0),objMatrix);
  outbound[1]:=VectorTransform3d(CreateVertex(1,1,0),objMatrix);
  outbound[2]:=VectorTransform3d(CreateVertex(1,-1,0),objMatrix);
  outbound[3]:=VectorTransform3d(CreateVertex(-1,-1,0),objMatrix);

  l:=outbound[0].x;
  r:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>r then
                         r:=outbound[i].x;
  if outbound[i].y<b then
                         b:=outbound[i].y;
  if outbound[i].y>t then
                         t:=outbound[i].y;
  if outbound[i].z<n then
                         n:=outbound[i].z;
  if outbound[i].z>f then
                         f:=outbound[i].z;
  end;

  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(r,T,f);



  {if PProjoutbound=nil then
  begin
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;}
end;
procedure GDBObjCircle.createpoint(var DC:TDrawContext);
var
   l{,i}:integer;
   ir:itrec;
   pvertex:pgdbvertex2d;
   tv:gdbvertex;
   v:gdbvertex;
begin
  Vertex3D_in_WCS_Array.clear;
  if (lod>32)or dc.MaxDetail then
                 begin
                      l:=lod;
                      if (l>CircleLODCount)or dc.MaxDetail then
                        l:=CircleLODCount;
                 end
            else
                l:=32;
  Vertex3D_in_WCS_Array.SetSize(circlepointoflod[l].Count);
  pvertex:=circlepointoflod[l].beginiterate(ir);
  if pvertex<>nil then
  repeat
        pgdbvertex2d(@tv)^:=pvertex^;
        tv.z:=0;
        v:=VectorTransform3D(tv,objmatrix);
        //v.count:=l-ir.itc;

        Vertex3D_in_WCS_Array.PushBackData(v);

        pvertex:=circlepointoflod[l].iterate(ir);
  until pvertex=nil;
  Vertex3D_in_WCS_Array.Shrink;
end;

procedure GDBObjCircle.CalcObjMatrix;
var m1{,m2,m3,m4}:DMatrix4D;
begin
  inherited CalcObjMatrix;
  //m1:=ONEMATRIX;
  //m1.mtr[0].v[0] := Radius;
  //m1.mtr[1].v[1] := Radius;
  //m1.mtr[2].v[2] := Radius;
  m1:=CreateScaleMatrix(Radius);
  objmatrix:=matrixmultiply(m1,objmatrix);
end;

procedure GDBObjCircle.DrawGeometry;
begin
  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
  inherited;
end;
procedure GDBObjCircle.projectpoint;
{var pm:DMatrix4D;
    tv:GDBvertex;
    tpv:GDBPolyVertex2D;
    ptpv:PGDBPolyVertex2D;
    i:Integer;}
begin
end;
procedure GDBObjCircle.LoadFromDXF;
var //s: String;
  byt{, code}: Integer;
begin
  //initnul;
  byt:=rdr.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing) then
    if not dxfvertexload(rdr,10,byt,Local.P_insert) then
    if not dxfDoubleload(rdr,40,byt,Radius) then {s := }rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  //PProjoutbound:=nil;
  //pprojpoint:=nil;
  //format;
end;
function GDBObjCircle.Clone;
var tvo: PGDBObjCircle;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjCircle));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert, Radius);
  tvo^.local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  //tvo^.format;
  result := tvo;
end;

{procedure GDBObjCircle.higlight;
begin
  glcolor3ubv(@palette[sysvar.SYS.SYS_SystmGeometryColor^]);
  myglbegin(GL_lines);
  glVertex2d(ProjP_insert.x-5,ProjP_insert.y);
  glVertex2d(ProjP_insert.x+5,ProjP_insert.y);
  glVertex2d(ProjP_insert.x,ProjP_insert.y-5);
  glVertex2d(ProjP_insert.x,ProjP_insert.y+5);
  myglend;
  inherited;
end;}
function GDBObjCircle.onmouse;
var
  i:Integer;
  r:Double;
begin
  r:=sqrt(ObjMatrix.mtr[0].v[0]*ObjMatrix.mtr[0].v[0]+ObjMatrix.mtr[0].v[1]*ObjMatrix.mtr[0].v[1]+ObjMatrix.mtr[0].v[2]*ObjMatrix.mtr[0].v[2]);
  for i:=0 to 5 do begin
    if(mf[i].v[0] * P_insert_in_WCS.x + mf[i].v[1] * P_insert_in_WCS.y + mf[i].v[2] * P_insert_in_WCS.z + mf[i].v[3]+r < 0 ) then
    exit(false);
  end;
  result:=Vertex3D_in_WCS_Array.onmouse(mf,false);
  if not result then
    if CalcPointTrueInFrustum(P_insert_in_WCS,mf)=IRFully then
      result:=true;
end;
procedure GDBObjCircle.rtsave;
begin
  inherited;
  //pgdbobjcircle(refp)^.Local.p_insert := Local.p_insert;
  pgdbobjcircle(refp)^.Radius := Radius;
  //pgdbobjcircle(refp)^.format;
end;
function GDBObjCircle.calcinfrustum;
var
  i:Integer;
  r:Double;
begin
  r:=sqrt(ObjMatrix.mtr[0].v[0]*ObjMatrix.mtr[0].v[0]+ObjMatrix.mtr[0].v[1]*ObjMatrix.mtr[0].v[1]+ObjMatrix.mtr[0].v[2]*ObjMatrix.mtr[0].v[2]);
  for i:=0 to 5 do
    if(frustum[i].v[0] * P_insert_in_WCS.x + frustum[i].v[1] * P_insert_in_WCS.y + frustum[i].v[2] * P_insert_in_WCS.z + frustum[i].v[3]+r{+GetLTCorrectH} < 0 ) then
       exit(false);
  result:=true;
end;
function GDBObjCircle.CalcTrueInFrustum;
var
  i:Integer;
  r:Double;
begin
  r:=sqrt(ObjMatrix.mtr[0].v[0]*ObjMatrix.mtr[0].v[0]+ObjMatrix.mtr[0].v[1]*ObjMatrix.mtr[0].v[1]+ObjMatrix.mtr[0].v[2]*ObjMatrix.mtr[0].v[2]);
  for i:=0 to 5 do
    if(frustum[i].v[0] * P_insert_in_WCS.x + frustum[i].v[1] * P_insert_in_WCS.y + frustum[i].v[2] * P_insert_in_WCS.z + frustum[i].v[3]+r{+GetLTCorrectH} < 0 ) then
      exit(IREmpty);
  result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,false);
end;
function GDBObjCircle.getsnap;
var
   tv,n{,v}:gdbvertex;
   plane:DVector4D;
begin
     if onlygetsnapcount=6 then
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
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //osp.dispcoord:=ProjP_insert;
            osp.ostype:=os_center;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q0;
            ProjectProc(osp.worldcoord,osp.dispcoord);
            osp.ostype:=os_q0;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q1;
            ProjectProc(osp.worldcoord,osp.dispcoord);
            osp.ostype:=os_q1;
            end
            else osp.ostype:=os_none;
       end;
     3:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q2;
            ProjectProc(osp.worldcoord,osp.dispcoord);
            osp.ostype:=os_q2;
            end
            else osp.ostype:=os_none;
       end;
     4:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q3;
            ProjectProc(osp.worldcoord,osp.dispcoord);
            osp.ostype:=os_q3;
            end
       end;
     5:begin
            if (SnapMode and osm_nearest)<>0
            then
            begin
            osp.ostype:=os_none;
            plane:=PlaneFrom3Pont(q0,q1,q2);
            Normalizeplane(plane);
            if
            PointOfRayPlaneIntersect({GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseraywithoutOS.lbegin,
                                      {GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseraywithoutOS.dir,
                                      plane,tv)
            then
            begin
                 n:=uzegeometry.VertexSub(tv,P_insert_in_WCS);
                 n:=uzegeometry.NormalizeVertex(n);
                 n:=uzegeometry.VertexMulOnSc(n,radius);
                 osp.worldcoord:=uzegeometry.VertexAdd(P_insert_in_WCS,n);
                 {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,tv);
                 osp.dispcoord:=tv;
                 osp.ostype:=os_nearest;
            end;
            end
       end
     else osp.ostype:=os_none;
     end;
     inc(onlygetsnapcount);
end;
(*function GDBObjCircle.InRect;
//var i:Integer;
//    ptpv:PGDBPolyVertex2D;
begin
     if pprojoutbound<>nil then if self.pprojoutbound^.inrect=IRFully then
     begin
          result:=IRFully;
          exit;
     end;
     //if POGLWnd^.seldesc.MouseFrameInverse then
     {if PProjPoint<>nil then if self.PProjPoint^.inrect=IRPartially then
     begin
          result:=IRPartially;
          exit;
     end;
     result:=IREmpty;}
end;*)
procedure GDBObjCircle.remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);
var
  tv:GDBvertex;
begin
  if pdesc^.pointtype=os_center then begin
    pdesc.worldcoord:=P_insert_in_WCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_q0 then begin
    pdesc.worldcoord:=q0;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_q1 then begin
    pdesc.worldcoord:=q1;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_q2 then begin
    pdesc.worldcoord:=q2;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_q3 then begin
    pdesc.worldcoord:=q3;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end;
end;
procedure GDBObjCircle.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(5);
          pdesc.selected:=false;
          pdesc.PDrawable:=nil;
          pdesc.pointtype:=os_center;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=Local.p_insert;
          {pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(ProjP_insert.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_q0;
          pdesc.attr:=[];
          pdesc.worldcoord:=q0;
          {pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(Pq0.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_q1;
          pdesc.attr:=[];
          pdesc.worldcoord:=q1;
          {pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(Pq1.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_q2;
          pdesc.attr:=[];
          pdesc.worldcoord:=q2;
          {pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(Pq2.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_q3;
          pdesc.attr:=[];
          pdesc.worldcoord:=q3;
          {pdesc.dispcoord.x:=round(Pq3.x);
          pdesc.dispcoord.y:=round(Pq3.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
function GDBObjCircle.beforertmodify;
begin
     Getmem(result,sizeof(tcirclertmodify));
     fillchar(result^,sizeof(tcirclertmodify),0);
end;
function GDBObjCircle.IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;
begin
  result:=false;
  if point.pointtype=os_center then begin
    if not ptcirclertmodify(p).p_insert then
                                            result:=true;
    ptcirclertmodify(p).p_insert:=true;
  end else if (point.pointtype=os_q0)or(point.pointtype=os_q1)or(point.pointtype=os_q2)or(point.pointtype=os_q3) then begin
    if (not ptcirclertmodify(p).r)and
       (not ptcirclertmodify(p).p_insert)then
                                             result:=true;
    ptcirclertmodify(p).r:=true;
  end;
end;
procedure GDBObjCircle.rtmodifyonepoint(const rtmod:TRTModifyData);
var
   m:DMatrix4D;
begin
  m:=ObjMatrix;
  MatrixInvert(m);
  m.mtr[3]:=NulVector4D;
  if rtmod.point.pointtype=os_center then begin
    Local.p_insert:=VectorTransform3D(rtmod.wc*Radius,m);
  end else if (rtmod.point.pointtype=os_q0)or(rtmod.point.pointtype=os_q1)or(rtmod.point.pointtype=os_q2)or(rtmod.point.pointtype=os_q3) then begin
    Radius:=Vertexlength(Local.p_insert,VectorTransform3D(rtmod.wc*Radius,m));
  end;
end;
function AllocCircle:PGDBObjCircle;
begin
  Getmem(pointer(result),sizeof(GDBObjCircle));
end;
function AllocAndInitCircle(owner:PGDBObjGenericWithSubordinated):PGDBObjCircle;
begin
  result:=AllocCircle;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
procedure SetCircleGeomProps(Pcircle:PGDBObjCircle; const args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pcircle.Local.p_insert:=CreateVertexFromArray(counter,args);
  Pcircle.Radius:=CreateDoubleFromArray(counter,args);
end;
function AllocAndCreateCircle(owner:PGDBObjGenericWithSubordinated; const args:array of const):PGDBObjCircle;
begin
  result:=AllocAndInitCircle(owner);
  //owner^.AddMi(@result);
  SetCircleGeomProps(result,args);
end;
class function GDBObjCircle.CreateInstance:PGDBObjCircle;
begin
  result:=AllocAndInitCircle(nil);
end;
begin
  RegisterDXFEntity(GDBCircleID,'CIRCLE','Circle',@AllocCircle,@AllocAndInitCircle,@SetCircleGeomProps,@AllocAndCreateCircle);
end.

