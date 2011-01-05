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

unit GDBWithLocalCS;
{$INCLUDE def.inc}

interface
uses OGLSpecFunc,gdbasetypes,gdbEntity,UGDBOutbound2DIArray,UGDBOpenArrayOfByte,varman,varmandef,GDBWithMatrix,
gl,
GDBase,{gDBDescriptor,gdbobjectsconstdef,oglwindowdef,}geometry,dxflow,sysutils,memman,GDBSubordinated,UGDBLayerArray{,GDBGenericSubEntry};
type
//pprojoutbound:{-}PGDBOOutbound2DIArray{/GDBPointer/};
{EXPORT+}
PGDBObj2dprop=^GDBObj2dprop;
GDBObj2dprop=record
                   OX:GDBvertex;(*'X Axis'*)(*saved_to_shd*)
                   OY:GDBvertex;(*'Y Axis'*)(*saved_to_shd*)
                   OZ:GDBvertex;(*'Z Axis'*)(*saved_to_shd*)
                   P_insert:GDBvertex;(*'Insertion point OCS'*)(*saved_to_shd*)
             end;
PGDBObjWithLocalCS=^GDBObjWithLocalCS;
GDBObjWithLocalCS=object(GDBObjWithMatrix)
               Local:GDBObj2dprop;(*'Object orientation'*)(*saved_to_shd*)
               P_insert_in_WCS:GDBvertex;(*'Insertion point WCS'*)(*saved_to_shd*)
               ProjP_insert:GDBvertex;(*'Insertion point DCS'*)
               PProjOutBound:PGDBOOutbound2DIArray;(*'Bounding box DCS'*)
               lod:GDBByte;(*'Level of detail'*)
               constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
               constructor initnul(owner:PGDBObjGenericWithSubordinated);
               destructor done;virtual;
               procedure SaveToDXFObjPostfix(outhandle:{GDBInteger}GDBOpenArrayOfByte);
               function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTUnit):GDBBoolean;

               procedure Format;virtual;
               procedure CalcObjMatrix;virtual;
               function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;
               procedure transform(const t_matrix:DMatrix4D);virtual;
               procedure Renderfeedback;virtual;
               function GetCenterPoint:GDBVertex;virtual;
               procedure createfield;virtual;

               procedure rtsave(refp:GDBPointer);virtual;
               procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
               procedure higlight;virtual;
         end;
{EXPORT-}
implementation
uses UGDBDescriptor,log;
procedure GDBObjWithLocalCS.higlight;
begin
  glcolor3ubv(@palette[sysvar.SYS.SYS_SystmGeometryColor^]);
  oglsm.myglbegin(GL_lines);
  glVertex2d(ProjP_insert.x-10,ProjP_insert.y);
  glVertex2d(ProjP_insert.x+10,ProjP_insert.y);
  glVertex2d(ProjP_insert.x,ProjP_insert.y-10);
  glVertex2d(ProjP_insert.x,ProjP_insert.y+10);
  oglsm.myglend;
  if PProjOutBound<>nil then PProjOutBound.DrawGeometry;

end;
procedure GDBObjWithLocalCS.TransformAt;
begin
    objmatrix:=geometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);


     //Local.ox:=PGDBVertex(@objmatrix[0])^;
     //Local.oy:=PGDBVertex(@objmatrix[1])^;
     Local.oz:=PGDBVertex(@objmatrix[2])^;

     Local.p_insert:=PGDBVertex(@objmatrix[3])^;
end;
procedure GDBObjWithLocalCS.rtsave;
//var m:DMatrix4D;
begin
  {m:=pgdbobjtext(refp)^.bp.owner.getmatrix^;
  MatrixInvert(m);
  Local.p_insert:=VectorTransform3D(Local.p_insert,m);}
  PGDBObjWithLocalCS(refp)^.Local.p_insert := Local.p_insert;
  PGDBObjWithLocalCS(refp)^.calcobjmatrix;
  //PGDBObjWithLocalCS(refp)^.format;
  //pgdbobjtext(refp)^.getoutbound;
end;
procedure GDBObjWithLocalCS.createfield;
begin
     inherited;
     Local.P_insert:=nulvertex;
     P_insert_in_WCS:=nulvertex;
     ProjP_insert:=nulvertex;
     PProjOutBound:=nil;
     lod:=0;
end;
function GDBObjWithLocalCS.GetCenterPoint;
begin
     result:=P_insert_in_WCS;
end;
procedure GDBObjWithLocalCS.Renderfeedback;
//var pm:DMatrix4D;
//    tv:GDBvertex;
begin
           inherited;
           gdb.GetCurrentDWG^.myGluProject2(P_insert_in_WCS,ProjP_insert);
           if pprojoutbound<>nil then pprojoutbound^.clear;
end;
constructor GDBObjWithLocalCS.initnul;
begin
  ObjMatrix:=OneMatrix;
  Local.ox:=XWCS;
  Local.oy:=YWCS;
  Local.oz:=ZWCS;
  local.p_insert:=nulvertex;
  inherited initnul(owner);
  pprojoutbound:=nil;
