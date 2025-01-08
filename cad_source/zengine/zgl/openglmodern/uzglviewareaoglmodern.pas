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

unit uzglviewareaoglmodern;
{$INCLUDE zengineconfig.inc}
interface
uses
  GLext,
  uzglbackendmanager,
  uzgldrawerogl,uzglviewareaogl,uzgldraweroglmodern,gl,
  gzctnrBufferAllocator,
  uzeSysParams;
const
  CVBOSize=256*1024*1024;
type

  TVBOAllocator=GBufferAllocator<ptruint,ptruint,integer>;

  TOpenGLModernViewArea=class(TOpenGLViewArea)
    public
      VBO:TVBOData;
    procedure CreateDrawer;override;
    procedure getareacaps;override;
  end;
implementation
procedure TOpenGLModernViewArea.CreateDrawer;
begin
  drawer:=TZGLOpenGLDrawerModern.Create;
  TZGLOpenGLDrawerModern(drawer).PVBO:=@VBO;
end;
procedure TOpenGLModernViewArea.getareacaps;
begin
  inherited;
  if Load_GL_version_1_2 then
    OpenGLParam.RD_DraverVersion:=GLV_1_2;
  if OpenGLParam.RD_DraverVersion=GLV_1_2 then
    if Load_GL_version_1_3 then
      OpenGLParam.RD_DraverVersion:=GLV_1_3;
  if OpenGLParam.RD_DraverVersion=GLV_1_3 then
    if Load_GL_version_1_4 then
      OpenGLParam.RD_DraverVersion:=GLV_1_4;
  if OpenGLParam.RD_DraverVersion=GLV_1_4 then
    if Load_GL_version_1_5 then
      OpenGLParam.RD_DraverVersion:=GLV_1_5;
  if OpenGLParam.RD_DraverVersion=GLV_1_5 then
    if Load_GL_version_2_0 then
      OpenGLParam.RD_DraverVersion:=GLV_2_0;
  if OpenGLParam.RD_DraverVersion=GLV_2_0 then
    if Load_GL_version_2_1 then
      OpenGLParam.RD_DraverVersion:=GLV_2_1;
  if OpenGLParam.RD_DraverVersion=GLV_2_1 then
    if Load_GL_version_3_0 then
      OpenGLParam.RD_DraverVersion:=GLV_3_0;
  if OpenGLParam.RD_DraverVersion=GLV_3_0 then
    if Load_GL_version_3_1 then
      OpenGLParam.RD_DraverVersion:=GLV_3_1;
  if OpenGLParam.RD_DraverVersion=GLV_3_1 then
    if Load_GL_version_3_2 then
      OpenGLParam.RD_DraverVersion:=GLV_3_2;
  if OpenGLParam.RD_DraverVersion=GLV_3_2 then
    if Load_GL_version_3_3 then
      OpenGLParam.RD_DraverVersion:=GLV_3_3;
  if OpenGLParam.RD_DraverVersion=GLV_3_3 then
    if Load_GL_version_4_0 then
      OpenGLParam.RD_DraverVersion:=GLV_4_0;
  if OpenGLParam.RD_DraverVersion=GLV_4_0 then
    if Load_GL_version_4_3 then
      OpenGLParam.RD_DraverVersion:=GLV_4_3;
  glGenBuffers(1,@VBO.vboID);
  glBindBuffer(GL_ARRAY_BUFFER,VBO.vboID);
  glBufferData(GL_ARRAY_BUFFER,CVBOSize,nil,GL_STATIC_DRAW);
  VBO.vboAllocator.init(CVBOSize);
end;
begin
  if ZESysParams.UseExperimentalFeatures then
    RegisterBackend(TOpenGLModernViewArea,'OpenGLModern');
end.
