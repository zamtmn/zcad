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
unit uzeent3dface;
{$INCLUDE zengineconfig.inc}

interface
uses
    uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,
    uzegeometry,uzeffdxfsupport,uzestyleslayers,UGDBSelectedObjArray,uzeentsubordinated,
    uzegeometrytypes,uzeent3d,uzeentity,sysutils,uzctnrVectorBytes,uzbtypes,uzeconsts,
    uzctnrvectorpgdbaseobjects,uzglviewareadata;
type
{Export+}
{REGISTEROBJECTTYPE GDBObj3DFace}
PGDBObj3DFace=^GDBObj3DFace;
GDBObj3DFace= object(GDBObj3d)
                 PInOCS:OutBound4V;(*'Coordinates OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 triangle:Boolean;
                 n,p1,p2,p3:GDBVertex3S;
                 //ProjPoint:GDBvertex;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;

                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                 //function getsnap(var osp:os_record):Boolean;virtual;
                 function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                 procedure addcontrolpoints(tdesc:Pointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 function GetObjTypeName:String;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;

                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;

                 class function CreateInstance:PGDBObj3DFace;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}

implementation
//uses log;
procedure GDBObj3DFace.TransformAt;
var i:Integer;
begin
      for i:=0 to 3 do
      begin
           PInOCS[I]:=VectorTransform3D(PGDBObj3DFace(p)^.PInOCS[I],t_matrix^);
      end;
end;
procedure GDBObj3DFace.transform(const t_matrix:DMatrix4D);
var i:Integer;
begin
      for i:=0 to 3 do
      begin
           PInOCS[I]:=VectorTransform3D(PInOCS[I],t_matrix);
      end;
end;
procedure GDBObj3DFace.getoutbound;
var i:Integer;
begin
     vp.BoundingBox.LBN:=PInWCS[0];
     vp.BoundingBox.RTF:=PInWCS[0];
      for i:=1 to 3 do
      begin
           concatBBandPoint(vp.BoundingBox,PInWCS[I]);
      end;
end;
procedure GDBObj3DFace.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var i:Integer;
    v:GDBVertex;
begin
    if assigned(EntExtensions)then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

      for i:=0 to 3 do
      begin
           PInWCS[I]:=VectorTransform3D(PInOCS[I],{CurrentCS}bp.ListPos.owner^.GetMatrix^);
      end;
      v:=vectordot(
                   VertexSub(PInWCS[0],PInWCS[1])
                   ,
                   VertexSub(PInWCS[2],PInWCS[1])
                  );
      if IsVectorNul(v) then
                            normal:=xy_Z_Vertex
                        else
                            normal:=normalizevertex(v);

      {normal:=normalizevertex(
                              vectordot(
                                        uzegeometry.VertexSub(PInWCS[0],PInWCS[1])
                                        ,
                                        uzegeometry.VertexSub(PInWCS[2],PInWCS[1])
                                       )
                             );}
     {if uzegeometry.IsVectorNul(normal) then
                                         normal:=normal;}
       if IsPointEqual(PInOCS[2],PInOCS[3])then
                                                        triangle:=true
                                                    else
                                                        triangle:=false;
  calcbb(dc);
     p1.x:=PInWCS[0].x;
     p1.y:=PInWCS[0].y;
     p1.z:=PInWCS[0].z;

     p2.x:=PInWCS[2].x;
     p2.y:=PInWCS[2].y;
     p2.z:=PInWCS[2].z;

     p3.x:=PInWCS[3].x;
     p3.y:=PInWCS[3].y;
     p3.z:=PInWCS[3].z;

     n.x:=normal.x;
     n.y:=normal.y;
     n.z:=normal.z;
   if assigned(EntExtensions)then
     EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
function GDBObj3DFace.GetObjTypeName;
begin
     result:=ObjN_GDBObj3DFace;
end;
constructor GDBObj3DFace.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDB3DfaceID;
  PInOCS[0]:= p;
end;
constructor GDBObj3DFace.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  //vp.ID := GDB3DfaceID;
  PInOCS[1]:= NulVertex;
end;
function GDBObj3DFace.GetObjType;
begin
     result:=GDB3DfaceID;
end;
procedure GDBObj3DFace.LoadFromDXF;
var //s: String;
  byt: Integer;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,PInOCS[0]) then
          if not dxfvertexload(f,11,byt,PInOCS[1]) then
          if not dxfvertexload(f,12,byt,PInOCS[2]) then
          if not dxfvertexload(f,13,byt,PInOCS[3]) then
          {s := }f.readString;
    byt:=readmystrtoint(f);
  end;
end;
procedure GDBObj3DFace.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'3DFACE','AcDbFace',IODXFContext);
  dxfvertexout(outhandle,10,PInOCS[0]);
  dxfvertexout(outhandle,11,PInOCS[1]);
  dxfvertexout(outhandle,12,PInOCS[2]);
  dxfvertexout(outhandle,13,PInOCS[3]);
