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

unit uzcRegSysVars;
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}
interface
uses
  SysUtils,uzcsysvars,
  uzsbVarmanDef,
  varman,
  //UUnitManager,
  uzsbTypeDescriptors;
  //UObjectDescriptor,
  //USinonimDescriptor,UBaseTypeDescriptor;
procedure RegSysVars(ptsu:PTUnit);
implementation
procedure RegSysVars(ptsu:PTUnit);
var
  utd:PUserTypeDescriptor;
begin
  utd:=ptsu^.RegisterType(TypeInfo(tlanguadedeb),'tlanguadedeb');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['UpdatePO','NotEnlishWord','DebugWord'],
                           [FNProgram,FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tdebug),'tdebug');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['languadedeb','ShowHiddenFieldInObjInsp'],
                           [FNProgram,FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tpath),'tpath');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['Distrib_Path','PreferedDistrib_Path','RoCfg_Path',
                            'WrCfg_Path','Temp_Path','Support_Paths',
                            'AdditionalSupport_Paths','Preload_Paths',
                            'Fonts_Paths','Alternate_Font','Template_Path',
                            'Template_File','LayoutFile','Dictionaries',
                            'Device_Library'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Path to program distributive','Prefered path to distributive','Path to program configs',
                            'Path to user configs','Temporary files','Support files',
                            'Additional support files','Preload files',
                            'Fonts','Alternate font file','Templates',
                            'Default template','Current layout','Dictionaries',
                            'Device base'],
                              [FNUser]);
    ptsu^.SetAttrs(utd,[[fldaReadOnly],[],[fldaReadOnly],[fldaReadOnly],
                        [fldaReadOnly],[],[fldaReadOnly],[],[],[],[],[],[],[],[]
                        ]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(trd),'trd');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['RD_RendererBackEnd','RD_CurrentWAParam',
                            'RD_GLUVersion','RD_GLUExtensions',
                            'RD_LastRenderTime','RD_LastUpdateTime',
                            'RD_LastCalcVisible','RD_MaxRenderTime',
                            'RD_DrawInsidePaintMessage','RD_ImageDegradation',
                            'RD_PanObjectDegradation','RD_SpatialNodesDepth',
                            'RD_SpatialNodeCount','RD_MaxLTPatternsInEntity',
                            'RD_UseLazFreeTypeImplementation'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Graphic device','Current graphic device params',
                            'GLU Version','GLU Extensions',
                            'Last render time','Last update time',
                            'Last visible calculation time','Maximum single pass time',
                            'Draw inside paint message','Image degradation',
                            'Degradation while pan','Spatial index nodes depth',
                            'Spatial index ents in node','Max LT patterns in entity',
                            'Use LazFreeType engine instead FreeType'],
                            [FNUser]);
    ptsu^.SetAttrs(utd,[[],[],[fldaReadOnly],[fldaReadOnly],[fldaReadOnly],
                        [fldaReadOnly],[fldaReadOnly],[],[],[],[],[fldaHidden],
                        [fldaHidden],[],[]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tsave),'tsave');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['SAVE_Auto_On','SAVE_Auto_Current_Interval',
                            'SAVE_Auto_Interval','SAVE_Auto_FileName'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Autosave','Time to autosave',
                            'Time between autosaves','Autosave file name'],
                            [FNUser]);
    ptsu^.SetAttrs(utd,[[],[fldaReadOnly],[],[]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tsave),'tsave');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['SAVE_Auto_On','SAVE_Auto_Current_Interval',
                            'SAVE_Auto_Interval','SAVE_Auto_FileName'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Autosave','Time to autosave',
                            'Time between autosaves','Autosave file name'],
                            [FNUser]);
    ptsu^.SetAttrs(utd,[[],[fldaReadOnly],[],[]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tcompileinfo),'tcompileinfo');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['SYS_Compiler','SYS_CompilerVer',
                            'SYS_CompilerTargetCPU','SYS_CompilerTargetOS',
                            'SYS_CompileDate','SYS_CompileTime',
                            'SYS_LCLVersion','SYS_LCLFullVersion',
                            'SYS_EnvironmentVersion'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Compiler','Compiler version',
                            'Target CPU','Target OS',
                            'Compile date','Compile time',
                            'LCL version','LCL full version',
                            'Environment version'],
                            [FNUser]);
    ptsu^.SetAttrs(utd,[[fldaReadOnly],[fldaReadOnly],[fldaReadOnly],
                        [fldaReadOnly],[fldaReadOnly],[fldaReadOnly],
                        [fldaReadOnly],[fldaReadOnly],[fldaReadOnly]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tsys),'tsys');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['SYS_Version','SYS_CompileInfo',
                            'SYS_RunTime','SYS_UniqueInstance',
                            'SYS_NoSplash','SYS_NoLoadLayout',
                            'SYS_UpdatePO','SYS_MemProfiling',
                            'SYS_UseExperimentalFeatures'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Program version','Build info',
                            'Uptime','Unique instance',
                            'No splash screen','No load layout',
                            'Update PO file','Memory profiling',
                            'Use experimental features'],
                            [FNUser]);
    ptsu^.SetAttrs(utd,[[fldaReadOnly],[fldaReadOnly],[fldaReadOnly],
                        [],[],[fldaReadOnly],
                        [fldaReadOnly],[fldaReadOnly],[fldaReadOnly]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TSystemDWG),'TSystemDWG');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['SysDWG_CodePage'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['DWGCODEPAGE for new drawings'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tdwg),'tdwg');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['System','DWG_DXFCodePage',
                            'DWG_DrawMode','DWG_OSMode',
                            'DWG_PolarMode','DWG_CLayer',
                            'DWG_CLinew','DWG_CColor',
                            'DWG_LTScale','DWG_CLTScale',
                            'DWG_CLType','DWG_CDimStyle',
                            'DWG_RotateTextInLT','DWG_CTStyle',

                            'DWG_LUnits','DWG_LUPrec',
                            'DWG_AUnits','DWG_AUPrec',
                            'DWG_AngDir','DWG_AngBase',
                            'DWG_UnitMode','DWG_InsUnits',
                            'DWG_TextSize','DWG_Snap',
                            'DWG_GridSpacing','DWG_DrawGrid',
                            'DWG_SnapGrid','DWG_EditInSubEntry',
                            'DWG_AdditionalGrips','DWG_HelpGeometryDraw',
                            'DWG_SelectedObjToInsp','DWG_AlwaysUseMultiSelectWrapper'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['System drawing settings','DWGCODEPAGE for saving',
                            'Display line weights','Snap mode',
                            'Polar tracking mode','Current layer',
                            'Current line weight','Current color',
                            'Global line type scale','Current line type scale',
                            'Drawing line type','Dim style',
                            'Rotate text in line type','Text style',

                            'LUnits (linear units format)','LUPrec (linear units precision)',
                            'AUnits (angular units format)','AUPrec (angular units precision)',
                            'AngDir (direction of positive angles)','AngBase (zero base angle)',
                            'UnitMode (display format for units)','InsUnits (value for automatic scaling of blocks)',
                            'TextSize (size of new crreated text ents)','Snap settings',
                            'Grid spacing','Display grid',
                            'Snap','SubEntities edit',
                            'Additional grips','Help geometry',
                            'Selected object to inspector','Always use multiselect wrapper'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TLayerControls),'TLayerControls');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['DSGN_LC_Net','DSGN_LC_Cable','DSGN_LC_Leader'],
                           [FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Nets','Cables','Leaders'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tdesigning),'tdesigning');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['DSGN_LayerControls','DSGN_TraceAutoInc',
                            'DSGN_LeaderDefaultWidth','DSGN_HelpScale',
                            'DSGN_SelNew','DSGN_SelSameName',
                            'DSGN_MaxSelectEntsCountWithObjInsp','DSGN_MaxSelectEntsCountWithGrips',
                            'DSGN_OTrackTimerInterval','DSGN_EntityMoveStartTimerInterval',
                            'DSGN_EntityMoveStartOffset','DSGN_EntityMoveByMouseUp'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Layers control','Increment trace names',
                            'Default leader width','Scale of auxiliary elements',
                            'New selection set','Auto select devices with same name',
                            'Maximum selected entities to object inspector','Maximum selected entities with grips',
                            'Object track timer interval','DSGN_EntityMoveStartTimerInterval',
                            'DSGN_EntityMoveStartOffset','DSGN_EntityMoveByMouseUp'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tobjinspinterface),'tobjinspinterface');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['INTF_ObjInsp_ShowHeaders','INTF_ObjInsp_OldStyleDraw',
                            'INTF_ObjInsp_Level0HeaderColor','INTF_ObjInsp_BorderColor',
                            'INTF_ObjInsp_WhiteBackground','INTF_ObjInsp_ShowSeparator',
                            'INTF_ObjInsp_ShowFastEditors','INTF_ObjInsp_ShowOnlyHotFastEditors',
                            'INTF_ObjInsp_RowHeight','INTF_ObjInsp_SpaceHeight',
                            'INTF_ObjInsp_ShowEmptySections','INTF_ObjInsp_ButtonSizeReducing'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Show headers','Old style',
                            'Level0 header color','Border color',
                            'White background','Show separator',
                            'Show fast editors','Show only hot fast editors',
                            'Row height override','Space height',
                            'Show empty sections','Button size reducing'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tmessagesinterface),'Ttmessagesinterface');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['INTF_Messages_SuppressDoubles'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Suppress doubles'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tinterface),'tinterface');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['INTF_LanguageOverride','INTF_CommandLineEnabled',
                            'INTF_ShowScrollBars','INTF_ShowDwgTabs',
                            'INTF_DwgTabsPosition','INTF_ShowDwgTabCloseBurron',
                            'INTF_ThemedUpToolbars','INTF_ThemedRightToolbars',
                            'INTF_ThemedDownToolbars','INTF_ThemedLeftToolbars',
                            'INTF_DefaultControlHeight','INTF_DefaultEditorFontHeight',
                            'INTF_OBJINSP_Properties','INTF_MESSAGES_Properties',
                            'INTF_AppMode','INTF_ColorScheme'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Language override','Command line enabled',
                            'Show scroll bars','Show drawing tabs',
                            'Drawing tabs position','Show drawing tab close button',
                            'Themed up toolbars','Themed right toolbars',
                            'Themed down toolbars','Themed left toolbars',
                            'Default control height','Default editor font height',
                            'Object inspector properties','Messages properties',
                            'Application mode','Application color scheme'],[FNUser]);
    ptsu^.SetAttrs(utd,[[],[],[],[],[],[],[],[],[],[],[fldaReadOnly],[],[],[],
                        [],[]]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(tdisp),'tdisp');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['DISP_SystmGeometryDraw','DISP_SystmGeometryColor',
                            'DISP_ZoomFactor','DISP_OSSize',
                            'DISP_CursorSize','DISP_CrosshairSize',
                            'DISP_RemoveSystemCursorFromWorkArea','DISP_DrawZAxis',
                            'DISP_ColorAxis','DISP_GripSize',
                            'DISP_BackGroundColor','DISP_UnSelectedGripColor',
                            'DISP_SelectedGripColor','DISP_HotGripColor',
                            'DISP_LWDisplayScale','DISP_DefaultLW'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['System geometry','Help color',
                            'Mouse wheel scale factor','Snap aperture size',
                            'Cursor size','Crosshair size',
                            'Remove system cursor from work area','Show Z axis',
                            'Colored cursor','Grip size',
                            'Background color','Unselected grip color',
                            'Selected grip color','Hot grip color',
                            'Display line weight scale','Default line weight'],
                           [FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(gdbsysvariable),'gdbsysvariable');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['PATH','RD',
                            'DISP','SYS',
                            'SAVE','DWG',
                            'DSGN','debug',
                            'INTF'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Paths','Graphics',
                            'Display','System',
                            'Saving','Drawing',
                            'Design','Debug',
                            'Interface'],
                           [FNUser]);
    ptsu^.SetAttrs(utd,[[],[],[],[],[],[],[],[fldaHidden],[]]);
  end;
  utd:=ptsu^.RegisterType(TypeInfo(pgdbsysvariable),'pgdbsysvariable');

end;
end.

