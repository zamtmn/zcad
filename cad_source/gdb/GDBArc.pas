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
unit GDBArc;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfPObjects,UGDBLayerArray,gdbasetypes,UGDBSelectedObjArray,gdbEntity,UGDBOutbound2DIArray{,UGDBPolyPoint2DArray},UGDBPoint3DArray,UGDBOpenArrayOfByte,varman,varmandef,
gl,
GDBase,UGDBDescriptor{,GDBWithLocalCS},gdbobjectsconstdef,oglwindowdef,geometry,dxflow,memman,GDBPlain{,OGLSpecFunc};
type
{Export+}
  ptarcrtmodify=^tarcrtmodify;
  tarcrtmodify=record
                        p1,p2,p3:GDBVertex2d;
                  end;
PGDBObjArc=^GDBObjARC;
GDBObjArc=object(GDBObjPlain)
                 R:GDBDouble;(*saved_to_shd*)
                 StartAngle:GDBDouble;(*saved_to_shd*)
                 EndAngle:GDBDouble;(*saved_to_shd*)
                 angle:GDBDouble;
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 length:GDBDouble;
                 q0,q1,q2:GDBvertex;
                 pq0,pq1,pq2:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR,S,E:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;

                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure CalcObjMatrix;virtual;
                 procedure Format;virtual;
                 procedure createpoint;virtual;
                 procedure getoutbound;virtual;
                 procedure RenderFeedback;virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer):GDBBoolean;virtual;
                 function beforertmodify:GDBPointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 destructor done;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
           end;
{EXPORT-}
implementation
uses log;
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
     Vertex3D_in_WCS_Array.ClearAndDone;
end;
constructor GDBObjARC.initnul;
begin
  inherited initnul(nil);
  vp.ID := GDBArcID;
  r := 1;
  startangle := 0;
  endangle := pi/2;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{7E7B2243-1D9C-43AD-BB6B-959FE9F49D5D}-GDBObjARC.Vertex3D_in_WCS_Array',{$ENDIF}100);
end;
constructor GDBObjARC.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBArcID;
  Local.p_insert := p;
  r := rr;
  startangle := s;
  endangle := e;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{AEF4273C-4EE8-4520-B23A-04C3AD6DABE3}',{$ENDIF}100);
  format;
end;
procedure GDBObjArc.SaveToDXF;
begin
  SaveToDXFObjPrefix(handle,outhandle,'ARC','AcDbCircle');
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
procedure GDBObjARC.format;
var
  v:GDBvertex4D;
begin
  calcObjMatrix;
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;
  length := abs(angle){*pi/180} * r * r;
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

  calcbb;
  createpoint;
end;
procedure GDBObjARC.getoutbound;
var //tv,tv2:GDBVertex;
    t,b,l,rr,n,f:GDBDouble;
    i:integer;
begin
  outbound[0]:=VectorTransform3d(CreateVertex(-1,1,0),objMatrix);
  outbound[1]:=VectorTransform3d(CreateVertex(1,1,0),objMatrix);
  outbound[2]:=VectorTransform3d(CreateVertex(1,-1,0),objMatrix);
  outbound[3]:=VectorTransform3d(CreateVertex(-1,-1,0),objMatrix);

  {outbound[0]:=VectorTransform3d(CreateVertex(cos(startangle),sin(startangle),0),objMatrix);
  outbound[1]:=VectorTransform3d(CreateVertex(cos(endangle),sin(endangle),0),objMatrix);
  tv:=vertexsub(pgdbvertex(@outbound[1])^,pgdbvertex(@outbound[0])^);
  t:=tv.x;
  tv.x:=tv.y;
  tv.y:=t;
  outbound[2]:=vertexadd(outbound[1],tv);
  outbound[3]:=vertexadd(outbound[0],tv);}


  l:=outbound[0].x;
  rr:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>rr then
                         rr:=outbound[i].x;
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
  vp.BoundingBox.RTF:=CreateVertex(rr,T,f);
  if PProjoutbound=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{B9B13A5B-467C-4E8A-B4BD-6F54713EBC0D}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{2D0D05D3-F10A-473F-88FC-D5FB9BD7B539}',{$ENDIF}4);
  end;
