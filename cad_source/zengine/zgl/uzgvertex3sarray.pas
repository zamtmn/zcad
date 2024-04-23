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

unit uzgvertex3sarray;
{$Mode delphi}{$H+)
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVector,sysutils,
     gzctnrVectorTypes,uzegeometrytypes,uzegeometry;
type
{Export+}
TStoredType=Double;
TCalcedType=Double;
TStoredCoordType=GDBvertex;
PZGLVertex3Sarray=^ZGLVertex3Sarray;
{REGISTEROBJECTTYPE ZGLVertex3Sarray}
ZGLVertex3Sarray= object(GZVector{-}<TStoredCoordType>{//})(*OpenArrayOfData=GDBvertex3S*)
                function AddGDBVertex(const v:GDBvertex):TArrayIndex;overload;
                function AddGDBVertex(const v:GDBvertex3S):TArrayIndex;overload;
                function GetLength(const i:TArrayIndex):TCalcedType;virtual;
             end;
{Export-}
implementation
function ZGLVertex3Sarray.GetLength(const i:TArrayIndex):TCalcedType;
var
  pv1,pv2:PT;
  v:TDataType;
begin
  pv1:=self.getDataMutable(i);
  pv2:=self.getDataMutable(i+1);;
  v.x:=pv2.x-pv1.x;
  v.y:=pv2.y-pv1.y;
  v.z:=pv2.z-pv1.z;
  result:=v.x*v.x+v.y*v.y+v.z*v.z;
end;
function ZGLVertex3Sarray.AddGDBVertex(const v:GDBvertex3S):TArrayIndex;overload;
var
    vs:TDataType;
begin
     vs.x:=v.x;
     vs.y:=v.y;
     vs.z:=v.z;
     result:=PushBackData(vs);
end;

function ZGLVertex3Sarray.AddGDBVertex(const v:GDBvertex):TArrayIndex;
var
    vs:TDataType;
begin
     vs.x:=v.x;
     vs.y:=v.y;
     vs.z:=v.z;
     result:=PushBackData(vs);
end;
begin
end.

