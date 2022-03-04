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
unit uzeentsolid;
{$INCLUDE zcadconfig.inc}

interface
uses
    uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,uzeentwithlocalcs,
    uzegeometry,uzeffdxfsupport,uzestyleslayers,
    UGDBSelectedObjArray,uzeentsubordinated,uzeentity,sysutils,uzctnrVectorBytes,
    uzegeometrytypes,uzbtypes,uzeconsts,uzctnrvectorpgdbaseobjects;
type
{Export+}
PGDBObjSolid=^GDBObjSolid;
{REGISTEROBJECTTYPE GDBObjSolid}
GDBObjSolid= object(GDBObjWithLocalCS)
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
                 procedure createpoint;virtual;

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

                 function CreateInstance:PGDBObjSolid;static;
                 function GetObjType:TObjID;virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;
           end;
{Export-}

implementation
//uses log;
procedure GDBObjSolid.TransformAt;
begin
  PInOCS[0]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[0],t_matrix^);
  PInOCS[1]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[1],t_matrix^);
  PInOCS[2]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[2],t_matrix^);
  PInOCS[3]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[3],t_matrix^);
end;
procedure GDBObjSolid.transform;
begin
  PInOCS[0]:=uzegeometry.VectorTransform3D(PInOCS[0],t_matrix);
  PInOCS[1]:=uzegeometry.VectorTransform3D(PInOCS[1],t_matrix);
  PInOCS[2]:=uzegeometry.VectorTransform3D(PInOCS[2],t_matrix);
  PInOCS[3]:=uzegeometry.VectorTransform3D(PInOCS[3],t_matrix);
end;
procedure GDBObjSolid.getoutbound;
var i:Integer;
begin
     vp.BoundingBox.LBN:=PInWCS[0];
     vp.BoundingBox.RTF:=PInWCS[0];
      for i:=1 to 3 do
      begin
           concatBBandPoint(vp.BoundingBox,PInWCS[I]);
      end;
end;
procedure GDBObjSolid.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
//var i:Integer;
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  calcObjMatrix;
  createpoint;
  normal:=normalizevertex(
                          vectordot(
                                    uzegeometry.VertexSub(PInWCS[0],PInWCS[1])
                                    ,
                                    uzegeometry.VertexSub(PInWCS[2],PInWCS[1])
                                   )
                         );
   if uzegeometry.IsPointEqual(PInOCS[2],PInOCS[3])then
                                                    triangle:=true
                                                else
                                                    triangle:=false;
  calcbb(dc);
   if assigned(EntExtensions)then
     EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
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
  //vp.ID := GDBSolidID;
  PInOCS[0]:= p;
end;
constructor GDBObjSolid.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  //vp.ID := GDBSolidID;
  PInOCS[1]:= NulVertex;
end;
function GDBObjSolid.GetObjType;
begin
     result:=GDBSolidID;
end;
procedure GDBObjSolid.LoadFromDXF;
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
procedure GDBObjSolid.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'SOLID','AcDbTrace',IODXFContext);
  dxfvertexout(outhandle,10,PInOCS[0]);
  dxfvertexout(outhandle,11,PInOCS[1]);
  dxfvertexout(outhandle,12,PInOCS[2]);
  dxfvertexout(outhandle,13,PInOCS[3]);
  SaveToDXFObjPostfix(outhandle)
end;

procedure GDBObjSolid.DrawGeometry;
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
       //oglsm.myglbegin(GL_TRIANGLES);
       //oglsm.myglNormal3dV(@normal);
       //oglsm.myglVertex3dV(@PInwCS[0]);
       //oglsm.myglVertex3dV(@PInwCS[1]);
       //oglsm.myglVertex3dV(@PInwCS[2]);
       dc.drawer.DrawTriangle3DInModelSpace(normal,PInwCS[0],PInwCS[1],PInwCS[2],dc.DrawingContext.matrixs);
       //oglsm.myglbegin(GL_LINES);
       //oglsm.myglNormal3dV(@normal);
       //oglsm.myglVertex3dV(@PInwCS[0]);
       //oglsm.myglVertex3dV(@PInwCS[1]);
       //oglsm.myglVertex3dV(@PInwCS[1]);
       //oglsm.myglVertex3dV(@PInwCS[2]);
       //oglsm.myglVertex3dV(@PInwCS[2]);
       //oglsm.myglVertex3dV(@PInwCS[0]);
       //oglsm.myglend;
       (*
       glNormal3fV(@n);
       {my}glVertex3fV(@p1);
       {my}glVertex3fV(@p2);
       {my}glVertex3fV(@p3);
        *)
       //oglsm.myglend;
  end
     else
  begin
  {oglsm.myglbegin(GL_QUADS);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglend;}
  dc.drawer.DrawQuad3DInModelSpace(normal,PInwCS[0],PInwCS[1],PInwCS[2],PInwCS[3],dc.DrawingContext.matrixs);
  {oglsm.myglbegin(GL_LINES);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[1]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[3]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[2]);
  oglsm.myglVertex3dV(@PInwCS[0]);
  oglsm.myglend;}
  end;

  //oglsm.myglDisable(GL_LIGHTING);
  //oglsm.myglDisable(GL_LIGHT0);
  //oglsm.myglDisable(GL_COLOR_MATERIAL);
  inherited;

