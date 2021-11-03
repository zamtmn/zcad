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

unit uzeentline;
{$INCLUDE def.inc}

interface
uses LCLProc,uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,
     gzctnrvectorpobjects,uzestyleslayers,uzbtypesbase,uzeentsubordinated,
     UGDBSelectedObjArray,uzeent3d,uzeentity,UGDBOpenArrayOfByte,uzbtypes,uzeconsts,
     uzbgeomtypes,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzbmemman;
type
{Export+}
PGDBObjLine=^GDBObjLine;
{REGISTEROBJECTTYPE GDBObjLine}
GDBObjLine= object(GDBObj3d)
                 CoordInOCS:GDBLineProp;(*'Coordinates OCS'*)(*saved_to_shd*)
                 CoordInWCS:GDBLineProp;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PProjPoint:PGDBLineProj;(*'Coordinates DCS'*)(*hidden_in_objinsp*)

                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p1,p2:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure CalcGeometry;virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                  function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                  function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                  function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;
                 //procedure feedbackinrect;virtual;
                 //function InRect:TInRect;virtual;
                  function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                  function getintersect(var osp:os_record;pobj:PGDBObjEntity; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                destructor done;virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                  function beforertmodify:GDBPointer;virtual;
                  procedure clearrtmodify(p:GDBPointer);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                  function jointoline(pl:pgdbobjline;var drawing:TDrawingDef):GDBBoolean;virtual;

                  function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;
                  function GetObjTypeName:GDBString;virtual;
                  function GetCenterPoint:GDBVertex;virtual;
                  procedure getoutbound(var DC:TDrawContext);virtual;
                  function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                  function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;

                  function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;
                  procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                  function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;

                  class function CreateInstance:PGDBObjLine;static;
                  function GetObjType:TObjID;virtual;
           end;
{Export-}
ptlinertmodify=^tlinertmodify;
tlinertmodify=record
                    lbegin,lmidle,lend:GDBBoolean;
                end;
function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
implementation
//uses log;
function GDBObjLine.GetTangentInPoint(point:GDBVertex):GDBVertex;
begin
     result:=normalizevertex(VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin));
end;
procedure GDBObjLine.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
var tv,dir:gdbvertex;
begin
     dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
     processaxis(posr,dir);
     //posr.arrayworldaxis.Add(@dir);
     tv:=uzegeometry.vectordot(dir,zwcs);
     processaxis(posr,tv);
     //posr.arrayworldaxis.Add(@tv);
end;
function GDBObjLine.IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;
begin
     result:=intercept3d(lbegin,lend,CoordInWCS.lBegin,CoordInWCS.lEnd);
end;
procedure GDBObjLine.getoutbound;
//var //tv,tv2:GDBVertex4D;
    //t,b,l,r,n,f:GDBDouble;
begin
     vp.BoundingBox:=CreateBBFrom2Point(CoordInWCS.lBegin,CoordInWCS.lEnd);
end;
function GDBObjLine.GetCenterPoint;
begin
     result:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 0.5);
end;
function GDBObjLine.GetObjTypeName;
begin
     result:=ObjN_GDBObjLine;
end;
function GDBObjLine.jointoline(pl:pgdbobjline;var drawing:TDrawingDef):GDBBoolean;
function online(w,u:gdbvertex):GDBBoolean;
var ww:GDBDouble;
    l:GDBDouble;
begin
     ww:=scalardot(w,u);
     l:=SqrOneVertexlength(VertexSub(w,VertexMulOnSc(u,ww)));
     if eps>l then
                  result:=true
              else
                  result:=false;
end;
var t1,t2,a1,a2:GDBDouble;
    q:GDBBoolean;
    w,u,dir:gdbvertex;
    dc:TDrawContext;
