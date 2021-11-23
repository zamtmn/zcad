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

unit uzeentcircle;
{$INCLUDE def.inc}
interface
uses
    gzctnrvectortypes,uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzecamera,
    gzctnrvectorpobjects,uzestyleslayers,uzbtypesbase,uzehelpobj,UGDBSelectedObjArray,
    uzbgeomtypes,uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,UGDBOpenArrayOfByte,
    uzbtypes,uzeentwithlocalcs,uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzbmemman;
type
//PProjPoint:PGDBPolyPoint2DArray;
//PProjPoint:{-}PGDBPolyPoint2DArray{/GDBPointer/};
{Export+}
  ptcirclertmodify=^tcirclertmodify;
  {REGISTERRECORDTYPE tcirclertmodify}
  tcirclertmodify=record
                        r,p_insert:GDBBoolean;
                  end;
PGDBObjCircle=^GDBObjCircle;
{REGISTEROBJECTTYPE GDBObjCircle}
GDBObjCircle= object(GDBObjWithLocalCS)
                 Radius:GDBLength;(*'Radius'*)(*saved_to_shd*)
                 q0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q3:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq3:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure CalcObjMatrix;virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 procedure createpoint(var DC:TDrawContext);virtual;
                 procedure projectpoint;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                 //procedure higlight;virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                 //function InRect:TInRect;virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 function beforertmodify:GDBPointer;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;

                 function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;
                 destructor done;virtual;

                 function GetObjTypeName:GDBString;virtual;

                 procedure createfield;virtual;
                 function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual; //<**Пересечение с линией описанной 2-я точками
                 procedure ReCalcFromObjMatrix;virtual;

                 function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                 function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;

                 class function CreateInstance:PGDBObjCircle;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
implementation
//uses
//    log;
function GDBObjCircle.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
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

function GDBObjCircle.GetTangentInPoint(point:GDBVertex):GDBVertex;
begin
     point:=uzegeometry.VertexSub(self.P_insert_in_WCS,point);
     result:=normalizevertex(uzegeometry.vectordot(point,self.Local.basis.oz));
end;
procedure GDBObjCircle.ReCalcFromObjMatrix;
//var
    //ox:gdbvertex;
begin
     inherited;
     Local.P_insert:=PGDBVertex(@objmatrix[3])^;
     self.Radius:=PGDBVertex(@objmatrix[0])^.x/local.basis.OX.x;
     {scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;}

     {if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.oz);
     normalizevertex(ox);
     rotate:=uzegeometry.scalardot(Local.ox,ox);
     rotate:=arccos(rotate)*180/pi;
     if local.OX.y<-eps then rotate:=360-rotate;}
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
     pq0:=nulvertex;
     pq1:=nulvertex;
     pq2:=nulvertex;
     pq3:=nulvertex;
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
function GDBObjCircle.ObjToGDBString(prefix,sufix:GDBString):GDBString;
begin
     result:=prefix+inherited ObjToGDBString('GDBObjCircle (addr:',')')+sufix;
end;
constructor GDBObjCircle.initnul;
begin
  inherited initnul(nil);
  //vp.ID := GDBCircleID;
  Radius := 1;
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{A9E5DE52-33D2-4658-A53E-986711DFBD14}',{$ENDIF}100);
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
  //ObjToGDBString('','');
  PProjoutbound:=nil;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{B3C847F9-E9DE-4B69-883A-B6D322142B0B}',{$ENDIF}100);
  //format;
end;
function GDBObjCircle.GetObjType;
begin
     result:=GDBCircleID;
end;
procedure GDBObjCircle.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'CIRCLE','AcDbCircle',IODXFContext);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfGDBDoubleout(outhandle,40,Radius);
  SaveToDXFObjPostfix(outhandle);
end;

procedure GDBObjCircle.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
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
  Representation.Clear;
  Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,true,true);
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjCircle.getoutbound;
var //tv,tv2:GDBVertex4D;
    t,b,l,r,n,f:GDBDouble;
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



  if PProjoutbound=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{692F5C82-E281-44D3-8156-ECC07AFB2FBC}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{0793766F-F818-48DA-918B-D9326DB90240}',{$ENDIF}4);
  end;
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
procedure GDBObjCircle.Renderfeedback;
var //pm:DMatrix4D;
    tv:GDBvertex;
    d:GDBDouble;
