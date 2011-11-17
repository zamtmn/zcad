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
unit GDBSolid;
{$INCLUDE def.inc}

interface
uses GDBWithLocalCS,UGDBOpenArrayOfPObjects,geometry,dxflow,UGDBLayerArray,gdbasetypes,UGDBSelectedObjArray,GDBSubordinated,GDB3d,gdbEntity,sysutils,UGDBOpenArrayOfByte,varman,varmandef,
gl,
GDBase,UGDBDescriptor,gdbobjectsconstdef{,oglwindowdef,dxflow},memman,OGLSpecFunc;
type
{Export+}
PGDBObjSolid=^GDBObjSolid;
GDBObjSolid=object(GDBObjWithLocalCS)
                 PInOCS:OutBound4V;(*'Coordinates OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 triangle:GDBBoolean;
                 n,p1,p2,p3:GDBVertex3S;
                 //ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure Format;virtual;
                 procedure createpoint;virtual;

                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                 procedure RenderFeedback;virtual;
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

                 //procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
           end;
{Export-}

implementation
uses log;
{procedure GDBObjSolid.TransformAt;
var i:GDBInteger;
begin
      for i:=0 to 3 do
      begin
           PInOCS[I]:=geometry.VectorTransform3D(PGDBObj3DFace(p)^.PInOCS[I],t_matrix^);
      end;
end;}
procedure GDBObjSolid.getoutbound;
var i:GDBInteger;
begin
     vp.BoundingBox.LBN:=PInWCS[0];
     vp.BoundingBox.RTF:=PInWCS[0];
      for i:=1 to 3 do
      begin
           concatBBandPoint(vp.BoundingBox,PInWCS[I]);
      end;
end;
procedure GDBObjSolid.format;
var i:GDBInteger;
begin
  calcObjMatrix;
  createpoint;
  normal:=normalizevertex(
                          vectordot(
                                    geometry.VertexSub(PInWCS[0],PInWCS[1])
                                    ,
                                    geometry.VertexSub(PInWCS[2],PInWCS[1])
                                   )
                         );
   if geometry.IsPointEqual(PInOCS[2],PInOCS[3])then
                                                    triangle:=true
                                                else
                                                    triangle:=false;
  calcbb;
end;
procedure GDBObjSolid.createpoint;
begin
  PInWCS[0]:=VectorTransform3D(PInOCS[0],objmatrix);
  PInWCS[1]:=VectorTransform3D(PInOCS[1],objmatrix);
  PInWCS[2]:=VectorTransform3D(PInOCS[2],objmatrix);
  PInWCS[3]:=VectorTransform3D(PInOCS[3],objmatrix);
end;

function GDBObjSolid.GetObjTypeName;
begin
     result:=ObjN_GDBObjSolid;
end;
constructor GDBObjSolid.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDB3DfaceID;
  PInOCS[0]:= p;
end;
constructor GDBObjSolid.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  vp.ID := GDB3DfaceID;
  PInOCS[1]:= NulVertex;
end;

procedure GDBObjSolid.LoadFromDXF;
var s: GDBString;
  byt: GDBInteger;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu) then
       if not dxfvertexload(f,10,byt,PInOCS[0]) then
          if not dxfvertexload(f,11,byt,PInOCS[1]) then
          if not dxfvertexload(f,12,byt,PInOCS[2]) then
          if not dxfvertexload(f,13,byt,PInOCS[3]) then
          s := f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
end;
procedure GDBObjSolid.SaveToDXF;
begin
  SaveToDXFObjPrefix(handle,outhandle,'SOLID','AcDbTrace');
  dxfvertexout(outhandle,10,PInOCS[0]);
  dxfvertexout(outhandle,11,PInOCS[1]);
  dxfvertexout(outhandle,12,PInOCS[2]);
  dxfvertexout(outhandle,13,PInOCS[3]);
  SaveToDXFObjPostfix(outhandle)
end;