begin
     result:=false;
     if Vertexlength(CoordInWCS.lbegin, CoordInWCS.lend)<Vertexlength(pl^.CoordInWCS.lbegin,pl^.CoordInWCS.lend) then
     begin
          result:=pl^.jointoline(@self,drawing);
          exit;
     end;
     dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
     u:=NormalizeVertex(dir);
     w:=VertexSub(pl.coordinwcs.lbegin,coordinwcs.lbegin);
     t1:=(scalardot(w,dir))/SqrOneVertexlength(dir);
     q:=online(w,u);
     w:=VertexSub(pl.coordinwcs.lend,coordinwcs.lbegin);
     t2:=(scalardot(w,dir))/SqrOneVertexlength(dir);
     q:=q and online(w,u);
     if not q then exit;
     a1:=0;
     a2:=1;
     if t1<a1 then a1:=t1;
     if t2<a1 then a1:=t2;
     if t1>a2 then a2:=t1;
     if t2>a2 then a2:=t2;
     self.CoordInOCS.lend:=VertexDmorph(self.CoordInOCS.lbegin,dir,a2);
     self.CoordInOCS.lbegin:=VertexDmorph(self.CoordInOCS.lbegin,dir,a1);
     self.CoordInWCS.lend:=VertexDmorph(self.CoordInWCS.lbegin,dir,a2);
     self.CoordInWCS.lbegin:=VertexDmorph(self.CoordInWCS.lbegin,dir,a1);
     dc:=drawing.CreateDrawingRC;
     FormatEntity(drawing,dc);
     pl^.YouDeleted(drawing);
     result:=true;
end;
function GDBObjLine.ObjToGDBString(prefix,sufix:GDBString):GDBString;
begin
     result:=prefix+inherited ObjToGDBString('GDBObjLine (addr:',')')+sufix;
end;
constructor GDBObjLine.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  //vp.ID := GDBlineID;
  CoordInOCS.lBegin := NulVertex;
  CoordInOCS.lEnd := NulVertex;
  PProjPoint:=nil;
end;
constructor GDBObjLine.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBlineID;
  CoordInOCS.lBegin := p1;
  CoordInOCS.lEnd := p2;
  PProjPoint:=nil;
  //format;
end;
function GDBObjLine.GetObjType;
begin
     result:=GDBlineID;
end;
procedure GDBObjLine.LoadFromDXF;
var //s: GDBString;
  byt: GDBInteger;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,CoordInOCS.lBegin) then
          if not dxfvertexload(f,11,byt,CoordInOCS.lEnd) then {s := }f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
end;
destructor GDBObjLine.done;
begin
     if PProjPoint<>nil then
                            GDBFreeMem(GDBPointer(PProjPoint));
     inherited done;
end;
procedure GDBObjLine.CalcGeometry;
var m:DMatrix4D;
begin
     if bp.ListPos.owner<>nil then
                                    begin
                                         if bp.ListPos.owner^.GetHandle=H_Root then
                                                                                   begin
                                                                                        CoordInWCS.lbegin:=CoordInOCS.lbegin;
                                                                                        CoordInWCS.lend:=CoordInOCS.lend;
                                                                                    end
                                                                               else
                                                                                   begin
                                                                                         m:=bp.ListPos.owner^.GetMatrix^;
                                                                                         CoordInWCS.lbegin:=VectorTransform3D(CoordInOCS.lbegin,m);
                                                                                         CoordInWCS.lend:=VectorTransform3D(CoordInOCS.lend,m);
                                                                                   end;
                                    end
                                else
                                    begin
                                         CoordInWCS.lbegin:=CoordInOCS.lbegin;
                                         CoordInWCS.lend:=CoordInOCS.lend;
                                    end;
end;

procedure GDBObjLine.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing);

  calcgeometry;
  calcbb(dc);

  Representation.Clear;
  Representation.DrawLineWithLT(dc,CoordInWCS.lBegin,CoordInWCS.lEnd,vp);
