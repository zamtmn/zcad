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
uses gdbasetypes,
     gdbase;
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
  {°}
  PTVSControl=^TVSControl;
  TVSControl=(
                TVSOn(*'On'*),
                TVSOff(*'Off'*),
                TVSDefault(*'Default'*)
             );
  TImageDegradation=packed record
                          RD_ID_Enabled:PGDBBoolean;(*'Enabled'*)
                          RD_ID_CurrentDegradationFactor:GDBDouble;(*'Current degradation factor'*)(*oi_readonly*)
                          RD_ID_MaxDegradationFactor:PGDBDouble;(*'Max degradation factor'*)
                          RD_ID_PrefferedRenderTime:PGDBInteger;(*'Preffered rendertime'*)
                      end;
  trd=packed record
            RD_Renderer:PGDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:PGDBString;(*'Version'*)(*oi_readonly*)
            RD_Extensions:PGDBString;(*'Extensions'*)(*oi_readonly*)
            RD_Vendor:PGDBString;(*'Vendor'*)(*oi_readonly*)
            RD_GLUVersion:PGDBString;(*'GLU Version'*)(*oi_readonly*)
            RD_GLUExtensions:PGDBString;(*'GLU Extensions'*)(*oi_readonly*)
            RD_MaxWidth:pGDBInteger;(*'Max width'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Max line width'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Max point size'*)(*oi_readonly*)
            RD_BackGroundColor:PTRGB;(*'Background color'*)
            RD_Restore_Mode:ptrestoremode;(*'Restore mode'*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_LastCalcVisible:GDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Maximum single pass time'*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_VSync:PTVSControl;(*'VSync'*)
            RD_Light:PGDBBoolean;(*'Light'*)
            RD_LineSmooth:PGDBBoolean;(*'Line smoth'*)
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
       end;
  tview=packed record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  tinterface=packed record
              INTF_ShowScrollBars:PGDBBoolean;(*'Show scroll bars'*)
              INTF_ShowDwgTabs:PGDBBoolean;(*'Show drawing tabs'*)
              INTF_DwgTabsPosition:PTAlign;(*'Drawing tabs position'*)
              INTF_ShowDwgTabCloseBurron:PGDBBoolean;(*'Show drawing tab close button'*)
              INTF_ShowLinesInObjInsp:PGDBBoolean;(*'Show lines in object inspector'*)
             end;
  tdisp=packed record
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
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
end.

