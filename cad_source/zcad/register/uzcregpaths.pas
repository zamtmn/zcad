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
  uzcsysvars,uzbPaths,uzctranslations,UUnitManager,Varman,
  TypeDescriptors,uzcLog,uzcsysparams;
implementation

initialization
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistroPath)/rtl/system.pas'),InterfaceTranslate,'PATH_Support_Path','String',@SupportPaths);
  sysvar.PATH.Dictionaries:=@SysParam.saved.DictionariesPath;
  sysvar.PATH.Program_Data:=@GetDistroPath;
  sysvar.PATH.Support_Path:=@SupportPaths;
  sysvar.PATH.AdditionalSupport_Path:=@GetAdditionalSupportPaths;
  sysvar.PATH.Temp_files:=@GetTempPath;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

