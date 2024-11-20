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

unit uzgprimitivescreatoroglmodern;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  GLext,GL,uzgloglstatemanager,
  uzgprimitivescreatorabstract,uzgindexsarray,uzgprimitives,
  sysutils,uzbtypes,uzgprimitivessarray,
  uzegeometry,uzbLogIntf,gzctnrVectorTypes,uzgprimitivescreator,
  uzgldrawerabstract,uzgldrawcontext,uzglgeomdata,uzgvertex3sarray;
const
  WrongVBOID=0;
type
TLLPrimitivesCreatorOGLModern=class(TLLPrimitivesCreator)
                function CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;override;
             end;
implementation
var
  old:integer=0;
type
  PTLLVBOLine=^TLLVBOLine;
  TLLVBOLine= object(TLLLine)
    vboID:GLuint;
    constructor init;
    destructor done;virtual;
    function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
  end;
constructor TLLVBOLine.init;
begin
  vboID:=WrongVBOID;
end;
destructor TLLVBOLine.done;
begin
  if vboID<>WrongVBOID then
    glDeleteBuffers(1,@vboID);
  vboID:=WrongVBOID;
end;
function TLLVBOLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
  if not OptData.ignorelines then begin
    OGLSM.mytotalglend;
    if vboID=WrongVBOID then begin
      glGenBuffers(1,@vboID);
      if vboID=WrongVBOID then
        old:=old
      else
        old:=vboID;
      glBindBuffer(GL_ARRAY_BUFFER,vboID);
      glBufferData(GL_ARRAY_BUFFER,{sizeof(TStoredCoordType)*2}sizeof(Double)*3*2,geomdata.Vertex3S.getDataMutable(P1Index),GL_STATIC_DRAW);
    end else
      glBindBuffer(GL_ARRAY_BUFFER,vboID);

    //Устанавливаем 3 координаты каждой вершины с 0 шагом в этом массиве; тут необходимо
    glVertexPointer(3, GL_DOUBLE, 0, nil);

    //Данный массив содержит вершины(не нормалей, цвета, текстуры и т.д.)
    glEnableClientState(GL_VERTEX_ARRAY);
    //Рисование треугольника, указывая количества вершин
    glDrawArrays(GL_LINES, 0, 2);

    glDisableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER,WrongVBOID);
    //Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+1);
  end;
  result:=getPrimitiveSize;
end;


function TLLPrimitivesCreatorOGLModern.CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;
var
   ptl:PTLLVBOLine;
begin
  pa.AlignDataSize;
  result:=pa.count;
  if OnlyOne then
    pa.SetSize(result+sizeof(TLLLine));
  pointer(ptl):=pa.getDataMutable(pa.AllocData(sizeof(TLLVBOLine)));
  ptl.init;
  ptl.P1Index:=P1Index;
end;
initialization
finalization
end.

