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
unit uzeentellipse;
{$INCLUDE zengineconfig.inc}
interface
uses
    uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzecamera,
    uzeentwithlocalcs,uzestyleslayers,
    UGDBSelectedObjArray,uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,
    uzegeometrytypes,uzctnrVectorBytes,varman,varmandef,uzbtypes,uzeconsts,
    uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentplain,
    uzctnrvectorpgdbaseobjects,uzeSnap,math;
type
{Export+}
  ptEllipsertmodify=^tEllipsertmodify;
  {REGISTERRECORDTYPE tEllipsertmodify}
  tEllipsertmodify=record
                        p1,p2,p3:GDBVertex2d;
                  end;
PGDBObjEllipse=^GDBObjEllipse;
{REGISTEROBJECTTYPE GDBObjEllipse}
GDBObjEllipse= object(GDBObjPlain)
                 RR:Double;(*saved_to_shd*)
                 MajorAxis:GDBvertex;
                 Ratio:Double;(*saved_to_shd*)
                 StartAngle:Double;(*saved_to_shd*)
                 EndAngle:Double;(*saved_to_shd*)
                 angle:Double;
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 length:Double;
                 q0,q1,q2:GDBvertex;
                 pq0,pq1,pq2:GDBvertex;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex;{RR,}S,E:Double;majaxis:GDBVertex);
                 constructor initnul;
                 procedure LoadFromDXF(var f:TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure createpoint;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 function beforertmodify:Pointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 destructor done;virtual;
                 function GetObjTypeName:String;virtual;
                 function calcinfrustum(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 function CalcTrueInFrustum(const frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure ReCalcFromObjMatrix;virtual;

                 function CreateInstance:PGDBObjEllipse;static;
                 function GetObjType:TObjID;virtual;
           end;
{EXPORT-}
implementation
//uses log;
procedure GDBObjEllipse.TransformAt;
var
    tv:GDBVertex4D;
begin
    objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);

    tv:=PGDBVertex4D(@t_matrix[3])^;
    PGDBVertex4D(@t_matrix[3])^:=NulVertex4D;
    MajorAxis:=VectorTransform3D(PGDBObjEllipse(p)^.MajorAxis,t_matrix^);
    PGDBVertex4D(@t_matrix[3])^:=tv;

     {Local.oz:=PGDBVertex(@objmatrix[2])^;

     Local.p_insert:=PGDBVertex(@objmatrix[3])^;}ReCalcFromObjMatrix;
end;
procedure GDBObjEllipse.transform;
var {tv,}tv2:GDBVertex4D;
begin
  inherited;

  tv2:=PGDBVertex4D(@t_matrix[3])^;
  PGDBVertex4D(@t_matrix[3])^:=NulVertex4D;
  MajorAxis:=VectorTransform3D(MajorAxis,t_matrix);
  PGDBVertex4D(@t_matrix[3])^:=tv2;

  ReCalcFromObjMatrix;
end;
procedure GDBObjEllipse.ReCalcFromObjMatrix;
//var
    //ox:gdbvertex;
begin
     inherited;
     {Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);}

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;


     //scale.x:=uzegeometry.oneVertexlength(PGDBVertex(@objmatrix[0])^);
     //scale.y:=uzegeometry.oneVertexlength(PGDBVertex(@objmatrix[1])^);
     //scale.z:=uzegeometry.oneVertexlength(PGDBVertex(@objmatrix[2])^);

     {if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);}
     //normalizevertex(ox);
     //rotate:=uzegeometry.scalardot(Local.basis.ox,ox);
    // rotate:=arccos(rotate)*180/pi;
     //if local.basis.OX.y<-eps then rotate:=360-rotate;
end;

