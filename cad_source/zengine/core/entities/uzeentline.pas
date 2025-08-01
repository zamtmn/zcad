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

unit uzeentline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses uzbLogIntf,uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,
     uzestyleslayers,uzeentsubordinated,
     UGDBSelectedObjArray,uzeent3d,uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,
     uzegeometrytypes,uzglviewareadata,uzegeometry,uzeffdxfsupport,
     uzeSnap,uzMVReader,uzCtnrVectorpBaseEntity;
type
PGDBObjLine=^GDBObjLine;
GDBObjLine= object(GDBObj3d)
                 {-}private{//}
                 fCoordInWCS:GDBLineProp;
                 {-}public{//}
                 CoordInOCS:GDBLineProp;

                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p1,p2:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                 procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
                 function IsStagedFormatEntity:boolean;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure CalcGeometry;virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                  function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                  function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                  function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;virtual;
                 //procedure feedbackinrect;virtual;
                 //function InRect:TInRect;virtual;
                  function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                  function getintersect(var osp:os_record;pobj:PGDBObjEntity; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                destructor done;virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                  function beforertmodify:Pointer;virtual;
                  procedure clearrtmodify(p:Pointer);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
                  function jointoline(pl:pgdbobjline;var drawing:TDrawingDef):Boolean;virtual;

                  function ObjToString(const prefix,sufix:String):String;virtual;
                  function GetObjTypeName:String;virtual;
                  function GetCenterPoint:GDBVertex;virtual;
                  procedure getoutbound(var DC:TDrawContext);virtual;
                  function CalcInFrustum(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                  function CalcTrueInFrustum(const frustum:ClipArray):TInBoundingVolume;virtual;

                  function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;
                  procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                  function GetTangentInPoint(const point:GDBVertex):GDBVertex;virtual;

                  class function CreateInstance:PGDBObjLine;static;
                  function GetObjType:TObjID;virtual;

                  function getCoordInWCS:GDBLineProp;

                  {-}property CoordInWCS:GDBLineProp read fCoordInWCS write fCoordInWCS;{//}
           end;
ptlinertmodify=^tlinertmodify;
tlinertmodify=record
                    lbegin,lmidle,lend:Boolean;
                end;
function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
implementation
//uses log;
function GDBObjLine.GetTangentInPoint(const point:GDBVertex):GDBVertex;
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
    //t,b,l,r,n,f:Double;
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
function GDBObjLine.jointoline(pl:pgdbobjline;var drawing:TDrawingDef):Boolean;
function online(w,u:gdbvertex):Boolean;
var ww:Double;
    l:Double;
begin
     ww:=scalardot(w,u);
     l:=SqrOneVertexlength(VertexSub(w,VertexMulOnSc(u,ww)));
     if eps>l then
                  result:=true
              else
                  result:=false;
end;
var t1,t2,a1,a2:Double;
    q:Boolean;
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
     w:=VertexSub(pl.CoordInWCS.lbegin,CoordInWCS.lbegin);
     t1:=(scalardot(w,dir))/SqrOneVertexlength(dir);
     q:=online(w,u);
     w:=VertexSub(pl.CoordInWCS.lend,CoordInWCS.lbegin);
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
     //self.CoordInWCS.lend:=VertexDmorph(self.CoordInWCS.lbegin,dir,a2);
     //self.CoordInWCS.lbegin:=VertexDmorph(self.CoordInWCS.lbegin,dir,a1);
     dc:=drawing.CreateDrawingRC;
     FormatEntity(drawing,dc);
     pl^.YouDeleted(drawing);
     result:=true;
end;
function GDBObjLine.ObjToString(const prefix,sufix:String):String;
begin
     result:=prefix+inherited ObjToString('GDBObjLine (addr:',')')+sufix;
end;
constructor GDBObjLine.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  //vp.ID := GDBlineID;
  CoordInOCS.lBegin := NulVertex;
  CoordInOCS.lEnd := NulVertex;
  //PProjPoint:=nil;
end;
constructor GDBObjLine.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBlineID;
  CoordInOCS.lBegin := p1;
  CoordInOCS.lEnd := p2;
  //PProjPoint:=nil;
  //format;
end;
function GDBObjLine.GetObjType;
begin
     result:=GDBlineID;
end;
procedure GDBObjLine.LoadFromDXF;
var //s: String;
  byt: Integer;
begin
  byt:=rdr.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing) then
       if not dxfvertexload(rdr,10,byt,CoordInOCS.lBegin) then
          if not dxfvertexload(rdr,11,byt,CoordInOCS.lEnd) then {s := }rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
end;
destructor GDBObjLine.done;
begin
     //if PProjPoint<>nil then
     //                       Freemem(Pointer(PProjPoint));
     inherited done;
end;
function GDBObjLine.getCoordInWCS:GDBLineProp;
var m:DMatrix4D;
begin
  if bp.ListPos.owner<>nil then begin
    if bp.ListPos.owner^.GetHandle=H_Root then begin
      result.lbegin:=CoordInOCS.lbegin;
      result.lend:=CoordInOCS.lend;
    end else begin
      m:=bp.ListPos.owner^.GetMatrix^;
      result.lbegin:=VectorTransform3D(CoordInOCS.lbegin,m);
      result.lend:=VectorTransform3D(CoordInOCS.lend,m);
    end;
  end else begin
    result.lbegin:=CoordInOCS.lbegin;
    result.lend:=CoordInOCS.lend;
  end;
end;

procedure GDBObjLine.CalcGeometry;
var
  m:DMatrix4D;
  tlp:GDBLineProp;
begin
  if bp.ListPos.owner<>nil then begin
    if bp.ListPos.owner^.GetHandle=H_Root then begin
      CoordInWCS:=CoordInOCS;
    end else begin
      m:=bp.ListPos.owner^.GetMatrix^;

      tlp.lbegin:=VectorTransform3D(CoordInOCS.lbegin,m);
      tlp.lend:=VectorTransform3D(CoordInOCS.lend,m);
      CoordInWCS:=tlp;
    end;
  end else begin
    CoordInWCS:=CoordInOCS;
  end;
end;

function GDBObjLine.IsStagedFormatEntity:boolean;
begin
  result:=true;
end;

procedure GDBObjLine.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions)then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

    calcgeometry;
    calcbb(dc);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    Representation.Clear;
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      if assigned(EntExtensions)then begin
        if EntExtensions.NeedStandardDraw(@self,drawing,DC) then
          Representation.DrawLineByConstRefLinePropWithLT(self,getmatrix^,dc,CoordInOCS,vp,true);
      end else
        Representation.DrawLineByConstRefLinePropWithLT(self,getmatrix^,dc,CoordInOCS,vp,true);
    end;
    Representation.Shrink;
    if assigned(EntExtensions)then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;
function GDBObjLine.CalcInFrustum;
var i:Integer;
begin
      if CalcAABBInFrustum(vp.BoundingBox,frustum)<>IREmpty then
                                                                                  result:=true
                                                                              else
                                                                                  result:=false;
      exit;
      result:=true;
      for i:=0 to 5 do
      begin
      if(frustum[i].v[0] * CoordInWCS.lbegin.x + frustum[i].v[1] * CoordInWCS.lbegin.y + frustum[i].v[2] * CoordInWCS.lbegin.z + frustum[i].v[3] < 0 )
     and(frustum[i].v[0] * CoordInWCS.lend.x +   frustum[i].v[1] * CoordInWCS.lend.y +   frustum[i].v[2] * CoordInWCS.lend.z +   frustum[i].v[3] < 0 )
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
function GDBObjLine.onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:GDBVertex):Boolean;
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
begin
  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
end;

function GDBObjLine.getsnap;
var t,d,e:Double;
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
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[1];
            osp.ostype:=os_end;
            end
            else osp.ostype:=os_none;
       end;
     1:begin
            if (SnapMode and osm_4)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 4);
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[2];
            osp.ostype:=os_1_4;
            end
            else osp.ostype:=os_none;
       end;
     2:begin
            if (SnapMode and osm_3)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 3);
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[3];
            osp.ostype:=os_1_3;
            end
            else osp.ostype:=os_none;
       end;
     3:begin
            if (SnapMode and osm_midpoint)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2);
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[4];
            osp.ostype:=os_midle;
            end
            else osp.ostype:=os_none;
       end;
     4:begin
            if (SnapMode and osm_3)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 2 / 3);
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[5];
            osp.ostype:=os_2_3;
            end
            else osp.ostype:=os_none;
       end;
     5:begin
            if (SnapMode and osm_4)<>0
            then
            begin
            osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 3 / 4);
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[6];
            osp.ostype:=os_3_4;
            end
            else osp.ostype:=os_none;
       end;
     6:begin
            if (SnapMode and osm_endpoint)<>0
            then
            begin
            osp.worldcoord:=CoordInWCS.lbegin;
            ProjectProc(osp.worldcoord,osp.dispcoord);
            //pgdbvertex2d(@osp.dispcoord)^:=pprojpoint^[0];
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
function line2dintercep(var x11, y11, x12, y12, x21, y21, x22, y22: Double; out t1,t2: Double): Boolean;
var
  d, d1, d2, dx1,dy1,dx2,dy2: Double;
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
var
  t1,t2,dist:Double;
  l1b,l1e,l2b,l2e,tv1,tv2,dir,dir2:gdbvertex;
