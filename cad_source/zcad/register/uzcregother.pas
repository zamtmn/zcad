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

unit uzcregother;
{$INCLUDE zcadconfig.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,Varman,SysUtils,
     UBaseTypeDescriptor,uzctnrVectorBytes, strmy, varmandef,
     uzcsysparams,uzcsysinfo,TypeDescriptors,URecordDescriptor,
     uzclog,LazLogger;
implementation
{$IFNDEF WINDOWS}
//var
//  ptd:PUserTypeDescriptor;
{$ENDIF}
var
  mem:TZctnrVectorBytes;
initialization;
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/sysvar.pas'),nil);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/savedvar.pas'),nil);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/devicebase.pas'),nil);

  SysVarUnit:=units.findunit(SupportPath,InterfaceTranslate,'sysvar');
  SavedUnit:=units.findunit(SupportPath,InterfaceTranslate,'savedvar');
  DBUnit:=units.findunit(SupportPath,InterfaceTranslate,'devicebase');

  if SysVarUnit<>nil then
  begin
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_DrawMode,'DWG_DrawMode');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_OSMode,'DWG_OSMode');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');
  //SysVarUnit.AssignToSymbol(SysVar.dwg.DWG_PolarMode,'DWG_PolarMode');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_StepGrid,'DWG_StepGrid');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_OriginGrid,'DWG_OriginGrid');

  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SnapGrid,'DWG_SnapGrid');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_DrawGrid,'DWG_DrawGrid');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SystmGeometryDraw,'DWG_SystmGeometryDraw');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_HelpGeometryDraw,'DWG_HelpGeometryDraw');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_EditInSubEntry,'DWG_EditInSubEntry');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_AdditionalGrips,'DWG_AdditionalGrips');
  SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_SelectedObjToInsp,'DWG_SelectedObjToInsp');
  //SysVarUnit.AssignToSymbol(SysVar.DWG.DWG_RotateTextInLT,'DWG_RotateTextInLT');

  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_TraceAutoInc,'DSGN_TraceAutoInc');
  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_LeaderDefaultWidth,'DSGN_LeaderDefaultWidth');
  SysVarUnit.AssignToSymbol(SysVar.DSGN.DSGN_HelpScale,'DSGN_HelpScale');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Net,'DSGN_LCNet');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Cable,'DSGN_LCCable');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_LayerControls.DSGN_LC_Leader,'DSGN_LCLeader');
  //SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_SelNew,'DSGN_SelNew');
  SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_SelSameName,'DSGN_SelSameName');
  //SysVarUnit.AssignToSymbol(sysvar.DSGN.DSGN_OTrackTimerInterval,'DSGN_OTrackTimerInterval');

  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_CursorSize,'DISP_CursorSize');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_CrosshairSize,'DISP_CrosshairSize');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_OSSize,'DISP_OSSize');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_ZoomFactor,'DISP_ZoomFactor');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_DrawZAxis,'DISP_DrawZAxis');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_ColorAxis,'DISP_ColorAxis');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_GripSize,'DISP_GripSize');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_SelectedGripColor,'DISP_SelectedGripColor');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_UnSelectedGripColor,'DISP_UnSelectedGripColor');
  //SysVarUnit.AssignToSymbol(SysVar.DISP.DISP_HotGripColor,'DISP_HotGripColor');

  //SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuProjType,'PMenuProjType');
  //SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuCommandLine,'PMenuCommandLine');
  //SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuHistoryLine,'PMenuHistoryLine');
  //SysVarUnit.AssignToSymbol(SysVar.MISC.PMenuDebugObjInsp,'PMenuDebugObjInsp');
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

  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowHeaders,'INTF_ObjInsp_ShowHeaders');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw,'INTF_ObjInsp_OldStyleDraw');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_WhiteBackground,'INTF_ObjInsp_WhiteBackground');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator,'INTF_ObjInsp_ShowSeparator');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowFastEditors,'INTF_ObjInsp_ShowFastEditors');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowOnlyHotFastEditors,'INTF_ObjInsp_ShowOnlyHotFastEditors');
  //SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Enable,'INTF_ObjInsp_RowHeight_OverriderEnable');
  //SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Value,'INTF_ObjInsp_RowHeight_OverriderValue');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_SpaceHeight,'INTF_ObjInsp_SpaceHeight');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_AlwaysUseMultiSelectWrapper,'INTF_ObjInsp_AlwaysUseMultiSelectWrapper');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowEmptySections,'INTF_ObjInsp_ShowEmptySections');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ButtonSizeReducing,'INTF_ObjInsp_ButtonSizeReducing');
  SysVarUnit.AssignToSymbol(SysVar.INTF.INTF_DefaultEditorFontHeight,'INTF_DefaultEditorFontHeight');

  SysVarUnit.AssignToSymbol(SysVar.RD.RD_PanObjectDegradation,'RD_PanObjectDegradation');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_UseStencil,'RD_UseStencil');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_DrawInsidePaintMessage,'RD_DrawInsidePaintMessage');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_RemoveSystemCursorFromWorkArea,'RD_RemoveSystemCursorFromWorkArea');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_VSync,'RD_VSync');
  {$IFNDEF WINDOWS}
  //if SysVar.RD.RD_VSync<>nil then
  //                               SysVar.RD.RD_VSync^:=TVSDefault;
  //ptd:=SysUnit.TypeName2PTD('trd');
  //if ptd<>nil then
  //                PRecordDescriptor(ptd).SetAttrib('RD_VSync',FA_READONLY,0);

  {$ENDIF}
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_LineSmooth,'RD_LineSmooth');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Restore_Mode,'RD_Restore_Mode');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxLineWidth,'RD_MaxLineWidth');
  //SysVar.RD.RD_MaxLineWidth^:=-1;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxPointSize,'RD_MaxPointSize');
  //SysVar.RD.RD_MaxPointSize^:=-1;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Vendor,'RD_Vendor');
  //SysVar.RD.RD_Vendor^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Renderer,'RD_Renderer');
  //SysVar.RD.RD_Renderer^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Version,'RD_Version');
  //SysVar.RD.RD_Version^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Extensions,'RD_Extensions');
  //SysVar.RD.RD_Extensions^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_GLUVersion,'RD_GLUVersion');
  //SysVar.RD.RD_GLUVersion^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_GLUExtensions,'RD_GLUExtensions');
  //SysVar.RD.RD_GLUExtensions^:=rsncOGLc;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxWidth,'RD_MaxWidth');
  //SysVar.RD.RD_MaxWidth^:=-1;
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_BackGroundColor,'RD_BackGroundColor');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_LastRenderTime,'RD_LastRenderTime');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_LastUpdateTime,'RD_LastUpdateTime');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxRenderTime,'RD_MaxRenderTime');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_Light,'RD_Light');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_Enabled,'RD_ID_Enabled');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor,'RD_ID_MaxDegradationFactor');
  //SysVarUnit.AssignToSymbol(SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime,'RD_ID_PrefferedRenderTime');
  //if SysVar.RD.RD_ImageDegradation.RD_ID_Enabled^ then
  //                                                    SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=0
  //                                                else
  //                                                    SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor^;
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_MaxLTPatternsInEntity,'RD_MaxLTPatternsInEntity');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_SpatialNodesDepth,'RD_SpatialNodesDepth');
  SysVarUnit.AssignToSymbol(SysVar.RD.RD_SpatialNodeCount,'RD_SpatialNodeCount');
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Current_Interval,'SAVE_Auto_Current_Interval');
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_Interval,'SAVE_Auto_Interval');
  SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_FileName,'SAVE_Auto_FileName');
  SysVarUnit.AssignToSymbol(SysVar.SAVE.SAVE_Auto_On,'SAVE_Auto_On');

  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_Version,'SYS_Version');
  SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_RunTime,'SYS_RunTime');
  SysVar.SYS.SYS_RunTime^:=0;
  //SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_ActiveMouse,'SYS_ActiveMouse');
  //SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_SystmGeometryColor,'SYS_SystmGeometryColor');
  //SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_IsHistoryLineCreated,'SYS_IsHistoryLineCreated');
  //SysVar.SYS.SYS_IsHistoryLineCreated^:=FALSE;
  //SysVarUnit.AssignToSymbol(SysVar.SYS.SYS_AlternateFont,'SYS_AlternateFont');

  SysVarUnit.AssignToSymbol(SysVar.PATH.device_library,'PATH_Device_Library');
  //s:=SysVar.PATH.device_library^;
  //SysVarUnit.AssignToSymbol(SysVar.PATH.Program_Run,'PATH_Program_Run');
  //s:=SysVar.PATH.Program_Run^;
  //SysVarUnit.AssignToSymbol(SysVar.PATH.Support_Path,'PATH_Support_Path');
  //s:=SysVar.PATH.Support_Path^;

  SysVarUnit.AssignToSymbol(SysVar.PATH.Template_Path,'PATH_Template_Path');
  //s:=SysVar.PATH.Template_Path^;
  SysVarUnit.AssignToSymbol(SysVar.PATH.Template_File,'PATH_Template_File');
  //s:=SysVar.PATH.Template_File^;

  SysVarUnit.AssignToSymbol(SysVar.PATH.LayoutFile,'PATH_LayoutFile');

  //SysVarUnit.AssignToSymbol(SysVar.PATH.Fonts_Path,'PATH_Fonts');

  //sysvar.RD.RD_LastRenderTime^:=0;
  //sysvar.PATH.Program_Run^:=sysparam.programpath;
  //sysvar.PATH.Temp_files:=@temppath;
  sysvar.SYS.SYS_Version^:=sysparam.notsaved.ver.versionstring;
  end;


  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/cables.pas'),nil);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/devices.pas'),nil);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/connectors.pas'),nil);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/styles/styles.pas'),nil);

  //units.loadunit(expandpath('*rtl\objdefunits\objname.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\blocktype.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\ark.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\connector.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elcableconnector.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\cable.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\trace.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elwire.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\objroot.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\firesensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\smokesensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\termosensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\handsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elmotor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\elsr.pas'),nil);

  //units.loadunit(expandpath('*rtl\objdefunits\bgbsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bgtsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bglsensor.pas'),nil);
  //units.loadunit(expandpath('*rtl\objdefunits\bias.pas'),nil);

  SysVar.debug.memdeb.GetMemCount:=nil;
  SysVar.debug.memdeb.FreeMemCount:=nil;
  SysVar.debug.memdeb.TotalAllocMb:=nil;
  SysVar.debug.memdeb.CurrentAllocMB:=nil;

  if sysunit<>nil then
  begin
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
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');

  mem.init(1024);
  SavedUnit^.SavePasToMem(mem);
  mem.SaveToFile(expandpath(ProgramPath+'rtl'+PathDelim+'savedvar.pas'));
  mem.done;
  //units.FreeAndDone;
end.
