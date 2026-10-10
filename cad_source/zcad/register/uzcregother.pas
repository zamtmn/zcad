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

uses
  SysUtils,
  uzbpaths,uzbEncoding,
  UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
  Varman,
  UBaseTypeDescriptor,uzctnrVectorBytesStream,uzsbVarmanDef,
  uzcsysparams,uzsbTypeDescriptors,URecordDescriptor,
  uzcLog,uzcFileStructure;

implementation

var
  mem:TZctnrVectorBytes;

initialization;
  SysVar.LOADSAVE.TxtSaveCodePage:=@TxtFileSaveCodePage;
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),
    InterfaceTranslate,'LOADSAVE_TxtSaveCodePage','TFileCodePage',@TxtFileSaveCodePage);

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
    SysVarUnit.AssignToSymbol(SysVar.LOADSAVE.AutoSave.CurrentInterval,'LOADSAVE_AutoSave_CurrentInterval');
    SysVarUnit.AssignToSymbol(SysVar.LOADSAVE.AutoSave.Interval,'LOADSAVE_AutoSave_Interval');
    if (SysVar.LOADSAVE.AutoSave.CurrentInterval<>nil)and(SysVar.LOADSAVE.AutoSave.Interval<>nil) then
      SysVar.LOADSAVE.AutoSave.CurrentInterval^:=SysVar.LOADSAVE.AutoSave.Interval^;
    SysVarUnit.AssignToSymbol(SysVar.LOADSAVE.AutoSave.FileName,'LOADSAVE_AutoSave_FileName');
    SysVarUnit.AssignToSymbol(SysVar.LOADSAVE.AutoSave.Enable,'LOADSAVE_AutoSave_Enabled');

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

  if sysunit<>nil then begin
    PRecordDescriptor(sysunit.TypeName2PTD('CommandRTEdObject'))^.FindField('commanddata')^.Collapsed:=False;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('VariablesUnit')^.Collapsed:=False;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('GeneralUnit')^.Collapsed:=False;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('GeometryUnit')^.Collapsed:=False;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('MiscUnit')^.Collapsed:=False;
    PRecordDescriptor(sysunit.TypeName2PTD('TMSEditor'))^.FindField('SummaryUnit')^.Collapsed:=False;
    SetCategoryCollapsed('NMO',False);
    SetCategoryCollapsed('GC',False);
    SetCategoryCollapsed('CABLE',False);
  end;

finalization;
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if SavedUnit<>nil then begin
    mem.init(1024);
    SavedUnit^.SavePasToMem(mem);
    mem.SaveToFile(GetWritableFilePath(CFSconfigsDir,CFSsavedvarpasFile));
    mem.done;
  end;
end.
