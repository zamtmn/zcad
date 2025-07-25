unit sysvar;
interface
uses System;
var
  ShowHiddenFieldInObjInsp:Boolean;
  INTF_ObjInsp_WhiteBackground:TGetterSetterBoolean;
  INTF_ObjInsp_ShowHeaders:TGetterSetterBoolean;
  INTF_ObjInsp_ShowSeparator:TGetterSetterBoolean;
  INTF_ObjInsp_OldStyleDraw:TGetterSetterBoolean;
  INTF_ObjInsp_ShowFastEditors:TGetterSetterBoolean;
  INTF_ObjInsp_ShowOnlyHotFastEditors:TGetterSetterBoolean;
  INTF_ObjInsp_RowHeight_OverriderEnable:TGetterSetterBoolean;
  INTF_ObjInsp_RowHeight_OverriderValue:TGetterSetterInteger;
  INTF_ObjInsp_SpaceHeight:TGetterSetterInteger;
  INTF_ObjInsp_ShowEmptySections:TGetterSetterBoolean;
  INTF_ObjInsp_ButtonSizeReducing:TGetterSetterInteger;
  DISP_CursorSize:Integer;
  DISP_OSSize:Double;
  DISP_CrosshairSize:Double;
  DISP_BackGroundColor:TRGB;
  RD_MaxRenderTime:Integer;
  DISP_ZoomFactor:Double;
  DISP_SystmGeometryDraw:Boolean;
  DISP_SystmGeometryDraw:Boolean;
  DISP_SystmGeometryColor:TGDBPaletteColor;
  DISP_HotGripColor:TGDBPaletteColor;
  DISP_SelectedGripColor:TGDBPaletteColor;
  DISP_UnSelectedGripColor:TGDBPaletteColor;
  DWG_OSMode:TGDBOSMode;
  DWG_OSModeControl:Boolean;
  DISP_GripSize:Integer;
  DISP_ColorAxis:Boolean;
  DISP_DrawZAxis:Boolean;
  RD_DrawInsidePaintMessage:TGDB3StateBool;
  DWG_PolarMode:Boolean;
  RD_LineSmooth:Boolean;
  RD_UseStencil:Boolean;
  RD_LastRenderTime:Integer;
  RD_LastUpdateTime:Integer;
  RD_ID_Enabled:Boolean;
  RD_ID_PrefferedRenderTime:Integer;
  RD_ID_MaxDegradationFactor:Double;
  RD_UseLazFreeTypeImplementation:Boolean;
  DISP_RemoveSystemCursorFromWorkArea:Boolean;
  DSGN_SelNew:Boolean;
  DWG_EditInSubEntry:Boolean;
  RD_SpatialNodeCount:Integer;
  RD_SpatialNodesDepth:Integer;
  DWG_RotateTextInLT:Boolean;
  RD_MaxLTPatternsInEntity:Integer;
  RD_PanObjectDegradation:Boolean;
  DSGN_OTrackTimerInterval:Integer;
  DISP_LWDisplayScale:Integer;
  RD_Light:Boolean;
  PATH_Preload_Path:String;
  PATH_Fonts:String;
  PATH_AlternateFont:String;
  PATH_Support_Path:String;
  INTF_CommandLineEnabled:Boolean;
  DSGN_NavigatorsUseMainFunction:Boolean;
  INTF_ObjInspButtonSizeReducing:Integer;
  DWG_HelpGeometryDraw:Boolean;
  DWG_AdditionalGrips:Boolean;
  DWG_SelectedObjToInsp:Boolean;
  DSGN_TraceAutoInc:Boolean;
  DSGN_LeaderDefaultWidth:Double;
  DSGN_HelpScale:Double;
  DSGN_LCNet:TLayerControl;
  DSGN_LCCable:TLayerControl;
  DSGN_LCLeader:TLayerControl;
  DSGN_SelSameName:Boolean;
  DSGN_MaxSelectEntsCountWithObjInsp:Integer;
  DSGN_MaxSelectEntsCountWithGrips:Integer;
  INTF_ShowScrollBars:Boolean;
  INTF_ShowDwgTabs:Boolean;
  INTF_DwgTabsPosition:TAlign;
  INTF_ShowDwgTabCloseBurron:Boolean;
  INTF_DefaultControlHeight:Integer;
  DWG_AlwaysUseMultiSelectWrapper:Boolean;
  INTF_DefaultEditorFontHeight:Integer;
  INTF_ThemedUpToolbars:Boolean;
  INTF_ThemedRightToolbars:Boolean;
  INTF_ThemedDownToolbars:Boolean;
  INTF_ThemedLeftToolbars:Boolean;
  INTF_AppMode:TAppMode;
  INTF_ColorScheme:String;
  INTF_MessagesSuppressDoubles:TGDB3StateBool;
  RD_Vendor:String;
  RD_Renderer:String;
  RD_Extensions:String;
  RD_Version:String;
  RD_Restore_Mode:TRestoreMode;
  RD_VSync:TGDB3StateBool;
  SAVE_Auto_Interval:Integer;
  SAVE_Auto_Current_Interval:Integer;
  SAVE_Auto_FileName:String;
  SAVE_Auto_On:Boolean;
  SYS_RunTime:Integer;
  SYS_Version:String;
  PATH_Device_Library:String;
  PATH_Template_Path:String;
  PATH_Template_File:String;
  PATH_LayoutFile:String;