function GDBObjEllipse.CalcObjMatrixWithoutOwner;
var rotmatr,dispmatr{,m1}:DMatrix4D;
begin
     //Local.oz:=NormalizeVertex(Local.oz);
     Local.basis.ox:=MajorAxis;
     Local.basis.oy:=CrossVertex(Local.basis.oz,Local.basis.ox);

     Local.basis.ox:=NormalizeVertex(Local.basis.ox);
     Local.basis.oy:=NormalizeVertex(Local.basis.oy);
     Local.basis.oz:=NormalizeVertex(Local.basis.oz);

     rotmatr:=onematrix;
     PGDBVertex(@rotmatr[0])^:=Local.basis.ox;
     PGDBVertex(@rotmatr[1])^:=Local.basis.oy;
     PGDBVertex(@rotmatr[2])^:=Local.basis.oz;

     dispmatr:=onematrix;
     PGDBVertex(@dispmatr[3])^:=Local.p_insert;

     result:=MatrixMultiply({dispmatr,}rotmatr,dispmatr);
end;
function GDBObjEllipse.CalcTrueInFrustum;
var i{,count}:Integer;
    //d1,d2,d3,d4:Double;
begin
      for i:=0 to 5 do
      begin
      if(frustum[i].v[0] * P_insert_in_WCS.x + frustum[i].v[1] * P_insert_in_WCS.y + frustum[i].v[2] * P_insert_in_WCS.z + frustum[i].v[3]+rr < 0 )
      then
      begin
           result:=IREmpty;
           exit;
           //system.break;
      end;
      end;
      result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum);
end;
function GDBObjEllipse.calcinfrustum;
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
function GDBObjEllipse.GetObjTypeName;
begin
     result:=ObjN_GDBObjEllipse;
end;
destructor GDBObjEllipse.done;
begin
     inherited done;
     //Vertex3D_in_WCS_Array.Clear;
     Vertex3D_in_WCS_Array.Done;
end;
constructor GDBObjEllipse.initnul;
begin
  startangle := 0;
  endangle := 2*pi;
  PProjoutbound:=nil;
  majoraxis:=onevertex;
  inherited initnul(nil);
  //vp.ID:=GDBEllipseID;
  //r := 1;
  Vertex3D_in_WCS_Array.init(100);
end;
constructor GDBObjEllipse.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID:=GDBEllipseID;
  Local.p_insert := p;
  //r := rr;
  startangle := s;
  endangle := e;
  majoraxis:=majaxis;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init(100);
  //format;
end;
function GDBObjEllipse.GetObjType;
begin
     result:=GDBEllipseID;
end;
procedure GDBObjEllipse.CalcObjMatrix;
var m1:DMatrix4D;
    v:GDBvertex4D;
begin
  inherited CalcObjMatrix;
  m1:=ONEMATRIX;
  m1[0].v[0] := {ratio*}onevertexlength(majoraxis);
  m1[1].v[1] := ratio*onevertexlength(majoraxis);
  m1[2].v[2] := {ratio*onevertexlength(majoraxis)}1;
  objmatrix:=matrixmultiply(m1,objmatrix);

    pgdbvertex(@v)^:=local.p_insert;
  v.z:=0;
  v.w:=1;
  m1:=objMatrix;
  MatrixInvert(m1);
  v:=VectorTransform(v,m1);
