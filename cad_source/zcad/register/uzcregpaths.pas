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

unit uzcregpaths;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzcsysvars,uzbpaths,uzctranslations,UUnitManager,Varman,
  TypeDescriptors,uzcLog;
implementation

initialization
  //units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_Program_Run','String',@ProgramPath);
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'PATH_Support_Path','String',@SupportPath);
  sysvar.PATH.Program_Run:=@ProgramPath;
  sysvar.PATH.Support_Path:=@SupportPath;
  sysvar.PATH.Temp_files:=@TempPath;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