end;

procedure GDBObj3DFace.DrawGeometry;
//var
   //p:GDBvertex4F;
begin
(*  oglsm.myglEnable(GL_LIGHTING);
  oglsm.myglEnable(GL_LIGHT0);
  oglsm.myglEnable (GL_COLOR_MATERIAL);

  p.x:=gdb.GetCurrentDWG.pcamera^.prop.point.x;
  p.y:=gdb.GetCurrentDWG.pcamera^.prop.point.y;
  p.z:=gdb.GetCurrentDWG.pcamera^.prop.point.z;
  p.w:=0;
  glLightfv(GL_LIGHT0,
            GL_POSITION,
            @p) ;

  {p.x:=gdb.GetCurrentDWG.pcamera^.look.x;
  p.y:=gdb.GetCurrentDWG.pcamera^.look.y;
  p.z:=gdb.GetCurrentDWG.pcamera^.look.z;
  p.w:=0;
  glLightfv(GL_LIGHT0,
            GL_SPOT_DIRECTION,
            @p) ;}
glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,50.000000);
  p.x:=0;
  p.y:=0;
  p.z:=0;
  p.w:=1;
glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@p);
glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,1);
glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
oglsm.myglEnable(GL_COLOR_MATERIAL);
*)
  if triangle then
  begin
       dc.drawer.DrawTriangle3DInModelSpace(normal,PInwCS[0],PInwCS[1],PInwCS[2],dc.DrawingContext.matrixs);
       {oglsm.myglbegin(GL_TRIANGLES);
       oglsm.myglNormal3dV(@normal);
       oglsm.myglVertex3dV(@PInwCS[0]);
       oglsm.myglVertex3dV(@PInwCS[1]);
       oglsm.myglVertex3dV(@PInwCS[2]);
       oglsm.myglend;}
  end
     else
  begin
    dc.drawer.DrawQuad3DInModelSpace(normal,PInwCS[0],PInwCS[1],PInwCS[2],PInwCS[3],dc.DrawingContext.matrixs);
  {oglsm.myglbegin(GL_QUADS);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglend;}
  end;

  //oglsm.myglDisable(GL_LIGHTING);
  //oglsm.myglDisable(GL_LIGHT0);
  //oglsm.myglDisable(GL_COLOR_MATERIAL);
  inherited;