end;
function GDBObjLine.CalcInFrustum;
var i:GDBInteger;
begin
      if CalcAABBInFrustum(vp.BoundingBox,frustum)<>IREmpty then
                                                                                  result:=true
                                                                              else
                                                                                  result:=false;
      exit;
      result:=true;
      for i:=0 to 5 do
      begin
      if(frustum[i][0] * CoordInWCS.lbegin.x + frustum[i][1] * CoordInWCS.lbegin.y + frustum[i][2] * CoordInWCS.lbegin.z + frustum[i][3] < 0 )
     and(frustum[i][0] * CoordInWCS.lend.x +   frustum[i][1] * CoordInWCS.lend.y +   frustum[i][2] * CoordInWCS.lend.z +   frustum[i][3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjLine.CalcTrueInFrustum;
begin
      result:=Representation.CalcTrueInFrustum(frustum,true);
end;
function GDBObjLine.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
begin
     if {distance2piece}SQRdist_Point_to_Segment(point,self.CoordInWCS.lBegin,self.CoordInWCS.lEnd)<bigeps then
                                                                                  begin
                                                                                    result:=true;
                                                                                    objects.PushBackData(@self);
                                                                                  end
                                                                                else
                                                                                    result:=false;
end;

function GDBObjLine.onmouse;
begin
     if Representation.CalcTrueInFrustum(mf,false)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
end;
procedure GDBObjLine.DrawGeometry;
//var
//  templod:gdbdouble;
begin
  if (selected)or(dc.selected) then
                     Representation.DrawNiceGeometry(DC)
                 else
                     begin
                     Representation.DrawGeometry(DC);
                     exit;
                     end;
  {if vp.LineType<>nil then
     if vp.LineType.h>0 then
  begin
  templod:=(vp.LineType.h*vp.LineTypeScale*SysVar.dwg.DWG_LTScale^)/(dc.zoom);
  if templod<3 then
     begin
     DC.Drawer.DrawLine3DInModelSpace(CoordInWCS.lBegin,CoordInWCS.lEnd,DC.matrixs);
     end;
  end;}
  inherited;
  {oglsm.myglbegin(GL_points);
  myglVertex3dV(@CoordInWCS.lBegin);
  myglVertex3dV(@CoordInWCS.lEnd);
  oglsm.myglend;}
end;
procedure GDBObjLine.RenderFeedback;
var tv:GDBvertex;
//    ptv:PGDBvertex;
//    ptv2d:PGDBvertex2D;
//    i:GDBInteger;
begin
  //if POGLWnd=nil then exit;
  {if PProjPoint<>nil then
  begin
       GDBFreeMem(GDBPointer(PProjPoint));
  end;}
  if PProjPoint=nil then GDBGetMem({$IFDEF DEBUGBUILD}'{BC97B497-84C4-4E1D-9A61-26CA379F29A7}',{$ENDIF}GDBPointer(pprojpoint),sizeof(GDBLineProj));

  ProjectProc(CoordInWCS.lbegin,tv);
  pprojpoint^[0]:=pGDBvertex2D(@tv)^;
  ProjectProc(CoordInWCS.lEnd,tv);
  pprojpoint^[1]:=pGDBvertex2D(@tv)^;
  ProjectProc(Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 4),tv);
  pprojpoint^[2]:=pGDBvertex2D(@tv)^;
  ProjectProc(Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 3),tv);
  pprojpoint^[3]:=pGDBvertex2D(@tv)^;
  ProjectProc(Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2),tv);
  pprojpoint^[4]:=pGDBvertex2D(@tv)^;
  ProjectProc(Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 2 / 3),tv);
  pprojpoint^[5]:=pGDBvertex2D(@tv)^;
  ProjectProc(Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 3 / 4),tv);
  pprojpoint^[6]:=pGDBvertex2D(@tv)^;

  {ptv:=@CoordInWCS.lbegin;
  ptv2d:=@pprojpoint^[0];
  for i:=0 to 6 do
  begin                   iuy
  myGluProject(ptv^.x,ptv^.y,ptv^.z,@gdb.GetCurrentDWG.pcamera^.modelMatrix,@gdb.GetCurrentDWG.pcamera^.projMatrix,@gdb.GetCurrentDWG.pcamera^.viewport,ptv2d.x,ptv2d.y,tv.z);
  inc(ptv);
  inc(ptv2d);
  end;}
  //pdx:=PProjPoint[1].x-PProjPoint[0].x;
  //pdy:=PProjPoint[1].y-PProjPoint[0].y;
  inherited;

