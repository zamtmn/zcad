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
unit gdbdrawcontext;
{$INCLUDE def.inc}
interface
uses gdbpalette,gdbasetypes,gdbase,uzglabstractdrawer,gdbobjectsconstdef,geometry;
type
TDrawContext=packed record
                   VisibleActualy:TActulity;
                   InfrustumActualy:TActulity;
                   DRAWCOUNT:TActulity;
                   Subrender:GDBInteger;
                   Selected:GDBBoolean;
                   SysLayer:GDBPointer;
                   MaxDetail:GDBBoolean;
                   DrawMode:GDBBoolean;
                   OwnerLineWeight:GDBSmallInt;
                   OwnerColor:GDBInteger;
                   MaxWidth:GDBInteger;
                   ScrollMode:GDBBoolean;
                   Zoom:GDBDouble;
                   drawer:TZGLAbstractDrawer;
                   matrixs:tmatrixs;
                   pcamera:PGDBBaseCamera;
                   SystmGeometryDraw:boolean;
                   SystmGeometryColor:TGDBPaletteColor;
             end;
function CreateAbstractRC:TDrawContext;
implementation
function CreateAbstractRC:TDrawContext;
begin
      result.Subrender:=0;
      result.Selected:=false;
      result.VisibleActualy:=0;
      result.InfrustumActualy:=0;
      result.DRAWCOUNT:=0;
      result.SysLayer:=nil;
      result.MaxDetail:=true;
      result.DrawMode:=true;
      result.OwnerLineWeight:=-3;
      result.OwnerColor:=ClWhite;
      result.MaxWidth:=20;
      result.ScrollMode:=false;
      result.Zoom:=1;
      result.drawer:=nil;
      result.matrixs.pmodelMatrix:=@OneMatrix;
      result.matrixs.pprojMatrix:=@OneMatrix;
      result.matrixs.pviewport:=@DefaultVP;
      result.pcamera:=nil;
      result.SystmGeometryDraw:=false;
      result.SystmGeometryColor:=1;
end;
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('gdbase.initialization');{$ENDIF}
end.

