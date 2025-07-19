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
uses uzegeometrytypes,uzeentplain,uzegeometry,sysutils,uzedrawingdef;
type

PGDBObjPlainWithOX=^GDBObjPlainWithOX;
GDBObjPlainWithOX= object(GDBObjPlain)
               procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
         end;
implementation
//uses
//    log;
procedure GDBObjPlainWithOX.CalcObjMatrix;
var rotmatr,dispmatr:DMatrix4D;
begin
     {if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=VectorDot(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=VectorDot(ZWCS,Local.oz);
     Local.ox.x:=1;
     Local.ox.y:=0;
     Local.ox.z:=0;}

     Local.basis.ox:=NormalizeVertex(Local.basis.ox);
     Local.basis.oy:=VectorDot(Local.basis.oz,Local.basis.ox);
     Local.basis.oy:=NormalizeVertex(Local.basis.oy);
     Local.basis.oz:=NormalizeVertex(Local.basis.oz);

     //rotmatr:=onematrix;
     //PGDBVertex(@rotmatr.mtr[0])^:=Local.basis.ox;
     //PGDBVertex(@rotmatr.mtr[1])^:=Local.basis.oy;
     //PGDBVertex(@rotmatr.mtr[2])^:=Local.basis.oz;
     rotmatr:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);

     //MatrixTranspose(rotmatr);

     //dispmatr:=onematrix;
     //PGDBVertex(@dispmatr.mtr[3])^:=Local.p_insert;
     dispmatr:=CreateTranslationMatrix(Local.p_insert);

     objmatrix:=MatrixMultiply(rotmatr,dispmatr);
     if bp.ListPos.owner<>nil then
                                  objmatrix:=MatrixMultiply(objmatrix,bp.ListPos.owner^.GetMatrix^)
                              else
                                  objmatrix:=MatrixMultiply(objmatrix,onematrix);

     P_insert_in_WCS:={PGDBVertex(@dispmatr[3])^;//}VectorTransform3D(nulvertex,objmatrix);
end;
begin
end.
