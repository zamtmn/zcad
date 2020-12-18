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

unit uzcreggeneralwiewarea;
{$INCLUDE def.inc}
interface
uses uzglbackendmanager,uzglgeometry,uzeentitiestree,uzcsysvars,uzglviewareageneral,
     uzeentabstracttext,uzbpaths,uzctranslations,UUnitManager,TypeDescriptors,LazLogger,
     uzgldrawcontext,uzccommandsmanager,uzepalette;
type
  TShowCursorHelper=class
    class procedure ShowCursorHandlerDrawLine(var DC:TDrawContext);
  end;

implementation

class procedure TShowCursorHelper.ShowCursorHandlerDrawLine(var DC:TDrawContext);
begin
  if commandmanager.pcommandrunning<>nil then begin
    if commandmanager.pcommandrunning.IData.DrawFromBasePoint then begin
      dc.drawer.SetColor(palette[{7}DC.SystmGeometryColor].rgb);
      dc.drawer.DrawLine3DInModelSpace(commandmanager.pcommandrunning.IData.BasePoint,commandmanager.pcommandrunning.IData.currentPointValue,dc.DrawingContext.matrixs);
    end;
  end;
end;


initialization
  TGeneralViewArea.RegisterShowCursorHandler(TShowCursorHelper.ShowCursorHandlerDrawLine);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CursorSize','GDBInteger',@sysvarDISPCursorSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_OSSize','GDBDouble',@sysvarDISPOSSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CrosshairSize','GDBDouble',@SysVarDISPCrosshairSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_BackGroundColor','TRGB',@sysvarDISPBackGroundColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxRenderTime','GDBInteger',@sysvarRDMaxRenderTime);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_ZoomFactor','GDBDouble',@sysvarDISPZoomFactor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','GDBBoolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','GDBBoolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryColor','TGDBPaletteColor',@sysvarDISPSystmGeometryColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_HotGripColor','TGDBPaletteColor',@sysvarDISPHotGripColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SelectedGripColor','TGDBPaletteColor',@sysvarDISPSelGripColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_UnSelectedGripColor','TGDBPaletteColor',@sysvarDISPUnSelGripColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_OSMode','TGDBOSMode',@sysvarDWGOSMode);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_OSModeControl','Boolean',@sysvarDWGOSModeControl);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_GripSize','GDBInteger',@sysvarDISPGripSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_ColorAxis','GDBBoolean',@sysvarDISPColorAxis);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_DrawZAxis','GDBBoolean',@sysvarDISPDrawZAxis);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_DrawInsidePaintMessage','TGDB3StateBool',@sysvarDrawInsidePaintMessage);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_PolarMode','GDBBoolean',@sysvarDWGPolarMode);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LineSmooth','GDBBoolean',@SysVarRDLineSmooth);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_UseStencil','GDBBoolean',@sysvarRDUseStencil);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LastRenderTime','GDBInteger',@sysvarRDLastRenderTime);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LastUpdateTime','GDBInteger',@sysvarRDLastUpdateTime);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_Enabled','GDBBoolean',@SysVarRDImageDegradationEnabled);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_PrefferedRenderTime','GDBInteger',@SysVarRDImageDegradationPrefferedRenderTime);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_MaxDegradationFactor','GDBDouble',@SysVarRDImageDegradationMaxDegradationFactor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_RemoveSystemCursorFromWorkArea','GDBBoolean',@SysVarRDRemoveSystemCursorFromWorkArea);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_SelNew','GDBBoolean',@sysvarDSGNSelNew);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_EditInSubEntry','GDBBoolean',@sysvarDWGEditInSubEntry);

units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_SpatialNodeCount','GDBInteger',@SysVarRDSpatialNodeCount);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_SpatialNodesDepth','GDBInteger',@SysVarRDSpatialNodesDepth);