end;
function GDBObjSolid.CalcInFrustum;
var i:Integer;
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
//var //pm:DMatrix4D;
    //tv:GDBvertex;
begin
           inherited;
           //pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           ProjectProc(PInWCS[0],PInDCS[0]);
           ProjectProc(PInWCS[1],PInDCS[1]);
           ProjectProc(PInWCS[2],PInDCS[2]);
           ProjectProc(PInWCS[3],PInDCS[3]);
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
    result:=true;
end;
function GDBObjSolid.CalcTrueInFrustum;
//var //d1:Double;
    //i:integer;
begin
      result:=CalcOutBound4VInFrustum(PInWCS,frustum);
end;
procedure GDBObjSolid.remaponecontrolpoint(pdesc:pcontrolpointdesc);
var vertexnumber:Integer;
begin
     vertexnumber:=abs(pdesc^.pointtype-os_polymin);
     pdesc.worldcoord:=PInWCS[vertexnumber];
     pdesc.dispcoord.x:=round(PInDCS[vertexnumber].x);
     pdesc.dispcoord.y:=round(PInDCS[vertexnumber].y);

end;

procedure GDBObjSolid.addcontrolpoints(tdesc:Pointer);
var pdesc:controlpointdesc;
    i:Integer;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
          pdesc.selected:=false;
          pdesc.pobject:=nil;

          for i := 0 to 3 do
          begin
          pdesc.pointtype:=os_polymin-i;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=PInWCS[i];
          {pdesc.dispcoord.x:=round(PInDCS[i].x);
          pdesc.dispcoord.y:=round(PInDCS[i].y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
          end;
end;

procedure GDBObjSolid.rtmodifyonepoint(const rtmod:TRTModifyData);
var vertexnumber:Integer;
    tv,wwc:gdbvertex;
    M: DMatrix4D;
begin
     vertexnumber:=abs(rtmod.point.pointtype-os_polymin);

     m:=self.ObjMatrix;

     {m[3][0]:=0;
     m[3][1]:=0;
     m[3][2]:=0;}

     uzegeometry.MatrixInvert(m);


     tv:=rtmod.dist;
     wwc:=rtmod.point.worldcoord;

     wwc:=VertexAdd(wwc,tv);

     //tv:=uzegeometry.VectorTransform3D(tv,m);
     wwc:=uzegeometry.VectorTransform3D(wwc,m);


     PInOCS[vertexnumber]:=wwc{VertexAdd(wwc,tv)};
     //PInOCS[vertexnumber].z:=0;

{
vertexnumber:=abs(rtmod.point.pointtype-os_polymin);
tv:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
uzegeometry.VectorTransform3D(tv,self.ObjMatrix);
PGDBArrayVertex2D(Vertex2D_in_OCS_Array.parray)^[vertexnumber].x:=tv.x;
PGDBArrayVertex2D(Vertex2D_in_OCS_Array.parray)^[vertexnumber].y:=tv.y;
}
end;

function GDBObjSolid.Clone;
var tvo: PGDBObjSolid;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjSolid));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, nulvertex);
  tvo^.Local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
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
function AllocSolid:PGDBObjSolid;
begin
  Getmem(result,sizeof(GDBObjSolid));
end;
function AllocAndInitSolid(owner:PGDBObjGenericWithSubordinated):PGDBObjSolid;
begin
  result:=AllocSolid;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
procedure SetSolidGeomProps(PSolid:PGDBObjSolid;args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  PSolid^.PInOCS[0]:=CreateVertexFromArray(counter,args);
  PSolid^.PInOCS[1]:=CreateVertexFromArray(counter,args);
  PSolid^.PInOCS[2]:=CreateVertexFromArray(counter,args);
  if counter>=high(args) then
                             PSolid^.PInOCS[3]:=PSolid^.PInOCS[2]
                         else
                             PSolid^.PInOCS[3]:=CreateVertexFromArray(counter,args)
end;
function AllocAndCreateSolid(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjSolid;
begin
  result:=AllocAndInitSolid(owner);
  SetSolidGeomProps(result,args);
end;
function GDBObjSolid.CreateInstance:PGDBObjSolid;
begin
  result:=AllocAndInitSolid(nil);
end;
begin
  RegisterDXFEntity(GDBSolidID,'SOLID','Solid',@AllocSolid,@AllocAndInitSolid,@SetSolidGeomProps,@AllocAndCreateSolid);
end.
