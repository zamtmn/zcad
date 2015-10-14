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

unit zcregisterzscript;
{$INCLUDE def.inc}
interface
uses zcadsysvars,paths,intftranslations,UUnitManager,TypeDescriptors;
implementation

initialization
{$IFDEF DEBUGINITSECTION}LogOut('zcregisterzscript.initialization');{$ENDIF}
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'ShowHiddenFieldInObjInsp','GDBBoolean',@debugShowHiddenFieldInObjInsp);
finalization
end.

