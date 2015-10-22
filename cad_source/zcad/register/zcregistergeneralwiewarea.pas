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
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CursorSize','GDBInteger',@sysvarDISPCursorSize);
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_OSSize','GDBDouble',@sysvarDISPOSSize);
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_CrosshairSize','GDBDouble',@SysVarDISPCrosshairSize);
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'DISP_BackGroundColor','TRGB',@sysvarDISPBackGroundColor);
units.CreateExtenalSystemVariable(sysvar.PATH.Support_Path,expandpath('*rtl/system.pas'),InterfaceTranslate,'RD_MaxRenderTime','GDBInteger',@sysvarRDMaxRenderTime);
sysvar.DISP.DISP_CursorSize:=@sysvarDISPCursorSize;
sysvar.DISP.DISP_OSSize:=@sysvarDISPOSSize;
sysvar.DISP.DISP_CrosshairSize:=@SysVarDISPCrosshairSize;
sysvar.DISP.DISP_BackGroundColor:=@sysvarDISPBackGroundColor;
sysvar.RD.RD_MaxRenderTime:=@sysvarRDMaxRenderTime;
finalization
end.

