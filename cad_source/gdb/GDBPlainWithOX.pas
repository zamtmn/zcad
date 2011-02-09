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

unit GDBPlainWithOX;
{$INCLUDE def.inc}

interface
uses GDBPlain{,gdbasetypes,gdbEntity,UGDBOutbound2DIArray,UGDBOpenArrayOfByte}{,varmandef,GDBWithMatrix},
gl,
GDBase,{gDBDescriptor,gdbobjectsconstdef,oglwindowdef,}geometry{,dxflow},sysutils,memman{,GDBSubordinated};
type
//pprojoutbound:{-}PGDBOOutbound2DIArray{/GDBPointer/};
{EXPORT+}
PGDBObjPlainWithOX=^GDBObjPlainWithOX;
GDBObjPlainWithOX=object(GDBObjPlain)
               procedure CalcObjMatrix;virtual;
         end;
{EXPORT-}
implementation
uses
    log;
//uses UGDBDescriptor;
procedure GDBObjPlainWithOX.CalcObjMatrix;
var rotmatr,dispmatr:DMatrix4D;
begin
     {if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=CrossVertex(ZWCS,Local.oz);
     Local.ox.x:=1;
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

     //MatrixTranspose(rotmatr);

     dispmatr:=onematrix;
     PGDBVertex(@dispmatr[3])^:=Local.p_insert;

     objmatrix:=MatrixMultiply(rotmatr,dispmatr);
     objmatrix:=MatrixMultiply(objmatrix,bp.ListPos.owner^.GetMatrix^);

     P_insert_in_WCS:={PGDBVertex(@dispmatr[3])^;//}VectorTransform3D(nulvertex,objmatrix);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCPlainWithOX.initialization');{$ENDIF}
end.
