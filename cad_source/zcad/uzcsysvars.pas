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

unit uzcsysvars;
{$INCLUDE def.inc}

interface
uses uzcsysparams,uzbtypesbase,uzbgeomtypes,uzepalette,
     uzedimensionaltypes,uzbtypes,uzctnrvectorgdbstring,
{$IFDEF LCLGTK2}
gtk2,gdk2,
{$ENDIF}
{$IFDEF LCLQT}
qtwidgets,qt4,qtint,
{$ENDIF}
{$IFDEF LCLQT5}
qtwidgets,qt5,qtint,
{$ENDIF}
{$IFNDEF DELPHI}LCLVersion{$ENDIF},sysutils;
type
{EXPORT+}
  tmemdeb=packed record
                GetMemCount,FreeMemCount:PGDBInteger;
                TotalAllocMb,CurrentAllocMB:PGDBInteger;
          end;
  trenderdeb=packed record
                   primcount,pointcount,bathcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tlanguadedeb=packed record
                   UpdatePO,NotEnlishWord,DebugWord:GDBInteger;
             end;

  tdebug=packed record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               languadedeb:tlanguadedeb;
               ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Show hidden fields'*)
               TestUnicodeString:UnicodeString;
        end;
  tpath=packed record
             Device_Library:PGDBString;(*'Device base'*)
             Support_Path:PGDBString;(*'Support files'*)
             Fonts_Path:PGDBString;(*'Fonts'*)
             Alternate_Font:PGDBString;(*'Alternate font file'*)
             Template_Path:PGDBString;(*'Templates'*)
             Template_File:PGDBString;(*'Default template'*)
             LayoutFile:PGDBString;(*'Current layout'*)
             Program_Run:PGDBString;(*'Program'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'Temporary files'*)(*oi_readonly*)
        end;
  PTCanvasData=^TCanvasData;
  TCanvasData=packed record
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
      end;
  trd=packed record
            RD_RendererBackEnd:PTEnumData;(*'Render backend'*)
            RD_CurrentWAParam:TFaceTypedData;
            RD_GLUVersion:PGDBString;(*'GLU Version'*)(*oi_readonly*)
            RD_GLUExtensions:PGDBString;(*'GLU Extensions'*)(*oi_readonly*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_LastCalcVisible:PGDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Maximum single pass time'*)
            RD_DrawInsidePaintMessage:PTGDB3StateBool;(*'Draw inside paint message'*)
            RD_RemoveSystemCursorFromWorkArea:PGDBBoolean;(*'Remove system cursor from work area'*)
            RD_Light:PGDBBoolean;(*'Light'*)
            RD_LineSmooth:PGDBBoolean;(*'Line smoothing'*)
            RD_ImageDegradation:TImageDegradation;(*'Image degradation'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Degradation while pan'*)
            RD_SpatialNodesDepth:PGDBInteger;(*'Spatial index nodes depth'*)(*hidden_in_objinsp*)
            RD_SpatialNodeCount:PGDBInteger;(*'Spatial index ents in node'*)(*hidden_in_objinsp*)
            RD_MaxLTPatternsInEntity:PGDBInteger;(*'Max LT patterns in entity'*)
      end;
  tsave=packed record
              SAVE_Auto_On:PGDBBoolean;(*'Autosave'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Time to autosave'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Time between autosaves'*)
              SAVE_Auto_FileName:PGDBString;(*'Autosave file name'*)
        end;
  tcompileinfo=packed record
                     SYS_Compiler:GDBString;(*'Compiler'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Compiler version'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Target CPU'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Target OS'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Compile date'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Compile time'*)(*oi_readonly*)
                     SYS_LCLVersion:GDBString;(*'LCL version'*)(*oi_readonly*)
                     SYS_LCLFullVersion:GDBString;(*'LCL full version'*)(*oi_readonly*)
                     SYS_EnvironmentVersion:GDBString;(*'Environment version'*)(*oi_readonly*)
               end;

  tsys=packed record
             SYS_Version:PGDBString;(*'Program version'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Build info'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Uptime'*)(*oi_readonly*)
             SYS_UniqueInstance:PGDBBoolean;(*'Unique instance'*)
             SYS_NoSplash:PGDBBoolean;(*'No splash screen'*)
             SYS_NoLoadLayout:PGDBBoolean;(*'No load layout'*)
             SYS_UpdatePO:PGDBBoolean;(*'Update PO file'*)

       end;
  tdwg=packed record
             DWG_DrawMode:PGDBBoolean;(*'Display line weights'*)
             DWG_OSMode:PTGDBOSMode;(*'Snap mode'*)
             DWG_PolarMode:PGDBBoolean;(*'Polar tracking mode'*)
             DWG_CLayer:{-}PGDBPointer{/PPGDBLayerPropObjInsp/};(*'Current layer'*)
             DWG_CLinew:PTGDBLineWeight;(*'Current line weigwt'*)
             DWG_CColor:PTGDBPaletteColor;(*'Current color'*)
             DWG_LTScale:PGDBDouble;(*'Global line type scale'*)
             DWG_CLTScale:PGDBDouble;(*'Current line type scale'*)
             DWG_CLType:{-}PGDBPointer{/PPGDBLtypePropObjInsp/};(*'Drawing line type'*)
             DWG_CDimStyle:{-}PGDBPointer{/PPGDBDimStyleObjInsp/};(*'Dim style'*)
             DWG_RotateTextInLT:PGDBBoolean;(*'Rotate text in line type'*)
             DWG_CTStyle:{-}PGDBPointer{/PPGDBTextStyleObjInsp/};(*'Text style'*)

             DWG_LUnits:PTLUnits;
             DWG_LUPrec:PTUPrec;
             DWG_AUnits:PTAUnits;
             DWG_AUPrec:PTUPrec;
             DWG_AngDir:PTAngDir;
             DWG_AngBase:PGDBAngleDegDouble;
             DWG_UnitMode:PTUnitMode;
             DWG_InsUnits:PTInsUnits;
             DWG_TextSize:PGDBDouble;

             DWG_EditInSubEntry:PGDBBoolean;(*'SubEntities edit'*)
             DWG_AdditionalGrips:PGDBBoolean;(*'Additional grips'*)
             DWG_HelpGeometryDraw:PGDBBoolean;(*'Help geometry'*)
             DWG_Snap:PGDBSnap2D;(*'Snap settings'*)
             DWG_GridSpacing:PGDBvertex2D;(*'Grid spacing'*)
             DWG_DrawGrid:PGDBBoolean;(*'Display grid'*)
             DWG_SnapGrid:PGDBBoolean;(*'Snap'*)
             DWG_SelectedObjToInsp:PGDBBoolean;(*'Selected object to inspector'*)
       end;
  TLayerControls=packed record
                       DSGN_LC_Net:PTLayerControl;(*'Nets'*)
                       DSGN_LC_Cable:PTLayerControl;(*'Cables'*)
                       DSGN_LC_Leader:PTLayerControl;(*'Leaders'*)
                 end;

  tdesigning=packed record
             DSGN_LayerControls:TLayerControls;(*'Control layers'*)
             DSGN_TraceAutoInc:PGDBBoolean;(*'Increment trace names'*)
             DSGN_LeaderDefaultWidth:PGDBDouble;(*'Default leader width'*)
             DSGN_HelpScale:PGDBDouble;(*'Scale of auxiliary elements'*)
             DSGN_SelNew:PGDBBoolean;(*'New selection set'*)
             DSGN_SelSameName:PGDBBoolean;(*'Auto select devices with same name'*)
             DSGN_OTrackTimerInterval:PGDBInteger;(*'Object track timer interval'*)
       end;
  tobjinspinterface=packed record
                INTF_ObjInsp_ShowHeaders:PGDBBoolean;(*'Show headers'*)
                INTF_ObjInsp_OldStyleDraw:PGDBBoolean;(*'Old style'*)
                INTF_ObjInsp_WhiteBackground:PGDBBoolean;(*'White background'*)
                INTF_ObjInsp_ShowSeparator:PGDBBoolean;(*'Show separator'*)
                INTF_ObjInsp_ShowFastEditors:PGDBBoolean;(*'Show fast editors'*)
                INTF_ObjInsp_ShowOnlyHotFastEditors:PGDBBoolean;(*'Show only hot fast editors'*)
                INTF_ObjInsp_RowHeight:PTGDBIntegerOverrider;(*'Row height'*)
                INTF_ObjInsp_SpaceHeight:PGDBInteger;(*'Space height'*)
                INTF_ObjInsp_AlwaysUseMultiSelectWrapper:PGDBBoolean;(*'Always use multiselect wrapper'*)
                INTF_ObjInsp_ShowEmptySections:PGDBBoolean;(*'Show empty sections'*)
                INTF_ObjInsp_ButtonSizeReducing:PGDBInteger;(*'Button size reducing'*)
               end;
  tinterface=packed record
              INTF_CommandLineEnabled:PGDBBoolean;(*'Command line enabled'*)
              INTF_ShowScrollBars:PGDBBoolean;(*'Show scroll bars'*)
              INTF_ShowDwgTabs:PGDBBoolean;(*'Show drawing tabs'*)
              INTF_DwgTabsPosition:PTAlign;(*'Drawing tabs position'*)
              INTF_ShowDwgTabCloseBurron:PGDBBoolean;(*'Show drawing tab close button'*)
              INTF_ThemedUpToolbars:PGDBBoolean;(*'Themed up toolbars'*)
              INTF_ThemedRightToolbars:PGDBBoolean;(*'Themed right toolbars'*)
              INTF_ThemedDownToolbars:PGDBBoolean;(*'Themed down toolbars'*)
              INTF_ThemedLeftToolbars:PGDBBoolean;(*'Themed left toolbars'*)
              INTF_DefaultControlHeight:PGDBInteger;(*'Default control height'*)(*oi_readonly*)
              INTF_DefaultEditorFontHeight:PGDBInteger;(*'Default editor font height'*)
              INTF_OBJINSP_Properties:tobjinspinterface;(*'Object inspector properties'*)
             end;
  tdisp=packed record
             DISP_SystmGeometryDraw:PGDBBoolean;(*'System geometry'*)
             DISP_SystmGeometryColor:PTGDBPaletteColor;(*'Help color'*)
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
             DISP_GripSize:PGDBInteger;(*'Grip size'*)
             DISP_BackGroundColor:PTRGB;(*'Background color'*)
             DISP_UnSelectedGripColor:PTGDBPaletteColor;(*'Unselected grip color'*)
             DISP_SelectedGripColor:PTGDBPaletteColor;(*'Selected grip color'*)
             DISP_HotGripColor:PTGDBPaletteColor;(*'Hot grip color'*)
             DISP_LWDisplayScale:PGDBInteger;(*'LWDisplayScale'*)
             DISP_DefaultLW:PTGDBLineWeight;(*'DefaultLW'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=packed record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Render'*)
    DISP:tdisp;(*'Display'*)
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    INTF:tinterface;(*'Interface'*)
    debug:tdebug;(*'Debug'*)
  end;
{EXPORT-}
var
  sysvar: gdbsysvariable;
implementation
begin
  {$IFNDEF DELPHI}

    SysVar.SYS.SSY_CompileInfo.SYS_Compiler:='Free Pascal Compiler (FPC)';
    SysVar.SYS.SSY_CompileInfo.SYS_CompilerVer:={$I %FPCVERSION%};
    SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU:={$I %FPCTARGETCPU%};
    SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS:={$I %FPCTARGETOS%};
    SysVar.SYS.SSY_CompileInfo.SYS_CompileDate:={$I %DATE%};
    SysVar.SYS.SSY_CompileInfo.SYS_CompileTime:={$I %TIME%};
    SysVar.SYS.SSY_CompileInfo.SYS_LCLVersion:=lcl_version;
    SysVar.SYS.SSY_CompileInfo.SYS_LCLFullVersion:=inttostr(lcl_fullversion);
    {$IFDEF LCLWIN32}
       SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:='Windows ';
       if Win32CSDVersion<>'' then
                                  SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:=SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion+inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber)+' '+Win32CSDVersion
                              else
                                  SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:=SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion+inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber);
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
    //SysVar.debug.TestUnicodeString:=UTF8ToString('test ゔ&#12436');
    SysVar.debug.TestUnicodeString:=UTF8ToString('你好来自俄罗斯');
    sysvar.RD.RD_RendererBackEnd:=nil;
end.