end;
procedure GDBObjEllipse.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  v:GDBvertex4D;
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  if self.Ratio<=1 then
                      rr:=uzegeometry.oneVertexlength(majoraxis)
                   else
                      rr:=uzegeometry.oneVertexlength(majoraxis)*ratio;

  calcObjMatrix;
  angle := endangle - startangle;
  if angle < 0 then angle := 2 * pi + angle;
  length := abs(angle){*pi/180} * rr;//---------------------------------------------------------------
  SinCos(startangle{*pi/180},v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q0:=pgdbvertex(@v)^;
  SinCos(startangle+angle{*pi/180}/2,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q1:=pgdbvertex(@v)^;
  SinCos(endangle{*pi/180},v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q2:=pgdbvertex(@v)^;

  calcbb(dc);
  createpoint;
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjEllipse.getoutbound;
var //tv,tv2:GDBVertex;
    t,b,l,rrr,n,f:Double;
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
  rrr:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>rrr then
                         rrr:=outbound[i].x;
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
  vp.BoundingBox.RTF:=CreateVertex(rrr,T,f);
  if PProjoutbound=nil then
  begin
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;
end;
procedure GDBObjEllipse.createpoint;
var
  //psymbol: PByte;
  i{, j, k}: Integer;
  //len: Word;
  //matr{,m1}: DMatrix4D;
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
                          Freemem(ppoint);
                     end;
  Getmem(PPoint,sizeof(GDBPoint2DArray));
  PPoint^.init(lod+1);}
  //matr:=objMatrix;
  SinCos(startangle,v.y,v.x);
  v.z:=0;
  pv:=VectorTransform3D(v,objmatrix);
  Vertex3D_in_WCS_Array.PushBackData(pv);

  lod:=100;  { TODO : А кто лод считать будет? }

  for i:=1 to lod do
  begin
              SinCos(startangle+i / lod * angle,v.y,v.x);
              v.z:=0;
              pv:=VectorTransform3D(v,objmatrix);
              Vertex3D_in_WCS_Array.PushBackData(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjEllipse.Renderfeedback;
var //pm:DMatrix4D;
    tv:GDBvertex;
    d:Double;
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
procedure GDBObjEllipse.DrawGeometry;
//var
//  i: Integer;
begin

  DC.drawer.DrawClosedContour3DInModelSpace(Vertex3D_in_WCS_Array,DC.DrawingContext.matrixs);
  //Vertex3D_in_WCS_Array.drawgeometry;

  inherited;

end;
procedure GDBObjEllipse.projectpoint;
//var pm:DMatrix4D;
//    tv:GDBvertex;
//    tpv:GDBPolyVertex2D;
//    ptpv:PGDBPolyVertex2D;
//    i:Integer;
begin

end;
procedure GDBObjEllipse.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'ELLIPSE','AcDbEllipse',IODXFContext);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfvertexout(outhandle,11,majoraxis);
    SaveToDXFObjPostfix(outhandle);

  //dxfStringout(outhandle,100,'AcDbEllipse');
  //WriteString_EOL(outhandle, '100');
  //WriteString_EOL(outhandle, 'AcDbArc');
  dxfDoubleout(outhandle,40,ratio{ * 180 / pi});
  dxfDoubleout(outhandle,41,startangle{ * 180 / pi});
  dxfDoubleout(outhandle,42,endangle{ * 180 / pi});
end;
procedure GDBObjEllipse.LoadFromDXF;
var
  byt{, code}: Integer;
begin
  //initnul;
  byt:=f.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfvertexload(f,11,byt,MajorAxis) then
    if not dxfDoubleload(f,40,byt,ratio) then
    if not dxfDoubleload(f,41,byt,startangle) then
    if not dxfDoubleload(f,42,byt,endangle) then f.ReadPAnsiChar;
    byt:=f.ParseInteger;
  end;
  startangle := startangle{ * pi / 180};
  endangle := endangle{ * pi / 180};
  PProjoutbound:=nil;
  //format;
end;
function GDBObjEllipse.onmouse;
var i:Integer;
begin
     for i:=0 to 5 do
     begin
     if(mf[i].v[0] * P_insert_in_WCS.x + mf[i].v[1] * P_insert_in_WCS.y + mf[i].v[2] * P_insert_in_WCS.z + mf[i].v[3]+RR < 0 )
     then
     begin
          result:=false;
          //system.break;
          exit;
     end;
     end;
     result:=Vertex3D_in_WCS_Array.onmouse(mf,false);
end;
procedure GDBObjEllipse.remaponecontrolpoint(pdesc:pcontrolpointdesc);
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
procedure GDBObjEllipse.addcontrolpoints(tdesc:Pointer);
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
function GDBObjEllipse.getsnap;
//var t,d,e:Double;
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
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=q0;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq0)^;
            osp.ostype:=os_begin;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_midpoint)<>0
            then
            begin
            osp.worldcoord:=q1;
            pgdbvertex2d(@osp.dispcoord)^:=pgdbvertex2d(@pq1)^;
            osp.ostype:=os_midle;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
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
function GDBObjEllipse.beforertmodify;
begin
     Getmem(result,sizeof(tellipsertmodify));
     tellipsertmodify(result^).p1.x:=q0.x;
     tellipsertmodify(result^).p1.y:=q0.y;
     tellipsertmodify(result^).p2.x:=q1.x;
     tellipsertmodify(result^).p2.y:=q1.y;
     tellipsertmodify(result^).p3.x:=q2.x;
     tellipsertmodify(result^).p3.y:=q2.y;
