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

uses
  uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzeentity,uzegeometrytypes,
  UGDBOutbound2DIArray,uzctnrVectorBytes,uzeentwithmatrix,uzbtypes,uzegeometry,
  uzeffdxfsupport,SysUtils,uzeentsubordinated,uzestyleslayers,uzMVReader,
  uzbLogIntf,uzestrconsts;

type
  PGDBObjWithLocalCS=^GDBObjWithLocalCS;

  GDBObjWithLocalCS=object(GDBObjWithMatrix)
    Local:GDBObj2dprop;

    //**получить на чтение координаты в мировой системе координат
    P_insert_in_WCS:GDBvertex;
    lod:byte;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure SaveToDXFObjPostfix(var outStream:TZctnrVectorBytes);
    {todo: проверить использование, выкинуть нах}
    function LoadFromDXFObjShared(var rdr:TZMemReader;
      DXFCode:integer;ptu:PExtensionData;var drawing:TDrawingDef;
      var context:TIODXFLoadContext):boolean;

    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
    function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;
    procedure transform(const t_matrix:DMatrix4D);virtual;
    function GetCenterPoint:GDBVertex;virtual;
    procedure createfield;virtual;

    procedure rtsave(refp:Pointer);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
    procedure higlight(var DC:TDrawContext);virtual;
    procedure ReCalcFromObjMatrix;virtual;
    function IsHaveLCS:boolean;virtual;
    function CanSimplyDrawInOCS(const DC:TDrawContext;
      const ParamSize,TargetSize:double):boolean;inline;
  end;

implementation

function GDBObjWithLocalCS.CanSimplyDrawInOCS(const DC:TDrawContext;
  const ParamSize,TargetSize:double):boolean;
var
  templod:double;
begin
  if dc.maxdetail then
    exit(True);
  templod:=sqrt(objmatrix.mtr[0].v[0]*objmatrix.mtr[0].v[0]+
    objmatrix.mtr[1].v[1]*objmatrix.mtr[1].v[1]+objmatrix.mtr[2].v[2]*objmatrix.mtr[2].v[2]);
  templod:=(templod*ParamSize)/(dc.DrawingContext.zoom);
  if templod>TargetSize then
    exit(True)
  else
    exit(False);
end;

function GDBObjWithLocalCS.IsHaveLCS:boolean;
begin
  Result:=True;
end;

procedure GDBObjWithLocalCS.ReCalcFromObjMatrix;
begin
  Local.basis.ox:=PGDBVertex(@objmatrix.mtr[0])^;
  Local.basis.oy:=PGDBVertex(@objmatrix.mtr[1])^;
  Local.basis.oz:=PGDBVertex(@objmatrix.mtr[2])^;

  Local.basis.ox:=normalizevertex(Local.basis.ox);
  Local.basis.oy:=normalizevertex(Local.basis.oy);
  Local.basis.oz:=normalizevertex(Local.basis.oz);
end;

procedure GDBObjWithLocalCS.higlight;
begin
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
end;

procedure GDBObjWithLocalCS.TransformAt;
begin
  objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);
  ReCalcFromObjMatrix;
end;

procedure GDBObjWithLocalCS.rtsave;
begin
  PGDBObjWithLocalCS(refp)^.Local.p_insert:=Local.p_insert;
  PGDBObjWithLocalCS(refp)^.Local.Basis:=Local.Basis;
  PGDBObjWithLocalCS(refp)^.calcobjmatrix;
end;

procedure GDBObjWithLocalCS.createfield;
begin
  inherited;
  Local.P_insert:=nulvertex;
  P_insert_in_WCS:=nulvertex;
  lod:=0;
end;

function GDBObjWithLocalCS.GetCenterPoint;
begin
  Result:=P_insert_in_WCS;
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
  if powner<>nil then begin
    Local.basis.ox:=PGDBVertex(@powner^.GetMatrix^.mtr[0])^;
    Local.basis.oy:=PGDBVertex(@powner^.GetMatrix^.mtr[1])^;
    Local.basis.oz:=PGDBVertex(@powner^.GetMatrix^.mtr[2])^;
  end else begin
    Local.basis.ox:=XWCS;
    Local.basis.oy:=YWCS;
    Local.basis.oz:=ZWCS;
  end;
end;

procedure GDBObjWithLocalCS.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  CalcObjMatrix;
  CalcActualVisible(dc.DrawingContext.VActuality);
end;

function GDBObjWithLocalCS.CalcObjMatrixWithoutOwner;

  procedure ReportLocalOZIsNul;
  begin
    zDebugLn('{EH}'+Format(rsFoundBrokenEntity,[self.GetObjTypeName,
      '$'+IntToHex(PtrUInt(@self)),'Local.basis.oz=(0,0,0)']));
  end;

var
  rotmatr,dispmatr:DMatrix4D;
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
  Result:=MatrixMultiply(dispmatr,rotmatr);
end;

procedure GDBObjWithLocalCS.CalcObjMatrix;
begin
  if bp.ListPos.owner<>nil then
    objmatrix:=
      MatrixMultiply(CalcObjMatrixWithoutOwner,bp.ListPos.owner^.GetMatrix^)
  else
    objmatrix:=CalcObjMatrixWithoutOwner;


  P_insert_in_WCS:=VectorTransform3D(nulvertex,objmatrix);
end;

procedure GDBObjWithLocalCS.transform;
begin
  inherited;
  ReCalcFromObjMatrix;
end;

procedure GDBObjWithLocalCS.SaveToDXFObjPostfix;
begin
  if (abs(local.basis.oz.x)>eps)or(abs(local.basis.oz.y)>eps)or
    (abs(local.basis.oz.z-1)>eps) then
    dxfvertexout(outStream,210,local.basis.oz);
end;

function GDBObjWithLocalCS.LoadFromDXFObjShared;
begin
  Result:=inherited LoadFromDXFObjShared(rdr,DXFCode,ptu,drawing,context);
  if not Result then
    Result:=dxfLoadGroupCodeVertex(rdr,210,DXFCode,Local.basis.oz);
end;

begin
end.
