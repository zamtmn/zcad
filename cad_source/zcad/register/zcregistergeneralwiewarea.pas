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

unit zcregistergeneralwiewarea;
{$INCLUDE def.inc}
interface
uses zcadsysvars,generalviewarea,paths,intftranslations,UUnitManager,TypeDescriptors;
implementation

initialization
{$IFDEF DEBUGINITSECTION}LogOut('zcregisterzscript.initialization');{$ENDIF}
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CursorSize','GDBInteger',@sysvarDISPCursorSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_OSSize','GDBDouble',@sysvarDISPOSSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CrosshairSize','GDBDouble',@SysVarDISPCrosshairSize);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_BackGroundColor','TRGB',@sysvarDISPBackGroundColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxRenderTime','GDBInteger',@sysvarRDMaxRenderTime);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_ZoomFactor','GDBDouble',@sysvarDISPZoomFactor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','GDBBoolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryDraw','GDBBoolean',@sysvarDISPSystmGeometryDraw);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_SystmGeometryColor','TGDBPaletteColor',@sysvarDISPSystmGeometryColor);
units.CreateExtenalSystemVariable(SupportPath,expandpath('*rtl/system.pas'),InterfaceTranslate,'DWG_OSMode','TGDBOSMode',@sysvarDWGOSMode);

sysvar.DISP.DISP_CursorSize:=@sysvarDISPCursorSize;sysvar.DISP.DISP_OSSize:=@sysvarDISPOSSize;
sysvar.DISP.DISP_CrosshairSize:=@SysVarDISPCrosshairSize;
sysvar.DISP.DISP_BackGroundColor:=@sysvarDISPBackGroundColor;
sysvar.RD.RD_MaxRenderTime:=@sysvarRDMaxRenderTime;
sysvar.DISP.DISP_ZoomFactor:=@sysvarDISPZoomFactor;
sysvar.DISP.DISP_SystmGeometryDraw:=@sysvarDISPSystmGeometryDraw;
sysvar.DISP.DISP_SystmGeometryColor:=@sysvarDISPSystmGeometryColor;

sysvar.DWG.DWG_OSMode:=@sysvarDWGOSMode
finalization
end.

