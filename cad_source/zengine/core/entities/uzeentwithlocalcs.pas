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
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzeentity,
     uzegeometrytypes,UGDBOutbound2DIArray,uzctnrVectorBytes,uzeentwithmatrix,uzbtypes,
     uzegeometry,uzeffdxfsupport,sysutils,uzeentsubordinated,uzestyleslayers,
     uzMVReader,uzbLogIntf,uzestrconsts;
type
PGDBObjWithLocalCS=^GDBObjWithLocalCS;
GDBObjWithLocalCS= object(GDBObjWithMatrix)
               Local:GDBObj2dprop;

               //**получить на чтение координаты в мировой системе координат
               P_insert_in_WCS:GDBvertex;
               //ProjP_insert:GDBvertex;
               //PProjOutBound:PGDBOOutbound2DIArray;
               lod:Byte;
               constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt);
               constructor initnul(owner:PGDBObjGenericWithSubordinated);
               destructor done;virtual;
               procedure SaveToDXFObjPostfix(var outStream:TZctnrVectorBytes);{todo: проверить использование, выкинуть нах}
               function LoadFromDXFObjShared(var rdr:TZMemReader;DXFCode:Integer;ptu:PExtensionData;var drawing:TDrawingDef;var context:TIODXFLoadContext):Boolean;

               procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
               procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
               function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;
               procedure transform(const t_matrix:DMatrix4D);virtual;
               function GetCenterPoint:GDBVertex;virtual;
               procedure createfield;virtual;

               procedure rtsave(refp:Pointer);virtual;
               procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
               procedure higlight(var DC:TDrawContext);virtual;
               procedure ReCalcFromObjMatrix;virtual;
               function IsHaveLCS:Boolean;virtual;
               function CanSimplyDrawInOCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;inline;
         end;

implementation

function GDBObjWithLocalCS.CanSimplyDrawInOCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;
var
   templod:Double;
begin
     if dc.maxdetail then
                         exit(true);
  templod:=sqrt(objmatrix.mtr[0].v[0]*objmatrix.mtr[0].v[0]+objmatrix.mtr[1].v[1]*objmatrix.mtr[1].v[1]+objmatrix.mtr[2].v[2]*objmatrix.mtr[2].v[2]);
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
     Local.basis.ox:=PGDBVertex(@objmatrix.mtr[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix.mtr[1])^;
     Local.basis.oz:=PGDBVertex(@objmatrix.mtr[2])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     {scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x;
     scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;

     if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    ox:=VectorDot(YWCS,Local.oz)
                                                                else
                                                                    ox:=VectorDot(ZWCS,Local.oz);
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
  //dc.drawer.DrawLine2DInDCS(ProjP_insert.x-10,ProjP_insert.y,ProjP_insert.x+10,ProjP_insert.y);
  //dc.drawer.DrawLine2DInDCS(ProjP_insert.x,ProjP_insert.y-10,ProjP_insert.x,ProjP_insert.y+10);
  //if PProjOutBound<>nil then PProjOutBound.DrawGeometry(dc);

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
     //ProjP_insert:=nulvertex;
     //PProjOutBound:=nil;
     lod:=0;
end;
function GDBObjWithLocalCS.GetCenterPoint;
begin
     result:=P_insert_in_WCS;
end;
constructor GDBObjWithLocalCS.initnul;
begin
  ObjMatrix:=OneMatrix;
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  local.p_insert:=nulvertex;
  inherited initnul(owner);
end;
constructor GDBObjWithLocalCS.init;
var
   powner:PGDBObjGenericWithSubordinated;
begin
  inherited init(own,layeraddres,LW);
  powner:=bp.ListPos.owner;
  if powner<>nil then
  begin
  Local.basis.ox:={wx^}PGDBVertex(@powner^.GetMatrix^.mtr[0])^;
  Local.basis.oy:={wy^}PGDBVertex(@powner^.GetMatrix^.mtr[1])^;
  Local.basis.oz:={wz^}PGDBVertex(@powner^.GetMatrix^.mtr[2])^;
  end
  else
  begin
  Local.basis.ox:=XWCS;
  Local.basis.oy:=YWCS;
  Local.basis.oz:=ZWCS;
  end;

  //pprojoutbound:=nil;
  //CalcObjMatrix;
end;
procedure GDBObjWithLocalCS.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
     CalcObjMatrix;
     CalcActualVisible(dc.DrawingContext.VActuality);
end;
function GDBObjWithLocalCS.CalcObjMatrixWithoutOwner;
  procedure ReportLocalOZIsNul;
  begin
    zDebugLn('{EH}'+Format(rsFoundBrokenEntity,[self.GetObjTypeName,'$'+IntToHex(PtrUInt(@self)),'Local.basis.oz=(0,0,0)']));
  end;
var rotmatr,dispmatr:DMatrix4D;
begin
  if IsVectorNul(Local.basis.oz) then begin
    ReportLocalOZIsNul;
    exit(EmptyMatrix);
  end;
  Local.basis.ox:=GetXfFromZ(Local.basis.oz);
  Local.basis.oy:=VectorDot(Local.basis.oz,Local.basis.ox);

  Local.basis.oy:=NormalizeVertex(Local.basis.oy);
  Local.basis.oz:=NormalizeVertex(Local.basis.oz);

  rotmatr:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);
  dispmatr:=CreateTranslationMatrix(Local.p_insert);
  result:=MatrixMultiply(dispmatr,rotmatr);
end;
procedure GDBObjWithLocalCS.CalcObjMatrix;
//var rotmatr,dispmatr:DMatrix4D;
begin
     (*if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=VectorDot(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=VectorDot(ZWCS,Local.oz);
     {Local.ox.x:=1;
     Local.ox.y:=0;
     Local.ox.z:=0;}

     Local.ox:=NormalizeVertex(Local.ox);
     Local.oy:=VectorDot(Local.oz,Local.ox);
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
  dxfvertexout(outStream,210,local.basis.oz);
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
     result:=inherited LoadFromDXFObjShared(rdr,DXFCode,ptu,drawing,context);
     if not result then result:=dxfLoadGroupCodeVertex(rdr,210,DXFCode,Local.basis.oz);
end;
destructor GDBObjWithLocalCS.done;
begin
          (*if assigned(PProjoutbound) then
                            begin
                            PProjoutbound^.{FreeAnd}Done;
                            Freemem(Pointer(PProjoutbound));
                            end;*)
          inherited done;
end;
begin
end.

