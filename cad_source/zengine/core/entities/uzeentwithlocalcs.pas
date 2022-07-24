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

unit uzeentwithlocalcs;
{$INCLUDE zengineconfig.inc}

interface
uses uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzeentity,
     uzegeometrytypes,UGDBOutbound2DIArray,uzctnrVectorBytes,uzeentwithmatrix,uzbtypes,
     uzegeometry,uzeffdxfsupport,sysutils,uzeentsubordinated,uzestyleslayers;
type
//pprojoutbound:{-}PGDBOOutbound2DIArray{/Pointer/};
{EXPORT+}
PGDBObj2dprop=^GDBObj2dprop;
{REGISTERRECORDTYPE GDBObj2dprop}
GDBObj2dprop=record
                   Basis:GDBBasis;(*'Basis'*)(*saved_to_shd*)
                   P_insert:GDBCoordinates3D;(*'Insertion point OCS'*)(*saved_to_shd*)
             end;
PGDBObjWithLocalCS=^GDBObjWithLocalCS;
{REGISTEROBJECTTYPE GDBObjWithLocalCS}
GDBObjWithLocalCS= object(GDBObjWithMatrix)
               Local:GDBObj2dprop;(*'Object orientation'*)(*saved_to_shd*)

               //**получить на чтение координаты в мировой системе координат
               P_insert_in_WCS:GDBvertex;(*'Insertion point WCS'*)(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
               ProjP_insert:GDBvertex;(*'Insertion point DCS'*)(*oi_readonly*)(*hidden_in_objinsp*)
               PProjOutBound:PGDBOOutbound2DIArray;(*'Bounding box DCS'*)(*oi_readonly*)(*hidden_in_objinsp*)
               lod:Byte;(*'Level of detail'*)(*oi_readonly*)(*hidden_in_objinsp*)
               constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt);
               constructor initnul(owner:PGDBObjGenericWithSubordinated);
               destructor done;virtual;
               procedure SaveToDXFObjPostfix(var outhandle:{Integer}TZctnrVectorBytes);{todo: проверить использование, выкинуть нах}
               function LoadFromDXFObjShared(var f:TZctnrVectorBytes;dxfcod:Integer;ptu:PExtensionData;var drawing:TDrawingDef):Boolean;

               procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
               procedure CalcObjMatrix;virtual;
               function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;
               procedure transform(const t_matrix:DMatrix4D);virtual;
               procedure Renderfeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
               function GetCenterPoint:GDBVertex;virtual;
               procedure createfield;virtual;

               procedure rtsave(refp:Pointer);virtual;
               procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
               procedure higlight(var DC:TDrawContext);virtual;
               procedure ReCalcFromObjMatrix;virtual;
               function IsHaveLCS:Boolean;virtual;
               function CanSimplyDrawInOCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;inline;
         end;
{EXPORT-}
implementation
//uses log;
function GDBObjWithLocalCS.CanSimplyDrawInOCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;
var
   templod:Double;
begin
     if dc.maxdetail then
                         exit(true);
  templod:=sqrt(objmatrix[0].v[0]*objmatrix[0].v[0]+objmatrix[1].v[1]*objmatrix[1].v[1]+objmatrix[2].v[2]*objmatrix[2].v[2]);
  templod:=(templod*ParamSize)/(dc.DrawingContext.zoom);
  if templod>TargetSize then
                            exit(true)
                        else
                            exit(false);
end;
function GDBObjWithLocalCS.IsHaveLCS:Boolean;
begin
     result:=true;
end;
procedure GDBObjWithLocalCS.ReCalcFromObjMatrix;
//var
    //ox:gdbvertex;
begin
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;
     Local.basis.oz:=PGDBVertex(@objmatrix[2])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     {scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x;
     scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;

     if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.oz);
     normalizevertex(ox);
     rotate:=uzegeometry.scalardot(Local.ox,ox);
     rotate:=arccos(rotate)*180/pi;
     if local.OX.y<-eps then rotate:=360-rotate;}
end;

procedure GDBObjWithLocalCS.higlight;
begin
  //oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^].RGB);
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
  {oglsm.myglbegin(GL_lines);
  oglsm.myglVertex2d(ProjP_insert.x-10,ProjP_insert.y);
  oglsm.myglVertex2d(ProjP_insert.x+10,ProjP_insert.y);
  oglsm.myglVertex2d(ProjP_insert.x,ProjP_insert.y-10);
  oglsm.myglVertex2d(ProjP_insert.x,ProjP_insert.y+10);
  oglsm.myglend;}
  dc.drawer.DrawLine2DInDCS(ProjP_insert.x-10,ProjP_insert.y,ProjP_insert.x+10,ProjP_insert.y);
  dc.drawer.DrawLine2DInDCS(ProjP_insert.x,ProjP_insert.y-10,ProjP_insert.x,ProjP_insert.y+10);
  if PProjOutBound<>nil then PProjOutBound.DrawGeometry(dc);

