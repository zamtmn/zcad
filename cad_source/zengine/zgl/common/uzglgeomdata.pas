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

unit uzglgeomdata;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzgindexsarray,uzgvertex3sarray,sysutils,uzeTypes,
     uzegeometrytypes,uzegeometry,gzctnrVectorTypes;
type

ZGLGeomData=object(GDBaseObject)
                                                Vertex3S:ZGLVertex3Sarray;
                                                Indexes:ZGLIndexsArray;
                                                constructor init(m:Integer);
                                                destructor done;virtual;
                                                procedure Clear;virtual;
                                                procedure Shrink;virtual;
                                                function Add2DPoint(const x,y:fontfloat):TArrayIndex;virtual;
                                          end;

implementation
//uses log;
function ZGLGeomData.Add2DPoint(const x,y:fontfloat):TArrayIndex;
var
    vs:ZGLVertex3Sarray.TDataType;
begin
     vs.x:=x;
     vs.y:=y;
     vs.z:=0;
     result:=Vertex3S.PushBackData(vs);
end;
constructor ZGLGeomData.init;
begin
  Vertex3S.init(m);
  Indexes.init(m);
end;
destructor ZGLGeomData.done;
begin
  Vertex3S.done;
  Indexes.done;
end;
procedure ZGLGeomData.Clear;
begin
  Vertex3S.Clear;
  Indexes.Clear;
end;
procedure ZGLGeomData.Shrink;
begin
  Vertex3S.Shrink;
  Indexes.Shrink;
end;
begin
end.

