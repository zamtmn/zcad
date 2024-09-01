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
  TypeDescriptors,uzcLog,uzcsysparams;
implementation

initialization
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('$(ZCADPath)/rtl/system.pas'),InterfaceTranslate,'PATH_Support_Path','String',GeAddrSupportPath);
  sysvar.PATH.Dictionaries:=@SysParam.saved.DictionariesPath;
  sysvar.PATH.Program_Run:=@ProgramPath;
  sysvar.PATH.Support_Path:=GeAddrSupportPath;
  sysvar.PATH.AdditionalSupport_Path:=@AdditionalSupportPath;
  sysvar.PATH.Temp_files:=@TempPath;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