begin
           //myGluProject(Local.p_insert.x,Local.p_insert.y,Local.p_insert.z,@POGLWnd^.pcamera^.modelMatrix,@POGLWnd^.pcamera^.projMatrix,@POGLWnd^.pcamera^.viewport,ProjP_insert.x,ProjP_insert.y,ProjP_insert.z);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(P_insert_in_WCS,ProjP_insert);
           if assigned(pprojoutbound)then
             pprojoutbound^.clear
           else
             getoutbound(dc);
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
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(q3,pq3);
           if pprojoutbound^.count<4 then
           begin
            lod:=4;
            //projectpoint;
           end
           else
           begin
                d:=pprojoutbound^.perimetr;
                d:=d/10;
                if d>255 then d:=255;
                if d<10 then d:=10;
                if lod<>round(d) then
                begin
                     lod:=round(d);
                     createpoint(dc);
                end;
                projectpoint;
           end;
end;
procedure GDBObjCircle.CalcObjMatrix;
var m1{,m2,m3,m4}:DMatrix4D;
begin
  inherited CalcObjMatrix;
  m1:=ONEMATRIX;
  m1[0, 0] := Radius;
  m1[1, 1] := Radius;
  m1[2, 2] := Radius;
  objmatrix:=matrixmultiply(m1,objmatrix);
end;

procedure GDBObjCircle.DrawGeometry;
//var
  //angle: GDBDouble;
  //i: GDBInteger;
begin
           if dc.selected then
                              begin
                              //Vertex3D_in_WCS_Array.drawgeometry2
                              Representation.DrawGeometry(DC);
                              end
                          else
                              begin
                                   if CanSimplyDrawInOCS(DC,{self.radius}1,6) then
                                                                                  begin
                                                                                       //Vertex3D_in_WCS_Array.drawgeometry
                                                                                       Representation.DrawGeometry(DC);
                                                                                  end
                                                         else
                                                             begin
                                                                  DC.Drawer.DrawLine3DInModelSpace(q0,q1,DC.DrawingContext.matrixs);
                                                                  DC.Drawer.DrawLine3DInModelSpace(q1,q2,DC.DrawingContext.matrixs);
                                                                  DC.Drawer.DrawLine3DInModelSpace(q2,q3,DC.DrawingContext.matrixs);
                                                                  DC.Drawer.DrawLine3DInModelSpace(q3,q0,DC.DrawingContext.matrixs);
                                                             end;
                              end;
  //Vertex3D_in_WCS_Array.DrawGeometry;

  {
  oglsm.myglpushmatrix;
  glmultmatrixd(@objmatrix);
  if (((not poglwnd.scrollmode)or(not sysvar.RD.RD_PanObjectDegradation^)) and (lod>8)) then begin
                                                                                          circlepointoflod[lod].drawgeometry;
                                                                                          myglbegin(gl_points);
                                                                                          circlepointoflod[lod].iterategl(@glvertex2dv);
                                                                                          myglend;
                                                                                     end
                                                                                else circlepointoflod[8].drawgeometry;
  oglsm.myglpopmatrix;
  }
  inherited;
end;
procedure GDBObjCircle.projectpoint;
{var pm:DMatrix4D;
    tv:GDBvertex;
    tpv:GDBPolyVertex2D;
    ptpv:PGDBPolyVertex2D;
    i:GDBInteger;}
begin
end;
procedure GDBObjCircle.LoadFromDXF;
var //s: GDBString;
  byt{, code}: GDBInteger;
begin
  //initnul;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
    if not dxfvertexload(f,10,byt,Local.P_insert) then
    if not dxfGDBDoubleload(f,40,byt,Radius) then {s := }f.readgdbstring;
    byt:=readmystrtoint(f);
  end;
  //PProjoutbound:=nil;
  //pprojpoint:=nil;
  //format;
end;
function GDBObjCircle.Clone;
var tvo: PGDBObjCircle;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{0238E343-798C-4E03-9518-0F251F8F4F80}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjCircle));
  tvo^.init(CalcOwner(own),vp.Layer, vp.LineWeight, Local.p_insert, Radius);
  tvo^.local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjCircle.rtedit;
