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
  tmemdeb=record
                GetMemCount,FreeMemCount:PGDBInteger;
                TotalAllocMb,CurrentAllocMB:PGDBInteger;
          end;
  trenderdeb=record
                   primcount,pointcount,bathcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tlanguadedeb=record
                   UpdatePO,NotEnlishWord,DebugWord:GDBInteger;
             end;

  tdebug=record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               languadedeb:tlanguadedeb;
               memi2:GDBInteger;(*'MemMan::I2'*)
               int1:GDBInteger;
        end;
  tpath=record
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
  trd=record
            RD_Renderer:PGDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:PGDBString;(*'Version'*)(*oi_readonly*)
            RD_Vendor:PGDBString;(*'Vendor'*)(*oi_readonly*)
            RD_MaxWidth:pGDBInteger;(*'Max width'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Max line width'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Max point size'*)(*oi_readonly*)
            RD_BackGroundColor:PRGB;(*'Background color'*)
            RD_Restore_Mode:ptrestoremode;(*'Restore mode'*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_LastCalcVisible:GDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Maximum single pass time'*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_VSync:PTVSControl;(*'VSync'*)
            RD_Light:PGDBBoolean;(*'Light'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Degradation while pan'*)
            RD_LineSmooth:PGDBBoolean;(*'Line smoth'*)
      end;
  tsave=record
              SAVE_Auto_On:PGDBBoolean;(*'Autosave'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Time to autosave'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Time between autosaves'*)
              SAVE_Auto_FileName:PGDBString;(*'Autosave file name'*)
        end;
  tcompileinfo=record
                     SYS_Compiler:GDBString;(*'Compiler'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Compiler version'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Target CPU'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Target OS'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Compile date'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Compile time'*)(*oi_readonly*)
                     SYS_LCLVersion:GDBString;(*'LCL version'*)(*oi_readonly*)
               end;

  tsys=record
             SYS_Version:PGDBString;(*'Program version'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Build info'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Uptime'*)(*oi_readonly*)
             SYS_SystmGeometryColor:PGDBInteger;(*'Help color'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'IsHistoryLineCreated'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Alternate font file'*)
       end;
  tdwg=record
             DWG_DrawMode:PGDBInteger;(*'Draw mode?'*)
             DWG_OSMode:PGDBInteger;(*'Snap mode'*)
             DWG_PolarMode:PGDBInteger;(*'Polar tracking mode'*)
             DWG_CLayer:PGDBInteger;(*'Current layer'*)
             DWG_CLinew:PGDBInteger;(*'Current line weigwt'*)
             DWG_CColor:PGDBInteger;(*'Current color'*)
             DWG_LTScale:PGDBDouble;(*'Drawing line type scale'*)
             DWG_EditInSubEntry:PGDBBoolean;(*'SubEntities edit'*)
             DWG_AdditionalGrips:PGDBBoolean;(*'Additional grips'*)
             DWG_SystmGeometryDraw:PGDBBoolean;
             DWG_HelpGeometryDraw:PGDBBoolean;
             DWG_StepGrid:PGDBvertex2D;
             DWG_OriginGrid:PGDBvertex2D;
             DWG_DrawGrid:PGDBBoolean;
             DWG_SnapGrid:PGDBBoolean;
             DWG_SelectedObjToInsp:PGDBBoolean;(*'SelectedObjToInsp'*)
       end;
  TLayerControls=record
                       DSGN_LC_Net:PTLayerControl;(*'Nets'*)
                       DSGN_LC_Cable:PTLayerControl;(*'Cables'*)
                       DSGN_LC_Leader:PTLayerControl;(*'Leaders'*)
                 end;

  tdesigning=record
             DSGN_LayerControls:TLayerControls;(*'Control layers'*)
             DSGN_TraceAutoInc:PGDBBoolean;(*'Increment trace names'*)
             DSGN_LeaderDefaultWidth:PGDBDouble;(*'Default leader width'*)
             DSGN_HelpScale:PGDBDouble;(*'Scale of auxiliary elements'*)
       end;
  tview=record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  tmisc=record
              PMenuProjType,PMenuCommandLine,PMenuHistoryLine,PMenuDebugObjInsp:pGDBPointer;
              ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Show hidden fields'*)
        end;
  tdisp=record
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Render'*)
    DISP:tdisp;
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    VIEW:tview;(*'View'*)
    MISC:tmisc;(*'Miscellaneous'*)
    debug:tdebug;(*'Debug'*)
  end;
{EXPORT-}
var
  sysvar: gdbsysvariable;
implementation
end.

