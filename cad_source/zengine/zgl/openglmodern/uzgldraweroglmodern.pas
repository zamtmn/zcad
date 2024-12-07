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
  uzgprimitivescreatoroglmodern;
type
  TZGLOpenGLDrawerModern=class(TZGLOpenGLDrawer)
    function GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;override;
  end;
implementation
var
  DrawerLLPCreator:TLLPrimitivesCreatorOGLModern;
function TZGLOpenGLDrawerModern.GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;
begin
  result:=DrawerLLPCreator;
end;
initialization
  DrawerLLPCreator:=TLLPrimitivesCreatorOGLModern.Create;
finalization
  DrawerLLPCreator.Destroy;
end.