begin
  if (onlygetsnapcount=1)or(pobj^.getobjtype<>gdblineid) then
    exit(false);

  result:=true;
  ProjectProc(CoordInWCS.lbegin,l1b);
  ProjectProc(CoordInWCS.lEnd,l1e);
  ProjectProc(pgdbobjline(pobj)^.CoordInWCS.lbegin,l2b);
  ProjectProc(pgdbobjline(pobj)^.CoordInWCS.lEnd,l2e);

  case onlygetsnapcount of
    0:begin
      if ((SnapMode and osm_apparentintersection)<>0)or((SnapMode and osm_intersection)<>0) then begin
        if line2dintercep(l1b.x,l1b.y,l1e.x,l1e.y,l2b.x,l2b.y,l2e.x,l2e.y,t1,t2) then begin
          dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
          dir2:=VertexSub(pgdbobjline(pobj)^.CoordInWCS.lEnd,pgdbobjline(pobj)^.CoordInWCS.lBegin);
          tv1.x:=CoordInWCS.lbegin.x+dir.x*t1;
          tv1.y:=CoordInWCS.lbegin.y+dir.y*t1;
          tv1.z:=CoordInWCS.lbegin.z+dir.z*t1;
          tv2.x:=pgdbobjline(pobj)^.CoordInWCS.lbegin.x+dir2.x*t2;
          tv2.y:=pgdbobjline(pobj)^.CoordInWCS.lbegin.y+dir2.y*t2;
          tv2.z:=pgdbobjline(pobj)^.CoordInWCS.lbegin.z+dir2.z*t2;
          dist:=Vertexlength(tv1,tv2);
          if dist<bigeps then begin
            if (SnapMode and osm_intersection)<>0 then begin
              osp.worldcoord:=tv1;
              {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,osp.dispcoord);
              osp.ostype:=os_intersection;
            end else
              osp.ostype:=os_none;
          end else begin
            if (SnapMode and osm_apparentintersection)<>0 then begin
              osp.worldcoord:=tv1;
              line2dintercep(l1b.x,l1b.y,l1e.x,l1e.y,l2b.x,l2b.y,l2e.x,l2e.y,t1,t2);
              {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(osp.worldcoord,osp.dispcoord);
              osp.ostype:=os_apparentintersection;
            end else
              osp.ostype:=os_none;
          end;
        end;
      end else
        osp.ostype:=os_none;
    end;
  end;
  inc(onlygetsnapcount);
end;
function GDBObjLine.Clone;
var tvo: PGDBObjLine;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjLine));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, CoordInOCS.lBegin, CoordInOCS.lEnd);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.CoordInOCS.lBegin.y := tvo^.CoordInOCS.lBegin.y;
  tvo^.bp.ListPos.Owner:=own;
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjLine.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,dxfName_Line,dxfName_AcDbLine,IODXFContext);
  dxfvertexout(outStream,10,CoordInOCS.lbegin);
  dxfvertexout(outStream,11,CoordInOCS.lend);
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
     Getmem(result,sizeof(tlinertmodify));
     clearrtmodify(result);