implementation
begin
  ShowHiddenFieldInObjInsp:=False;
  INTF_ObjInsp_WhiteBackground:=False;
  INTF_ObjInsp_ShowHeaders:=True;
  INTF_ObjInsp_ShowSeparator:=True;
  INTF_ObjInsp_OldStyleDraw:=False;
  INTF_ObjInsp_ShowFastEditors:=True;
  INTF_ObjInsp_ShowOnlyHotFastEditors:=False;
  INTF_ObjInsp_RowHeight_OverriderEnable:=False;
  INTF_ObjInsp_RowHeight_OverriderValue:=21;
  INTF_ObjInsp_SpaceHeight:=3;
  INTF_ObjInsp_ShowEmptySections:=False;
  INTF_ObjInsp_ButtonSizeReducing:=4;
  DISP_CursorSize:=6;
  DISP_OSSize:=10;
  DISP_CrosshairSize:=0.05;
  DISP_BackGroundColor.r:=0;
  DISP_BackGroundColor.g:=0;
  DISP_BackGroundColor.b:=0;
  DISP_BackGroundColor.a:=255;
  RD_MaxRenderTime:=0;
  DISP_ZoomFactor:=1.624;
  DISP_SystmGeometryDraw:=False;
  DISP_SystmGeometryDraw:=False;
  DISP_SystmGeometryColor:=250;
  DISP_HotGripColor:=11;
  DISP_SelectedGripColor:=12;
  DISP_UnSelectedGripColor:=150;
  DWG_OSMode:=14311;
  DWG_OSModeControl:=True;
  DISP_GripSize:=10;
  DISP_ColorAxis:=False;
  DISP_DrawZAxis:=False;
  RD_DrawInsidePaintMessage:=T3SB_Default;
  DWG_PolarMode:=True;
  RD_LineSmooth:=False;
  RD_UseStencil:=False;
  RD_LastRenderTime:=0;
  RD_LastUpdateTime:=0;
  RD_ID_Enabled:=False;
  RD_ID_PrefferedRenderTime:=20;
  RD_ID_MaxDegradationFactor:=0;
  RD_UseLazFreeTypeImplementation:=False;
  DISP_RemoveSystemCursorFromWorkArea:=True;
  DSGN_SelNew:=False;
  DWG_EditInSubEntry:=False;
  RD_SpatialNodeCount:=8;
  RD_SpatialNodesDepth:=10;
  DWG_RotateTextInLT:=True;
  RD_MaxLTPatternsInEntity:=10000;
  RD_PanObjectDegradation:=False;
  DSGN_OTrackTimerInterval:=500;
  DISP_LWDisplayScale:=10;
  RD_Light:=False;
  PATH_Preload_Path:='$(DistribPath)/preload;$(UserDir)/zcad/preload;$(LocalConfigDir)/$(AppName)/preload;$(GlobalConfigDir)/$(AppName)/preload';
  PATH_Fonts:='$(SystemFontsPath);$(UserFontsPath);$(DistribPath)/fonts;C:/APPS/MY/acad/support;C:/Program Files/Autodesk/AutoCAD 2022/Fonts';
  PATH_AlternateFont:='_mipGost.shx';
  PATH_Support_Path:='$(DistribPath)/rtl;$(DistribPath)/rtl/objdefunits;$(DistribPath)/rtl/objdefunits/include;$DataSearhPrefixes(components);$(DistribPath)/blocks/el/general;$(DistribPath)/blocks/el/general/velecdevice';
  INTF_CommandLineEnabled:=True;
  DSGN_NavigatorsUseMainFunction:=True;
  INTF_ObjInspButtonSizeReducing:=4;
  DWG_HelpGeometryDraw:=True;
  DWG_AdditionalGrips:=False;
  DWG_SelectedObjToInsp:=True;
  DSGN_TraceAutoInc:=False;
  DSGN_LeaderDefaultWidth:=10;
  DSGN_HelpScale:=1;
  DSGN_LCNet.Enabled:=True;
  DSGN_LCNet.LayerName:='DEFPOINTS';
  DSGN_LCCable.Enabled:=True;
  DSGN_LCCable.LayerName:='EL_KABLE';
  DSGN_LCLeader.Enabled:=True;
  DSGN_LCLeader.LayerName:='TEXT';
  DSGN_SelSameName:=False;
  DSGN_MaxSelectEntsCountWithObjInsp:=25000;
  DSGN_MaxSelectEntsCountWithGrips:=100;
  INTF_ShowScrollBars:=True;
  INTF_ShowDwgTabs:=True;
  INTF_DwgTabsPosition:=TATop;
  INTF_ShowDwgTabCloseBurron:=True;
  INTF_DefaultControlHeight:=33;
  DWG_AlwaysUseMultiSelectWrapper:=True;
  INTF_DefaultEditorFontHeight:=0;
  INTF_ThemedUpToolbars:=False;
  INTF_ThemedRightToolbars:=False;
  INTF_ThemedDownToolbars:=False;
  INTF_ThemedLeftToolbars:=False;
  INTF_AppMode:=TAMAllowDark;
  INTF_ColorScheme:='Dark';
  INTF_MessagesSuppressDoubles:=T3SB_Default;
  RD_Vendor:='';
  RD_Renderer:='';
  RD_Extensions:='';
  RD_Version:='';
  RD_Restore_Mode:=WND_Texture;
  RD_VSync:=T3SB_Fale;
  SAVE_Auto_Interval:=300;
  SAVE_Auto_Current_Interval:=300;
  SAVE_Auto_FileName:='$(CurrentDrawingPath)/$(CurrentDrawingFileNameOnly)_autosave.dxf';
  SAVE_Auto_On:=True;
  SYS_RunTime:=0;
  SYS_Version:='';
  PATH_Device_Library:='$(DistribPath)/programdb;$(UserDir)/zcad/userdb';
  PATH_Template_Path:='$(DistribPath)/templates';
  PATH_Template_File:='minimal.dxf';
  PATH_LayoutFile:='defaultlayout.xml';
end.