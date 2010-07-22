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
unit GDB3d;
{$INCLUDE def.inc}

interface
uses GDBEntity,log;
type
{EXPORT+}
GDBObj3d=object(GDBObjEntity)
         end;
{EXPORT-}
implementation
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBObj3D.initialization');{$ENDIF}
end.
