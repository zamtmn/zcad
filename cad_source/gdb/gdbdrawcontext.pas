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
uses gdbasetypes,gdbase,uzglabstractdrawer;
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
             end;
implementation
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('gdbase.initialization');{$ENDIF}
end.