end;
procedure GDBObjWithLocalCS.TransformAt;
begin
    objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);

     {Local.oz:=PGDBVertex(@objmatrix[2])^;

     Local.p_insert:=PGDBVertex(@objmatrix[3])^;}ReCalcFromObjMatrix;
end;
procedure GDBObjWithLocalCS.rtsave;
//var m:DMatrix4D;
begin
  {m:=pgdbobjtext(refp)^.bp.owner.getmatrix^;
  MatrixInvert(m);
  Local.p_insert:=VectorTransform3D(Local.p_insert,m);}
  PGDBObjWithLocalCS(refp)^.Local.p_insert := Local.p_insert;
  PGDBObjWithLocalCS(refp)^.Local.Basis := Local.Basis;
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
           ProjectProc(P_insert_in_WCS,ProjP_insert);
           if pprojoutbound<>nil then pprojoutbound^.clear;
end;
constructor GDBObjWithLocalCS.initnul;
begin
  ObjMatrix:=OneMatrix;
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  local.p_insert:=nulvertex;
  inherited initnul(owner);
  pprojoutbound:=nil;
end;
constructor GDBObjWithLocalCS.init;
var
   powner:PGDBObjGenericWithSubordinated;
begin
  inherited init(own,layeraddres,LW);
  powner:=bp.ListPos.owner;
  if powner<>nil then
  begin
  Local.basis.ox:={wx^}PGDBVertex(@powner^.GetMatrix^[0])^;
  Local.basis.oy:={wy^}PGDBVertex(@powner^.GetMatrix^[1])^;
  Local.basis.oz:={wz^}PGDBVertex(@powner^.GetMatrix^[2])^;
  end
  else
  begin
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  end;

  pprojoutbound:=nil;
  //CalcObjMatrix;
end;
procedure GDBObjWithLocalCS.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
     CalcObjMatrix;
end;
function GDBObjWithLocalCS.CalcObjMatrixWithoutOwner;
var rotmatr,dispmatr:DMatrix4D;
begin
     //Local.oz:=NormalizeVertex(Local.oz);
     Local.basis.ox:=GetXfFromZ(Local.basis.oz);
     {if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=CrossVertex(ZWCS,Local.oz);}
     Local.basis.oy:=CrossVertex(Local.basis.oz,Local.basis.ox);

     Local.basis.oy:=NormalizeVertex(Local.basis.oy);
     Local.basis.oz:=NormalizeVertex(Local.basis.oz);

     rotmatr:=onematrix;
     PGDBVertex(@rotmatr[0])^:=Local.basis.ox;
     PGDBVertex(@rotmatr[1])^:=Local.basis.oy;
     PGDBVertex(@rotmatr[2])^:=Local.basis.oz;

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
     if bp.ListPos.owner<>nil then
                                  objmatrix:=MatrixMultiply({objmatrix}CalcObjMatrixWithoutOwner,bp.ListPos.owner^.GetMatrix^)
                              else
                                  objmatrix:=CalcObjMatrixWithoutOwner;


     P_insert_in_WCS:={PGDBVertex(@dispmatr[3])^;//}VectorTransform3D(nulvertex,objmatrix);
end;
procedure GDBObjWithLocalCS.transform;
//var tv,tv2:GDBVertex4D;
begin

  {tv2:=PGDBVertex4D(@t_matrix[3])^;
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
  Local.p_insert:=PGDBVertex(@tv)^;}
  inherited;
  ReCalcFromObjMatrix;
end;
procedure GDBObjWithLocalCS.SaveToDXFObjPostfix;
begin
  if (abs(local.basis.oz.x)>eps)or(abs(local.basis.oz.y)>eps)or(abs(local.basis.oz.z-1)>eps) then
  begin
  dxfvertexout(outhandle,210,local.basis.oz);
  {WriteString_EOL(outhandle, '210');
  WriteString_EOL(outhandle, floattostr(local.oz.x));
  WriteString_EOL(outhandle, '220');
  WriteString_EOL(outhandle, floattostr(local.oz.y));
  WriteString_EOL(outhandle, '230');
  WriteString_EOL(outhandle, floattostr(local.oz.z));}
  end;
end;
function GDBObjWithLocalCS.LoadFromDXFObjShared;
//var s:String;
begin
     result:=inherited LoadFromDXFObjShared(f,dxfcod,ptu,drawing);
     if not result then result:=dxfvertexload(f,210,dxfcod,Local.basis.oz);
end;
destructor GDBObjWithLocalCS.done;
begin
          if assigned(PProjoutbound) then
                            begin
                            PProjoutbound^.{FreeAnd}Done;
                            Freemem(Pointer(PProjoutbound));
                            end;
          inherited done;
end;
begin
end.

