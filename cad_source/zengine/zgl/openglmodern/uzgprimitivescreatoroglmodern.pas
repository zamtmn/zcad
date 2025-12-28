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
  sysutils,uzbtypes,uzeTypes,uzgprimitivessarray,
  uzegeometry,uzbLogIntf,gzctnrVectorTypes,uzgprimitivescreator,
  uzgldrawerabstract,uzgldrawcontext,uzglgeomdata,uzgvertex3sarray,
  uzegeometrytypes;
const
  WrongVBOID=0;
type
TLLPrimitivesCreatorOGLModern=class(TLLPrimitivesCreator)
                function CreateLLLine(var pa:TLLPrimitivesArray;const P1Index:TLLVertexIndex;OnlyOne:Boolean=False):TArrayIndex;override;
             end;
implementation
uses
  uzgldraweroglmodern;
var
  old:integer=0;
type
  PTLLVBOLine=^TLLVBOLine;
  TLLVBOLine= object(TLLLine)
    //vboID:GLuint;
    VBOIndex:TVBOAllocator.TIndexInRanges;
    constructor init;
    destructor done;virtual;
    function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
  end;
constructor TLLVBOLine.init;
begin
  VBOIndex:=-1;
  //vboID:=WrongVBOID;
end;
destructor TLLVBOLine.done;
begin
  //if vboID<>WrongVBOID then
  //  glDeleteBuffers(1,@vboID);
  //vboID:=WrongVBOID;
end;
function TLLVBOLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
var
  offs:integer;
const
  size=sizeof(Double)*3*2;
begin
  if not OptData.ignorelines then begin
    OGLSM.mytotalglend;
    if VBOIndex=-1 then begin
      glBindBuffer(GL_ARRAY_BUFFER,TZGLOpenGLDrawerModern(drawer).PVBO^.vboID);
      VBOIndex:=TZGLOpenGLDrawerModern(drawer).PVBO^.vboAllocator.Allocate(size,-1);
      offs:=TZGLOpenGLDrawerModern(drawer).PVBO^.vboAllocator.AllocatedRanges.mutable[VBOIndex]^.offset;
      glBufferSubData(GL_ARRAY_BUFFER,offs,size,geomdata.Vertex3S.getDataMutable(P1Index));
      glVertexPointer(3, GL_DOUBLE, 0, nil);
      glEnableClientState(GL_VERTEX_ARRAY);
    end else begin
      //glBindBuffer(GL_ARRAY_BUFFER,TZGLOpenGLDrawerModern(drawer).PVBO^.vboID);
      offs:=TZGLOpenGLDrawerModern(drawer).PVBO^.vboAllocator.AllocatedRanges.mutable[VBOIndex]^.offset;
    end;

    //Устанавливаем 3 координаты каждой вершины с 0 шагом в этом массиве; тут необходимо
    //glVertexPointer(3, GL_DOUBLE, 0, nil);

    //Данный массив содержит вершины(не нормалей, цвета, текстуры и т.д.)
    //glEnableClientState(GL_VERTEX_ARRAY);
    //Рисование треугольника, указывая количества вершин
    //glDrawArrays(GL_LINES,offs div (size div 2), 2);
    //Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+1);

    //glDisableClientState(GL_VERTEX_ARRAY);
    //glBindBuffer(GL_ARRAY_BUFFER,WrongVBOID);
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