end;
procedure GDBObjARC.createpoint;
var
  //psymbol: PGDBByte;
  i{, j, k}: GDBInteger;
  //len: GDBWord;
  matr{,m1}: DMatrix4D;
  v:GDBvertex;
  pv:GDBVertex;
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
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;

  Vertex3D_in_WCS_Array.clear;
  {if ppoint<>nil then
                     begin
                          ppoint^.done;
                          GDBFreeMem(ppoint);
                     end;
  GDBGetMem(PPoint,sizeof(GDBPoint2DArray));
  PPoint^.init(lod+1);}
  matr:=objMatrix;
  v.x:=cos(startangle);
  v.y:=sin(startangle);
  v.z:=0;
  pv:=VectorTransform3D(v,objmatrix);
  Vertex3D_in_WCS_Array.add(@pv);

  lod:=100;  { TODO : А кто лод считать будет? }

  for i:=1 to lod do
  begin
              v.x:=cos(startangle+i / lod * angle);
              v.y:=sin(startangle+i / lod * angle);
              v.z:=0;
              pv:=VectorTransform3D(v,objmatrix);
              Vertex3D_in_WCS_Array.add(@pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjARC.Renderfeedback;
var pm:DMatrix4D;
    tv:GDBvertex;
    d:GDBDouble;
begin
           gdb.GetCurrentDWG^.myGluProject2(Local.p_insert,ProjP_insert);
           pprojoutbound^.clear;
           pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           gdb.GetCurrentDWG^.myGluProject2(outbound[0],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[1],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[2],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[3],tv);
           pprojoutbound^.addlastgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(q0,pq0);
           gdb.GetCurrentDWG^.myGluProject2(q1,pq1);
           gdb.GetCurrentDWG^.myGluProject2(q2,pq2);
           if pprojoutbound^.count<4 then
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
                     createpoint;
                end;
                projectpoint;
           end;
end;
procedure GDBObjARC.DrawGeometry;
//var
//  i: GDBInteger;
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
                     Vertex3D_in_WCS_Array.drawgeometry2
                 else
                     Vertex3D_in_WCS_Array.drawgeometry;
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
var s: GDBString;
  byt{, code}: GDBInteger;
begin
  //initnul;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfGDBDoubleload(f,40,byt,r) then
    if not dxfGDBDoubleload(f,50,byt,startangle) then
    if not dxfGDBDoubleload(f,51,byt,endangle) then s := f.readgdbstring;
    byt:=readmystrtoint(f);
  end;
  startangle := startangle * pi / 180;
  endangle := endangle * pi / 180;
  PProjoutbound:=nil;
  format;
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
end;
procedure GDBObjARC.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_begin:begin
          pdesc.worldcoord:=q0;
          pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq0.y);
                             end;
                    os_midle:begin
          pdesc.worldcoord:=q1;
          pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq1.y);
                             end;
                    os_end:begin
          pdesc.worldcoord:=q2;
          pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq2.y);
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
          pdesc.worldcoord:=q0;
          pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq0.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);

          pdesc.pointtype:=os_midle;
          pdesc.worldcoord:=q1;
          pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq1.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);

          pdesc.pointtype:=os_end;
          pdesc.worldcoord:=q1;
          pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-Pq2.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;
function GDBObjARC.getsnap;
//var t,d,e:GDBDouble;
  //  tv,n,v:gdbvertex;
begin
     if onlygetsnapcount=3 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=q0;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq0)^;
            osp.ostype:=os_begin;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_midpoint)<>0
            then
            begin
            osp.worldcoord:=q1;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq1)^;
            osp.ostype:=os_midle;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_endpoint)<>0
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
procedure GDBObjARC.rtmodifyonepoint(const rtmod:TRTModifyData);
var a,b,c,d,e,f,g,p_x,p_y,rr:GDBDouble;
    tv:gdbvertex2d;
    ptdata:tarcrtmodify;
begin
     ptdata.p1.x:=q0.x;
     ptdata.p1.y:=q0.y;
     ptdata.p2.x:=q1.x;
     ptdata.p2.y:=q1.y;
     ptdata.p3.x:=q2.x;
     ptdata.p3.y:=q2.y;

          case rtmod.point.pointtype of
               os_begin:begin
                             ptdata.p1.x:=q0.x+rtmod.dist.x;
                             ptdata.p1.y:=q0.y+rtmod.dist.y;
                        end;
               os_midle:begin
                             ptdata.p2.x:=q1.x+rtmod.dist.x;
                             ptdata.p2.y:=q1.y+rtmod.dist.y;
                      end;
               os_end:begin
                             ptdata.p3.x:=q2.x+rtmod.dist.x;
                             ptdata.p3.y:=q2.y+rtmod.dist.y;
                        end;
          end;
        A:= ptdata.p2.x - ptdata.p1.x;
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
        renderfeedback;
        end;

end;
function GDBObjARC.Clone;
var tvo: PGDBObjArc;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{368BA81A-219B-4DE9-A8E0-64EE16001126}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjArc));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, Local.p_insert, r,startangle,endangle);
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjARC.rtsave;
begin
  pgdbobjarc(refp)^.Local.p_insert := Local.p_insert;
  pgdbobjarc(refp)^.startangle := startangle;
  pgdbobjarc(refp)^.endangle := endangle;
  pgdbobjarc(refp)^.r := r;
  pgdbobjarc(refp)^.format;
  pgdbobjarc(refp)^.renderfeedback;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBArc.initialization');{$ENDIF}
end.
