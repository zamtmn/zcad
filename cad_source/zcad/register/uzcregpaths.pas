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
  uzsbTypeDescriptors,uzcLog,uzcsysparams;
implementation

initialization
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'PATH_Support_Path','String',@SupportPaths);
  sysvar.PATH.Dictionaries:=@ZCSysParams.saved.DictionariesPath;
  sysvar.PATH.RoCfg_Path:=@GetRoCfgsPath;
  sysvar.PATH.WrCfg_Path:=@GetWrCfgsPath;
  sysvar.PATH.Support_Paths:=@SupportPaths;
  sysvar.PATH.Distrib_Path:=@GetDistribPath;
  sysvar.PATH.PreferedDistrib_Path:=@ZCSysParams.saved.PreferredDistribPath;
  sysvar.PATH.AdditionalSupport_Paths:=@GetAdditionalSupportPaths;
  sysvar.PATH.Temp_Path:=@GetTempPath;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