procedure GDBObjSolid.DrawGeometry;
var
   p:GDBvertex4F;
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
       oglsm.myglbegin(GL_LINES);
       oglsm.myglNormal3dV(@normal);
       oglsm.myglVertex3dV(@PInwCS[0]);
       oglsm.myglVertex3dV(@PInwCS[1]);
       oglsm.myglVertex3dV(@PInwCS[1]);
       oglsm.myglVertex3dV(@PInwCS[2]);
       oglsm.myglVertex3dV(@PInwCS[2]);
       oglsm.myglVertex3dV(@PInwCS[0]);
       oglsm.myglend;
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
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglend;
  oglsm.myglbegin(GL_LINES);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglend;
  end;

  //oglsm.myglDisable(GL_LIGHTING);
  //oglsm.myglDisable(GL_LIGHT0);
  //oglsm.myglDisable(GL_COLOR_MATERIAL);
  inherited;

end;
function GDBObjSolid.CalcInFrustum;
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
procedure GDBObjSolid.RenderFeedback;
var pm:DMatrix4D;
    tv:GDBvertex;
begin
           inherited;
           pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           gdb.GetCurrentDWG^.myGluProject2(PInWCS[0],PInDCS[0]);
           gdb.GetCurrentDWG^.myGluProject2(PInWCS[1],PInDCS[1]);
           gdb.GetCurrentDWG^.myGluProject2(PInWCS[2],PInDCS[2]);
           gdb.GetCurrentDWG^.myGluProject2(PInWCS[3],PInDCS[3]);
end;

{function GDBObjSolid.getsnap;

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
function GDBObjSolid.onmouse;
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
function GDBObjSolid.CalcTrueInFrustum;
var d1:GDBDouble;
    i:integer;
begin
      result:=CalcOutBound4VInFrustum(PInWCS,frustum);
end;
procedure GDBObjSolid.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:GDBInteger;
begin
     vertexnumber:=abs(pdesc^.pointtype-os_polymin);
     pdesc.worldcoord:=PInWCS[vertexnumber];
     pdesc.dispcoord.x:=round(PInDCS[vertexnumber].x);
     pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-PInDCS[vertexnumber].y);

end;

procedure GDBObjSolid.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
    i:GDBInteger;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{92DDADAD-909D-4938-A1F9-3BD78FBB2B70}',{$ENDIF}1);
          for i := 0 to 3 do
          begin
          pdesc.selected:=false;
          pdesc.pointtype:=os_polymin-i;
          pdesc.worldcoord:=PInWCS[i];
          pdesc.dispcoord.x:=round(PInDCS[i].x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-PInDCS[i].y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
          end;
end;

procedure GDBObjSolid.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:GDBInteger;
    tv,wwc:gdbvertex;
    M: DMatrix4D;
begin
     vertexnumber:=abs(rtmod.point.pointtype-os_polymin);

     m:=self.ObjMatrix;

     {m[3][0]:=0;
     m[3][1]:=0;
     m[3][2]:=0;}

     geometry.MatrixInvert(m);


     tv:=rtmod.dist;
     wwc:=rtmod.point.worldcoord;

     wwc:=VertexAdd(wwc,tv);

     //tv:=geometry.VectorTransform3D(tv,m);
     wwc:=geometry.VectorTransform3D(wwc,m);


     PInOCS[vertexnumber]:=wwc{VertexAdd(wwc,tv)};
     //PInOCS[vertexnumber].z:=0;

{
vertexnumber:=abs(rtmod.point.pointtype-os_polymin);
tv:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
geometry.VectorTransform3D(tv,self.ObjMatrix);
PGDBArrayVertex2D(Vertex2D_in_OCS_Array.parray)^[vertexnumber].x:=tv.x;
PGDBArrayVertex2D(Vertex2D_in_OCS_Array.parray)^[vertexnumber].y:=tv.y;
}
end;

function GDBObjSolid.Clone;
var tvo: PGDBObjSolid;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{1C6F0445-7339-449A-BDEB-7D38A46FD910}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjSolid));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, nulvertex);
  tvo^.Local:=local;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PInOCS:=PInOCS;
  tvo^.PInWCS:=PInWCS;
  tvo^.PInDCS:=PInDCS;
  result := tvo;
end;
procedure GDBObjSolid.rtsave;
begin
  pGDBObjSolid(refp)^.PInOCS:=PInOCS;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBSolid.initialization');{$ENDIF}
end.