end;
function GDBObjEllipse.IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;
begin
     result:=true;
end;
procedure GDBObjEllipse.rtmodifyonepoint(const rtmod:TRTModifyData);
var a,b,c,d,e,f,g,p_x,p_y,rrr:Double;
    tv:gdbvertex2d;
    ptdata:tellipsertmodify;
begin
     ptdata.p1.x:=q0.x;
     ptdata.p1.y:=q0.y;
     ptdata.p2.x:=q1.x;
     ptdata.p2.y:=q1.y;
     ptdata.p3.x:=q2.x;
     ptdata.p3.y:=q2.y;

  if rtmod.point.pointtype=os_begin then begin
    ptdata.p1.x:=q0.x+rtmod.dist.x;
    ptdata.p1.y:=q0.y+rtmod.dist.y;
  end else if rtmod.point.pointtype=os_midle then begin
    ptdata.p2.x:=q1.x+rtmod.dist.x;
    ptdata.p2.y:=q1.y+rtmod.dist.y;
  end else if  rtmod.point.pointtype=os_end then begin
    ptdata.p3.x:=q2.x+rtmod.dist.x;
    ptdata.p3.y:=q2.y+rtmod.dist.y;
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
        rrr:= sqrt(sqr(ptdata.p1.x - p_x) + sqr(ptdata.p1.y - p_y));
        rr:=rrr;
        Local.p_insert.x:=p_x;
        Local.p_insert.y:=p_y;
        Local.p_insert.z:=0;
        tv.x:=p_x;
        tv.y:=p_y;
        startangle:=vertexangle(tv,ptdata.p1);
        endangle:=vertexangle(tv,ptdata.p3);
        if startangle>endangle then
        begin
                                                                                      rrr:=startangle;
                                                                                      startangle:=endangle;
                                                                                      endangle:=rrr
        end;
        rrr:=vertexangle(tv,ptdata.p2);
        if (rrr>startangle) and (rrr<endangle) then
                                                                                 begin
                                                                                 end
                                                                             else
                                                                                 begin
                                                                                      rrr:=startangle;
                                                                                      startangle:=endangle;
                                                                                      endangle:=rrr
                                                                                 end;
        //format;
        //renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
        end;

end;
function GDBObjEllipse.Clone;
var tvo: PGDBObjEllipse;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjEllipse));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert, {r,}startangle,endangle,majoraxis);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  //tvo^.vp.ID:=GDBEllipseID;
  tvo^.Local:=local;
  tvo^.RR:=RR;
  tvo^.MajorAxis:=MajorAxis;
  tvo^.Ratio:=Ratio;

  //tvo^.format;
  result := tvo;
end;
procedure GDBObjEllipse.rtsave;
begin
  PGDBObjEllipse(refp)^.Local.p_insert := Local.p_insert;
  PGDBObjEllipse(refp)^.startangle := startangle;
  PGDBObjEllipse(refp)^.endangle := endangle;
  PGDBObjEllipse(refp)^.RR:=RR;
  PGDBObjEllipse(refp)^.MajorAxis:=MajorAxis;
  PGDBObjEllipse(refp)^.Ratio:=Ratio;
  //PGDBObjEllipse(refp)^.format;
  //PGDBObjEllipse(refp)^.renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
end;
function AllocEllipse:PGDBObjEllipse;
begin
  Getmem(result,sizeof(GDBObjEllipse));
end;
function AllocAndInitEllipse(owner:PGDBObjGenericWithSubordinated):PGDBObjEllipse;
begin
  result:=AllocEllipse;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
function GDBObjEllipse.CreateInstance:PGDBObjEllipse;
begin
  result:=AllocAndInitEllipse(nil);
end;
begin
  RegisterDXFEntity(GDBEllipseID,'ELLIPSE','Ellipse',@AllocEllipse,@AllocAndInitEllipse);
end.
