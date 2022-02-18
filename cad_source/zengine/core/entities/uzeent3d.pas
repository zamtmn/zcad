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
unit uzeent3d;
{$INCLUDE zcadconfig.inc}

interface
uses uzeentity;
type
{EXPORT+}
{REGISTEROBJECTTYPE GDBObj3d}
GDBObj3d= object(GDBObjEntity)
         end;
{EXPORT-}
implementation
begin
end.
