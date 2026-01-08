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

unit uzgldraweroglmodern;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgldrawerogl,uzgldrawergeneral,uzgprimitivescreatorabstract,uzgprimitivescreator,
  uzgprimitivescreatoroglmodern,gl,
  uzecamera,
  gzctnrBufferAllocator;
type
  TVBOAllocator=GBufferAllocator<ptruint,ptruint,integer>;
  PVBOData=^TVBOData;
  TVBOData=record
    vboID:GLuint;
    vboAllocator:TVBOAllocator;
  end;
  TZGLOpenGLDrawerModern=class(TZGLOpenGLDrawer)
    public
      PVBO:PVBOData;
    function GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;override;
    procedure endrender;override;
    procedure SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);override;
  end;
implementation
var
  DrawerLLPCreator:TLLPrimitivesCreatorOGLModern;
procedure TZGLOpenGLDrawerModern.SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);
begin
  inherited;
  //glUniformMatrix4fv(glGetUniformLocation(shaderProgram, 'model'), 1, false, mMatrix, 0);
  {mm:=cam.modelMatrix;
  oglsm.myglViewport(0, 0, w, h);
  oglsm.myglGetIntegerv(GL_VIEWPORT, @cam.viewport);

  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglLoadMatrixD(@cam.modelMatrixLCS);

  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglLoadMatrixD(@cam.projMatrixLCS);

  oglsm.myglMatrixMode(GL_MODELVIEW);}
end;

function TZGLOpenGLDrawerModern.GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;
begin
  result:=DrawerLLPCreator;
end;
procedure TZGLOpenGLDrawerModern.endrender;
begin
  glDrawArrays(GL_LINES,0,PVBO^.vboAllocator.AllocatedRanges.Size * 2);
  inherited;
end;
initialization
  DrawerLLPCreator:=TLLPrimitivesCreatorOGLModern.Create;
finalization
  DrawerLLPCreator.Destroy;
end.

