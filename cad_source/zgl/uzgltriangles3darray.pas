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

unit uzgltriangles3darray;
{$INCLUDE def.inc}
interface
uses uzglline3darray,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
type
{Export+}
ZGLTriangle3DArray=object(ZGLLine3DArray)(*OpenArrayOfData=GDBVertex*)
                procedure DrawGeometry;virtual;
             end;
{Export-}
implementation
uses OGLSpecFunc,log;
procedure ZGLTriangle3DArray.drawgeometry;
var p:PGDBVertex;
    i:GDBInteger;
begin
  p:=parray;
  oglsm.myglbegin(GL_TRIANGLES);
  for i:=0 to count-{3}1 do
  begin
     oglsm.myglVertex3dV(@p^);
     inc(p);
  end;
  oglsm.myglend;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgltriangles3darray.initialization');{$ENDIF}
end.

