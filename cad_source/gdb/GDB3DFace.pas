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
unit GDB3DFace;
{$INCLUDE def.inc}

interface
uses ugdbdrawingdef,GDBCamera,UGDBOpenArrayOfPObjects,geometry,dxflow,UGDBLayerArray,gdbasetypes,UGDBSelectedObjArray,GDBSubordinated,GDB3d,gdbEntity,sysutils,UGDBOpenArrayOfByte,varman,varmandef,
ugdbltypearray,
GDBase,gdbobjectsconstdef{,oglwindowdef,dxflow},memman,OGLSpecFunc;
type
{Export+}
PGDBObj3DFace=^GDBObj3DFace;
GDBObj3DFace=object(GDBObj3d)
                 PInOCS:OutBound4V;(*'Coordinates OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 triangle:GDBBoolean;
                 n,p1,p2,p3:GDBVertex3S;
                 //ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;
                 procedure FormatEntity(const drawing:TDrawingDef);virtual;

                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;
                 //function getsnap(var osp:os_record):GDBBoolean;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure getoutbound;virtual;

                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
           end;
{Export-}

implementation
uses log;
procedure GDBObj3DFace.TransformAt;
var i:GDBInteger;
begin
      for i:=0 to 3 do
      begin
           PInOCS[I]:=geometry.VectorTransform3D(PGDBObj3DFace(p)^.PInOCS[I],t_matrix^);
      end;
end;
procedure GDBObj3DFace.transform(const t_matrix:DMatrix4D);
var i:GDBInteger;
begin
      for i:=0 to 3 do
      begin
           PInOCS[I]:=geometry.VectorTransform3D(PInOCS[I],t_matrix);
      end;
end;
procedure GDBObj3DFace.getoutbound;
var i:GDBInteger;
begin
     vp.BoundingBox.LBN:=PInWCS[0];
     vp.BoundingBox.RTF:=PInWCS[0];
      for i:=1 to 3 do
      begin
           concatBBandPoint(vp.BoundingBox,PInWCS[I]);
      end;
end;
procedure GDBObj3DFace.FormatEntity(const drawing:TDrawingDef);
var i:GDBInteger;
begin
      for i:=0 to 3 do
      begin
           PInWCS[I]:=VectorTransform3D(PInOCS[I],{CurrentCS}bp.ListPos.owner^.GetMatrix^);
      end;
      normal:=normalizevertex(
                              vectordot(
                                        geometry.VertexSub(PInWCS[0],PInWCS[1])
                                        ,
                                        geometry.VertexSub(PInWCS[2],PInWCS[1])
                                       )
                             );
     {if geometry.IsVectorNul(normal) then
                                         normal:=normal;}
       if geometry.IsPointEqual(PInOCS[2],PInOCS[3])then
                                                        triangle:=true
                                                    else
                                                        triangle:=false;
  calcbb;
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

end;
function GDBObj3DFace.GetObjTypeName;
begin
     result:=ObjN_GDBObj3DFace;
end;
constructor GDBObj3DFace.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDB3DfaceID;
  PInOCS[0]:= p;
end;
constructor GDBObj3DFace.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  vp.ID := GDB3DfaceID;
  PInOCS[1]:= NulVertex;
end;

procedure GDBObj3DFace.LoadFromDXF;
var //s: GDBString;
  byt: GDBInteger;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,PInOCS[0]) then
          if not dxfvertexload(f,11,byt,PInOCS[1]) then
          if not dxfvertexload(f,12,byt,PInOCS[2]) then
          if not dxfvertexload(f,13,byt,PInOCS[3]) then
          {s := }f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
end;
procedure GDBObj3DFace.SaveToDXF;
begin
  SaveToDXFObjPrefix(handle,outhandle,'3DFACE','AcDbFace');
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
       oglsm.myglbegin(GL_TRIANGLES);
       oglsm.myglNormal3dV(@normal);
       oglsm.myglVertex3dV(@PInwCS[0]);
       oglsm.myglVertex3dV(@PInwCS[1]);
       oglsm.myglVertex3dV(@PInwCS[2]);
       (*
       glNormal3fV(@n);
       {my}glVertex3fV(@p1);
       {my}glVertex3fV(@p2);
       {my}glVertex3fV(@p3);
        *)
       oglsm.myglend;
  end
     else
  begin
  oglsm.myglbegin(GL_QUADS);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglend;
  end;

  //oglsm.myglDisable(GL_LIGHTING);
  //oglsm.myglDisable(GL_LIGHT0);
  //oglsm.myglDisable(GL_COLOR_MATERIAL);
  inherited;

end;
function GDBObj3DFace.CalcInFrustum;
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i][0] * PInWCS[0].x + frustum[i][1] * PInWCS[0].y + frustum[i][2] * PInWCS[0].z + frustum[i][3] < 0 )
      and(frustum[i][0] * PInWCS[1].x + frustum[i][1] * PInWCS[1].y + frustum[i][2] * PInWCS[1].z + frustum[i][3] < 0 )
      and(frustum[i][0] * PInWCS[2].x + frustum[i][1] * PInWCS[2].y + frustum[i][2] * PInWCS[2].z + frustum[i][3] < 0 )
      and(frustum[i][0] * PInWCS[3].x + frustum[i][1] * PInWCS[3].y + frustum[i][2] * PInWCS[3].z + frustum[i][3] < 0 )
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
   subresult:TINRect;
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
    result:=true;
end;
function GDBObj3DFace.CalcTrueInFrustum;
//var d1:GDBDouble;
    //i:integer;
begin
      result:=CalcOutBound4VInFrustum(PInWCS,frustum);
end;
procedure GDBObj3DFace.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:GDBInteger;
begin
     vertexnumber:=abs(pdesc^.pointtype-os_polymin);
     pdesc.worldcoord:=PInWCS[vertexnumber];
     pdesc.dispcoord.x:=round(PInDCS[vertexnumber].x);
     pdesc.dispcoord.y:=round(PInDCS[vertexnumber].y);
end;
procedure GDBObj3DFace.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
    i:GDBInteger;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{92DDADAD-909D-4938-A1F9-3BD78FBB2B70}',{$ENDIF}1);
          pdesc.pobject:=nil;
          for i := 0 to 3 do
          begin
          pdesc.selected:=false;
          pdesc.pointtype:=os_polymin-i;
          pdesc.worldcoord:=PInWCS[i];
          {pdesc.dispcoord.x:=round(PInDCS[i].x);
          pdesc.dispcoord.y:=round(PInDCS[i].y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
          end;
end;

procedure GDBObj3DFace.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:GDBInteger;
begin
     vertexnumber:=abs(rtmod.point.pointtype-os_polymin);
     PInOCS[vertexnumber]:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
end;

function GDBObj3DFace.Clone;
var tvo: PGDBObj3DFace;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{1C6F0445-7339-449A-BDEB-7D38A46FD910}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObj3DFace));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, nulvertex);
  CopyVPto(tvo^);
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
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDB3DFace.initialization');{$ENDIF}
end.
