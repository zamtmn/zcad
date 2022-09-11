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

unit uzcregfontmanager;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzcsysvars,uzefontmanager,uzbpaths,uzctranslations,UUnitManager,Varman,
  TypeDescriptors,uzcLog;
implementation

initialization
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_Fonts','String',@sysvarPATHFontsPath);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_AlternateFont','String',@sysvarAlternateFont);
sysvar.PATH.Fonts_Path:=@sysvarPATHFontsPath;
sysvar.PATH.Alternate_Font:=@sysvarAlternateFont;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

