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

unit uzcreginterface;
{$INCLUDE zengineconfig.inc}
interface
uses uzcsysvars,uzbpaths,uzctranslations,UUnitManager,uzsbTypeDescriptors,
     Varman,uzcoidecorations,uzegluinterface,uzcLog,uzccommandlineutil,
     uzeSysParams,uzcSysParams;
implementation
var
  system_pas_path:string;

initialization
  DecorateSysTypes;
  system_pas_path:=expandpath('$(DistribPath)/rtl/system.pas');
  units.CreateExtenalSystemVariable(SysVarNotSavedUnit,SysVarNSN,GetSupportPaths,system_pas_path,InterfaceTranslate,'RD_GLUVersion','String',@GLUVersion);
  SysVarNotSavedUnit.AssignToSymbol(SysVar.RD.RD_GLUVersion,'RD_GLUVersion');
  sysvar.RD.RD_GLUVersion^:=GLUVersion;

  units.CreateExtenalSystemVariable(SysVarNotSavedUnit,SysVarNSN,GetSupportPaths,system_pas_path,InterfaceTranslate,'RD_GLUExtensions','String',@GLUExtensions);
  SysVarNotSavedUnit.AssignToSymbol(SysVar.RD.RD_GLUExtensions,'RD_GLUExtensions');
  sysvar.RD.RD_GLUExtensions^:=GLUExtensions;

  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_CommandLineEnabled','Boolean',@INTFCommandLineEnabled);
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_CommandLineEnabled,'INTF_CommandLineEnabled');

  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,system_pas_path,InterfaceTranslate,'INTF_MessagesSuppressDoubles','TGDB3StateBool',@INTFMessagesSuppressDoubles);
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_MESSAGES_Properties.INTF_Messages_SuppressDoubles,'INTF_MessagesSuppressDoubles');

  SysVar.sys.SYS_UniqueInstance:=@ZCSysParams.saved.UniqueInstance;
  SysVar.sys.SYS_NoSplash:=@ZCSysParams.saved.NoSplash;
  SysVar.sys.SYS_NoLoadLayout:=@ZCSysParams.saved.NoLoadLayout;
  SysVar.sys.SYS_UpdatePO:=@ZCSysParams.saved.UpdatePO;
  SysVar.sys.SYS_MemProfiling:=@ZCSysParams.saved.MemProfiling;
  SysVar.sys.SYS_UseExperimentalFeatures:=@ZESysParams.UseExperimentalFeatures;
  SysVar.INTF.INTF_LanguageOverride:=@ZCSysParams.saved.LangOverride;

  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedUpToolbars,'INTF_ThemedUpToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedRightToolbars,'INTF_ThemedRightToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedDownToolbars,'INTF_ThemedDownToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedLeftToolbars,'INTF_ThemedLeftToolbars');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