units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_RotateTextInLT','GDBBoolean',@sysvarDWGRotateTextInLT);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxLTPatternsInEntity','GDBInteger',@SysVarRDMaxLTPatternsInEntity);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_PanObjectDegradation','GDBBoolean',@SysVarRDPanObjectDegradation);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_OTrackTimerInterval','GDBInteger',@sysvarDSGNOTrackTimerInterval);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_LWDisplayScale','GDBInteger',@sysvarDISPLWDisplayScale);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_Light','GDBBoolean',@sysvarRDLight);

sysvar.DISP.DISP_CursorSize:=@sysvarDISPCursorSize;
sysvar.DISP.DISP_OSSize:=@sysvarDISPOSSize;
sysvar.DISP.DISP_CrosshairSize:=@SysVarDISPCrosshairSize;
sysvar.DISP.DISP_BackGroundColor:=@sysvarDISPBackGroundColor;
sysvar.RD.RD_MaxRenderTime:=@sysvarRDMaxRenderTime;
sysvar.DISP.DISP_ZoomFactor:=@sysvarDISPZoomFactor;
sysvar.DISP.DISP_SystmGeometryDraw:=@sysvarDISPSystmGeometryDraw;
sysvar.DISP.DISP_SystmGeometryColor:=@sysvarDISPSystmGeometryColor;
sysvar.DISP.DISP_HotGripColor:=@sysvarDISPHotGripColor;
sysvar.DISP.DISP_SelectedGripColor:=@sysvarDISPSelGripColor;
sysvar.DISP.DISP_UnSelectedGripColor:=@sysvarDISPUnSelGripColor;
sysvar.DISP.DISP_GripSize:=@sysvarDISPGripSize;
sysvar.DISP.DISP_ColorAxis:=@sysvarDISPColorAxis;
sysvar.DISP.DISP_DrawZAxis:=@sysvarDISPDrawZAxis;

sysvar.DISP.DISP_LWDisplayScale:=@sysvarDISPLWDisplayScale;
sysvar.DISP.DISP_DefaultLW:=@sysvarDISPDefaultLW;

sysvar.RD.RD_DrawInsidePaintMessage:=@sysvarDrawInsidePaintMessage;

sysvar.DWG.DWG_OSMode:=@sysvarDWGOSMode;
sysvar.DWG.DWG_PolarMode:=@sysvarDWGPolarMode;
sysvar.RD.RD_LineSmooth:=@SysVarRDLineSmooth;
sysvar.RD.RD_UseStencil:=@sysvarRDUseStencil;
sysvar.RD.RD_LastRenderTime:=@sysvarRDLastRenderTime;
sysvar.RD.RD_LastUpdateTime:=@sysvarRDLastUpdateTime;
SysVar.RD.RD_ImageDegradation.RD_ID_Enabled:=@SysVarRDImageDegradationEnabled;
SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime:=@SysVarRDImageDegradationPrefferedRenderTime;
SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=@SysVarRDImageDegradationCurrentDegradationFactor;
SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor:=@SysVarRDImageDegradationMaxDegradationFactor;

SysVar.RD.RD_RemoveSystemCursorFromWorkArea:=@SysVarRDRemoveSystemCursorFromWorkArea;
sysvar.DWG.DWG_EditInSubEntry:=@sysvarDWGEditInSubEntry;

SysVar.RD.RD_SpatialNodeCount:=@SysVarRDSpatialNodeCount;
SysVar.RD.RD_SpatialNodesDepth:=@SysVarRDSpatialNodesDepth;

SysVar.DWG.DWG_RotateTextInLT:=@sysvarDWGRotateTextInLT;
SysVar.RD.RD_MaxLTPatternsInEntity:=@SysVarRDMaxLTPatternsInEntity;
SysVar.RD.RD_PanObjectDegradation:=@SysVarRDPanObjectDegradation;
sysvar.RD.RD_RendererBackEnd:=@BackendsNames;

sysvar.DSGN.DSGN_OTrackTimerInterval:=@sysvarDSGNOTrackTimerInterval;
sysvar.DSGN.DSGN_SelNew:=@sysvarDSGNSelNew;
sysvar.RD.RD_LastCalcVisible:=@sysvarRDLastCalcVisible;
sysvar.RD.RD_Light:=@sysvarRDLight;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