end;
function GDBObj3DFace.CalcInFrustum;
var i:Integer;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i].v[0] * PInWCS[0].x + frustum[i].v[1] * PInWCS[0].y + frustum[i].v[2] * PInWCS[0].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * PInWCS[1].x + frustum[i].v[1] * PInWCS[1].y + frustum[i].v[2] * PInWCS[1].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * PInWCS[2].x + frustum[i].v[1] * PInWCS[2].y + frustum[i].v[2] * PInWCS[2].z + frustum[i].v[3] < 0 )
      and(frustum[i].v[0] * PInWCS[3].x + frustum[i].v[1] * PInWCS[3].y + frustum[i].v[2] * PInWCS[3].z + frustum[i].v[3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
procedure GDBObj3DFace.RenderFeedback;
//var //pm:DMatrix4D;
    //tv:GDBvertex;
begin
           inherited;
           //pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(PInWCS[0],PInDCS[0]);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(PInWCS[1],PInDCS[1]);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(PInWCS[2],PInDCS[2]);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(PInWCS[3],PInDCS[3]);
end;

{function GDBObj3DFace.getsnap;

begin
     if onlygetsnapcount=1 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_point)<>0
            then
            begin
            osp.worldcoord:=P_insertInWCS;
            osp.dispcoord:=projpoint;
            osp.ostype:=os_point;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;}
function GDBObj3DFace.onmouse;
var
   subresult:TInBoundingVolume;
begin
  result:=false;
    subresult:=CalcOutBound4VInFrustum(PInWCS,mf);
    if subresult<>IRPartially then
                               if subresult=irempty then
                                                        exit
                                                    else
                                                        begin
                                                             result:=true;
                                                             exit;
                                                        end;
    if uzegeometry.CalcTrueInFrustum (PInwCS[0],PInwCS[1],mf)<>IREmpty
                                                                then
                                                                    begin
                                                                         result:=true;
                                                                         exit;
                                                                    end;
    if uzegeometry.CalcTrueInFrustum (PInwCS[1],PInwCS[2],mf)<>IREmpty
                                                                then
                                                                    begin
                                                                         result:=true;
                                                                         exit;
                                                                    end;
   if triangle then
                   begin
                          if uzegeometry.CalcTrueInFrustum (PInwCS[2],PInwCS[0],mf)<>IREmpty
                                                                                      then
                                                                                          begin
                                                                                               result:=true;
                                                                                               exit;
                                                                                          end;
                   end
               else
                   begin
                         if uzegeometry.CalcTrueInFrustum (PInwCS[2],PInwCS[3],mf)<>IREmpty
                                                                                     then
                                                                                         begin
                                                                                              result:=true;
                                                                                              exit;
                                                                                         end;
                         if uzegeometry.CalcTrueInFrustum (PInwCS[3],PInwCS[0],mf)<>IREmpty
                                                                                     then
                                                                                         begin
                                                                                              result:=true;
                                                                                              exit;
                                                                                         end;
                   end;
end;
function GDBObj3DFace.CalcTrueInFrustum;
var
    i:integer;
begin
      result:=CalcOutBound4VInFrustum(PInWCS,frustum);
      if result<>IRPartially then
                                 exit;
      i:=0;
      if uzegeometry.CalcPointTrueInFrustum (PInwCS[0],frustum)<>IREmpty
                                                                  then
                                                                      begin
                                                                           inc(i);
                                                                      end;
      if uzegeometry.CalcPointTrueInFrustum (PInwCS[1],frustum)<>IREmpty
                                                                  then
                                                                      begin
                                                                           inc(i);
                                                                      end;
      if uzegeometry.CalcPointTrueInFrustum (PInwCS[2],frustum)<>IREmpty
                                                                  then
                                                                      begin
                                                                           inc(i);
                                                                      end;
     if not triangle then
                     begin
                           if uzegeometry.CalcPointTrueInFrustum (PInwCS[3],frustum)<>IREmpty
                                                                                       then
                                                                                           begin
                                                                                                inc(i);
                                                                                           end;
                           if i=4 then
                                      begin
                                           result:=IRFully;
                                           exit;
                                      end;
                     end
                     else
                     begin
                          if i=3 then
                                      begin
                                           result:=IRFully;
                                           exit;
                                      end;

                     end;
     if uzegeometry.CalcTrueInFrustum (PInwCS[0],PInwCS[1],frustum)<>IREmpty
                                                                 then
                                                                     begin
                                                                          exit;
                                                                     end;
     if uzegeometry.CalcTrueInFrustum (PInwCS[1],PInwCS[2],frustum)<>IREmpty
                                                                 then
                                                                     begin
                                                                          exit;
                                                                     end;
    if triangle then
                    begin
                           if uzegeometry.CalcTrueInFrustum (PInwCS[2],PInwCS[0],frustum)<>IREmpty
                                                                                       then
                                                                                           begin
                                                                                                exit;
                                                                                           end;
                    end
                else
                    begin
                          if uzegeometry.CalcTrueInFrustum (PInwCS[2],PInwCS[3],frustum)<>IREmpty
                                                                                      then
                                                                                          begin
                                                                                               exit;
                                                                                          end;
                          if uzegeometry.CalcTrueInFrustum (PInwCS[3],PInwCS[0],frustum)<>IREmpty
                                                                                      then
                                                                                          begin
                                                                                               exit;
                                                                                          end;
                    end;
   result:=IRempty;

end;
procedure GDBObj3DFace.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:Integer;
begin
     vertexnumber:=pdesc^.vertexnum;
     pdesc.worldcoord:=PInWCS[vertexnumber];
     pdesc.dispcoord.x:=round(PInDCS[vertexnumber].x);
     pdesc.dispcoord.y:=round(PInDCS[vertexnumber].y);
end;
procedure GDBObj3DFace.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
    i:Integer;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
          pdesc.PDrawable:=nil;
          for i := 0 to 3 do
          begin
          pdesc.selected:=false;
          pdesc.vertexnum:=i;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=PInWCS[i];
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
          end;
end;

procedure GDBObj3DFace.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:Integer;
begin
     vertexnumber:=rtmod.point.vertexnum;
     PInOCS[vertexnumber]:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
end;

function GDBObj3DFace.Clone;
var tvo: PGDBObj3DFace;
begin
  Getmem(Pointer(tvo), sizeof(GDBObj3DFace));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, nulvertex);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PInOCS:=PInOCS;
  tvo^.PInWCS:=PInWCS;
  tvo^.PInDCS:=PInDCS;
  result := tvo;
end;
procedure GDBObj3DFace.rtsave;
begin
  pGDBObj3DFace(refp)^.PInOCS:=PInOCS;
end;
function Alloc3DFace:PGDBObj3DFace;
begin
  Getmem(pointer(result),sizeof(GDBObj3DFace));
end;
function AllocAndInit3DFace(owner:PGDBObjGenericWithSubordinated):PGDBObj3DFace;
begin
  result:=Alloc3DFace;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
class function GDBObj3DFace.CreateInstance:PGDBObj3DFace;
begin
  result:=AllocAndInit3DFace(nil);
end;
begin
  RegisterDXFEntity(GDB3DFaceID,'3DFACE','3DFace',@Alloc3DFace,@AllocAndInit3DFace);
end.
