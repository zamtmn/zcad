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
  uzgldrawerogl,uzglviewareaogl,uzgldraweroglmodern;
type
  TOpenGLModernViewArea=class(TOpenGLViewArea)
    procedure CreateDrawer;override;
    procedure getareacaps;override;
  end;
implementation
procedure TOpenGLModernViewArea.CreateDrawer;
begin
  drawer:=TZGLOpenGLDrawerModern.Create;
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
end;
begin
  RegisterBackend(TOpenGLModernViewArea,'OpenGLModern');
end.
