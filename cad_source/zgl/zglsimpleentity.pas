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
unit zglsimpleentity;
{$INCLUDE def.inc}

interface
uses {GDBEntity,}log,GDBase{,gdbasetypes};
type
{EXPORT+}
ZGLObjSimpleEntity={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                  end;
{EXPORT-}
implementation
begin
  {$IFDEF DEBUGINITSECTION}LogOut('zglsimpleetity.initialization');{$ENDIF}
end.
