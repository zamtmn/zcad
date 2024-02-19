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
  uzcsysvars,uzefontmanager,uzeFontFileFormatTTFBackend,
  uzbpaths,uzctranslations,UUnitManager,Varman,
  TypeDescriptors,uzcLog;
implementation

initialization
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_Fonts','String',@sysvarPATHFontsPath);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_AlternateFont','String',@sysvarAlternateFont);
{$IF DEFINED(USELAZFREETYPETTFIMPLEMENTATION) and DEFINED(USEFREETYPETTFIMPLEMENTATION)}
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_UseLazFreeTypeImplementation','Boolean',@sysvarTTFUseLazFreeTypeImplementation);
sysvar.RD.RD_UseLazFreeTypeImplementation:=@sysvarTTFUseLazFreeTypeImplementation;
{$ELSE}
{$ENDIF}
sysvar.PATH.Fonts_Path:=@sysvarPATHFontsPath;
sysvar.PATH.Alternate_Font:=@sysvarAlternateFont;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

