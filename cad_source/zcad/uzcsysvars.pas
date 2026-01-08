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

unit uzcsysvars;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzbUnits,
  uzcsysparams,uzegeometrytypes,uzepalette,
  uzbtypes,uzeTypes,uzcTypes,uzctnrvectorstrings,varmandef,
{$IFDEF LCLGTK2}
gtk2,gdk2,
{$ENDIF}
{$IFDEF LCLQT}
qtwidgets,qt4,qtint,
{$ENDIF}
{$IFDEF LCLQT5}
qtwidgets,qt5,qtint,
{$ENDIF}
{$IFNDEF DELPHI}LCLVersion{$ENDIF},sysutils,
  uzestyleslayers,uzeStylesLineTypes,uzestylesdim,uzestylestexts,uzbUsable;
type

  tlanguadedeb=record
    UpdatePO,NotEnlishWord,DebugWord:integer;
  end;

  tdebug=record
    languadedeb:tlanguadedeb;
    ShowHiddenFieldInObjInsp:PBoolean;(*'Show hidden fields'*)
  end;

  tpath=record
    Distrib_Path:TFString;(*'Path to program distributive'*)(*oi_readonly*)
    PreferedDistrib_Path:PString;(*'Prefered path to distributive'*)
    RoCfg_Path:TFString;(*'Path to program configs'*)(*oi_readonly*)
    WrCfg_Path:TFString;(*'Path to user configs'*)(*oi_readonly*)
    Temp_Path:TFString;(*'Temporary files'*)(*oi_readonly*)
    Support_Paths:PString;(*'Support files'*)
    AdditionalSupport_Paths:TFString;(*'Additional support files'*)(*oi_readonly*)
    Preload_Paths:PString;(*'Preload files'*)
    Fonts_Paths:PString;(*'Fonts'*)
    Alternate_Font:PString;(*'Alternate font file'*)
    Template_Path:PString;(*'Templates'*)
    Template_File:PString;(*'Default template'*)
    LayoutFile:PString;(*'Current layout'*)
    Dictionaries:PString;(*'Dictionaries'*)
    Device_Library:PString;(*'Device base'*)
  end;

  trd=record
    RD_RendererBackEnd:PTEnumData;(*'Graphic device'*)
    RD_CurrentWAParam:THardTypedData;(*'Current graphic device params'*)
    RD_GLUVersion:PString;(*'GLU Version'*)(*oi_readonly*)
    RD_GLUExtensions:PString;(*'GLU Extensions'*)(*oi_readonly*)
    RD_LastRenderTime:PInteger;(*'Last render time'*)(*oi_readonly*)
    RD_LastUpdateTime:PInteger;(*'Last update time'*)(*oi_readonly*)
    RD_LastCalcVisible:PInteger;(*'Last visible calculation time'*)(*oi_readonly*)
    RD_MaxRenderTime:PInteger;(*'Maximum single pass time'*)
    RD_DrawInsidePaintMessage:PTGDB3StateBool;(*'Draw inside paint message'*)
    RD_ImageDegradation:TImageDegradation;(*'Image degradation'*)
    RD_PanObjectDegradation:PBoolean;(*'Degradation while pan'*)
    RD_SpatialNodesDepth:PInteger;(*'Spatial index nodes depth'*)(*hidden_in_objinsp*)
    RD_SpatialNodeCount:PInteger;(*'Spatial index ents in node'*)(*hidden_in_objinsp*)
    RD_MaxLTPatternsInEntity:PInteger;(*'Max LT patterns in entity'*)
    RD_UseLazFreeTypeImplementation:PBoolean;(*'Use LazFreeType engine instead FreeType'*)
  end;

  tsave=record
    SAVE_Auto_On:PBoolean;(*'Autosave'*)
    SAVE_Auto_Current_Interval:PInteger;(*'Time to autosave'*)(*oi_readonly*)
    SAVE_Auto_Interval:PInteger;(*'Time between autosaves'*)
    SAVE_Auto_FileName:PString;(*'Autosave file name'*)
  end;

  tcompileinfo=record
    SYS_Compiler:string;(*'Compiler'*)(*oi_readonly*)
    SYS_CompilerVer:string;(*'Compiler version'*)(*oi_readonly*)
    SYS_CompilerTargetCPU:string;(*'Target CPU'*)(*oi_readonly*)
    SYS_CompilerTargetOS:string;(*'Target OS'*)(*oi_readonly*)
    SYS_CompileDate:string;(*'Compile date'*)(*oi_readonly*)
    SYS_CompileTime:string;(*'Compile time'*)(*oi_readonly*)
    SYS_LCLVersion:string;(*'LCL version'*)(*oi_readonly*)
    SYS_LCLFullVersion:string;(*'LCL full version'*)(*oi_readonly*)
    SYS_EnvironmentVersion:string;(*'Environment version'*)(*oi_readonly*)
  end;

  tsys=record
    SYS_Version:PString;(*'Program version'*)(*oi_readonly*)
    SYS_CompileInfo:tcompileinfo;(*'Build info'*)(*oi_readonly*)
    SYS_RunTime:PInteger;(*'Uptime'*)(*oi_readonly*)
    SYS_UniqueInstance:PBoolean;(*'Unique instance'*)
    SYS_NoSplash:PBoolean;(*'No splash screen'*)
    SYS_NoLoadLayout:PBoolean;(*'No load layout'*)(*oi_readonly*)
    SYS_UpdatePO:PBoolean;(*'Update PO file'*)(*oi_readonly*)
    SYS_MemProfiling:PBoolean;(*'Memory profiling'*)(*oi_readonly*)
    SYS_UseExperimentalFeatures:PBoolean;
    (*'Use experimental features'*)(*oi_readonly*)
  end;

  TSystemDWG=record
    SysDWG_CodePage:PTZCCodePage;(*'DWGCODEPAGE for new drawings'*)
  end;

  tdwg=record
    System:TSystemDWG;(*'System drawing settings'*)
    DWG_DXFCodePage:PTZCCodePage;(*'DWGCODEPAGE for saving'*)
    DWG_DrawMode:PBoolean;(*'Display line weights'*)
    DWG_OSMode:PTGDBOSMode;(*'Snap mode'*)
    DWG_PolarMode:PBoolean;(*'Polar tracking mode'*)
    DWG_CLayer:PPGDBLayerPropObjInsp;(*'Current layer'*)
    DWG_CLinew:PTGDBLineWeight;(*'Current line weight'*)
    DWG_CColor:PTGDBPaletteColor;(*'Current color'*)
    DWG_LTScale:PDouble;(*'Global line type scale'*)
    DWG_CLTScale:PDouble;(*'Current line type scale'*)
    DWG_CLType:PPGDBLtypePropObjInsp;(*'Drawing line type'*)
    DWG_CDimStyle:PPGDBDimStyleObjInsp;(*'Dim style'*)
    DWG_RotateTextInLT:PBoolean;(*'Rotate text in line type'*)
    DWG_CTStyle:PPGDBTextStyleObjInsp;(*'Text style'*)

    DWG_LUnits:PTLUnits;(*'LUnits (linear units format)'*)
    DWG_LUPrec:PTUPrec;(*'LUPrec (linear units precision)'*)
    DWG_AUnits:PTAUnits;(*'AUnits (angular units format)'*)
    DWG_AUPrec:PTUPrec;(*'AUPrec (angular units precision)'*)
    DWG_AngDir:PTAngDir;(*'AngDir (direction of positive angles)'*)
    DWG_AngBase:PTZeAngleDeg;(*'AngBase (zero base angle)'*)
    DWG_UnitMode:PTUnitMode;(*'UnitMode (display format for units)'*)
    DWG_InsUnits:PTInsUnits;(*'InsUnits (value for automatic scaling of blocks)'*)
    DWG_TextSize:PDouble;(*'TextSize (size of new crreated text ents)'*)
    DWG_Snap:PGDBSnap2D;(*'Snap settings'*)
    DWG_GridSpacing:PzePoint2d;(*'Grid spacing'*)
    DWG_DrawGrid:PBoolean;(*'Display grid'*)
    DWG_SnapGrid:PBoolean;(*'Snap'*)

    DWG_EditInSubEntry:PBoolean;(*'SubEntities edit'*)
    DWG_AdditionalGrips:PBoolean;(*'Additional grips'*)
    DWG_HelpGeometryDraw:PBoolean;(*'Help geometry'*)
    DWG_SelectedObjToInsp:PBoolean;(*'Selected object to inspector'*)
    DWG_AlwaysUseMultiSelectWrapper:PBoolean;(*'Always use multiselect wrapper'*)
  end;

  TLayerControls=record
    DSGN_LC_Net:PTLayerControl;(*'Nets'*)
    DSGN_LC_Cable:PTLayerControl;(*'Cables'*)
    DSGN_LC_Leader:PTLayerControl;(*'Leaders'*)
  end;

  tdesigning=record
    DSGN_LayerControls:TLayerControls;(*'Control layers'*)
    DSGN_TraceAutoInc:PBoolean;(*'Increment trace names'*)
    DSGN_LeaderDefaultWidth:PDouble;(*'Default leader width'*)
    DSGN_HelpScale:PDouble;(*'Scale of auxiliary elements'*)
    DSGN_SelNew:PBoolean;(*'New selection set'*)
    DSGN_SelSameName:PBoolean;(*'Auto select devices with same name'*)
    DSGN_MaxSelectEntsCountWithObjInsp:PInteger;(*'Maximum selected entities to object inspector'*)
    DSGN_MaxSelectEntsCountWithGrips:PInteger;(*'Maximum selected entities with grips'*)
    DSGN_OTrackTimerInterval:PInteger;(*'Object track timer interval'*)
    DSGN_EntityMoveStartTimerInterval:PInteger;
    DSGN_EntityMoveStartOffset:PInteger;
    DSGN_EntityMoveByMouseUp:PBoolean;
  end;

  tobjinspinterface=record
    INTF_ObjInsp_ShowHeaders:TGetterSetterBoolean;(*'Show headers'*)
    INTF_ObjInsp_OldStyleDraw:TGetterSetterBoolean;(*'Old style'*)
    INTF_ObjInsp_Level0HeaderColor:TGetterSetterTColor;(*'Level0 header color'*)
    INTF_ObjInsp_BorderColor:TGetterSetterTColor;(*'Border color'*)
    INTF_ObjInsp_WhiteBackground:TGetterSetterBoolean;(*'White background'*)
    INTF_ObjInsp_ShowSeparator:TGetterSetterBoolean;(*'Show separator'*)
    INTF_ObjInsp_ShowFastEditors:TGetterSetterBoolean;(*'Show fast editors'*)
    INTF_ObjInsp_ShowOnlyHotFastEditors:TGetterSetterBoolean;(*'Show only hot fast editors'*)
    INTF_ObjInsp_RowHeight:TGetterSetterTUsableInteger;(*'Row height override'*)
    INTF_ObjInsp_SpaceHeight:TGetterSetterInteger;(*'Space height'*)
    INTF_ObjInsp_ShowEmptySections:TGetterSetterBoolean;(*'Show empty sections'*)
    INTF_ObjInsp_ButtonSizeReducing:TGetterSetterInteger;(*'Button size reducing'*)
  end;

  tmessagesinterface=record
    INTF_Messages_SuppressDoubles:PTGDB3StateBool;(*'Suppress doubles'*)
  end;

  tinterface=record
    INTF_LanguageOverride:PString;(*'Language override'*)
    INTF_CommandLineEnabled:PBoolean;(*'Command line enabled'*)
    INTF_ShowScrollBars:PBoolean;(*'Show scroll bars'*)
    INTF_ShowDwgTabs:PBoolean;(*'Show drawing tabs'*)
    INTF_DwgTabsPosition:PTAlign;(*'Drawing tabs position'*)
    INTF_ShowDwgTabCloseBurron:PBoolean;(*'Show drawing tab close button'*)
    INTF_ThemedUpToolbars:PBoolean;(*'Themed up toolbars'*)
    INTF_ThemedRightToolbars:PBoolean;(*'Themed right toolbars'*)
    INTF_ThemedDownToolbars:PBoolean;(*'Themed down toolbars'*)
    INTF_ThemedLeftToolbars:PBoolean;(*'Themed left toolbars'*)
    INTF_DefaultControlHeight:PInteger;(*'Default control height'*)(*oi_readonly*)
    INTF_DefaultEditorFontHeight:PInteger;(*'Default editor font height'*)
    INTF_OBJINSP_Properties:tobjinspinterface;(*'Object inspector properties'*)
    INTF_MESSAGES_Properties:tmessagesinterface;(*'Messages properties'*)
    INTF_AppMode:PTAppMode;(*'Application mode'*)
    INTF_ColorScheme:PString;(*'Application color scheme'*)
  end;

  tdisp=record
    DISP_SystmGeometryDraw:PBoolean;(*'System geometry'*)
    DISP_SystmGeometryColor:PTGDBPaletteColor;(*'Help color'*)
    DISP_ZoomFactor:PDouble;(*'Mouse wheel scale factor'*)
    DISP_OSSize:PDouble;(*'Snap aperture size'*)
    DISP_CursorSize:PInteger;(*'Cursor size'*)
    DISP_CrosshairSize:PDouble;(*'Crosshair size'*)
    DISP_RemoveSystemCursorFromWorkArea:PBoolean;(*'Remove system cursor from work area'*)
    DISP_DrawZAxis:PBoolean;(*'Show Z axis'*)
    DISP_ColorAxis:PBoolean;(*'Colored cursor'*)
    DISP_GripSize:PInteger;(*'Grip size'*)
    DISP_BackGroundColor:PTRGB;(*'Background color'*)
    DISP_UnSelectedGripColor:PTGDBPaletteColor;(*'Unselected grip color'*)
    DISP_SelectedGripColor:PTGDBPaletteColor;(*'Selected grip color'*)
    DISP_HotGripColor:PTGDBPaletteColor;(*'Hot grip color'*)
    DISP_LWDisplayScale:PInteger;(*'Display line weight scale'*)
    DISP_DefaultLW:PTGDBLineWeight;(*'Default line weight'*)
  end;

  gdbsysvariable=record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Graphics'*)
    DISP:tdisp;(*'Display'*)
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    debug:tdebug;(*'Debug'*)(*hidden_in_objinsp*)
    INTF:tinterface;(*'Interface'*)
  end;
  pgdbsysvariable=^gdbsysvariable;



