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

unit uzeutils;
{$INCLUDE def.inc}
interface
uses
gdbase,GDBasetypes,uzeentity,geometry;
procedure LayerCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
procedure LTypeCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
implementation
procedure LayerCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.Layer then
                                  inc(Counter);
end;
procedure LTypeCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.LineType then
                                  inc(Counter);
end;
begin
end.
