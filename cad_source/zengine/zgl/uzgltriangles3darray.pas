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
uses gdbdrawcontext,uzglline3darray,gdbasetypes,sysutils,gdbase,memman,geometry;
type
{Export+}
ZGLTriangle3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLLine3DArray)(*OpenArrayOfData=GDBVertex*)
                procedure DrawGeometry(var rc:TDrawContext);virtual;
             end;
{Export-}
implementation
uses OGLSpecFunc,log;
var
    DUMMY_oglsmmygltrianglescounter:integer;
    DUMMY_vertex1,DUMMY_vertex2:GDBVertex;
procedure DUMMY_oglsmmyglbegin;
begin
     DUMMY_oglsmmygltrianglescounter:=0;
end;
procedure DUMMY_oglsmmyglVertex3dV(var rc:TDrawContext; const V:PGDBVertex);
begin
  case DUMMY_oglsmmygltrianglescounter of
                                         0:DUMMY_vertex1:=V^;
                                         1:DUMMY_vertex2:=V^;
                                         2:begin
                                                DUMMY_oglsmmygltrianglescounter:=-1;
                                                rc.Drawer.DrawTriangle3DInModelSpace(xy_Z_Vertex,DUMMY_vertex1,DUMMY_vertex2,v^,rc.matrixs);
                                           end;
  end;
  inc(DUMMY_oglsmmygltrianglescounter);
end;
procedure ZGLTriangle3DArray.drawgeometry;
var p:PGDBVertex;
    i:GDBInteger;
begin
  p:=parray;
  //oglsm.myglbegin(GL_TRIANGLES);
  DUMMY_oglsmmyglbegin;
  for i:=0 to count-{3}1 do
  begin
     //if ((i div 3)mod 2)>0 then
     //oglsm.myglVertex3dV(@p^);
     DUMMY_oglsmmyglVertex3dV(rc,pointer(p));
     inc(p);
  end;
  //oglsm.myglend;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgltriangles3darray.initialization');{$ENDIF}
end.