end;
function GDBObjLine.getsnap;
var t,d,e:GDBDouble;
    tv,n,v,dir:gdbvertex;
begin
     if onlygetsnapcount=9 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
     case onlygetsnapcount of
     0:begin
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=CoordInWCS.lend;
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[1];
            osp.ostype:=os_end;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_4)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 4);
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[2];
            osp.ostype:=os_1_4;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (SnapMode and osm_3)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 3);
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[3];
            osp.ostype:=os_1_3;
            end
            else osp.ostype:=os_none;
       end;
     3:begin
            if (SnapMode and osm_midpoint)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2);
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[4];
            osp.ostype:=os_midle;
            end
            else osp.ostype:=os_none;
       end;
     4:begin
            if (SnapMode and osm_3)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 2 / 3);
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[5];
            osp.ostype:=os_2_3;
            end
            else osp.ostype:=os_none;
       end;
     5:begin
            if (SnapMode and osm_4)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 3 / 4);
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[6];
            osp.ostype:=os_3_4;
            end
            else osp.ostype:=os_none;
       end;
     6:begin
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=CoordInWCS.lbegin;
            pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[0];
            osp.ostype:=os_begin;
            end
            else osp.ostype:=os_none;
       end;
     7:begin
            if (SnapMode and osm_perpendicular)<>0
            then
            begin
            tv:=vectordot(dir,{GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.dir);
            t:= -((CoordInWCS.lbegin.x-{GDB.GetCurrentDWG.OGLwindow1.}param.lastpoint.x)*dir.x+(CoordInWCS.lbegin.y-{GDB.GetCurrentDWG.OGLwindow1.}param.lastpoint.y)*dir.y+(CoordInWCS.lbegin.z-{GDB.GetCurrentDWG.OGLwindow1.}param.lastpoint.z)*dir.z)/
                 ({sqr(dir.x)+sqr(dir.y)+sqr(dir.z)}SqrVertexlength(self.CoordInWCS.lBegin,self.CoordInWCS.lEnd){length_2});
            if (t>=0) and (t<=1)
            then
            begin
            osp.worldcoord.x:=CoordInWCS.lbegin.x+t*dir.x;
            osp.worldcoord.y:=CoordInWCS.lbegin.y+t*dir.y;
            osp.worldcoord.z:=CoordInWCS.lbegin.z+t*dir.z;
            {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,tv);
            osp.dispcoord:=tv;
            osp.ostype:=os_perpendicular;
            end
            else osp.ostype:=os_none;
            end
            else osp.ostype:=os_none;
       end;
     8:begin
            if (SnapMode and osm_nearest)<>0
            then
            begin
            tv:=vectordot(dir,{GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.dir);
            n:=vectordot({GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.dir,tv);
            n:=NormalizeVertex(n);
            v.x:={GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.lbegin.x-CoordInWCS.lbegin.x;
            v.y:={GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.lbegin.y-CoordInWCS.lbegin.y;
            v.z:={GDB.GetCurrentDWG.OGLwindow1.}param.md.mouseray.lbegin.z-CoordInWCS.lbegin.z;
            d:=scalardot(n,v);
            e:=scalardot(n,dir);
            if e<eps then osp.ostype:=os_none
                     else
                         begin
                              if d<eps then osp.ostype:=os_none
                                       else
                                           begin
                                                t:=d/e;
                                                if (t>1)or(t<0)then osp.ostype:=os_none
                                                else
                                                begin
            osp.worldcoord.x:=CoordInWCS.lbegin.x+t*dir.x;
            osp.worldcoord.y:=CoordInWCS.lbegin.y+t*dir.y;
            osp.worldcoord.z:=CoordInWCS.lbegin.z+t*dir.z;
            {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,tv);
            osp.dispcoord:=tv;
            osp.ostype:=os_nearest;
                                               end;
                                           end;

                         end;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
function line2dintercep(var x11, y11, x12, y12, x21, y21, x22, y22: GDBDouble; out t1,t2: GDBDouble): GDBBoolean;
var
  d, d1, d2, dx1,dy1,dx2,dy2: GDBDouble;
begin
  t1 := 0;
  t2 := 0;
  result := false;
  dy1:=(y12 - y11);
  dx2:=(x21 - x22);
  dy2:=(y21 - y22);
  dx1:=(x12 - x11);
  D := dy1{(y12 - y11)} * dx2{(x21 - x22)} - dy2{(y21 - y22)} * dx1{(x12 - x11)};
  if {(D <> 0)}abs(d)>{bigeps}sqreps then
  begin
       D1 := (y12 - y11) * (x21 - x11) - (y21 - y11) * (x12 - x11);
       D2 := (y21 - y11) * (x21 - x22) - (y21 - y22) * (x21 - x11);
    t2 := D1 / D;
    t1 := D2 / D;
    if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      result := true;
    end;
  end;
end;
function GDBObjLine.getintersect;
var t1,t2,dist:GDBDouble;
    tv1,tv2,dir,dir2{,e}:gdbvertex;
begin
     if (onlygetsnapcount=1)or(pobj^.{vp.id}getobjtype<>gdblineid) then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if ((SnapMode and osm_apparentintersection)<>0)or((SnapMode and osm_intersection)<>0)
            then
            begin
            if not assigned(pgdbobjline(pobj)^.pprojpoint) then
                                                               begin
                                                               //pgdbobjline(pobj)^.RenderFeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);
                                                               debugln('{E}pobj)^.pprojpoint=nil;//(((((((');
                                                               osp.ostype:=os_none;
                                                               exit;
                                                               end;
            if line2dintercep(pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y,   pgdbobjline(pobj)^.pprojpoint[0].x,pgdbobjline(pobj)^.pprojpoint[0].y,pgdbobjline(pobj)^.pprojpoint[1].x,pgdbobjline(pobj)^.pprojpoint[1].y,  t1,t2)
            then
                begin
                     dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
                     dir2:=VertexSub(pgdbobjline(pobj)^.CoordInWCS.lEnd,pgdbobjline(pobj)^.CoordInWCS.lBegin);
                     tv1.x:=CoordInWCS.lbegin.x+dir.x*t1;
                     tv1.y:=CoordInWCS.lbegin.y+dir.y*t1;
                     tv1.z:=CoordInWCS.lbegin.z+dir.z*t1;
                     tv2.x:=pgdbobjline(pobj)^.CoordInWCS.lbegin.x+dir2.x*t2;
                     tv2.y:=pgdbobjline(pobj)^.CoordInWCS.lbegin.y+dir2.y*t2;
                     tv2.z:=pgdbobjline(pobj)^.CoordInWCS.lbegin.z+dir2.z*t2;
                     dist:=Vertexlength(tv1,tv2);
                     if dist<bigeps
                     then
                         begin
                              if (SnapMode and osm_intersection)<>0
                              then
                              begin
                              osp.worldcoord:=tv1;
                              {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,osp.dispcoord);
                              osp.ostype:=os_intersection;
                              end
                              else osp.ostype:=os_none;
                         end
                     else
                         begin
                              if (SnapMode and osm_apparentintersection)<>0
                              then
                              begin
                              osp.worldcoord:=tv1;
                              line2dintercep(pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y,   pgdbobjline(pobj)^.pprojpoint[0].x,pgdbobjline(pobj)^.pprojpoint[0].y,pgdbobjline(pobj)^.pprojpoint[1].x,pgdbobjline(pobj)^.pprojpoint[1].y,  t1,t2);
                              {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,osp.dispcoord);
                              osp.ostype:=os_apparentintersection;
                              end
                              else osp.ostype:=os_none;
                         end;
                end;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
function GDBObjLine.Clone;
var tvo: PGDBObjLine;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{5A1B005F-39F1-431B-B65E-0C532AEFA5D0}-GDBObjLine.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjLine));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, CoordInOCS.lBegin, CoordInOCS.lEnd);
  CopyVPto(tvo^);
  tvo^.CoordInOCS.lBegin.y := tvo^.CoordInOCS.lBegin.y;
  tvo^.bp.ListPos.Owner:=own;
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjLine.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'LINE','AcDbLine',IODXFContext);
  dxfvertexout(outhandle,10,CoordInOCS.lbegin);
  dxfvertexout(outhandle,11,CoordInOCS.lend);
end;
procedure GDBObjLine.rtedit;
begin
  if mode = os_midle then
  begin
    CoordInOCS.lbegin := VertexAdd(pgdbobjline(refp)^.CoordInOCS.lBegin, dist);
    CoordInOCS.lend := VertexAdd(pgdbobjline(refp)^.CoordInOCS.lend, dist);
  end
  else if mode = os_end then
  begin
    CoordInOCS.lend := VertexAdd(pgdbobjline(refp)^.CoordInOCS.lend, dist);
  end
  else if mode = os_begin then
  begin
    CoordInOCS.lbegin := VertexAdd(pgdbobjline(refp)^.CoordInOCS.lBegin, dist);
  end;
  //format;
end;

procedure GDBObjLine.rtsave;
begin
  pgdbobjline(refp)^.CoordInOCS.lBegin := CoordInOCS.lbegin;
  pgdbobjline(refp)^.CoordInOCS.lEnd := CoordInOCS.lend;
  //pgdbobjline(refp)^.format;
end;
procedure GDBObjLine.TransformAt;
begin
  CoordInOCS.lbegin:=uzegeometry.VectorTransform3D(pgdbobjline(p)^.CoordInOCS.lBegin,t_matrix^);
  CoordInOCS.lend:=VectorTransform3D(pgdbobjline(p)^.CoordInOCS.lend,t_matrix^);
end;
function GDBObjLine.beforertmodify;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{D2E91E60-41CC-45FE-AC5E-CAEC5013C0ED}',{$ENDIF}result,sizeof(tlinertmodify));
     clearrtmodify(result);
end;
procedure GDBObjLine.clearrtmodify(p:GDBPointer);
begin
     fillchar(p^,sizeof(tlinertmodify),0);
end;
function GDBObjLine.IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;
begin
     result:=false;
  case point.pointtype of
       os_begin:begin
                     if not ptlinertmodify(p)^.lbegin then
                                                               result:=true;
                     ptlinertmodify(p)^.lbegin:=true;
                end;
       os_end:begin
                     if not ptlinertmodify(p)^.lend then
                                                             result:=true;
                     ptlinertmodify(p)^.lend:=true;
                end;
       os_midle:begin
                     if (not ptlinertmodify(p)^.lbegin)
                     and (not ptlinertmodify(p)^.lend) then
                                                               result:=true;
                     ptlinertmodify(p)^.lbegin:=true;
                     ptlinertmodify(p)^.lend:=true;
                end;
  end;

end;

procedure GDBObjLine.rtmodifyonepoint(const rtmod:TRTModifyData);
var
    tv,tv2:GDBVERTEX;
begin
          case rtmod.point.pointtype of
               os_begin:begin
                             CoordInOCS.lbegin:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_end:begin
                           CoordInOCS.lend:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                      end;
               os_midle:begin
                             tv:=uzegeometry.VertexSub(CoordInOCS.lend,CoordInOCS.lbegin);
                             tv:=uzegeometry.VertexMulOnSc(tv,0.5);
                             tv2:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             CoordInOCS.lbegin:=VertexSub(tv2, tv);
                             CoordInOCS.lend:=VertexAdd(tv2,tv);
                        end;
          end;

end;
procedure GDBObjLine.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_begin:begin
                                  pdesc.worldcoord:=CoordInWCS.lbegin;
                                  pdesc.dispcoord.x:=round(PProjPoint[0].x);
                                  pdesc.dispcoord.y:=round(PProjPoint[0].y);
                             end;
                    os_end:begin
                                pdesc.worldcoord:=CoordInWCS.lend;
                                pdesc.dispcoord.x:=round(PProjPoint[1].x);
                                pdesc.dispcoord.y:=round(PProjPoint[1].y);
                             end;
                    os_midle:begin
                                  pdesc.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2);
                                  pdesc.dispcoord.x:=round(PProjPoint[4].x);
                                  pdesc.dispcoord.y:=round(PProjPoint[4].y);
                             end;
                    end;