var
  sysvar: gdbsysvariable;
  testvar: tlanguadedeb;
implementation
begin
  {$IFNDEF DELPHI}

    SysVar.SYS.SYS_CompileInfo.SYS_Compiler:='Free Pascal Compiler (FPC)';
    SysVar.SYS.SYS_CompileInfo.SYS_CompilerVer:={$I %FPCVERSION%};
    SysVar.SYS.SYS_CompileInfo.SYS_CompilerTargetCPU:={$I %FPCTARGETCPU%};
    SysVar.SYS.SYS_CompileInfo.SYS_CompilerTargetOS:={$I %FPCTARGETOS%};
    SysVar.SYS.SYS_CompileInfo.SYS_CompileDate:={$I %DATE%};
    SysVar.SYS.SYS_CompileInfo.SYS_CompileTime:={$I %TIME%};
    SysVar.SYS.SYS_CompileInfo.SYS_LCLVersion:=lcl_version;
    SysVar.SYS.SYS_CompileInfo.SYS_LCLFullVersion:=inttostr(lcl_fullversion);
    {$IFDEF LCLWIN32}
       SysVar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion:='Windows ';
       if Win32CSDVersion<>'' then
                                  SysVar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion:=SysVar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion+inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber)+' '+Win32CSDVersion
                              else
                                  SysVar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion:=SysVar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion+inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber);
    {$ENDIF}
    {$IFDEF LCLQt}
       SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:='Qt'+inttostr(QtVersionMajor)+'.'+inttostr(QtVersionMinor)+'.'+inttostr(QtVersionMicro);
    {$ENDIF}
    {$IFDEF LCLQt5}
       SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:='Qt'+inttostr(QtVersionMajor)+'.'+inttostr(QtVersionMinor)+'.'+inttostr(QtVersionMicro);
    {$ENDIF}
    {$IFDEF LCLGTK2}
       SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:='GTK+'+inttostr(gtk_major_version)+'.'+inttostr(gtk_minor_version)+'.'+inttostr(gtk_micro_version);
    {$ENDIF}

  {$ENDIF}
    SysVar.debug.languadedeb.NotEnlishWord:=0;
    SysVar.debug.languadedeb.UpdatePO:=0;
    sysvar.RD.RD_RendererBackEnd:=nil;
end.

