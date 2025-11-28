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
unit uzeentplainwithox;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzegeometrytypes,uzeentplain,uzegeometry,SysUtils,uzedrawingdef;

type

  PGDBObjPlainWithOX=^GDBObjPlainWithOX;

  GDBObjPlainWithOX=object(GDBObjPlain)
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
  end;

implementation

procedure GDBObjPlainWithOX.CalcObjMatrix;
var
  rotmatr,dispmatr:TzeTypedMatrix4d;
begin
  Local.basis.ox:=NormalizeVertex(Local.basis.ox);
  Local.basis.oy:=VectorDot(Local.basis.oz,Local.basis.ox);
  Local.basis.oy:=NormalizeVertex(Local.basis.oy);
  Local.basis.oz:=NormalizeVertex(Local.basis.oz);

  rotmatr:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);

  dispmatr:=CreateTranslationMatrix(Local.p_insert);

  objmatrix:=MatrixMultiply(rotmatr,dispmatr);
  if bp.ListPos.owner<>nil then
    objmatrix:=
      MatrixMultiply(objmatrix,bp.ListPos.owner^.GetMatrix^)
  else
    objmatrix:=MatrixMultiply(objmatrix,onematrix);

  P_insert_in_WCS:=VectorTransform3D(nulvertex,objmatrix);
end;

begin
end.
