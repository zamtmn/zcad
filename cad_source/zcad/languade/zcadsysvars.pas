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

unit zcadsysvars;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbpalette,
     gdbase,UGDBStringArray
{$IFDEF LCLGTK2}
gtk2,gdk2,
{$ENDIF}
{$IFDEF LCLQT}
qtwidgets,qt4,qtint,
{$ENDIF}
{$IFNDEF DELPHI},LCLVersion{$ENDIF},sysutils;
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
        end;
  tpath=packed record
             Device_Library:PGDBString;(*'Device base'*)
             Support_Path:PGDBString;(*'Support files'*)
             Fonts_Path:PGDBString;(*'Fonts'*)
             Template_Path:PGDBString;(*'Templates'*)
             Template_File:PGDBString;(*'Default template'*)
             LayoutFile:PGDBString;(*'Current layout'*)
             Program_Run:PGDBString;(*'Program'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'Temporary files'*)(*oi_readonly*)
        end;
  ptrestoremode=^trestoremode;
  TRestoreMode=(
                WND_AuxBuffer(*'AUX buffer'*),
                WND_AccumBuffer(*'ACCUM buffer'*),
                WND_DrawPixels(*'Memory'*),
                WND_NewDraw(*'Redraw'*),
                WND_Texture(*'Texture'*)
               );
  TImageDegradation=packed record
                          RD_ID_Enabled:PGDBBoolean;(*'Enabled'*)
                          RD_ID_CurrentDegradationFactor:GDBDouble;(*'Current degradation factor'*)(*oi_readonly*)
                          RD_ID_MaxDegradationFactor:PGDBDouble;(*'Max degradation factor'*)
                          RD_ID_PrefferedRenderTime:PGDBInteger;(*'Prefered rendertime'*)
                      end;
  TTextRenderingType=(TRT_System,TRT_ZGL,TRT_Both);
  PTCanvasData=^TCanvasData;
  TCanvasData=packed record
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
      end;
  TGDIPrimitivesCounter=packed record
            Lines:GDBInteger;
            Triangles:GDBInteger;
            Quads:GDBInteger;
            Points:GDBInteger;
            ZGLSymbols:GDBInteger;
            SystemSymbols:GDBInteger;
      end;
  PTGDIData=^TGDIData;
  TGDIData=packed record
            RD_TextRendering:TTextRenderingType;
            RD_DrawDebugGeometry:GDBBoolean;
            DebugCounter:TGDIPrimitivesCounter;
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:GDBString;(*'Version'*)(*oi_readonly*)
      end;
  PTOpenglData=^TOpenglData;
  TOpenglData=packed record
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:GDBString;(*'Version'*)(*oi_readonly*)
            RD_Extensions:GDBString;(*'Extensions'*)(*oi_readonly*)
            RD_Vendor:GDBString;(*'Vendor'*)(*oi_readonly*)
            RD_Restore_Mode:trestoremode;(*'Restore mode'*)
            RD_VSync:TGDB3StateBool;(*'VSync'*)
      end;
  trd=packed record
            RD_RendererBackEnd:TEnumData;(*'Render backend'*)
            RD_CurrentWAParam:TFaceTypedData;
            RD_GLUVersion:PGDBString;(*'GLU Version'*)(*oi_readonly*)
            RD_GLUExtensions:PGDBString;(*'GLU Extensions'*)(*oi_readonly*)
            RD_BackGroundColor:PTRGB;(*'Background color'*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_MaxWidth:pGDBInteger;(*'Max width'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Max line width'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Max point size'*)(*oi_readonly*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_LastCalcVisible:GDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
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
             SYS_SystmGeometryColor:PTGDBPaletteColor;(*'Help color'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'IsHistoryLineCreated'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Alternate font file'*)
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
             DWG_SystmGeometryDraw:PGDBBoolean;(*'System geometry'*)
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
  tview=packed record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
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
               end;
  tinterface=packed record
              INTF_ShowScrollBars:PGDBBoolean;(*'Show scroll bars'*)
              INTF_ShowDwgTabs:PGDBBoolean;(*'Show drawing tabs'*)
              INTF_DwgTabsPosition:PTAlign;(*'Drawing tabs position'*)
              INTF_ShowDwgTabCloseBurron:PGDBBoolean;(*'Show drawing tab close button'*)
              INTF_DefaultControlHeight:PGDBInteger;(*'Default control height'*)(*oi_readonly*)
              INTF_DefaultEditorFontHeight:PGDBInteger;(*'Default editor font height'*)
              INTF_OBJINSP_Properties:tobjinspinterface;(*'Object inspector properties'*)
             end;
  tdisp=packed record
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
             DISP_GripSize:PGDBInteger;(*'Grip size'*)
             DISP_UnSelectedGripColor:PTGDBPaletteColor;(*'Unselected grip color'*)
             DISP_SelectedGripColor:PTGDBPaletteColor;(*'Selected grip color'*)
             DISP_HotGripColor:PTGDBPaletteColor;(*'Hot grip color'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=packed record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Render'*)
    DISP:tdisp;
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    INTF:tinterface;(*'Interface'*)
    VIEW:tview;(*'View'*)
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
    {$IFDEF LCLGTK2}
       SysVar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion:='GTK+'+inttostr(gtk_major_version)+'.'+inttostr(gtk_minor_version)+'.'+inttostr(gtk_micro_version);
    {$ENDIF}

  {$ENDIF}
    SysVar.debug.languadedeb.NotEnlishWord:=0;
    SysVar.debug.languadedeb.UpdatePO:=0;
end.