end;
procedure GDBObjLine.clearrtmodify(p:Pointer);
begin
     fillchar(p^,sizeof(tlinertmodify),0);
end;
function GDBObjLine.IsRTNeedModify(const Point:PControlPointDesc; p:Pointer):Boolean;
begin
  result:=false;
  if point.pointtype=os_begin then begin
    if not ptlinertmodify(p)^.lbegin then
      result:=true;
    ptlinertmodify(p)^.lbegin:=true;
  end else if point.pointtype=os_end then begin
    if not ptlinertmodify(p)^.lend then
      result:=true;
    ptlinertmodify(p)^.lend:=true;
  end else if point.pointtype=os_midle then begin
    if (not ptlinertmodify(p)^.lbegin)
    and (not ptlinertmodify(p)^.lend) then
      result:=true;
    ptlinertmodify(p)^.lbegin:=true;
    ptlinertmodify(p)^.lend:=true;
  end;

end;

procedure GDBObjLine.rtmodifyonepoint(const rtmod:TRTModifyData);
var
    tv,tv2:GDBVERTEX;
begin
  if rtmod.point.pointtype=os_begin then begin
    CoordInOCS.lbegin:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
  end else if rtmod.point.pointtype=os_end then begin
    CoordInOCS.lend:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
  end else if rtmod.point.pointtype=os_midle then begin
    tv:=uzegeometry.VertexSub(CoordInOCS.lend,CoordInOCS.lbegin);
    tv:=uzegeometry.VertexMulOnSc(tv,0.5);
    tv2:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
    CoordInOCS.lbegin:=VertexSub(tv2, tv);
    CoordInOCS.lend:=VertexAdd(tv2,tv);
  end;
end;
procedure GDBObjLine.remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);
var
  tv:GDBvertex;
begin
  if pdesc^.pointtype=os_begin then begin
    pdesc.worldcoord:=CoordInWCS.lbegin;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_end then begin
    pdesc.worldcoord:=CoordInWCS.lend;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_midle then begin
    pdesc.worldcoord:=Vertexmorph(CoordInWCS.lbegin, CoordInWCS.lend, 1 / 2);
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end;
end;
procedure GDBObjLine.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(3);

          pdesc.selected:=false;
          pdesc.PDrawable:=nil;

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
  Getmem(pointer(result),sizeof(GDBObjLine));
end;
function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
begin
  result:=AllocLine;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
procedure SetLineGeomProps(Pline:PGDBObjLine; const args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pline.CoordInOCS.lBegin:=CreateVertexFromArray(counter,args);
  Pline.CoordInOCS.lEnd:=CreateVertexFromArray(counter,args);
end;
function AllocAndCreateLine(owner:PGDBObjGenericWithSubordinated; const args:array of const):PGDBObjLine;
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
