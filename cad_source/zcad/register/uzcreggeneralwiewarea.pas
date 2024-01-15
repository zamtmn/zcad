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

unit uzcreggeneralwiewarea;
{$INCLUDE zengineconfig.inc}
interface
uses uzglbackendmanager,uzglgeometry,uzeentitiestree,uzcsysvars,uzglviewareageneral,
     uzeentabstracttext,uzbpaths,uzctranslations,UUnitManager,TypeDescriptors,uzcLog,
     Varman,
     uzgldrawcontext,uzccommandsmanager,uzepalette;
type
  TShowCursorHelper=class
    class procedure ShowCursorHandlerDrawLine(var DC:TDrawContext);
  end;

implementation

class procedure TShowCursorHelper.ShowCursorHandlerDrawLine(var DC:TDrawContext);
begin
  if commandmanager.CurrCmd.pcommandrunning<>nil then begin
    if commandmanager.CurrCmd.pcommandrunning.IData.DrawFromBasePoint then begin
      dc.drawer.SetColor(palette[{7}DC.SystmGeometryColor].rgb);
      dc.drawer.DrawLine3DInModelSpace(commandmanager.CurrCmd.pcommandrunning.IData.BasePoint,commandmanager.CurrCmd.pcommandrunning.IData.currentPointValue,dc.DrawingContext.matrixs);
    end;
  end;
end;


initialization
  TGeneralViewArea.RegisterShowCursorHandler(TShowCursorHelper.ShowCursorHandlerDrawLine);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CursorSize','Integer',@sysvarDISPCursorSize);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_OSSize','Double',@sysvarDISPOSSize);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CrosshairSize','Double',@SysVarDISPCrosshairSize);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_BackGroundColor','TRGB',@sysvarDISPBackGroundColor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxRenderTime','Integer',@sysvarRDMaxRenderTime);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_ZoomFactor','Double',@sysvarDISPZoomFactor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','Boolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','Boolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryColor','TGDBPaletteColor',@sysvarDISPSystmGeometryColor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_HotGripColor','TGDBPaletteColor',@sysvarDISPHotGripColor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SelectedGripColor','TGDBPaletteColor',@sysvarDISPSelGripColor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_UnSelectedGripColor','TGDBPaletteColor',@sysvarDISPUnSelGripColor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_OSMode','TGDBOSMode',@sysvarDWGOSMode);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_OSModeControl','Boolean',@sysvarDWGOSModeControl);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_GripSize','Integer',@sysvarDISPGripSize);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_ColorAxis','Boolean',@sysvarDISPColorAxis);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_DrawZAxis','Boolean',@sysvarDISPDrawZAxis);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_DrawInsidePaintMessage','TGDB3StateBool',@sysvarDrawInsidePaintMessage);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_PolarMode','Boolean',@sysvarDWGPolarMode);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LineSmooth','Boolean',@SysVarRDLineSmooth);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_UseStencil','Boolean',@sysvarRDUseStencil);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LastRenderTime','Integer',@sysvarRDLastRenderTime);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_LastUpdateTime','Integer',@sysvarRDLastUpdateTime);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_Enabled','Boolean',@SysVarRDImageDegradationEnabled);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_PrefferedRenderTime','Integer',@SysVarRDImageDegradationPrefferedRenderTime);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_ID_MaxDegradationFactor','Double',@SysVarRDImageDegradationMaxDegradationFactor);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_RemoveSystemCursorFromWorkArea','Boolean',@SysVarDISPRemoveSystemCursorFromWorkArea);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_SelNew','Boolean',@sysvarDSGNSelNew);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_EditInSubEntry','Boolean',@sysvarDWGEditInSubEntry);

units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_SpatialNodeCount','Integer',@SysVarRDSpatialNodeCount);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_SpatialNodesDepth','Integer',@SysVarRDSpatialNodesDepth);

units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_RotateTextInLT','Boolean',@sysvarDWGRotateTextInLT);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxLTPatternsInEntity','Integer',@SysVarRDMaxLTPatternsInEntity);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_PanObjectDegradation','Boolean',@SysVarRDPanObjectDegradation);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_OTrackTimerInterval','Integer',@sysvarDSGNOTrackTimerInterval);


units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_EntityMoveStartTimerInterval','Integer',@sysvarDSGNEntityMoveStartTimerInterval);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_EntityMoveStartOffset','Integer',@sysvarDSGNEntityMoveStartOffset);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DSGN_EntityMoveByMouseUp','Boolean',@sysvarDSGNEntityMoveByMouseUp);

units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_LWDisplayScale','Integer',@sysvarDISPLWDisplayScale);
units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_Light','Boolean',@sysvarRDLight);

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
SysVar.DISP.DISP_RemoveSystemCursorFromWorkArea:=@SysVarDISPRemoveSystemCursorFromWorkArea;

sysvar.RD.RD_DrawInsidePaintMessage:=@sysvarDrawInsidePaintMessage;

sysvar.DWG.DWG_OSMode:=@sysvarDWGOSMode;
sysvar.DWG.DWG_PolarMode:=@sysvarDWGPolarMode;
sysvar.RD.RD_LastRenderTime:=@sysvarRDLastRenderTime;
sysvar.RD.RD_LastUpdateTime:=@sysvarRDLastUpdateTime;
SysVar.RD.RD_ImageDegradation.RD_ID_Enabled:=@SysVarRDImageDegradationEnabled;
SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime:=@SysVarRDImageDegradationPrefferedRenderTime;
SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=@SysVarRDImageDegradationCurrentDegradationFactor;
SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor:=@SysVarRDImageDegradationMaxDegradationFactor;

sysvar.DWG.DWG_EditInSubEntry:=@sysvarDWGEditInSubEntry;

SysVar.RD.RD_SpatialNodeCount:=@SysVarRDSpatialNodeCount;
SysVar.RD.RD_SpatialNodesDepth:=@SysVarRDSpatialNodesDepth;

SysVar.DWG.DWG_RotateTextInLT:=@sysvarDWGRotateTextInLT;
SysVar.RD.RD_MaxLTPatternsInEntity:=@SysVarRDMaxLTPatternsInEntity;
SysVar.RD.RD_PanObjectDegradation:=@SysVarRDPanObjectDegradation;
sysvar.RD.RD_RendererBackEnd:=@BackendsNames;

sysvar.DSGN.DSGN_OTrackTimerInterval:=@sysvarDSGNOTrackTimerInterval;
sysvar.DSGN.DSGN_EntityMoveStartTimerInterval:=@sysvarDSGNEntityMoveStartTimerInterval;
sysvar.DSGN.DSGN_EntityMoveStartOffset:=@sysvarDSGNEntityMoveStartOffset;
sysvar.DSGN.DSGN_EntityMoveByMouseUp:=@sysvarDSGNEntityMoveByMouseUp;

sysvar.DSGN.DSGN_SelNew:=@sysvarDSGNSelNew;
sysvar.RD.RD_LastCalcVisible:=@sysvarRDLastCalcVisible;;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