end;
constructor GDBObjWithLocalCS.init;
begin
  inherited init(own,layeraddres,LW);
  if bp.owner<>nil then
  begin
  Local.ox:={wx^}PGDBVertex(@bp.owner^.GetMatrix^[0])^;
  Local.oy:={wy^}PGDBVertex(@bp.owner^.GetMatrix^[1])^;
  Local.oz:={wz^}PGDBVertex(@bp.owner^.GetMatrix^[2])^;
  end
  else
  begin
  Local.ox:=XWCS;
  Local.oy:=YWCS;
  Local.oz:=ZWCS;
  end;

  pprojoutbound:=nil;
  //CalcObjMatrix;
end;
procedure GDBObjWithLocalCS.Format;
begin
     CalcObjMatrix;
end;
function GDBObjWithLocalCS.CalcObjMatrixWithoutOwner;
var rotmatr,dispmatr:DMatrix4D;
begin
     //Local.oz:=NormalizeVertex(Local.oz);
     if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=CrossVertex(ZWCS,Local.oz);
     Local.ox:=NormalizeVertex(Local.ox);
     Local.oy:=CrossVertex(Local.oz,Local.ox);
     Local.oy:=NormalizeVertex(Local.oy);
     Local.oz:=NormalizeVertex(Local.oz);

     rotmatr:=onematrix;
     PGDBVertex(@rotmatr[0])^:=Local.ox;
     PGDBVertex(@rotmatr[1])^:=Local.oy;
     PGDBVertex(@rotmatr[2])^:=Local.oz;

     dispmatr:=onematrix;
     PGDBVertex(@dispmatr[3])^:=Local.p_insert;

     result:=MatrixMultiply(dispmatr,rotmatr);
end;
procedure GDBObjWithLocalCS.CalcObjMatrix;
//var rotmatr,dispmatr:DMatrix4D;
begin
     (*if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=CrossVertex(ZWCS,Local.oz);
     {Local.ox.x:=1;
     Local.ox.y:=0;
     Local.ox.z:=0;}

     Local.ox:=NormalizeVertex(Local.ox);
     Local.oy:=CrossVertex(Local.oz,Local.ox);
     Local.oy:=NormalizeVertex(Local.oy);
     Local.oz:=NormalizeVertex(Local.oz);

     rotmatr:=onematrix;
     PGDBVertex(@rotmatr[0])^:=Local.ox;
     PGDBVertex(@rotmatr[1])^:=Local.oy;
     PGDBVertex(@rotmatr[2])^:=Local.oz;

     dispmatr:=onematrix;
     PGDBVertex(@dispmatr[3])^:=Local.p_insert;

     objmatrix:=MatrixMultiply(dispmatr,rotmatr);*)
     objmatrix:=MatrixMultiply({objmatrix}CalcObjMatrixWithoutOwner,bp.owner^.GetMatrix^);

     P_insert_in_WCS:={PGDBVertex(@dispmatr[3])^;//}VectorTransform3D(nulvertex,objmatrix);
end;
procedure GDBObjWithLocalCS.transform;
var tv,tv2:GDBVertex4D;
begin

  tv2:=PGDBVertex4D(@t_matrix[3])^;
  PGDBVertex4D(@t_matrix[3])^:=NulVertex4D;

  tv:=NulVertex4D;
  PGDBVertex(@tv)^:=Local.ox;
  tv:=VectorTransform(tv,t_matrix);
  Local.ox:=PGDBVertex(@tv)^;

  tv:=NulVertex4D;
  PGDBVertex(@tv)^:=Local.oy;
  tv:=VectorTransform(tv,t_matrix);
  Local.oy:=PGDBVertex(@tv)^;

  tv:=NulVertex4D;
  PGDBVertex(@tv)^:=Local.oz;
  tv:=VectorTransform(tv,t_matrix);
  Local.oz:=PGDBVertex(@tv)^;

  PGDBVertex4D(@t_matrix[3])^:=tv2;

  tv:=NulVertex4D;
  PGDBVertex(@tv)^:=Local.p_insert;
  tv:=VectorTransform(tv,t_matrix);
  Local.p_insert:=PGDBVertex(@tv)^;
end;
procedure GDBObjWithLocalCS.SaveToDXFObjPostfix;
begin
  if (abs(local.oz.x)>eps)or(abs(local.oz.y)>eps)or(abs(local.oz.z-1)>eps) then
  begin
  dxfvertexout(outhandle,210,local.oz);
  {WriteString_EOL(outhandle, '210');
  WriteString_EOL(outhandle, floattostr(local.oz.x));
  WriteString_EOL(outhandle, '220');
  WriteString_EOL(outhandle, floattostr(local.oz.y));
  WriteString_EOL(outhandle, '230');
  WriteString_EOL(outhandle, floattostr(local.oz.z));}
  end;
end;
function GDBObjWithLocalCS.LoadFromDXFObjShared;
//var s:GDBString;
begin
     result:=inherited LoadFromDXFObjShared(f,dxfcod,ptu);
     if not result then result:=dxfvertexload(f,210,dxfcod,Local.oz);
end;
destructor GDBObjWithLocalCS.done;
begin
          if assigned(PProjoutbound) then
                            begin
                            PProjoutbound^.{FreeAnd}Done;
                            GDBFreeMem(GDBPointer(PProjoutbound));
                            end;
          inherited done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBWithLocalCS.initialization');{$ENDIF}
end.
