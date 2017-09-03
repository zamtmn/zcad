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

unit uzcreginterface;
{$INCLUDE def.inc}
interface
uses uzcsysvars,uzbpaths,uzctranslations,UUnitManager,TypeDescriptors,
     Varman,uzcoidecorations,uzegluinterface,LazLogger;
implementation

initialization
  DecorateSysTypes;
  units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_GLUVersion','String',@GLUVersion);
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_GLUVersion,'RD_GLUVersion');
  sysvar.RD.RD_GLUVersion^:=GLUVersion;

  units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_GLUExtensions','String',@GLUExtensions);
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_GLUExtensions,'RD_GLUExtensions');
  sysvar.RD.RD_GLUExtensions^:=GLUExtensions;

finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