begin
  if mode = os_center then
  begin
    Local.p_insert := VertexAdd(pgdbobjcircle(refp)^.Local.p_insert, dist);
  end
  else if (mode = os_q0) or (mode = os_q1) or (mode = os_q2) or (mode = os_q3) then
  begin
         //r:=VertexAdd(pgdbobjcircle(refp)^.p_insert,wc);
    Radius := Vertexlength(Local.p_insert, wc);
  end;
  //format;
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
var i:GDBInteger;
begin
     for i:=0 to 5 do
     begin
     if(mf[i][0] * P_insert_in_WCS.x + mf[i][1] * P_insert_in_WCS.y + mf[i][2] * P_insert_in_WCS.z + mf[i][3]+radius < 0 )
     then
     begin
          result:=false;
          system.exit;
     end;
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
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 5 do
      begin
      if(frustum[i][0] * P_insert_in_WCS.x + frustum[i][1] * P_insert_in_WCS.y + frustum[i][2] * P_insert_in_WCS.z + frustum[i][3]+radius{+GetLTCorrectH} < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjCircle.CalcTrueInFrustum;
var i{,count}:GDBInteger;
    //d1,d2,d3,d4:gdbdouble;
begin
      for i:=0 to 5 do
      begin
      if(frustum[i][0] * P_insert_in_WCS.x + frustum[i][1] * P_insert_in_WCS.y + frustum[i][2] * P_insert_in_WCS.z + frustum[i][3]+radius{+GetLTCorrectH} < 0 )
      then
      begin
           result:=IREmpty;
           exit;
           //system.break;
      end;
      end;
      result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum);
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
            osp.dispcoord:=ProjP_insert;
            osp.ostype:=os_center;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q0;
            osp.dispcoord:=pq0;
            osp.ostype:=os_q0;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q1;
            osp.dispcoord:=pq1;
            osp.ostype:=os_q1;
            end
            else osp.ostype:=os_none;
       end;
     3:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q2;
            osp.dispcoord:=pq2;
            osp.ostype:=os_q2;
            end
            else osp.ostype:=os_none;
       end;
     4:begin
            if (SnapMode and osm_quadrant)<>0
            then
            begin
            osp.worldcoord:=q3;
            osp.dispcoord:=pq3;
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
            PointOfLinePlaneIntersect({GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseraywithoutOS.lbegin,
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
//var i:GDBInteger;
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
procedure GDBObjCircle.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_center:begin
          pdesc.worldcoord:=P_insert_in_WCS;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(ProjP_insert.y);
                             end;
                    os_q0:begin
          pdesc.worldcoord:=q0;
          pdesc.dispcoord.x:=round(Pq0.x);
          pdesc.dispcoord.y:=round(Pq0.y);
                             end;
                    os_q1:begin
          pdesc.worldcoord:=q1;
          pdesc.dispcoord.x:=round(Pq1.x);
          pdesc.dispcoord.y:=round(Pq1.y);
                             end;
                    os_q2:begin
          pdesc.worldcoord:=q2;
          pdesc.dispcoord.x:=round(Pq2.x);
          pdesc.dispcoord.y:=round(Pq2.y);
                             end;
                    os_q3:begin
          pdesc.worldcoord:=q3;
          pdesc.dispcoord.x:=round(Pq3.x);
          pdesc.dispcoord.y:=round(Pq3.y);
                             end;
                    end;
end;
procedure GDBObjCircle.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{8B6B9276-7E44-4F66-AE81-AAED0879173A}',{$ENDIF}5);
          pdesc.selected:=false;
          pdesc.pobject:=nil;
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
     GDBGetMem({$IFDEF DEBUGBUILD}'{AC2C102F-944D-4CF8-A111-0DB5CCFB51C8}',{$ENDIF}result,sizeof(tcirclertmodify));
     fillchar(result^,sizeof(tcirclertmodify),0);
end;
function GDBObjCircle.IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;
begin
     result:=false;
  case point.pointtype of
       os_center:begin
                      if not ptcirclertmodify(p).p_insert then
                                                              result:=true;
                      ptcirclertmodify(p).p_insert:=true;
                 end;
    oS_q3..os_q0:begin
                      if (not ptcirclertmodify(p).r)and
                         (not ptcirclertmodify(p).p_insert)then
                                                               result:=true;
                      ptcirclertmodify(p).r:=true;
                 end;
  end;

end;
procedure GDBObjCircle.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
          case rtmod.point.pointtype of
               os_center:begin
                             Local.p_insert:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             Radius:=Radius;
                         end;
            oS_q3..os_q0:begin
                              Radius:=Vertexlength(Local.p_insert {rtmod.point.worldcoord}, rtmod.wc);
                         end;
          end;
end;
function AllocCircle:PGDBObjCircle;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocCircle}',{$ENDIF}pointer(result),sizeof(GDBObjCircle));
end;
function AllocAndInitCircle(owner:PGDBObjGenericWithSubordinated):PGDBObjCircle;
begin
  result:=AllocCircle;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
procedure SetCircleGeomProps(Pcircle:PGDBObjCircle;args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pcircle.Local.p_insert:=CreateVertexFromArray(counter,args);
  Pcircle.Radius:=CreateDoubleFromArray(counter,args);
end;
function AllocAndCreateCircle(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjCircle;
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