end;
procedure GDBObjLine.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{4CBC9A73-A88D-443B-B925-2F0611D82AB0}',{$ENDIF}3);

          pdesc.selected:=false;
          pdesc.pobject:=nil;

          //renderfeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,nil);

          pdesc.pointtype:=os_midle;
          pdesc.attr:=[];
          pdesc.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2);
          {pdesc.dispcoord.x:=round(PProjPoint[4].x);
          pdesc.dispcoord.y:=round(PProjPoint[4].y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_begin;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=CoordInWCS.lbegin;
          {pdesc.dispcoord.x:=round(PProjPoint[0].x);
          pdesc.dispcoord.y:=round(PProjPoint[0].y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_end;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=CoordInWCS.lend;
          {pdesc.dispcoord.x:=round(PProjPoint[1].x);
          pdesc.dispcoord.y:=round(PProjPoint[1].y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
{function GDBObjLine.InRect;
begin
     result:=IREmpty;
     if pprojpoint=nil then
                           exit;
     if pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y)
    and pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pprojpoint[1].x,pprojpoint[1].y)
      then
          begin
               result:=IRFully;
          end
      else
          if
          intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
          then
          begin
               result:=IRPartially;
          end
end;}

procedure GDBObjLine.transform;
var tv:GDBVertex4D;
begin
  pgdbvertex(@tv)^:=CoordInOCS.lbegin;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  CoordInOCS.lbegin:=pgdbvertex(@tv)^;

  pgdbvertex(@tv)^:=CoordInOCS.lend;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  CoordInOCS.lend:=pgdbvertex(@tv)^;
end;
function AllocLine:PGDBObjLine;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocLine}',{$ENDIF}pointer(result),sizeof(GDBObjLine));
end;
function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
begin
  result:=AllocLine;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
procedure SetLineGeomProps(Pline:PGDBObjLine;args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pline.CoordInOCS.lBegin:=CreateVertexFromArray(counter,args);
  Pline.CoordInOCS.lEnd:=CreateVertexFromArray(counter,args);
end;
function AllocAndCreateLine(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjLine;
begin
  result:=AllocAndInitLine(owner);
  //owner^.AddMi(@result);
  SetLineGeomProps(result,args);
end;
class function GDBObjLine.CreateInstance:PGDBObjLine;
begin
  result:=AllocAndInitLine(nil);
end;
begin
  RegisterDXFEntity(GDBlineID,'LINE','Line',@AllocLine,@AllocAndInitLine,@SetLineGeomProps,@AllocAndCreateLine);
end.
