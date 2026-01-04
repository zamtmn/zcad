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

unit uzcregother;
{$INCLUDE zengineconfig.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,Varman,SysUtils,
     UBaseTypeDescriptor,uzctnrVectorBytesStream,varmandef,
     uzcsysparams,TypeDescriptors,URecordDescriptor,
     uzcLog,uzcFileStructure;
implementation
var
  mem:TZctnrVectorBytes;

initialization;
  units.loadunit(GetSupportPaths,InterfaceTranslate,FindFileInCfgsPaths(CFSconfigsDir,CFSsysvarpasFile),nil);
  units.loadunit(GetSupportPaths,InterfaceTranslate,FindFileInCfgsPaths(CFSconfigsDir,CFSsavedvarpasFile),nil);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/devicebase.pas'),nil);

  SysVarUnit:=units.findunit(GetSupportPaths,InterfaceTranslate,'sysvar');
  SavedUnit:=units.findunit(GetSupportPaths,InterfaceTranslate,'savedvar');
  DBUnit:=units.findunit(GetSupportPaths,InterfaceTranslate,'devicebase');

  if SysVarUnit<>nil then begin
    SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_HelpGeometryDraw,'DWG_HelpGeometryDraw');
    SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_AdditionalGrips,'DWG_AdditionalGrips');
    SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SelectedObjToInsp,'DWG_SelectedObjToInsp');
    SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_TraceAutoInc,'DSGN_TraceAutoInc');
    SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_LeaderDefaultWidth,'DSGN_LeaderDefaultWidth');
    SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_HelpScale,'DSGN_HelpScale');
    SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net,'DSGN_LCNet');
    SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable,'DSGN_LCCable');
    SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader,'DSGN_LCLeader');
    SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_SelSameName,'DSGN_SelSameName');
    SysVarUnit.AssignToSymbol(SysVar.debug.ShowHiddenFieldInObjInsp,'ShowHiddenFieldInObjInsp');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ShowScrollBars,'INTF_ShowScrollBars');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ShowDwgTabs,'INTF_ShowDwgTabs');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_DwgTabsPosition,'INTF_DwgTabsPosition');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedUpToolbars,'INTF_ThemedUpToolbars');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedRightToolbars,'INTF_ThemedRightToolbars');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedDownToolbars,'INTF_ThemedDownToolbars');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ThemedLeftToolbars,'INTF_ThemedLeftToolbars');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ShowDwgTabCloseBurron,'INTF_ShowDwgTabCloseBurron');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_DefaultControlHeight,'INTF_DefaultControlHeight');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_AppMode,'INTF_AppMode');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_ColorScheme,'INTF_ColorScheme');
    SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_AlwaysUseMultiSelectWrapper,'DWG_AlwaysUseMultiSelectWrapper');
    SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_DefaultEditorFontHeight,'INTF_DefaultEditorFontHeight');
    SysVarUnit.AssignToSymbol(SysVar.RD.RD_PanObjectDegradation,'RD_PanObjectDegradation');
    SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxLTPatternsInEntity,'RD_MaxLTPatternsInEntity');
    SysVarUnit.AssignToSymbol(SysVar.RD.RD_SpatialNodesDepth,'RD_SpatialNodesDepth');
    SysVarUnit.AssignToSymbol(SysVar.RD.RD_SpatialNodeCount,'RD_SpatialNodeCount');
    SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Current_Interval,'SAVE_Auto_Current_Interval');
    SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Interval,'SAVE_Auto_Interval');
    if (SysVar.SAVE.SAVE_Auto_Current_Interval<>nil)and(SysVar.SAVE.SAVE_Auto_Interval<>nil) then
      SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
    SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_FileName,'SAVE_Auto_FileName');
    SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_On,'SAVE_Auto_On');

    SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_Version,'SYS_Version');
    SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_RunTime,'SYS_RunTime');
    if SysVar.SYS.SYS_RunTime<>nil then
      SysVar.SYS.SYS_RunTime^:=0;
    SysVarUnit.AssignToSymbol(SysVar.PATH.device_library,'PATH_Device_Library');
    SysVarUnit.AssignToSymbol(SysVar.PATH.Template_Path,'PATH_Template_Path');
    SysVarUnit.AssignToSymbol(SysVar.PATH.Template_File,'PATH_Template_File');
    SysVarUnit.AssignToSymbol(SysVar.PATH.Preload_Paths,'PATH_Preload_Path');
    SysVarUnit.AssignToSymbol(SysVar.PATH.LayoutFile,'PATH_LayoutFile');
    if sysvar.SYS.SYS_Version<>nil then
      sysvar.SYS.SYS_Version^:=ZCSysParams.notsaved.ver.versionstring;
  end;
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/cables.pas'),nil);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/devices.pas'),nil);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/connectors.pas'),nil);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/styles/styles.pas'),nil);

  SysVar.debug.memdeb.GetMemCount:=nil;
  SysVar.debug.memdeb.FreeMemCount:=nil;
  SysVar.debug.memdeb.TotalAllocMb:=nil;
  SysVar.debug.memdeb.CurrentAllocMB:=nil;

  if sysunit<>nil then begin
    PRecordDescriptor(sysunit.TypeName2PTD('CommandRTEdObject'))^.FindField('commanddata')^.Collapsed:=false;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('VariablesUnit')^.Collapsed:=false;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('GeneralUnit')^.Collapsed:=false;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('GeometryUnit')^.Collapsed:=false;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('MiscUnit')^.Collapsed:=false;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('SummaryUnit')^.Collapsed:=false;
    SetCategoryCollapsed('NMO',false);
    SetCategoryCollapsed('GC',false);
    SetCategoryCollapsed('CABLE',false);
  end;
finalization;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if SavedUnit<>nil then begin
    mem.init(1024);
    SavedUnit^.SavePasToMem(mem);
    mem.SaveToFile(GetWritableFilePath(CFSconfigsDir,CFSsavedvarpasFile));
    mem.done;
  end;
end.
