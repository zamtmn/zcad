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

unit zcregisterfontmanager;
{$INCLUDE def.inc}
interface
uses zcadsysvars,UGDBFontManager,paths,intftranslations,UUnitManager,TypeDescriptors;
implementation

initialization
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_Fonts','GDBString',@sysvarPATHFontsPath);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_AlternateFont','GDBString',@sysvarAlternateFont);
sysvar.PATH.Fonts_Path:=@sysvarPATHFontsPath;
sysvar.PATH.Alternate_Font:=@sysvarAlternateFont;
finalization
end.

