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
uses uzcsysvars,uzbpaths,uzctranslations,UUnitManager,TypeDescriptors,
     Varman,uzcoidecorations,uzegluinterface,uzcLog,uzccommandlineutil,
     uzcsysparams;
implementation
var
  system_pas_path:string;

initialization
  DecorateSysTypes;
  system_pas_path:=expandpath('$(ZCADPath)/rtl/system.pas');
  units.CreateExtenalSystemVariable(SysVarNotSavedUnit,SysVarNSN,GetSupportPath,system_pas_path,InterfaceTranslate,'RD_GLUVersion','String',@GLUVersion);
  SysVarNotSavedUnit.AssignToSymbol(SysVar.RD.RD_GLUVersion,'RD_GLUVersion');
  sysvar.RD.RD_GLUVersion^:=GLUVersion;

  units.CreateExtenalSystemVariable(SysVarNotSavedUnit,SysVarNSN,GetSupportPath,system_pas_path,InterfaceTranslate,'RD_GLUExtensions','String',@GLUExtensions);
  SysVarNotSavedUnit.AssignToSymbol(SysVar.RD.RD_GLUExtensions,'RD_GLUExtensions');
  sysvar.RD.RD_GLUExtensions^:=GLUExtensions;

  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,system_pas_path,InterfaceTranslate,'INTF_CommandLineEnabled','Boolean',@INTFCommandLineEnabled);
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_CommandLineEnabled,'INTF_CommandLineEnabled');

  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,system_pas_path,InterfaceTranslate,'INTF_MessagesSuppressDoubles','TGDB3StateBool',@INTFMessagesSuppressDoubles);
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_MESSAGES_Properties.INTF_Messages_SuppressDoubles,'INTF_MessagesSuppressDoubles');

  SysVar.sys.SYS_UniqueInstance:=@SysParam.saved.UniqueInstance;
  SysVar.sys.SYS_NoSplash:=@SysParam.saved.NoSplash;
  SysVar.sys.SYS_NoLoadLayout:=@SysParam.saved.NoLoadLayout;
  SysVar.sys.SYS_UpdatePO:=@SysParam.saved.UpdatePO;
  SysVar.sys.SYS_MemProfiling:=@SysParam.saved.MemProfiling;
  SysVar.INTF.INTF_LanguageOverride:=@SysParam.saved.LangOverride;

  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedUpToolbars,'INTF_ThemedUpToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedRightToolbars,'INTF_ThemedRightToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedDownToolbars,'INTF_ThemedDownToolbars');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedLeftToolbars,'INTF_ThemedLeftToolbars');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

