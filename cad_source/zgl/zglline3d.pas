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
unit zglline3d;
{$INCLUDE def.inc}

interface
uses zglsimpleentity,log;
type
{EXPORT+}
ZGLObjLine3D={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLObjSimpleEntity)
             end;
{EXPORT-}
implementation
begin
  {$IFDEF DEBUGINITSECTION}LogOut('zglline3d.initialization');{$ENDIF}
end.
